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

    def self.build_triple(s,p,o, trans_type='add')
      xml = "<#{trans_type}>"
      [s,p,o].each do |uri_or_literal|
        if uri_or_literal =~ /http:\/\//
	  xml += "<uri>&lt;#{uri_or_literal}&gt;</uri>"
	else
	  #xml += "\t\t<literal datatype=\"&lt;#{RDFConstants.class_to_literal[uri_or_literal.class]}&gt;\">#{uri_or_literal}</literal>\n"
	  xml += "<literal>#{uri_or_literal}</literal>"
	end
      end
      xml += "</#{trans_type}>"
    end

  end
end
