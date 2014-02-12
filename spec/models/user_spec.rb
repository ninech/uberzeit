# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  email                :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  deleted_at           :datetime
#  given_name           :string(255)
#  birthday             :date
#  authentication_token :string(255)
#

require 'spec_helper'

describe User do

  let(:user) { FactoryGirl.create(:user) }

  it 'has a valid factory' do
    FactoryGirl.build(:user).should be_valid
  end

  it 'acts as paranoid' do
    user.destroy
    expect { User.find(user.id) }.to raise_error
    expect { User.with_deleted.find(user.id) }.to_not raise_error
  end

  it 'ensures that at least one employment exists' do
    user = FactoryGirl.create(:user, with_employment: false)
    2.times { user.ensure_employment_exists }
    user.employments.count.should eq(1)
  end

  describe '#time_sheet' do
    it 'returns an instance of TimeSheet' do
      user.time_sheet.should be_instance_of(TimeSheet)
    end
  end

  describe '#current_employment' do
    it 'returns the current active employment' do
      user.current_employment.should eq(user.employments.first)
    end
  end

  describe '.in_teams' do
    it 'returns all the users which belong to the specified team' do
      user2 = FactoryGirl.create(:user)
      User.in_teams(user.teams).should eq([user])
    end

    it 'returns all the users which belong to the specified teams' do
      user = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      User.in_teams(Team.all).count.should eq([user, user2].count)
    end
  end

  describe '::only_active' do
    it 'returns only the active users' do
      user2 = FactoryGirl.create(:user, active: false)
      User.only_active.should_not include(user2)
    end
  end

  describe 'validation' do
    let(:user) { FactoryGirl.build(:user) }

    it 'allows valid users' do
      user.should be_valid
    end

    it 'ensures the email address is unique' do
      user.save!
      other_user = FactoryGirl.build :user
      other_user.email = user.email
      other_user.should_not be_valid
    end

    it 'ensures the email address is valid' do
      other_user = FactoryGirl.build :user
      other_user.email = 'gooby@shemail'
      other_user.should_not be_valid
    end

    it 'requires a non-empty given_name' do
      user.given_name = ''
      user.should_not be_valid
    end

    it 'requires a non-empty name' do
      user.name = ''
      user.should_not be_valid
    end

    it 'requries a non-empty password' do
      user.password = user.password_confirmation = nil
      user.should_not be_valid
    end

    context 'with an auth source set' do
      let(:user) { User.new email: 'example@test.com', auth_source: 'ldap', given_name: 'Jebus', name: 'Christus' }

      it 'does not require a password' do
        user.password = user.password_confirmation = nil
        user.should be_valid
      end
    end
  end

end
