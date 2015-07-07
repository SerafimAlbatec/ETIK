class SimpleUserPse < ActiveRecord::Base
	belongs_to :paraggelia
	validates :sungate_num, uniqueness: true

	def self.search(search, user_code, all)
	  if ( search && all = !all) 
	  	where("name LIKE ? OR eponimo LIKE ? AND dealer_num like ?", "%#{search}%", "%#{search}%", user_code)
	  else
	    where(:dealer_num => user_code)
	  end
	end
end
