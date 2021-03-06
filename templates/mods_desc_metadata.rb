class ModsDescMetadata < ActiveFedora::NokogiriDatastream
  # MODS XML constants.

  MODS_NS = 'http://www.loc.gov/mods/v3'
  MODS_SCHEMA = 'http://www.loc.gov/standards/mods/v3/mods-3-3.xsd'
  MODS_PARAMS = {
    "version"            => "3.3",
    "xmlns:xlink"        => "http://www.w3.org/1999/xlink",
    "xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
    "xmlns"              => MODS_NS,
    "xsi:schemaLocation" => "#{MODS_NS} #{MODS_SCHEMA}",
  }

  # OM terminology.

  set_terminology do |t|
    t.root :path => 'mods', :xmlns => MODS_NS
    t.originInfo  do
      t.dateOther
    end
    t.abstract
    t.titleInfo  do
      t.title
    end

    t.title :ref => [:mods, :titleInfo, :title]
    t.name  do
      t.namePart
      t.role  do
        t.roleTerm
      end
    end

    t.relatedItem  do
      t.titleInfo  do
        t.title
      end
      t.location  do
        t.url
      end
    end

    t.subject  do
      t.topic
    end

    t.preferred_citation :path => 'note',  :attributes => { :type => "preferred citation" }
    t.related_citation :path => 'note',  :attributes => { :type => "citation/reference" }

  end

  # Blocks to pass into Nokogiri::XML::Builder.new()

  define_template :name do |xml|
      xml.name {
        xml.namePart
        xml.role {
          xml.roleTerm(:authority => "marcrelator", :type => "text")
        }
      }
  end

  define_template :relatedItem do |xml|
      xml.relatedItem {
        xml.titleInfo {
          xml.title
        }
        xml.location {
          xml.url
        }
      }
  end

  define_template :related_citation do |xml|
    xml.note(:type => "citation/reference")
  end

  def self.xml_template
    Nokogiri::XML::Builder.new do |xml|
      xml.mods(MODS_PARAMS) {
        xml.originInfo {
          xml.dateOther
        }
        xml.abstract
        xml.titleInfo {
          xml.title
        }
        xml.name {
          xml.namePart
          xml.role {
            xml.roleTerm
          }
        }
        xml.relatedItem {
          xml.titleInfo {
            xml.title
          }
          xml.location {
            xml.url
          }
        }
        xml.subject {
          xml.topic
        }
        xml.note(:type => "preferred citation")
        xml.note(:type => "citation/reference")
      }
    end.doc
  end

  def insert_person
    insert_new_node(:name)
  end

  def insert_related_item
    insert_new_node(:relatedItem)
  end

  def insert_related_citation
    insert_new_node(:related_citation)
  end

  def insert_new_node(term)
    add_child_node(ng_xml.root, term)
  end

  def remove_node(term, index)
    node = self.find_by_terms(term.to_sym => index.to_i).first
    unless node.nil?
      node.remove
      self.dirty = true
    end
  end

end
