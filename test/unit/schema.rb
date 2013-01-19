# encoding: utf-8

class CreateQueryableItems < ActiveRecord::Migration
  def self.up
    create_table :queryable_items, :force => true do |t|
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
    drop_table :queryable_items
  end
end

class CreateQueryableItemCategories < ActiveRecord::Migration
  def self.up
    create_table :queryable_item_categories, :force => true do |t|
      t.string :name
      t.integer :item_count, :default => 0
    end
  end

  def self.down
    drop_table :queryable_item_categories
  end
end

class CreateQueryableItemUsers < ActiveRecord::Migration
  def self.up
    create_table :queryable_item_users, :force => true do |t|
      t.string :first_name
      t.string :last_name
      t.boolean :active, :default => true
    end
  end

  def self.down
    drop_table :queryable_item_users
  end
end

class QueryableItemCategory < ActiveRecord::Base
  has_many :items, :class_name => "QueryableItem"
end

class QueryableItemUser < ActiveRecord::Base
  has_many :items, :class_name => "QueryableItem"
end

class QueryableItem < ActiveRecord::Base
  belongs_to :category, :class_name => "QueryableItemCategory", :counter_cache => :item_count
  belongs_to :user, :class_name => "QueryableItemUser"

  validates_presence_of :user

  acts_as_queryable :columns => {
    :category => {:sortable => "#{QueryableItemCategory.table_name}.item_count", :groupable => true, :default_order => 'desc'},
    :user => {:sortable => ["#{QueryableItemUser.table_name}.last_name", "#{QueryableItemUser.table_name}.first_name", "#{QueryableItemUser.table_name}.id"]},
    :description => {},
    :quantity => {:sortable => true, :default_order => 'desc', :label => "#"},
    :approved => {:groupable => true},
    :due => {:sortable => true},
    :created_at => {:sortable => true, :default_order => 'desc'},
    :updated_at => {:sortable => true, :default_order => 'desc'}
  }, :filters => {
    :category_id => {:type => :list_optional, :order => 1, :choices => lambda { |q| QueryableItemCategory.all.map(&:id).map(&:to_s) }, :if => lambda { |q| QueryableItemCategory.all.present? }},
    :user_id => {:type => :list, :order => 2, :choices => lambda { |q| QueryableItemUser.all.map(&:id).map(&:to_s) }},
    :description => {:type => :text, :order => 3},
    :quantity => {:type => :integer, :order => 4, :label => "Number Available"},
    :approved => {:type => :boolean, :order => 5},
    :due => {:type => :date, :order => 6},
    :created_at => {:type => :date_past, :order => 7},
    :updated_at => {:type => :date_past, :order => 8}
  }
end

CreateQueryableItems.up
CreateQueryableItemCategories.up
CreateQueryableItemUsers.up
