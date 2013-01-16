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
  end
end