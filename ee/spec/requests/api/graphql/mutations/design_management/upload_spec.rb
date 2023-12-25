# frozen_string_literal: true
require "spec_helper"

describe "uploading designs" do
  include GraphqlHelpers
  include DesignManagementTestHelpers

  let(:current_user) { create(:user) }
  let(:issue) { create(:issue) }
  let(:project) { issue.project }
  let(:files) { [fixture_file_upload('spec/fixtures/dk.png')] }
  let(:variables) { {} }

  let(:mutation) do
    input = {
      project_path: project.full_path,
      iid: issue.iid,
      files: files
    }.merge(variables)
    graphql_mutation(:design_management_upload, input)
  end

  let(:mutation_response) { graphql_mutation_response(:design_management_upload) }

  before do
    enable_design_management

    project.add_developer(current_user)
  end

  it "returns an error if the user is not allowed to upload designs" do
    post_graphql_mutation(mutation, current_user: create(:user))

    expect(graphql_errors).not_to be_empty
  end

  it "responds with the created designs" do
    post_graphql_mutation(mutation, current_user: current_user)

    designs = mutation_response["designs"]

    expect(designs.size).to eq(1)
    expect(designs.first["filename"]).to eq("dk.png")
  end

  context "when the issue does not exist" do
    let(:variables) { { iid: "123" } }

    it "returns an error" do
      post_graphql_mutation(mutation, current_user: create(:user))

      expect(graphql_errors).not_to be_empty
    end
  end

  context "when saving the designs raises an error" do
    it "responds with errors" do
      expect_next_instance_of(::DesignManagement::SaveDesignsService) do |service|
        expect(service).to receive(:execute).and_return({ status: :error, message: "Something went wrong" })
      end

      post_graphql_mutation(mutation, current_user: current_user)
      expect(mutation_response["errors"].first).to eq("Something went wrong")
    end
  end
end
