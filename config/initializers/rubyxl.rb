module RubyXL
  module WorksheetConvenienceMethods
    def add_dropdown(row, col, content_list=nil, title=nil, prompt=nil)

      formula = RubyXL::Formula.new(expression: content_list)

      loc = if content_list # Indicates it is a dropdown.
              RubyXL::Reference.new(row, 1048000, col, col)
            else
              RubyXL::Reference.new(row, col)
            end

      val = RubyXL::DataValidation.new(prompt_title: title,
                                       prompt: prompt,
                                       sqref: loc,
                                       formula1: content_list ? formula : nil,
                                       type: content_list ? 'list' : nil,
                                       show_input_message: true)

      unless self.data_validations.nil?
        self.data_validations << val
      end

    end
    alias_method :add_hint, :add_dropdown # Alias as to not confuse myself
  end
end 