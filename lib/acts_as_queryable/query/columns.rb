# encoding: utf-8

module ActsAsQueryable::Query
  module Columns

    def columns
      self[:columns].present? && self[:columns] || default_columns
    end

    def columns=(names)
      # Only accept enumerable objects.
      if names.is_a?(Enumerable)
        names = names.map do |name|
          # Filter out non-symbols and blank values.
          if name.is_a?(Symbol) || !name.blank?
            # Enforce symbols
            n = name.to_s.to_sym
            # Only accept real column names
            n if column_available?(n)
          end
        end.compact

        # Set to nil if equal to the default columns.
        names = nil if names == default_columns || names.blank?
      end
      # Always write attribute and let validation do its magic.
      self[:columns] = names
    end

    # Public: Return the available query result columns from either an instance 
    # or class attribute.
    #
    # Returns the available columns as a Hash.
    def available_columns
      @available_columns || self.class.read_inheritable_attribute(:available_columns)
    end

    def column_available?(name)
      !!available_columns[name]
    end

    # Public: Fetch the default column names for the query as an Array. The 
    # default is the first available column, or none if no columns are available.
    #
    # Returns an Array of the default column names or an empty Array.
    def default_columns
      [available_columns.keys.first].compact
    end

    def has_default_columns?
      self[:columns].blank?
    end

    def groupable_columns
      available_columns.map { |n, c| n if c[:groupable] }.compact
    end

    def sortable_columns
      available_columns.map { |n, c| n if c[:sortable] }.compact
    end

    # Public: Return an available query column's defintion by name,
    # or an empty Hash.
    #
    # name - The name of the column to retrieve.
    #
    # Returns the Hash of the column definition.
    def column_for(name)
      available_columns[name] || {}
    end

    def groupable_for(name)
      column_for(name)[:groupable]
    end

    def sortable_for(name)
      column_for(name)[:sortable]
    end

    def default_order_for(name)
      column_for(name)[:default_order]
    end

    def column_label_for(name)
      column_for(name)[:label] || label_for(name)
    end

    # Public: Determines whether a column is selected for the query.
    #
    # name - The column name as a Symbol.
    #
    # Returns a boolean indicating whether the column exists.
    def has_column?(name)
      columns.present? && columns.include?(name)
    end
  end
end