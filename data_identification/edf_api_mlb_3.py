import os
import re
import sys
import pickle
import json
from random import *    
from nltk.corpus import stopwords

reload(sys)  
sys.setdefaultencoding('utf8')
    
stop_words = stopwords.words('french')

from treetagger import TreeTagger
tt = TreeTagger(language='french')
seed(942)

from flask import Flask
from flask import request
app = Flask(__name__)

@app.route("/estimate_trt", methods=['GET', 'POST'])
def estimate_trt():    
    estimate = mlb_estimate(request.form['us'], './mlb_model_1.obj')     
    return json.dumps(estimate)

@app.route("/estimate_data", methods=['GET', 'POST'])
def estimate_data():    
    file_us = open("tmp.txt", "w")
    file_us.write(request.form['txt'])    
    os.system('python do-concord.py -c unitex-fr.yaml -g patterns/motif_data_global.fst2 tmp.txt')
    lines = tuple(open('spec-presage-concordances.txt', 'r'))
    return json.dumps(lines)

@app.route("/", methods=['GET', 'POST'])
def welcome():
    return "Welcome !"

### Estimate
def mlb_estimate(userStory, mlb_model_url):
    mlb_model= pickle.load(open(mlb_model_url, 'rb'))
    mlb_binarizer= mlb_model.mlb_binarizer
    vectorizer=mlb_model.vectorizer
    model_feature=mlb_model.model_feature
    model_fit=mlb_model.model_fit
    vector_features= tranform_userStory (userStory, model_feature, vectorizer)
    result_bin= model_fit.predict(vector_features)
    mlb_pred=mlb_binarizer.inverse_transform(result_bin)[0]
    return mlb_pred


def tranform_userStory (userStory, model_feature, vectorizer):
    words= clean_text(userStory).split()
    print words
    #Remove stop words from "words"
    stops = set(stopwords.words("french"))       
    meaningful_words = ' '.join([w for w in words if not w in stops])
    print meaningful_words  
    vector=vectorizer.transform([meaningful_words])
    vector_features=model_feature.transform(vector).toarray()
    return vector_features



def clean_text(line):
    line= re.sub("[0-9]", " ", line.replace(",", "").replace("\\","").replace('"', '').replace('|','').replace('\r', '').replace('\n', '')).lower()
    line_cl=""
    stemmed_us= tt.tag(line) ### Tagging (lematization) using tree tagger
    for w in stemmed_us:
        if len(w[0])>2:
            if not str(w[2])=='<unknown>':
                line_cl+=" "+ str(w[2])
            else:
                line_cl+=" "+ str(w[0])
    return line_cl

# Class of model
class Mlb_Model_class:
    def __init__(self, model_fit, mlb_binarizer, model_feature, vectorizer):
        self.model_fit=model_fit
        self.mlb_binarizer=mlb_binarizer
        self.vectorizer=vectorizer
        self.model_feature=model_feature

if __name__ == "__main__":
    app.run(port=5001)