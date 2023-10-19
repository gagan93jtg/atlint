require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  describe "User listing API" do
    context "when we have one user" do
      let!(:user) { FactoryBot.create(:user) }

      before { get "/api/v1/users" }

      it "should get one user from response" do
        body = JSON.parse(response.body)
        expect(body["data"].count).to eq(1)
      end

      it "should respond with http 200 (ok)" do
        expect(response).to have_http_status(:ok)
      end

      it "should respond with the expected use" do
        body = JSON.parse(response.body)
        expect(body["data"][0]["email"]).to eq(user.email)
      end
    end

    context "when we have zero users" do
      before { get "/api/v1/users" }

      it "should get one user from response" do
        body = JSON.parse(response.body)
        expect(body["data"].count).to eq(0)
      end

      it "should respond with http 200 (ok)" do
         expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "User creation flows" do
    context "Invalid details" do
      context "Missing details" do
        let(:user_attrs) { { email: nil } }
        before { post "/api/v1/users", params: { user: user_attrs } }

        it "should not be able to create the user" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "Duplicate details" do
        let!(:user) { FactoryBot.create(:user) }
        before { post "/api/v1/users", params: { user: user.as_json.slice("email", "password", "username") } }

        it "should not be able to create the user" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "Valid details" do
      let(:user_attrs) {  FactoryBot.build(:user).as_json.compact }
      before { post "/api/v1/users", params: { user: user_attrs } }

      it "should be able to create the user" do
        expect(response).to have_http_status(:ok)
      end

      it "should be able to save user details" do
        body = JSON.parse(response.body)
        expect(body["data"]["user"]["email"]).to eq(user_attrs["email"])
      end
    end
  end

  describe "User login flow" do
    context "Valid details" do
      let!(:user) { FactoryBot.create(:user) }
      before { post "/api/v1/users/login", params: { user: user.as_json.slice("email", "password") } }

      it "should be able to login" do
        expect(response).to have_http_status(:ok)
      end

      it "should get successful response" do
        body = JSON.parse(response.body)
        expect(body["success"]).to be_truthy
      end
    end

    context "Invalid details" do
      context "Password invalid"  do
        let!(:user) { FactoryBot.create(:user) }
        before { post "/api/v1/users/login", params: { user: user.as_json.slice("email").merge(password: "1234xxxx") } }

        it "should not be able to login" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "Email invalid"  do
        let!(:user) { FactoryBot.create(:user) }
        before { post "/api/v1/users/login", params: { user: user.as_json.slice("password").merge(email: "1234@xxxx") } }

        it "should not be able to login" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "No user present"  do
        before { post "/api/v1/users/login", params: { user: { email: "1234@xxxx", password: '1234xxx' } } }

        it "should not be able to login" do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
