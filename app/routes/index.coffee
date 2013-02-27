#Modules required
ConnectServ = require 'ssh2'
nano = require("nano")("http://localhost:5984")
db_name = "wstats"
db = nano.use(db_name)
cronJob = require('cron').CronJob


#Declare the different variables needed from environment for SSH
dotcloudprivatekey = process.env['dotcloudPRIVATEKEY']
ec2privatekey = process.env['ec2PRIVATEKEY']

stagehost = process.env['STAGING_SSH_HOST']
prodhost = process.env['PROD_SSH_HOST']
eshost = process.env['EC2_ES_SSH_HOST']


stagedbport = process.env['STAGING_DB_SSH_PORT']
stagedbuser = process.env['STAGING_DB_SSH_USER']

stagepyport = process.env['STAGING_PY_SSH_PORT']
stagepyuser = process.env['STAGING_PY_SSH_USER']

stageqport = process.env['STAGING_Q_SSH_PORT']
stagequser = process.env['STAGING_Q_SSH_USER']

stageworkersport = process.env['STAGING_WORKERS_SSH_PORT']
stageworkersuser = process.env['STAGING_WORKERS_SSH_USER']

proddbport = process.env['PROD_DB_SSH_PORT']
proddbuser = process.env['PROD_DB_SSH_USER']

prodpyport = process.env['PROD_PY_SSH_PORT']
prodpyuser = process.env['PROD_PY_SSH_USER']

prodqport = process.env['PROD_Q_SSH_PORT']
prodquser = process.env['PROD_Q_SSH_USER']

prodworkersport = process.env['PROD_WORKERS_SSH_PORT']
prodworkersuser = process.env['PROD_WORKERS_SSH_USER']

esport = 22
esuser = process.env['EC2_ES_SSH_USER']

datalogjob = new cronJob(
  #Every 4 hours right now....
  cronTime: "0 */4 * * * *"
  onTick: ->
    #This probably needs to be changed to something less.. fugly.
    #A new SSH Object for each server doesn't really sound.. viable?
    #I'll look into SSH2 later and see if I can close a connection and open a different one.

    #stageDB
    stagedbloadavg = ""
    stagedb = new ConnectServ()
    stagedb.on "connect", ->

    stagedb.on "ready", ->
      stagedb.exec "w | head -1 | awk '{print $11}' | rev | cut -b 2- | rev" , (err, stream) ->
        throw err if err
        stream.on "data", (data, extended) ->
          console.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
          stagedbloadavg = parseFloat(data.toString('ascii'))

        stream.on "exit", (data, extended) ->
          stagedb.end()

      stagedb.on "error", (err) -> 
        console.log "Connection Error : " + err

      stagedb.on "end", ->
        console.log "Connection ended to StageDB"

      stagedb.on "close", (had_error) ->
        console.log "Connection closed due to " + had_error

      stagedb.connect
        host: stagehost
        port: stagedbport
        username: stagedbuser
        privateKey: dotcloudprivatekey

    #stagePY
    stagepyloadavg = ""
    stagepy = new ConnectServ()
    stagepy.on "connect", ->

    stagepy.on "ready", ->
      stagepy.exec "w | head -1 | awk '{print $11}' | rev | cut -b 2- | rev" , (err, stream) ->
        throw err if err
        stream.on "data", (data, extended) ->
          console.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
          stagepyloadavg = parseFloat(data.toString('ascii'))

        stream.on "exit", (data, extended) ->
          stagepy.end()

      stagepy.on "error", (err) -> 
        console.log "Connection Error : " + err

      stagepy.on "end", ->
        console.log "Connection ended to StageDB"

      stagepy.on "close", (had_error) ->
        console.log "Connection closed due to " + had_error

      stagepy.connect
        host: stagehost
        port: stagepyport
        username: stagepyuser
        privateKey: dotcloudprivatekey   
    
    #stageQ
    stageqloadavg = ""
    stageq = new ConnectServ()
    stageq.on "connect", ->

    stageq.on "ready", ->
      stageq.exec "w | head -1 | awk '{print $11}' | rev | cut -b 2- | rev" , (err, stream) ->
        throw err if err
        stream.on "data", (data, extended) ->
          console.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
          stageqloadavg = parseFloat(data.toString('ascii'))

        stream.on "exit", (data, extended) ->
          stageq.end()

      stageq.on "error", (err) -> 
        console.log "Connection Error : " + err

      stageq.on "end", ->
        console.log "Connection ended to StageDB"

      stageq.on "close", (had_error) ->
        console.log "Connection closed due to " + had_error

      stageq.connect
        host: stagehost
        port: stageqport
        username: stagequser
        privateKey: dotcloudprivatekey   
        
    #stageWorkers
    stageworkersloadavg = ""
    stageworkers = new ConnectServ()
    stageworkers.on "connect", ->

    stageworkers.on "ready", ->
      stageworkers.exec "w | head -1 | awk '{print $11}' | rev | cut -b 2- | rev" , (err, stream) ->
        throw err if err
        stream.on "data", (data, extended) ->
          console.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
          stageworkersloadavg = parseFloat(data.toString('ascii'))

        stream.on "exit", (data, extended) ->
          stageworkers.end()

      stageworkers.on "error", (err) -> 
        console.log "Connection Error : " + err

      stageworkers.on "end", ->
        console.log "Connection ended to StageDB"

      stageworkers.on "close", (had_error) ->
        console.log "Connection closed due to " + had_error

      stageworkers.connect
        host: stagehost
        port: stageworkersport
        username: stageworkersuser
        privateKey: dotcloudprivatekey   
    
    #proddb
    proddbloadavg = ""
    proddb = new ConnectServ()
    proddb.on "connect", ->

    proddb.on "ready", ->
      proddb.exec "w | head -1 | awk '{print $11}' | rev | cut -b 2- | rev" , (err, stream) ->
        throw err if err
        stream.on "data", (data, extended) ->
          console.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
          proddbloadavg = parseFloat(data.toString('ascii'))

        stream.on "exit", (data, extended) ->
          proddb.end()

      proddb.on "error", (err) -> 
        console.log "Connection Error : " + err

      proddb.on "end", ->
        console.log "Connection ended to StageDB"

      proddb.on "close", (had_error) ->
        console.log "Connection closed due to " + had_error

      proddb.connect
        host: prodhost
        port: proddbport
        username: proddbuser
        privateKey: dotcloudprivatekey   
        
    #Prodpy    
    prodpyloadavg = ""
    prodpy = new ConnectServ()
    prodpy.on "connect", ->

    prodpy.on "ready", ->
      prodpy.exec "w | head -1 | awk '{print $11}' | rev | cut -b 2- | rev" , (err, stream) ->
        throw err if err
        stream.on "data", (data, extended) ->
          console.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
          prodpyloadavg = parseFloat(data.toString('ascii'))

        stream.on "exit", (data, extended) ->
          prodpy.end()

      prodpy.on "error", (err) -> 
        console.log "Connection Error : " + err

      prodpy.on "end", ->
        console.log "Connection ended to StageDB"

      prodpy.on "close", (had_error) ->
        console.log "Connection closed due to " + had_error

      prodpy.connect
        host: prodhost
        port: prodpyport
        username: prodpyuser
        privateKey: dotcloudprivatekey

    #Prodq    
    prodqloadavg = ""
    prodq = new ConnectServ()
    prodq.on "connect", ->

    prodq.on "ready", ->
      prodq.exec "w | head -1 | awk '{print $11}' | rev | cut -b 2- | rev" , (err, stream) ->
        throw err if err
        stream.on "data", (data, extended) ->
          console.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
          prodqloadavg = parseFloat(data.toString('ascii'))

        stream.on "exit", (data, extended) ->
          prodq.end()

      prodq.on "error", (err) -> 
        console.log "Connection Error : " + err

      prodq.on "end", ->
        console.log "Connection ended to StageDB"

      prodq.on "close", (had_error) ->
        console.log "Connection closed due to " + had_error

      prodq.connect
        host: prodhost
        port: prodqport
        username: prodquser
        privateKey: dotcloudprivatekey

    #Prodworkers    
    prodworkersloadavg = ""
    prodworkers = new ConnectServ()
    prodworkers.on "connect", ->

    prodworkers.on "ready", ->
      prodworkers.exec "w | head -1 | awk '{print $11}' | rev | cut -b 2- | rev" , (err, stream) ->
        throw err if err
        stream.on "data", (data, extended) ->
          console.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
          prodworkersloadavg = parseFloat(data.toString('ascii'))

        stream.on "exit", (data, extended) ->
          prodworkers.end()

      prodworkers.on "error", (err) -> 
        console.log "Connection Error : " + err

      prodworkers.on "end", ->
        console.log "Connection ended to StageDB"

      prodworkers.on "close", (had_error) ->
        console.log "Connection closed due to " + had_error

      prodworkers.connect
        host: prodhost
        port: prodworkersport
        username: prodworkersuser
        privateKey: dotcloudprivatekey



    #Elastic Search
    esloadavg = ""
    es = new ConnectServ()
    es.on "connect", ->

    es.on "ready", ->
      es.exec "w | head -1 | awk '{print $11}' | rev | cut -b 2- | rev" , (err, stream) ->
        throw err if err
        stream.on "data", (data, extended) ->
          console.log ((if extended is "stderr" then "STDERR: " else "STDOUT ")) + data
          esloadavg = parseFloat(data.toString('ascii'))

        stream.on "exit", (data, extended) ->
          es.end()

      es.on "error", (err) -> 
        console.log "Connection Error : " + err

      es.on "end", ->
        console.log "Connection ended to StageDB"

      es.on "close", (had_error) ->
        console.log "Connection closed due to " + had_error

      es.connect
        host: eshost
        port: esport
        username: esuser
        privateKey: ec2privatekey

      currentTime = Date.now()
      #Insert into database
      nano.db.create db_name, (error, body, headers) ->
        return response.send(error.message, error["status-code"]) if error
        db.insert
          stagedb: stagedbloadavg
          stagepy: stagepyloadavg
          stageq: stageqloadavg
          stageworkers: stageworkersloadavg
          proddb: proddbloadavg
          prodpy: prodpyloadavg
          prodq: prodqloadavg
          prodworkers: prodworkersloadavg
          es: es
          date: currentTime
        , (error2, body, header) ->
          return response.send(error2, message, error2["status-code"]) if error2
          response.send "Insert ok", 200
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

