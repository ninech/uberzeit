require 'spec_helper'
require 'cancan/matchers'

describe Ability do

  let(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:admin) }

  subject { ability }

  describe 'User' do
    context 'as the user itself' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, user) }
      it { should be_able_to(:update, user) }

      it { should_not be_able_to(:create, User) }
      it { should_not be_able_to(:destroy, user) }
    end

    context 'as another User' do
      let(:ability) { Ability.new(FactoryGirl.create(:user)) }

      it { should_not be_able_to(:read, user) }
      it { should_not be_able_to(:update, user) }
      it { should_not be_able_to(:create, User) }
      it { should_not be_able_to(:destroy, user) }
    end
  end

  describe 'TimeType' do

    let(:time_type) { FactoryGirl.create(:time_type) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, time_type) }
      it { should be_able_to(:update, time_type) }
      it { should be_able_to(:create, TimeType) }
      it { should be_able_to(:destroy, time_type) }
    end

    context 'as a normal user' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, time_type) }
      it { should_not be_able_to(:update, time_type) }
      it { should_not be_able_to(:create, TimeType) }
      it { should_not be_able_to(:destroy, time_type) }
    end
  end

  describe 'TimeSheet' do

    let(:time_sheet) { FactoryGirl.create(:time_sheet, user: user) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, time_sheet) }
      it { should be_able_to(:update, time_sheet) }
      it { should be_able_to(:create, TimeSheet) }
      it { should be_able_to(:destroy, time_sheet) }
    end

    context 'as the owner' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, time_sheet) }
      it { should be_able_to(:update, time_sheet) }
      it { should be_able_to(:create, TimeSheet) }
      it { should be_able_to(:destroy, time_sheet) }
    end

    context 'as another user' do
      let(:ability) { Ability.new(FactoryGirl.create(:user)) }

      it { should_not be_able_to(:read, time_sheet) }
      it { should_not be_able_to(:update, time_sheet) }
      it { should_not be_able_to(:destroy, time_sheet) }
    end
  end

end
