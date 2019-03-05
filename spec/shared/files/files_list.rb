RSpec.shared_examples 'GET /:id/files' do
  describe 'GET /:id/files' do
    
    let!(:file) {
      create(:file, {
        creator: campaign.invitations.first,
        name: 'test.txt',
        mime_type: 'text/plain',
        size: 19,
        campaign: campaign
      })
    }
    
    describe 'Nominal case' do
      before do
        get "/campaigns/#{campaign.id.to_s}/files", {session_id: session.token, app_key: 'test_key', token: 'test_token'}
      end
      it 'Returns a OK (200) status code' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json([
          {
            id: file.id.to_s,
            name: 'test.txt',
            type: 'text/plain',
            size: 19,
            account: {
              id: account.id.to_s,
              username: account.username
            }
          }
        ])
      end
    end

    it_behaves_like 'a route', 'get', '/campaign_id/files'

    describe '403 errors' do
      describe 'account not authorized' do
        let!(:other_account) { create(:account, username: 'Babaussine', email: 'test@other.com') }
        let!(:other_session) { create(:session, token: 'any_other_token', account: other_account) }

        before do
          get "/campaigns/#{campaign.id.to_s}/files", {session_id: other_session.token, app_key: 'test_key', token: 'test_token',}
        end
        it 'Returns a Forbidden (403) status code' do
          expect(last_response.status).to be 403
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 403,
            field: 'session_id',
            error: 'forbidden'
          })
        end
      end
    end
  end
end