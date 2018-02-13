require "rails_helper"

RSpec.describe ChunksController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/chunks").to route_to("chunks#index")
    end

    it "routes to #new" do
      expect(:get => "/chunks/new").to route_to("chunks#new")
    end

    it "routes to #show" do
      expect(:get => "/chunks/1").to route_to("chunks#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/chunks/1/edit").to route_to("chunks#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/chunks").to route_to("chunks#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/chunks/1").to route_to("chunks#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/chunks/1").to route_to("chunks#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/chunks/1").to route_to("chunks#destroy", :id => "1")
    end

  end
end
