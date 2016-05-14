fs                  = require 'fs'
path                = require 'path'
HOMEDIR             = path.join(__dirname,'..')
LIB_COV             = path.join(HOMEDIR,'lib-cov')
LIB_DIR             = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
Util                = require(path.join(LIB_DIR,'util')).Util
PriorityQueue       = require 'priorityqueuejs'
{EventEmitter}      = require 'events'
DEFAULT_PRIORITY    = 5
DEFAULT_INTERVAL    = 200
DEFAULT_FUZZ_FACTOR = 1/10
DEFAULT_MAX_WORKERS = 1

class WorkQueue extends EventEmitter

  constructor:(options)->
    options ?= {}
    @default_priority = options.priority    ? DEFAULT_PRIORITY
    @work_interval    = options.interval    ? DEFAULT_INTERVAL
    @fuzz_factor      = options.fuzz        ? DEFAULT_FUZZ_FACTOR
    @max_workers      = options.workers     ? DEFAULT_MAX_WORKERS

  pending_task_count:()=>(@queue?.size() ? 0)

  active_task_count:()=>(@tasks_running ? 0)

  enqueue_task:(method,args,priority,callback)=>
    # adjust arguments, set defaults
    if typeof args is 'function' and not priority? and not callback?
      callback = args
      priority = null
      args = null
    else if typeof priority is 'function' and not callback?
      callback = priority
      priority = null
    method   ?= ((cb)->cb())
    args     ?= []
    priority ?= @default_priority
    callback ?= (()->undefined)
    unless Array.isArray(args)
      args = [args]
    # enqueue task
    task = {
      priority : priority
      method   : method
      args     : args
      callback : callback
    }
    @queue ?= new PriorityQueue((a,b)->(a.priority-b.priority))
    @queue.enq task
    @emit "task-enqueued", @, task
    return @pending_task_count()

  dequeue_task:()=>
    if (not @queue?) or @queue.isEmpty()
      # no tasks
      return
    else if @tasks_running >= @max_workers
      @emit "busy", @
    else
      @tasks_running ?= 0
      @tasks_running += 1
      task = @queue?.deq()
      @emit "task-dequeued", @, task
      try
        task.method task.args..., (result...)=>
          @tasks_running ?= 1
          @tasks_running -= 1
          task.callback(result...)
          process.nextTick ()=>
            @emit "task-completed", @, task, result
      catch err
        @tasks_running ?= 1
        @tasks_running -= 1
        if EventEmitter.listenerCount(this, 'error') > 0
          @emit "error", @, task, err
        else
          throw err

  start_working:(options)=>
    if @worker?
      @stop_work()
    options ?= {}
    delay = Util.to_int(options.interval) ? @work_interval
    fuzz_factor = parseFloat(options.fuzz ? @fuzz_factor)
    if isNaN(fuzz) or not fuzz?
      fuzz_factor = @fuzz_factor
    if fuzz_factor and fuzz_factor > 0
      # compute fuzz as a value within +/- delay*fuzz_factor
      fuzz = (Math.random()*(2*delay*fuzz_factor))-(delay*fuzz_factor)
      delay = Math.round(delay + fuzz)
      if delay <= 0
        delay = @work_interval
    process.nextTick ()=>
      @worker = setInterval(@dequeue_task)
      @emit "work-beginning", @
    return @pending_task_count()

  stop_working:()=>
    if @worker
      clearInterval(@worker)
    @worker = null
    process.nextTick ()=>
      @emit "work-ending", @
    return @pending_task_count()

exports.WorkQueue = WorkQueue
