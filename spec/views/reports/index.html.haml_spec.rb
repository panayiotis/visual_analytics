require 'rails_helper'

RSpec.describe "reports/index", type: :view do
  before(:each) do
    assign(:reports, [
      Report.create!(
        :name => "Name",
        :short_name => "Short Name",
        :description => "Description",
        :attribution => "Attribution"
      ),
      Report.create!(
        :name => "Name",
        :short_name => "Short Name",
        :description => "Description",
        :attribution => "Attribution"
      )
    ])
  end

  it "renders a list of reports" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Short Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Attribution".to_s, :count => 2
  end
end
