#Modules required
ConnectServ = require 'ssh2'
nano = require("nano")(process.env['CLOUDANT_URL'])
db_name = "wstats"
db = nano.use(db_name)
cronJob = require('cron').CronJob


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
prodDBMemTotal = ""
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
    connection = "w | head -1 | awk '{print $12}'" if value = "CPU"
    connection = "egrep 'Mem' /proc/meminfo | awk '{print $2}' | head -1" if value = "MemoryTotal"
    connection = "egrep 'Mem' /proc/meminfo | awk '{print $2}' | tail -1" if value = "MemoryFree"
    sshConnection.exec connection, (err, stream) ->
      throw err if err
      stream.on "data", (data, extended) ->
        console.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
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
  #Every 15 minutes.
  cronTime: "0 */15 * * * *"
  onTick: ->
    #Grabs the loadaverage from each server by SSH into them
    sshLogin stageHost, stageDBPort, stageDBUser, dotCloudpKey, "CPU"
    sshLogin stageHost, stagePyPort, stagePyUser, dotCloudpKey, "CPU"
    sshLogin stageHost, stageQPort, stageQUser, dotCloudpKey, "CPU"
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
    sshLogin prodHost, prodWorkersPort, prodWorkersUser, dotCloudpKey, "MemoryFree"
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

exports.index = (req, res) ->
	res.render 'index', { title: 'Graphs' }

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
