'''
    send_push_reminders.py

    Uses the Parse.com framework to send push notifications to RMW testers.

    The message sent is randomly chosen from the list REMINDERS.
'''
import httplib
import json

# Push Notification Group to send notifications to.
NOTIFICATION_GROUP = "development"

# REST URL to send push notifications.
PARSE_API   = 'api.parse.com'
PARSE_PUSH  = '/1/push'

# Headers required for the Parse API.
PARSE_API_HEADERS = {
    'X-Parse-Application-Id': 	'D55ULIo2tJiuquYpIM90h8Tswnkusor9U9AssZcw',
    'X-Parse-REST-API-Key': 	'fMpXGCqMqIwadLwll6FtSvxahccIOQyNsd5ue7iS',
    'Content-Type': 			'application/json'
}

# List of messages to send out. Message that is sent will be randomly chosen
# when the script is called.
REMINDERS = [
    "Please run the ROCKMYWORLD application and contribute activity data.",
    "Please run the ROCKMYWORLD application! Tip: it might be useful for you\
     to disable password lock so you can give feedback easier!"
]


def main():
    data = {
        'channel': NOTIFICATION_GROUP,
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
