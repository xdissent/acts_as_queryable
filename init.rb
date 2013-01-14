# encoding: utf-8

require 'dispatcher'
require 'acts_as_queryable'

Dispatcher.to_prepare :acts_as_queryable do
  ActsAsQueryable::Patches::ActiveRecordBase.patch
  ActsAsQueryable::Patches::ApplicationController.patch
end