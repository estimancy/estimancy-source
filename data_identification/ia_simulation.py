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
    res = ia_based_sizing_control("Update an employee")
    return json.dumps(res)

##########################################################################################
##                                Simple simulation                                     ##
##########################################################################################
def ia_based_sizing_control (userStory):
    ### path to be modified for the use in the server
    csvFile="/Users/nicolasrenard/Estimancy/estimancy/data_identification/simulation_DB.csv"
    with open(csvFile, "rt") as csvfile:
        data = csv.DictReader(csvfile, delimiter=',', quotechar='\"')
        #  Read file
        data = list(data)
        print(data)
        i=0
        UOs="UNKNOWN".split(' ')
        for line in data :
            if (line['Functional requirement']!='' and line['UO type'] !=''):
                if line['Functional requirement']==userStory:
                    print ("found")
                    UOs=line['UO type'].strip("()").split(' ')
    return (UOs)

if __name__ == "__main__":
    app.run(port=5001)



                    