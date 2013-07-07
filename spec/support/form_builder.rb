shared_examples "form builder" do
  let(:name) { :name }

  [:email, :number, :password, :phone, :search, :text, :url].each do |type|
    describe "#{type}_field" do
      let(:view)  { "#{type}_field" }
      let(:field) { Hash[:type => type, :value => "sshaw", :id => "item_name", :name => "item[name]"] }
      it_should_behave_like "a form field"
    end
  end

  describe "#file" do
    let(:view)  { "file_field" }
    let(:field) { file_field_tag("item[name]", :id => "item_name") }
    it_should_behave_like "a form field"
  end

  describe "#uneditable_input" do
    let(:view)  { "uneditable_input" }
    let(:field) { content_tag(:span, "sshaw", :id => "item_name", :class => "uneditable-input") }
    it_should_behave_like "a form field"
  end

  describe "#text_area" do
    let(:view)  { "text_area" }
    let(:field) { text_area_tag("item[name]", :id => "item_name", :value => "sshaw") }
    it_should_behave_like "a form field"
  end

  describe "#select" do
    let(:view)  { "select" }
    let(:field) { select_tag("item[name]", :options => %w[sshaw fofinha], :selected => "sshaw", :id => "item_name") }
    it_should_behave_like "a form field"
  end

  describe "#radio_buttons" do
    def radio_button
      content_tag(:label, :class => "radio", :for => "item_name") do
        field = hidden_field_tag("item[name]", :value => 0) <<
          radio_button_tag("item[name]", :id => "item_name", :value => 1)
        field << yield if block_given?
        field
      end
    end

    it "renders the field" do
      html = control_group do
        content_tag(:label, "Name", :class => "control-label") << controls { radio_button }
      end
      
      req(format, "radio_buttons").should eq clean(html)
    end
  end

  describe "#check_box" do
    def check_box
      content_tag(:label, :class => "checkbox", :for => "item_name") do
        field = hidden_field_tag("item[name]", :value => 0) <<
          check_box_tag("item[name]", :id => "item_name", :value => 1) <<
          "Name"
        field << yield if block_given?
        field
      end
    end

    it "renders the field" do
      html = control_group do
        controls { check_box }
      end

      req(format, "check_box").should eq clean(html)
    end

    [:help_block, :help_inline].each do |option|
      klass = option.to_s.tr "_", "-"

      it "renders the field using the :#{option} option" do
        html = control_group do
          controls do
            check_box { content_tag(:span, option.to_s.titleize, :class => klass) }
          end
        end

        req(format, "check_box_with_#{option}").should eq clean(html)
      end
    end

    VALIDATION_STATES.each do |state|
      it "renders the field using the :#{state} option" do
        html = control_group(state) do
          controls do
            check_box { content_tag(:span, state.to_s.titleize, :class => "help-inline") }
          end
        end

        req(format, "check_box_with_#{state}").should eq clean(html)
      end
    end
  end

  # .cg { label + .extras { .controls { .... } } }
  describe "#collection_check_boxes" do
  end

  # same as collect check box
  describe "#collection_radio_buttons" do
  end
end
