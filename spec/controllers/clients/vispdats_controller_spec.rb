require 'rails_helper'

RSpec.describe Clients::VispdatsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Vispdat. As you add validations to Vispdat, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { build(:vispdat).attributes }
  let(:warehouse_client) { create :authoritative_warehouse_client }
  let(:client) { warehouse_client.destination }
  let(:vispdat) { create(:vispdat, client: client) }
  let(:invalid_attributes) {}

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # VispdatsController. Be sure to keep this updated too.
  let(:valid_session) {}

  let(:user) { create :user }
  let(:vispdat_editor) { create :vispdat_editor }

  before(:each) do
    user.roles << vispdat_editor
    authenticate(user)
  end

  describe 'GET #index' do
    it 'assigns all vispdats as @vispdats' do
      vispdat.save
      get :index, params: { client_id: vispdat.client.to_param }
      expect(assigns(:vispdats)).to eq([vispdat])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested vispdat as @vispdat' do
      vispdat.save
      get :show, params: { id: vispdat.to_param, client_id: vispdat.client.to_param }
      expect(assigns(:vispdat)).to eq(vispdat)
    end
  end

  describe 'GET #show' do
    it 'renders show' do
      vispdat.save
      get :show, params: { id: vispdat.to_param, client_id: vispdat.client.to_param }
      expect(response).to render_template(:show)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested vispdat as @vispdat' do
      vispdat.save
      get :edit, params: { id: vispdat.to_param, client_id: vispdat.client.to_param }
      expect(assigns(:vispdat)).to eq(vispdat)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Vispdat' do
        expect do
          post :create, params: { client_id: client.id, vispdat: valid_attributes, type: 'GrdaWarehouse::Vispdat::Individual' }
        end.to change(GrdaWarehouse::Vispdat::Individual, :count).by(1)
      end

      it 'assigns a newly created vispdat as @vispdat' do
        post :create, params: { client_id: client.id, vispdat: valid_attributes }
        expect(assigns(:vispdat)).to be_a(GrdaWarehouse::Vispdat::Individual)
        expect(assigns(:vispdat)).to be_persisted
      end

      it 'sets the user_id to current_user' do
        post :create, params: { client_id: client.id, vispdat: valid_attributes }
        expect(assigns(:vispdat).user_id).to eq user.id
      end
    end

    context 'with invalid params' do
      it 'creates a stub vispdat as @vispdat' do
        post :create, params: { client_id: client.id, vispdat: invalid_attributes }
        expect(assigns(:vispdat)).to be_a(GrdaWarehouse::Vispdat::Individual)
      end
    end
  end
end
