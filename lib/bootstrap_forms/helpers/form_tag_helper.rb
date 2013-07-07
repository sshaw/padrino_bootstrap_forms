module BootstrapForms
  module Helpers
    module FormTagHelper
      include BootstrapForms::Helpers::Wrappers

      %w(check_box_tag email_field_tag file_field_tag number_field_tag password_field_tag radio_button_tag search_field_tag select_tag telephone_field_tag text_area_tag text_field_tag url_field_tag).each do |method_name|
        # prefix each method with bootstrap_*
        define_method("bootstrap_#{method_name}") do |name, *args|
          @name = name
          @field_options = args.extract_options!
          # TODO: use whatever method Padrino's builder uses...
          @field_options[:id] ||= name

          control_group_div do
            label_field + input_div do
              extras { send(method_name.to_sym, name, objectify_options(@field_options)) }
            end
          end
        end
      end

      alias :bootstrap_phone_field_tag :bootstrap_telephone_field_tag

      def uneditable_input_tag(name, *args)
        @name = name
        @field_options = args.extract_options!
        @args = args

        # Padrino will always generate a label's for attribute, this results in invalid HTML.
        # label_field will use :id as the for attribute if present.
        @field_options[:id] = nil unless @field_options[:id]

        control_group_div do
          label_field + input_div do
            extras do
              # Due to how Padrino implements ERB this block (and others) will be called many (4?) times.
              # To avoid string accumulation under :class -and to keep option passing somewhat straightforward- we just dup()
              options = @field_options.dup
              options[:class] = [options[:class], 'uneditable-input'].compact.join " "

              content_tag(:span,  escape_html(options[:value]), objectify_options(options.except(:value)))
            end
          end
        end
      end

      def bootstrap_button_tag(*args)
        options = args.extract_options!
        klass = ["btn"]
        klass << (options[:class] || "btn-primary")

        options[:class] = klass.join " "
        name = args.shift || 'Submit'
        # button_tag() renders <input type="button">
        content_tag(:button, name, options)
      end

      def bootstrap_submit_tag(*args)
        options = args.extract_options!
        klass = ["btn"]
        klass << (options[:class] || "btn-primary")

        options[:class] = klass.join " "
        name = args.shift || 'Submit'
        submit_tag(name, options)
      end

      # TODO: Need to allow for btn-XXX classes
      def bootstrap_cancel_tag(*args)
        options = args.extract_options!
        klass = ["btn cancel"]
        klass << options[:class] if options[:class]

        options[:class] = klass.join " "
        options[:back] ||= 'javascript:history.go(-1)'

        name = args.shift || 'Cancel'
        link_to(name, options[:back], options.except(:back))
      end

      def bootstrap_actions(&block)
        content = block_given? ? capture_html(&block) : [bootstrap_submit_tag, bootstrap_cancel_tag].join(' ').html_safe
        content_tag(:div, content, :class => 'form-actions')
      end
    end
  end
end