import httplib
import json
import urllib

# REST URL to send push notifications
PARSE_API 	= 'api.parse.com'
PARSE_PUSH 	= '/1/push' 

# Headers required for the Parse API
PARSE_API_HEADERS = { 
	'X-Parse-Application-Id': 	'D55ULIo2tJiuquYpIM90h8Tswnkusor9U9AssZcw',
	'X-Parse-REST-API-Key': 	'fMpXGCqMqIwadLwll6FtSvxahccIOQyNsd5ue7iS',
	'Content-Type': 			'application/json'
}

REMINDERS = [
	"Please run the ROCKMYWORLD application and contribute activity data.",
	"Please run the ROCKMYWORLD application! Tip: it might be useful for you to disable password lock so you can give feedback easier!"
]

def main():

	data = { 
		'channel': 'testers',
		'data': {
			'alert': REMINDERS[0]
		}
	}

	conn = httplib.HTTPSConnection( PARSE_API )
	conn.request( 'POST', PARSE_PUSH, json.dumps( data ), PARSE_API_HEADERS )
	response = conn.getresponse()

	print response.status, response.reason
	print response.read()

	conn.close()

if __name__ == '__main__':
	main()