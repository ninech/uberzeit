# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :datetime
#

class Project < ActiveRecord::Base
  include CustomerAssignable

  acts_as_paranoid

  attr_accessible :name

  validates_presence_of :name

  default_scope order(:name)
end
