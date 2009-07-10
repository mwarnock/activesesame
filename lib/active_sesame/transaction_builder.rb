module ActiveSesame::TransactionBuilder

  def self.object_to_triples(object)
    base_class = object.class.base_uri_location.gsub(/<|>/,"") + object.class.rdf_class
    full_transaction = self.build_triple(object.instance, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", base_class)
    object.class.simple_attributes.keys.inject(full_transaction) do |transaction,attribute|
      transaction += self.build_triple(object.instance, attribute, object.send(Support.uri_to_sym(attribute)))
    end
  end

  def self.build_triples(list_of_triples, trans_type='add')
    xml_for_transation = list_of_triples.inject("<transaction>") do |xml, triple|
      xml += "<#{trans_type}>" + type_cast(triple[:subject]) + type_cast(triple[:predicate]) + type_cast(triple[:object]) + "</#{trans_type}>"
      xml
    end
    xml_for_transation += "</transaction>"
  end

  def self.type_cast(uri_or_literal)
    if uri_or_literal =~ /http:\/\//
      "<uri>#{uri_or_literal}</uri>"
    else
      "<literal datatype=\"#{ActiveSesame::RDFConstants.class_to_literal[uri_or_literal.class]}\">#{uri_or_literal}</literal>"
    end
  end

end

