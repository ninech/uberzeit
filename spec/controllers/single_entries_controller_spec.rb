require 'spec_helper'

describe SingleEntriesController do
  render_views

  context 'for non-signed in users' do
    it 'denies access' do
      time_sheet = FactoryGirl.create(:time_sheet)
      get :new, time_sheet_id: time_sheet
      response.code.should eq('401')
    end
  end

  context 'for signed-in users' do
    before do
      test_sign_in
    end

    describe 'GET "new"' do
      it 'assigns a single entry to @single_entry' do
        time_sheet = FactoryGirl.create(:time_sheet)
        get :new, time_sheet_id: time_sheet
        assigns(:entry).class.should be(SingleEntry)
      end

      it 'renders the :new template' do
        time_sheet = FactoryGirl.create(:time_sheet)
        get :new, time_sheet_id: time_sheet
        response.should render_template :new
      end
    end

    describe 'GET "edit"' do
      before do
        @entry = FactoryGirl.create(:single_entry)
      end

      it 'assigns the to-be entry to @entry' do
        get :edit, id: @entry, time_sheet_id: @entry.time_sheet
        assigns(:entry).should eq(@entry)
      end

      it 'renders the :edit template' do
        get :edit, id: @entry, time_sheet_id: @entry.time_sheet
        assigns(:entry).should eq(@entry)
      end
    end

    describe 'PUT "update"' do
      before do
        @entry = FactoryGirl.create(:single_entry)
      end

      context 'with valid attributes' do
        it 'changes @entry\'s attributes' do
          put :update, id: @entry, time_sheet_id: @entry.time_sheet, single_entry: FactoryGirl.attributes_for(:single_entry, whole_day: true)
          @entry.reload
          @entry.whole_day.should be_true
        end

        it 'redirects to the sheet overview' do
          put :update, id: @entry, time_sheet_id: @entry.time_sheet, single_entry: FactoryGirl.attributes_for(:single_entry)
          response.should redirect_to @entry.time_sheet
        end
      end

      context 'with invalid attributes' do
        it 're-renders the :edit template' do
          put :update, id: @entry, time_sheet_id: @entry.time_sheet, single_entry: FactoryGirl.attributes_for(:invalid_single_entry)
          response.should render_template :edit
        end
      end
    end

    describe 'POST "create"' do
      before do
        @time_sheet = FactoryGirl.create(:time_sheet)
      end

      context 'with valid attributes' do
        it 'creates a new single entry' do
          expect do
            time_type = FactoryGirl.create(:time_type_work)
            post :create, time_sheet_id: @time_sheet, single_entry: FactoryGirl.attributes_for(:single_entry, time_type_id: time_type.id)
          end.to change(SingleEntry,:count).by(1)
        end

        it 'redirects to the sheet overview' do
          time_type = FactoryGirl.create(:time_type_work)
          post :create, time_sheet_id: @time_sheet, single_entry: FactoryGirl.attributes_for(:single_entry, time_type_id: time_type.id) 
          response.should redirect_to @time_sheet
        end
      end

      context 'with invalid attributes' do
        it 'does not save the new single entry' do
          expect { post :create, time_sheet_id: @time_sheet, single_entry: FactoryGirl.attributes_for(:invalid_single_entry) }.to_not change(SingleEntry,:count)
        end

        it 're-renders the :new template' do
          post :create, time_sheet_id: @time_sheet, single_entry: FactoryGirl.attributes_for(:invalid_single_entry)
          response.should render_template :new
        end
      end
    end
  end
end
