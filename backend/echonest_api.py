#/bin/python

import json
from pprint import pprint
import sys
import urllib

from hack.helper import UserCategory
from hack.helper import get_user_category

ECHONEST_KEY = 'YBBLFZVQBRPQF1VKS'
ECHONEST_API = 'http://developer.echonest.com/api/v4/song/search'
ECHONEST_ARTIST = 'http://developer.echonest.com/api/v4/artist/similar'

USER_CATEGORIES = {
  UserCategory.STUDYING : {
      'sort' : 'song_hotttnesss-desc',
      'max_danceability' : '.2',
      'max_energy' : '.2',
      'max_loudness' : '20'
    },
  UserCategory.RUNNING : {
      'sort' : 'song_hotttnesss-desc',
      'min_tempo' : '240',
      'min_danceability' : '.6',
      'min_energy' : '.6'
    },
  UserCategory.COMMUTING : {
      'song_min_hotttnesss' : '.75',
      'min_danceability' : '.5',
      'min_energy' : '.5'
    },
  UserCategory.WALKING : {    
      'sort' : 'song_hotttnesss-desc',
      'min_tempo' : '200',
      'min_danceability' : '.35',
      'min_energy' : '.5'
    },
  UserCategory.WAKING_UP : {
      'sort' : 'song_hotttnesss-desc',
      'max_energy' : '.4',
    },
  UserCategory.WINDING_DOWN : {
      'max_tempo' : '80',
      'sort' : 'song_hotttnesss-desc'
    },
  UserCategory.PRE_PARTY : {
      'song_min_hotttnesss' : '.85',
      'artist_start_year_after' : '2002',
    }
}

class EchonestMagicError(Exception):
  pass


def getSimilarMood(moods):
  args = {
    'api_key' : ECHONEST_KEY,
    'bucket'  : 'id:7digital-US',
    'limit'   : 'true'
  }

  for mood in moods:
    args.update({'mood' : mood})

  url = ECHONEST_API + '?' + urllib.urlencode(args) + '&bucket=tracks'
  return search(url)

def getSimilarArtist(artist):
  args = {
    'api_key' : ECHONEST_KEY,
    'bucket'  : 'id:7digital-US',
    'limit'   : 'true'
    'name'    | artist
  }

  url = ECHONEST_ARTIST + '?' + urllib.urlencode(args) + '&bucket=tracks'
  return search(url)

def getCategory(category):
  print 'echonest search for:', category

  # default category
  if category is None or category is '':
    category = UserCategory.PRE_PARTY

  args = {
      'api_key' : ECHONEST_KEY,
      'bucket'  : 'id:7digital-US',
      'limit'   : 'true'
  }

  args.update(USER_CATEGORIES[category])

  url = ECHONEST_API + '?' + urllib.urlencode(args) + '&bucket=tracks'
  return search(url)

# Peforce search and return trakcks
def search(url):
  result = json.load(urllib.urlopen(url))

  echonest_status = result['response']['status']
  if echonest_status['code'] != 0:
    print 'UGHHH echonest error!', echonest_status['message']
    return

  track_data = []
  print 'found %d songs!' % len(result['response']['songs'])

  for s in result['response']['songs']:
    if 'title' not in s:
      continue

    artist = ''
    if 'artist_name' in s:
      artist = s['artist_name']
    
    preview_url = ''
    album_img = ''
    if 'tracks' in s:
      if s['tracks'][0]:
        if s['tracks'][0]['preview_url']:
          preview_url = s['tracks'][0]['preview_url']
        if s['tracks'][0]['release_image']:
          album_img = s['tracks'][0]['release_image']

    track_data.append({
        'name'        : s['title'],
        'artist'      : artist,
        'preview_url' : preview_url,
        'album_img'   : album_img,
        'id'          : s['id']
    })

  return track_data