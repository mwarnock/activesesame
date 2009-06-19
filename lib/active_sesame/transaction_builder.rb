module ActiveSesame
  module TransactionBuilder
    require 'rexml/document'

    def self.object_to_triples(object)
      base_class = object.class.base_uri_location.gsub(/<|>/,"") + object.class.rdf_class
      full_transaction = self.build_triple(object.instance, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", base_class)
      object.class.simple_attributes.keys.inject(full_transaction) do |transaction,attribute|
        transaction += self.build_triple(object.instance, attribute, object.send(Support.uri_to_sym(attribute)))
      end
    end

    def self.build_triples(list_of_triples, trans_type='add')
      xml_for_transation = list_of_triples.inject("<#{trans_type}>") do |xml, triple|
        triple_hash = triple.to_h
        xml += type_cast(triple_hash[:subject]) + type_cast(triple_hash[:predicate]) + type_cast(triple_hash[:object])
        xml
      end
      xml_for_transation += "</#{trans_type}>"
    end

    def self.type_cast(uri_or_literal)
      if uri_or_literal =~ /http:\/\//
        "<uri>&lt;#{uri_or_literal}&gt;</uri>"
      else
        #xml += "\t\t<literal datatype=\"&lt;#{RDFConstants.class_to_literal[uri_or_literal.class]}&gt;\">#{uri_or_literal}</literal>\n"
        "<literal>#{uri_or_literal}</literal>"
      end
    end

  end
end
