class ProjectIssueLister < GithubGraphQlClient
  attr_reader :organization, :repo, :project_name, :column_name

  PAGE_SIZE = 100

  def initialize(params)
    @organization = params.fetch(:organization)
    @repo = params.fetch(:repo)
    @project_name = params.fetch(:project_name)
    @column_name = params.fetch(:column_name)
    super(params)
  end

  def issues
    end_cursor = nil
    data = get_issues(end_cursor)

    issues, page_info = issues_and_page_info(data)
    next_page = page_info.fetch("hasNextPage")
    end_cursor = page_info.fetch("endCursor")

    while next_page do
      data = get_issues(end_cursor)
      batch, page_info = issues_and_page_info(data)
      next_page = page_info.fetch("hasNextPage")
      end_cursor = page_info.fetch("endCursor")
      issues = issues + batch
    end

    issues.map { |issue| Issue.new(id: issue.dig("content", "id"), github_token: github_token) }
  end

  private

  def get_issues(end_cursor = nil)
    json = run_query(
      body: issues_query(end_cursor),
      token: github_token
    )

    JSON.parse(json)
  end

  def issues_query(end_cursor)
    after = end_cursor.nil? ? "" : %[, after: "#{end_cursor}"]
    %[
      {
        repository(owner: "#{organization}", name: "#{repo}") {
          projects(search: "#{project_name}", first: 1) {
            nodes {
              id
              columns(first: #{PAGE_SIZE}) {
                nodes {
                  id
                  name
                  cards(first: #{PAGE_SIZE} #{after}) {
                    nodes {
                      content {
                        ... on Issue {
                          id
                          number
                          title
                        }
                      }
                    }
                    pageInfo {
                      hasNextPage
                      endCursor
                    }
                  }
                }
              }
            }
          }
        }
      }
    ]
  end

  def issues_and_page_info(data)
    column = data.dig("data", "repository", "projects", "nodes")
      .first
      .dig("columns", "nodes")
      .find {|c| c.fetch("name") == "Icebox" }

    cards = column.dig("cards", "nodes")
    page_info = column.dig("cards", "pageInfo")

    [ cards, page_info ]
  end
end

__END__


{
  repository(owner: "ministryofjustice", name: "cloud-platform") {
    projects(search: "Cloud Platform Team Kanban Board", first: 1) {
      edges {
        node {
          id
          columns(first: 100) {
            nodes {
              id
              name
              cards(first: 2) {
                nodes {
                  content {
                    ... on Issue {
                      id
                      number
                      title
                    }
                  }
                }
                pageInfo {
                  hasNextPage
                  endCursor
                }
              }
            }
          }
        }
      }
    }
  }
}


