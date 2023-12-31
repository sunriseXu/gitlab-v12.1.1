# frozen_string_literal: true

module OmniAuth
  module Strategies
    class GroupSaml < SAML
      extend ::Gitlab::Utils::Override

      option :name, 'group_saml'
      option :callback_path, ->(env) { callback?(env) }

      override :setup_phase
      def setup_phase
        if metadata_phase?
          require_discovery_token
        else
          require_saml_provider
        end

        # Set devise scope for custom callback URL
        env["devise.mapping"] = Devise.mappings[:user]

        settings = Gitlab::Auth::GroupSaml::DynamicSettings.new(group_lookup.group).to_h
        env['omniauth.strategy'].options.merge!(settings)

        if OmniAuth.config.test_mode && on_request_path?
          emulate_relay_state
        end

        super
      end

      # Prevent access to SLO endpoints. These make less sense at
      # group level and would need additional work to securely support
      override :other_phase
      def other_phase
        if metadata_phase?
          super
        else
          call_app!
        end
      end

      # NOTE: This method duplicates code from omniauth-saml
      #       so that we can access authn_request to store it
      #       See: https://github.com/omniauth/omniauth-saml/issues/172
      override :request_phase
      def request_phase
        authn_request = OneLogin::RubySaml::Authrequest.new

        store_authn_request_id(authn_request)

        with_settings do |settings|
          redirect(authn_request.create(settings, additional_params_for_authn_request))
        end
      end

      def emulate_relay_state
        request.query_string.sub!('redirect_to', 'RelayState')
      end

      def self.invalid_group!(path)
        raise ActionController::RoutingError, path
      end

      def self.callback?(env)
        env['PATH_INFO'] =~ Gitlab::PathRegex.saml_callback_regex
      end

      override :callback_path
      def callback_path
        @callback_path ||= begin
          if options[:callback_path].call(env)
            current_path
          elsif group_lookup.path
            "/groups/#{group_lookup.path}/-/saml/callback"
          else
            super
          end
        end
      end

      private

      def metadata_phase?
        on_subpath?(:metadata)
      end

      def store_authn_request_id(authn_request)
        Gitlab::Auth::SamlOriginValidator.new(session).store_origin(authn_request)
      end

      def group_lookup
        @group_lookup ||= Gitlab::Auth::GroupSaml::GroupLookup.new(env)
      end

      def require_saml_provider
        unless group_lookup.group_saml_enabled?
          self.class.invalid_group!(group_lookup.path)
        end
      end

      def require_discovery_token
        unless group_lookup.token_discoverable?
          self.class.invalid_group!(group_lookup.path)
        end
      end
    end
  end
end
