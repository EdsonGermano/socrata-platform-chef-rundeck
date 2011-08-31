require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ChefRundeck" do
  it "has a VERSION" do
    ChefRundeck::VERSION.should_not be_nil
  end
end
