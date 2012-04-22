import csv
import json
import os
import pymongo
import urllib, urllib2
import sys
import time

import rdioapi

RDIO_KEY 	= 'vuzwpzmda4hwvwfhqkwqqpyh'
RDIO_SECRET = 'kHRJvWdT2t'

# Connect to RDIO
state = {}
rdio = rdioapi.Rdio( RDIO_KEY, RDIO_SECRET, state )

ECHONEST_API_KEY = '6JRJVZ4BDYWXSPUGZ'

ECHO_API 	= 'http://developer.echonest.com/api/v4/song/search?%s'
ECHO_SEARCH = { 'api_key': 	ECHONEST_API_KEY,
				'format': 	'json',
				'results':	10,
				'bucket': 	'id:rdio-us-streaming' }

def get_rdio_id( artist, track ):
	query = dict( ECHO_SEARCH )
	query[ 'artist' ] = artist
	query[ 'title'  ] = track

	results = json.loads( \
				urllib2.urlopen( \
					ECHO_API % ( urllib.urlencode( query ) ) \
				).read() )
	
	for song in results[ 'response' ][ 'songs' ]:
		if len( song[ 'foreign_ids' ] ) > 0:
			fids = song[ 'foreign_ids' ]
			for fid in fids:
				if fid[ 'catalog' ] == 'rdio-us-streaming':
					return fid[ 'foreign_id'].split( ':' )[2]
	
	return None

def get_rdio_icon( rdio_id ):
	results = rdio.get( keys=rdio_id )

	if results is not None and rdio_id in results:
		results = results[ rdio_id ]
		if 'bigIcon' in results:
			return results[ 'bigIcon' ]
		elif 'icon' in results:
			return results[ 'icon' ]

	return None

def main( data_file ):

	csvreader = csv.reader( data_file )
	connection = pymongo.Connection()
	rmwdb = connection[ 'rmw' ]

	songs = rmwdb.songs

	count = 0
	for row in csvreader:
		count += 1

		try:
			artist, track, activities, rdio_id = row
		except ValueError, e:
			continue
			
		activities = [ x.strip().lower() for x in activities.split( ',' ) ]
		artist = artist.strip()
		track  = track.strip()

		rdio_id = rdio_id.strip()
		if rdio_id == None or len( rdio_id ) == 0:
			print '%s - %s has no RDIO ID' % ( artist, track )
			songs.insert( {'artist': artist, 'track': track, 'icon': None, 'activities': activities, 'rdio_id': None } )
			continue

		icon = get_rdio_icon( rdio_id )

		print '[%d] Inserting %s - %s' % ( count, artist, track )
		songs.insert( {'artist': artist, 'track': track, 'icon': icon, 'activities': activities, 'rdio_id': rdio_id } )
		time.sleep( 1 ) # Sleep for a second before doing next query

if __name__ == '__main__':
	main( open( sys.argv[1] ) )