#!flask/bin/python

'''
demandPredict.py

Coding Challenge for Uber
Demand Prediction: Washington D.C. 

Created on Sep 20, 2013
@author: ajsmith007@gmail.com
'''

from flask import Flask, jsonify, render_template, send_from_directory, request, make_response
import os
import jinja2
import json

VERSION = "2013.09.23"
jinja_environment = jinja2.Environment(autoescape = True, # cgi escape set to autoescape
                                       loader=jinja2.FileSystemLoader(os.path.join(os.path.dirname(__file__), 'templates')))

app = Flask(__name__)

# Original and Derived Data
data = []
with open('static/data/uber_demand_prediction_challenge.json') as f:
    for line in f:
        data.append(json.loads(line))
 
#with open('static/data/uber_demand_prediction_challenge_model.json') as json_file:    
#    model = json.load(json_file)

# Temporary Data
prediction = [
    {
        'year': 2012,
        'month': 4,
        'day': 30,
        'hour': 20,
        'doy': 121,
        'dow': u'Monday',
        'n_dow': u'1-Monday',
        'date': u'04-30-2012',
        'datetime_et': u'04-30-2012T20:00:00 EST',
        'datetime_utc': u'05-01-2012T00:00:00 UTC',
        'datetime': u'05-01-2012T00:00:00',
        'prediction': 33.02
    },
    {
        'year': 2012,
        'month': 4,
        'day': 30,
        'hour': 21,
        'doy': 121,
        'dow': u'Monday',
        'n_dow': u'1-Monday',
        'date': u'04-30-2012',
        'datetime_et': u'04-30-2012T21:00:00 EST',
        'datetime_utc': u'05-01-2012T01:00:00 UTC',
        'datetime': u'05-01-2012T01:00:00',
        'prediction': 42.96
    },
    {
        'year': 2012,
        'month': 4,
        'day': 30,
        'hour': 22,
        'doy': 121,
        'dow': u'Monday',
        'n_dow': u'1-Monday',
        'date': u'04-30-2012',
        'datetime_et': u'04-30-2012T22:00:00 EST',
        'datetime_utc': u'05-01-2012T02:00:00 UTC',
        'datetime': u'05-01-2012T02:00:00',
        'prediction': 12.03
    },
    {
        'year': 2012,
        'month': 4,
        'day': 30,
        'hour': 23,
        'doy': 121,
        'dow': u'Monday',
        'n_dow': u'1-Monday',
        'date': u'04-30-2012',
        'datetime_et': u'04-30-2012T23:00:00 EST',
        'datetime_utc': u'05-01-2012T03:00:00 UTC',
        'datetime': u'05-01-2012T03:00:00',
        'prediction': 10.6
    },
    {
        'year': 2012,
        'month': 5,
        'day': 1,
        'hour': 0,
        'doy': 122,
        'dow': u'Tuesday',
        'n_dow': u'2-Tuesday',
        'date': u'05-01-2012',
        'datetime_et': u'05-01-2012T00:00:00 EST',
        'datetime_utc': u'05-01-2012T04:00:00 UTC',
        'datetime': u'05-01-2012T04:00:00',
        'prediction': 6.05
    },
]


# Errors
@app.errorhandler(400)
def not_found400(error):
    return make_response(jsonify( { 'error': 'Bad request' } ), 400)
 
@app.errorhandler(404)
def not_found404(error):
    return make_response(jsonify( { 'error': 'Not found' } ), 404)

# Routes
@app.route('/')
@app.route('/index/')
@app.route('/index.html')
def index():
#    # Get current user
#    user = users.get_current_user()
#    if user:
#             if users.is_current_user_admin():
#                 admin = True
#                 # Include Admin Functions
    user = { 'nickname': 'UberReviewer' } # fake user - pull from OAuth login
    return render_template('index.html',
                           title = 'Uber Code Challenge',
                           projectname = 'Demand Prediction',
                           market = 'Washington D.C.',
                           author = 'Drew Smith',
                           #userID = user.user_id(),
                           #userNickname = user.nickname(),
                           version = VERSION,
                           user = user)

@app.route('/demand.html')
def demand():
    user = { 'nickname': 'UberReviewer' } # fake user - pull from OAuth login
    return render_template('demand.html',
                           title = 'Uber Code Challenge',
                           projectname = 'Demand Prediction',
                           subtitle = 'Demand Prediction',
                           market = 'Washington D.C.',
                           author = 'Drew Smith',
                           version = VERSION,
                           user = user)

@app.route('/methodology.html')
def methodology():
    user = { 'nickname': 'UberReviewer' } # fake user - pull from OAuth login 
    return render_template('methodology.html',
                           title = 'Uber Code Challenge',
                           projectname = 'Demand Prediction',
                           subtitle = 'Methodology',
                           market = 'Washington D.C.',
                           author = 'Drew Smith',
                           version = VERSION,
                           user = user)

@app.route('/api.html')
@app.route('/api/')
@app.route('/api/v1/')
def api():
    user = { 'nickname': 'UberReviewer' } # fake user - pull from OAuth login
    return render_template('api.html', 
                           title = 'Uber Code Challenge',
                           projectname = 'Demand Prediction',
                           subtitle = 'API',
                           market = 'Washington D.C.',
                           author = 'Drew Smith',
                           version = VERSION,
                           user = user)

@app.route('/api/v1/data', methods = ['GET'])
def getData():
    return jsonify( { 'data': data } )

@app.route('/api/v1/model', methods = ['GET'])
def getModel():
    return model

@app.route('/api/v1/prediction', methods = ['GET'])
def getPrediction():
    if request.method == 'GET':
        return jsonify( { 'prediction': prediction } )
    return make_response(jsonify( { 'error': 'Not found' } ), 404) #abort(404) #  GET request not included
    
@app.route('/api/v1/prediction/<datetime>', methods = ['GET'])
def getPredictionDateTime(datetime):
    predict = filter(lambda t: t['datetime'] == datetime, prediction)
    if len(predict) == 0:
        return make_response(jsonify( { 'error': 'Not found' } ), 404) #abort(404) #  datetime not found
    return jsonify( { 'prediction': predict[0] } )

@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'), 'img/favicon.ico')

# Main
if __name__ == '__main__':
    app.run(debug = True)
