# encoding: utf-8

require File.dirname(__FILE__) + '/../test_helper'
require 'pry'

class QueryableQueryTest < ActiveSupport::TestCase
  def setup
    @columns = {
      :name => {:sortable => true, :default_order => "asc"},
      :category => {:sortable => true, :groupable => true}
    }
    @filters = {
      :name => {:type => :string, :order => 1},
      :category => {:type => :list, :order => 2},
      :invisible => {:if => lambda { |q| false }},
      :visible => {:if => lambda { |q| true }},
      :choices => {:type => :list, :choices => [1, 2, 3]},
      :dyn_choices => {:type => :list, :choices => lambda { |q| [q.name, Date.today] }}
    }

    Object.const_set :Foo, Class.new(ActiveRecord::Base)
    Foo.acts_as_queryable :columns => @columns, :filters => @filters
    @query = FooQuery.new :name => "_"
  end

  def teardown
    Object.send :remove_const, :Foo
    Object.send :remove_const, :FooQuery
  end

  context "a query's available columns" do
    should "be available as a hash attribute on the query class" do
      assert_equal @columns, @query.available_columns
    end
  end

  context "a query's available filters" do
    should "evaluate conditionals" do
      assert @query.filter_available?(:visible)
      assert !@query.filter_available?(:invisible)
    end

    should "evaluate choices" do
      assert_equal [1, 2, 3], @query.choices_for(:choices)
      assert_equal ["_", Date.today], @query.choices_for(:dyn_choices)
    end
  end

  # fixtures :projects, :users, :queryable_queries

  # context "a query" do
  #   should "return all widgets" do
  #     query = WidgetQuery.new :name => "_"
  #     widget_ids = query.query.collect(&:id)

  #     assert widget_ids.include?(1)
  #     assert widget_ids.include?(2)
  #     assert widget_ids.include?(3)
  #     assert widget_ids.include?(4)
  #     assert widget_ids.include?(5)
  #     assert widget_ids.include?(6)
  #     assert widget_ids.include?(7)
  #   end

  #   should "return widgets filtered on name equals" do
  #     query = WidgetQuery.new :name => "_", 
  #       :filters => {'name' => {:operator => "=", :values => [widgets(:widget_4).name]}}
  #     widget_ids = query.query.collect(&:id)

  #     assert !widget_ids.include?(1)
  #     assert !widget_ids.include?(2)
  #     assert !widget_ids.include?(3)
  #     assert widget_ids.include?(4)
  #     assert !widget_ids.include?(5)
  #     assert !widget_ids.include?(6)
  #     assert !widget_ids.include?(7)
  #   end

  #   should "return widgets filtered on name not equals" do
  #     query = WidgetQuery.new :name => "_", 
  #       :filters => {'name' => {:operator => "!", :values => [widgets(:widget_4).name]}}
  #     widget_ids = query.query.collect(&:id)

  #     assert widget_ids.include?(1)
  #     assert widget_ids.include?(2)
  #     assert widget_ids.include?(3)
  #     assert !widget_ids.include?(4)
  #     assert widget_ids.include?(5)
  #     assert widget_ids.include?(6)
  #     assert widget_ids.include?(7)
  #   end

  #   should "return widgets filtered on name contains" do
  #     query = WidgetQuery.new :name => "_", 
  #       :filters => {'name' => {:operator => "~", :values => ["pariatur"]}}
  #     widget_ids = query.query.collect(&:id)

  #     assert !widget_ids.include?(1)
  #     assert !widget_ids.include?(2)
  #     assert !widget_ids.include?(3)
  #     assert !widget_ids.include?(4)
  #     assert widget_ids.include?(5)
  #     assert !widget_ids.include?(6)
  #     assert !widget_ids.include?(7)
  #   end

  #   should "return widgets filtered on name not contains" do
  #     query = WidgetQuery.new :name => "_", 
  #       :filters => {'name' => {:operator => "!~", :values => ["pariatur"]}}
  #     widget_ids = query.query.collect(&:id)

  #     assert widget_ids.include?(1)
  #     assert widget_ids.include?(2)
  #     assert widget_ids.include?(3)
  #     assert widget_ids.include?(4)
  #     assert !widget_ids.include?(5)
  #     assert widget_ids.include?(6)
  #     assert widget_ids.include?(7)
  #   end
  # end
end
