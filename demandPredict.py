#!flask/bin/python
'''
########################################################################################
demandPredict.py

Coding Challenge for Uber
Demand Prediction: Washington D.C. 

__author__ = "Drew Smith" 
__email__ = "ajsmith007@gmail.com"
__version__ = "1.0.0"
__status__ = "Demonstration"
__copyright__ = Copyright 2013, Drew Smith"

Assigned on: Sept 18, 2013
Created on: Sep 20, 2013
Completed on: Sep 26, 2013

########################################################################################
'''
from flask import Flask, jsonify, render_template, send_from_directory, request, make_response
import os
import jinja2
import datetime
import json
import csv
import dateutil.parser, dateutil.tz

########################################################################################
VERSION = "2013.09.26"
jinja_environment = jinja2.Environment(autoescape = True, # cgi escape set to autoescape
                                       loader=jinja2.FileSystemLoader(os.path.join(os.path.dirname(__file__), 'templates')))

app = Flask(__name__)

########################################################################################
# Original and Derived Data
data = []
with open('static/data/uber_demand_prediction_challenge.json') as f:
    for line in f:
        data.append(json.loads(line))

# Modeled Intercepts [r][c] = [d][h]
intercept = []
intercept_file = 'static/data/intercept.csv'
csvReader = csv.reader(open(intercept_file, 'rb'), delimiter=',', quotechar='|')
for row in csvReader:
    intercept.append(row)
# access elements by index [dow][hr]: print intercept[6][10] = Saturday 1000 localtime
 
# Modeled Intercepts [r][c] = [d][h]
slope = []
slope_file = 'static/data/slope.csv'
csvReader = csv.reader(open(slope_file, 'rb'), delimiter=',', quotechar='|')
for row in csvReader:
    slope.append(row)
# access elements by index: print slope[0][1] = Sunday 0100 localtime

########################################################################################
# Empty Class to hold prediction variables
class Prediction:
    pass

########################################################################################
# Prep Data and Demand Prediction Model
def predictFutureDemand(inputStr):
    # Model of future demand from input utc datetime
    prediction = Prediction()
    # Convert input ISO format datetime "2012-05-01T00:00:00" to python datetime object
    prediction.datetime_utc = dateutil.parser.parse(inputStr)
    # Compute which Day of Epoch (doe)
    doeObj = prediction.datetime_utc - datetime.datetime.utcfromtimestamp(0)
    prediction.doe = int(doeObj.days)
    # Convert input UTC time to local date time
    WASHDC = dateutil.tz.gettz('America/New_York')
    UTC = dateutil.tz.gettz('UTC') 
    prediction.utc_dt = prediction.datetime_utc.replace(tzinfo=UTC)
    prediction.local_dt = prediction.utc_dt.astimezone(WASHDC)
    # Extract which Day of the Week as numeric (1=Mon, .., 7=Sun etc)
    wkday = prediction.local_dt.weekday()
    if (wkday == 7):            # coeff table has 0=Sun, 1=Mon, ..., etc
        prediction.dow = 0
    else:
        prediction.dow = int(wkday)
    # Extract which Hour of the Day (0-23)
    prediction.hr = int(prediction.local_dt.strftime("%H"))
    # Look up Linear Model Coefficents
    prediction.b = intercept[prediction.dow][prediction.hr]
    prediction.m = slope[prediction.dow][prediction.hr]
    # Compute Demand Prediction from the RLM for the given UTC date and time in pp.pp 
    prediction.demand = float(prediction.m)*float(prediction.doe) + float(prediction.b)
    return prediction  

########################################################################################
# Error Responses
@app.errorhandler(400)
def not_found400(error):
    return make_response(jsonify( { 'error': 'Bad request' } ), 400)
 
@app.errorhandler(404)
def not_found404(error):
    return make_response(jsonify( { 'error': 'Not found' } ), 404)

########################################################################################
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
                           title = 'Uber Demand Prediction Challenge',
                           market = 'Market',
                           location = 'Washington D.C.',
                           author = 'Drew Smith',
                           #userID = user.user_id(),
                           #userNickname = user.nickname(),
                           version = VERSION,
                           user = user)

@app.route('/results.html')
def results():
    user = { 'nickname': 'UberReviewer' } # fake user - pull from OAuth login
    return render_template('results.html',
                           title = 'Uber Demand Prediction Challenge',
                           subtitle = 'Results',
                           market = 'Market',
                           location = 'Washington D.C.',
                           author = 'Drew Smith',
                           version = VERSION,
                           user = user)

@app.route('/methodology.html')
def methodology():
    user = { 'nickname': 'UberReviewer' } # fake user - pull from OAuth login 
    return render_template('methodology.html',
                           title = 'Uber Demand Prediction Challenge',
                           subtitle = 'Methodology',
                           market = 'Market',
                           location = 'Washington D.C.',
                           author = 'Drew Smith',
                           version = VERSION,
                           user = user)

@app.route('/api.html')
@app.route('/api/')
@app.route('/api/v1/')
def api():
    user = { 'nickname': 'UberReviewer' } # fake user - pull from OAuth login
    return render_template('api.html', 
                           title = 'Uber Demand Prediction Challenge',
                           subtitle = 'API',
                           market = 'Market',
                           location = 'Washington D.C.',
                           author = 'Drew Smith',
                           version = VERSION,
                           user = user)


# API calls
@app.route('/api/v1/data', methods = ['GET'])
def getData():
    return jsonify( { 'data': data } )

@app.route('/api/v1/model', methods = ['GET'])
def getModel():
    return jsonify(slope=slope, intercept=intercept)

@app.route('/api/v1/prediction', methods = ['GET'])
def getPrediction():
    queryStr = request.args.get('q')
    if len(queryStr) == 0:
        return make_response(jsonify( { 'error': 'Not found' } ), 404) #abort(404) 
    # Might need to check that the format of queryStr is valid ISO date time
    if len(queryStr) != 19:
        return make_response(jsonify( { 'error': 'Bad request' } ), 400) # malformed GET request
    
    demand = predictFutureDemand(queryStr)
    demandPrediction = demand.demand
    return jsonify( {"UberDemandPrediction": [{'datetime': queryStr,
                                               'datetime_utc': demand.datetime_utc,
                                               'doe': demand.doe,
                                               'utc_dt': demand.utc_dt,
                                               'local_dt':demand.local_dt,
                                               'dow':demand.dow,
                                               'hr':demand.hr,
                                               'b': demand.b,
                                               'm':demand.m,
                                               'demand': demandPrediction}] })

# favicon
@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'), 'img/favicon.ico')

########################################################################################
# Main
if __name__ == '__main__':
    app.run(debug = True)
