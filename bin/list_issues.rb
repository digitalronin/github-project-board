#!/usr/bin/env ruby

require "json"
require "net/http"

require_relative "../lib/github_graph_ql_client"
require_relative "../lib/issue_lister"

OWNER = "ministryofjustice"
REPO = "cloud-platform"

params = {
  organization: OWNER,
  repo: REPO,
  github_token: ENV.fetch("GITHUB_TOKEN")
}

issues = IssueLister.new(params).open_issues

pp issues
