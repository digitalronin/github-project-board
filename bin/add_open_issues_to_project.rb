#!/usr/bin/env ruby

require_relative '../lib/github_project'

OWNER = "ministryofjustice"
REPO = "cloud-platform"

PROJECT_NAME = "Cloud Platform Team Kanban Board"
ICEBOX_COLUMN_NAME = "Icebox"
ICEBOX_COLUMN_ID = "MDEzOlByb2plY3RDb2x1bW4xMDQ3NDkzMw=="

params = {
  organization: OWNER,
  repo: REPO,
  github_token: ENV.fetch("GITHUB_TOKEN")
}

repo_open_issues = RepoIssueLister.new(params).open_issues

project_icebox_issues = ProjectIssueLister.new(params.merge(
  project_name: PROJECT_NAME,
  column_name: ICEBOX_COLUMN_NAME
)).issues

project_issue_ids = project_icebox_issues.map(&:id)
issues_to_add = repo_open_issues.reject { |issue| project_issue_ids.include?(issue.id) }

issues_to_add.map { |issue| issue.add_to_project_column(ICEBOX_COLUMN_ID) }

puts "Added #{issues_to_add.size} issues to #{ICEBOX_COLUMN_NAME}"
