class TimeSheet < ActiveRecord::Base
  acts_as_paranoid
  
  belongs_to :user
  
  has_many :single_entries

  validates_presence_of :user
  
end
