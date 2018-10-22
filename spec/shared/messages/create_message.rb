RSpec.shared_examples 'POST /:id/messages' do
  describe 'POST /:id/messages' do
    let!(:campaign) { create(:campaign, creator: account) }
    let!(:session) { create(:session, account: account) }

    describe 'Nominal case' do
      before do
        post '/campaign_id/messages', {token: 'test_token', app_key: 'test_key', session_id: session.token, content: 'test'}
      end
      it 'Returns a Created (201) status code' do
        expect(last_response.status).to be 201
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json({
          message: 'created',
          item: {
            username: account.username,
            type: 'text',
            content: 'test'
          }
        })
      end
      describe 'campaign messages' do
        before do
          campaign.reload
        end
        it 'has effectively added a message in the campaign' do
          expect(campaign.messages.count).to be 1
        end
        it 'has added the correct message to the campaign' do
          expect(campaign.messages.first.content).to eq 'test'
        end
      end
    end

    describe 'Alternative cases' do
      before do
        post '/campaign_id/messages', {token: 'test_token', app_key: 'test_key', session_id: session.token, content: '/roll 2d10+5'}
      end
      it 'Returns a Created (201) status code' do
        expect(last_response.status).to be 201
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json({
          message: 'created',
          item: {
            username: account.username,
            type: 'diceroll',
            number_of_dices: 2,
            number_of_faces: 10,
            modifier: 5
          }
        })
      end
      describe 'campaign messages' do
        let!(:message) {
          campaign.reload
          campaign.messages.first
        }
        it 'has the correct number of dices' do
          expect(message.number_of_dices).to be 2
        end
        it 'has the correct number of faces' do
          expect(message.number_of_faces).to be 10
        end
        it 'has the correct modifier' do
          expect(message.modifier).to be 5
        end
      end
    end

    it_should_behave_like 'a route', 'post', '/campaign_id/messages'

    describe '400 errors' do
      describe 'message not given' do
        before do
          post '/campaign_id/messages', {token: 'test_token', app_key: 'test_key', session_id: session.token}
        end
        it 'Returns a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'content',
            'error' => 'required'
          })
        end
      end
      describe 'message given empty' do
        before do
          post '/campaign_id/messages', {token: 'test_token', app_key: 'test_key', session_id: session.token, content: ''}
        end
        it 'Returns a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'content',
            'error' => 'required'
          })
        end
      end
      describe 'session ID not given' do
        before do
          post '/campaign_id/messages', {token: 'test_token', app_key: 'test_key'}
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
        let!(:another_account) { create(:another_account) }
        let!(:session) { create(:session, account: another_account) }

        before do
          post '/campaign_id/messages', {token: 'test_token', app_key: 'test_key', session_id: session.token}
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