# encoding: utf-8

module ActsAsQueryable
  module Patches
    module Base
      def target
        raise NotImplementedError
      end

      def patched?
        target.included_modules.include? self
      end

      def patch
        patch! unless patched?
      end

      def patch!
        target.send :include, self
      end

      def included(base)
        base.send :extend, self::ClassMethods if self.const_defined? "ClassMethods"
        base.send :include, self::InstanceMethods if self.const_defined? "InstanceMethods"
      end
    end
  end
end