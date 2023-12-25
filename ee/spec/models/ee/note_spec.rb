require 'spec_helper'

describe Note do
  include ::EE::GeoHelpers

  describe 'associations' do
    it { is_expected.to belong_to(:review).inverse_of(:notes) }
  end

  context 'object storage with background upload' do
    before do
      stub_uploads_object_storage(AttachmentUploader, background_upload: true)
    end

    context 'when running in a Geo primary node' do
      set(:primary) { create(:geo_node, :primary) }
      set(:secondary) { create(:geo_node) }

      before do
        stub_current_geo_node(primary)
      end

      it 'creates a Geo deleted log event for attachment' do
        Sidekiq::Testing.inline! do
          expect do
            create(:note, :with_attachment)
          end.to change(Geo::UploadDeletedEvent, :count).by(1)
        end
      end
    end
  end

  describe '#parent' do
    it 'returns group for epic notes' do
      group = create(:group)
      note = create(:note_on_epic, noteable: create(:epic, group: group))

      expect(note.parent).to eq(group)
    end
  end

  describe '#for_design' do
    it 'is true when the noteable is a design' do
      note = build(:note, noteable: build(:design))

      expect(note).to be_for_design
    end
  end
end
