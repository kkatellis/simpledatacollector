from flask import Flask, render_template

# Import API functions
from server.api.analyzer import analyzer_api

from server.cache import cache
from server.db import db

# Flask components
MAIN  = Flask( __name__ )

def create_app( settings = 'server.settings.Dev' ):
    MAIN.config.from_object( settings )
    
    # Initialize db/cache with app
    db.init_app( MAIN )
    cache.init_app( MAIN )
    
    # Register apis
    MAIN.register_blueprint( analyzer_api, url_prefix='/api' )
        
    return MAIN

@MAIN.route( '/' )
@MAIN.route( '/index.html' )
def index():
    return render_template( 'index.html' )
