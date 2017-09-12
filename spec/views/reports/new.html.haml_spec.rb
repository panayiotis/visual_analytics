require 'rails_helper'

RSpec.describe "reports/new", type: :view do
  before(:each) do
    assign(:report, Report.new(
      :name => "MyString",
      :short_name => "MyString",
      :description => "MyString",
      :attribution => "MyString"
    ))
  end

  it "renders new report form" do
    render

    assert_select "form[action=?][method=?]", reports_path, "post" do

      assert_select "input#report_name[name=?]", "report[name]"

      assert_select "input#report_short_name[name=?]", "report[short_name]"

      assert_select "input#report_description[name=?]", "report[description]"

      assert_select "input#report_attribution[name=?]", "report[attribution]"
    end
  end
end
