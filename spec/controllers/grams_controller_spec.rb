require 'rails_helper'

RSpec.describe GramsController, type: :controller do

  describe "grams#index action" do
    it "should successfully show page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "should require users to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show new form" do
      user = FactoryGirl.create(:user)
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#show action" do
    it "should successfully show the page if the gram is found" do
      show_success = FactoryGirl.create(:gram)
      sign_in show_success.user

      get :show, id: show_success.id
      expect(response).to have_http_status(:success)
    end
    it "should return a 404 error if the gram isn't found" do 
      show_fail = FactoryGirl.create(:gram)
      sign_in show_fail.user

      get :show, id: 'TACOCAT'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#create action" do
    it "should require users to be logged in" do
      post :create, gram: {message: 'Hello!'}
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully create a new gram in our database" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram: {
        message: 'Hello!',
        picture: fixture_file_upload("/picture.png", 'image/png')
      }
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq('Hello!')
      expect(gram.user).to eq(user)
    end 

    it "should properly deal with validation errors" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram: {message: ' '}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eq 0
    end
  end

  describe "grams#edit" do
    it "shouldn't let a user who did not create the gram to edit the gram" do
      edit_access = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      get :edit, id: edit_access.id
      expect(response).to have_http_status(:forbidden)

    end

    it "shouldn't allow unauthenticated users to edit a gram" do
      edit_auth = FactoryGirl.create(:gram)
      get :edit, id: edit_auth.id
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the edit form if the gram is found" do
      edit_success = FactoryGirl.create(:gram)
      sign_in edit_success.user

      get :edit, id: edit_success.id
      expect(response).to have_http_status(:success)
    end
    
    it "should return a 404 error message if the gram is not found" do
      edit_fail = FactoryGirl.create(:gram)
      sign_in edit_fail.user

      get :edit, id: 'SWAG'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update" do
    it "shouldn't allow users who did not create the gram to update the gram" do
      update_access = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      patch :update, id: update_access.id, gram: {message: 'woohoo!'} 
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't allow unauthenticated users to update a gram" do
      update_auth = FactoryGirl.create(:gram)
      patch :update, id: update_auth.id, gram: {message: 'hello'}
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow users to successfully update grams" do
      update_success = FactoryGirl.create(:gram, message: "initial value")
      sign_in update_success.user

      patch :update, id: update_success.id, gram: {message: 'changed'}
      expect(response).to redirect_to root_path

      update_success.reload
      expect(update_success.message).to eq 'changed'
    end

    it "should have http 404 error if the grams cannot be found" do
      update_fail = FactoryGirl.create(:gram)
      sign_in update_fail.user

      patch :update, id: "YOLOSWAG", gram: {message: 'changed'}
      expect(response).to have_http_status(:not_found)
    end

    it "should render an edit form with http status of unprocessable_entity" do
      update_fail = FactoryGirl.create(:gram, message: "initial value")
      sign_in update_fail.user

      patch :update, id: update_fail.id, gram: {message: ' '}
      expect(response).to have_http_status(:unprocessable_entity)

      update_fail.reload
      expect(update_fail.message).to eq 'initial value'
    end
  end

  describe "grams#destroy" do
    it "shouldn't allow user who did not create the gram to destroy the gram" do
      destroy_access = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user

      delete :destroy, id: destroy_access.id
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't allow unauthenticated users to destroy a gram" do
      destroy_auth = FactoryGirl.create(:gram)
      delete :destroy, id: destroy_auth.id
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow user to destroy gram" do
      destroy_success = FactoryGirl.create(:gram)
      sign_in destroy_success.user

      delete :destroy, id: destroy_success.id 
      expect(response).to redirect_to root_path

      destroy_success = Gram.find_by_id(destroy_success.id)
      expect(destroy_success).to eq nil
    end

    it "should return 404 message if we cannot find a gram with the id that is specified" do
      delete_fail = FactoryGirl.create(:user)
      sign_in delete_fail

      delete :destroy, id: 'SPACEDUCK'
      expect(response).to have_http_status(:not_found)
    end
  end

end
