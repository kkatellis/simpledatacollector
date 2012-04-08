'''
settings.py
    
Contains the settings for the Flask application. 
See http://flask.pocoo.org/docs/config/ for more details. 
'''

import os

class Config( object ):
    DEBUG = False
    TESTING = False
    SECRET_KEY = 'CHANGE THIS!!!!!'
    CACHE_TYPE = 'simple'

class Dev( Config ):
    DEBUG = True
    #SQLALCHEMY_DATABASE_URI = 'sqlite:///../tmp/dev.db'
    classpath = os.getcwd() + '/scripts/ActivityAnalyzer/bin'
    ANALYZER_PATH = 'java -classpath "' + classpath + '" ActivityAnalyzer %s'

class Production( Config ):
    #SQLALCHEMY_DATABASE_URI = 'sqlite:///../tmp/dev.db'
    ANALYZER_PATH = 'java -classpath "/Library/WebServer/Documents/rmw/scripts/ActivityAnalyzer/bin" ActivityAnalyzer %s'

class Testing( Config ):
    TESTING = True