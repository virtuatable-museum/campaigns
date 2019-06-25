# frozen_string_literal: true

module Services
  # This class represents the bucket containing all the campaigns.
  # @param Vincent Courtois <courtois.vincent@outlook.com>
  class Bucket
    include Singleton

    # @!attribute [r] aws_client
    #   @return [Aws::S3::Client] the link to the Amazon S3 API.
    attr_reader :aws_client
    # @!attribute [r] aws_bucket
    #   @return [Aws::S3::Bucket] the representation of the Amazon S3
    #     bucket for the campaigns.
    attr_reader :aws_bucket
    # @!attribute [r] logger
    #   @return [Logger] the logger displaying messages in the console.
    attr_reader :logger

    def initialize
      @aws_client = Aws::S3::Client.new
      @aws_bucket = load_buckets_config['campaigns'][ENV['RACK_ENV']]

      @logger = Logger.new(STDOUT)
      create_bucket_if_not_exists
    end

    # Creates the bucket if it does not exist (then the HEAD request fails).
    def create_bucket_if_not_exists
      aws_client.head_bucket(bucket: aws_bucket)
    rescue StandardError
      aws_client.create_bucket(bucket: aws_bucket)
    end

    # Stores the given file in the bucket for this campaign.
    # @param filename [String] the name of the file you want to store on AWS.
    # @param content [String] the text content of the file.
    def store(campaign, filename, content)
      aws_client.put_object(
        bucket: aws_bucket,
        key: "#{campaign.id}/#{filename}",
        body: Base64.decode64(content.split(',', 2).last)
      )
    end

    # Gets the informations about a file given its filename.
    # @param campaign [Arkaan::Campaign] the campaign the file
    #   is supposed to be in.
    # @param filename [String] the name of the file,
    #   with its extension (eg "file.txt")
    def file_infos(campaign, filename)
      aws_client.get_object(
        bucket: aws_bucket,
        key: "#{campaign.id}/#{filename}"
      )
    end

    # Gets the size of the file in bytes.
    # @param campaign [Arkaan::Campaign] the campaign the file
    #   is supposed to be in.
    # @param filename [String] the name of the file you're
    #   looking for the size.
    # @return [Integer] the size of the file desired, or zero
    #   if the file is not found.
    def file_size(campaign, filename)
      file_infos(campaign, filename).to_h[:content_length].to_i
    rescue StandardError
      0
    end

    # Gets the text content of a file.
    # @param campaign [Arkaan::Campaign] the campaign the file
    #   is supposed to be in.
    # @param filename [String] the name of the file you're looking for.
    # @return [Integer] the raw text content of the file,
    #   not yet encoded in base64.
    def file_content(campaign, filename)
      file_infos(campaign, filename).body.read.to_s
    end

    # Checks if a file exists in the given campaign.
    # @param campaign [Arkaan::Campaign] the campaign the file
    #   is supposed to be in.
    # @param filename [String] the name of the file you're looking for.
    # @return [Boolean] TRUE if the file exists, FALSE otherwise.
    def file_exists?(campaign, filename)
      parameters = { bucket: aws_bucket, key: "#{campaign.id}/#{filename}" }
      Aws::S3::Client.new.get_object(parameters) != false
    rescue StandardError
      false
    end

    # Deletes the file if it exists in the bucket.
    # @param campaign [Arkaan::Campaign] the campaign the file
    #   is supposed to be in.
    # @param filename [String] the name of the file you're looking to destroy.
    def delete_file(campaign, filename)
      if file_exists?(campaign, filename)
        aws_client.delete_object(
          bucket: aws_bucket,
          key: "#{campaign.id}/#{filename}"
        )
      end
    end

    def load_buckets_config
      dir = File.dirname(__FILE__)
      YAML.load_file(File.join(dir, '..', 'config', 'buckets.yml'))
    end
  end
end
