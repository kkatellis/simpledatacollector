'''
    analyze.py

    API functions to handle data analyzing and feedback from the device
'''
import os
import datetime
import json
import pymongo
import shlex, subprocess

from random import randint

from flask import abort, current_app, Blueprint, request
from werkzeug import secure_filename

from server.db import song_to_dict

NUM_SONGS       = 6
NUM_RAND_SONGS  = 2

analyzer_api = Blueprint( 'analyzer_api', __name__ )

ALLOWED_EXTENSIONS = set( ['zip'] )

GPS_FMT  = '"%f" "%f" "%f" "%s"'
ACC_FMT  = '"%f" "%f" "%f"'
GYRO_FMT = '"%f" "%f" "%f"'
MIC_FMT  = '"%f" "%f"'

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
    except Exception, error:
        print error
        abort( 400 )

    # Save data if we have a UDID & tags parameters
    if 'udid' in request.args and 'tags' in request.args:
        activity_data = rmwdb.activitydata

        data_obj = dict( request.args )

        # Remove GPS timestamp info before sending to database
        del( data_obj[ 'timestamp' ] )
        del( data_obj[ 'prev_timestamp' ] )

        for key in data_obj.keys():
            if 'tags' not in key and 'udid' not in key:
                data_obj[ key ] = float( data_obj[ key ][0] )
            else:
                data_obj[ key ] = data_obj[ key ][0]

        # Split up the calibrate tags
        data_obj[ 'tags' ] = [ x.strip() for x in request.args.get( 'tags' ).split( ',' ) ]
        data_obj[ 'timestamp' ] = datetime.datetime.utcnow()

        activity_data.insert( data_obj )

    # Join up the arguments and call the Analzyer
    arguments = ' '.join( [ prev_gps, curr_gps, acc_data, gyro_dat, mic_data ] )

    final_call = str( current_app.config[ 'ANALYZER_PATH' ] % ( arguments ) )
    process = subprocess.Popen( shlex.split( final_call ), stdout=subprocess.PIPE ).stdout

    # Read the activites from the analyzer output
    activities = []
    for line in process.readlines():
        activities.append( line.strip() )

    # call song recommendation engine
    playlist = []

    # Get the number of songs with this activity
    num_songs = songs.find( {'activities': activities[0] } ).count()

    for idx in xrange( NUM_SONGS ):
        try:
            song = songs.find( {'activities': activities[0] } )\
                        .skip( randint( 0, num_songs - 1 )  )\
                        .limit( 1 )
        except IndexError, error:
            print error
            continue

        playlist.append( song_to_dict( song[0] ) )

    # Get the number of songs without any tags
    # Empty string indicates a song with no activity tags
    num_songs = songs.find( {'activities': '' } ).count()

    for idx in xrange( NUM_RAND_SONGS ):
        try:
            song = songs.find( {'activities': '' } )\
                        .skip( randint( 0, num_songs - 1 ) )\
                        .limit( 1 )
        except IndexError, error:
            print error
            continue

        playlist.append( song_to_dict( song[0] ) )

    results = {}
    results[ 'activities' ] = activities
    results[ 'playlist' ] = playlist
    return json.dumps( results )

def allowed_file( filename ):
    return '.' in filename and filename.rsplit( '.', 1 )[1] in ALLOWED_EXTENSIONS

@analyzer_api.route( '/feedback_upload', methods=[ 'POST' ] )
def feedback_upload():
    '''
        Handles saving feedback high frequency (HF) data and sound wave data
        collection. The app zips up the HF data and sound wave and uploads
        it to this URL.

        Parameters
        ----------
        file - ZIP file data

        Results
        -------
        JSON success if the file was successfully uploaded
        JSON failure otherwise
    '''
    uploaded_file = request.files[ 'file' ]
    if uploaded_file and allowed_file( uploaded_file.filename ):
        filename = secure_filename( uploaded_file.filename )
        uploaded_file.save( os.path.join( current_app.config['UPLOAD_FOLDER'], filename ) )
        return json.dumps( {'success': True} )
    else:
        return json.dumps( {'success': False} )

@analyzer_api.route( '/feedback' )
def handle_feedback():
    '''
        Handles saving feedback that is sent from the app.

        Parameters
        ----------
        uuid                - UUID of device sending the feedback
        is_correct_activity - Whether or not our predicted activity is 
                                is_correct_activity
        current_activity    - The user's current activity ( This will be set to
                                the predicted activity if we guessed 
                                correctly ).
        is_good_song        - Whether or not the current song is a good song
                                for the current activity
        current_song        - MongoDB ID of the current song playing.

        Results
        -------
        JSON success if all params are present and correctly parsed
        JSON failure if something is not present or incorrectly parsed
    '''
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
        if 'current_song' not in request.args:
            raise Exception( 'Missing current_song' )

        fback[ 'uuid' ]                 = request.args.get( 'uuid' )
        fback[ 'is_correct_activity' ]  = bool( request.args.get( 'is_correct_activity' ) )
        fback[ 'current_activity' ]     = request.args.get( 'current_activity' ).upper()
        fback[ 'current_song' ]         = request.args.get( 'current_song' )
        fback[ 'is_good_song' ]         = bool( request.args.get( 'is_good_song' ) )

        feedback.insert( fback )        
    except Exception, exception:
        print exception
        return json.dumps( {'success': False, 'msg': str( exception ) } )

    return json.dumps( {'success': True } ) 