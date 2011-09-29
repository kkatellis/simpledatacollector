<!doctype html>
<html>
<meta name="apple-mobile-web-app-status-bar-style" content="black" />
<script src='/static/jqtouch/jquery-1.4.2.min.js' type='text/javascript'></script>

<!-- 
<meta name="viewport" content="minimum-scale=1.0, width=device-width, maximum-scale=1">
<meta name="apple-mobile-web-app-capable" content="YES">
-->
<script type='text/javascript'>
	$( function() {
		document.ax = 0;
		document.ay = 0;
		document.az = 0;
		
		// Start grabbing accelerometer data
		if (typeof window.DeviceMotionEvent != 'undefined') {

			// Listen to motion events and update the position
			window.addEventListener('devicemotion', function (e) {
				document.ax = Math.abs( e.accelerationIncludingGravity.x );
				document.ay = Math.abs( e.accelerationIncludingGravity.y );
				document.az = Math.abs( e.accelerationIncludingGravity.z );

				$( '#accel' ).html( document.ax + '<br>' + document.ay + '<br>' + document.az );
			}, false);
		}
	});
</script>
<body>
	<div id='accel'>
		adadf
	</div>
</body>
</html>