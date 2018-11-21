module Services
   # This service handles the deposit of files in amazon AWS and the creation of the files objects in campaigns.
   # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Files
    include Singleton

    attr_reader :aws_client

    attr_reader :bucket

    def initialize
      @aws_client = Aws::S3::Client.new
      @bucket = ::Services::Bucket.instance
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

    def store(file, params)
      bucket.store(file.invitation.campaign, params['name'], params['content'])
      size = bucket.file_size(file.invitation.campaign, file.name)
      file.update_attribute(:size, size)
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
          raw_content = bucket.file_content(campaign, file.name)
          return "data:#{file.mime_type};base64,#{Base64.encode64(raw_content)}".strip
        end
      end
    end

    def campaign_file_exists?(campaign, filename)
      return bucket.file_exists?(campaign, filename)
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
        if !file.nil?
          file.delete
          bucket.delete_file(campaign, file.name)
        end
      end
    end

    def bucket_name(name)
      return buckets_config[name][ENV['RACK_ENV']]
    end

    def parse_mime_type(content)
      return content.split(';', 2).first.split(':', 2).last
    end
  end
end