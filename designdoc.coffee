_ = require('underscore')
nano = require("nano")('http://localhost:5984')
nano.db.create('wstats')
db_name = "wstats"
db = nano.use(db_name)



view_insert = { 
  escpu:                'function(doc) { emit(doc._id, doc.esloadavg) }',
  prodpycpu:            'function(doc) { emit(doc._id, doc.prodpyloadavg) }',
  prodqcpu:             'function(doc) { emit(doc._id, doc.prodqloadavg) }',
  proddbcpu:            'function(doc) { emit(doc._id, doc.proddbloadavg) }',
  prodworkerscpu:       'function(doc) { emit(doc._id, doc.prodworkersloadavg) }',
  esmemratio:           'function(doc) { emit(doc._id, doc.esmem) }',
  proddbmemratio:       'function(doc) { emit(doc._id, doc.proddbmem) }',
  prodpymemratio:       'function(doc) { emit(doc._id, doc.prodpymem) }',
  prodqmemratio:        'function(doc) { emit(doc._id, doc.prodqmem) }',
  prodworkersmemratio:  'function(doc) { emit(doc._id, doc.prodworkersmem) }',
}

_.each view_insert, (val, key) ->
  tmp =
    language: 'javascript'
    views: {}

  tmp['views']["#{key}"] = map: val

  db.insert tmp
  , "_design/#{key}", (err, body) ->
    console.log body unless err

