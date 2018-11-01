RSpec.shared_examples 'POST /:id/commands' do
  describe 'POST /:id/commands' do
    let!(:campaign) { create(:campaign, creator: account) }
    let!(:session) { create(:session, account: account) }

    def app
      Controllers::Commands.new
    end

    describe 'Nominal cases' do
      before do
        post '/campaigns/campaign_id/commands', {token: 'test_token', app_key: 'test_key', session_id: session.token, command: 'roll', content: '2d10+5'}
      end
      it 'Returns a Created (201) status code' do
        expect(last_response.status).to be 201
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json({
          message: 'created',
          item: {
            username: account.username,
            type: 'command'
          }
        })
      end
      it 'has the correct data' do
        expect(JSON.parse(last_response.body)['item']['data']).to include_json(
          command: 'roll',
          number_of_dices: 2,
          number_of_faces: 10,
          modifier: 5
        )
      end
      it 'Returns the correct number of results in the body' do
        expect(JSON.parse(last_response.body)['item']['data']['results'].count).to be 2
      end
      describe 'created message' do
        let!(:message) {
          campaign.reload
          campaign.messages.first
        }
        it 'has the correct message type' do
          expect(message.type).to eq :command
        end
        it 'has the correct command' do
          expect(message.data[:command]).to eq 'roll'
        end
        it 'has the correct number of dices' do
          expect(message.data[:number_of_dices]).to be 2
        end
        it 'has the correct number of faces' do
          expect(message.data[:number_of_faces]).to be 10
        end
        it 'has the correct modifier' do
          expect(message.data[:modifier]).to be 5
        end
        it 'has the correct number of results' do
          expect(message.data[:results].length).to be 2
        end
      end
    end

    describe 'Alternative cases' do
      describe 'when the content is not given' do
        before do
          post '/campaigns/campaign_id/commands', {token: 'test_token', app_key: 'test_key', session_id: session.token, command: 'easteregg'}
        end
        it 'Returns a Created (201) status' do
          expect(last_response.status).to be 201
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({item: 'easter egg to test'})
        end
      end
      describe 'when the content is given as empty' do
        before do
          post '/campaigns/campaign_id/commands', {token: 'test_token', app_key: 'test_key', session_id: session.token, command: 'easteregg', content: ''}
        end
        it 'Returns a Created (201) status' do
          expect(last_response.status).to be 201
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({item: 'easter egg to test'})
        end
      end
    end

    it_should_behave_like 'a route', 'post', '/campaigns/campaign_id/commands'

    describe '400 errors' do
      describe 'command not given' do
        before do
          post '/campaigns/campaign_id/commands', {token: 'test_token', app_key: 'test_key', session_id: session.token}
        end
        it 'Returns a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'command',
            'error' => 'required'
          })
        end
      end
      describe 'command given empty' do
        before do
          post '/campaigns/campaign_id/commands', {token: 'test_token', app_key: 'test_key', session_id: session.token, command: ''}
        end
        it 'Returns a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'command',
            'error' => 'required'
          })
        end
      end
      describe 'unknown command' do
        before do
          post '/campaigns/campaign_id/commands', {token: 'test_token', app_key: 'test_key', session_id: session.token, command: 'unknown', content: 'any'}
        end
        it 'Returns a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'command',
            'error' => 'unknown'
          })
        end
      end
      describe 'unparsable content' do
        before do
          post '/campaigns/campaign_id/commands', {token: 'test_token', app_key: 'test_key', session_id: session.token, command: 'roll', content: 'error triger'}
        end
        it 'Returns a Bad Request (400) status' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(JSON.parse(last_response.body)).to include_json({
            'status' => 400,
            'field' => 'content',
            'error' => 'unparsable'
          })
        end
      end
      describe 'session ID not given' do
        before do
          post '/campaigns/campaign_id/commands', {token: 'test_token', app_key: 'test_key'}
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
          post '/campaigns/campaign_id/commands', {token: 'test_token', app_key: 'test_key', session_id: session.token}
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