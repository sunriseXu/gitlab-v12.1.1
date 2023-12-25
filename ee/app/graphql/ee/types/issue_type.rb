# frozen_string_literal: true

module EE
  module Types
    module IssueType
      extend ActiveSupport::Concern

      prepended do
        field :weight, GraphQL::INT_TYPE,
              null: true,
              resolve: -> (obj, _args, _ctx) { obj.supports_weight? ? obj.weight : nil }

        field :designs, ::Types::DesignManagement::DesignCollectionType,
              null: true, method: :design_collection
      end
    end
  end
end
