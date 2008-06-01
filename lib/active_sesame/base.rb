module ActiveSesame
  class Base
    include SesameRepository
    ActiveSesame::MonkeyPatches #Run The monkey Patches
  
    def Base.inherited(subClass)
      ############################################
      #######  Generic Attribute Handling ########
      ############################################

      #Create class variables that are independant of the super class
      class << self
        attr_accessor :rdf_class, :triple_store_id, :base_uri, :unique_property, :unique_property_type, :attributes, :attribute_method_names
        attr_accessor :simple_attributes, :simple_method_names
        attr_accessor :complex_attributes, :complex_method_names
      end

      #Set the Default values for the inheritable class accessors
      subClass.rdf_class = subClass.name.split("::").last.to_s
      subClass.triple_store_id = "study-stash"
      subClass.set_base_uri "http://study-stash.radiology.umm.edu/ontologies/study-stash.owl#"
      subClass.unique_property = subClass.name
      subClass.unique_property_type = RDFConstants.class_to_match_hash[String]
      subClass.attributes = {}
      subClass.attribute_method_names = []
      subClass.simple_attributes = {}
      subClass.simple_method_names = []
      subClass.complex_attributes = {}
      subClass.complex_method_names = []

      #Create the attribute accessors for instances
      attr_accessor :attribute_table, :instance, :transaction_triples

      def subClass.base_uri_location
        uri_with_quacks = self.base_uri.split(" ").last
	uri_with_quacks.slice(1,uri_with_quacks.length-2)
      end

      def subClass.set_rdf_class(new_class_name)
        self.rdf_class = new_class_name.to_s
	self.set_attributes
      end

      def subClass.set_triple_store_id(new_id)
        self.triple_store_id = new_id.to_s
	self.set_attributes
      end

      def subClass.set_unique_property(new_property_name, type)
        self.unique_property = new_property_name.to_s
	self.unique_property_type = RDFConstants.class_to_match_hash[type]
      end

      def subClass.set_attributes
        #puts "SELECT ?property_name ?property_type WHERE { ?property_name rdfs:domain <#{rdf_class}>; rdfs:range ?property_type }"
        self.attributes = ResultParser.hash_values(self.find_by_sparql("SELECT ?property_name ?property_type WHERE { ?property_name rdfs:domain <#{rdf_class}>; rdfs:range ?property_type }"))
	self.attributes.each do |uri,type|
	  if RDFConstants.literals.include?(type) 
	    self.simple_attributes[uri] = type
	    self.simple_method_names << Support.uri_to_sym(uri)
	  else
	    self.complex_attributes[uri] = type
	    self.complex_method_names << Support.uri_to_sym(uri).to_s.pluralize
	  end
	end
        self.generate_methods
	self.attributes
      end
      
      def subClass.set_attribute_method_names
        self.attribute_method_names = self.attributes.keys.collect {|key| Support.uri_to_sym(key) }
      end

      ####################################
      ######## Validation Tools  #########
      ####################################

      def subClass.validate(instance)
        self.find(instance.instance) ? false : true
      end

      ###########################################
      ######## Dynamic Method Generation ########
      ###########################################

      #creates accessor methods and initiates other method Generators
      def subClass.generate_methods
	attr_accessor *(self.simple_method_names) unless self.simple_method_names.empty?
	self.generate_find_methods
	self.generate_complex_methods
      end

      #Generates methods for selecting all the uri (complex) properties associated with a specific instance
      def subClass.generate_complex_methods
        self.complex_attributes.each do |uri,type|
          method = Support.uri_to_sym(uri)
	  define_method(method.to_s.pluralize) do
	    if Kernel.const_get(Support.uri_to_sym(type))
	      ResultParser.singular_values(self.class.find_by_sparql("SELECT ?object WHERE { <#{self.instance}> <#{uri}> ?object }")).collect {|foreign_uri| Kernel.const_get(Support.uri_to_sym(type)).find(foreign_uri) }
	    else
	      "No Class Defined for: #{Support.uri_to_sym(type)}"
	    end
	  end
	  define_method("add_" + method.to_s.pluralize) do |instance_or_object|
	    instance_or_object.class == String ? instance = instance_or_object : instance = instance_or_object.instance
	    if Kernel.const_get(Support.uri_to_sym(type))
              self.class.group_save(ActiveSesame::TransactionBuilder.build_triple(self.instance, uri, instance))
	    end
	  end
	  attr_accessor (method.to_s.pluralize + "_for_" + self.name.downcase).to_sym
	end
      end

      #Generates all the find_by_property methods for the inherited class
      def subClass.generate_find_methods
        self.simple_method_names.each do |m|
          self.class_eval(
	    "def self.find_by_#{m} (value)
	       #puts \"SELECT \#{self.attributes_to_sparql_vars} WHERE { ?instance <#{m}> '\#{value}'^^\#{ActiveSesame::RDFConstants.class_to_match_hash[value.class]} . \#{self.attributes_to_sparql_patterns}}\"
               self.new(ResultParser.tableize(self.find_by_sparql(\"SELECT \#{self.attributes_to_sparql_vars} WHERE { ?instance <#{m}> '\#{value}' . \#{self.attributes_to_sparql_patterns}}\")).first)
               #puts self.find_by_sparql(\"SELECT \#{self.attributes_to_sparql_vars} WHERE { ?instance <#{m}> '\#{value}'^^\#{ActiveSesame::RDFConstants.class_to_match_hash[value.class]} . \#{self.attributes_to_sparql_patterns}}\")
	     end") #When you fix the datatype attributes in allegro graph you need to change this function or you'll get nils
	end
      end


      ######################################
      ######## SPARQL Query Helpers ########
      ######################################

      #Converts the simple method names list into a series of sparql patterns for the WHERE clause
      def subClass.attributes_to_sparql_patterns
        self.simple_method_names.inject("") {|outstring,item| outstring += "?instance <#{item}> ?#{item}. "}
      end

      #Converts the simple method names list into a string of SPARQL variables
      def subClass.attributes_to_sparql_vars
        "?instance ?" + self.simple_method_names.join(" ?")
      end


      ######################################
      ######### SPARQL Find Methods ########
      ######################################

      #Does a SPARQL select based on simple options and instantiates the Class Instances From the Returning XML
      def subClass.find(unique_uri_or_length, args={})
        if unique_uri_or_length.class != Symbol
	  begin
            puts "SELECT #{self.attributes_to_sparql_vars.gsub("?instance","")} WHERE { #{self.attributes_to_sparql_patterns.gsub("?instance",'<' + unique_uri_or_length + '>')}}"
            graph_object = self.new(ResultParser.tableize(self.find_by_sparql("SELECT #{self.attributes_to_sparql_vars.gsub("?instance","")} WHERE { #{self.attributes_to_sparql_patterns.gsub("?instance",'<' + unique_uri_or_length + '>')}}")).first)
	    graph_object.instance = unique_uri_or_length
	    return graph_object
	  rescue
	    return nil
	  end
	elsif args.has_key?(:sparql) #Submit Pure Sparql without Object Creation (Returns Hash)
	  (ResultParser.tableize(self.find_by_sparql(:sparql)))
	elsif args.has_key?(:simple_conditional) #Returns objects that match the simple_condition, if specified, and apply the length operator via the send method
	  (ResultParser.tableize(self.find_by_sparql("SELECT #{self.attributes_to_sparql_vars} WHERE {?instance rdf:type <#{self.rdf_class}> . #{args[:simple_conditional]} OPTIONAL {#{self.attributes_to_sparql_patterns}} . }")).collect {|table| self.new(table)}).send(unique_uri_or_length)
	else
	  (ResultParser.tableize(self.find_by_sparql("SELECT #{self.attributes_to_sparql_vars} WHERE {?instance rdf:type <#{self.rdf_class}> . OPTIONAL {#{self.attributes_to_sparql_patterns}} . }")).collect {|table| self.new(table)}).send(unique_uri_or_length)
	end
      end

      def subClass.uniques(args={})
        uniques = []
	generals = self.find(:all, args)
        generals.each {|g| uniques << g unless uniques.find {|u| u.instance == g.instance}}
	uniques
      end

      #########################################
      ########## Class Admin Methods ##########
      #########################################


      #########################################
      ######## Class Initializer Calls ########
      #########################################
      subClass.set_attributes
      subClass.set_attribute_method_names
    end
    
    #Class methods for ActiveSesame::Base
    #These will not be inherited by sub classes
    class << self
    end

    ######################################
    ########## Instance Methods ##########
    ######################################
    
    def initialize(attributes_table={})
      @attribute_table = attributes_table
      @attribute_table.each {|key,value| self.send(key.to_s + "=", ActiveSesame::Support.uncode_whitespace(value)) }
    end
    
    def add_transaction_triple(s,p,o)
      self.transaction_triples = self.transaction_triples + ActiveSesame::TransactionBuilder.build_triple(s,p,o)
    end

    def save
      if self.class.validate(self)
        self.build_triples
        self.before_save
        self.class.group_save(self.transaction_triples)
	self.after_save
	return true
      else
        self.after_save
        return false
      end
    end

    def build_triples
      self.transaction_triples = ActiveSesame::TransactionBuilder.object_to_triples(self)
    end

    def before_save
    end

    def after_save
      self.class.complex_method_names.each do |method|
        values = self.send(method.to_s.pluralize + "_for_" + self.class.rdf_class.downcase)
	values.to_a
        if self.send(method.to_s.pluralize + "_for_" + self.class.rdf_class.downcase)
	  values.each {|value| self.send("add_" + method.to_s.pluralize, value)}
	end
      end
    end


  end

end


