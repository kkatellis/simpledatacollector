<!doctype html>
<html>
	<head>
		<meta charset="UTF-8" />
		<title>The Hack</title>	
		
		<!-- Apple iOS related stuffs -->
		<meta name="apple-mobile-web-app-status-bar-style" content="black" />
		<meta name="viewport" content="minimum-scale=1.0, width=device-width, maximum-scale=1">
		<meta name="apple-mobile-web-app-capable" content="YES">
		<link rel='apple-touch-icon' href='/static/img/touch-icon-iphone.png' />
		<link rel='apple-touch-icon' sizes='72x72' href='/static/img/touch-icon-ipad.png'/>
		<link rel='apple-touch-icon' sizes='114x114' href='/static/img/touch-icon-iphone4.png'/>
		<link rel='apple-touch-startup-image' href='/static/img/touch-startup.png' />
		
		<!-- jqTouch related stuffs -->
		<link rel='stylesheet' type='text/css' href='/static/jqtouch/jqtouch.css' />
		<link rel='stylesheet' type='text/css' href='/static/themes/apple/theme.css' />
		<link rel='stylesheet' type='text/css' href='/static/extensions/jqt.bars/jqt.bars.css' />
		<link rel='stylesheet' type='text/css' href='/static/extensions/jqt.bars/themes/apple/theme.css' />

		<!-- related stuffs -->
		<link rel="stylesheet" type="text/css" href="/static/css/master.css">
	</head>
	<body>
		<div id="tabbar"> 
			<div><ul> 
				<li> 
					<a href="#history" mask="/static/img/tabs/history.png" mask2x="/static/img/tabs/history.png">
						<strong>History</strong>
					</a> 
				</li>
				<li> 
					<a onclick='sendData();' href="#home" mask="/static/img/tabs/music.png" mask2x="/static/img/tabs/music.png">
						<strong>Music</strong>
					</a> 
				</li> 
				<li> 
					<a onclick='loadSocial();' href="#social" mask="/static/img/tabs/social.png" mask2x="/static/img/tabs/social.png">
						<strong>Discover</strong>
					</a> 
				</li> 
			</ul></div> 
		</div>
		<div id='activity'>
			<div style='margin:16px 0;'><img src='/static/img/ajax-loader.gif'></div>
			<div>Loading...</div>
		</div>
		<div id='trackinfo'>
			<div style="float:right;"><a href="javascript:toggleInfoDiv();"><img src="/static/img/x.png" width=32 /></a></div>
			<div id='info-content'></div>
		</div>
		<div id="jqt">
			<div id='history'>
				<div class="toolbar">
					<h1>History</h1>
				</div>
				<div style='margin-top:44px;'>
					<ul id='history-list' class='edgetoedge'></ul>
				</div>
			</div>
			<div id='social'>
				<div class="toolbar">
					<h1>Discover</h1>
					<div style='float:right;margin-top:-4px;'>
						<a onClick="window.location='https://www.facebook.com/dialog/oauth?client_id=170844926329169&amp;redirect_uri=http://thehack.dvanoni.com/api/facebook&amp;display=touch'"><img src="/static/img/facebook.png" width=32 height=32 style="vertical-align:middle;" /></a>
					</div>
				</div>
				<div style='margin-top:44px;'>
					<div id='discover-map-wrapper'>
						<img src='/static/img/staticmap.png'>
						<div id='discover-map' style='position:absolute;top:0;left:0;'></div>
					</div>
				</div>
			</div>
			<div id="home" class='current'>
				<div id='player'>
					<div id='player-audio'>
						<audio></audio>
					</div>
					<div id='player-track-info'>
						<div>
							<div class='loc' style="z-index:20">LOCATION</div>
							<div class='artist' style="position:relative;z-index:50">Artist</div>
							<div class='title' style="position:relative;z-index:51">Title</div>
						</div>
					</div>
					<div id='player-album-art'>
						<div id='next-album'>
							<img alt='next album'/>
						</div>
						<div id='current-album'>
							<div id='play-btn'>
								<img src='/static/img/play_button.png' alt='play button'>
							</div>
							<img alt='current album'/>
						</div>
					</div>
					<div id="player-controls">
						<button class="repeat">repeat is <span>OFF</span></button>
					</div>
					<div class='info_icon'><a href="javascript:toggleInfoDiv();"><img src="/static/img/info_icon.png"/></a></class>
				</div>
			</div>
		</div>
		<script src='/static/jqtouch/jquery-1.4.2.min.js' type='text/javascript'></script>
		<!--<script src="/static/js/jquery-ui-1.8.16.custom.min.js" type='text/javascript' charset="utf-8"></script>-->
		<script src="/static/jqtouch/jqtouch.js" type="application/x-javascript" charset="utf-8"></script>
		<script src="/static/extensions/jqt.bars/jqt.bars.js" type="application/x-javascript" charset="utf-8"></script> 
		<script src="/static/js/geolocation.js" type='text/javascript' charset="utf-8"></script>
		<script src="/static/js/player.js" type='text/javascript' charset="utf-8"></script>
		<script src="/static/js/master.js" type='text/javascript' charset="utf-8"></script>
	</body>
</html>
