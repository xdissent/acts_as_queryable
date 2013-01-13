# encoding: utf-8

class QueryableQuery < ActiveRecord::Base
  unloadable

  serialize :filters
  serialize :column_names
  serialize :sort_criteria, Array

  validates_presence_of :name, :on => :save
  validates_length_of :name, :maximum => 255

  #
  # Queryable Class
  #
  class_inheritable_accessor :queryable_class
  attr_writer :queryable_class

  def queryable_class
    @queryable_class || self.class.queryable_class
  end

  #
  # Operators
  #
  class_inheritable_hash :operators
  attr_writer :operators

  self.operators = {
    "="   => :label_equals,
    "!"   => :label_not_equals,
    "!*"  => :label_none,
    "*"   => :label_all,
    ">="  => :label_greater_or_equal,
    "<="  => :label_less_or_equal,
    "><"  => :label_between,
    "<t+" => :label_in_less_than,
    ">t+" => :label_in_more_than,
    "t+"  => :label_in,
    "t"   => :label_today,
    "w"   => :label_this_week,
    ">t-" => :label_less_than_ago,
    "<t-" => :label_more_than_ago,
    "t-"  => :label_ago,
    "~"   => :label_contains,
    "!~"  => :label_not_contains
  }

  def operators
    @operators || self.class.operators
  end

  #
  # Operators By Filter Type
  #
  class_inheritable_hash :operators_by_filter_type
  attr_writer :operators_by_filter_type

  self.operators_by_filter_type = {
    :list => [ "=", "!" ],
    :list_optional => [ "=", "!", "!*", "*" ],
    :date => [ "=", ">=", "<=", "><", "<t+", ">t+", "t+", "t", "w", ">t-", "<t-", "t-" ],
    :date_past => [ "=", ">=", "<=", "><", ">t-", "<t-", "t-", "t", "w" ],
    :string => [ "=", "~", "!", "!~" ],
    :text => [  "~", "!~" ],
    :integer => [ "=", ">=", "<=", "!*", "*" ]
  }

  def operators_by_filter_type
   @operators_by_filter_type || self.class.operators_by_filter_type
  end

  #
  # Available Columns
  #
  class_inheritable_array :available_columns
  attr_writer :available_columns

  self.available_columns = []
  
  def available_columns
    @available_columns || self.class.available_columns
  end

  #
  # Available Filters
  #
  class_inheritable_hash :available_filters
  attr_writer :available_filters

  self.available_filters = {}
  
  def available_filters
    @available_filters || self.class.available_filters
  end

  def validate
    filters.each_key do |field|
      errors.add label_for(field), :blank unless
          # filter requires one or more values
          !field_blank?(field) or 
          # filter doesn't require any value
          field_blank_allowed?(field)
    end if filters
  end

  def field_blank?(field)
    !!(values_for(field) and !values_for(field).first.blank?)
  end

  def field_blank_allowed?(field)
    ["!*", "*", "t", "w"].include? operator_for(field)
  end

  def has_filter?(field)
    filters and filters[field]
  end

  def type_for(field)
    available_filters[field][:type] if available_filters.has_key?(field)
  end

  def operator_for(field)
    has_filter?(field) ? filters[field][:operator] : nil
  end

  def values_for(field)
    has_filter?(field) ? filters[field][:values] : nil
  end

  def value_for(field, index=0)
    (values_for(field) || [])[index]
  end

  def label_for(field)
    label = available_filters[field][:name] if available_filters.has_key?(field)
    label ||= field.gsub(/\_id$/, "")
  end

  # Returns an array of columns that can be used to group the results
  def groupable_columns
    available_columns.select { |c| c.groupable }
  end

  # Returns a Hash of columns and the key for sorting
  def sortable_columns
    available_columns.inject({}) do |h, column|
      h[column.name.to_s] = column.sortable
      h
    end
  end

  def columns
    if has_default_columns?
      [available_columns.first]
    else
      # preserve the column_names order
      column_names.collect {|name| available_columns.find {|col| col.name == name}}.compact
    end
  end

  def column_names=(names)
    if names
      names = names.select {|n| n.is_a?(Symbol) || !n.blank? }
      names = names.collect {|n| n.is_a?(Symbol) ? n : n.to_sym }
      # Set column_names to nil if default columns
      if names.map(&:to_s) == default_columns
        names = nil
      end
    end
    write_attribute(:column_names, names)
  end

  def has_column?(column)
    column_names && column_names.include?(column.name)
  end

  def has_default_columns?
    column_names.nil? || column_names.empty?
  end

  def default_columns
    [available_columns.first]
  end

  def sort_criteria=(arg)
    c = []
    if arg.is_a?(Hash)
      arg = arg.keys.sort.collect {|k| arg[k]}
    end
    c = arg.select {|k,o| !k.to_s.blank?}.slice(0,3).collect {|k,o| [k.to_s, o.to_s == 'desc' ? o.to_s : 'asc']}
    write_attribute(:sort_criteria, c)
  end

  def sort_criteria
    read_attribute(:sort_criteria) || []
  end

  def sort_criteria_key(arg)
    sort_criteria && sort_criteria[arg] && sort_criteria[arg].first
  end

  def sort_criteria_order(arg)
    sort_criteria && sort_criteria[arg] && sort_criteria[arg].last
  end

  # Returns the SQL sort order that should be prepended for grouping
  def group_by_sort_order
    if grouped? && (column = group_by_column)
      column.sortable.is_a?(Array) ?
        column.sortable.collect {|s| "#{s} #{column.default_order}"}.join(',') :
        "#{column.sortable} #{column.default_order}"
    end
  end

  # Returns true if the query is a grouped query
  def grouped?
    !group_by_column.nil?
  end

  def group_by_column
    groupable_columns.detect {|c| c.groupable && c.name.to_s == group_by}
  end

  def group_by_statement
    group_by_column.try(:groupable)
  end

  def statement
    # filters clauses
    filters_clauses = []
    filters.each_key do |field|
      v = values_for(field).clone
      next unless v and !v.empty?
      operator = operator_for(field)
      db_table = queryable_class.table_name
      db_field = field
      sql = '(' + sql_for_field(field, operator, v, db_table, db_field) + ')'
      filters_clauses << sql
    end if filters and valid?
    filters_clauses.join(' AND ')
  end

  def query(options={})
    order_option = [group_by_sort_order, options[:order]].reject { |s| s.blank? }.join(',')
    order_option = nil if order_option.blank?
    queryable_class.find :all, 
      :include => (options[:include] || []).uniq,
      :conditions => self.class.merge_conditions(statement, options[:conditions]),
      :order => order_option,
      :limit => options[:limit],
      :offset => options[:offset]
  rescue ::ActiveRecord::StatementInvalid => e
    raise Query::StatementInvalid.new(e.message)
  end

  private

  # Helper method to generate the WHERE sql for a +field+, +operator+ and a +value+
  def sql_for_field(field, operator, value, db_table, db_field, is_custom_filter=false)
    sql = ''
    case operator
    when "="
      if [:date, :date_past].include?(type_for(field))
        sql = date_clause(db_table, db_field, (Date.parse(value.first) rescue nil), (Date.parse(value.first) rescue nil))
      else
        if value.any?
          sql = "#{db_table}.#{db_field} IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
        else
          # IN an empty set
          sql = "0=1"
        end
      end
    when "!"
      if value.present?
        sql = "(#{db_table}.#{db_field} IS NULL OR #{db_table}.#{db_field} NOT IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + "))"
      else
        # empty set of forbidden values allows all results
        sql = "1=1"
      end
    when "!*"
      sql = "#{db_table}.#{db_field} IS NULL"
      sql << " OR #{db_table}.#{db_field} = ''" if is_custom_filter
    when "*"
      sql = "#{db_table}.#{db_field} IS NOT NULL"
      sql << " AND #{db_table}.#{db_field} <> ''" if is_custom_filter
    when ">="
      if [:date, :date_past].include?(type_for(field))
        sql = date_clause(db_table, db_field, (Date.parse(value.first) rescue nil), nil)
      else
        if is_custom_filter
          sql = "CAST(#{db_table}.#{db_field} AS decimal(60,3)) >= #{value.first.to_i}"
        else
          sql = "#{db_table}.#{db_field} >= #{value.first.to_i}"
        end
      end
    when "<="
      if [:date, :date_past].include?(type_for(field))
        sql = date_clause(db_table, db_field, nil, (Date.parse(value.first) rescue nil))
      else
        if is_custom_filter
          sql = "CAST(#{db_table}.#{db_field} AS decimal(60,3)) <= #{value.first.to_i}"
        else
          sql = "#{db_table}.#{db_field} <= #{value.first.to_i}"
        end
      end
    when "><"
      if [:date, :date_past].include?(type_for(field))
        sql = date_clause(db_table, db_field, (Date.parse(value[0]) rescue nil), (Date.parse(value[1]) rescue nil))
      else
        if is_custom_filter
          sql = "CAST(#{db_table}.#{db_field} AS decimal(60,3)) BETWEEN #{value[0].to_i} AND #{value[1].to_i}"
        else
          sql = "#{db_table}.#{db_field} BETWEEN #{value[0].to_i} AND #{value[1].to_i}"
        end
      end
    when ">t-"
      sql = relative_date_clause(db_table, db_field, - value.first.to_i, 0)
    when "<t-"
      sql = relative_date_clause(db_table, db_field, nil, - value.first.to_i)
    when "t-"
      sql = relative_date_clause(db_table, db_field, - value.first.to_i, - value.first.to_i)
    when ">t+"
      sql = relative_date_clause(db_table, db_field, value.first.to_i, nil)
    when "<t+"
      sql = relative_date_clause(db_table, db_field, 0, value.first.to_i)
    when "t+"
      sql = relative_date_clause(db_table, db_field, value.first.to_i, value.first.to_i)
    when "t"
      sql = relative_date_clause(db_table, db_field, 0, 0)
    when "w"
      first_day_of_week = l(:general_first_day_of_week).to_i
      day_of_week = Date.today.cwday
      days_ago = (day_of_week >= first_day_of_week ? day_of_week - first_day_of_week : day_of_week + 7 - first_day_of_week)
      sql = relative_date_clause(db_table, db_field, - days_ago, - days_ago + 6)
    when "~"
      sql = "LOWER(#{db_table}.#{db_field}) LIKE '%#{connection.quote_string(value.first.to_s.downcase)}%'"
    when "!~"
      sql = "LOWER(#{db_table}.#{db_field}) NOT LIKE '%#{connection.quote_string(value.first.to_s.downcase)}%'"
    end

    return sql
  end

  # Returns a SQL clause for a date or datetime field.
  def date_clause(table, field, from, to)
    s = []
    if from
      s << ("#{table}.#{field} > '%s'" % [connection.quoted_date((from - 1).to_time.end_of_day)])
    end
    if to
      s << ("#{table}.#{field} <= '%s'" % [connection.quoted_date(to.to_time.end_of_day)])
    end
    s.join(' AND ')
  end

  # Returns a SQL clause for a date or datetime field using relative dates.
  def relative_date_clause(table, field, days_from, days_to)
    date_clause(table, field, (days_from ? Date.today + days_from : nil), (days_to ? Date.today + days_to : nil))
  end
end
