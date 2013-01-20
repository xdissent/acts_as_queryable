# encoding: utf-8

module ActsAsQueryable::Query
  module Filters
    
    def filters
      (self[:filters] || {}).symbolize_keys
    end

    # Public: Return the available query filters from either an instance 
    # or class attribute.
    #
    # Returns the available filters as a Hash.
    def available_filters
      @available_filters ||= eval_class_filters
    end

    # Public: Evaluate conditionals and dynamic values in filter definitions.
    #
    # Returns a Hash of resulting filters.
    def eval_class_filters
      Hash[self.class.read_inheritable_attribute(:available_filters).reject { |n, f| 
          f[:if].is_a?(Proc) && !f[:if].call(self)
        }.map { |n, f|
          [n.to_sym, f.merge(f[:choices].is_a?(Proc) ? {:choices => f[:choices].call(self)} : {})]
        }
      ]
    end

    # Public: Return the available query filters from either an instance 
    # or class attribute. Filters are sorted by :order key in the filter 
    # definition.
    #
    # Returns the available filters as a an Array of Arrays of name, filter.
    def available_filters_sorted
      available_filters.sort { |a,b| a[1][:order] <=> b[1][:order] }
    end

    def filter_available?(name)
      !!available_filters[name]
    end

    # Public: Return an available query filter's defintion by name,
    # or an empty Hash.
    #
    # name - The name of the filter to retrieve.
    #
    # Returns the Hash of the filter definition.
    def filter_for(name)
      available_filters[name] || {}
    end

    def type_for(name)
      filter_for(name)[:type]
    end

    def choices_for(name)
      filter_for(name)[:choices]
    end

    def filter_label_for(name)
      filter_for(name)[:label] || label_for(name)
    end

    # Public: Determines whether a filter exists for the query.
    #
    # name - The filter name as a Symbol.
    #
    # Returns a boolean indicating whether the filter exists.
    def has_filter?(name)
      filters.present? && filters[name]
    end

    def operator_for(name)
      filters[name][:operator] if has_filter?(name)
    end

    def values_for(name)
      filters[name][:values] if has_filter?(name)
    end

    def value_for(name, index=0)
      (values_for(name) || [])[index]
    end

    def add_filter(name, operator, values)
      return unless values.nil? || values.is_a?(Array)
      # check if name is defined as an available filter
      if filter_available?(name.to_sym)
        # TODO: check if operator is allowed for that filter
        self[:filters] = filters.merge(name.to_sym => {:operator => operator, :values => (values || [''])})
      end
    end

    def add_short_filter(name, expression)
      return unless expression
      parms = expression.to_s.scan(/^(!\*|!|\*)?(.*)$/).first
      add_filter name, (parms[0] || "="), [parms[1] || ""]
    end

    # Add multiple filters using +add_filter+
    def add_filters(filters, operators, values)
      if filters.is_a?(Array) && operators.is_a?(Hash) && (values.nil? || values.is_a?(Hash))
        filters.each do |name|
          add_filter(name, operators[name], values && values[name])
        end
      end
    end
  end
end