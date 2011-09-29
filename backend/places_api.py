#/bin/python

import json
from pprint import pprint
import urllib

PLACES_KEY = 'AIzaSyCvfId0lM9v_F2igUi4AIRbFJHr8IlMFAY'
PLACES_API = 'https://maps.googleapis.com/maps/api/place/search/json'

WORKOUT = [
  'gym',
  'health'
]

LOWKEY = [
  'museum',
  'park',
  'aquarium',
  'art_gallery',
  'cafe',
  'spa'
]

SOCIAL = [
  'bar',
  'night_club'
]

TRAVEL = [
  'subway_station',
  'taxi_stand',
  'train_station'
]

STUDY = [
  'book_store',
  'library',
  'university',
  'school'
]

PLACE_TYPES = [
  WORKOUT,
  LOWKEY,
  SOCIAL,
  TRAVEL,
  STUDY
]

class SearchError(Exception):
   pass

def coord_to_place_type(lat, lng):  

  if lat is None or lng is None:
    print 'INVALID coordinates:', lat, lng
    return None

  flattened_places =\
      [place for sublist in PLACE_TYPES for place in sublist]

  args = {
        'location' : '%s,%s' % (lat, lng),
        'radius'   : 10,
        'sensor'   : 'true',
        'key'      : PLACES_KEY,
        'types'    : '|'.join(flattened_places)
  }

  url = PLACES_API + '?' + urllib.urlencode(args)
  result = json.load(urllib.urlopen(url))

  if 'Error' in result:
    # An error occurred; raise an exception
    raise SearchError, result['Error']
      
  if result[ 'status' ] == 'ZERO_RESULTS':
    raise SearchError, 'Zero results'
  
  for t in result['results'][0]['types']:
    if t in flattened_places:
      return t
