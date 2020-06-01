RSpec.describe Controllers::Characters do
  def app
    Controllers::Characters.new
  end

  before :each do
    DatabaseCleaner.clean
  end

  before do
    definitions = [
      {
        'name' => 'Coddirole',
        'description' => 'Custom role playing system for Coddity',
        'validator' => 'validator.json',
        'editor' => 'editor.html',
        'displayer' => 'displayer.html',
        'style' => 'style.css',
        'folder' => File.absolute_path(File.join(__dir__, '..', '..', 'plugins', 'coddirole'))
      }
    ]
    allow(Services::Rulesets.instance).to receive(:definitions).and_return(definitions)
  end

  # Didier is the creator of the campaign (and the ruleset, but it matters less)
  let!(:didier) { create(:didier) }
  let!(:session_didier) { create(:session, account: didier) }
  let!(:coddirole) { create(:coddirole, creator: didier) }
  let!(:campaign) { create(:campaign, creator: didier, ruleset: coddirole) }
  # Jacques is an accepted player in the campaign
  let!(:jacques) { create(:jacques) }
  let!(:session_jacques) { create(:session, account: jacques) }
  let!(:invitation) { create(:invitation, account: jacques, enum_status: :accepted, campaign: campaign) }
  # Louis is not at all in the campaign
  let!(:louis) { create(:louis) }

  let!(:gateway) { create(:gateway) }
  let!(:appli) { create(:application, creator: didier) }

  let!(:data) {
    {'level' => 1, 'class' => 'wizard', 'name' => 'Gandalf'}.to_json
  }

  let!(:wrong_data) {
    {'level' => 'test', 'class' => nil}.to_json
  }

  describe 'POST /:id/characters' do
    describe 'Nominal case' do
      before do
        post "/campaigns/#{campaign.id.to_s}/characters", {
          session_id: session_didier.token,
          token: gateway.token,
          app_key: appli.key,
          invitation_id: invitation.id,
          data: data
        }
      end
      it 'Returns a 201 (Created) status code' do
        expect(last_response.status).to be 201
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json(JSON.parse(data))
      end
      describe 'Created character' do
        let!(:character) { invitation.characters.first }
        it 'Has created the character' do
          expect(invitation.characters.count).to be 1
        end
        it 'Has selected the character' do
          expect(character.selected).to be true
        end
        it 'Has correctly initialized the character' do
          expect(character.data).to include_json(JSON.parse(data))
        end
      end
    end
    describe 'errors' do
      describe '400 errors' do
        describe 'Data not given' do
          before do
            post "/campaigns/#{campaign.id.to_s}/characters", {
              session_id: session_didier.token,
              token: gateway.token,
              app_key: appli.key,
              invitation_id: invitation.id
            }
          end
          it 'Returns a 400 (Bad Request) status code' do
            expect(last_response.status).to be 400
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json(
              status: 400,
              field: 'data',
              error: 'required'
            )
          end
        end
        describe 'Invitation not given' do
          before do
            post "/campaigns/#{campaign.id.to_s}/characters", {
              session_id: session_didier.token,
              token: gateway.token,
              app_key: appli.key,
              data: data
            }
          end
          it 'Returns a 400 (Bad Request) status code' do
            expect(last_response.status).to be 400
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json(
              status: 400,
              field: 'invitation_id',
              error: 'required'
            )
          end
        end
        describe 'Invalid character' do
          before do
            post "/campaigns/#{campaign.id.to_s}/characters", {
              session_id: session_didier.token,
              token: gateway.token,
              app_key: appli.key,
              data: wrong_data,
              invitation_id: invitation.id
            }
          end
          it 'Returns a 400 (Bad Request) status code' do
            expect(last_response.status).to be 400
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json(
              status: 400,
              field: 'data',
              error: 'validation'
            )
          end
        end
      end
      describe '403 errors' do
        describe 'Session not creator' do
          before do
            post "/campaigns/#{campaign.id.to_s}/characters", {
              session_id: session_jacques.token,
              token: gateway.token,
              app_key: appli.key,
              data: data,
              invitation_id: invitation.id
            }
          end
          it 'Returns a 403 (Forbidden) status code' do
            expect(last_response.status).to be 403
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json(
              status: 403,
              field: 'session_id',
              error: 'forbidden'
            )
          end
        end
      end
      describe '404 errors' do
        describe 'Session not found' do
          before do
            post "/campaigns/#{campaign.id.to_s}/characters", {
              session_id: 'wrong token',
              token: gateway.token,
              app_key: appli.key,
              data: data,
              invitation_id: invitation.id
            }
          end
          it 'Returns a 404 (Not Found) status code' do
            expect(last_response.status).to be 404
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json(
              status: 404,
              field: 'session_id',
              error: 'unknown'
            )
          end
        end
        describe 'campaign not found' do
          before do
            post "/campaigns/unknown/characters", {
              session_id: session_didier.token,
              token: gateway.token,
              app_key: appli.key,
              data: data,
              invitation_id: invitation.id
            }
          end
          it 'Returns a 404 (Not Found) status code' do
            expect(last_response.status).to be 404
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json(
              status: 404,
              field: 'campaign_id',
              error: 'unknown'
            )
          end
        end
        describe 'Invitation not found' do
          before do
            post "/campaigns/#{campaign.id.to_s}/characters", {
              session_id: session_didier.token,
              token: gateway.token,
              app_key: appli.key,
              data: data,
              invitation_id: 'unknown'
            }
          end
          it 'Returns a 404 (Not Found) status code' do
            expect(last_response.status).to be 404
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json(
              status: 404,
              field: 'invitation_id',
              error: 'unknown'
            )
          end
        end
      end
    end
  end

  describe 'GET /:id/characters' do
    let!(:character) { create(:character, data: JSON.parse(data), invitation: invitation) }
    describe 'Nominal case' do
      before do
        get "/campaigns/#{campaign.id.to_s}/characters", {
          session_id: session_jacques.token,
          token: gateway.token,
          app_key: appli.key
        }
      end
      it 'Returns a 200 (OK) status code' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json([JSON.parse(data)])
      end
    end
    describe 'As a game master' do
      before do
        get "/campaigns/#{campaign.id.to_s}/characters", {
          session_id: session_didier.token,
          token: gateway.token,
          app_key: appli.key
        }
      end
      it 'Returns a 200 (OK) status code' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json([JSON.parse(data)])
      end
    end
  end
end