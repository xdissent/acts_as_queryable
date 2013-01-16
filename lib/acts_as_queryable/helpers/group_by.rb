# encoding: utf-8

module ActsAsQueryable::Helpers
  module GroupBy

    # Public: Build a column selection widget for the group_by attribute.
    #
    # query - A Queryable or nil to use the @query instance variable.
    #
    # Returns the widget as a String.
    def query_group_by(query=nil)
      query ||= @query
      content_tag :div, (query_group_by_label(query) +
        query_group_by_select(query)), :class => "query-group-by"
    end

    # Public: Build a label for the group_by select.
    #
    # name - The name of the field to label.
    # query - A Queryable or nil to use the @query instance variable.
    #
    # Returns the label tag as a String.
    def query_group_by_label(query=nil)
      label_tag "group_by", "Group By"
    end

    # Public: Build a select tag with groupable columns.
    #
    # query - A Queryable or nil to use the @query instance variable.
    #
    # Returns the select tag as a String.
    def query_group_by_select(query=nil)
      query ||= @query
      select_tag 'group_by', 
        options_for_select(query_group_by_options(query), query.group_by)
    end

    # Public: Build a selection of columns available to group_by.
    #
    # query - A Queryable or nil to use the @query instance variable.
    #
    # Returns the select tag as a String.
    def query_group_by_options(query=nil)
      query ||= @query
      [["",""]] + query.groupable_columns.map { |c| [query.column_label_for(c), c] }
    end
  end
end