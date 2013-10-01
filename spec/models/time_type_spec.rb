# == Schema Information
#
# Table name: time_types
#
#  id                       :integer          not null, primary key
#  name                     :string(255)
#  is_work                  :boolean          default(FALSE)
#  is_vacation              :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  deleted_at               :datetime
#  icon                     :string(255)
#  color_index              :integer          default(0)
#  exclude_from_calculation :boolean          default(FALSE)
#  bonus_calculator         :string(255)
#

require 'spec_helper'

describe TimeType do
  it 'has a valid factory' do
    FactoryGirl.create(:time_type).should be_valid
  end

  it 'returns the name as default string' do
    time_type = FactoryGirl.create(:time_type)
    time_type.to_s == time_type.name
  end

  it 'acts as paranoid' do
    time_type = FactoryGirl.create(:time_type)
    time_type.destroy
    expect { TimeType.find(time_type.id) }.to raise_error
    expect { TimeType.with_deleted.find(time_type.id) }.to_not raise_error
  end

  it 'has a unique name' do
    time_type = FactoryGirl.create(:time_type, name: 'Work')
    FactoryGirl.build(:time_type, name: 'Work').should_not be_valid
  end

  it 'has a valid bonus calculator' do
    FactoryGirl.build(:time_type, bonus_calculator: 'blubber').should_not be_valid
  end

  it 'allows a bonus calculator null' do
    FactoryGirl.build(:time_type, bonus_calculator: '').should be_valid
  end

  it 'updates the time spans if the bonus changes' do
    time_type = FactoryGirl.create(:time_type_work)
    time_entry = FactoryGirl.create(:time_entry, start_time: '00:45:00', end_time: '01:30:00')

    # TODO: remove fugly solution because of strange factory
    time_entry.time_type = time_type
    time_entry.save!

    UberZeit::BonusCalculators.register :nine_on_duty, UberZeit::BonusCalculators::NineOnDuty
    time_type.bonus_calculator = 'nine_on_duty'
    expect { time_type.save! }.to change { time_entry.time_spans.reload.collect(&:duration_bonus) }
  end
end
