should   = require 'should'
fs       = require 'fs'
path     = require 'path'
HOMEDIR  = path.join(__dirname,'..')
LIB_COV  = path.join(HOMEDIR,'lib-cov')
LIB_DIR  = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
FileUtil = require(path.join(LIB_DIR,'file-util')).FileUtil

describe 'FileUtil',->

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
