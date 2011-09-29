from fabric.api import cd, env, run
from fabric.colors import green
from fabric.contrib.files import exists

env.user = 'hackallstar'
env.hosts = [ 'thehack.dvanoni.com' ]

PRODUCTION_DIR  = 'thehack.dvanoni.com'
GIT_LOCATION    = 'git://github.com/dvanoni/TheHack.git'
APP_FOLDER      = 'TheHack'

def deploy():
    with cd( PRODUCTION_DIR ):
        # Clone the code if the source directory doesn't already exist
        print green( 'Cloning/pulling latest code...' )
        if not exists( APP_FOLDER ):
            run( 'git clone %s' % ( GIT_LOCATION ) )
        else:
            # Update the source
            with cd( APP_FOLDER ):
                run( 'git pull' )
        
        print green( 'restarting python instance' )
        # Finally restart our instance
        run( 'pkill python' )
