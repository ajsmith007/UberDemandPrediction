UberDemandPrediction
====================

Regional Demand Prediction for Private Car Service estimated from Mobile App data. 

This project looks at the overall regional demand for private car services in the Washington DC metropolitain area as a function of time. Demand is estimated from mobile app data (specifically when a user opens the application) which is used as a proxy for near term driver demand. The data does not contain GPS positions.

Data processing, analysis and visualizations are included in a local webapp server (Flask) and the predictions are distributed in JSON via a RESTful API.

Instructions for running he server are included for both Linux and Windows in the virtualenv_instructions.txt
