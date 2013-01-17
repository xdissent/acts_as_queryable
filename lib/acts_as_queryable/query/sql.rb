# encoding: utf-8

module ActsAsQueryable::Query
  module Sql
  
    def to_sql
      return nil unless filters.present? and valid?
      filters.map { |n, f| sql_for(n) }.reject { |s| s.blank? }.join(' AND ')
    end

    def query(options={})
      order_option = [group_by_sort_clause, sort_criteria_clause, options[:order]].reject { |s| s.blank? }.join(',')
      order_option = nil if order_option.blank?
      queryable_class.find :all, 
        :include => (options[:include] || []),
        :conditions => self.class.merge_conditions(to_sql, options[:conditions]),
        :order => order_option,
        :limit => options[:limit],
        :offset => options[:offset]
    rescue ::ActiveRecord::StatementInvalid => e
      raise StatementInvalid.new(e.message)
    end

    def count(options={})
      queryable_class.count :include => (options[:include] || []), 
        :conditions => self.class.merge_conditions(to_sql, options[:conditions])
    rescue ::ActiveRecord::StatementInvalid => e
      raise StatementInvalid.new(e.message)
    end

    def count_by_group(options={})
      return {nil => count(options)} unless grouped?
      begin
        # Rails will raise an (unexpected) RecordNotFound if there's only a nil group value
        r = queryable_class.count :group => group_by_clause, 
          :include => (options[:include] || [group_by]), 
          :conditions => self.class.merge_conditions(to_sql, options[:conditions])
      rescue ActiveRecord::RecordNotFound
        r = {nil => count(options)}
      end
      r
    rescue ::ActiveRecord::StatementInvalid => e
      raise StatementInvalid.new(e.message)
    end

    def group_by_clause
      return nil unless grouped?
      groupable = groupable_for(group_by)
      groupable = group_by.to_s if groupable == true
      groupable
    end

    def group_by_sort_clause
      return nil unless grouped?
      order_clause group_by, (default_order_for(group_by) || 'asc')
    end

    def sort_criteria_clause
      return nil unless sort_criteria.present?
      sort_criteria.reverse.map { |name, order| order_clause name, order }.reject { |s| s.blank? }.join(',')
    end

    def order_clause(name, order)
      # Translate name to sortable (true, String table name and field, or array of table names and fields)
      sortable = sortable_for(name)
      # Force valid sortable value for group_by.
      sortable ||= true if group_by == name
      # Bail if we don't have anything to sort on.
      return nil unless sortable
      # Translate true into field name column the the queryable class table.
      sortable = "#{self.queryable_class.table_name}.#{name}" if sortable == true
      # Force to array and join
      Array(sortable).map { |s| "#{s} #{order}" }.reject { |s| s.blank? }.join(',')
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
    def sql_for(name, operator=nil, values=nil, table=nil, field=nil, type=nil)
      values ||= values_for(name)
      # return if values_blank?(name, values)
      type ||= type_for(name)
      table ||= queryable_class.table_name
      operator ||= operator_for(name)
      field ||= name
      sql = nil

      case operator
      when "="
        if [:date, :date_past].include?(type)
          sql = date_clause(table, field, (Date.parse(values.first) rescue nil), (Date.parse(values.first) rescue nil))
        elsif type == :boolean
          if values.first.to_i == 0
            sql = "#{table}.#{field} = #{connection.quoted_false}"
          else
            sql = "#{table}.#{field} = #{connection.quoted_true}"
          end
        else
          if values.present?
            sql = "#{table}.#{field} IN (" + values.map{ |val| "'#{connection.quote_string(val)}'" }.join(",") + ")"
          else
            # IN an empty set
            sql = "0=1"
          end
        end
      when "!"
        if values.present?
          sql = "(#{table}.#{field} IS NULL OR #{table}.#{field} NOT IN (" + values.map{ |val| "'#{connection.quote_string(val)}'" }.join(",") + "))"
        else
          # empty set of forbidden values allows all results
          sql = "1=1"
        end
      when "!*"
        sql = "#{table}.#{field} IS NULL"
      when "*"
        sql = "#{table}.#{field} IS NOT NULL"
      when ">="
        if [:date, :date_past].include?(type)
          sql = date_clause(table, field, (Date.parse(values.first) rescue nil), nil)
        else
          sql = "#{table}.#{field} >= #{values.first.to_i}"
        end
      when "<="
        if [:date, :date_past].include?(type)
          sql = date_clause(table, field, nil, (Date.parse(values.first) rescue nil))
        else
          sql = "#{table}.#{field} <= #{values.first.to_i}"
        end
      when "><"
        if [:date, :date_past].include?(type)
          sql = date_clause(table, field, (Date.parse(values[0]) rescue nil), (Date.parse(values[1]) rescue nil))
        else
          sql = "#{table}.#{field} BETWEEN #{values[0].to_i} AND #{values[1].to_i}"
        end
      when ">t-"
        sql = relative_date_clause(table, field, - values.first.to_i, 0)
      when "<t-"
        sql = relative_date_clause(table, field, nil, - values.first.to_i)
      when "t-"
        sql = relative_date_clause(table, field, - values.first.to_i, - values.first.to_i)
      when ">t+"
        sql = relative_date_clause(table, field, values.first.to_i, nil)
      when "<t+"
        sql = relative_date_clause(table, field, 0, values.first.to_i)
      when "t+"
        sql = relative_date_clause(table, field, values.first.to_i, values.first.to_i)
      when "t"
        sql = relative_date_clause(table, field, 0, 0)
      when "w"
        first_day_of_week = 7
        day_of_week = Date.today.cwday
        days_ago = (day_of_week >= first_day_of_week ? day_of_week - first_day_of_week : day_of_week + 7 - first_day_of_week)
        sql = relative_date_clause(table, field, - days_ago, - days_ago + 6)
      when "~"
        sql = "LOWER(#{table}.#{field}) LIKE '%#{connection.quote_string(values.first.to_s.downcase)}%'"
      when "!~"
        sql = "LOWER(#{table}.#{field}) NOT LIKE '%#{connection.quote_string(values.first.to_s.downcase)}%'"
      end

      sql.empty? ? nil : "(#{sql})"
    end
  end
end