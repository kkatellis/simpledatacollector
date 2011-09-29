// Accelerometer vars
var ax = 0, ay = 0, az = 0;

function getRandomInt (min, max) {
	return Math.floor(Math.random() * (max - min + 1)) + min;
}		

var jQT = new $.jQTouch({
	addGlossToIcon: false,
	statusBar: 'black',
	preloadImages: [
		'/static/themes/jqt/img/back_button.png',
		'/static/themes/jqt/img/back_button_clicked.png',
		'/static/themes/jqt/img/button_clicked.png',
		'/static/themes/jqt/img/grayButton.png',
		'/static/themes/jqt/img/whiteButton.png',
		'/static/themes/jqt/img/loading.gif',
		'/static/img/tabs/music.png',
		'/static/img/tabs/social.png',
	],
	useFastTouch: true
});

/*
	Send data that has been acquired from the phone to our API for 
	recommendations
*/
function sendData() {
	// Mash all the phone data together
	coords = getCoords();	
	phone_data = {
		latitude: coords.latitude, 
		longitude: coords.longitude,
		accelerometer: ax + ',' + ay + ',' + az,
		timestamp: Date.now() / 1000.0
	};
	
	// Construct API call and work some magic
	$.getJSON( '/api/recommend', phone_data, function( data ) {
	    
	    if( player.playlist.length > 1 ) {
            player.updatePlaylist(data);
	    }
		else {
			player.initPlaylist(data);
		}
	});
}

function loadSocial() {
	$( '#activity' ).fadeIn( 'fast' );
	$( '#discover-map' ).html( '' ).scrollLeft( 80 ).scrollTop( 160 );
	
	$.getJSON( '/api/similar', null, function( data ) {
		for( var i = 0; i < data.length; i++ ) {
			var track = data[i];
			var top  = getRandomInt( 16, 578 );
			var left = getRandomInt( 16, 578 );
			
			if( track.album_img ) {
				var html = "<div class='social-track' style='top:" + top + "px;left:" + left + "px;'>" +
							"<img src='" + track.album_img + "' width='48'>" +
							"</div>";
				$( '#discover-map' ).append( html );
			}
		}
		
		$( '.social-track' ).fadeIn( 'slow' );
		$( '#activity' ).fadeOut( 'fast' );
	});
}


$(function(){
	// Start acquiring our location
	//acquireLocation();
	
	// Start grabbing accelerometer data
	if (typeof window.DeviceMotionEvent != 'undefined') {

		// Listen to motion events and update the position
		window.addEventListener('devicemotion', function (e) {
			ax = e.accelerationIncludingGravity.x;
			ay = e.accelerationIncludingGravity.y;
			az = e.accelerationIncludingGravity.z;
		}, false);
	}

	sendData();
	//setTimeout( sendData, 2000 );
});
