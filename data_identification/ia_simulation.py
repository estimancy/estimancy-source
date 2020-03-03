import os
import re
import sys
import pickle

import csv
import json

from flask import Flask
from flask import request
app = Flask(__name__)

@app.route("/ia_based_sizing_control", methods=['GET', 'POST'])
def ia_based_sizing_control():
    res = ia_based_sizing_control(request.form['us'])
    return json.dumps(res)

##########################################################################################
##                                Simple simulation                                     ##
##########################################################################################
def ia_based_sizing_control (userStory):
    ### path to be modified for the use in the server
    csvFile="./simulation_DB.csv"
    with open(csvFile, "rt") as csvfile:
        data = csv.DictReader(csvfile, delimiter=',', quotechar='\"')
        #  Read file
        data = list(data)    
        i=0
        UOs = "UNKNOWN"
        for line in data :
            if (line['FR']!='' and line['UOT']!=''):
                if line['FR'] == userStory:                
                    UOs = line['UOT']
    return (UOs)

if __name__ == "__main__":
    app.run(port=5001)



                    