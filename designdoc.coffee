nano = require("nano")('http://localhost:5984')
nano.db.create('wstats')
db_name = "wstats"
db = nano.use(db_name)

db.insert 
    language: 'javascript'
    views: 
      stagedbcpu: 
        map: 'function(doc) {emit (doc._id, doc.stagedbloadavg) }'
, '_design/stagedbcpu', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      stagepycpu: 
        map: 'function(doc) { emit(doc._id, doc.stagepyloadavg) }'
, '_design/stagepycpu', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      stageqcpu: 
        map: 'function(doc) { emit(doc._id, doc.stageqloadavg) }'
, '_design/stageqcpu', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      stageworkerscpu: 
        map: 'function(doc) { emit(doc._id, doc.stageworkersloadavg) }'
, '_design/stageworkerscpu', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      escpu: 
        map: 'function(doc) { emit(doc._id, doc.esloadavg) }'
, '_design/escpu', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      prodpycpu: 
        map: 'function(doc) { emit(doc._id, doc.prodpyloadavg)}'
, '_design/prodpycpu', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      prodqcpu: 
        map: 'function(doc) { emit(doc._id, doc.prodqloadavg) }'
, '_design/prodqcpu', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      proddbcpu: 
        map: 'function(doc) { emit(doc._id, doc.proddbloadavg) }'
, '_design/proddbcpu', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      prodworkerscpu: 
        map: 'function(doc) { emit(doc._id, doc.prodworkersloadavg) }'
, '_design/prodworkerscpu', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      esmemratio: 
        map: 'function(doc) { emit(doc._id, doc.esmem) }'
, '_design/esmemratio', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      proddbmemratio: 
        map: 'function(doc) { emit(doc._id, doc.proddbmem) }'
, '_design/proddbmemratio', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      prodpymemratio: 
        map: 'function(doc) { emit(doc._id, doc.prodpymem) }'
, '_design/prodpymemratio', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      prodqmemratio: 
        map: 'function(doc) { emit(doc._id, doc.prodqmem) }'
, '_design/prodqmemratio', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      prodworkersmemratio: 
        map: 'function(doc) { emit(doc._id, doc.prodworkersmem) }'
, '_design/prodworkersmemratio', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      stagedbmemratio: 
        map: 'function(doc) { emit(doc._id, doc.stagedbmem) }'
, '_design/stagedbmemratio', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      stagepymemratio: 
        map: 'function(doc) { emit(doc._id, doc.stagepymem) }'
, '_design/stagepymemratio', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      stageqmemratio: 
        map: 'function(doc) { emit(doc._id, doc.stageqmem) }'
, '_design/stageqmemratio', (err, body) ->
  console.log body unless err

db.insert 
    language: 'javascript'
    views: 
      stageworkersmemratio: 
        map: 'function(doc) { emit(doc._id, doc.stageworkersmem) }'
, '_design/stageworkersmemratio', (err, body) ->
  console.log body unless err
###