module Csa::Ccm

  class MatrixRow

    ATTRIBS = %i[
      control_domain_id control_id question_id control_spec
      question_content answer_yes answer_no answer_na comment
      control_domain_description
    ].freeze

    attr_accessor *ATTRIBS

    def initialize(ruby_xl_row)
      @control_domain_description = ruby_xl_row[0].value
      @control_id = ruby_xl_row[1].value
      @question_id = ruby_xl_row[2].value
      @control_spec = ruby_xl_row[3].value
      @question_content = ruby_xl_row[4].value
      @answer_yes = ruby_xl_row[5].value
      @answer_no = ruby_xl_row[6].value
      @answer_na = ruby_xl_row[7].value
      @comment = ruby_xl_row[8].value

      # In 3.0.1 2017-09-01, question_id for "AIS-02.2" is listed as "AIS- 02.2"
      %w[control_id question_id].each do |field|
        if val = send(field)
          send("#{field}=", val.gsub(/\s/, ''))
        end
      end

      # In 3.0.1 2017-09-01, Rows 276 and 277's control ID says "LG-02" but it should be "STA-05" instead.
      if @control_id.nil? && @question_id
        @control_id = @question_id.split('.').first
      end

      @control_domain_id = control_id.split('-').first if @control_id

      # puts "HERE IN ROW! #{ruby_xl_row.cells.map(&:value)}"

      # puts control_domain_description
      # puts control_id
      # puts question_id

      self
    end

    def control_domain_title
      return nil if control_domain_description.nil?

      name, = control_domain_description.split(/(\n)/)
      name
    end

    def control_title
      return nil if control_domain_description.nil?

      _, _, control_title = control_domain_description.split(/(\n)/)
      control_title
    end

  end
end
