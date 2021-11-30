module JSONTranslate
  module Translates
    module QueryMethods
      def where(*args)
        opts, *rest = args
        if opts.is_a?(Hash)
          query = spawn

          translated_attrs = translated_attributes(opts)
          untranslated_attrs = untranslated_attributes(opts)

          unless untranslated_attrs.empty?
            query.where!(untranslated_attrs, *rest)
          end

          translated_attrs.each do |key, value|
            if value.is_a?(String)
              column_name = "#{key}#{SUFFIX}"
              join_column = "#{column_name}_values"

              query
                .joins!("JOIN jsonb_each_text(#{table_name}.#{column_name}) #{join_column} ON true")
                .where!("#{join_column}.value = (?)", value)
            else
              super
            end
          end

          query
        else
          super
        end
      end

      def order(*args)
        if args.is_a?(Array)
          check_if_method_has_arguments!(:order, args)
          query = spawn
          attrs = args

          # TODO: Remove this ugly hack
          if args[0].is_a?(Hash)
            attrs = args[0]
          elsif args[0].is_a?(Symbol)
            attrs = Hash[args.map { |attr| [attr, :asc] }]
          end

          translated_attrs = translated_attributes(attrs)
          untranslated_attrs = untranslated_attributes(attrs)

          query.order!(untranslated_attrs) unless untranslated_attrs.empty?

          translated_attrs.each do |key, value|
            query.order!(Arel.sql("#{key}#{SUFFIX} ->> '#{I18n.locale}' #{value}"))
          end

          query
        else
          super
        end
      end

      private

      def translated_attributes(opts)
        opts.select { |key, _| translated_attribute_names.include?(key) }
      end

      def untranslated_attributes(opts)
        return safe_untranslated_attributes(opts) if opts.is_a?(Array)

        opts.reject { |key, _| translated_attribute_names.include?(key) }
      end

      def safe_untranslated_attributes(opts)
        opts
          .reject { |opt| opt.is_a?(Arel::Nodes::Ordering) }
          .map! { |opt| Arel.sql(opt.to_s) }
      end
    end
  end
end
