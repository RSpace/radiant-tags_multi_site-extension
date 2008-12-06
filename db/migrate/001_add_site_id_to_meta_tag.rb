class AddSiteIdToMetaTag < ActiveRecord::Migration
  def self.up
    raise 'You must have both the tag extension and the multi site extension installed to use this extension' unless defined? MetaTag && defined? Site
    raise 'You must create at least one site to assign existing tags to, before running this migration' if MetaTag.count > 0 && Site.count == 0

    add_column :meta_tags, :site_id, :integer
    remove_index :meta_tags, :name
    add_index :meta_tags, [:name, :site_id], :unique => true
    
    MetaTag.update_all("site_id = #{Site.find(:first).id}") if MetaTag.count > 0
  end
  
  def self.down
    remove_column :meta_tags, :site_id
    remove_index :meta_tags, [:name, :site_id]
    add_index :meta_tags, :name, :unique => true
  end
end
