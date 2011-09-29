import bottle
import json
import urllib2
import cStringIO

from bottle import template, request
from PIL import Image

import json
import urllib

FRONT_END = bottle.Bottle()

@FRONT_END.route( '/index' )
def front_end_index():
	login = True
	s = bottle.request.environ.get('beaker.session')

	if s:
		username = s.get('username')
		profile_id = s.get('profile_id')
		access_token = s.get('access_token')
		fb_image = "https://graph.facebook.com/me/picture?access_token=%s" % access_token
		fb_music = "https://graph.facebook.com/me/music?access_token=%s" % access_token
		music = json.load(urllib.urlopen(fb_music))

	else:
		username = None
		fb_image = None
		music = None

	if username:
		login = False

	return template('index', login=login, username=username, fb_image=fb_image, my_music=music)
	
@FRONT_END.route( '/dominant_color' )
def dominant_color():
    '''
        Grab an image and determine it's dominant color
    '''
    img_url = request.GET.get( 'url' )

    # Read the image
    try:
        f = cStringIO.StringIO( urllib2.urlopen( urllib2.unquote( img_url ) ).read() )
        img = Image.open( f )
        img.load()
    except Exception:
        return json.dumps( '#%02x%02x%02x' % ( 50, 50, 50 ) )

    # Resize image to get dominant color
    color = img.resize( (1,1), Image.ANTIALIAS).getpixel( (0,0) )
    brightness = ( color[0] + color[1] + color[2] ) / 3.0
    
    # Have some thresholds so that the album art isn't overwhelmed
    if brightness > 240:
        color = ( color[0] * .75, color[1] * .75, color[2] * .75 )
    elif brightness < 50:
        color = ( color[0] + 50, color[1] + 50, color[2] + 50 )
    
    # Finally return the hex color value
    return json.dumps( '#%02x%02x%02x' % color )
