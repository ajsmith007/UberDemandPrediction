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
Completed on: Sep 25, 2013

########################################################################################
'''
from flask import Flask, jsonify, render_template, send_from_directory, request, make_response
import os
import jinja2
import datetime
import json
import csv
import dateutil.parser

########################################################################################
VERSION = "2013.09.25"
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
# access elements by index [dow][hr]: print intercept[6][10] = Saturday 1000
 
# Modeled Intercepts [r][c] = [d][h]
slope = []
slope_file = 'static/data/slope.csv'
csvReader = csv.reader(open(slope_file, 'rb'), delimiter=',', quotechar='|')
for row in csvReader:
    slope.append(row)
# access elements by index: print slope[0][1] = Sunday 0100

########################################################################################
# Prep Data and Demand Prediction Model
def predictFutureDemand(inputStr):
    # Model of future demand from input utc datetime
    verbose = True
    if verbose == True: print inputStr
    # Convert input ISO format datetime "2012-05-01T00:00:00" to python datetime object
    datetime_utc = dateutil.parser.parse(inputStr)
    if verbose == True: print datetime_utc
    # Compute which Day of Epoch (doe)
    doeObj = datetime_utc - datetime.datetime.utcfromtimestamp(0)
    doe = int(doeObj.days)
    if verbose == True: print doe
    # Convert input UTC time to local date time 
    local_dt = datetime_utc
    if verbose == True: print local_dt
    # Extract which Day of the Week as numeric (1=Mon, .., 7=Sun etc)
    wkday = local_dt.weekday()
    if (wkday == 7):            # coeff table has 0=Sun, 1=Mon, ..., etc
        dow = 0
    else:
        dow = int(wkday)
    #dow = 0    # debugging
    if verbose == True: print dow
    # Extract which Hour of the Day (0-23)
    hr = int(local_dt.strftime("%H"))
    #hr = 3     # debugging
    if verbose == True: print hr
    # Look up Linear Model Coefficents
    b = intercept[dow][hr]
    if verbose == True: print b
    m = slope[dow][hr]
    if verbose == True: print m
    # Compute Demand Prediction from the RLM for the given UTC date and time in pp.pp 
    prediction = float(m)*float(doe) + float(b)
    #prediction = -99.99     # placeholder for debug
    if verbose == True: print prediction
    return prediction  
      
# def generatePrediction(self, futuredt):
#     # Convert input ISO format datetime "2012-05-01T00:00:00" to python datetime (dt) object
#     import dateutil.parser
#     utc_dt = dateutil.parser.parse(futuredt)
#         
#     # Computed derived vars for predict model
#     doe = utc_dt - datetime.datetime.utcfromtimestamp(0) # day of epoch - pass full object need to call as.numeric
# #         epoch = datetime.datetime.utcfromtimestamp(0)
# #         #print epoch
# #         #1970-01-01 00:00:00
# #         #today = datetime.datetime.today()
# #         d = today - epoch
# #         #print d
# #         #13196 days, 9:50:44.266200
# #         #print d.days # timedelta object
# #         #13196
#     local_dt = utc_dt
#     #doy = local_dt.timetuple().tm_yday
#     dow = local_dt.strftime("%A")
#     n_dow = local_dt.isoweekday()
#     hour = local_dt.strftime("%H")
#     prediction = predictFutureDemand(local_dt)
#     
#     # Tuple of prediction in a dict
#     #prediction = {'prediction': prediction}
#     
#     # Return prediction float
#     return prediction

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
    
    prediction = predictFutureDemand(queryStr)
    return jsonify( {'datetime': queryStr }, { 'prediction': prediction } )
    
# @app.route('/api/v1/prediction/<datetime>', methods = ['GET'])
# def getPredictionDateTime():
#     #predict = filter(lambda t: t['datetime'] == datetime, prediction)
#     if len(predict) == 0:
#         return make_response(jsonify( { 'error': 'Not found' } ), 404) #abort(404) #  datetime not found
#     return jsonify( { 'prediction': predict[0] } )

# favicon
@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'), 'img/favicon.ico')

########################################################################################
# Main
if __name__ == '__main__':
    app.run(debug = True)
