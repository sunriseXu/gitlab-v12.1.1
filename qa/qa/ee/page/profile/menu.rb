# frozen_string_literal: true

module QA
  module EE
    module Page
      module Profile
        module Menu
          def wait_for_key_to_replicate(text, max_wait: Runtime::Geo.max_file_replication_time)
            wait(max: max_wait) { page.has_text?(text) }
          end
        end
      end
    end
  end
end
