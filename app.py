import os
import datetime
import time
import paramiko
from flask import Flask
from flask import render_template
from flask import flash, request, redirect, url_for
from flaskext.couchdb import (CouchDBManager, Document, TextField, DateTimeField, ViewField, paginate)

#Application Setup
app = Flask(__name__)


#CouchDB Config files
COUCHDB_SERVER = os.environ['CLOUDANT_URL']
COUCHDB_DATABASE = 'wstats'

app.config.from_object(__name__)

#model
class wstat(Document):
    serverRequest = TextField()
    doctype = serverRequest
    ctime = DateTimeField(default=datetime.datetime.now)
    dataStore = TextField()

    all = ViewField('wdata', '''
        function (doc) {
            if (doc.doc_type == 'wstats') {
                emit(doc.ctime, doc);
            };
        }''', descending=True)

manager = CouchDBManager()
manager.add_document(wstat)
manager.setup(app)


@app.route("/")
def index():
    page = paginate(wstat.all(), 5, request.args.get('start'))
    return render_template('index.html', page=page)

@app.route('/', methods=['POST'])
def post():
    #Grabs server parameters and requests
    serverUsage = request.form.get('server')
    serverRequest = request.form.get('mytype')
    if serverUsage == "PD":
        envhost = os.environ['PROD_SSH_HOST']
        envport = os.environ['PROD_DB_SSH_PORT']
        envuser = os.environ['PROD_DB_SSH_USER']
        envprivatekey = os.environ['dotcloudPRIVATEKEY']
    if serverUsage == "PP":
        envhost = os.environ['PROD_SSH_HOST']
        envport = os.environ['PROD_PY_SSH_PORT']
        envuser = os.environ['PROD_PY_SSH_USER']
        envprivatekey = os.environ['dotcloudPRIVATEKEY']
    if serverUsage == "PQ":
        envhost = os.environ['PROD_SSH_HOST']
        envport = os.environ['PROD_Q_SSH_PORT']
        envuser = os.environ['PROD_Q_SSH_USER']
        envprivatekey = os.environ['dotcloudPRIVATEKEY']
    if serverUsage == "PW":
        envhost = os.environ['PROD_SSH_HOST']
        envport = os.environ['PROD_WORKERS_SSH_PORT']
        envuser = os.environ['PROD_WORKERS_SSH_USER']
        envprivatekey = os.environ['dotcloudPRIVATEKEY']
    if serverUsage == "SD":
        envhost = os.environ['STAGING_SSH_HOST']
        envport = os.environ['STAGING_DB_SSH_PORT']
        envuser = os.environ['STAGING_DB_SSH_USER']
        envprivatekey = os.environ['dotcloudPRIVATEKEY']
    if serverUsage == "SP":
        envhost = os.environ['STAGING_SSH_HOST']
        envport = os.environ['STAGING_PY_SSH_PORT']
        envuser = os.environ['STAGING_PY_SSH_USER']
        envprivatekey = os.environ['dotcloudPRIVATEKEY']
    if serverUsage == "SQ":
        envhost = os.environ['STAGING_SSH_HOST']
        envport = os.environ['STAGING_Q_SSH_PORT']
        envuser = os.environ['STAGING_Q_SSH_USER']
        envprivatekey = os.environ['dotcloudPRIVATEKEY']
    if serverUsage == "SW":
        envhost = os.environ['STAGING_SSH_HOST']
        envport = os.environ['STAGING_WORKERS_SSH_PORT']
        envuser = os.environ['STAGING_WORKERS_SSH_USER']
        envprivatekey = os.environ['dotcloudPRIVATEKEY']
    if serverUsage == "ES":
        envhost = os.environ['EC2_ES_SSH_HOST']
        envport = 22
        envuser = os.environ['EC2_ES_SSH_USER']
        envprivatekey = os.environ['ec2PRIVATEKEY']
    #Gets the load average in number form . 0.00
    if serverRequest == "CL":
        SSHCOMMAND="w | head -1 | awk '{print $11}' | rev | cut -b 2- | rev"
    #Getse CPU in a string Cpu(s): 0.0%us, 0.0%sy, 0.0%id, 0.0%wa, 0.0%hi,0.0%si, %.2%st
    if serverRequest == "CU":
        SSHCOMMAND="top | head -3 | tail -1"
    #Gets Top Data
    if serverRequest == "TP": 
        SSHCOMMAND="top -n 1 -b"
    if serverRequest == "MM":
        SSHCOMMAND="free -m | head -2 | tail -1 | awk '{print $3}'"
    if serverRequest == "MF":
        SSHCOMMAND="free -m | head -2 | tail -1 | awk '{print $4}'"

    #Grabs wstat 
    #Creates a SSH tunnel to grab data 
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=envhost, port=int(envport), username=envuser, pkey=envprivatekey)
    ssh_stdin, ssh_stdout, ssh_stderr = ssh.exec_command(SSHCOMMAND)
    exit_status = ssh_stdout.channel.recv_exit_status()

    dataStore = ssh_stdout.read().strip()
    
    wStat = wstat(dataStore=dataStore, serverRequest=serverRequest)
    wStat.store()

    return redirect(url_for('index'))


if __name__ == "__main__":
	port = int(os.environ.get('PORT', 5000))
        app.debug = True
	app.run(host='0.0.0.0', port=port)
