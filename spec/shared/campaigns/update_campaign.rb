RSpec.shared_examples 'PUT /:id' do
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
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 404,
            'field' => 'campaign_id',
            'error' => 'unknown'
          })
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
        it 'returns an Unprocessable Entity (400) response code when updating with an already used title' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct body when updating with an already used title' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'title',
            'error' => 'uniq'
          })
        end
      end
    end
  end
end