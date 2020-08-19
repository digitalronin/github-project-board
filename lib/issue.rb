class Issue < GithubGraphQlClient
  attr_reader :id

  def initialize(params)
    @id = params.fetch(:id)
    super(params)
  end

  def add_to_project_column(column_id)
    json = run_query(
      body: add_issue_query(column_id),
      token: github_token
    )

    JSON.parse(json)
  end

  private

  def add_issue_query(column_id)
    %[
      mutation AddIssueToProject {
        addProjectCard(input: {
          contentId: "#{id}",
          projectColumnId: "#{column_id}"
        }) {
          clientMutationId
        }
      }
    ]
  end
end
