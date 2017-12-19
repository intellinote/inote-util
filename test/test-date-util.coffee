require 'coffee-errors'
#------------------------------------------------------------------------------#
should  = require 'should'
fs      = require 'fs'
path    = require 'path'
HOMEDIR = path.join(__dirname,'..')
LIB_COV = path.join(HOMEDIR,'lib-cov')
LIB_DIR = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
DateUtil    = require(path.join(LIB_DIR,'util')).DateUtil


describe 'DateUtil',->

  it "can format dates",(done)->
    DateUtil.format_datetime_long(new Date(1427304533478)).should.equal "Wednesday 25 March 2015 at 5:28 PM GMT"
    done()

  it "duration accepts times as Dates or millis",(done)->
    now = new Date()
    later = new Date(now.getTime() + 6*60*60*1000 + 2*60*1000 + 3*1000 + 123)
    DateUtil.duration(later,now).string.brief.short.should.equal "6h 2m 3s 123m"
    DateUtil.duration(later.getTime(),now).string.brief.short.should.equal "6h 2m 3s 123m"
    DateUtil.duration(later,now.getTime()).string.brief.short.should.equal "6h 2m 3s 123m"
    DateUtil.duration(later.getTime(),now.getTime()).string.brief.short.should.equal "6h 2m 3s 123m"
    done()

  it "duration can parse a duration in various human-readable forms",(done)->
    tests = [
      [ 123, "123m" ]
      [ 3*1000 + 123, "3s 123m" ]
      [ 2*60*1000 + 3*1000 + 123, "2m 3s 123m" ]
      [ 6*60*60*1000 + 2*60*1000 + 3*1000 + 123, "6h 2m 3s 123m" ]
      [ 5*24*60*60*1000 + 6*60*60*1000 + 2*60*1000 + 3*1000 + 123, "5d 6h 2m 3s 123m" ]
      [ 3*7*24*60*60*1000 + 5*24*60*60*1000 + 6*60*60*1000 + 2*60*1000 + 3*1000 + 123, "3w 5d 6h 2m 3s 123m" ]
      [ 9*52*7*24*60*60*1000 + 3*7*24*60*60*1000 + 5*24*60*60*1000 + 6*60*60*1000 + 2*60*1000 + 3*1000 + 123, "9y 3w 5d 6h 2m 3s 123m" ]
    ]
    for test in tests
      found = DateUtil.duration(test[0],0)
      found.string.brief.short.should.equal test[1]
    tests = [
      [ 123, "123 milliseconds" ]
      [ 3*1000, "3 seconds" ]
      [ 1*60*1000, "1 minute" ]
      [ 6*60*60*1000, "6 hours" ]
      [ 5*24*60*60*1000, "5 days" ]
      [ 3*7*24*60*60*1000, "3 weeks" ]
      [ 9*52*7*24*60*60*1000, "9 years" ]
    ]
    for test in tests
      found = DateUtil.duration(test[0],0)
      found.string.min.long.should.equal test[1]
    done()

  it "can match ISO8601 dates",(done)->
    DateUtil.iso_8601_regexp().test((new Date()).toISOString()).should.be.ok
    matches = "2014-12-17T23:55:22.192Z".match DateUtil.iso_8601_regexp()
    matches[0].should.equal "2014-12-17T23:55:22.192Z" # full string
    matches[1].should.equal "2014-12-17"               # full date
    matches[2].should.equal "2014"                     # year
    matches[3].should.equal "12"                       # month
    matches[4].should.equal "17"                       # day
    matches[5].should.equal "23:55:22.192Z"            # full time
    matches[6].should.equal "23"                       # hours
    matches[7].should.equal "55"                       # minutes
    matches[8].should.equal "22.192"                   # seconds.millis
    matches[9].should.equal "22"                       # seconds (no millis)
    matches[10].should.equal "192"                     # milliseconds
    matches[11].should.equal "Z"                       # timezone
    done()
