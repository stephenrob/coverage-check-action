# frozen_string_literal: true

require 'octokit'

class GithubCheckRunService
  def initialize(report, github_data, report_name, report_adapter)
    @report = report
    @github_data = github_data
    @report_name = report_name
    @report_adapter = report_adapter

    if @github_data[:api] != 'https://api.github.com'
      Octokit.configure do |c|
        c.api_endpoint = @github_data[:api]
      end
    end

    @client = Octokit::Client.new(access_token: @github_data[:token])
  end

  def run
    repo_name = "#{@github_data[:owner]}/#{@github_data[:repo]}"

    check = @client.create_check_run(repo_name, @report_name, @github_data[:sha], status: 'in_progress', started_at: Time.now.iso8601)

    @summary = @report_adapter.summary(@report)
    @annotations = @report_adapter.annotations(@report)
    @conclusion = @report_adapter.conclusion(@report)
    @percent = @report_adapter.lines_covered_percent(@report)

    @client.update_check_run(repo_name, check["id"], {
      name: @report_name,
      head_sha: @github_data[:sha],
      status: 'completed',
      completed_at: Time.now.iso8601,
      conclusion: @conclusion,
      output: {
        title: "#{@report_name} #{@percent}%",
        summary: @summary,
        annotations: @annotations
      }
    })
  end
end