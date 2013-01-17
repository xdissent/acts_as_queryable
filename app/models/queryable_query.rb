# encoding: utf-8

class QueryableQuery < ActiveRecord::Base
  unloadable

  include ActsAsQueryable::Query::Filters
  include ActsAsQueryable::Query::Columns
  include ActsAsQueryable::Query::Operators
  include ActsAsQueryable::Query::GroupBy
  include ActsAsQueryable::Query::Sort
  include ActsAsQueryable::Query::Sql
  include ActsAsQueryable::Query::Validation

  serialize :filters
  serialize :columns
  serialize :sort_criteria, Array

  validates_presence_of :name, :on => :save
  validates_length_of :name, :maximum => 255
  validate :validate_filters, :validate_columns, :validate_group_by

  # Queryable class/instance accessors
  class_inheritable_accessor :queryable_class
  class_inheritable_hash_writer :operators_by_filter_type, :available_columns, :available_filters, :operators
  # attr_writer :queryable_class, :operators_by_filter_type, :available_columns, :available_filters, :operators

  # Default operators
  self.operators = {
    "="   => :is,
    "!"   => :is_not,
    "!*"  => :none,
    "*"   => :all,
    ">="  => :greater_than_equal,
    "<="  => :less_than_equal,
    "><"  => :is_between,
    "<t+" => :in_less_than,
    ">t+" => :in_more_than,
    "t+"  => :in,
    "t"   => :today,
    "w"   => :this_week,
    ">t-" => :less_than_days_ago,
    "<t-" => :more_than_days_ago,
    "t-"  => :days_ago,
    "~"   => :contains,
    "!~"  => :does_not_contain
  }

  # Default operators by filter type
  self.operators_by_filter_type = {
    :list =>          [ "=", "!" ],
    :list_optional => [ "=", "!", "!*", "*" ],
    :date =>          [ "=", ">=", "<=", "><", "<t+", ">t+", "t+", "t", "w", ">t-", "<t-", "t-" ],
    :date_past =>     [ "=", ">=", "<=", "><", ">t-", "<t-", "t-", "t", "w" ],
    :string =>        [ "=", "~", "!", "!~" ],
    :text =>          [ "~", "!~" ],
    :integer =>       [ "=", ">=", "<=", "!*", "*" ],
    :boolean =>       [ "=" ]
  }

  self.available_columns = {}
  self.available_filters = {}

  # Public: Return the class of the object of the query from either an
  # instance or class attribute.
  #
  # Returns the queryable class constant.
  def queryable_class
    @queryable_class || self.class.queryable_class
  end

  def label_for(name, options={})
    I18n.t(name, {:default => name.to_s.titleize}.merge(options))
  end
end
