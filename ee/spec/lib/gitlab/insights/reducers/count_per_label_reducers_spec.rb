# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Insights::Reducers::CountPerLabelReducer do
  include_context 'Insights reducers context'

  def find_issuables(project, opts)
    Gitlab::Insights::Finders::IssuableFinder.new(project, nil, opts).find
  end

  def reduce(issuable_relation, labels)
    described_class.reduce(issuable_relation, labels: labels)
  end

  let(:opts) do
    {
      state: 'opened',
      issuable_type: 'issue',
      filter_labels: [label_bug.title],
      collection_labels: [label_manage.title, label_plan.title],
      group_by: 'month',
      period_limit: 5
    }
  end
  let(:issuable_relation) { find_issuables(project, opts) }

  subject { reduce(issuable_relation, opts[:collection_labels]) }

  let(:expected) do
    {
      label_manage.title => 1,
      label_plan.title => 1,
      Gitlab::Insights::UNCATEGORIZED => 1
    }
  end

  it 'raises an error for an unknown :issuable_type option' do
    expect { reduce(issuable_relation, nil) }.to raise_error(described_class::InvalidLabelsError, "Invalid value for `labels`: `[]`. It must be a non-empty array!")
  end

  it 'returns issuables with only the needed fields' do
    expect(subject).to eq(expected)
  end

  it 'avoids N + 1 queries' do
    control_queries = ActiveRecord::QueryRecorder.new { subject }
    create(:labeled_issue, :opened, labels: [label_bug], project: project)

    expect { reduce(find_issuables(project, opts), opts[:collection_labels]) }.not_to exceed_query_limit(control_queries)
  end
end
