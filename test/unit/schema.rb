# encoding: utf-8

class CreateQueryItems < ActiveRecord::Migration
  def self.up
    create_table :query_items, :force => true do |t|
      t.integer :category_id
      t.integer :user_id, :null => false
      t.string :name
      t.text :description
      t.integer :quantity
      t.boolean :approved, :default => false
      t.datetime :due
      t.timestamps
    end
  end

  def self.down
    drop_table :query_items
  end
end.up

class CreateQueryItemCategories < ActiveRecord::Migration
  def self.up
    create_table :query_item_categories, :force => true do |t|
      t.string :name
      t.text :description
      t.integer :category_count, :default => 0
    end
  end

  def self.down
    drop_table :query_item_categories
  end
end.up

class CreateQueryItemUsers < ActiveRecord::Migration
  def self.up
    create_table :query_item_users, :force => true do |t|
      t.string :first_name
      t.string :last_name
      t.boolean :active, :default => true
    end
  end

  def self.down
    drop_table :query_item_users
  end
end.up

class QueryItemCategory < ActiveRecord::Base
  has_many :items, :class_name => "QueryItem"
end

class QueryItemUser < ActiveRecord::Base
  has_many :items, :class_name => "QueryItem"
end

class QueryItem < ActiveRecord::Base
  belongs_to :category, :class_name => "QueryItemCategory", :counter_cache => true
  belongs_to :user, :class_name => "QueryItemUser"

  validates_presence_of :user

  acts_as_queryable :columns => {
    :category => {:sortable => "#{QueryItemCategory.table_name}.category_count", :groupable => true, :default_order => 'desc'}
    :user => {:sortable => ["#{QueryItemUser.table_name}.last_name", "#{QueryItemUser.table_name}.first_name", "#{QueryItemUser.table_name}.id"]},
    :description => {},
    :quantity => {:sortable => true, :default_order => 'desc', :label => "#"},
    :approved => {:groupable => true},
    :due => {:sortable => true},
    :created_at => {:sortable => true, :default_order => 'desc'},
    :updated_at => {:sortable => true, :default_order => 'desc'}
  }, :filters => {
    :category_id => {:type => :list_optional, :order => 1, :choices => lambda { |q| QueryItemCategory.all }, :if => lambda { |q| QueryItemCategory.all.present? }},
    :user_id => {:type => :list, :order => 2, :choices => lambda { |q| QueryItemUser.all }},
    :description => {:type => :text, :order => 3},
    :quantity => {:type => :integer, :order => 4, :label => "Number Available"}
    :approved => {:type => :boolean, :order => 5},
    :due => {:type => :date, :order => 6},
    :created_at => {:type => :date_past, :order => 7},
    :updated_at => {:type => :date_past, :order => 8}
  }
end