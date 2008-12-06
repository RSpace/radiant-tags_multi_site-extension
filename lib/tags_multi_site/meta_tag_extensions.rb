module TagsMultiSite
  module MetaTagExtensions
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval {
        class << self
          alias_method_chain :cloud, :multisite
        end

        # HACK: Remove the existing validates_uniqueness_of block
        read_inheritable_attribute(:validate).reject! do |proc|
          if proc.is_a?(Proc)
            method = eval("caller[0] =~ /`([^']*)'/ and $1", proc.binding).to_sym rescue nil # Returns the name of method the proc was declared in
            :validates_uniqueness_of == method
          else
            false
          end
        end

        # Add new validates_uniqueness_of with correct scope
        validates_uniqueness_of :name, :case_sensitive => false, :scope => :site_id
      }
    end
    
    module ClassMethods
      def cloud_with_multisite(args = {})
        if args[:conditions]
          args[:conditions][0] += ' and site_id = ?'
        else
          args[:conditions] = ['site_id = ?']
        end
        args[:conditions] << Page.current_site.id
        
        cloud_without_multisite(args)
      end
    end
    
  end
end