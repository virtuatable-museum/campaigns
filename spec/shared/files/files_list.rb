RSpec.shared_examples 'GET /:id/files' do
  describe 'GET /:id/files' do

    let!(:other_campaign) { create(:campaign, id: 'other_campaign_id', title: 'other title', creator: account) }
    let!(:other_account) { create(:account, username: 'Other account', email: 'other@account.fr') }
    let!(:other_session) { create(:session, token: 'other_token', account: other_account)}
    let!(:other_invitation) { create(:accepted_invitation, account: other_account, campaign: other_campaign) }
    let!(:creator) { other_campaign.invitations.where(enum_status: :creator).first }
    
    let!(:file) {
      create(:file, {
        creator: creator,
        name: 'test.txt',
        mime_type: 'text/plain',
        size: 19,
        campaign: other_campaign
      })
    }

    let!(:other_file) {
      create(:file, {
        creator: creator,
        name: 'other.txt',
        mime_type: 'text/plain',
        size: 19,
        campaign: other_campaign
      })
    }

    let!(:permission) { Arkaan::Campaigns::Files::Permission.create(file: file, invitation: other_invitation, enum_level: :read) }
    
    describe 'Nominal case' do
      before do
        get "/campaigns/#{other_campaign.id.to_s}/files", {session_id: other_session.token, app_key: 'test_key', token: 'test_token'}
      end
      it 'Returns a OK (200) status code' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct number of files' do
        expect(JSON.parse(last_response.body).count).to be 1
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
        let!(:third_account) { create(:account, username: 'Babaussine', email: 'test@other.com') }
        let!(:third_session) { create(:session, token: 'any_other_token', account: third_account) }

        before do
          get "/campaigns/#{other_campaign.id.to_s}/files", {session_id: third_session.token, app_key: 'test_key', token: 'test_token',}
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