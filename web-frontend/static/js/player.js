var player = {};

// Track class
function Track(trackInfo) {
    'use strict';
    this.trackName = null;
    this.artistName = null;
    this.trackURL = null;
    this.albumArtURL = null;
    this.loc = null;

    this.parseInput = function (input) {
        if (input.name) {
            this.trackName = input.name;
        }
        if (input.artist) {
            this.artistName = input.artist;
        }
        if (input.preview_url) {
            this.trackURL = input.preview_url;
        }
        if (input.album_img) {
            this.albumArtURL = input.album_img;
        }
        if (input.loc) {
            this.loc = input.loc;
        }
    };

    if (trackInfo) {
        this.parseInput(trackInfo);
    }
}

(function () {
    'use strict';

    player.playlist = [];
    player.history = [];
    player.trackLoaded = false;
    player.repeatEnabled = false;

    player.addTrackToPlaylist = function (track) {
        player.playlist.push(track);
    };

	player.initPlaylist = function (tracks) {
		// add tracks to playlist
		var t;
		for (t in tracks) {
			player.addTrackToPlaylist(new Track(tracks[t]));
		}
		player.loadCurrentTrack();
	};

	player.updatePlaylist = function (tracks) {
	    if (player.playlist.length > 1) {
			// clear remaining tracks
            player.playlist.splice(1, player.playlist.length - 1);

			// add tracks to playlist
			var t;
			for (t in tracks) {
				player.addTrackToPlaylist(new Track(tracks[t]));
			}

			player.setNextAlbumArtSrc(player.playlist[1].albumArtURL);
	    }
	};


    player.addTrackToHistory = function (track) {
        var id = player.history.push(track) - 1;

        var historyItem = $('<li class="history-item"></li>')
            .prependTo(player.ui.history)
            .click(function () {
                player.loadHistoryTrack(id);
                player.play();
                $('#tab_1').click();
            })
			.append('<div class="album"><img src="' + track.albumArtURL + '"/></div>')
			.append($('<div></div>')
				.append('<span class="artist">' + track.artistName + '</span><br/>')
				.append('<span class="track">' + track.trackName + '</span>'));

		var sep = historyItem.siblings('.sep').first();
		console.log(sep);
		if (sep.size() === 1 && sep.hasClass(track.loc)) {
			sep.detach().prependTo(player.ui.history);
		} else {
			$('<li class="sep"></li>').addClass(track.loc).html(track.loc).prependTo(player.ui.history);
		}
    };

    player.loadAudioSrc = function (src) {
        player.ui.audio.get(0).src = src;
        player.ui.audio.get(0).load();
        player.ui.audio.get(0).play();
        player.ui.audio.get(0).pause();
    };

    player.setBackgroundColor = function (url) {
        $.ajax({
            url: '/front_end/dominant_color',
            async: false,
            data: {'url': url},
            dataType: 'json',
            success: function (color) {
//                $('#home').animate({backgroundColor: color});
                $('#home').css('background-color', color);
            }
        });
    };

    player.setCurrentAlbumArtSrc = function (src) {
        player.setBackgroundColor(src);
        player.ui.currentAlbumArt.attr('src', src);
    };

    player.setNextAlbumArtSrc = function (src) {
        player.ui.nextAlbumArt.attr('src', src);
    };

    player.setTrackInfo = function (title, artist, loc) {
        player.ui.trackInfo.title.html(title);
        player.ui.trackInfo.artist.html(artist);
        player.ui.trackInfo.loc.html(loc);
    };

    player.loadTrack = function (track) {
        if (!track) {
            throw "Invalid track: " + track;
        }
        player.loadAudioSrc(track.trackURL);
        player.setCurrentAlbumArtSrc(track.albumArtURL);
        player.setTrackInfo(track.trackName, track.artistName, track.loc);
        player.trackLoaded = true;
    };

    player.loadCurrentTrack = function () {
        player.trackLoaded = false;
        player.loadTrack(player.playlist[0]);
        player.setNextAlbumArtSrc(player.playlist[1].albumArtURL);
    };

    player.loadNextTrack = function (callback) {
		$('#activity').fadeIn(function () {
			// remove first track from playlist and add it to history
			player.addTrackToHistory(player.playlist.shift());
			player.loadCurrentTrack();
			if (callback) {
				callback();
			}
		});
    };

    player.loadHistoryTrack = function (id) {
        if (!player.history[id]) {
            throw "Invalid history track ID: " + id;
        }
        // remove first track from playlist and add it to history
        player.addTrackToHistory(player.playlist.shift());
        // push history track into front of playlist
        player.playlist.unshift(player.history[id]);
        player.loadCurrentTrack();
    };

    player.play = function () {
        if (!player.trackLoaded) {
            player.loadCurrentTrack();
        }
        player.ui.audio.get(0).play();
		player.ui.controls.playPause.attr( 'src', '/static/img/pause_button.png' )
//        player.ui.controls.playPause.html("pause");
    };

    player.pause = function () {
        player.ui.audio.get(0).pause();
//        player.ui.controls.playPause.html("play");
		player.ui.controls.playPause.attr( 'src', '/static/img/play_button.png' )
    };

    player.playPause = function () {
        if (player.ui.audio.get(0).paused) {
            player.play();
        } else {
            player.pause();
        }
    };

    player.playNext = function () {
        player.loadNextTrack(function () {
			player.play();
		});
    };

    player.toggleRepeat = function () {
        player.repeatEnabled = !player.repeatEnabled;
        var span = player.ui.controls.repeat.find('span');
        if (player.repeatEnabled) {
            span.html("ON");
        } else {
            span.html("OFF");
        }
    };

    // player event handlers
    player.handlers = {};

    player.handlers.trackEnded = function (event) {
        if (player.repeatEnabled) {
            player.ui.audio.get(0).currentTime = 0;
            player.play();
        } else {
            player.playNext();
        }
    };

	player.handlers.trackCanPlay = function (event) {
		$('#activity').fadeOut();
	};

    $(function () {
        // player UI elements
        player.ui = {
            'audio': $('#player-audio audio'),
            'trackInfo': {
                'title': $('#player-track-info .title'),
                'artist': $('#player-track-info .artist'),
                'loc' : $('#player-track-info .loc')
            },
            'currentAlbumArt': $('#current-album > img'),
            'nextAlbumArt': $('#next-album > img'),
            'controls': {
                'repeat': $('#player-controls .repeat'),
                'playPause': $( '#play-btn > img' )
            },
            'history': $('#history-list')
        };

        // bind event handlers
        player.ui.audio.bind({
			ended: player.handlers.trackEnded,
			canplay: player.handlers.trackCanPlay
		});
        player.ui.currentAlbumArt.click(player.playPause);
        player.ui.controls.playPause.click( player.playPause )
        player.ui.nextAlbumArt.click(player.playNext);
        player.ui.controls.repeat.click(player.toggleRepeat);
    });
}());

function toggleInfoDiv() {
    var d = $('#trackinfo');
    var i = $('#info-content');
    if (d.css('display') == 'none') {
        track_data = {title : player.playlist[0].trackName, artist : player.playlist[0].artistName}
        $.getJSON( '/api/amazon', track_data, function( data ) {
            var html = '<span style="font-size:42px;">'+player.playlist[0].artistName+'</span>';
            var url = 'http://www.amazon.com'
            if (data != null) {
                url = data.url
            }
            html += '<br /><a href="'+url+'" style="color:#fff;">Buy this album!</a>';
            i.html(html);
            d.fadeIn();
        });
    } else {
        d.fadeOut();
    }
    
}
