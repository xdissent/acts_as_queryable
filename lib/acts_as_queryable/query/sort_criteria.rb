# encoding: utf-8

module ActsAsQueryable::Query
  module SortCriteria

    def sort_criteria
      self[:sort_criteria] || []
    end

    def sort_criteria=(arg)
      if arg.is_a?(Enumerable)
        arg = arg.keys.sort.map { |k| arg[k] } if arg.is_a?(Hash)
        arg = arg.select { |k, o| k.to_s.present? }.slice(0, 3).map { |k, o| [k.to_s.to_sym, (o.to_s == 'desc' ? :desc : :asc)] }
      end
      self[:sort_criteria] = arg
    end
  end
end