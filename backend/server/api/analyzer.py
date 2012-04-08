import datetime
import json
import pymongo
import shlex, subprocess

from random import randint

from flask import abort, current_app, Blueprint, request, render_template

from server.helper import get_rdio_id

analyzer_api = Blueprint( 'analyzer_api', __name__ )

GPS_FMT  = '"%f" "%f" "%f" "%s"'
ACC_FMT  = '"%f" "%f" "%f"'
GYRO_FMT = '"%f" "%f" "%f"'
MIC_FMT  = '"%f" "%f"'

@analyzer_api.route( '/has_rdio_id', methods=[ 'GET' ] )
def check_page():
    return render_template( 'idcheck.html' )

@analyzer_api.route( '/has_rdio_id', methods=[ 'POST' ] )
def check_result():
    artist = request.form[ 'artist' ]
    track  = request.form[ 'track' ]

    rdio_id = get_rdio_id( artist, track )
    if rdio_id == None:
        return json.dumps( {'success': False} )
    return json.dumps( {'success': True, 'id': rdio_id } )

@analyzer_api.route( '/analyze' )
def analyze():
    connection = pymongo.Connection()
    rmwdb = connection[ 'rmw' ]
    songs = rmwdb.songs

    try:
        prev_gps = GPS_FMT % ( float( request.args.get( 'prev_lat' ) ), 
                     float( request.args.get( 'prev_long' ) ),
                     float( request.args.get( 'prev_speed' ) ),
                     request.args.get( 'prev_timestamp' ) )

        curr_gps = GPS_FMT % ( float( request.args.get( 'lat' ) ), 
                     float( request.args.get( 'long' ) ),
                     float( request.args.get( 'speed' ) ),
                     request.args.get( 'timestamp' ) )

        acc_data = ACC_FMT % ( float( request.args.get( 'acc_x' ) ),
                            float( request.args.get( 'acc_y' ) ),
                            float( request.args.get( 'acc_z' ) ) )
                            
        gyro_dat = GYRO_FMT % ( float( request.args.get( 'gyro_x' ) ),
                            float( request.args.get( 'gyro_y' ) ),
                            float( request.args.get( 'gyro_z' ) ) )

        mic_data = MIC_FMT % ( float( request.args.get( 'mic_avg_db' )),
                                float( request.args.get( 'mic_peak_db' ) ) )
    except Exception, e:
        print e
        abort( 400 )

    # Save data if we have a UDID & tags parameters
    if 'udid' in request.args and 'tags' in request.args:
        activityData = rmwdb.activitydata

        dataObj = dict( request.args )

        # Remove GPS timestamp info before sending to database
        del( dataObj[ 'timestamp' ] )
        del( dataObj[ 'prev_timestamp' ] )

        for key in dataObj.keys():
            if 'tags' not in key and 'udid' not in key:
                dataObj[ key ] = float( dataObj[ key ][0] )
            else:
                dataObj[ key ] = dataObj[ key ][0]

        # Split up the calibrate tags
        dataObj[ 'tags' ] = [ x.strip() for x in request.args.get( 'tags' ).split( ',' ) ]
        dataObj[ 'timestamp' ] = datetime.datetime.utcnow()

        activityData.insert( dataObj )

    # Join up the arguments and call the Analzyer
    arguments = ' '.join( [ prev_gps, curr_gps, acc_data, gyro_dat, mic_data ] )

    final_call = str( current_app.config[ 'ANALYZER_PATH' ] % ( arguments ) )
    p = subprocess.Popen( shlex.split( final_call ), stdout=subprocess.PIPE ).stdout

    # Read the activites from the analyzer output
    activities = []
    for line in p.readlines():
        activities.append( line.strip() )

    # call song recommendation engine
    playlist = []

    # Get the number of songs with this activity
    num_songs = songs.find( {'activities': activities[0] } ).count()

    for idx in xrange( 10 ):
        song = songs.find( {'activities': activities[0] } ).skip( randint( 0, num_songs ) ).limit( 1 )[0]

        newsong = {}
        newsong[ 'artist' ]  = song[ 'artist' ]
        newsong[ 'title' ]   = song[ 'track' ]
        newsong[ 'rdio_id' ] = song[ 'rdio_id' ]

        if song[ 'icon' ] is not None:
            newsong[ 'icon' ] = song[ 'icon' ]

        playlist.append( newsong )

    results = {}
    results[ 'activities' ] = activities
    results[ 'playlist' ] = playlist
    return json.dumps( results )

@analyzer_api.route( '/feedback' )
def handle_feedback():
    connection = pymongo.Connection()
    rmwdb = connection[ 'rmw' ]
    feedback = rmwdb.feedback

    fback = {}
    try:
        # Check for required parameters
        if 'uuid' not in request.args:
            raise Exception( 'Missing uuid' )
        if 'is_correct_activity' not in request.args:
            raise Exception( 'Missing is_correct_activity' )
        if 'current_activity' not in request.args:
            raise Exception( 'Missing current_activity' )
        if 'is_good_song' not in request.args:
            raise Exception( 'Missing is_good_song' )

        fback[ 'uuid' ]                 = request.args.get( 'uuid' )
        fback[ 'is_correct_activity' ]  = bool( request.args.get( 'is_correct_activity' ) )
        fback[ 'current_activity' ]     = request.args.get( 'current_activity' ).upper()
        fback[ 'is_good_song' ]         = bool( request.args.get( 'is_good_song' ) )

        feedback.insert( fback )        
    except Exception, e:
        print e
        return json.dumps( {'success': False, 'msg': str( e ) } )

    return json.dumps( {'success': True } ) 