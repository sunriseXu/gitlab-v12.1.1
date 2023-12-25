# frozen_string_literal: true

module Elastic
  module MilestonesSearch
    extend ActiveSupport::Concern

    included do
      include ApplicationSearch

      def as_indexed_json(options = {})
        # We don't use as_json(only: ...) because it calls all virtual and serialized attributtes
        # https://gitlab.com/gitlab-org/gitlab-ee/issues/349
        data = {}

        [:id, :iid, :title, :description, :project_id, :created_at, :updated_at].each do |attr|
          data[attr.to_s] = safely_read_attribute_for_elasticsearch(attr)
        end

        data.merge(generic_attributes)
      end

      def self.nested?
        true
      end

      def self.elastic_search(query, options: {})
        options[:in] = %w(title^2 description)

        query_hash = basic_query_hash(options[:in], query)

        query_hash = project_ids_filter(query_hash, options)

        self.__elasticsearch__.search(query_hash)
      end
    end
  end
end
