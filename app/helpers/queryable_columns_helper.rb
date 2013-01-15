# encoding: utf-8

module QueryableColumnsHelper
  unloadable

  def query_columns(query=nil)
    query ||= @query
    render :partial => "queryable/columns", :locals => {:query => query}
  end

  def query_columns_available(query=nil)
    query ||= @query
    (query_columns_available_label(query) +
      query_columns_available_select(query))
  end

  def query_columns_available_label(query=nil)
    label_tag "available_columns", "Available Columns"
  end

  def query_columns_available_select(query=nil)
    query ||= @query
    select_tag("available_columns",
      options_for_select(query_columns_available_options(query)),
      :multiple => true, 
      :size => 10)
  end

  def query_columns_available_options(query=nil)
    query ||= @query
    (query.available_columns - query.columns).map { |column| [column.caption, column.name] }
  end

  def query_columns_available_buttons
    (content_tag(:button, "&#8594;", :type => :button, :onclick => "moveOptions(this.form.available_columns, this.form.selected_columns);") +
      content_tag(:button, "&#8592;", :onclick => "moveOptions(this.form.selected_columns, this.form.available_columns);"))
  end

  def query_columns_selected(query=nil)
    query ||= @query
    (query_columns_selected_label(query) +
      query_columns_selected_select(query))
  end

  def query_columns_selected_label(query=nil)
    label_tag "selected_columns", "Selected Columns"
  end

  def query_columns_selected_select(query=nil)
    query ||= @query
    select_tag("c[]",
      options_for_select(query_columns_selected_options(query)),
      :multiple => true, 
      :size => 10)
  end

  def query_columns_selected_options(query=nil)
    query ||= @query
    query.columns.map { |column| [column.caption, column.name] }
  end

  def query_columns_selected_buttons
    (content_tag(:button, "&#8593;", :onclick => "moveOptionsUp(this.form.selected_columns);") +
      content_tag(:button, "&#8595;", :onclick => "moveOptionsDown(this.form.selected_columns);"))
  end
end