nano = require("nano")("http://localhost:5984")
start = Date.now()
# clean up the database we created previously
nano.db.destroy "alice", ->
  
  # create a new database
  nano.db.create "alice", ->
    
    # specify the database we are going to use
    alice = nano.use("alice")
    
    # and insert a document in it
    alice.insert
      crazy: false
      stupdi: start
    , "time", (err, body, header) ->
      if err
        console.log "[alice.insert] ", err.message
        return
      console.log "you have inserted the rabbit."
      console.log body
