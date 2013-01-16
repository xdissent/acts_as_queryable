# encoding: utf-8

module ActsAsQueryable::Patches
  module ApplicationController
    extend Base

    def self.target
      ::ApplicationController
    end

    module ClassMethods
      def queryable(klass=nil, filter_options={})
        klass ||= name.sub("Controller", "").singularize.constantize
        return unless klass.queryable?
        write_inheritable_attribute :queryable, klass
        include ::QueryableHelper
        helper :queryable
        before_filter :find_query, filter_options
      end
    end
  end
end