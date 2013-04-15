# Underscore utility
_ = require("underscore")

# Miso library
Miso = require("miso.dataset")
Miso.Parsers.Couchdb = (data, options) ->

_.extend Miso.Parsers.Couchdb::,
  parse: (rows) ->
    columns = undefined
    valueIsObject = undefined
    data = {}
    
    # No data to process
    unless rows.length
      return (
        columns: []
        data: {}
      )
    
    # If doc property is present, use this as the value
    if _.isObject(rows[0].doc)
      
      # Iterate over every row and swap the doc for the value
      _.each rows, (row) ->
        
        # Swap the value for the document
        row.value = row.doc

    
    # Set columns based off the first row.
    if _.isObject(rows[0].value)
      columns = _.keys(rows[0].value)
      
      # Set this flag for assignment later on
      valueIsObject = true
    
    # If the first row is not an object, use key/val
    else
      columns = ["key", "value"]
    
    # Ensure each column has an array for data.
    _.each columns, (column) ->
      data[column] = []

    
    # Iterate over every row and column and insert the data fetched
    # correctly.
    _.each rows, (row) ->
      _.each columns, (column) ->
        
        # Add to the respective column, if its not an object, use key/val
        data[column].push (if valueIsObject then row.value[column] else row[column])


    
    # Expected format for dataset.
    columns: columns
    data: data
