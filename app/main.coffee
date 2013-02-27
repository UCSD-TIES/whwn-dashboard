routes = require './routes'
app = module.exports = require './config'

# Routes

app.get '/', routes.index
app.get '/setup', routes.setupGET
app.post '/setup', routes.setupPOST
