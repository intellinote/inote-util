should   = require 'should'
fs       = require 'fs'
path     = require 'path'
HOMEDIR  = path.join(__dirname,'..')
LIB_COV  = path.join(HOMEDIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
FileUtil = require(path.join(LIB_DIR,'index')).FileUtil
AsyncUtil = require(path.join(LIB_DIR,'index')).AsyncUtil
TEST_FS  = path.join HOMEDIR, "test", "data", "test-fs"

describe 'FileUtil',->

  it "can determine the age of a file", (done)->
    FileUtil.file_age path.join(HOMEDIR, "package.json"), (err, age1)->
      should.not.exist err
      AsyncUtil.set_timeout 500, ()->
        FileUtil.file_age path.join(HOMEDIR, "package.json"), (err, age2)->
          should.not.exist err
          (age2 - age1).should.be.above(499)
          (age2 - age1).should.be.below(600)
          AsyncUtil.set_timeout 600, ()->
            FileUtil.file_age path.join(HOMEDIR, "package.json"), (err, age3)->
              should.not.exist err
              (age3 - age2).should.be.above(599)
              (age3 - age2).should.be.below(700)
              done()

  it "can test if a file is a plain file", (done)->
    FileUtil.is_file "xyzzy.i.do.not.exist", (err, is_file)->
      should.not.exist err
      is_file.should.equal false
      FileUtil.is_file LIB_DIR, (err, is_file)->
        should.not.exist err
        is_file.should.equal false
        FileUtil.is_file path.join(HOMEDIR,"package.json"), (err, is_file)->
          should.not.exist err
          is_file.should.equal true
          done()

  it "can test if a file is a directory", (done)->
    FileUtil.is_directory "xyzzy.i.do.not.exist", (err, is_dir)->
      should.not.exist err
      is_dir.should.equal false
      FileUtil.is_directory LIB_DIR, (err, is_dir)->
        should.not.exist err
        is_dir.should.equal true
        FileUtil.is_directory path.join(HOMEDIR,"package.json"), (err, is_dir)->
          should.not.exist err
          is_dir.should.equal false
          done()

  it "can list the files and directories in a directory", (done)->
    FileUtil.ls TEST_FS, (err, files)=>
      should.not.exist err
      should.exist files
      files.length.should.equal 5
      basenames = files.map (x)->path.basename(x)
      for f in ["dir-one","dir-two","file-one.txt", "file-two.xyz", "file-three.txt"]
        (f in basenames).should.equal true
      done()

  it "can list the files and directories in a directory (explicit types)", (done)->
    FileUtil.ls TEST_FS, types:['file','directory'], (err, files)=>
      should.not.exist err
      should.exist files
      files.length.should.equal 5
      basenames = files.map (x)->path.basename(x)
      for f in ["dir-one","dir-two","file-one.txt", "file-two.xyz", "file-three.txt"]
        (f in basenames).should.equal true
      done()

  it "can recursively list the files and directories in a directory", (done)->
    FileUtil.ls TEST_FS, {recurse:true}, (err, files)=>
      should.not.exist err
      should.exist files
      files.length.should.equal 10
      basenames = files.map (x)->path.basename(x)
      for f in ["dir-one","dir-two","file-one.txt", "file-two.xyz", "file-three.txt","file-one-a.txt","file-one-b.txt","file-one-c.xyz","file-two-a.xyz","file-two-b.txt"]
        (f in basenames).should.equal true
      done()

  it "can recursively list the files and directories matching a given pattern in a directory", (done)->
    FileUtil.ls TEST_FS, {recurse:true,pattern:/one/}, (err, files)=>
      should.not.exist err
      should.exist files
      files.length.should.equal 5
      basenames = files.map (x)->path.basename(x)
      for f in ["dir-one","file-one.txt","file-one-a.txt","file-one-b.txt","file-one-c.xyz"]
        (f in basenames).should.equal true
      done()

  it "can recursively list the files matching a given pattern in a directory", (done)->
    FileUtil.ls TEST_FS, {recurse:true,pattern:/\.xyz$/,type:'file'}, (err, files)=>
      should.not.exist err
      should.exist files
      files.length.should.equal 3
      basenames = files.map (x)->path.basename(x)
      for f in ["file-two.xyz","file-one-c.xyz","file-two-a.xyz"]
        (f in basenames).should.equal true
      done()

  it "can list the files in a directory", (done)->
    FileUtil.ls TEST_FS, type:'file', (err, files)=>
      should.not.exist err
      should.exist files
      files.length.should.equal 3
      basenames = files.map (x)->path.basename(x)
      for f in ["file-one.txt", "file-two.xyz", "file-three.txt"]
        (f in basenames).should.equal true
      done()

  it "can list the directories in a directory", (done)->
    FileUtil.ls TEST_FS, types:'dir', (err, files)=>
      should.not.exist err
      should.exist files
      files.length.should.equal 2
      basenames = files.map (x)->path.basename(x)
      for f in ["dir-one", "dir-two" ]
        (f in basenames).should.equal true
      done()

  it "can sanitize filenames",(done)->
    tests = [
      ["Foo.txt","Foo.txt"]
      ["/home/rod/test/dir/Foo.txt","/home/rod/test/dir/Foo.txt"]
      ["Foo Bar.txt","Foo-Bar.txt"]
      ["/home/rod w/test dir/Foo Bar.txt","/home/rod w/test dir/Foo-Bar.txt"]
      ["xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz.txt","xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz.txt"]
      ["~!@#$%^&*()+=1.2.3.4.5.6.7.8.9.txt","-------------1-2-3-4-5-6-7-8-9.txt"]
    ]
    for test in tests
      FileUtil.sanitize_filename(test[0]).should.equal test[1]
    done()

  it "can uniquify filenames",(done)->
    tests = [
      [[HOMEDIR,"package",".json"],"package-001.json"]
      [[HOMEDIR,"package",".json",2],"package-01.json"]
      [[HOMEDIR,"package",".json",1],"package-1.json"]
      [[HOMEDIR,"package",".json",10],"package-0000000001.json"]
      [[HOMEDIR,"xyzzy",".txt"],"xyzzy.txt"]
    ]
    for test in tests
      FileUtil.uniquify_filename(test[0]...).should.equal test[1]
    done()

  it "can make and remove directories",(done)->
    (FileUtil.mkdir(path.join(HOMEDIR,"foo","bar","gamma","another"))).should.be.ok
    fs.existsSync(path.join(HOMEDIR,"foo","bar","gamma","another")).should.be.ok
    fs.closeSync(fs.openSync(path.join(HOMEDIR,"foo","bar","gamma","another","some-file"), 'w'))
    fs.existsSync(path.join(HOMEDIR,"foo","bar","gamma","another","some-file")).should.be.ok
    (FileUtil.rmdir(path.join(HOMEDIR,"foo","bar","gamma","another"),path.join(HOMEDIR,"foo","bar","gamma"),path.join(HOMEDIR,"foo","bar","i-do-not-exist"))).should.not.be.ok
    fs.existsSync(path.join(HOMEDIR,"foo","bar","gamma","another")).should.not.be.ok
    fs.existsSync(path.join(HOMEDIR,"foo","bar","gamma")).should.not.be.ok
    fs.existsSync(path.join(HOMEDIR,"foo","bar")).should.be.ok
    fs.closeSync(fs.openSync(path.join(HOMEDIR,"foo","bar","some-file"), 'w'))
    fs.existsSync(path.join(HOMEDIR,"foo","bar","some-file")).should.be.ok
    (FileUtil.rm(path.join(HOMEDIR,"foo","bar","some-file"))).should.be.ok
    fs.existsSync(path.join(HOMEDIR,"foo","bar","some-file")).should.not.be.ok
    fs.existsSync(path.join(HOMEDIR,"foo")).should.be.ok
    (FileUtil.rmdir(path.join(HOMEDIR,"foo"))).should.be.ok
    fs.existsSync(path.join(HOMEDIR,"foo")).should.not.be.ok
    done()

  it "can change file extensions",(done)->
    tests = [
      [ "foo.foo", ".bar", "foo.bar" ]
      [ "foo.foo", "bar", "foo.bar" ]
      [ "foo.foo.foo", "bar", "foo.foo.bar" ]
      [ "foo.foo.foo", "bar.bar", "foo.foo.bar.bar" ]
      [ "/foo/bar.xxx/file.ext", ".txt", "/foo/bar.xxx/file.txt" ]
      [ "/foo/bar.xxx/file.ext", "txt", "/foo/bar.xxx/file.txt" ]
    ]
    for test in tests
      FileUtil.replace_extension(test[0],test[1]).should.equal test[2]
    done()

  it "can strip file extensions",(done)->
    tests = [
      [ "foo.foo", "foo" ]
      [ "foo.foo.foo", "foo.foo" ]
      [ "/foo/bar.xxx/file.ext", "/foo/bar.xxx/file" ]
      [ "/foo/bar.xxx/file", "/foo/bar.xxx/file" ]
      [ "/foo/bar.xxx-file", "/foo/bar" ]
    ]
    for test in tests
      FileUtil.strip_extension(test[0]).should.equal test[1]
    done()

  it "can test the MIME type of a file", (done)->
    FileUtil.get_file_mime_type path.join(HOMEDIR, "package.json"), (err, type)->
      should.not.exist err
      console.log type
      done()
