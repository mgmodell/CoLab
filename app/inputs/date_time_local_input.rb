# frozen_string_literal: true

class DateTimeLocalInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    @builder.datetime_local_field(attribute_name, merged_input_options).to_s.html_safe
  end
end
