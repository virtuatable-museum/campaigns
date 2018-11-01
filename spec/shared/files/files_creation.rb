RSpec.shared_examples 'POST /:id/files' do

  describe 'POST /:id/files' do

    let!(:campaign) { create(:campaign, creator: account, title: 'test_titre_files') }
    let!(:session) { create(:session, account: account) }
    let!(:attachment_name) { File.join(File.dirname(__FILE__), '..', '..', 'attachments', 'test.txt') }
    let!(:attachment) { Rack::Test::UploadedFile.new(attachment_name, "text/plain") }
    
    describe 'Nominal case' do
      before do
        post "/#{campaign.id.to_s}/files", {
          session_id: session.token,
          app_key: 'test_key',
          token: 'test_token',
          filename: 'file.txt',
          content: attachment
        }
      end
      it 'Returns a OK (200) status code' do
        expect(last_response.status).to be 200
      end
      it 'returns the correct body' do
        expect(last_response.body).to include_json({
          filename: 'file.txt'
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

        it 'has created a file with the correct filename' do
          expect(created_file.filename).to eq 'file.txt'
        end
      end
      describe 'AWS created file' do
        let(:content) { ::Services::Files.instance.get_file_content('campaigns', 'file.txt') }

        it 'has the correct content' do
          expect(content).to eq "Beaucoup\nde contenu"
        end
      end
    end

    it_behaves_like 'a route', 'post', '/campaign_id/files'

    describe '400 errors' do
      describe 'file content not given' do
        before do
          post "/#{campaign.id.to_s}/files", {session_id: session.token, app_key: 'test_key', token: 'test_token', filename: 'file.txt'}
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
      end
      describe 'filename not given' do
        before do
          post "/#{campaign.id.to_s}/files", {session_id: session.token, app_key: 'test_key', token: 'test_token', content: attachment}
        end
        it 'Returns a Bad request (400) status code' do
          expect(last_response.status).to be 400
        end
        it 'Returns the correct body' do
          expect(last_response.body).to include_json({
            status: 400,
            field: 'filename',
            error: 'required'
          })
        end
      end
    end
  end
end