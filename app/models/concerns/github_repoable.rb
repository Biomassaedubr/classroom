# frozen_string_literal: true
module GitHubRepoable
  extend ActiveSupport::Concern

  def add_team_to_github_repository
    github_repository = GitHubRepository.new(organization.github_client, github_repo_id)
    github_team       = GitHubTeam.new(organization.github_client, github_team_id)

    github_team.add_team_repository(github_repository.full_name, repository_permissions)
  end

  def create_github_repository
    repo_description = "#{repo_name} created by GitHub Classroom"
    github_repository = github_organization.create_repository(repo_name,
                                                              private: private?,
                                                              description: repo_description)
    self.github_repo_id = github_repository.id
  end

  def destroy_github_repository
    github_organization.delete_repository(github_repo_id)
  end

  def delete_github_repository_on_failure
    yield
  rescue GitHub::Error
    silently_destroy_github_repository
    raise GitHub::Error, 'Assignment failed to be created'
  end

  def silently_destroy_github_repository
    destroy_github_repository
  end

  def push_starter_code
    return true unless starter_code_repo_id

    client = creator.github_client

    assignment_repository   = GitHubRepository.new(client, github_repo_id)
    starter_code_repository = GitHubRepository.new(client, starter_code_repo_id)

    delete_github_repository_on_failure do
      assignment_repository.get_starter_code_from(starter_code_repository)
    end
  end

  def github_organization
    @github_organization ||= GitHubOrganization.new(organization.github_client, organization.github_id)
  end

  def give_admin_permission?
    student_assignment = respond_to?(:assignment) ? assignment : group_assignment
    student_assignment.students_are_repo_admins?
  end

  def repository_permissions
    {}.tap do |options|
      options[:permission] = 'admin' if give_admin_permission?
    end
  end
end
