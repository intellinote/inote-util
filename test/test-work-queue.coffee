require 'coffee-errors'
#------------------------------------------------------------------------------#
should    = require 'should'
fs        = require 'fs'
path      = require 'path'
HOMEDIR   = path.join __dirname, '..'
LIB_COV   = path.join HOMEDIR, 'lib-cov'
LIB       = path.join HOMEDIR, 'lib'
LIB_DIR   = if fs.existsSync(LIB_COV) then LIB_COV else LIB
WorkQueue = require(path.join(LIB_DIR,'work-queue')).WorkQueue
AsyncUtil = require(path.join(LIB_DIR,'index')).AsyncUtil

describe "WorkQueue",->

  it "processes tasks", (done)->
    action_count = 0
    foos = []
    bars = []
    wq = new WorkQueue()
    action = (foo,bar,cb)=>
      wq.pending_task_count().should.equal 0
      wq.active_task_count().should.equal 1
      action_count++
      foos.push foo
      bars.push bar
      cb(action_count,foo)
    wq.pending_task_count().should.equal 0
    wq.active_task_count().should.equal 0
    size = wq.enqueue_task action, ["f1","b1"], (count,foo)=>
      count.should.equal 1
      foo.should.equal "f1"
      action_count.should.equal 1
      foos.length.should.equal 1
      foos[0].should.equal "f1"
      bars.length.should.equal 1
      bars[0].should.equal "b1"
      wq.pending_task_count().should.equal 0
      wq.active_task_count().should.equal 0
      left = wq.stop_working()
      left.should.equal 0
      done()
    size.should.equal 1
    wq.pending_task_count().should.equal 1
    wq.active_task_count().should.equal 0
    wq.start_working()

  it "processes tasks in priority order", (done)->
    action_count = 0
    ids = []
    action = (id,cb)=>
      action_count++
      ids.push id
      cb()
    wq = new WorkQueue()
    wq.enqueue_task action, ["P5"], 5, ()=>
      action_count.should.equal 2
      ids.length.should.equal 2
      ids[0].should.equal "P10"
      ids[1].should.equal "P5"
    wq.enqueue_task action, ["P10"], 10, ()=>
      action_count.should.equal 1
      ids.length.should.equal 1
      ids[0].should.equal "P10"
    wq.enqueue_task action, ["P2"], 2, ()=>
      action_count.should.equal 3
      ids.length.should.equal 3
      ids[0].should.equal "P10"
      ids[1].should.equal "P5"
      ids[2].should.equal "P2"
      wq.stop_working()
      done()
    wq.start_working()

  it "can run tasks in parallel", (done)->
    action_count = 0
    running = {}
    action = (id,delay,cb)=>
      action_count++
      running[id] = true
      AsyncUtil.set_timeout delay, ()=>
        running[id] = false
        cb()
    wq = new WorkQueue({workers:2})
    wq.enqueue_task action, ["slow",1000], 10, ()=>
      running.fast.should.equal false
      wq.stop_working()
      done()
    wq.enqueue_task action, ["fast",1], 5, ()=>
      running.slow.should.equal true
    wq.start_working()

  it "doesn't run tasks in parallel by default", (done)->
    action_count = 0
    running = {}
    action = (id,delay,cb)=>
      action_count++
      running[id] = true
      AsyncUtil.set_timeout delay, ()=>
        running[id] = false
        cb()
    wq = new WorkQueue()
    wq.enqueue_task action, ["slow",1000], 10, ()=>
      should.not.exist running.fast
      wq.stop_working()
      done()
    wq.enqueue_task action, ["fast",1], 5, ()=>
      running.slow.should.equal false
      wq.stop_working()
      done()
    wq.start_working()


  it "emits events", (done)->
    action = (id, err, cb)=>
      if err?
        throw err
      else
        cb()
    enqueued = {}
    dequeued = {}
    completed = {}
    errored = {}
    begin = null
    wq = new WorkQueue()
    wq.on "task-enqueued", (q,t)=>
      enqueued[t.args[0]] = true
    wq.on "task-dequeued", (q,t)=>
      dequeued[t.args[0]] = true
    wq.on "task-completed", (q,t,r)=>
      completed[t.args[0]] = true
    wq.on "error", (q,t,e)=>
      errored[t.args[0]] = e
      wq.stop_working()
    wq.on "work-beginning", (q)=>
      begin = true
    wq.on "work-ending", (q)=>
      begin.should.equal true
      enqueued.A.should.equal true
      enqueued.B.should.equal true
      dequeued.A.should.equal true
      dequeued.B.should.equal true
      completed.A.should.equal true
      should.not.exist completed.B
      should.not.exist errored.A
      should.exist errored.B
      done()
    wq.enqueue_task action, ["A", null], (()->undefined)
    wq.enqueue_task action, ["B", new Error("Mock Error")], (()->undefined)
    wq.start_working()
