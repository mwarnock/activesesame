require 'active_support'
require 'active_sesame'
class Study < ActiveSesame::Base
end

@study_hash = {}
Study.simple_method_names.each {|key| @study_hash[key] = "" }
@study_hash[:patientSex] = "M"
@study_hash[:procedureCode] = "A CT of the Head"
@study_hash[:aquiringModality] = "CT"
@study_hash[:patientAge] = "015Y"
@study_hash[:patientHistory] = "Cronic Headaches"
@study_hash[:accessionNumber] = "0523432"
@study_hash[:studyDateTime] = "2007-08-11 13:02"
@study_hash[:bodyPartExamined] = "Head"
@study_hash[:patientID] = "101"
@study_hash[:reasonFor] = "Cronic Headaches"
@study_hash[:submittedBy] = "mwarnock"
@study_hash[:patientName] = "John Doe"
@study_hash[:uid] = "1.2.34.53534.32342342.9885"
@study_hash[:instance] = Study.base_uri_location + @study_hash[:uid].gsub(".","_")
@study = Study.new(@study_hash)
@study.save

puts Study.find(:all).inspect
