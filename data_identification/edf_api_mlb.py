import numpy as np
import re
import nltk
import csv
import sys
import pickle
import nltk
import codecs
import json
from random import *    
from nltk.tokenize import WhitespaceTokenizer
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import TfidfVectorizer
from docx import Document
from sklearn import cross_validation
from nltk.stem.snowball import FrenchStemmer
from sklearn.ensemble import ExtraTreesClassifier
from sklearn.feature_selection import SelectFromModel
from sklearn.model_selection import GridSearchCV
from sklearn.svm import LinearSVC
from sklearn import svm
from sklearn import tree
from sklearn.preprocessing import MultiLabelBinarizer

reload(sys)  
sys.setdefaultencoding('utf8')
    
stop_words = stopwords.words('french')
wst = WhitespaceTokenizer()
stemmer = FrenchStemmer()

from treetagger import TreeTagger
tt = TreeTagger(language='french')
seed(942)

from flask import Flask
from flask import request
app = Flask(__name__)

@app.route("/estimate", methods=['GET', 'POST'])
def estimate():    
    estimate = mlb_estimate(request.form['us'], './mlb_model_1.obj')     
    return json.dumps(estimate)

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


### Prepare dataset to multilabel classification
### Cas plusieurs UOs pour chaque exigence
def dataset_mlb_process(UO_list):
    mlb = MultiLabelBinarizer()
    Binarized_out=mlb.fit_transform(UO_list)
    return Binarized_out

def get_mlb_stat(UO_list, Binarized):
    UO_stat=[]
    comb= [[x,y,z] for x in [0,1] for y in [0,1] for z in [0,1]]
    for UO in UO_list:
        for i in UO:
            UO_stat.append(i)
    my_series = pandas.Series(UO_stat)
    freq_sl= my_series.value_counts()
    def get_lists_freq(Binarized, comb):
        freq=[]
        for i in comb:
            k=0
            for j in Binarized:
                if (j==i).all():
                    k=k+1
            freq.append(k)
        return freq
    freq_mlb= get_lists_freq(Binarized, comb)
    return(freq_sl, freq_mlb)

    #scipy.stats.describe(Binarized)


### Balance the dataset

def balance_dataset(intRedVect, UO_list):
    intBal=[]
    outBal=[]
    comb= [[x,y,z] for x in [0,1] for y in [0,1] for z in [0,1]]
    mlb = MultiLabelBinarizer()
    Binarized = mlb.fit_transform(UO_list)
    def mlb_to_nsl_transform(Binarized, comb):
        Binarized_nsl=[]
        cat=range(0,len(comb))
        for i in Binarized:
            for j in range(0, len(comb)-1):
                if (i==comb[j]).all():
                    Binarized_nsl.append(cat[j])
        return Binarized_nsl
    def nsl_to_mlb_transform(Binarized_nsl, comb):
        OutMlbBin_bal=[]
        cat=range(0,len(comb))
        for i in Binarized_nsl:
            for j in range(0, len(comb)-1):
                if i==cat[j]:
                    OutMlbBin_bal.append(comb[j])
        OutMlbBin_bal=np.asarray(OutMlbBin_bal)
        return OutMlbBin_bal
    Binarized_nsl= mlb_to_nsl_transform(Binarized, comb)
    ros = RandomOverSampler()
    X_resampled, y_resampled = ros.fit_sample(intRedVect, Binarized_nsl)
    # Apply SMOTE SVM
    #sm = SMOTE(kind='regular')
    #X_resampled, y_resampled = sm.fit_sample(intRedVect, Binarized_nsl)
    OutMlbBin_bal=nsl_to_mlb_transform(y_resampled, comb)
    intRedVect_bal=X_resampled
    combined = list(zip(intRedVect_bal, OutMlbBin_bal))
    shuffle(combined)
    intBal[:], outBal[:] = zip(*combined)
    intRedVect_bal=np.asarray(intBal)
    OutMlbBin_bal=np.asarray(outBal)
    return(mlb, intRedVect_bal, OutMlbBin_bal)
    # frequence of each case



### Evaluate DT model multi label classification on balanced Dataset using over sampling

def DT_mlb_unbal(intRedVect_bal, OutMlbBin_bal):
    clf=OneVsRestClassifier(tree.DecisionTreeClassifier(random_state=519))
    scores = cross_validation.cross_val_score(clf, intRedVect_bal, OutMlbBin_bal, cv=10, scoring= 'accuracy')
    accuracy=np.mean(scores)
    modelFitted=OneVsRestClassifier(tree.DecisionTreeClassifier(random_state=519)).fit(intRedVect_bal, OutMlbBin_bal)
    return (accuracy, modelFitted)


# Class of model
class Mlb_Model_class:
    def __init__(self, model_fit, mlb_binarizer, model_feature, vectorizer):
        self.model_fit=model_fit
        self.mlb_binarizer=mlb_binarizer
        self.vectorizer=vectorizer
        self.model_feature=model_feature




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


if __name__ == "__main__":
    app.run(port=5001)
