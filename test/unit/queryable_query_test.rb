# encoding: utf-8

require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/widget'

class QueryableQueryTest < ActiveSupport::TestCase
  fixtures :projects, :users, :widgets, :queryable_queries

  context "a query" do
    should "return all widgets" do
      query = WidgetQuery.new :name => "_"
      widget_ids = query.query.collect(&:id)

      assert widget_ids.include?(1)
      assert widget_ids.include?(2)
      assert widget_ids.include?(3)
      assert widget_ids.include?(4)
      assert widget_ids.include?(5)
      assert widget_ids.include?(6)
      assert widget_ids.include?(7)
    end

    should "return widgets filtered on name equals" do
      query = WidgetQuery.new :name => "_", 
        :filters => {'name' => {:operator => "=", :values => [widgets(:widget_4).name]}}
      widget_ids = query.query.collect(&:id)

      assert !widget_ids.include?(1)
      assert !widget_ids.include?(2)
      assert !widget_ids.include?(3)
      assert widget_ids.include?(4)
      assert !widget_ids.include?(5)
      assert !widget_ids.include?(6)
      assert !widget_ids.include?(7)
    end

    should "return widgets filtered on name not equals" do
      query = WidgetQuery.new :name => "_", 
        :filters => {'name' => {:operator => "!", :values => [widgets(:widget_4).name]}}
      widget_ids = query.query.collect(&:id)

      assert widget_ids.include?(1)
      assert widget_ids.include?(2)
      assert widget_ids.include?(3)
      assert !widget_ids.include?(4)
      assert widget_ids.include?(5)
      assert widget_ids.include?(6)
      assert widget_ids.include?(7)
    end

    should "return widgets filtered on name contains" do
      query = WidgetQuery.new :name => "_", 
        :filters => {'name' => {:operator => "~", :values => ["pariatur"]}}
      widget_ids = query.query.collect(&:id)

      assert !widget_ids.include?(1)
      assert !widget_ids.include?(2)
      assert !widget_ids.include?(3)
      assert !widget_ids.include?(4)
      assert widget_ids.include?(5)
      assert !widget_ids.include?(6)
      assert !widget_ids.include?(7)
    end

    should "return widgets filtered on name not contains" do
      query = WidgetQuery.new :name => "_", 
        :filters => {'name' => {:operator => "!~", :values => ["pariatur"]}}
      widget_ids = query.query.collect(&:id)

      assert widget_ids.include?(1)
      assert widget_ids.include?(2)
      assert widget_ids.include?(3)
      assert widget_ids.include?(4)
      assert !widget_ids.include?(5)
      assert widget_ids.include?(6)
      assert widget_ids.include?(7)
    end
  end
end
