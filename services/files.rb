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

    def create(session, campaign, filename, content)
      create_bucket_if_not_exist('campaigns')
      invitation = campaign.invitations.where(account: session.account).first
      if !invitation.nil?
        file = Arkaan::Campaigns::File.create(filename: filename, invitation: invitation)
        if file.valid? && file.persisted?
          insert_in_bucket('campaigns', filename, content)
        end
      end
    end

    def load_buckets_config
      YAML.load_file(File.join(File.dirname(__FILE__), '..', 'config', 'buckets.yml'))
    end

    def get_file_content(bucket, filename)
      aws_client.get_object(bucket: bucket_name(bucket), key: filename).body.read.to_s
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

    def insert_in_bucket(name, filename, content)
      aws_client.put_object({
        bucket: bucket_name(name),
        key: filename,
        body: content['tempfile'].read.to_s
      })
    end
  end
end