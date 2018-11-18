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

  # rspec spec/controllers/campaigns_spec.rb[1:8]
  include_examples 'GET /:id/messages'

  # rspec spec/controllers/campaigns_spec.rb[1:9]
  include_examples 'POST /:id/messages'

  # rspec spec/controllers/campaigns_spec.rb[1:10]
  include_examples 'POST /:id/commands'
end