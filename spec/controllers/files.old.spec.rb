RSpec.describe Controllers::Files do

  before(:each) { DatabaseCleaner.clean }

  let!(:account) { create(:account) }
  let!(:gateway) { create(:gateway) }
  let!(:appli) { create(:application, creator: account) }
  let!(:session) { create(:session, account: account) }

  def app; Controllers::Files.new; end

  after :all do
    Services::Bucket.instance.remove_all
  end

  # I deactivated the tests about files because they are supposed to be moved to a dedicated service
  # in the future and I don't want then to be here anymore.

  # rspec spec/controllers/files_spec.rb[1:1]
  # include_examples 'POST /:id/files'

  # rspec spec/controllers/files_spec.rb[1:2]
  # include_examples 'DELETE /:id/files/:file_id'

  # rspec spec/controllers/files_spec.rb[1:3]
  # include_examples 'PUT /:id/files/:file_id'

  # rspec spec/controllers/files_spec.rb[1:4]
  # include_examples 'GET /:id/files'

  # rspec spec/controllers/files_spec.rb[1:5]
  # include_examples 'GET /:id/files/:file_id'
end