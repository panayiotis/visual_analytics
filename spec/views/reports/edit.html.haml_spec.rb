require 'rails_helper'

RSpec.describe "reports/edit", type: :view do
  before(:each) do
    @report = assign(:report, Report.create!(
      :name => "MyString",
      :short_name => "MyString",
      :description => "MyString",
      :attribution => "MyString"
    ))
  end

  it "renders the edit report form" do
    render

    assert_select "form[action=?][method=?]", report_path(@report), "post" do

      assert_select "input#report_name[name=?]", "report[name]"

      assert_select "input#report_short_name[name=?]", "report[short_name]"

      assert_select "input#report_description[name=?]", "report[description]"

      assert_select "input#report_attribution[name=?]", "report[attribution]"
    end
  end
end
