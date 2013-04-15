#Modules required
ConnectServ = require 'ssh2'
#nano = require("nano")(process.env['CLOUDANT_URL'])
nano = require("nano")('http://localhost:5984')
db_name = "wstats"
db = nano.use(db_name)
cronJob = require('cron').CronJob
async = require 'async'

#Declare the different variables grabbed from Heroku environment for SSH
dotCloudpKey = process.env['dotcloudPRIVATEKEY']
ec2pKey = process.env['ec2PRIVATEKEY']

stageHost = process.env['STAGING_SSH_HOST']
prodHost = process.env['PROD_SSH_HOST']
esHost = process.env['EC2_ES_SSH_HOST']


stageDBPort = process.env['STAGING_DB_SSH_PORT']
stageDBUser = process.env['STAGING_DB_SSH_USER']

stagePyPort = process.env['STAGING_PY_SSH_PORT']
stagePyUser = process.env['STAGING_PY_SSH_USER']

stageQPort = process.env['STAGING_Q_SSH_PORT']
stageQUser = process.env['STAGING_Q_SSH_USER']

stageWorkersPort = process.env['STAGING_WORKERS_SSH_PORT']
stageWorkersUser = process.env['STAGING_WORKERS_SSH_USER']

prodDBPort = process.env['PROD_DB_SSH_PORT']
prodDBUser = process.env['PROD_DB_SSH_USER']

prodPyPort = process.env['PROD_PY_SSH_PORT']
prodPyUser = process.env['PROD_PY_SSH_USER']

prodQPort = process.env['PROD_Q_SSH_PORT']
prodQUser = process.env['PROD_Q_SSH_USER']

prodWorkersPort = process.env['PROD_WORKERS_SSH_PORT']
prodWorkersUser = process.env['PROD_WORKERS_SSH_USER']

esPort = 22
esUser = process.env['EC2_ES_SSH_USER']

stageDBLoadAvg = ""
stageDBMemTotal = ""
stageDBMemFree = ""
stagePyLoadAvg = ""
stagePyMemTotal = ""
stagePyMemFree = ""
stageQLoadAvg = ""
stageQMemTotal = ""
stageQMemFree = ""
stageWorkersLoadAvg = ""
stageWorkersMemTotal = ""
stageWorkersMemFree = ""
prodDBLoadAvg = ""
prodDBMemTotalg = ""
prodDBMemFree = ""
prodPyLoadAvg = ""
prodPyMemTotal = ""
prodPyMemFree = ""
prodQLoadAvg = ""
prodQMemTotal = ""
prodQMemFree = ""
prodWorkersLoadAvg = ""
prodWorkersMemTotal= ""
prodWorkersMemFree = ""
esLoadAvg = ""
esMemTotal = "" 
esMemFree = ""

cpuCommand = "w | head -1 | awk '{print $12}'"
memoryTotalCommand = "egrep 'Mem' /proc/meminfo | awk '{print $2}' | head -1"
memoryFreeCommand = "egrep 'Mem' /proc/meminfo | awk '{print $2}' | tail -1"

#Mem Parser, parses the memory data. It could be more efficient to just SSH into the system again
#but that increases cost on our paid network side.....
memPercentage = (memoryTotal, memoryFree) -> 
  return 0 if memoryTotal < memoryFree
  return 0 if memoryTotal == memoryFree
  if memoryTotal > memoryFree
    temp = memoryTotal - memoryFree
    temp = temp/memoryTotal
    temp = 1 - temp
    return temp
#SSH Method
sshLogin = (sshHost, sshPort, sshUser, sshPrivateKey, value) ->
  sshConnection = new ConnectServ()
  
  sshConnection.on "connect", ->  

  #The exec code will give the load average of the past 15 minutes, and then will return the number
  sshConnection.on "ready", ->
    if value is "CPU" then connection = cpuCommand
    if value is "MemoryTotal" then connection = memoryTotalCommand
    if value is "MemoryFree" then connection = memoryFreeCommand
    console.log connection
    console.log value
    sshConnection.exec connection, (err, stream) ->
      throw err if err
      stream.on "data", (data, extended) ->
        consogle.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
        stageDBLoadAvg = parseFloat(data.toString('ascii')) if sshPort is stageDBPort and value is "CPU"
        stagePyLoadAvg = parseFloat(data.toString('ascii')) if sshPort is stagePyPort and value is "CPU"
        stageQLoadAvg = parseFloat(data.toString('ascii')) if sshPort is stageQPort and value is "CPU" 
        stageWorkersLoadAvg = parseFloat(data.toString('ascii')) if sshPort is stageWorkersPort and value is "CPU"
        prodDBLoadAvg = parseFloat(data.toString('ascii')) if sshPort is prodDBPort and value is "CPU"
        prodPyLoadAvg = parseFloat(data.toString('ascii')) if sshPort is prodPyPort and value is "CPU"
        prodQLoadAvg = parseFloat(data.toString('ascii')) if sshPort is prodQPort and value is "CPU"

        prodWorkersLoadAvg = parseFloat(data.toString('ascii')) if sshPort is prodWorkersPort and value is "CPU"
        esLoadAvg = parseFloat(data.toString('ascii')) if sshPort is esPort and value is "CPU"

        stageDBMemTotal = parseFloat(data.toString('ascii')) if sshPort is stageDBPort and value is "MemoryTotal"
        stagePyMemTotal = parseFloat(data.toString('ascii')) if sshPort is stagePyPort and value is "MemoryTotal"
        stageQMemTotal = parseFloat(data.toString('ascii')) if sshPort is stageQPort and value is "MemoryTotal"
        stageWorkersMemTotal = parseFloat(data.toString('ascii')) if sshPort is stageWorkersPort and value is "MemoryTotal"
        prodDBMemTotal = parseFloat(data.toString('ascii')) if sshPort is prodDBPort and value is "MemoryTotal"
        prodPyMemTotal = parseFloat(data.toString('ascii')) if sshPort is prodPyPort and value is "MemoryTotal"
        prodQMemTotal = parseFloat(data.toString('ascii')) if sshPort is prodQPort and value is "MemoryTotal"
        prodWorkersMemTotal = parseFloat(data.toString('ascii')) if sshPort is prodWorkersPort and value is "MemoryTotal"
        esMemTotal = parseFloat(data.toString('ascii')) if sshPort is esPort and value is "MemoryTotal"

        stageDBMemFree = parseFloat(data.toString('ascii')) if sshPort is stageDBPort and value is "MemoryFree"
        stagePyMemFree = parseFloat(data.toString('ascii')) if sshPort is stagePyPort and value is "MemoryFree"
        stageQMemFree = parseFloat(data.toString('ascii')) if sshPort is stageQPort and value is "MemoryFree"
        stageWorkersMemFree = parseFloat(data.toString('ascii')) if sshPort is stageWorkersPort and value is "MemoryFree"
        prodDBMemFree = parseFloat(data.toString('ascii')) if sshPort is prodDBPort and value is "MemoryFree"
        prodPyMemFree = parseFloat(data.toString('ascii')) if sshPort is prodPyPort and value is "MemoryFree"
        prodQMemFree = parseFloat(data.toString('ascii')) if sshPort is prodQPort and value is "MemoryFree"
        prodWorkersMemFree = parseFloat(data.toString('ascii')) if sshPort is prodWorkersPort and value is "MemoryFree"
        esMemFree = parseFloat(data.toString('ascii')) if sshPort is esPort and value is "MemoryFree"
      stream.on "exit", (data, extended) -> 
        sshConnection.end()

  sshConnection.on "error", (err) ->
    console.log "Connection Error : " + err

  sshConnection.on "end" , ->
    console.log "Connection ended"

  sshConnection.on "close", (had_error) ->
    console.log "Connection closed due to " + had_error

  sshConnection.connect
    host: sshHost
    port: sshPort
    username: sshUser
    privateKey: sshPrivateKey


datalogjob = new cronJob(
  #every minute
  cronTime: "0 * * * * *"
  onTick: ->
    #Grabs the loadaverage from each server by SSH into them
    sshLogin stageHost, stageDBPort, stageDBUser, dotCloudpKey, "CPU"
    console.log "CPU stageDB"
    sshLogin stageHost, stagePyPort, stagePyUser, dotCloudpKey, "CPU"
    console.log "CPU stagePY"
    sshLogin stageHost, stageQPort, stageQUser, dotCloudpKey, "CPU"
    console.log "CPU StageQ"
    sshLogin stageHost, stageWorkersPort, stageWorkersUser, dotCloudpKey, "CPU"
    sshLogin prodHost, prodDBPort, prodDBUser, dotCloudpKey, "CPU"
    sshLogin prodHost, prodPyPort, prodPyUser, dotCloudpKey, "CPU"
    sshLogin prodHost, prodQPort, prodQUser, dotCloudpKey, "CPU"
    sshLogin prodHost, prodWorkersPort, prodWorkersUser, dotCloudpKey, "CPU"
    sshLogin esHost, esPort, esUser, ec2pKey, "CPU"
    sshLogin stageHost, stageDBPort, stageDBUser, dotCloudpKey, "MemoryTotal"
    sshLogin stageHost, stagePyPort, stagePyUser, dotCloudpKey, "MemoryTotal"
    sshLogin stageHost, stageQPort, stageQUser, dotCloudpKey, "MemoryTotal"
    sshLogin stageHost, stageWorkersPort, stageWorkersUser, dotCloudpKey, "MemoryTotal"
    sshLogin prodHost, prodDBPort, prodDBUser, dotCloudpKey, "MemoryTotal"
    sshLogin prodHost, prodPyPort, prodPyUser, dotCloudpKey, "MemoryTotal"
    sshLogin prodHost, prodQPort, prodQUser, dotCloudpKey, "MemoryTotal"
    sshLogin prodHost, prodWorkersPort, prodWorkersUser, dotCloudpKey, "MemoryTotal"
    sshLogin esHost, esPort, esUser, ec2pKey, "MemoryTotal"
    sshLogin stageHost, stageDBPort, stageDBUser, dotCloudpKey, "MemoryFree"
    sshLogin stageHost, stagePyPort, stagePyUser, dotCloudpKey, "MemoryFree"
    sshLogin stageHost, stageQPort, stageQUser, dotCloudpKey, "MemoryFree"
    sshLogin stageHost, stageWorkersPort, stageWorkersUser, dotCloudpKey, "MemoryFree"
    sshLogin prodHost, prodDBPort, prodDBUser, dotCloudpKey, "MemoryFree"
    sshLogin prodHost, prodPyPort, prodPyUser, dotCloudpKey, "MemoryFree"
    sshLogin prodHost, prodQPort, prodQUser, dotCloudpKey, "MemoryFree"
    sshLogin esHost, esPort, esUser, ec2pKey, "MemoryFree"

    stageDBMem = memPercentage stageDBMemTotal, stageDBMemFree
    stagePyMem = memPercentage stagePyMemTotal, stagePyMemFree
    stageQMem = memPercentage stageQMemTotal, stageQMemFree
    stageWorkersMem = memPercentage stageWorkersMemTotal, stageWorkersMemFree
    prodDBMem = memPercentage prodDBMemTotal, prodDBMemFree
    prodPyMem = memPercentage prodPyMemTotal, prodPyMemFree
    prodQMem = memPercentage prodQMemTotal, prodQMemFree
    prodWorkersMem = memPercentage prodWorkersMemTotal, prodWorkersMemFree
    esMem = memPercentage esMemTotal, esMemFree

    currentTime = Date.now().toString()
    #Insert into database
    nano.db.create db_name, (error, body, headers) ->
      if error
        #Don't return as the database has most likely been created previously...
        console.log "error occured due to status code ", error.message
      db.insert
        stagedbloadavg: stageDBLoadAvg
        stagepyloadavg: stagePyLoadAvg
        stageqloadavg: stageQLoadAvg
        stageworkersloadavg: stageWorkersLoadAvg
        proddbloadavg: prodDBLoadAvg
        prodpyloadavg: prodPyLoadAvg
        prodqloadavg: prodQLoadAvg
        prodworkersloadavg: prodWorkersLoadAvg
        esloadavg: esLoadAvg
        stagedbmem: stageDBMem
        stagepymem: stagePyMem
        stageqmem: stageQMem
        stageworkersmem: stageWorkersMem
        proddbmem: prodDBMem
        prodpymem: prodPyMem
        prodqmem: prodQMem
        prodworkersmem: prodWorkersMem
        esmem: esMem
      , currentTime, (error2, body, header) ->
        if error2
          console.log "error occured due to status code ", error2.message
          return
        console.log "Insert ok", 200
  start: false
)

newTime = (docid) -> 
  currentTime = Date.now().toString()
  subtractTime = currentTime - docid
  subtractTime = (-((((subtractTime / 1000) / 60) / 60) / 24)).toFixed(4)
  return subtractTime


exports.test =  (req, res) ->
    db.view "", "getAll", (error, body, headers) ->
          res.send body, 200

exports.index = (req, res) ->
      prodDBCPUArrx = []
      prodDBCPUArry = []
      prodPyCPUArrx = []
      prodPyCPUArry = []
      prodQCPUArrx = []
      prodQCPUArry = []
      prodWorkersCPUArrx = []
      prodWorkersCPUArry = []
      esCPUArrx = []
      esCPUArry = []
      stageDBCPUArrx = []
      stageDBCPUArry = []
      stagePyCPUArrx = []
      stagePyCPUArry = []
      stageQCPUArrx = []
      stageQCPUArry = []
      stageWorkersCPUArrx = []
      stageWorkersCPUArry = []
      prodDBMemArrx = []
      prodDBMemArry = []
      prodPyMemArrx = []
      prodPyMemArry = []
      prodQMemArrx = []
      prodQMemArry = []
      prodWorkersMemArrx = []
      prodWorkersMemArry = []
      esMemArrx = []
      esMemArry = []
      stageDBMemArrx = []
      stageDBMemArry = []
      stagePyMemArrx = []
      stagePyMemArry = []
      stageQMemArrx = []
      stageQMemArry = []
      stageWorkersMemArrx = []
      stageWorkersMemArry = []
      async.series [ (callback) ->
          db.view 'proddbcpu', 'proddbcpu', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                prodDBCPUArrx.push(currentTime)
                prodDBCPUArry.push((doc.value).toFixed(4))
                console.log doc
              console.log prodDBCPUArrx
              console.log prodDBCPUArry
              callback(null, 'one')
        , (callback) ->
          db.view 'prodpycpu', 'prodpycpu', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                prodPyCPUArrx.push(currentTime)
                prodPyCPUArry.push((doc.value).toFixed(4))
                console.log doc
              console.log prodPyCPUArrx
              console.log prodPyCPUArry
              callback(null, 'two')
        , (callback) ->
          db.view 'prodqcpu', 'prodqcpu', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                prodQCPUArrx.push(currentTime)
                prodQCPUArry.push((doc.value).toFixed(4))
                console.log doc
              console.log prodQCPUArrx
              console.log prodQCPUArry
              callback(null, 'three')
        , (callback) ->
          db.view 'prodworkerscpu', 'prodworkerscpu', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                prodWorkersCPUArrx.push(currentTime)
                prodWorkersCPUArry.push((doc.value).toFixed(4))
                console.log doc
              console.log prodWorkersCPUArrx
              console.log prodWorkersCPUArry
              callback(null, 'four')
        , (callback) ->
          db.view 'escpu', 'escpu', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                esCPUArrx.push(currentTime)
                esCPUArry.push((doc.value).toFixed(4))
                console.log doc
              console.log esCPUArrx
              console.log esCPUArry
              callback(null, 'five')
        , (callback) ->
          db.view 'stagedbcpu', 'stagedbcpu', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                stageDBCPUArrx.push(currentTime)
                stageDBCPUArry.push((doc.value).toFixed(4))
                console.log doc
              console.log stageDBCPUArrx
              console.log stageDBCPUArry
              callback(null, 'six')
        , (callback) ->
          db.view 'stagepycpu', 'stagepycpu', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                stagePyCPUArrx.push(currentTime)
                stagePyCPUArry.push((doc.value).toFixed(4))
                console.log doc
              console.log stagePyCPUArrx
              console.log stagePyCPUArry
              callback(null, 'seven')
        , (callback) ->
          db.view 'stageqcpu', 'stageqcpu', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                stageQCPUArrx.push(currentTime)
                stageQCPUArry.push((doc.value).toFixed(4))
                console.log doc
              console.log stageQCPUArrx
              console.log stageQCPUArry
              callback(null, 'eight')
        , (callback) ->
          db.view 'proddbmemratio', 'proddbmemratio', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                prodDBMemArrx.push(currentTime)
                prodDBMemArry.push((doc.value).toFixed(4))
                console.log doc
              console.log prodDBMemArrx
              console.log prodDBMemArry
              callback(null, 'nine')
        , (callback) ->
          db.view 'prodpymemratio', 'prodpymemratio', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                prodPyMemArrx.push(currentTime)
                prodPyMemArry.push((doc.value).toFixed(4))
                console.log doc
              console.log prodPyMemArrx
              console.log prodPyMemArry
              callback(null, 'ten')
        , (callback) ->
          db.view 'prodqmemratio', 'prodqmemratio', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                prodQMemArrx.push(currentTime)
                prodQMemArry.push((doc.value).toFixed(4))
                console.log doc
              console.log prodQMemArrx
              console.log prodQMemArry
              callback(null, 'eleven')
        , (callback) ->
          db.view 'prodworkersmemratio', 'prodworkersmemratio', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                prodWorkersMemArrx.push(currentTime)
                prodWorkersMemArry.push((doc.value).toFixed(4))
                console.log doc
              console.log prodWorkersMemArrx
              console.log prodWorkersMemArry
              callback(null, 'twelve')
        , (callback) ->
          db.view 'esmemratio', 'esmemratio', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                esMemArrx.push(currentTime)
                esMemArry.push((doc.value).toFixed(4))
                console.log doc
              console.log esMemArrx
              console.log esMemArry
              callback(null, 'thirteen')
        , (callback) ->
          db.view 'stagedbmemratio', 'stagedbmemratio', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                stageDBMemArrx.push(currentTime)
                stageDBMemArry.push((doc.value).toFixed(4))
                console.log doc
              console.log stageDBMemArrx
              console.log stageDBMemArry
              callback(null, 'fourteen')
        , (callback) ->
          db.view 'stagepymemratio', 'stagepymemratio', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                stagePyMemArrx.push(currentTime)
                stagePyMemArry.push((doc.value).toFixed(4))
                console.log doc
              console.log stagePyMemArrx
              console.log stagePyMemArry
              callback(null, 'fifteen')
        , (callback) ->
          db.view 'stageqmemratio', 'stageqmemratio', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                stageQMemArrx.push(currentTime)
                stageQMemArry.push((doc.value).toFixed(4))
                console.log doc
              console.log stageQMemArrx
              console.log stageQMemArry
              callback(null, 'sixteen')
        , (callback) ->
          db.view 'stageworkersmemratio', 'stageworkersmemratio', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                stageWorkersMemArrx.push(currentTime)
                stageWorkersMemArry.push((doc.value).toFixed(4))
                console.log doc
              console.log stageWorkersMemArrx
              console.log stageWorkersMemArry
              callback(null, 'seventeen')
        , (callback) ->
          db.view 'stageworkerscpu', 'stageworkerscpu', (err, body) ->
            unless err
              body.rows.forEach (doc) -> 
                currentTime = newTime doc.id
                stageWorkersCPUArrx.push(currentTime)
                stageWorkersCPUArry.push((doc.value).toFixed(4))
                console.log doc
              console.log stageWorkersCPUArrx
              console.log stageWorkersCPUArry
              callback(null, 'eighteen')
        , (callback) ->  
          res.render 'index', { title: 'Graphs', prodDBCPUArrx: prodDBCPUArrx, prodDBCPUArry: prodDBCPUArry, prodPyCPUArrx: prodPyCPUArrx, prodPyCPUArry: prodPyCPUArry, prodQCPUArrx: prodQCPUArrx, prodQCPUArry: prodQCPUArry,prodWorkersCPUArrx: prodWorkersCPUArrx, prodWorkersCPUArry: prodWorkersCPUArry, esCPUArrx: esCPUArrx,       esCPUArry: esCPUArry, stageDBCPUArrx: stageDBCPUArrx, stageDBCPUArry: stageDBCPUArry, stagePyCPUArrx: stagePyCPUArrx, stagePyCPUArry: stagePyCPUArry, stageQCPUArrx: stageQCPUArrx, stageQCPUArry: stageQCPUArry, stageWorkersCPUArrx: stageWorkersCPUArrx, stageWorkersCPUArry: stageWorkersCPUArry,prodDBMemArrx: prodDBMemArrx,      prodDBMemArry: prodDBMemArry, prodPyMemArrx: prodPyMemArrx, prodPyMemArry: prodPyMemArry, prodQMemArrx: prodQMemArrx, prodQMemArry: prodQMemArry,                prodWorkersMemArrx: prodWorkersMemArrx, prodWorkersMemArry: prodWorkersMemArry, esMemArrx: esMemArrx, esMemArry: esMemArry, stageDBMemArrx: stageDBMemArrx,     stageDBMemArry: stageDBMemArry, stagePyMemArrx: stagePyMemArrx, stagePyMemArry: stagePyMemArry, stageQMemArrx: stageQMemArrx, stageQMemArry: stageQMemArry,        stageWorkersMemArrx: stageWorkersMemArrx, stageWorkersMemArry: stageWorkersMemArry }
          callback(null, 'nineteen')
        ]

exports.setupGET = (req, res) ->
        test = nano.use('activate')
        status = ""
        test.get 'onlinestatus',
          (err, body) ->
            status = body.online unless err 
        res.render 'setup', { title: 'Configuration', status2: status}

exports.setupPOST = (req, res) ->
        if req.body.online is "off"
          nano.db.destroy "activate", ->
            nano.db.create "activate", ->
              resetSwitch = nano.use("activate")
              resetSwitch.insert
                online: "down"
                , "onlinestatus", (err, body, header) ->
                  if err
                    console.log "[resetSwitch.insert] ", err.message
                    return
            datalogjob.stop()
            console.log "Successfully Shutdown CronJob"
        else if req.body.online is "on"
            nano.db.destroy "activate", ->
              nano.db.create "activate", ->
                resetSwitch = nano.use("activate")
                resetSwitch.insert
                  online: "up"
                  , "onlinestatus", (err, body, header) ->
                    if err
                      console.log "[resetSwitch.insert] ", err.message
                      return
                datalogjob.start()
                console.log "Successfully Started CronJob"
          test = nano.use('activate')
          status = ""
          test.get 'onlinestatus',
            (err, body) ->
              status = body.online unless err 
          res.render 'setup', { title: 'Configuration', status2: status}
