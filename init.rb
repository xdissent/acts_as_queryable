# encoding: utf-8

require 'dispatcher'
require 'redmine'
require 'acts_as_queryable'

Redmine::Plugin.register :acts_as_queryable do
  name 'Acts As Queryable plugin'
  author 'Greg Thornton'
  description 'Abstracts the Chiliproject query interface'
  version '0.0.1'
  url 'http://xdissent.com'
  author_url 'http://xdissent.com'

  Dispatcher.to_prepare :acts_as_queryable do
    Redmine::Acts::Queryable::Patches::ActiveRecordBase.patch
  end
end