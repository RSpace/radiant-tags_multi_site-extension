module TagsMultiSite
  module PageExtensions
    def self.included(base)
      base.class_eval {
        include(InstanceMethods)
        alias_method_chain :meta_tags=, :multi_site
      }
    end
    
    module InstanceMethods
      # Traverse the tree until the homepage is found, then look it up
      def homepage_site
        root = self
        while root.parent_id != nil
          root = root.parent
        end
        Site.find_by_homepage_id(root.id)
      end

      # Override the tag_with method to be able to set the right site
      def meta_tags_with_multi_site=(tags)
        self.save if self.new_record?
        # just skip the whole method if the tags string hasn't changed
        return if tags == tag_list

        # Find site
        site_id = self.homepage_site.id

        # do we need to delete any tags?
        tags_to_delete = tag_list.split(MetaTag::DELIMITER) - tags.split(MetaTag::DELIMITER)
        tags_to_delete.select{|t| meta_tags.delete(MetaTag.find_by_name_and_site_id(t, site_id))}

        tags.split(MetaTag::DELIMITER).each do |tag|
          begin
            MetaTag.find_or_create_by_name_and_site_id(tag.strip.squeeze(" "), site_id).taggables << self
          rescue ActiveRecord::StatementInvalid => e
            # With SQLite3 - a duplicate tagging will result in the following message:
            # SQLite3::SQLException: SQL logic error or missing database: INSERT INTO taggings ("meta_tag_id", "taggable_type", "taggable_id") VALUES(11, 'Page', 74)
            # raise unless e.to_s =~ /duplicate/i
          end
        end
      end
    end
    
  end
end