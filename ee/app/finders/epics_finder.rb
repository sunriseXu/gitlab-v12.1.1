# frozen_string_literal: true

class EpicsFinder < IssuableFinder
  def self.scalar_params
    @scalar_params ||= %i[
      parent_id
      author_id
      author_username
      label_name
      start_date
      end_date
      search
    ]
  end

  def self.array_params
    @array_params ||= { label_name: [] }
  end

  def klass
    Epic
  end

  def execute
    raise ArgumentError, 'group_id argument is missing' unless group

    items = init_collection
    items = by_created_at(items)
    items = by_updated_at(items)
    items = by_search(items)
    items = by_author(items)
    items = by_timeframe(items)
    items = by_state(items)
    items = by_label(items)
    items = by_parent(items)
    items = by_iids(items)

    sort(items)
  end

  def group
    return unless params[:group_id]
    return @group if defined?(@group)

    group = Group.find(params[:group_id])

    unless Ability.allowed?(current_user, :read_epic, group)
      raise ActiveRecord::RecordNotFound.new("Could not find a Group with ID #{params[:group_id]}")
    end

    @group = group
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def init_collection
    groups = if params[:iids].present?
               # If we are querying for specific iids, then we should only be looking at
               # those in the group, not any sub-groups (which can have identical iids).
               # The `group` method takes care of checking permissions
               [group]
             else
               groups_user_can_read_epics(group.self_and_descendants)
             end

    Epic.where(group: groups)
  end
  # rubocop: enable CodeReuse/ActiveRecord

  private

  def count_key(value)
    last_value = Array(value).last

    if last_value.is_a?(Integer)
      Epic.states.invert[last_value].to_sym
    else
      last_value.to_sym
    end
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def groups_user_can_read_epics(groups)
    groups = Gitlab::GroupPlansPreloader.new.preload(groups)

    DeclarativePolicy.user_scope do
      groups.select { |g| Ability.allowed?(current_user, :read_epic, g) }
    end
  end
  # rubocop: enable CodeReuse/ActiveRecord

  # rubocop: disable CodeReuse/ActiveRecord
  def by_timeframe(items)
    return items unless params[:start_date] && params[:end_date]

    end_date = params[:end_date].to_datetime.end_of_day
    start_date = params[:start_date].to_datetime.beginning_of_day

    items
      .where('epics.start_date is not NULL or epics.end_date is not NULL')
      .where('epics.start_date is NULL or epics.start_date <= ?', end_date)
      .where('epics.end_date is NULL or epics.end_date >= ?', start_date)
  rescue ArgumentError
    items
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def parent_id?
    params[:parent_id].present?
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def by_parent(items)
    return items unless parent_id?

    items.where(parent_id: params[:parent_id])
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
