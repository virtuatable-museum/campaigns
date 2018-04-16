RSpec.shared_examples 'GET /own' do
  describe 'GET /own' do
    let!(:other_account) { create(:account, username: 'other_username', email: 'other@mail.com') }
    let!(:campaign) { create(:campaign, creator: account) }
    let!(:other_campaign) { create(:campaign, id: 'other_campaign_id', creator: other_account, title: 'another title') }
    let!(:third_campaign) { create(:campaign, id: 'other_campaign_id_2', creator: account, title: 'another title again', is_private: false) }
    let!(:session) { create(:session, account: account) }

    describe 'Nominal case' do
      before do
        get '/own', {token: 'test_token', app_key: 'test_key', session_id: session.token}
      end
      it 'Returns a 200 (OK) status' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(JSON.parse(last_response.body)).to eq({
          'count' => 2,
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
            },
            {
              'id' => third_campaign.id.to_s,
              'title' => 'another title again',
              'description' => 'A longer description of the campaign',
              'creator' => {
                'id' => account.id.to_s,
                'username' => 'Babausse'
              },
              'is_private' => false,
              'tags' => ['test_tag']
            }
          ]
        })
      end
    end

    describe '400 errors' do
      describe 'session ID not given' do
        before do
          get '/own', {token: 'test_token', app_key: 'test_key'}
        end
        it 'Raises a Bad Request (400) error' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            'status' => 400,
            'field' => 'session_id',
            'error' => 'required'
          })
        end
      end
    end

    describe '404 errors' do
      describe 'session ID not found' do
        before do
          get '/own', {token: 'test_token', app_key: 'test_key', session_id: 'unknown_session_id'}
        end
        it 'Raises a Not Found (404)) error' do
          expect(last_response.status).to be 404
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            'status' => 404,
            'field' => 'session_id',
            'error' => 'unknown'
          })
        end
      end
    end
  end
end