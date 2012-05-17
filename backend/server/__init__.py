import pymongo

from flask import Flask, render_template, request

# Import API functions
from server.api.analyzer import analyzer_api
from server.api.misc import misc_api

from server.cache import cache
from server.db import db

# Flask components
MAIN  = Flask( __name__ )

def gunicorn_app( environ, start_response ):
	return MAIN( environ, start_response )

def create_app( settings = 'server.settings.Dev' ):
    MAIN.config.from_object( settings )
    
    # Initialize db/cache with app
    db.init_app( MAIN )
    cache.init_app( MAIN )
    
    # Register apis
    MAIN.register_blueprint( analyzer_api, url_prefix='/api' )
    MAIN.register_blueprint( misc_api, url_prefix='/api' )
        
    return MAIN

@MAIN.route( '/stats/search', methods=[ 'GET' ] )
def stats_search():
    connection = pymongo.Connection()
    rmwdb = connection[ 'rmw' ]
    feedback = rmwdb.feedback

    uuid = request.args.get( 'uuid', '' )
    results = feedback.find( {'uuid': { '$regex': '%s*.' % ( uuid ) } } ).sort( 'timestamp', direction=pymongo.DESCENDING ).limit( 100 )

    return render_template( 'stats_search.html', results=results, uuid=uuid )    


@MAIN.route( '/stats', methods=[ 'GET' ] )
def stats():
    connection = pymongo.Connection()
    rmwdb = connection[ 'rmw' ]
    feedback = rmwdb.feedback

    count  = feedback.find().count()
    recent = feedback.find().sort( 'timestamp', direction=pymongo.DESCENDING ).limit( 10 )

    return render_template( 'stats.html', count=count, recent=recent )

@MAIN.route( '/' )
@MAIN.route( '/index.html' )
def index():
    return render_template( 'index.html' )
