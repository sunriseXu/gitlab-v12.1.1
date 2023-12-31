# frozen_string_literal: true

require 'spec_helper'

describe API::PackageFiles do
  let(:user) { create(:user) }
  let(:project) { create(:project, :public) }
  let(:package) { create(:maven_package, project: project) }

  before do
    project.add_developer(user)
  end

  describe 'GET /projects/:id/packages/:package_id/package_files' do
    let(:url) { "/projects/#{project.id}/packages/#{package.id}/package_files" }

    context 'packages feature enabled' do
      before do
        stub_licensed_features(packages: true)
      end

      context 'project is public' do
        it 'returns 200' do
          get api(url)

          expect(response).to have_gitlab_http_status(200)
        end

        it 'returns 404 if package does not exist' do
          get api("/projects/#{project.id}/packages/0/package_files")

          expect(response).to have_gitlab_http_status(404)
        end
      end

      context 'project is private' do
        let(:project) { create(:project, :private) }

        it 'returns 404 for non authenticated user' do
          get api(url)

          expect(response).to have_gitlab_http_status(404)
        end

        it 'returns 404 for a user without access to the project' do
          project.team.truncate

          get api(url, user)

          expect(response).to have_gitlab_http_status(404)
        end

        it 'returns 200 and valid response schema' do
          get api(url, user)

          expect(response).to have_gitlab_http_status(200)
          expect(response).to match_response_schema('public_api/v4/packages/package_files', dir: 'ee')
        end
      end

      context 'with pagination params' do
        let(:per_page) { 2 }
        let!(:package_file_1) { package.package_files[0] }
        let!(:package_file_2) { package.package_files[1] }
        let!(:package_file_3) { package.package_files[2] }

        before do
          stub_licensed_features(packages: true)
        end

        context 'when viewing the first page' do
          it 'returns first 2 packages' do
            get api(url, user), params: { page: 1, per_page: per_page }

            expect_paginated_array_response([package_file_1.id, package_file_2.id])
          end
        end

        context 'viewing the second page' do
          it 'returns the last package' do
            get api(url, user), params: { page: 2, per_page: per_page }

            expect_paginated_array_response([package_file_3.id])
          end
        end
      end
    end

    context 'packages feature disabled' do
      before do
        stub_licensed_features(packages: false)
      end

      it 'returns 403' do
        get api(url, user)

        expect(response).to have_gitlab_http_status(403)
      end
    end
  end
end
