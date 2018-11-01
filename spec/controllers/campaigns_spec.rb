RSpec.describe Controllers::Campaigns do

  before :each do
    DatabaseCleaner.clean
  end

  let!(:account) { create(:account) }
  let!(:gateway) { create(:gateway) }
  let!(:application) { create(:application, creator: account) }

  def app
    Controllers::Campaigns.new
  end

  include_examples 'GET /'

  include_examples 'GET /creations'

  include_examples 'GET /:id'

  include_examples'GET /:id/invitations'

  include_examples 'POST /'

  include_examples 'PUT /:id'

  include_examples 'DELETE /:id'

  include_examples 'GET /:id/messages'

  include_examples 'POST /:id/messages'

  include_examples 'POST /:id/commands'

  include_examples 'POST /:id/files'
end