#!flask/bin/python

'''
demandPredict.py

Demand prediction coding challenge for Uber
    - 

Created on Sep 20, 2013
@author: ajsmith007@gmail.com
'''

from flask import Flask, jsonify, abort

app = Flask(__name__)

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
def index():
    return "Hello Flask World!"

@app.route('/api/v1/tasks', methods = ['GET'])
def getTasks():
    return jsonify( { 'tasks': tasks } )

@app.route('/api/v1/tasks/<int:task_id>', methods = ['GET'])
def getTaskByID(task_id):
    task = filter(lambda t: t['id'] == task_id, tasks)
    if len(task) == 0:
        abort(404)
    return jsonify( { 'task': task[0] } )

if __name__ == '__main__':
    app.run(debug = True)