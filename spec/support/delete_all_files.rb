class Services::Bucket
  # Removes all the files from a bucket. This method has been moved in
  # a support class so that it can't be used in the service by mistake.
  def remove_all
    objects = aws_client.list_objects(bucket: aws_bucket)[:contents]
    objects.each do |object|
      aws_client.delete_object(bucket: aws_bucket, key: object[:key])
    end
    aws_client.delete_bucket(bucket: aws_bucket)
  end
end