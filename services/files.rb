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
      invitation = campaign.invitations.where(account: session.account).first
      mime_type = parse_mime_type(parameters['content'])
      return Arkaan::Campaigns::File.new(
        name: parameters['name'],
        mime_type: mime_type,
        invitation: invitation
      )
    end

    def store(campaign, file, parameters)
      create_bucket_if_not_exist('campaigns')
      insert_campaign_file(campaign, parameters)
      object = aws_client.get_object({
        bucket: bucket_name('campaigns'),
        key: "#{campaign.id.to_s}/#{parameters['name']}"
      })
      file.update_attribute(:size, object.to_h[:content_length])
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

    def get_campaign_file(campaign, file_id)
      campaign.invitations.each do |invitation|
        invitation.reload
        file = invitation.files.where(id: file_id).first
        if !file.nil?
          key = "#{campaign.id.to_s}/#{file.name}"
          raw_content = aws_client.get_object(bucket: bucket_name('campaigns'), key: key).body.read.to_s
          return "data:#{file.mime_type};base64,#{Base64.encode64(raw_content)}".strip
        end
      end
    end

    def empty_bucket(name)
      objects = aws_client.list_objects(bucket: bucket_name(name))[:contents]
      objects.each do |object|
        aws_client.delete_object(bucket: bucket_name(name), key: object[:key])
      end
      aws_client.delete_bucket(bucket: bucket_name(name))
    end

    def campaign_file_exists?(campaign, filename)
      Aws::S3::Client.new.get_object(bucket: bucket_name('campaigns'), key: "#{campaign.id.to_s}/#{filename}")
      return true
    rescue StandardError => exception
      return false
    end

    def campaign_has_file?(campaign, file_id)
      campaign.invitations.each do |invitation|
        file = invitation.files.where(id: file_id).first
        return true if !file.nil?
      end
      return false
    end

    def delete_campaign_file(campaign, file_id)
      campaign.invitations.each do |invitation|
        file = invitation.files.where(id: file_id).first
        file.delete if !file.nil?
      end
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
        key: "#{campaign.id.to_s}/#{parameters['name']}",
        body: Base64.decode64(content)
      })
    end

    def parse_mime_type(content)
      return content.split(';', 2).first.split(':', 2).last
    end
  end
end