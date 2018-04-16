RSpec.shared_examples 'GET /' do
  describe 'GET /' do
    describe 'Nominal case' do
    let!(:campaign) { create(:campaign, creator: account, is_private: false) }
    let!(:other_account) { create(:account, username: 'other_username', email: 'other@mail.com') }
    let!(:other_campaign) { create(:campaign, id: 'other_campaign_id', creator: other_account, title: 'another title', is_private: false) }
    let!(:session) { create(:session, account: account) }

      before do
        get '/', {token: 'test_token', app_key: 'test_key', session_id: session.token}
      end
      it 'correctly returns a OK (200) when requesting the list of campaigns' do
        expect(last_response.status).to be 200
      end
      it 'returns the correct body when requesting the list of campaigns' do
        expect(JSON.parse(last_response.body)).to eq({
          'count' => 1,
          'items' => [
            {
              'id' => other_campaign.id.to_s,
              'title' => 'another title',
              'description' => 'A longer description of the campaign',
              'creator' => {
                'id' => other_account.id.to_s,
                'username' => 'other_username'
              },
              'is_private' => false,
              'tags' => ['test_tag']
            }
          ]
        })
      end
    end

    it_should_behave_like 'a route', 'get', '/'
  end
end