# frozen_string_literal: true

require 'spec_helper'

describe EE::Gitlab::Checks::PushRules::FileSizeCheck do
  include_context 'push rules checks context'

  describe '#validate!' do
    let(:push_rule) { create(:push_rule, max_file_size: 1) }
    # SHA of the 2-mb-file branch
    let(:newrev)    { 'bf12d2567099e26f59692896f73ac819bae45b00' }
    let(:ref)       { 'my-branch' }

    before do
      # Delete branch so Repository#new_blobs can return results
      project.repository.delete_branch('2-mb-file')
    end

    it_behaves_like 'check ignored when push rule unlicensed'

    it 'returns an error if file exceeds the maximum file size' do
      expect { subject.validate! }.to raise_error(Gitlab::GitAccess::UnauthorizedError, "File \"file.bin\" is larger than the allowed size of 1 MB")
    end
  end
end
