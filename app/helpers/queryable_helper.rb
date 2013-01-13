# encoding: utf-8

module QueryableHelper

  def operators_for_select(filter_type, query_class=nil)
    query_class ||= @query && @query.class
    query_class.operators_by_filter_type[filter_type].collect {|o| [l(query_class.operators[o]), o]}
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
      l(:general_text_Yes)
    when 'FalseClass'
      l(:general_text_No)
    else
      h(value.to_s)
    end
  end

  def query_session_key
    query_class = self.class.read_inheritable_attribute('query_class')
    "query_#{query_class.underscore.gsub '/', '_'}"
  end

  def find_query_object
    query_class = self.class.read_inheritable_attribute('query_class')
    return unless query_class

    if !params[:query_id].blank?
      @query = query_class.find(params[:query_id])
      session[query_session_key] = {:id => @query.id}
    else
      if params[:set_filter] || session[query_session_key].nil?
        @query = query_class.new :name => "_"
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
        session[query_session_key] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names, :display_subprojects => @query.display_subprojects}
      else
        @query = query_class.find_by_id(session[query_session_key][:id]) if session[query_session_key][:id]
        @query ||= query_class.new :name => "_", :filters => session[query_session_key][:filters], :group_by => session[query_session_key][:group_by], :column_names => session[query_session_key][:column_names]
      end
    end
  rescue ActiveRecord::RecordNotFound
  end
end
