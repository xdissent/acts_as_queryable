# encoding: utf-8

module QueryableFiltersHelper
  unloadable

  # Public: Render the query filters widget.
  #
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns nothing.
  def query_filters(query=nil)
    query ||= @query
    render :partial => "queryable/filters", :locals => {:query => query}
  end

  # Public: Build a filter field enable/disable widget with a label.
  #
  # field - The name of the field to label.
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the widget as a String.
  def query_filter_name(field, query=nil)
    query ||= @query
    (check_box_tag('f[]', field, query.has_filter?(field), :onclick => "toggle_filter('#{field}');", :id => "cb_#{field}") +
      label_tag("cb_#{field}", query.label_for(field)))
  end

  # Public: Renders a query filter field'svalues, attempting to find a 
  # type-specific template at "queryable/filters/_<type>.rhtml", falling 
  # back to the "text" type if one can't be found.
  #
  # field - The name of the field to render.
  # query - A Queryable or nil to use the @query instance variable.
  # 
  # Returns nothing.
  def query_filter_values(field, query=nil)
    query ||= @query
    field_type = query.type_for(field)
    render :partial => "queryable/filters/#{field_type}", :locals => {:query => query, :field => field}
  rescue ActionView::MissingTemplate
    render :partial => "queryable/filters/text", :locals => {:query => query, :field => field}
  end

  # Public: Build an operator selection widget for a filter field.
  #
  # field - The name of the field to label.
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the widget as a String.
  def query_filter_operator(field, query=nil)
    query ||= @query
    (query_filter_operator_label(field, query) +
      query_filter_operator_select(field, query))
  end

  # Public: Build a label for filter operators.
  #
  # field - The name of the field to label.
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the label tag as a String.
  def query_filter_operator_label(field, query=nil)
    label_tag "operators_#{field}", "Operator"
  end

  # Public: Build a select tag with operators for a filter field.
  #
  # field - The name of the field for which to find operators.
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the select tag as a String.
  def query_filter_operator_select(field, query=nil)
    query ||= @query
    options = query_filter_operator_options(field, query)
    select_tag "op[#{field}]", 
      options_for_select(options, query.operator_for(field)), 
      :id => "operators_#{field}", 
      :onchange => "toggle_operator('#{field}');"
  end

  # Public: Build select options with operators for a filter field.
  #
  # field - The name of the field for which to find operators.
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the select options as an Array.
  def query_filter_operator_options(field, query=nil)
    query ||= @query
    query.operators_by_filter_type[query.type_for(field)].map { |o| [query.operators[o], o] }
  end

  # Public: Build a field name selection widget for adding a new filter.
  #
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the widget as a String.
  def query_filter_add(query=nil)
    query ||= @query
    (query_filter_add_label(query) +
      query_filter_add_select(query))
  end

  # Public: Build a label for a new filter.
  #
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the label tag as a String.
  def query_filter_add_label(query=nil)
    label_tag "add_filter_select", "Add Filter"
  end

  # Public: Build a select tag with available fields for a new filter.
  #
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the select tag as a String.
  def query_filter_add_select(query=nil)
    query ||= @query
    select_tag 'add_filter_select', 
        options_for_select(query_filter_add_options(query)),
        :onchange => "add_filter();",
        :name => nil
  end

  # Public: Build a selection of field names available to add a new filter.
  #
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the select tag as a String.
  def query_filter_add_options(query=nil)
    query ||= @query
    [["Select Filter",""]] + query.available_filters_sorted.map do |field| 
      [query.label_for(field[0]), field[0]] unless query.has_filter?(field[0])
    end.compact
  end
end
