# encoding: utf-8

require 'active_record'
require 'active_record/errors'
require 'acts_as_queryable'

if Rails.version.to_i < 3
  require 'dispatcher'

  Dispatcher.to_prepare :acts_as_queryable do
    ActsAsQueryable::Patches::ActiveRecordBase.patch
    ActsAsQueryable::Patches::ApplicationController.patch
  end
else
  Rails.configuration.to_prepare do
    ActsAsQueryable::Patches::ActiveRecordBase.patch
    ActsAsQueryable::Patches::ApplicationController.patch
  end
end