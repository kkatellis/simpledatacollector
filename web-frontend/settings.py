import os
# Some helper methods
here = lambda * x: os.path.join(os.path.abspath(os.path.dirname(__file__)), *x)
root = lambda * x: os.path.join(os.path.abspath(PROJECT_ROOT), *x)
PROJECT_ROOT = here('..')

# DEBUG Settings
APP_DEBUG = True

# Testing DB
DB_HOST = 'localhost'
DB_USER = 'development'
DB_NAME = 'thehack'

STATIC_PATH = root( 'frontend', 'static' )