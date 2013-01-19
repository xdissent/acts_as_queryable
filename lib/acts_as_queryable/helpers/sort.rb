# encoding: utf-8

module ActsAsQueryable::Helpers
  module Sort

    # Public: Build a sort criteria widget the query.
    #
    # query - A Queryable or nil to use the @query instance variable.
    #
    # Returns the widget as a String.
    def query_sort_criteria(query=nil)
      query ||= @query
      content = ""
      3.times do |index|
        content += content_tag :div,
          (query_sort_criteria_attribute(index, query) +
            query_sort_criteria_direction(index, query))
      end
      content_tag :div, content, :class => "query-sort-criteria"
    end

    def query_sort_criteria_attribute(index=0, query=nil)
      query ||= @query
      (query_sort_criteria_attribute_label(index, query) +
        query_sort_criteria_attribute_select(index, query))
    end

    def query_sort_criteria_attribute_label(index=0, query=nil)
      label_tag "query_sort_criteria_attribute_#{index}", qt(:sort_column)
    end

    def query_sort_criteria_attribute_select(index=0, query=nil)
      query ||= @query
      select_tag("query[sort_criteria][#{index}][]",
        options_for_select(query_sort_criteria_attribute_options(query), query.sort_criteria[index].to_s),
        :id => "query_sort_criteria_attribute_#{index}")
    end

    def query_sort_criteria_attribute_options(query=nil)
      query ||= @query
      [["", ""]] + query.sortable_columns.map { |name| [query.column_label_for(name), name.to_s] }
    end

    def query_sort_criteria_direction(index=0, query=nil)
      query ||= @query
      (query_sort_criteria_direction_label(index, query) +
        query_sort_criteria_direction_select(index, query))
    end

    def query_sort_criteria_direction_label(index=0, query=nil)
      label_tag "query_sort_criteria_direction_#{index}", qt(:sort_direction)
    end

    def query_sort_criteria_direction_select(index=0, query=nil)
      query ||= @query
      select_tag("query[sort_criteria][#{index}][]",
        options_for_select(query_sort_criteria_direction_options(query), @query.sort_criteria[index].to_s),
        :id => "query_sort_criteria_direction_#{index}")
    end

    def query_sort_criteria_direction_options(query=nil)
      [["", ""], [qt(:ascending), "asc"], [qt(:descending), "desc"]]
    end
  end
end