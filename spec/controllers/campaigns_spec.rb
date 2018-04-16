RSpec.describe Controllers::Campaigns do

  before do
    DatabaseCleaner.clean
  end

  let!(:account) { create(:account) }
  let!(:gateway) { create(:gateway) }
  let!(:application) { create(:application, creator: account) }

  def app
    Controllers::Campaigns.new
  end

  include_examples 'GET /'

  include_examples 'GET /own'

  include_examples 'GET /:id'

  include_examples'GET /:id/invitations'

  include_examples 'POST /'

  include_examples 'PUT /:id'

  include_examples 'DELETE /:id'
end