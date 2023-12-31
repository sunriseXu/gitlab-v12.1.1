# frozen_string_literal: true

class Explore::OnboardingController < Explore::ApplicationController
  include ::OnboardingExperimentHelper

  before_action :authenticate_user!
  before_action :set_project!

  layout 'onboarding'

  private

  def set_project!
    @project = get_onboarding_demo_project

    return render_404 unless @project && can?(current_user, :read_project, @project)

    session[:onboarding_project] = { project_full_path: @project.web_url, project_name: @project.name }
  end

  def get_onboarding_demo_project
    Project.find_by_full_path("gitlab-org/gitlab-ce") if allow_access_to_onboarding?
  end
end
