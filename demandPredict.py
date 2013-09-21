#!flask/bin/python

'''
demandPredict.py

Coding Challenge for Uber
Demand Prediction: Washington D.C. 

Created on Sep 20, 2013
@author: ajsmith007@gmail.com
'''

from flask import Flask, jsonify, abort, render_template, send_from_directory
import os
import jinja2
import json

VERSION = "09.21"
jinja_environment = jinja2.Environment(autoescape = True, # cgi escape set to autoescape
                                       loader=jinja2.FileSystemLoader(os.path.join(os.path.dirname(__file__), 'templates')))

app = Flask(__name__)

data = []
with open('static/data/uber_demand_prediction_challenge.json') as f:
    for line in f:
        data.append(json.loads(line))


tasks = [
    {
        'id': 1,
        'title': u'Buy groceries',
        'description': u'Milk, Cheese, Pizza, Fruit, Tylenol', 
        'done': False
    },
    {
        'id': 2,
        'title': u'Learn Python',
        'description': u'Need to find a good Python tutorial on the web', 
        'done': False
    }
]

@app.route('/')
@app.route('/index')
@app.route('/index.html')
def index():
    user = { 'nickname': 'UberReviewer' } # fake user
    return render_template('index.html',
                           title = 'Uber Code Challenge',
                           projectname = 'Demand Prediction',
                           market = 'Washington D.C.',
                           author = 'Drew Smith',
                           version = VERSION,
                           user = user)

@app.route('/demand.html')
def demand():
    user = { 'nickname': 'UberReviewer' } # fake user
    return render_template('demand.html',
                           title = 'Uber Code Challenge',
                           projectname = 'Demand Prediction',
                           subtitle = 'Demand Prediction',
                           market = 'Washington D.C.',
                           author = 'Drew Smith',
                           version = VERSION,
                           user = user)

@app.route('/api.html')
@app.route('/api')
@app.route('/api/')
@app.route('/api/v1')
@app.route('/api/v1/')
def api():
    user = { 'nickname': 'UberReviewer' } # fake user
    return render_template('api.html',
                           title = 'Uber Code Challenge',
                           projectname = 'Demand Prediction',
                           subtitle = 'API',
                           market = 'Washington D.C.',
                           author = 'Drew Smith',
                           version = VERSION,
                           user = user)

@app.route('/methodology.html')
def methodology():
    user = { 'nickname': 'UberReviewer' } # fake user
    return render_template('methodology.html',
                           title = 'Uber Code Challenge',
                           projectname = 'Demand Prediction',
                           subtitle = 'Methodology',
                           market = 'Washington D.C.',
                           author = 'Drew Smith',
                           version = VERSION,
                           user = user)

@app.route('/api/v1/tasks', methods = ['GET'])
def getTasks():
    return jsonify( { 'tasks': tasks } )

@app.route('/api/v1/tasks/<int:task_id>', methods = ['GET'])
def getTaskByID(task_id):
    task = filter(lambda t: t['id'] == task_id, tasks)
    if len(task) == 0:
        abort(404)
    return jsonify( { 'task': task[0] } )

@app.route('/api/v1/data', methods = ['GET'])
def getData():
    return jsonify( { 'data': data } )

@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'), 'img/favicon.ico')

if __name__ == '__main__':
    app.run(debug = True)