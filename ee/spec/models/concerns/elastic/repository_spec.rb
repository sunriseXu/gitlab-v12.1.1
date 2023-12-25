require 'spec_helper'

describe Repository, :elastic do
  before do
    stub_ee_application_setting(elasticsearch_search: true, elasticsearch_indexing: true)
  end

  def index!(project)
    Sidekiq::Testing.inline! do
      project.repository.index_blobs
      project.repository.index_commits

      Gitlab::Elastic::Helper.refresh_index
    end
  end

  it "searches blobs and commits" do
    project = create :project, :repository
    index!(project)

    expect(project.repository.search('def popen')[:blobs][:total_count]).to eq(1)
    expect(project.repository.search('def | popen')[:blobs][:total_count] > 1).to be_truthy
    expect(project.repository.search('initial')[:commits][:total_count]).to eq(1)
  end

  it 'can filter blobs' do
    project = create :project, :repository
    index!(project)

    expect(project.repository.search('def | popen filename:test')[:blobs][:total_count]).to eq(1)
    expect(project.repository.search('def | popen path:ruby')[:blobs][:total_count]).to eq(4)
    expect(project.repository.search('def | popen extension:md')[:blobs][:total_count]).to eq(1)
  end

  it 'can delete blobs' do
    project = create :project, :repository
    blob = project.repository.blob_at('b83d6e391c22777fca1ed3012fce84f633d7fed0', 'files/ruby/popen.rb')

    expect(project.repository.delete_blob(blob)[:delete]).not_to be_empty
  end

  it 'can return the index as a json' do
    project = create :project, :repository
    index = project.repository.as_indexed_json

    expect(index[:blobs]).not_to be_empty
    expect(index[:commits]).not_to be_empty
  end

  def search_and_check!(on, query, type:, per: 1000)
    results = on.search(query, type: type, per: per)["#{type}s".to_sym][:results]

    blobs, commits = results.partition { |result| result['_source']['blob'].present? }

    case type
    when :blob
      expect(blobs).not_to be_empty
      expect(commits).to be_empty
    when :commit
      expect(blobs).to be_empty
      expect(commits).not_to be_empty
    else
      raise ArgumentError
    end
  end

  # A negation query can match both commits and blobs as they both have _type
  # 'repository'. Ensure this doesn't happen, in both global and project search
  it 'filters commits from blobs, and vice-versa' do
    project = create :project, :repository
    index!(project)

    search_and_check!(Repository, '-foo', type: :blob)
    search_and_check!(Repository, '-foo', type: :commit)
    search_and_check!(project.repository, '-foo', type: :blob)
    search_and_check!(project.repository, '-foo', type: :commit)
  end

  describe "class method find_commits_by_message_with_elastic" do
    it "returns commits" do
      project = create :project, :repository
      project1 = create :project, :repository

      project.repository.index_commits
      project1.repository.index_commits

      Gitlab::Elastic::Helper.refresh_index

      expect(Repository.find_commits_by_message_with_elastic('initial').first).to be_a(Commit)
      expect(Repository.find_commits_by_message_with_elastic('initial').count).to eq(2)
      expect(Repository.find_commits_by_message_with_elastic('initial').total_count).to eq(2)
    end
  end

  describe "find_commits_by_message_with_elastic" do
    it "returns commits" do
      project = create :project, :repository

      project.repository.index_commits

      Gitlab::Elastic::Helper.refresh_index

      expect(project.repository.find_commits_by_message_with_elastic('initial').first).to be_a(Commit)
      expect(project.repository.find_commits_by_message_with_elastic('initial').count).to eq(1)
      expect(project.repository.find_commits_by_message_with_elastic('initial').total_count).to eq(1)
    end
  end
end
