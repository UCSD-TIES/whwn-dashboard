# Underscore utility
_ = require("underscore")

# Miso library
Miso = require("miso.dataset")

# Nano library
nano = require("nano")

#
# * The Couchdb importer is responsible for fetching data from a CouchDB
# * database.
# *
# * Parameters:
# *   options
# *     auth - Authentication to the database server
# *     host - Address to the database server
# *     db - Name of the database
# *     query - Query to make to the database
# 
Miso.Importers.Couchdb = (options) ->
  _.defaults this, options,
    auth: ""
    host: ""
    db: ""
    query: ""

  
  # Generate the CouchDB url
  url = [@auth, @host, @db].join("")
  
  # Establish a connection
  @connection = nano([url, @query and "?" + @query].join(""))

_.extend Miso.Importers.Couchdb::,
  fetch: (options) ->
    if _.isFunction(@view)
      @view @connection, (err, data) ->
        return options.error(err)  if err
        options.success data.rows

