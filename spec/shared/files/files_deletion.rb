RSpec.shared_examples 'DELETE /:id/files/:file_id' do
  describe 'DELETE /:id/files/:file_id' do

    let!(:base_64_content) {'data:text/plain;base64,dGVzdApzYXV0IGRlIGxpZ25lIGV0IGVzcGFjZXMK'}

    describe 'Nominal case' do
      before :each do
        # First we have to create the file before deleting it.
        post "/campaigns/#{campaign.id.to_s}/files", {
          session_id: session.token,
          app_key: 'test_key',
          token: 'test_token',
          name: 'test.txt',
          content: base_64_content
        }
        file_id = JSON.parse(last_response.body)['id']
        delete "/campaigns/#{campaign.id.to_s}/files/#{file_id}", {
          session_id: session.token,
          app_key: 'test_key',
          token: 'test_token'
        }
        campaign.reload
      end
      it 'Returns a OK (200) status code' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body' do
        expect(last_response.body).to include_json({message: 'deleted'})
      end
      it 'Has deleted the file in the database' do
        expect(campaign.invitations.first.files.count).to be 0
      end
      it 'Has deleted the file on AWS' do
        expect(::Services::Files.instance.campaign_file_exists?(campaign, 'test.txt')).to be false
      end
    end

    it_behaves_like 'a route', 'delete', '/campaign_id/files/file_id'

    describe 'Errors' do
      describe '404 errors' do
        describe 'When the file is not found' do
          before do
            delete "/campaigns/#{campaign.id.to_s}/files/unknown_file", {
              session_id: session.token,
              app_key: 'test_key',
              token: 'test_token'
            }
          end
          it 'Returns a Not Found (404) status code' do
            expect(last_response.status).to be 404
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json({
              status: 404,
              field: 'file_id',
              error: 'unknown'
            })
          end
        end
      end

      describe '403 errors' do
        describe 'user not creator' do
          let!(:other_account) { create(:account, username: 'Babaussine', email: 'test@other.com') }
          let!(:invitation) { create(:accepted_invitation, campaign: campaign, account: other_account) }
          let!(:other_session) { create(:session, token: 'any_other_token', account: other_account) }

          before do
            # First we have to create the file before deleting it.
            post "/campaigns/#{campaign.id.to_s}/files", {
              session_id: session.token,
              app_key: 'test_key',
              token: 'test_token',
              name: 'test.txt',
              content: base_64_content
            }
            file_id = JSON.parse(last_response.body)['id']
            delete "/campaigns/#{campaign.id.to_s}/files/#{file_id}", {
              session_id: other_session.token,
              app_key: 'test_key',
              token: 'test_token'
            }
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
          it 'has not created the corresponding file' do
            expect(::Services::Files.instance.campaign_file_exists?(campaign, 'test.txt'))
          end
        end
      end
    end
  end
end