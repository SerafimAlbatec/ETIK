class PseUser < ActiveRecord::Base
	#validates_length_of :phone, :minimum => 10, :maximum => 10
	validates_presence_of :name, :eponimo, :address, :company, :email 
end
