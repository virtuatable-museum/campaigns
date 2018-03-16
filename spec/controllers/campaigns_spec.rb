RSpec.describe Controllers::Campaigns do

  before do
    DatabaseCleaner.clean
  end

  let!(:account) { create(:account) }
  let!(:gateway) { create(:gateway) }
  let!(:application) { create(:application, creator: account) }

  def app
    Controllers::Campaigns.new
  end

  describe 'GET /' do
    describe 'Nominal case' do
      let!(:campaign) { create(:campaign, creator: account) }

      before do
        get '/', {token: 'test_token', app_key: 'test_key'}
      end
      it 'correctly returns a OK (200) when requesting the list of campaigns' do
        expect(last_response.status).to be 200
      end
      it 'returns the correct body when requesting the list of campaigns' do
        expect(JSON.parse(last_response.body)).to eq({
          'count' => 1,
          'items' => [
            {
              'title' => 'test_title',
              'description' => 'A longer description of the campaign',
              'creator' => {
                'id' => account.id.to_s,
                'username' => 'Babausse'
              },
              'is_private' => true
            }
          ]
        })
      end
    end

    it_should_behave_like 'a route', 'get', '/'
  end

  describe 'POST /' do
    describe 'Nominal case' do
      before do
        post '/', {token: 'test_token', app_key: 'test_key', title: 'some title', description: 'test', is_private: true, creator_id: account.id.to_s}
      end
      it 'returns a Created (201) status when correctly creating a campaign' do
        expect(last_response.status).to be 201
      end
      it 'returns the correct body when correctly creating a campaign' do
        expect(JSON.parse(last_response.body)).to eq({'message' => 'created'})
      end
    end

    it_should_behave_like 'a route', 'post', '/'

    describe 'bad requests errors' do
      describe 'Campaign title not given error' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', description: 'test', is_private: true, creator_id: account.id.to_s}
        end
        it 'returns a Bad Request (400) error when not giving the campaign title' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct body when not giving the campaign title' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'missing.title'})
        end
      end
    end

    describe 'Unprocessable entity errors' do
      describe 'Campaign title too short' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', title: 'a', is_private: true, creator_id: account.id.to_s}
        end
        it 'returns an Unprocessable Entity (422) error when the title is too short' do
          expect(last_response.status).to be 422
        end
        it 'returns the correct body when the campaign title is too short' do
          expect(JSON.parse(last_response.body)).to eq({'errors' => ['campaign.title.short']})
        end
      end

      describe 'campaign title already taken' do
        before do
          create(:campaign, title: 'test_title', creator: account)
          post '/', {token: 'test_token', app_key: 'test_key', title: 'test_title', creator_id: account.id.to_s}
        end
        it 'returns an Unprocessable Entity (422) error when the title is already used' do
          expect(last_response.status).to be 422
        end
        it 'returns the correct body when the campaign title is already used by this user' do
          expect(JSON.parse(last_response.body)).to eq({'errors' => ['campaign.title.uniq']})
        end
      end
    end
  end
end