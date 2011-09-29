var watchId = null;
var latitude = null;
var longitude = null;
var imageWidth = null;
var imageHeight = null;

// Determine whether user is running on iPad by checking the user agent of the browser
function isPad() {
   // Returns true if the user agent is associated with an iPad and false, otherwise
	if (navigator.userAgent.match(/iPad/i))
	{
		return true;
	}
	return false;
}

//Show a Google static map centered at a given position. Display the latitude and longitude coordinates associated with this position.
function showLocation (position) {
	latitude = position.coords.latitude;
	longitude = position.coords.longitude;
	console.log( latitude + ', ' + longitude );
}

// Handle location errors
function handleError(error) 
{
	var errorMessage;
	switch (error.code)
	{
		case error.code.PERMISSION_DENIED:
			errorMessage = "Permission Denied";
			break;
		case error.code.POSITION_UNAVAILABLE:
			errorMessage = "Position Unavailable";
			break;	
		case error.code.TIMEOUT:
			errorMessage = "Time Out";
			break;
		case error.code.UNKNOWN_ERROR:
			errorMessage = "Unknown Error";
			break;	
	}
	
	console.log( error.message );
	alert( error.message );
}


// Check the orientation of the device and update the position of the longitude in the application
function updateOrientation() {
	if (navigator.geolocation) {
		navigator.geolocation.getCurrentPosition(showLocation, handleError);
	}
}

//Update the map if the current location is different from the previous location
function updateLocation(position)
{
	// Update the map if the current position is different from the previous position
	if ((latitude != position.coords.latitude)||(longitude != position.coords.longitude))
	{
		showLocation(position);
	}
 
}

// Get the current location and register for location changes
function acquireLocation(event)
{
	if (navigator.geolocation) {
		updateOrientation();
		
		// Register for location changes and pass the returned position to the updateLocation method
		watchId = navigator.geolocation.watchPosition(updateLocation, handleError);
	} else {
		console.log( 'Your browser does not support Geolocation services.' );
	}
	
}

function getCoords() {
	return { 'latitude': latitude, 'longitude': longitude };
}

// Unregister for location changes when the user quits the application
function clearWatchId() {
	if(watchId) {
		navigator.geolocation.clearWatch(watchId);
		watchId = null;
	}
}