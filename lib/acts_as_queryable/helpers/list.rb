# encoding: utf-8

module ActsAsQueryable::Helpers
  module List

    # Public: Render the query filters widget.
    #
    # query - A Queryable or nil to use the @query instance variable.
    #
    # Returns nothing.
    def query_list(query=nil, items=nil)
      query ||= @query
      items ||= query.query
      render :partial => "queryable/list", :locals => {:query => query, :items => items}
    end

    def query_list_headers(query=nil)
      query ||= @query
      query.columns.map { |name| content_tag :th, query.column_label_for(name) }.join("")
    end

    def query_list_items(query=nil, items=nil)
      query ||= @query
      previous_group = nil
      items.map do |item|
        group_row = ""
        if query.grouped?
          group = query_list_item_value(query.group_by, item, query)
          group_row = query_list_group_row(group, item, query) if group != previous_group
          previous_group = group
        end
        group_row + content_tag(:tr, query_list_item(item, query))
      end.join
    end

    def query_list_item(item, query=nil)
      query ||= @query
      query.columns.map do |name| 
        value = query_list_item_value(name, item, query)
        content_tag :td, query_list_item_value_content(value, name, item, query)
      end.join
    end

    def query_list_item_value(name, item, query=nil)
      query ||= @query
      item.try(name)
    end

    def query_list_item_value_content(value, name, item, query=nil)
      query ||= @query
      case value.class.name
      when "Time"
        format_time(value)
      when "Date"
        format_date(value)
      when "TrueClass"
        qt(:yes)
      when "FalseClass"
        qt(:no)
      when "Array"
        value.map { |v| query_list_item_value_content(v, name, item, query) }.join ","
      else
        h(value.to_s)
      end
    end

    def query_list_group_row(value, item, query=nil)
      query ||= @query
      content = query_list_item_value_content(value, query.group_by, item, query)
      row = content_tag :td, "#{query.column_label_for(query.group_by)}: #{content}", :colspan => query.columns.size
      content_tag :tr, row
    end
  end
end