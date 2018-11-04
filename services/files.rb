module Services
   # This service handles the deposit of files in amazon AWS and the creation of the files objects in campaigns.
   # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Files
    include Singleton

    attr_reader :aws_client

    attr_reader :buckets_config

    def initialize
      @aws_client = Aws::S3::Client.new
      @buckets_config = load_buckets_config
    end

    def create(session, campaign, parameters)
      create_bucket_if_not_exist('campaigns')
      invitation = campaign.invitations.where(account: session.account).first
      if !invitation.nil?
        file = Arkaan::Campaigns::File.create(
          name: parameters['name'],
          size: parameters['size'],
          mime_type: parameters['type'],
          invitation: invitation
        )
        if file.valid? && file.persisted?
          insert_campaign_file(campaign, parameters)
        end
        return file
      end
    end

    def list(campaign)
      files = []
      campaign.invitations.each do |invitation|
        invitation.files.each do |file|
          files << Decorators::File.new(file).to_h
        end
      end
      return files
    end

    def load_buckets_config
      YAML.load_file(File.join(File.dirname(__FILE__), '..', 'config', 'buckets.yml'))
    end

    def get_file_content(bucket, filename)
      aws_client.get_object(bucket: bucket_name(bucket), key: filename).body.read.to_s
    end

    def get_campaign_file(campaign, filename)
      aws_client.get_object(bucket: bucket_name('campaigns'), key: filename).body.read.to_s
    end

    def create_bucket_if_not_exist(name)
      begin
        aws_client.head_bucket(bucket: bucket_name(name))
      rescue
        aws_client.create_bucket(bucket: bucket_name(name))
      end
    end

    def bucket_name(name)
      return buckets_config[name][ENV['RACK_ENV']]
    end

    def insert_campaign_file(campaign, parameters)
      content = parameters['content'].split(',', 2).last
      aws_client.put_object({
        bucket: bucket_name('campaigns'),
        key: parameters['name'],
        body: Base64.decode64(content)
      })
    end
  end
end