nano = require("nano")("http://localhost:5984")
alice = nano.use('rwar')
moo = ""
cow = ""
alice.get 'time',
  (err, body) ->
    moo = body
    cow =  moo.crazy unless err

console.log cow
