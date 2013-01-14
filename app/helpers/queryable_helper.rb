# encoding: utf-8

module QueryableHelper

  def query_filters(query=nil)
    query ||= @query
    render :partial => "queryable/filters", :locals => {:query => query}
  end

  def query_filter_operators_for(field, query=nil)
    query ||= @query
    operators = operators_for_select query.type_for(field)
    select_tag "op[#{field}]", 
      options_for_select(operators, query.operator_for(field)), 
      :id => "operators_#{field}", 
      :onchange => "toggle_operator('#{field}');", 
      :class => "select-small", 
      :style => "vertical-align: top;"
  end

  def query_filter_add(query=nil)
    query ||= @query
    field_options = query.available_filters_sorted.map do |field| 
      [query.label_for(field[0]), field[0]] unless query.has_filter?(field[0])
    end.compact
    (label_tag('add_filter_select', "Add Filter") + 
      select_tag('add_filter_select', 
        options_for_select([["",""]] + field_options),
        :onchange => "add_filter();",
        :class => "select-small",
        :name => nil))
  end

  def query_filter_fields_for(field, query=nil)
    query ||= @query
    field_type = query.type_for(field)
    render :partial => "queryable/filters/#{field_type}", :locals => {:query => query, :field => field}
  rescue ActionView::MissingTemplate
    render :partial => "queryable/filters/text", :locals => {:query => query, :field => field}
  end

  def query_filter_scripts(query=nil)
    query ||= @query
    (javascript_include_tag("prototype") +
      javascript_include_tag("filters", :plugin => :acts_as_queryable))
  end

  def operators_for_select(filter_type, query_class=nil)
    query_class ||= @query_class || (@query && @query.class) || self.class.read_inheritable_attribute('query_class')
    return [] unless query_class
    query_class.operators_by_filter_type[filter_type].collect {|o| [query_class.operators[o], o]}
  end

  def column_header(column)
    if column.sortable
      sort_header_tag column.name.to_s, :caption => column.caption, 
        :default_order => column.default_order
    else
      content_tag 'th', h(column.caption)
    end
  end

  def column_content(column, queryable)
    value = column.value(queryable)
    case value.class.name
    when 'Time'
      format_time(value)
    when 'Date'
      format_date(value)
    when 'TrueClass'
      "Yes"
    when 'FalseClass'
      "No"
    else
      h(value.to_s)
    end
  end

  def query_session_key
    "query_#{@query_class.name.underscore.gsub '/', '_'}"
  end

  def find_query_object
    @query_class ||= self.class.read_inheritable_attribute('query_class')
    return unless @query_class

    if !params[:query_id].blank?
      @query = @query_class.find_by_id(params[:query_id])
      return unless @query
      session[query_session_key] = {:id => @query.id}
    else
      if params[:set_filter] || session[query_session_key].nil?
        @query = @query_class.new :name => "_"
        if params[:fields] || params[:f]
          @query.filters = {}
          @query.add_filters(params[:fields] || params[:f], params[:operators] || params[:op], params[:values] || params[:v])
        else
          @query.available_filters.keys.each do |field|
            @query.add_short_filter(field, params[field]) if params[field]
          end
        end
        @query.group_by = params[:group_by]
        @query.column_names = params[:c] || (params[:query] && params[:query][:column_names])
        session[query_session_key] = {:filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names}
      else
        @query = @query_class.find_by_id(session[query_session_key][:id]) if session[query_session_key][:id]
        @query ||= @query_class.new(session[query_session_key].merge :id => nil, :name => "_")
      end
    end
  end
end
