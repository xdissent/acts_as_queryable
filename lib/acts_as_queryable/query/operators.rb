# encoding: utf-8

module ActsAsQueryable::Query
  module Operators

    # Public: Return the available query operators from either an instance 
    # or class attribute. Each operator is a key with its label as the value.
    #
    # Returns the operators as a Hash.
    def operators
      @operators || self.class.read_inheritable_attribute(:operators)
    end
    
    # Public: Return the available query operators for each filter type as
    # a Hash, with filter types as keys and Arrays of String operators as
    # values. An instance attribute is retrieved first, falling back to a
    # class attribute.
    #
    # Returns the operators as a Hash.
    def operators_by_filter_type
     @operators_by_filter_type || self.class.read_inheritable_attribute(:operators_by_filter_type)
    end

    def operators_for(name)
      operators_by_filter_type[type_for(name)] || []
    end
  end
end