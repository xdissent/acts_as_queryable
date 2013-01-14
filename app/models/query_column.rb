#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

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
