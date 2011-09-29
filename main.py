import bottle

from bottle import redirect, run, static_file, template
from beaker.middleware import SessionMiddleware

from backend.server import BACK_END

from frontend.settings import STATIC_PATH
from frontend.main import FRONT_END

# Set debug mode and create the main bottle application
bottle.debug( True )
MAIN = bottle.Bottle()

import bottle
from beaker.middleware import SessionMiddleware

session_opts = {
    'session.type': 'file',
    'session.expires': 40000000,
    'session.data_dir': './data',
    'session.auto': True
}
app = SessionMiddleware(MAIN, session_opts)

@MAIN.route( '/static/:path#.+#')
def server_static( path ):
    '''
    Return static files situated at STATIC_PATH
    '''
    return static_file( path, root=STATIC_PATH )

@MAIN.route( '/' )
def index():
    return redirect( '/front_end/index' )

@MAIN.route( '/accel_test' )
def accel():
    return template( 'accel_test' )
        
# Attach API functions
MAIN.mount( FRONT_END, '/front_end' )
MAIN.mount( BACK_END, '/api' )
if __name__ == '__main__':    
    run( app=app, host='localhost', port=8080, reloader=True )