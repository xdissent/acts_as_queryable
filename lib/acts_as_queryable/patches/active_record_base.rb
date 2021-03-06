# encoding: utf-8

module ActsAsQueryable::Patches
  module ActiveRecordBase
    extend Base

    def self.target
      ::ActiveRecord::Base
    end

    def self.included(base)
      base.extend ::ActsAsQueryable
    end
  end
end