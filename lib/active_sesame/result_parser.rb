module ActiveSesame
  module ResultParser
    require 'rexml/document'
    #def ResultParser.append_features(someClass)
      def self.tableize(xml_document)
        xml_document = REXML::Document.new(xml_document) if xml_document.class == String
        #keys = []
	rows = []
        #xml_document.elements.each("/sparql/head/variable") do |variable|
        #  keys << variable.attributes["name"]
	#end
	xml_document.elements.each("/sparql/results/result") do |result|
          hash = {}
	  result.elements.each("binding") do |binding|
	    if binding.elements["uri"]
	      hash[binding.attributes["name"]] = binding.elements["uri"].text
	    elsif binding.elements["literal"]
	      hash[binding.attributes["name"]] = type_cast_literal(binding.elements["literal"])
	    end
	  end
	  #puts hash.inspect
	  rows << hash
	end
	return rows
      end

      def self.singular_values(xml_document)
        xml_document = REXML::Document.new(xml_document) if xml_document.class == String
        values = []
	xml_document.elements.each("/sparql/results/result/binding") do |binding|
	  values << binding.elements["uri"].text if binding.elements["uri"]
	  values << binding.elements["literal"].text if binding.elements["literal"]
	end
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

      def self.type_cast_literal(literal_element)
	#puts literal_element.attributes["datatype"] #Use when Exception thrown "nil is not a Symbol"
	return literal_element.text.send(RDFConstants.literal_to_proc_hash[literal_element.attributes["datatype"]]) if literal_element.attributes["datatype"]
	return literal_element.text
      end
    #end
  end
end
