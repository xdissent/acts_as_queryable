# encoding: utf-8

class QueryColumn
  attr_accessor :name, :sortable, :groupable, :default_order, :caption

  def initialize(name, options={})
    self.name = name
    self.sortable = options[:sortable]
    self.groupable = options[:groupable] || false
    if groupable == true
      self.groupable = name.to_s
    end
    self.default_order = options[:default_order]
    self.caption = options[:caption] || name.to_s.titleize
  end

  # Returns true if the column is sortable, otherwise false
  def sortable?
    !sortable.nil?
  end

  def value(issue)
    issue.send name
  end
end
