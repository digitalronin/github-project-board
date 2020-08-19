class RepoIssueLister < GithubGraphQlClient
  attr_reader :organization, :repo

  PAGE_SIZE = 100

  def initialize(params)
    @organization = params.fetch(:organization)
    @repo = params.fetch(:repo)
    super(params)
  end

  def open_issues
    issues = []
    end_cursor = nil

    data = get_issues(end_cursor)

    issues = issues + data.dig("issues", "edges")
    next_page = data.dig("issues", "pageInfo", "hasNextPage")
    end_cursor = data.dig("issues", "pageInfo", "endCursor")

    while next_page do
      data = get_issues(end_cursor)
      issues = issues + data.dig("issues", "edges")
      next_page = data.dig("issues", "pageInfo", "hasNextPage")
      end_cursor = data.dig("issues", "pageInfo", "endCursor")
    end

    issues.map { |issue| Issue.new(id: issue.dig("node", "id"), github_token: github_token) }
  end

  # private

  def get_issues(end_cursor = nil)
    json = run_query(
      body: issues_query(end_cursor),
      token: github_token
    )

    JSON.parse(json).dig("data", "repository")
  end

  def issues_query(end_cursor)
    after = end_cursor.nil? ? "" : %[, after: "#{end_cursor}"]
    %[
    {
      repository(owner: "#{organization}", name: "#{repo}") {
        issues(states: [OPEN], first: #{PAGE_SIZE} #{after}) {
          edges {
            node {
              id
              number
              state
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
    ]
  end
end
