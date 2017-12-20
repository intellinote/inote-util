require 'coffee-errors'
#------------------------------------------------------------------------------#
fs        = require 'fs'
path      = require 'path'
HOME_DIR  = path.join(__dirname,'..')
LIB_COV   = path.join(HOME_DIR,'lib-cov')
LIB_DIR   = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOME_DIR,'lib')
S3Model   = require(path.join(LIB_DIR,'s3-model')).S3Model
assert    = require('assert')
config    = require(path.join(LIB_DIR,'config')).config.init()
S3_CONFIG = config.get("s3")

if not S3_CONFIG?
  console.warn """
    WARNING: S3 configuration not provided so S3Model tests will be skipped.
             Set:
               {s3:{access_key_id:"",secret_access_key:"",region:""}}
             in your configuration to avoid this warning.
  """

else

  s3 = undefined

  describe 'S3Model', () ->

    before (done) ->
      s3 = new S3Model(S3_CONFIG)
      s3.create_folder 'test_folder-7635364', (err, results) ->
        if err
          s3.delete_folder 'test_folder-7635364', (err, results) ->
            s3.create_folder 'test_folder-7635364', (err, results) ->
              done()
        else
          done()

    after (done) ->
      done()

    describe 'Folder Management', () ->

      it 'should create a folder', (done) ->
        s3.create_folder 'sample_folder', (err, results) ->
          assert.equal results.Location, '/sample_folder'
          done()

      it 'should list all folders', (done) ->
        s3.get_all_folders (err, results) ->
          bucket_names = results.Buckets.map (bucket) ->
            return bucket.Name
          assert bucket_names.includes 'sample_folder'
          done()

      it 'should check if a folder exists', (done) ->
        s3.folder_exists 'test_folder-7635364', (err, found_folder) ->
          assert.equal found_folder, true
          done()

      it 'should delete a folder', (done) ->
        s3.delete_folder 'sample_folder', (err, results) ->
          assert.deepEqual results, {}
          done()

    describe 'File Management', () ->

      it 'should create a file', (done) ->
        body = Buffer.from [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a]
        s3.create_file 'test_folder-7635364', 'testFile123', 'image/png', body, (err, created_file) ->
          assert created_file.ETag?
          done()

      it 'should create a file in a folder that does not exist and create that folder', (done) ->
        folder_name = 'magically-created-folder-323'
        filename = 'testFile123'
        body = Buffer.from [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a]
        contentType = 'image/png'
        s3.create_file folder_name, filename, contentType, body, (err, created_file) ->
          assert created_file.ETag?
          s3.folder_exists folder_name, (err, found_folder) ->
            assert found_folder
            done()

      it 'should create a file in the default folder and then find it', (done) ->
        body = Buffer.from [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a]
        s3.create_file 'my_folder', 'fake_file.png', 'image/png', body, (err, created_file) ->
          assert created_file.ETag
          s3.get_file null, 'fake_file.png', (err, found_file) ->
            assert found_file.match(/.*Expires.*/).length > 0
            assert found_file.match(/https:\/\/.*s3\.amazonaws\.com.*\/fake_file\.png.*/).length > 0
            done()

      it 'should get the file', (done) ->
        s3.get_file 'test_folder-7635364', 'testFile123', (err, found_file) ->
          assert found_file.match(/.*Expires.*/)
          done()

      it 'should delete a file', (done) ->
        s3.delete_file 'test_folder-7635364', 'testFile123', (err, deleted_file) ->
          assert deleted_file, {}
          done()
