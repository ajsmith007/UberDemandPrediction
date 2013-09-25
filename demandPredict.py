#!flask/bin/python

'''
demandPredict.py

Coding Challenge for Uber
Demand Prediction: Washington D.C. 

Created on Sep 20, 2013
Completed on Sep 24, 2013
@author: ajsmith007@gmail.com
'''

from flask import Flask, jsonify, render_template, send_from_directory, request, make_response
import os
import jinja2
import datetime
import json
import csv

VERSION = "2013.09.24"
jinja_environment = jinja2.Environment(autoescape = True, # cgi escape set to autoescape
                                       loader=jinja2.FileSystemLoader(os.path.join(os.path.dirname(__file__), 'templates')))

app = Flask(__name__)

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

# Prep Data and Demand Prediction Model
def predictFutureDemand(self, dt):
    # Model of future demand from input datetime
    prediction = 99         # prediction placeholder
    
    # Prediction Linear Model
    #
    #
    #
    #
    predictionLinear = 99

    # Prediction Regression Tree Model
    #
    #
    #
    #
    predictionTree = 99
    
    return prediction  
      
def generatePredictionVars(self, futuredt):
    # Convert input ISO format datetime "2012-05-01T00:00:00" to python datetime (dt) object
    import dateutil.parser
    dt = dateutil.parser.parse(futuredt)
        
    # Computed derived vars for predict model
    doe = dt - datetime.datetime.utcfromtimestamp(0)
#         epoch = datetime.datetime.utcfromtimestamp(0)
#         #print epoch
#         #1970-01-01 00:00:00
#         #today = datetime.datetime.today()
#         d = today - epoch
#         #print d
#         #13196 days, 9:50:44.266200
#         #print d.days # timedelta object
#         #13196
    
    doy = dt.timetuple().tm_yday
    dow = dt.strftime("%A")
    n_dow = dt.isoweekday()
    
    prediction = predictFutureDemand(dt)
    
    # Compile results into a dict
    results = {'doe': doe.day,
               'doy': doy,
               'dow': dow,
               'n_dow': n_dow,
               'prediction': prediction
    }
    
    # Return json object of prediction with derived vars
    return jsonify(results)


# Error Responses
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

# favicon
@app.route('/favicon.ico')
def favicon():
    return send_from_directory(os.path.join(app.root_path, 'static'), 'img/favicon.ico')


# Main
if __name__ == '__main__':
    app.run(debug = True)
