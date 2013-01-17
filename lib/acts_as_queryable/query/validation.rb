# encoding: utf-8

module ActsAsQueryable::Query
  module Validation

    # Public: Validates the filters and adds a :blank error on each if
    # the filter values are blank or :inclusion error if a filter is not
    # available.
    #
    # Returns nothing.
    def validate_filters
      filters.each_key do |name|
        if !filter_available?(name)
          errors.add filter_label_for(name), :inclusion
        elsif values_blank?(name) && !blank_allowed?(name)
          errors.add filter_label_for(name), :blank 
        end
      end if filters.present?
    end

    # Public: Validates the columns and adds an :inclusion error if a column 
    # is not available.
    #
    # Returns the available columns as a Hash.
    def validate_columns
      columns.each do |name|
        if !column_available?(name)
          errors.add column_label_for(name), :inclusion
        end
      end if columns.present?
    end

    # Public: Validates the group_by attribute and adds an :inclusion error
    # if the group_by column is not available. An :invalid error is added if
    # the group_by column is not groupable per the column definition.
    #
    # Returns the available columns as a Hash.
    def validate_group_by
      if group_by.present?
        if !column_available?(group_by)
          errors.add column_label_for(group_by), :inclusion
        elsif !groupable_for(group_by)
          errors.add column_label_for(group_by), :invalid
        end
      end
    end

    # Public: Determines if a filter's values are blank.
    #
    # name - The filter name as a Symbol.
    # values - Values to check for blankness or nil for current filter values.
    #
    # Returns a boolean indicating whether the filter's values are blank.
    def values_blank?(name, values=nil)
      values ||= values_for(name)
      values.blank? || values.first.blank?
    end

    # Public: Determines if a filter's values are allowed to be blank.
    #
    # name - The filter name as a Symbol.
    #
    # Returns a boolean indicating whether blank filter values are allowed.
    def blank_allowed?(name)
      ["!*", "*", "t", "w"].include? operator_for(name)
    end
  end
end