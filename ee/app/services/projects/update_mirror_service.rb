# frozen_string_literal: true

module Projects
  class UpdateMirrorService < BaseService
    Error = Class.new(StandardError)
    UpdateError = Class.new(Error)

    def execute
      unless project.mirror?
        return success
      end

      unless can?(current_user, :push_code_to_protected_branches, project)
        return error("The mirror user is not allowed to push code to all branches on this project.")
      end

      update_tags do
        project.fetch_mirror(forced: true)
      end

      update_branches
      update_lfs_objects

      success
    rescue Gitlab::Shell::Error, Gitlab::Git::BaseError, UpdateError => e
      error(e.message)
    end

    private

    def update_branches
      local_branches = repository.branches.each_with_object({}) { |branch, branches| branches[branch.name] = branch }

      errors = []

      repository.upstream_branches.each do |upstream_branch|
        name = upstream_branch.name

        next if skip_branch?(name)

        local_branch = local_branches[name]

        if local_branch.nil?
          result = CreateBranchService.new(project, current_user).execute(name, upstream_branch.dereferenced_target.sha, create_master_if_empty: false)
          if result[:status] == :error
            errors << result[:message]
          end
        elsif local_branch.dereferenced_target == upstream_branch.dereferenced_target
          # Already up to date
        elsif repository.diverged_from_upstream?(name)
          handle_diverged_branch(upstream_branch, local_branch, name, errors)
        else
          begin
            repository.ff_merge(current_user, upstream_branch.dereferenced_target, name)
          rescue Gitlab::Git::PreReceiveError, Gitlab::Git::CommitError => e
            errors << e.message
          end
        end
      end

      unless errors.empty?
        raise UpdateError, errors.join("\n\n")
      end
    end

    def update_tags(&block)
      old_tags = repository_tags_with_target.each_with_object({}) { |tag, tags| tags[tag.name] = tag }

      fetch_result = yield
      return fetch_result unless fetch_result

      repository.expire_tags_cache

      tags = repository_tags_with_target

      tags.each do |tag|
        old_tag = old_tags[tag.name]
        tag_target = tag.dereferenced_target.sha
        old_tag_target = old_tag ? old_tag.dereferenced_target.sha : Gitlab::Git::BLANK_SHA

        next if old_tag_target == tag_target

        Git::TagPushService.new(
          project,
          current_user,
          {
            oldrev: old_tag_target,
            newrev: tag_target,
            ref: "#{Gitlab::Git::TAG_REF_PREFIX}#{tag.name}",
            mirror_update: true
          }
        ).execute
      end

      fetch_result
    end

    def update_lfs_objects
      result = Projects::LfsPointers::LfsImportService.new(project).execute

      if result[:status] == :error
        log_error(result[:message])
        # Uncomment once https://gitlab.com/gitlab-org/gitlab-ce/issues/61834 is closed
        # raise UpdateError, result[:message]
      end
    end

    def handle_diverged_branch(upstream, local, branch_name, errors)
      if project.mirror_overwrites_diverged_branches?
        newrev = upstream.dereferenced_target.sha
        oldrev = local.dereferenced_target.sha

        # Gitaly migration: https://gitlab.com/gitlab-org/gitaly/issues/1246
        ::Gitlab::GitalyClient::StorageSettings.allow_disk_access do
          repository.update_branch(branch_name, user: current_user, newrev: newrev, oldrev: oldrev)
        end
      elsif branch_name == project.default_branch
        # Cannot be updated
        errors << "The default branch (#{project.default_branch}) has diverged from its upstream counterpart and could not be updated automatically."
      else
        # We ignore diverged branches other than the default branch
      end
    end

    # In Git is possible to tag blob objects, and those blob objects don't point to a Git commit so those tags
    # have no target.
    def repository_tags_with_target
      repository.tags.select(&:dereferenced_target)
    end

    def skip_branch?(name)
      project.only_mirror_protected_branches && !ProtectedBranch.protected?(project, name)
    end

    def service_logger
      @service_logger ||= Gitlab::UpdateMirrorServiceJsonLogger.build
    end

    def base_payload
      {
        user_id: current_user.id,
        project_id: project.id,
        import_url: project.safe_import_url
      }
    end

    def log_error(error_message)
      service_logger.error(base_payload.merge(error_message: error_message))
    end
  end
end
