# encoding: utf-8

class CreateWidgets < ActiveRecord::Migration
  def self.up
    create_table :widgets, :force => true do |t|
      t.integer :project_id
      t.integer :user_id, :default => 0, :null => false
      t.string :name, :default => "", :null => false
      t.text :description
      t.timestamps
    end
    add_index :widgets, :project_id
    add_index :widgets, :user_id
  end

  def self.down
    remove_index :widgets, :project_id
    remove_index :widgets, :user_id
    drop_table :widgets
  end
end

class Widget < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :user

  acts_as_queryable :columns => [
      QueryColumn.new(:project, :sortable => "#{Project.table_name}.name", :groupable => true),
      QueryColumn.new(:user, :sortable => ["#{User.table_name}.lastname", "#{User.table_name}.firstname", "#{User.table_name}.id"], :groupable => true),
      QueryColumn.new(:name, :sortable => "#{table_name}.name"),
      QueryColumn.new(:description, :sortable => "#{table_name}.description"),
      QueryColumn.new(:created_at, :sortable => "#{table_name}.created_at", :default_order => 'desc'),
      QueryColumn.new(:updated_at, :sortable => "#{table_name}.updated_on", :default_order => 'desc')
    ], :filters => {
      "name" => { :type => :text, :order => 1 },
      "description" => { :type => :text, :order => 2 },
      "created_at" => { :type => :date_past, :order => 3 },
      "updated_at" => { :type => :date_past, :order => 4 }
    }
end

CreateWidgets.up