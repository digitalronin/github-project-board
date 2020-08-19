#!/usr/bin/env ruby

require_relative '../lib/github_project'

OWNER = "ministryofjustice"
REPO = "cloud-platform"

# Icebox column of the github project board
ICEBOX_COLUMN_ID = "MDEzOlByb2plY3RDb2x1bW4xMDQ3NDkzMw=="

params = {
  organization: OWNER,
  repo: REPO,
  github_token: ENV.fetch("GITHUB_TOKEN")
}

IssueLister.new(params).open_issues.each do |hash|
  issue_id = hash.dig("node", "id")
  pp Issue.new(
    id: issue_id,
    github_token: ENV.fetch("GITHUB_TOKEN")
  ).add_to_project_column(ICEBOX_COLUMN_ID)
end
