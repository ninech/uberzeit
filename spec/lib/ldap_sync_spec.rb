require 'spec_helper'

describe LdapSync do
  before do
    @systems = OpenStruct.new({
      id: 'Systems',
      cn: 'Systems',
      managers: [],
      people: []
    })

    @administration = OpenStruct.new({
      id: 'Administration',
      cn: 'Administration',
      managers: [],
      people: []
    })

    @departments = [@systems, @administration]

    @person = OpenStruct.new({
      id: 'tofue',
      sn: 'Fuenke',
      givenname: 'Tobias',
      birthdate: '1990-09-29',
      mail: 'tofue@nine.ch',
      cancelled?: false
    })

    @person.stub(:departments) do
      @departments.collect do |dep|
        dep if dep.people.include?(@person) or dep.managers.include?(@person)
      end.compact
    end

    @systems.managers << @person
    @systems.people << @person
    @administration.people << @person

    Department.stub(:find) { |id|  @departments.find { |dep| dep.cn == id } }
    Department.stub(:find_all).and_return(@departments)
    Person.stub(:find).and_return(@person)
    Person.stub(:find_one).and_return(@person)
    Person.stub(:find_all).and_return([@person])

    LdapSync.all

    @user = User.last
  end

  it 'creates a local user' do
    @user.should_not be_nil
  end

  it 'creates the teams which the user is member of' do
    @person.departments.each do |department|
      Team.find_by_uid(department.id).should_not be_nil
    end
  end

  it 'creates the teams which the user is leader of' do
    Department.find_all.each do |department|
      if department.managers.include?(@person)
        Team.find_by_uid(department.id).should_not be_nil
      end
    end
  end

  it 'assigns the properties of the user correctly' do
    @user.birthday.should eq(Date.new(1990,9,29))
    @user.given_name.should eq(@person.givenname)
    @user.name.should eq(@person.sn)
  end

  it 'assigns the properties of the teams correctly' do
    @user.teams.each do |team|
      team.name.should eq(Department.find(team.uid).cn)
    end
  end

  it 'removes missing leadership links' do
    team = Team.find_by_uid(@systems.id)
    @user.has_role?(:team_leader, team).should be_true
    @systems.managers.delete(@person)
    LdapSync.all
    @user.has_role?(:team_leader, team).should be_false
  end

  it 'removes missing membership links' do
    team = Team.find_by_uid(@administration.id)
    team.has_member?(@user).should be_true
    @administration.people.delete(@person)
    LdapSync.all
    team.reload.has_member?(@user).should be_false
  end

  it 'detects the change from member to leader' do
    team = Team.find_by_uid(@administration.id)
    @user.has_role?(:team_leader, team).should be_false
    @administration.managers.push(@person)
    LdapSync.all
    @user.has_role?(:team_leader, team).should be_true
  end

  it 'deletes "cancelled" persons' do
    User.find_by_uid(@person.mail).should_not be_nil
    @person.stub(:cancelled?).and_return(true)
    LdapSync.all
    User.find_by_uid(@person.mail).should be_nil
    User.with_deleted.find_by_uid(@person.mail).should_not be_nil
  end

  it 'delegates the user to admin when in admin department' do
    @user.has_role?(:admin).should be_true
  end

  it 'revokes admin rights when user is no longer in admin department' do
    @user.has_role?(:admin).should be_true
    @administration.managers.delete(@person)
    @administration.people.delete(@person)
    LdapSync.all
    @user.has_role?(:admin).should be_false
  end
end
