# encoding: utf-8

module ActsAsQueryable::Query
  module Sort

    def sort_criteria
      self[:sort_criteria] || []
    end

    def sort_criteria=(arg)
      arg = arg.keys.sort.map { |k| arg[k] } if arg.is_a?(Hash)
      c = arg.select { |k,o| k.to_s.present? }.slice(0, 3).map {|k,o| [k.to_s, o.to_s == 'desc' ? o.to_s : 'asc'] }
      self[:sort_criteria] = c
    end

    def sort_criteria_key(arg)
      sort_criteria && sort_criteria[arg] && sort_criteria[arg].first
    end

    def sort_criteria_order(arg)
      sort_criteria && sort_criteria[arg] && sort_criteria[arg].last
    end
  end
end