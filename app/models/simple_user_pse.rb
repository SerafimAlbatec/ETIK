class SimpleUserPse < ActiveRecord::Base
	belongs_to :paraggelia
	validates :cust_no, uniqueness: true
end
