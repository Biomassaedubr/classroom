# frozen_string_literal: true
module GitHubTeamable
  extend ActiveSupport::Concern

  def create_github_team
    github_team = organization.github_organization.create_team(title)
    self.github_team_id = github_team.id
  end

  def destroy_github_team
    return true unless github_team_id.present?
    organization.github_organization.delete_team(github_team_id)
  end

  def silently_destroy_github_team
    destroy_github_team
  end
end
