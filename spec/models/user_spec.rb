# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  uid                  :string(255)
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

  describe '#create_with_omniauth' do
    context 'without extra attributes' do

      let(:omniauth_hash) { {'uid' => 'user-one'} }

      it 'can be created' do
        User.create_with_omniauth(omniauth_hash).should be_persisted
      end
    end
    context 'with extra attributes' do

      let(:omniauth_hash) { {'uid' => 'user-one', 'info' => {'name' => 'Super User'}} }

      subject { User.create_with_omniauth(omniauth_hash) }

      it { should be_persisted }
      its(:name) { should eq('Super User') }

    end
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

end
