# encoding: utf-8

require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/schema'

class QueryableQueryTest < ActiveSupport::TestCase
  fixtures :queryable_queries, :queryable_item_users, :queryable_item_categories, :queryable_items
  
  def setup
    @query = QueryableItemQuery.new :name => "_"
  end

  context "a query" do

    context "with no filters" do
      should "return all items" do
        assert_equal @query.items.map(&:id).sort, QueryableItem.all.map(&:id).sort
      end
    end

    context "counts" do
      should "match the results length" do
        assert_equal @query.items.size, @query.count
      end

      should "be a Hash keyed by group column value if grouped" do
        counts = {}
        @query.group_by = @query.groupable_columns.first
        @query.items.each do |item|
          v = item.send @query.group_by
          counts[v] = (counts[v] || 0) + 1
        end

        q_counts = @query.count_by_group
        assert @query.grouped?, "Query is grouped."
        assert_equal counts.keys.map { |k| k ? k.id : 0}.sort, q_counts.keys.map { |k| k ? k.id : 0 }.sort, "Count group keys must match"
        assert_equal counts.values.sort, q_counts.values.sort, "Count group values must match"

        @query.group_by = nil
        counts = Hash[[counts.reduce { |a,b| [nil, b[1] + a[1]] }]]
        assert !@query.grouped?, "Query is not grouped."
        assert_equal counts, @query.count_by_group
      end
    end

  end
end
