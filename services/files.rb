# frozen_string_literal: true

module Services
  # This service handles the deposit of files in amazon AWS and the creation of
  # the files objects in campaigns.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Files
    include Singleton

    # @!attribute [r] bucket
    #   @return [Services::Bucket] the service to make direct actions
    #     on the campaigns bucket.
    attr_reader :bucket

    def initialize
      @bucket = ::Services::Bucket.instance
    end

    # Creates the file and stores it in the AWS bucket but does NOT
    # persist it in the database.
    #
    # @param session [Arkaan::Authentication::Session] the session of the
    #   account creating the file.
    # @param campaign [Arkaan::campaign] the campaign the file
    #   will be created in.
    # @param name [String] the name of the file to store.
    # @param content [String] the base64 content of the file to store.
    # @return [Arkaan::Campaigns::Files::Document] the created file in the database,
    #   not yet persisted (but the upload has succeeded).
    def create(session, campaign, name, content)
      invitation = campaign.invitations.where(account: session.account).first
      file = Arkaan::Campaigns::Files::Document.new(
        name: name,
        mime_type: parse_mime_type(content),
        creator: invitation
      )
      return file unless file.valid?
      raise file_creation_error unless store(file, content)

      file
    end

    # Stores a file, already persisted in the database, on amazon S3.
    # @param file [Arkaan::Campaigns::Files::Document] the file with the informations to store on AWS.
    # @param content [String] the text representation of the content of the file.
    def store(file, content)
      bucket.store(file.campaign, file.name, content)
      size = bucket.file_size(file.campaign, file.name)
      file.update_attribute(:size, size)
    end

    # List the files for a campaign by aggregating the files of the different invitations.
    # @param campaign [Arkaan::Campaign] the campaign to obtain the files from.
    # @return [Array<Hash>] a list of decorated files represented as hashes.
    def list(campaign, session)
      params = { account_id: session.account.id }
      invitation = campaign.invitations.where(params).first
      files = get_authorized_files(campaign, invitation)
      Decorators::File.decorate_collection(files).map(&:to_h)
    end

    # Returns the text representation of the file identified by this ID.
    # @param campaign [Arkaan::Campaign] the campaign the file is in.
    # @param file_id [String] the unique identifier of the file.
    # @return [String, NilClass] the string representation of the file, or nil if the file does not exist in the database.
    def get_campaign_file(campaign, file_id)
      file = campaign.files.where(id: file_id).first
      return if file.nil?

      raw_content = bucket.file_content(campaign, file.name)
      "data:#{file.mime_type};base64,#{Base64.encode64(raw_content)}".strip
    end

    # Checks if the campaign has a file with the given unique identifier.
    # @param campaign [Arkaan::Campaign] the campaign the files is supposed to be in.
    # @param file_id [String] the unique identifier of the string to check the existence.
    def campaign_has_file?(campaign, file_id)
      !campaign.files.where(id: file_id).first.nil?
    end

    # Searches for a file in the given campaign with the given identifier, then deletes it, and deletes it from AWS.
    # @param campaign [Arkaan::Campaign] the campaign the file you want to delete is in.
    # @param file_id [String] the unique identifier for the file.
    def delete_campaign_file(campaign, file_id)
      file = campaign.files.where(id: file_id).first
      return if file.nil?

      file.delete
      bucket.delete_file(campaign, file.name)
    end

    # Parses the MIME type from the file content given with a format : data:<mime_type>;base64,<content>
    # @param content [String] the string representation of the content of the file.
    # @return [String] the MIME type of the file (eq: "plain/text").
    def parse_mime_type(content)
      content.split(';', 2).first.split(':', 2).last
    end

    # Updates the permissions on a file, this is done in two steps :
    # 1. Remove the permissions that are not given in the update permissions parameters
    # 2. Add the permissions that does not already exist in the file but are given in the hash.
    #
    # @param file [Arkaan::Campaigns::Files::Document] the file to update the permissions of.
    # @param permissions [Array<Hash>] an array of permissions,
    #   each permission is a hash responding to :invitation and :level.
    def update_permissions(file, permissions)
      permissions = Services::Permissions.instance.parse(permissions)
      remove_permissions(file, permissions)
      insert_permissions(file, permissions)
    end

    # Removes the permissions of the file that are NOT contained in the permissions list.
    # @param file [Arkaan::Campaigns::Files::Document] the file to remove the permissions from
    # @param permissions [Array<Hash>] an array of permissions to check the existence in the file.
    def remove_permissions(file, permissions)
      file.permissions.where(:enum_level.ne => :creator).each do |tmp_perm|
        still_existing = permissions.select do |p|
          p.invitation.id == tmp_perm.invitation.id
        end
        tmp_perm.delete if still_existing.count.zero?
      end
    end

    # Inserts the permissions from the array if not exist in the file, or increment it.
    # @param file [Arkaan::Campaigns::Files::Document] the file to increment the permissions from.
    # @param permissions [Array<Hash>] the permissions to add in the file.
    def insert_permissions(file, permissions)
      permissions.each do |tmp_perm|
        existing = file.permissions.where(
          invitation_id: tmp_perm[:invitation].id
        ).first
        if existing.nil?
          create_from_hash(file, tmp_perm)
        else
          existing.update_attribute(:level, tmp_perm[:level])
        end
      end
    end

    # Gets a file by its unique identifier.
    # @param file_id [String] the unique identifier of the file
    # @return [Arkaan::Campaigns::Files::Document] the file object returned by the ORM
    def get(file_id)
      Arkaan::Campaigns::Files::Document.where(id: file_id).first
    end

    private

    def create_from_hash(file, perm_hash)
      Arkaan::Campaigns::Files::Permission.create(
        file: file,
        invitation: perm_hash[:invitation],
        enum_level: perm_hash[:level]
      )
    end

    def file_creation_error
      Arkaan::Utils::Errors.new(
        action: 'files_creation',
        field: 'upload',
        error: 'failed'
      )
    end

    def get_authorized_files(campaign, invitation)
      campaign.files.to_a.reject do |file|
        params = { invitation_id: invitation.id }
        file.permissions.where(params).first.nil?
      end
    end
  end
end
