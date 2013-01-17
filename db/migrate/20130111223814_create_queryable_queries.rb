# encoding: utf-8

class CreateQueryableQueries < ActiveRecord::Migration
  def self.up
    create_table :queryable_queries do |t|
      t.string :name, :default => "", :null => false
      t.text :filters
      t.text :columns
      t.text :sort_criteria
      t.string :group_by
      t.string :type
    end
  end

  def self.down
    drop_table :queryable_queries
  end
end
