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

  # rspec spec/controllers/campaigns_spec.rb[1:1]
  include_examples 'GET /'

  # rspec spec/controllers/campaigns_spec.rb[1:2]
  include_examples 'GET /creations'

  # rspec spec/controllers/campaigns_spec.rb[1:3]
  include_examples 'GET /:id'

  # rspec spec/controllers/campaigns_spec.rb[1:4]
  include_examples'GET /:id/invitations'

  # rspec spec/controllers/campaigns_spec.rb[1:5]
  include_examples 'POST /'

  # rspec spec/controllers/campaigns_spec.rb[1:6]
  include_examples 'PUT /:id'

  # rspec spec/controllers/campaigns_spec.rb[1:7]
  include_examples 'DELETE /:id'

  # rspec spec/controllers/campaigns_spec.rb[1:8]
  include_examples 'GET /:id/messages'

  # rspec spec/controllers/campaigns_spec.rb[1:9]
  include_examples 'POST /:id/messages'

  # rspec spec/controllers/campaigns_spec.rb[1:10]
  include_examples 'POST /:id/commands'
end