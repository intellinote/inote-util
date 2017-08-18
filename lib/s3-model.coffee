# All the ways that the code base interacts with s3
# http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html
# This is to be used in the v2 api and in the image service
fs             = require 'fs'
path           = require 'path'
HOMEDIR        = path.join(__dirname)
LIB_COV        = path.join(HOMEDIR,'lib-cov')
LIB_DIR        = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR)
config         = require(path.join(LIB_DIR,'config')).config.init()
AWS            = require('aws-sdk')
default_folder = 'teamone-files-new'

class S3Model
  constructor:(@pool) ->

    AWS.config.credentials = config.get('s3')
    if not config.get 's3'
      console.log """WARNING: You did not set any credentials for s3 in your config, all S3 files and routes will fail. Also, make js-tests will fail.
        You need something like this in your config:

        "s3": =>
          "access_key_id":"xxxxxxxx",
          "secret_access_key": "xxxxxx/IHJ+c",
          "region":"us-east-1"
        }"""

    @s3 = new AWS.S3
      endpoint: 's3.amazonaws.com',
      signature_version: 'v4'

  create_folder: (folder_name, callback) =>
    folder_name = @_sanitize_folder_name folder_name
    data =
      Bucket: folder_name
    @s3.createBucket data, (err, response) ->
      callback err, response

  delete_folder: (folder_name, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name
    @s3.deleteBucket data, (err, response) ->
      callback err, response

  get_all_folders: (callback) =>
    @s3.listBuckets {}, (err, response) ->
      callback err, response

  folder_exists: (folder_name, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name
    @s3.getBucketLocation data, (err, response) ->
      callback err, not err and response?

  create_file: (folder_name, filename, file_type, body, callback) =>
    folder_name = @_sanitize_folder_name folder_name
    data =
      Bucket: folder_name
      Key: filename,
      Body: body,
      ContentType: file_type
    @create_folder folder_name, (err, created_folder) =>
      @s3.putObject data, (err, response) ->
        console.log err if err
        callback err, response

  get_file: (folder_name, filename, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name,
      Key: filename,
      Expires: config.get('s3:expires') or 86400 # Default is one day
    @s3.getSignedUrl 'getObject', data, (err, url) ->
      callback err, url

  get_meta_data: (folder_name, filename, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name,
      Key: filename
    @s3.headObject data, (err, response) ->
      callback err, response

  update_file: (folder_name, filename, file_type, body, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name,
      Key: filename
    @delete_file folder_name, filename, (err, deleted_file) =>
      @create_file folder_name, filename, file_type, body, (err, created_file) ->
        callback err, created_file

  delete_file: (folder_name, filename, callback) =>
    folder_name = @_sanitize_folder_name(folder_name)
    data =
      Bucket: folder_name,
      Key: filename
    @s3.deleteObject data, (err, response) ->
      callback err, response

  _sanitize_folder_name: (folder_name)->
    if not folder_name
      folder_name = default_folder
    return folder_name

exports.S3Model = S3Model
