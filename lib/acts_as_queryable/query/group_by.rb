# encoding: utf-8

module ActsAsQueryable::Query
  module GroupBy

    def group_by
      self[:group_by].to_sym if self[:group_by].present?
    end

    def group_by=(name)
      self[:group_by] = name.to_s
    end

    def grouped?
      column_available?(group_by) && groupable_for(group_by)
    end

    # Returns the SQL sort order that should be prepended for grouping
    def group_by_sort_order
      return nil unless grouped?
      sortable = sortable_for(group_by)
      # If sortable is a boolean true, use the queryable class field with the same name.
      sortable = "#{self.queryable_class.table_name}.#{name}" if sortable == true
      sortable.is_a?(Array) ?
        sortable.collect { |s| "#{s} #{default_order_for(name)}" }.join(',') :
        "#{sortable} #{default_order_for(name)}"
    end
  end
end