RSpec.shared_examples 'GET /:id/messages' do
  describe 'GET /:id/messages' do
    let!(:campaign) { create(:campaign, creator: account) }
    let!(:another_account) { create(:another_account) }
    let!(:session) { create(:session, account: another_account) }
    let!(:chat_invitation) { create(:accepted_invitation, campaign: campaign, account: another_account) }
    let!(:message) { create(:message, player: chat_invitation, campaign: campaign, content: 'test messages') }

    describe 'Nominal case' do
      before do
        get "/#{campaign.id.to_s}/messages", {token: 'test_token', app_key: 'test_key', session_id: session.token}
      end
      it 'Returns a OK (200) status code' do
        expect(last_response.status).to be 200
      end
      it 'Retuens the correct body' do
        expect(last_response.body).to include_json([
          {
            id: message.id.to_s,
            username: another_account.username,
            created_at: message.created_at.utc.iso8601,
            content: 'test messages'
          }
        ])
      end
    end

    it_should_behave_like 'a route', 'post', '/campaign_id/messages'

    describe '400 errors' do
      describe 'session ID not given' do
        before do
          get '/campaign_id/messages', {token: 'test_token', app_key: 'test_key'}
        end
        it 'Returns a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'session_id',
            'error' => 'required'
          })
        end
      end
    end

    describe '403 error' do
      describe 'Session ID not allowed' do
        let!(:third_account) { create(:account, email: 'third@test.com', username: 'Third account') }
        let!(:other_session) { create(:session, account: third_account, token: 'truite violette') }

        before do
          get "/#{campaign.id.to_s}/messages", {token: 'test_token', app_key: 'test_key', session_id: other_session.token}
        end
        it 'Returns a 403 error' do
          expect(last_response.status).to be 403
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 403,
            'field' => 'session_id',
            'error' => 'forbidden'
          })
        end
      end
    end
  end
end