RSpec.shared_examples 'GET /:id/invitations' do

  describe 'GET /:id/invitations' do
    let!(:acceptation_date) { DateTime.now }
    let!(:other_account) { create(:account, username: 'Other username', email: 'test@email.com') }
    let!(:third_account) { create(:account, username: 'Third username', email: 'third@email.com') }
    let!(:campaign) { create(:campaign, creator: account) }
    let!(:pending_invitation) { create(:invitation, account: third_account, campaign: campaign, creator: other_account) }
    let!(:accepted_invitation) {
      create(:invitation,
        account: account,
        campaign: campaign,
        accepted: true,
        creator: other_account,
        accepted_at: acceptation_date
      )
    }

    describe 'Nominal case' do
      before do
        get "/#{campaign.id.to_s}/invitations?token=test_token&app_key=test_key"
      end
      it 'Returns a OK (200) status code when correctly returning the invitations' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct invitations when getting the invitations' do
        expect(JSON.parse(last_response.body)).to eq({
          'accepted' => {
            'count' => 1,
            'items' => [
              {
                'id' => accepted_invitation.id.to_s,
                'creator' =>
                'Other username',
                'username' => 'Babausse'
              }
            ]
          },
          'pending' => {
            'count' => 1,
            'items' => [
              {
                'id' => pending_invitation.id.to_s,
                'creator' => 'Other username',
                'username' => 'Third username'
              }
            ]
          }
        })
      end
    end

    it_should_behave_like 'a route', 'get', '/campaign_id/invitations'

    describe 'Not Found Errors' do
      describe 'Campaign not found error' do
        before do
          get '/fake_campaign_id/invitations', {token: 'test_token', app_key: 'test_key'}
        end
        it 'correctly returns a Not Found (404) error when the campaign you want to get does not exist' do
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
  end
end