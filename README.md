UberDemandPrediction
====================

Regional Demand Prediction for Private Car Service estimated from Mobile App data. 

This project looks at the overall regional demand for private car services in the Washington DC metropolitain area as a function of time. Demand is estimated from mobile app data (specifically when a user opens the application) which is used as a proxy for near term driver demand. The data does not contain individual GPS positions and the users have been anonomized.

Data processing, analysis and visualization was done in R. The presentation utilizes a light web framework built on Flask, Jinja2 and Bootstrap.css. The predictions are distributed in JSON via a RESTful API using Python.

Instructions for running the server are included for both Linux and Windows in the virtualenv_instructions.txt
