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

  describe 'SingleEntry' do

    let(:single_entry) { FactoryGirl.create(:single_entry, time_sheet: user.sheets.first) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, single_entry) }
      it { should be_able_to(:update, single_entry) }
      it { should be_able_to(:create, SingleEntry) }
      it { should be_able_to(:destroy, single_entry) }
    end

    context 'as the owner' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, single_entry) }
      it { should be_able_to(:update, single_entry) }
      it { should be_able_to(:create, SingleEntry) }
      it { should be_able_to(:destroy, single_entry) }
    end

    context 'as another user' do
      let(:ability) { Ability.new(FactoryGirl.create(:user)) }

      it { should_not be_able_to(:read, single_entry) }
      it { should_not be_able_to(:update, single_entry) }
      it { should_not be_able_to(:destroy, single_entry) }
    end
  end

  describe 'Employment' do

    let(:employment) { FactoryGirl.create(:employment, user: user) }

    context 'as a user with the administration role' do
      let(:ability) { Ability.new(admin) }

      it { should be_able_to(:read, employment) }
      it { should be_able_to(:update, employment) }
      it { should be_able_to(:create, Employment) }
      it { should be_able_to(:destroy, employment) }
    end

    context 'as the owner' do
      let(:ability) { Ability.new(user) }

      it { should be_able_to(:read, employment) }
      it { should_not be_able_to(:update, employment) }
      it { should_not be_able_to(:create, Employment) }
      it { should_not be_able_to(:destroy, employment) }
    end

    context 'as another user' do
      let(:ability) { Ability.new(FactoryGirl.create(:user)) }

      it { should_not be_able_to(:read, employment) }
      it { should_not be_able_to(:update, employment) }
      it { should_not be_able_to(:create, Employment) }
      it { should_not be_able_to(:destroy, employment) }
    end
  end
end
