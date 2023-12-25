# frozen_string_literal: true

module EE
  module Todo
    extend ::Gitlab::Utils::Override

    override :parent
    def parent
      project || group
    end
  end
end
