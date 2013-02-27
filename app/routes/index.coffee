#Modules required
ConnectServ = require 'ssh2'
nano = require("nano")("http://localhost:5984")
db_name = "wstats"
db = nano.use(db_name)
cronJob = require('cron').CronJob


#Declare the different variables grabbed from Heroku environment for SSH
dotCloudPrivateKey = process.env['dotCloudPrivateKey']
ec2PrivateKey = process.env['ec2PrivateKey']

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

tempLoadAvg = ""

#SSH Method
sshLogin = (sshHost, sshPort, sshUser, sshPrivateKey) ->
  sshConnection = new ConnectServ()
  
  sshConnection.on "connect", ->  

  #The exec code will give the load average of the past 15 minutes, and then will return the number
  sshConnection.on "ready", -> 
    sshConnection.exec "w | head -1 | awk '{print $12}' | rev | cut -b 2- | rev", (err, stream) ->
      throw err if err
      stream.on "data", (data, extended) ->
        console.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
        tempLoadAvg = parseFloat(data.toString('ascii'))

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

  return tempLoadAvg

datalogjob = new cronJob(
  #Every 4 hours right now....
  cronTime: "0 */4 * * * *"
  onTick: ->
    #Grabs the loadaverage from each server by SSH into them
    stageDBLoadAvg = sshLogin stageHost, stageDBPort, stageDBUser, dotCloudPrivateKey
    stagePyLoadAvg = sshLogin stageHost, stagePyPort, stagePyUser, dotCloudPrivateKey
    stageQLoadAvg = sshLogin stageHost, stageQPort, stageQUser, dotCloudPrivateKey
    stageWorkersLoadAvg = sshLogin stageHost, stageWorkersPort, stageWorkersUser, dotCloudPrivateKey
    prodDBLoadAvg = sshLogin prodHost, prodDBPort, prodDBUser, dotCloudPrivateKey
    prodPyLoadAvg = sshLogin prodHost, prodPyPort, prodPyUser, dotCloudPrivateKey
    prodQLoadAvg = sshLogin prodHost, prodQPort, prodQUser, dotCloudPrivateKey
    prodWorkersLoadAvg = sshLogin prodHost, prodWorkersPort, prodWorkersUser, dotCloudPrivateKey
    esLoadAvg = sshLogin esHost, esPort, esUser, ec2PrivateKey

    currentTime = Date.now()
    #Insert into database
    nano.db.create db_name, (error, body, headers) ->
      if error
        #Don't return as the database has most likely been created previously...
        console.log "error occured due to status code ", error.message
      db.insert
        stagedb: stageDBLoadAvg
        stagepy: stagePyLoadAvg
        stageq: stageQLoadAvg
        stageworkers: stageWorkersLoadAvg
        proddb: prodDBLoadAvg
        prodpy: prodPyLoadAvg
        prodq: prodQLoadAvg
        prodworkers: prodWorkersLoadAvg
        es: esLoadAvg
        date: currentTime
      , (error2, body, header) ->
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

