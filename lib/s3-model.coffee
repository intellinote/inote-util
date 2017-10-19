AWS                    = require('aws-sdk')
DEFAULT_DEFAULT_FOLDER = 'default-folder'

# Interacts with AWS S3.
# See http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html
class S3Model

  # `config` should be set in the project that is calling this library. It should look like the following:
  # "s3": {
  #  "expires": "84600",
  #  "accessKeyId": "",
  #  "secretAccessKey": "",
  #  "region": "us-east-1",
  #  "defaultFolder": "teamone-files-new"
  # },
  constructor:(config)->
    config ?= {}
    @default_folder = config.default_folder ? "default-folder"
    if config.credentials?
      AWS.config.credentials = config.credentials
    else if config.accessKeyId?
      AWS.config.credentials = config
    unless AWS.config.credentials?
      console.warn "WARNING: S3Model created but no AWS credentials have been set. You may want to pass `{access_key_id:, secret_access_key:, region: }` to the S3Model constructor."
    @s3 = new AWS.S3
      endpoint: 's3.amazonaws.com',
      signature_version: 'v4'

  # callback:(err, aws_response)
  create_folder: (folder_name, callback) =>
    folder_name = @_sanitize_folder_name folder_name
    data =
      Bucket: folder_name
    @s3.createBucket data, (err, response) ->
      callback err, response

  # callback:(err, aws_response)
  delete_folder: (folder_name, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name
    @s3.deleteBucket data, (err, response) ->
      callback err, response

  # callback:(err, aws_response)
  get_all_folders: (callback) =>
    @s3.listBuckets {}, (err, response) ->
      callback err, response

  # callback:(err, folder_exists)
  folder_exists: (folder_name, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name
    @s3.getBucketLocation data, (err, response) ->
      callback err, not err and response?

  # callback:(err, aws_response)
  create_file: (folder_name, filename, file_type, body, callback) =>
    folder_name = @_sanitize_folder_name folder_name
    data =
      Bucket: folder_name
      Key: filename,
      Body: body,
      ContentType: file_type
    @create_folder folder_name, (err, created_folder) =>
      @s3.putObject data, (err, response) ->
        callback err, response

  # callback:(err, url)
  get_file: (folder_name, filename, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name,
      Key: filename,
      Expires: 86400 # Default is one day - TODO: should probably make this configurable
    @s3.getSignedUrl 'getObject', data, (err, url) ->
      callback err, url

  # callback:(err, aws_response)
  get_meta_data: (folder_name, filename, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name,
      Key: filename
    @s3.headObject data, (err, response) ->
      callback err, response

  # callback:(err, aws_response)
  update_file: (folder_name, filename, file_type, body, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name,
      Key: filename
    @delete_file folder_name, filename, (err, deleted_file) => # TODO - are we sure we want to ignore errors here?
      @create_file folder_name, filename, file_type, body, (err, created_file) ->
        callback err, created_file

  # callback:(err, aws_response)
  delete_file: (folder_name, filename, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name,
      Key: filename
    @s3.deleteObject data, (err, response) ->
      callback err, response

  # returns a valid folder name (defaulting to `@default_folder` when `null`)
  _sanitize_folder_name: (folder_name)->
    return folder_name ? @default_folder

exports.S3Model = S3Model
