# encoding: utf-8

module ActsAsQueryable::Helpers
  module Scripts

    # Public: Include scripts required by acts_as_queryable.
    #
    # Returns nothing.
    def query_scripts
      return if @queryable_scripted
      @queryable_scripted = true
      concat javascript_include_tag("prototype")
      concat javascript_include_tag("select_list_move")
      concat javascript_include_tag("filters", :plugin => :acts_as_queryable)
      concat javascript_include_tag("columns", :plugin => :acts_as_queryable)
    end

    # Public: Include styles required by acts_as_queryable.
    #
    # Returns nothing.
    def query_styles
      return if @queryable_styled
      @queryable_styled = true
      concat stylesheet_link_tag("filters", :plugin => :acts_as_queryable)
      concat stylesheet_link_tag("columns", :plugin => :acts_as_queryable)
    end
  end
end