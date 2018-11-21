RSpec.shared_examples 'POST /:id/files' do
  describe 'POST /:id/files' do

    let!(:file_service) { ::Services::Files.instance }
    let!(:bucket_service) { ::Services::Bucket.instance }

    before :each do
      bucket_service.create_bucket_if_not_exists
    end

    let!(:base_64_content) {'data:text/plain;base64,dGVzdApzYXV0IGRlIGxpZ25lIGV0IGVzcGFjZXM='}
    let!(:invalid_content) {'data:text/rtf;base64,dGVzdApzYXV0IGRlIGxpZ25lIGV0IGVzcGFjZXMK'}
    
    describe 'Nominal case' do
      before do
        post "/campaigns/#{campaign.id.to_s}/files", {
          session_id: session.token,
          app_key: 'test_key',
          token: 'test_token',
          name: 'test.txt',
          content: base_64_content
        }
      end
      it 'Returns a OK (200) status code' do
        expect(last_response.status).to be 200
      end
      it 'returns the correct body' do
        expect(last_response.body).to include_json({
          name: 'test.txt',
          type: 'text/plain'
        })
      end
      it 'has created a file in the corresponding invitation' do
        campaign.reload
        expect(campaign.invitations.first.files.count).to be 1
      end
      describe 'file parameters' do
        let!(:created_file) {
          campaign.reload
          campaign.invitations.first.files.first
        }

        it 'has created a file with the correct name' do
          expect(created_file.name).to eq 'test.txt'
        end
        it 'has created a file with the correct MIME type' do
          expect(created_file.mime_type).to eq 'text/plain'
        end
      end

      describe 'AWS created file' do
        let!(:file_id) { JSON.parse(last_response.body)['id'] }
        let(:content) { file_service.get_campaign_file(campaign, file_id) }

        it 'has the correct content' do
          expect(content).to eq base_64_content
        end
      end
    end

    it_behaves_like 'a route', 'post', '/campaign_id/files'

    describe :errors do

      before :all do
        ::Services::Bucket.instance.remove_all
      end

      describe '400 errors' do
        describe 'file content not given' do
          before do
            post "/campaigns/#{campaign.id.to_s}/files",{
              session_id: session.token,
              app_key: 'test_key',
              token: 'test_token',
              name: 'test.txt'
            }
          end
          it 'Returns a Bad request (400) status code' do
            expect(last_response.status).to be 400
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json({
              status: 400,
              field: 'content',
              error: 'required'
            })
          end
          it 'has not created the corresponding file' do
            expect(file_service.campaign_file_exists?(campaign, 'test.txt'))
          end
        end
        describe 'filename not given' do
          before do
            post "/campaigns/#{campaign.id.to_s}/files", {
              session_id: session.token,
              app_key: 'test_key',
              token: 'test_token',
              size: 30,
              content: base_64_content
            }
          end
          it 'Returns a Bad request (400) status code' do
            expect(last_response.status).to be 400
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json({
              status: 400,
              field: 'name',
              error: 'required'
            })
          end
          it 'has not created the corresponding file' do
            expect(file_service.campaign_file_exists?(campaign, 'test.txt'))
          end
        end
        describe 'invalid MIME type' do
          before do
            post "/campaigns/#{campaign.id.to_s}/files", {
              session_id: session.token,
              app_key: 'test_key',
              token: 'test_token',
              size: 30,
              name: 'test.txt',
              content: invalid_content
            }
          end
          it 'Returns a Bad request (400) status code' do
            expect(last_response.status).to be 400
          end
          it 'Returns the correct body' do
            expect(last_response.body).to include_json({
              status: 400,
              field: 'mime_type',
              error: 'pattern'
            })
          end
          it 'has not created the corresponding file' do
            expect(file_service.campaign_file_exists?(campaign, 'test.txt'))
          end
        end
      end

      describe '403 errors' do
        describe 'user not creator' do
          let!(:other_account) { create(:account, username: 'Babaussine', email: 'test@other.com') }
          let!(:invitation) { create(:accepted_invitation, campaign: campaign, account: other_account) }
          let!(:other_session) { create(:session, token: 'any_other_token', account: other_account) }

          before do
            post "/campaigns/#{campaign.id.to_s}/files", {
              session_id: other_session.token,
              app_key: 'test_key',
              token: 'test_token',
              name: 'test.txt',
              content: base_64_content
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
            expect(file_service.campaign_file_exists?(campaign, 'test.txt'))
          end
        end
      end
    end
  end
end