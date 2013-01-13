# encoding: utf-8

module Redmine::Acts::Queryable
  module Patches
    module ActiveRecordBase
      extend Base

      def self.target
        ::ActiveRecord::Base
      end

      def self.included(base)
        base.extend ::Redmine::Acts::Queryable
      end
    end
  end
end