xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'
xml.declare! :DOCTYPE, :project, :PUBLIC, "-//DTO Labs Inc.//DTD Resources Document 1.0//EN", "project.dtd"
xml.project do
  @nodes.each do |node|
    xml.node(node)
  end
end
