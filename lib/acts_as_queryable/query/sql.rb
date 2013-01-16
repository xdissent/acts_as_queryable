# encoding: utf-8

module ActsAsQueryable::Query
  module Sql
  
    def to_sql
      return nil unless filters.present? and valid?
      filters.map { |n, f| sql_for(n) }.reject { |s| s.blank? }.join(' AND ')
    end

    def query(options={})
      order_option = [group_by_clause, sort_criteria_clause, options[:order]].reject { |s| s.blank? }.join(',')
      order_option = nil if order_option.blank?
      queryable_class.find :all, 
        :include => (options[:include] || []).uniq,
        :conditions => self.class.merge_conditions(to_sql, options[:conditions]),
        :order => order_option,
        :limit => options[:limit],
        :offset => options[:offset]
    rescue ::ActiveRecord::StatementInvalid => e
      raise StatementInvalid.new(e.message)
    end

  private
    def sort_criteria_clause
      return nil unless sort_criteria.present?
      sort_criteria.reverse.map { |name, order| order_clause name, order }.join(',')
    end

    def order_clause(name, order)
      # Translate name to sortable (true, String table name and field, or array of table names and fields)
      sortable = sortable_for(name)
      return nil unless sortable
      # Translate true into field name column the the queryable class table.
      sortable = "#{self.queryable_class.table_name}.#{name}" if sortable == true
      # Force to array and join
      Array(sortable).map { |s| "#{s} #{order}" }.join(',')
    end

    def group_by_clause
      return nil unless grouped?
      order_clause group_by, (default_order_for(group_by) || 'asc')
    end

    # Returns a SQL clause for a date or datetime field.
    def date_clause(table, field, from, to)
      s = []
      s << ("#{table}.#{field} > '%s'" % [connection.quoted_date((from - 1).to_time.end_of_day)]) if from
      s << ("#{table}.#{field} <= '%s'" % [connection.quoted_date(to.to_time.end_of_day)]) if to
      s.join(' AND ')
    end

    # Returns a SQL clause for a date or datetime field using relative dates.
    def relative_date_clause(table, field, days_from, days_to)
      date_clause(table, field, (days_from ? Date.today + days_from : nil), (days_to ? Date.today + days_to : nil))
    end

    # Helper method to generate the WHERE sql for a +field+, +operator+ and a +value+
    def sql_for(name)
      return "" if values_blank?(name)

      value = values_for(name)
      type = type_for(name)
      table = queryable_class.table_name
      sql = nil

      case operator_for(name)
      when "="
        if [:date, :date_past].include?(type)
          sql = date_clause(table, name, (Date.parse(value.first) rescue nil), (Date.parse(value.first) rescue nil))
        else
          if value.any?
            sql = "#{table}.#{name} IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + ")"
          else
            # IN an empty set
            sql = "0=1"
          end
        end
      when "!"
        if value.present?
          sql = "(#{table}.#{name} IS NULL OR #{table}.#{name} NOT IN (" + value.collect{|val| "'#{connection.quote_string(val)}'"}.join(",") + "))"
        else
          # empty set of forbidden values allows all results
          sql = "1=1"
        end
      when "!*"
        sql = "#{table}.#{name} IS NULL"
      when "*"
        sql = "#{table}.#{name} IS NOT NULL"
      when ">="
        if [:date, :date_past].include?(type)
          sql = date_clause(table, name, (Date.parse(value.first) rescue nil), nil)
        else
          sql = "#{table}.#{name} >= #{value.first.to_i}"
        end
      when "<="
        if [:date, :date_past].include?(type)
          sql = date_clause(table, name, nil, (Date.parse(value.first) rescue nil))
        else
          sql = "#{table}.#{name} <= #{value.first.to_i}"
        end
      when "><"
        if [:date, :date_past].include?(type)
          sql = date_clause(table, name, (Date.parse(value[0]) rescue nil), (Date.parse(value[1]) rescue nil))
        else
          sql = "#{table}.#{name} BETWEEN #{value[0].to_i} AND #{value[1].to_i}"
        end
      when ">t-"
        sql = relative_date_clause(table, name, - value.first.to_i, 0)
      when "<t-"
        sql = relative_date_clause(table, name, nil, - value.first.to_i)
      when "t-"
        sql = relative_date_clause(table, name, - value.first.to_i, - value.first.to_i)
      when ">t+"
        sql = relative_date_clause(table, name, value.first.to_i, nil)
      when "<t+"
        sql = relative_date_clause(table, name, 0, value.first.to_i)
      when "t+"
        sql = relative_date_clause(table, name, value.first.to_i, value.first.to_i)
      when "t"
        sql = relative_date_clause(table, name, 0, 0)
      when "w"
        first_day_of_week = 7
        day_of_week = Date.today.cwday
        days_ago = (day_of_week >= first_day_of_week ? day_of_week - first_day_of_week : day_of_week + 7 - first_day_of_week)
        sql = relative_date_clause(table, name, - days_ago, - days_ago + 6)
      when "~"
        sql = "LOWER(#{table}.#{name}) LIKE '%#{connection.quote_string(value.first.to_s.downcase)}%'"
      when "!~"
        sql = "LOWER(#{table}.#{name}) NOT LIKE '%#{connection.quote_string(value.first.to_s.downcase)}%'"
      end

      sql.empty? ? "(#{sql})" : ""
    end
  end
end