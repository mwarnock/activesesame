module ActiveSesame
  module ResultParser
    require 'libxml'
    #def ResultParser.append_features(someClass)
    def self.tableize(xml_document)
      xml_document = self.to_document(xml_document)
      rows = []
      xml_document.find("/sparql/results/result").each do |result|
        hash = {}
        result.each_element do |binding|
          key = binding.attributes.to_h["name"]
          hash[key] = value_from_binding(binding)
        end
        rows << hash
      end
      return rows
    end

      def self.singular_values(xml_document)
        xml_document = self.to_document(xml_document)
        values = []
	xml_document.find("/sparql/results/result/binding").each {|binding| values << self.value_from_binding(binding) }
	return values
      end

      def self.hash_values(xml_document)
        xml_document = REXML::Document.new(xml_document) if xml_document.class == String
        keys = []
        xml_document.elements.each("/sparql/head/variable") do |variable|
          keys << variable.attributes["name"]
	end
        xml_document = REXML::Document.new(xml_document) if xml_document.class == String
        hash = {}
	xml_document.elements.each("/sparql/results/result") do |result|
	  hash[result.elements["binding[@name='#{keys[0]}']/uri|literal"].text] = result.elements["binding[@name='#{keys[1]}']/uri|literal"].text
	end
	return hash
      end

      def self.value_from_binding(binding)
        literal = binding.find_first("literal")
        uri = binding.find_first("uri")
        if uri
          uri.content
        elsif literal
          type_cast_literal(literal)
        end
      end

      def self.type_cast_literal(literal_element)
	#puts literal_element.attributes["datatype"] #Use when Exception thrown "nil is not a Symbol"
	return literal_element.content.send(RDFConstants.literal_to_proc_hash[literal_element.attributes.to_h["datatype"]]) if literal_element.attributes.to_h["datatype"]
	return literal_element.text
      end
    #end

      private
      def self.to_document(string_or_doc)
        if string_or_doc.class == String
          string_or_doc.sub!("xmlns=\"http://www.w3.org/2005/sparql-results#\"","")
          LibXML::XML::Document.string(string_or_doc)
        else
          string_or_doc
        end
      end
  end
end
