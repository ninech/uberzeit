# == Schema Information
#
# Table name: customers
#
#  id           :integer          primary key
#  name         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  abbreviation :string(255)
#

class Customer < ActiveRecord::Base
  has_many :projects
  has_many :activities

  default_scope { order(:number) }

  attr_accessible :number, :name, :abbreviation

  validates_numericality_of :number
  validates_uniqueness_of :number, if: :number?
  validates_presence_of :name

  def display_name
    display_name_parts = [name]
    display_name_parts.prepend "#{number}:" unless number.nil?
    display_name_parts.append "- #{abbreviation}" unless abbreviation.blank? || abbreviation == name
    display_name_parts.join ' '
  end

  def to_s
    display_name
  end
end
