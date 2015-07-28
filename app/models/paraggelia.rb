class Paraggelia < ActiveRecord::Base
	has_many :simple_user_pse

	def self.search(search, current_user_id, all)
	  if ( search && all = !all) 
	  	where("(eponimo LIKE ? OR name LIKE ?) AND user like ? AND done like ?", "%#{search}%", "%#{search}%", current_user_id, 0).order("updated_at").reverse
	  else
	    where(:user => current_user_id, :done => 0).order("updated_at").reverse
	  end
	end

	def self.search_admin(search, all)
	  if ( search && all = !all) 
	  	where("eponimo LIKE ? AND done like ?", "%#{search}%",  0)
	  else
	    where(:done => 0)
	  end
	end
end
