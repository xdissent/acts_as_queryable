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
  # name - The name of the field to label.
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the widget as a String.
  def query_filter_name(name, query=nil)
    query ||= @query
    (check_box_tag('f[]', name, query.has_filter?(name), :onclick => "toggle_filter('#{name}');", :id => "cb_#{name}") +
      label_tag("cb_#{name}", query.filter_label_for(name)))
  end

  # Public: Renders a query filter field's values, attempting to find a 
  # type-specific template at "queryable/filters/_<type>.rhtml", falling 
  # back to the "text" type if one can't be found.
  #
  # name - The name of the field to render.
  # query - A Queryable or nil to use the @query instance variable.
  # 
  # Returns nothing.
  def query_filter_values(name, query=nil)
    query ||= @query
    render :partial => "queryable/filters/#{query.type_for(name)}", :locals => {:query => query, :field => name}
  rescue ActionView::MissingTemplate
    render :partial => "queryable/filters/text", :locals => {:query => query, :field => name}
  end

  # Public: Build an operator selection widget for a filter field.
  #
  # name - The name of the field to label.
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the widget as a String.
  def query_filter_operator(name, query=nil)
    query ||= @query
    (query_filter_operator_label(name, query) +
      query_filter_operator_select(name, query))
  end

  # Public: Build a label for filter operators.
  #
  # name - The name of the field to label.
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the label tag as a String.
  def query_filter_operator_label(name, query=nil)
    label_tag "operators_#{name}", "Operator"
  end

  # Public: Build a select tag with operators for a filter field.
  #
  # name - The name of the field for which to find operators.
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the select tag as a String.
  def query_filter_operator_select(name, query=nil)
    query ||= @query
    options = query_filter_operator_options(name, query)
    select_tag "op[#{name}]", 
      options_for_select(options, query.operator_for(name)), 
      :id => "operators_#{name}", 
      :onchange => "toggle_operator('#{name}');"
  end

  # Public: Build select options with operators for a filter field.
  #
  # name - The name of the field for which to find operators.
  # query - A Queryable or nil to use the @query instance variable.
  #
  # Returns the select options as an Array.
  def query_filter_operator_options(name, query=nil)
    query ||= @query
    query.operators_for(name).map { |o| [query.operators[o], o] }
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
    [["Select Filter",""]] + query.available_filters_sorted.map do |n, f| 
      [query.filter_label_for(n), n] unless query.has_filter?(n)
    end.compact
  end
end
