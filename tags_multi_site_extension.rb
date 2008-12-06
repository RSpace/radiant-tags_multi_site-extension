# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class TagsMultiSiteExtension < Radiant::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/tags_multi_site"
  
  def activate
    MetaTag.send :include, TagsMultiSite::MetaTagExtensions
    Page.send :include, TagsMultiSite::PageExtensions
  end
  
  def deactivate
  end
  
end