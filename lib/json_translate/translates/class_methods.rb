module JSONTranslate
  module Translates
    module ClassMethods
      def translates?
        included_modules.include?(InstanceMethods)
      end

      private

      # Override the default relation methods in order to inject custom finder methods for hstore translations.
      def relation
        super.extending!(QueryMethods)
      end
    end
  end
end
