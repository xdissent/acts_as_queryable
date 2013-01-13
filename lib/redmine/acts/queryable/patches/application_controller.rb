# encoding: utf-8

module Redmine::Acts::Queryable
  module Patches
    module ApplicationController
      extend Base

      def self.target
        ::ApplicationController
      end

      module ClassMethods
        def query_class(klass)
          write_inheritable_attribute('query_class', klass)
        end
      end
    end
  end
end