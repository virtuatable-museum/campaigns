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
              'id' => campaign.id.to_s,
              'title' => 'test_title',
              'description' => 'A longer description of the campaign',
              'creator' => {
                'id' => account.id.to_s,
                'username' => 'Babausse'
              },
              'is_private' => true,
              'tags' => ['test_tag']
            }
          ]
        })
      end
    end

    it_should_behave_like 'a route', 'get', '/'
  end

  describe 'GET /:id' do
    let!(:campaign) { create(:campaign, creator: account) }

    describe 'Nominal case' do
      before do
        get '/campaign_id', {token: 'test_token', app_key: 'test_key'}
      end
      it 'returns a OK (200) response code when successfully getting a camapign' do
        expect(last_response.status).to be 200
      end
      it 'returns the correct body when getting a campaign' do
        expect(JSON.parse(last_response.body)).to eq({
          'id' => campaign.id.to_s,
          'title' => 'test_title',
          'description' => 'A longer description of the campaign',
          'creator' => {
            'id' => account.id.to_s,
            'username' => 'Babausse'
          },
          'is_private' => true,
          'tags' => ['test_tag']
        })
      end
    end

    it_should_behave_like 'a route', 'put', '/campaign_id'

    describe 'Not Found Errors' do
      describe 'Campaign not found error' do
        before do
          put '/fake_campaign_id', {token: 'test_token', app_key: 'test_key'}
        end
        it 'correctly returns a Not Found (404) error when the campaign you want to get does not exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the campaign does not exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'campaign_not_found'})
        end
      end
    end
  end

  describe 'POST /' do
    describe 'Nominal case' do
      before do
        post '/', {
          token: 'test_token',
          app_key: 'test_key',
          title: 'some title',
          description: 'test',
          is_private: true,
          creator_id: account.id.to_s,
          tags: ['test_tag']
        }
      end
      it 'returns a Created (201) status when correctly creating a campaign' do
        expect(last_response.status).to be 201
      end
      it 'returns the correct body when correctly creating a campaign' do
        expect(JSON.parse(last_response.body)).to eq({'message' => 'created'})
      end
      describe 'created campaign' do
        let!(:created_campaign) { Arkaan::Campaign.all.first }

        it 'has created a new campaign' do
          expect(Arkaan::Campaign.all.count).to be 1
        end
        it 'has created a campaign with the correct title' do
          expect(created_campaign.title).to eq 'some title'
        end
        it 'has created a campaign with the correct description' do
          expect(created_campaign.description).to eq 'test'
        end
        it 'has created a private campaign' do
          expect(created_campaign.is_private).to be true
        end
        it 'has_created a campaign with the correct creator' do
          expect(created_campaign.creator_id.to_s).to eq account.id.to_s
        end
        it 'has inserted the correct tags in the campaign' do
          expect(created_campaign.tags).to eq ['test_tag']
        end
      end
      describe 'created tag' do
        let!(:created_tag) { Arkaan::Campaigns::Tag.all.first }

        it 'has created tags for the new campaign' do
          expect(Arkaan::Campaigns::Tag.all.count).to be 1
        end
        it 'has created a tag with the correct content' do
          expect(created_tag.content).to eq 'test_tag'
        end
        it 'has created a tag with the correct count' do
          expect(created_tag.count).to be 1
        end
      end
    end

    describe 'when no tags are given' do
      before do
        post '/', {token: 'test_token', app_key: 'test_key', title: 'some title', is_private: true, creator_id: account.id.to_s}
      end
      it 'has correctly created a campaign' do
        expect(Arkaan::Campaign.all.count).to be 1
      end
      it 'has created no tags in the database' do
        expect(Arkaan::Campaigns::Tag.all.count).to be 0
      end
      it 'has created a campaign with an empty tags array' do
        expect(Arkaan::Campaign.first.tags).to eq []
      end
    end

    describe 'when the same tag is given several times' do
      before do
        post '/', {
          token: 'test_token',
          app_key: 'test_key',
          title: 'some title',
          description: 'test',
          is_private: true,
          creator_id: account.id.to_s,
          tags: ['test_tag', 'test_tag']
        }
      end
      it 'has correctly created a campaign' do
        expect(Arkaan::Campaign.all.count).to be 1
      end
      it 'has correctly populated the tags for the campaign' do
        expect(Arkaan::Campaign.first.tags).to eq ['test_tag']
      end
      it 'has created a tag for the campaign' do
        expect(Arkaan::Campaigns::Tag.all.count).to be 1
      end
      it 'has created a tag with the correct count' do
        expect(Arkaan::Campaigns::Tag.first.count).to be 1
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

  describe 'PUT /:id' do
    describe 'Successful updates' do
      let!(:campaign) { create(:campaign, creator: account) }
      let!(:counter) { Arkaan::Campaigns::Tag.create(content: 'test_tag', count: 1) }

      describe 'nothing being updated' do
        before do
          put "/#{campaign.id.to_s}", {token: 'test_token', app_key: 'test_key'}
        end
        it 'returns a OK (200) response code when updating nothing' do
          expect(last_response.status).to be 200
        end
        it 'returns the correct body when updating nothing' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'updated'})
        end
        describe 'campaign parameters' do
          let!(:updated_campaign) { Arkaan::Campaign.where(id: 'campaign_id').first }

          it 'has not changed the title of the campaign' do
            expect(updated_campaign.title).to eq 'test_title'
          end
          it 'has not changed the description of the campaign' do
            expect(updated_campaign.description).to eq 'A longer description of the campaign'
          end
          it 'has not changed the privacy of the campaign' do
            expect(updated_campaign.is_private).to be true
          end
          it 'has not changed the tags of the campaign' do
            expect(updated_campaign.tags).to eq ['test_tag']
          end
        end
      end
      describe 'update of the title' do
        before do
          put "/#{campaign.id.to_s}", {token: 'test_token', app_key: 'test_key', title: 'another random title'}
        end
        it 'returns a OK (200) response code when updating the title' do
          expect(last_response.status).to be 200
        end
        it 'returns the right body when updating the title' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'updated'})
        end
        it 'has correctly updated the title of the campaign' do
          expect(Arkaan::Campaign.where(id: 'campaign_id').first.title).to eq 'another random title'
        end
      end
      describe 'update of the description' do
        before do
          put "/#{campaign.id.to_s}", {token: 'test_token', app_key: 'test_key', description: 'another long description'}
        end
        it 'returns a OK (200) response code when updating the description' do
          expect(last_response.status).to be 200
        end
        it 'returns the right body when updating the description' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'updated'})
        end
        it 'has correctly updated the description of the campaign' do
          expect(Arkaan::Campaign.where(id: 'campaign_id').first.description).to eq 'another long description'
        end
      end
      describe 'update of the privacy' do
        before do
          put "/#{campaign.id.to_s}", {token: 'test_token', app_key: 'test_key', is_private: false}
        end
        it 'returns a OK (200) response code when updating the privacy' do
          expect(last_response.status).to be 200
        end
        it 'returns the right body when updating the privacy' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'updated'})
        end
        it 'has correctly updated the privacy of the campaign' do
          expect(Arkaan::Campaign.where(id: 'campaign_id').first.is_private).to be false
        end
      end
      describe 'update of the tags' do
        describe 'update with an empty tags list' do
          before do
            put "/#{campaign.id.to_s}", {token: 'test_token', app_key: 'test_key', tags: []}
          end
          it 'returns a OK (200) response code when updating the tags' do
            expect(last_response.status).to be 200
          end
          it 'returns the right body when updating the tags' do
            expect(JSON.parse(last_response.body)).to eq({'message' => 'updated'})
          end
          it 'has correctly updated the tags of the campaign' do
            expect(Arkaan::Campaign.where(id: 'campaign_id').first.tags).to eq []
          end
          it 'has deleted the tags counters not used anymore' do
            expect(Arkaan::Campaigns::Tag.all.count).to be 0
          end
        end
        describe 'update with another tags list' do
          before do
            put "/#{campaign.id.to_s}", {token: 'test_token', app_key: 'test_key', tags: ['random_tag']}
          end
          it 'returns a OK (200) response code when updating the tags' do
            expect(last_response.status).to be 200
          end
          it 'returns the right body when updating the tags' do
            expect(JSON.parse(last_response.body)).to eq({'message' => 'updated'})
          end
          it 'has correctly updated the tags of the campaign' do
            expect(Arkaan::Campaign.where(id: 'campaign_id').first.tags).to eq ['random_tag']
          end
          it 'has left only one counter for tags' do
            expect(Arkaan::Campaigns::Tag.all.count).to be 1
          end
          it 'has left a tags counter with the right content' do
            expect(Arkaan::Campaigns::Tag.first.content).to eq 'random_tag'
          end
          it 'has left a tags counter with the right count' do
            expect(Arkaan::Campaigns::Tag.first.count).to be 1
          end
        end
      end
    end

    it_should_behave_like 'a route', 'put', '/campaign_id'

    describe 'Not Found errors' do
      describe 'Campaign not found error' do
        before do
          put '/fake_campaign_id', {token: 'test_token', app_key: 'test_key'}
        end
        it 'correctly returns a Not Found (404) error when the campaign you want to update does not exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the campaign does not exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'campaign_not_found'})
        end
      end
    end

    describe 'Unprocessable entity errors' do
      describe 'when the updated title is already used by another campaign' do
        let!(:campaign) { create(:campaign, creator: account) }
        let!(:other_campaign) { create(:campaign, id: 'another_campaign_id', title: 'another title', creator: account) }

        before do
          put '/campaign_id', {token: 'test_token', app_key: 'test_key', title: 'another title'}
        end
        it 'returns an Unprocessable Entity (422) response code when updating with an already used title' do
          expect(last_response.status).to be 422
        end
        it 'returns the correct body when updating with an already used title' do
          expect(JSON.parse(last_response.body)).to eq({'errors' => ['campaign.title.uniq']})
        end
      end
    end
  end

  describe 'DELETE /:id' do
    let!(:campaign) { create(:campaign, creator: account) }

    describe 'Nominal case' do
      before do
        delete '/campaign_id', {token: 'test_token', app_key: 'test_key'}
      end
      it 'Returns a OK (200) when you successfully delete a campaign' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body when successfully suppressing a campaign' do
        expect(JSON.parse(last_response.body)).to eq({'message' => 'deleted'})
      end
      it 'has deleted the campaign properly' do
        expect(Arkaan::Campaign.count).to be 0
      end
    end

    it_should_behave_like 'a route', 'delete', '/campaign_id'

    describe 'Not Found errors' do
      describe 'Campaign not found error' do
        before do
          delete '/any_other_id', {token: 'test_token', app_key: 'test_key'}
        end
        it 'correctly returns a Not Found (404) error when the campaign you try to delete does not exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the campaign does not exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'campaign_not_found'})
        end
      end
    end
  end
end