define('DS/InstantMessagingWebRTC/js/view/RTCallingComponentView',
    [
    'UWA/Class',
    'UWA/Class/View',
    'DS/RTProxyDriver/RTLogger',
    'i18n!DS/InstantMessagingWebRTC/assets/nls/feed',
    'DS/InstantMessagingWebRTC/assets/svg_icons',
    'DS/UIKIT/Tooltip',
	'DS/UIKIT/Spinner',
    "css!InstantMessagingWebRTC/InstantMessagingWebRTC.css"
    ], function(
        Class, View,
        logger,
        NLS,
        svg_icons,
        Tooltip,
		Spinner
    ){
    'use strict';
    return View.extend({
        tagName : "div",
        id : "RTCallingComponent", // useless and wrong : there can be several instances of this div
		className : "RTCallingComponent",
        setup: function(options) {
			this.nwayActivated = options.nwayActivated;
            this.listenTo(this.model, "onChange:title", this.changeTitle);
            this.listenTo(this.model, "onChange:callDuration", this.changeCallDuration);
			this.listenTo(this.model, "onChange:username", this.changeUsername);
			this.listenTo(this.model, "onChange:nway", this.nway);
			if (!this.model.get('IamTheCaller')) this.startRingtone();
        },

		nway : function() {
			this.hideButtons();
			this.hideIcons();
			this.showUsername();
			this.container.addClassName('nway');
			if ( ! this.nwayActivated) return true;
			//this.hideAvatar();
			this.hideCallDuree();
			this.hideCallDureeVid();
		},

		startRingtone : function() {
			try {
				if (!document.ringtone) return logger.WebRTC("Can not start ringtone");
				document.ringtone.loop = true;
				var playPromise = document.ringtone.play();
				if (playPromise !== undefined) {
				  playPromise.then(function() {
					logger.WebRTC("ringtone play");
				  }, function(error) {
					logger.WebRTC("ringtone failed to play."+error);
				  });
				}
				this.willStopRingtone = setTimeout((function(that) { return function(){
					that.stopRingtone();
				}})(this),30000); // ring for 30s (same time before callMissed)
			}
			catch(e) {
				logger.WebRTC("ringtone failed to play."+e);
			}
		},

		stopRingtone : function() {
			clearTimeout(this.willStopRingtone);
			if (!document.ringtone) return logger.WebRTC("Can not stop ringtone");
			document.ringtone.pause();
			document.ringtone.currentTime = 0;
			logger.WebRTC("ringtone stop");
		},

        changeTitle : function (model,options) {
            if (this.container && this.container.children && this.container.children.RTCallingComponent_title) this.container.children.RTCallingComponent_title.innerText = model.get('title');
        },

        changeUsername : function (model,options) {
            this.container.children.RTCallingComponent_infos.children.RTCallingComponent_username.innerText = model.get('username');
        },

		displayError : function (message) {
			this.model.set({state:"error"});
			this.maximize();
			this.showAvatar();
			this.hideVideo();
			this.hideButtons();
			this.hideIcons();
			this.model.set({title : NLS[message] || message});
			this.hideCallDuree();
			this.hideCallDureeVid();
			this.showTitle();
			if (this.container && this.container.children && this.container.children.RTCallingComponent_title && this.container.children.RTCallingComponent_title.classList) this.container.children.RTCallingComponent_title.classList.add("errorTitle");
			this.container.removeClassName('nwayvideo');
		},

        changeCallDuration : function (model,options) {
			var time = model.get('callDuration');
			var hours = Math.floor(time / 3600);
			time = time - hours * 3600;
			var seconds = time % 60;
			if (seconds<10) seconds = "0"+seconds;
			var minutes = Math.floor(time / 60);
			if (minutes<10) minutes = "0"+minutes;
			var finalString = (hours ? hours+":":"")+minutes+":"+seconds;
			//if (model.get('type') == 'audio')
				this.container.children.RTCallingComponent_infos.children.RTCallingComponent_callDuration.innerText =  finalString;
			//else
				this.container.children.RTCallingComponent_callDuration_video.innerText =  finalString;
        },

        removeIconsButHangUp : function (data) {
            if (data !== "calling"){
                this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_phone.addClassName("hidden");
                this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_phone_linked.addClassName("hidden");
                this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.addClassName("rigthSide");
                //this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_audio.removeClassName("hidden");
    			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic.addClassName("rigthSide");
    			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_phoneOFF.addClassName("rigthSide");
                this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic.removeClassName("hidden");
                this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.removeClassName("hidden");
            }
            /*
            var i, icons = this.container.children.RTCallingComponent_icons.children;
			if(icons)
				for (i=0; i<icons.length; i++) {
					if (icons[i].id != "RTwebrtc_icon_phoneOFF")
						icons[i].addClassName("hidden");
					else{
						if (!data)
							icons[i].addClassName("rigthSide");
					}

				}
                */
        },
        showAllIcons : function () {
            if (this.model.get('state').indexOf("incoming") != -1) return this.showIncomingIcons();
            return this.showOnCallIcons();
        },
        showOnCallIcons : function () {
            this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_phone.addClassName("hidden");
            this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_phone_linked.addClassName("hidden");
            this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.removeClassName("rigthSide");
            //this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_audio.removeClassName("hidden");
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic.removeClassName("rigthSide");
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_phoneOFF.removeClassName("rigthSide");

			this.addTooltip(this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic, NLS.muteAudio || "Mute");
			this.addTooltip(this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video, NLS.muteVideo || "Hide camera");
        },
        showIncomingIcons : function () {
            this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_phone.removeClassName("hidden");
            this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_phone_linked.removeClassName("hidden");
            this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.addClassName("hidden");
            //this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_audio.addClassName("hidden");
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic.addClassName("hidden");
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_phoneOFF.removeClassName("rigthSide");
        },
        setSizeButtonFull : function (container) {
            var sizebutton = this.buttons;
            if (!sizebutton) return false;
            sizebutton.removeClassName("fonticon-resize-small");
            sizebutton.addClassName("fonticon-resize-full");
        },
        setSizeButtonSmall : function () {
            var sizebutton = this.buttons;
            if (!sizebutton) return false;
            sizebutton.addClassName("fonticon-resize-small");
            sizebutton.removeClassName("fonticon-resize-full");
        },
        hideButtons        : function () {this.buttons.addClassName("hidden");},
        showButtons        : function () {this.buttons.removeClassName("hidden");},
        hideIcons          : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_icons) this.container.children.RTCallingComponent_icons.addClassName("hidden");},
        showIcons          : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_icons) this.container.children.RTCallingComponent_icons.removeClassName("hidden");},
        hideInfos          : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_infos) this.container.children.RTCallingComponent_infos.addClassName("hidden");},
        showInfos          : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_infos) this.container.children.RTCallingComponent_infos.removeClassName("hidden");},
        hideTitle          : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_title) this.container.children.RTCallingComponent_title.addClassName("hidden");},
        showTitle          : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_title) this.container.children.RTCallingComponent_title.removeClassName("hidden");},
        hideUsername       : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_infos) this.container.children.RTCallingComponent_infos.children.RTCallingComponent_username.addClassName("hidden");},
        showUsername       : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_infos) this.container.children.RTCallingComponent_infos.children.RTCallingComponent_username.removeClassName("hidden");},
        hideCallDuree      : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_infos) this.container.children.RTCallingComponent_infos.children.RTCallingComponent_callDuration.addClassName("hidden");},
        showCallDuration   : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_infos) this.container.children.RTCallingComponent_infos.children.RTCallingComponent_callDuration.removeClassName("hidden");},
		hideCallDureeVid   : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_callDuration_video) this.container.children.RTCallingComponent_callDuration_video.addClassName("hidden");},
        showCallDurationVid: function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_callDuration_video) this.container.children.RTCallingComponent_callDuration_video.removeClassName("hidden");},
        hideSubtitle       : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_infos) this.container.children.RTCallingComponent_infos.children.RTCallingComponent_subtitle.addClassName("hidden");},
        showSubtitle       : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_infos) this.container.children.RTCallingComponent_infos.children.RTCallingComponent_subtitle.removeClassName("hidden");},
        hideAvatar         : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_avatar) this.container.children.RTCallingComponent_avatar.addClassName("hidden");},
        showAvatar         : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_avatar) this.container.children.RTCallingComponent_avatar.removeClassName("hidden");},
        hideVideo          : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_video) this.container.children.RTCallingComponent_video.addClassName("hidden");},
        showVideo          : function () {if (this.container && this.container.children && this.container.children.RTCallingComponent_video) this.container.children.RTCallingComponent_video.removeClassName("hidden");},
        hideSelfVideo      : function () {this.localDivVideo.addClassName("hidden");},
        showSelfVideo      : function () {this.localDivVideo.removeClassName("hidden");},
        fullScreen         : function () {this.container.addClassName("fullScreen"); },
        normalScreen       : function () {this.container.removeClassName("fullScreen");},
        showAudioIcon      : function () {if (this.container && this.container.children && this.container.children.RTwebrtc_icon_audio) this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_audio.removeClassName("hidden");},
		showMicIcon        : function () {if (this.container && this.container.children && this.container.children.RTwebrtc_icon_mic) this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic.removeClassName("hidden");},
		showVideoIcon      : function () {if (this.container && this.container.children && this.container.children.RTwebrtc_icon_video) this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.removeClassName("hidden");},
		hideVideoNull	   : function () {/*if (this.container && this.container.children && this.container.children.RTCallingComponent_video_null) this.container.children.RTCallingComponent_video.children.RTCallingComponent_video_null.addClassName("hidden");*/},
		showVideoNull	   : function () {/*if (this.container && this.container.children && this.container.children.RTCallingComponent_video_null) this.container.children.RTCallingComponent_video.children.RTCallingComponent_video_null.removeClassName("hidden");*/},

		forcePosition : function () { // remove top/left style set on element in order to have only CSS rules after a d&d
			this.container.style.left = '';
			this.container.style.top = '';
		},

        pauseLocalVideo : function () {
			//this.localDivVideo.pause();
		},

        playLocalVideo : function () {
			this.localDivVideo.play();
            this.localDivVideo.muted = true;

		},

		showLocalStream : function (stream, video) {
			if (!stream) return logger.error("showLocalStream needs a stream");
            var videoDiv = this.localDivVideo;//this.container.children.RTCallingComponent_video.children.RTCallingComponent_video_local;
            try {
				videoDiv.src = window.URL.createObjectURL(stream);
				videoDiv.autoplay = true;
                if(navigator.platform.indexOf("iPhone") != -1){
                    videoDiv.onloadeddata = function() {
                        videoDiv.play();
                    };
                }
				videoDiv.load();
                videoDiv.muted = true;
			} catch(err) {
				try {
					videoDiv.srcObject = stream;
					videoDiv.autoplay = true;
                    if(navigator.platform.indexOf("iPhone") != -1){
                        videoDiv.onloadeddata = function() {
                            videoDiv.play();
                        };
                    }
					videoDiv.load();
                    videoDiv.muted = true;
				}
				catch(e) {
					logger.error("RTCallingComponentView unable to showLocalStream "+err+e);
				}
			}

			this.dispatchEvent("localStreamLoad");

			// change the action/tooltip of video button regarding what we are currently streaming
			if (stream.getTracks().length >= 2 ) { //audio+video
				//TODO : instead of condition on length, check type of each track and look for "video"
				this.displayNormalCameraIcon();
				videoDiv.removeClassName('hidden');
				this.showVideo();
			}
			else { // audio only
				this.displayMutedCameraIcon();
				this.hideVideo();
			}
			this.addMuteListener(stream.getTracks());
        },
		
		addMuteListener : function(tracks) {
			var muteHandler = function(evt) {
				console.log(evt);
			}
			for (var i in tracks)
				tracks[i].onmute = muteHandler;
		},

        showDistantStream : function (stream) {
			if (!stream) return logger.error("showDistantStream needs a stream");
            var videoDiv = this.container.children.RTCallingComponent_video.children.RTCallingComponent_video_distant;
			try {
				videoDiv.src = window.URL.createObjectURL(stream);
				videoDiv.autoplay = true;

                if(navigator.platform.indexOf("iPhone") != -1){
                    videoDiv.onloadeddata = function() {
                        videoDiv.play();
                    };
                }
				videoDiv.load();
			} catch(err) {
				try {
					videoDiv.srcObject = stream;
					videoDiv.autoplay = true;
                    if(navigator.platform.indexOf("iPhone") != -1){
                        videoDiv.onloadeddata = function() {
                            videoDiv.play();
                        };
                    }
					videoDiv.load();

				}
				catch(e) {
					logger.error("RTCallingComponentView unable to showDistantStream "+err+e);
				}
			}
			//this.maximize();
			var tracks = stream.getTracks();
            if (tracks.length >= 2 || tracks[0].kind=='video' ) {
				this.hideVideoNull();
				this.showVideo();
				this.hideAvatar();
				this.hasReceivedVideo = true;
			}
			this.addMuteListener(stream.getTracks());
        },

		detectDoubleTapOn : function (div) {
			var detectDbleClick = (function (self) {
				var clickTimer = null;
				return function touchStart () {
					if (clickTimer == null) {
						clickTimer = setTimeout(function () {
							clickTimer = null;
						}, 500)
					} else {
						clearTimeout(clickTimer);
						clickTimer = null;
						self.dispatchEvent("doubleClick");
					}
				}
			})(this);
			div.addEventListener("touchstart", detectDbleClick);
			div.addEventListener("click", detectDbleClick);
		},
		detectDoubleTapOnVideoAndAvatar : function (div) {
			this.detectDoubleTapOn(this.container.children.RTCallingComponent_video.children.RTCallingComponent_video_distant);
			this.detectDoubleTapOn(this.container.children.RTCallingComponent_avatar);
		},

        remove : function () {
            this.container.style.transform = "scale(0)";
            setTimeout((function(that) { return function(){
				that.container.remove();
				that.destroy();
            }})(this),500); // CSS transition is set to 0.5s
        },

        minimizeForAudio : function () {
			this.showAvatar();
            this.showCallDuration();
            //this.hideSubtitle();
			this.removeIconsButHangUp();
        },
        minimizeForVideo : function () {
            //this.hideInfos();
			//this.hideCallDureeVid();
        },
        minimize: function() {
			this.addTooltip(this.container.parentElement ? this.container.parentElement.children.RTCallingComponent_buttons : this.container.children.RTCallingComponent_buttons, NLS.maximize || "Maximize");
            this.removeIconsButHangUp();
            this.setSizeButtonFull();
            this.hideTitle();
			this.forcePosition();
            this.container.addClassName('minimized');
            this.hideUsername();
            this.normalScreen();
            //this.hideSelfVideo();
            this.showButtons();
			//this.setDraggable();
            if((navigator.platform.indexOf("iPhone") === -1) && (navigator.platform.indexOf("iPod") === -1) && (navigator.platform.indexOf("iPad") === -1)) {
                this.setDraggable(this.container.parentElement);
            }

            if (this.model.get('type') == 'video') this.minimizeForVideo();
            else if (this.model.get('type') == 'audio') this.minimizeForAudio();
			if (this.model.get('nway')) this.nway();
        },
		showOnlyUsername: function() {
			this.showInfos();
			this.hideSubtitle();
			this.hideCallDuree();
			this.showUsername();
		},

		setDraggable: function(containR) {
			var container = containR || this.container; // can be set on container or container.parentElement
			container.draggable = true;
			var posX;
			var posY;
            var posXRef;
			var posYRef;
			var mask;
			var showMask = function (evt) {
				mask = UWA.createElement('div', {
				'id':'IamAMaskToHelpDragDropOverIframe',
				'class':'ImustDisappearAfterDrop',
				styles: {
					position : 'absolute',
					height: '1000%',
					width: '1000%',
					top : '0',
					bottom : '0',
					right : '0',
					left : '0',
					margin: '0 auto',
					zIndex: 5000
				}});
				container.style.zIndex = 5001;
				mask.inject(document.body);
			};
			var hideMask = function (evt) {
                if (mask){
                    mask.hide();
    				mask.destroy();
                }
				container.style.zIndex = '';
			};

            var onmousemoveListener = function (evt) {
				if (typeof evt == 'undefined') var evt = window.event;
				posX = evt.clientX;
				posY = evt.clientY;
			};

            var onmousemoveListenerInDiv = function (evt) {
				if (typeof evt == 'undefined') var evt = window.event;
				posXRef = evt.offsetX;
				posYRef = evt.offsetY;
			};

			var ondragstartListener = function (evt) {
                document.addEventListener("dragover", onmousemoveListener);
				showMask();
                //posXRef = posX;
    			//posYRef = posY;
				logger.WebRTC('CallingComponent Drag Start');
				if (typeof evt == 'undefined') var evt = window.event;
				var style = window.getComputedStyle(evt.target, null);
				var offset_data = (parseInt(style.getPropertyValue('left'),10) - evt.clientX) + ',' + (parseInt(style.getPropertyValue('top'),10) - evt.clientY);
				if (evt && evt.dataTransfer && evt.dataTransfer.setData) evt.dataTransfer.setData('text/plain',offset_data);
				container.offset_data = offset_data;

			};
			var ondragendListener = function (evt) {
				logger.WebRTC('CallingComponent Drag End');
				if (typeof evt == 'undefined') var evt = window.event;
				//var offset = evt.dataTransfer.getData('text/plain').split(',');
				//if (!offset || !offset[0]) offset = container.offset_data.split(',');
                //var XX = this.getOffsets().x - (posXRef - posX); //+ this.getDimensions().width +
                //var YY = this.getOffsets().y - (posYRef - posY);
				evt.target.style.left = (posX - posXRef) + 'px';
				evt.target.style.top =  (posY - posYRef) + 'px';
				evt.target.style.bottom =  'auto';
				evt.target.classList.remove('initialPosition');
				evt.preventDefault();
				document.removeEventListener("dragover", onmousemoveListener);
                container.onmousemove = "";
				setTimeout(hideMask,100);
			};
			container.ondragstart = ondragstartListener;
			container.ondragend = ondragendListener;
			container.ontouchstart  = ondragstartListener;
			container.ontouchend = ondragendListener;
            container.onmousemove = onmousemoveListenerInDiv;
		},

        maximize: function() {
            /*
            this.container.parentElement.style.top = "";
            this.container.parentElement.style.left = "";
            this.container.parentElement.style.bottom = "";
            */
            this.addTooltip(this.container.parentElement ? this.container.parentElement.children.RTCallingComponent_buttons : this.container.children.RTCallingComponent_buttons, NLS.minimize || "Minimize");
			if (this.model.get('nway')) {
				if (this.model.get('state') == 'callvideo') this.maximizeForVideo();
				return true;
			}

            this.setSizeButtonSmall();
            this.showAllIcons();
            this.showTitle();
			this.showButtons();
			this.forcePosition();
            this.container.removeClassName('minimized');
            this.normalScreen();
            this.showUsername();
            //this.hideSelfVideo();
            if (this.model.get('state') == 'calling') this.hideButtons();
            else if (this.model.get('state') == 'callvideo') this.maximizeForVideo();
            else if (this.model.get('state') == 'callaudio') this.maximizeForAudio();
        },

        maximizeForVideo: function () {
			if (this.model.get('nway')) {
				this.container.addClassName('nwayvideo');
				return true;
			}
            this.showVideo();
            this.hideAvatar();
            this.hideTitle();
            this.showInfos();
            //this.showSelfVideo();
            this.showButtons();
            this.hideCallDuree();
			this.showCallDurationVid();
            this.showSubtitle();
			this.fullScreen();
        },

        maximizeForAudio: function () {
            this.hideTitle();
            this.removeIconsButHangUp();
            //this.showAudioIcon();
			this.showMicIcon();
			this.showVideoIcon();
            this.showSubtitle();
            this.showCallDuration();
			this.hideCallDureeVid();//useless
        },

        endCall : function () {
            //this.removeTooltip(this.container.parentElement.children.RTCallingComponent_buttons);
            this.showAvatar();
            //this.maximize();
            this.hideIcons();
            this.hideButtons();
            this.hideVideo();
            this.showSubtitle();
            this.hideCallDuree();
			this.hideCallDureeVid();
            this.showUsername();
            this.showInfos();
			this.stopRingtone();
			if (this.container.children && this.container.children.RTCallingComponent_title && this.container.children.RTCallingComponent_title.classList) this.container.children.RTCallingComponent_title.classList.remove("errorTitle");
			this.container.removeClassName('nwayvideo');
			this.showTitle();
            setTimeout((function(that) { return function(){
                that.remove();
            }})(this),2000);
        },

        toggleAudio : function(muted) {
            if (this.model.get('localAudio')) {
                this.dispatchEvent("stopDistantAudio"); // TODO
                this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_audio.innerHTML = svg_icons.RTwebrtc_icon_audio_muted;
            } else {
                this.dispatchEvent("startDistantAudio");
                this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_audio.innerHTML = svg_icons.RTwebrtc_icon_audio;
            }
        },

        toggleVideo : function(muted) {
			if ( this.model.get('isMyVideoOn') == 'audio')
				this.switchFromAudioToVideo();
            else if (this.model.get('localVideo')) {
                this.dispatchEvent("stopLocalVideo");
                this.displayMutedCameraIcon();
            } else {
                this.dispatchEvent("startLocalVideo");
                this.displayNormalCameraIcon();
            }
        },

		displayNormalCameraIcon : function () {
            //this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.innerHTML = svg_icons.RTwebrtc_icon_video;
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.addClassName('fonticon-videocamera');
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.removeClassName('fonticon-videocamera-off');
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.innerHTML = svg_icons.RTwebrtc_icon_video;
			this.addTooltip(this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video, NLS.muteVideo || "Hide camera");
		},

		displayMutedCameraIcon : function () {
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.removeClassName('fonticon-videocamera');
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.addClassName('fonticon-videocamera-off');
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video.innerHTML = svg_icons.RTwebrtc_icon_video_muted;
			this.addTooltip(this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video, NLS.unmuteVideo || "Show camera");
		},

		toggleMic : function(forceUnmute) {
            if (this.model.get('localAudio') && !forceUnmute) {
                this.dispatchEvent("stopLocalAudio");
				this.displayMutedMicIcon();
            } else {
                this.dispatchEvent("startLocalAudio");
                this.displayNormalMicIcon();
            }
        },

		displayNormalMicIcon : function () {
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic.removeClassName('fonticon-microphone-off');
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic.addClassName('fonticon-microphone');
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic.innerHTML = svg_icons.RTwebrtc_icon_mic;
			this.addTooltip(this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic, NLS.muteAudio || "Mute");
		},

		displayMutedMicIcon : function () {
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic.addClassName('fonticon-microphone-off');
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic.removeClassName('fonticon-microphone');
			this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic.innerHTML = svg_icons.RTwebrtc_icon_mic_muted;
			this.addTooltip(this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic, NLS.unmuteAudio || "Unmute");
		},

		switchFromAudioToVideo : function () {
			logger.WebRTC("RTCallingComponentView switchFromAudioToVideo");
			this.dispatchEvent("switchToVideo");
			//this.maximize();
            this.showVideo();
            //this.showSelfVideo();
            this.hideVideoNull();
			//if (!this.hasReceivedVideo)
			//	this.showVideoNull();
		},

        onClickListeners : {
            RTwebrtc_icon_mic : function (event, that) {
                if (that.model.get('state') == "callvideo" || that.model.get('state') == "callaudio") that.toggleMic();
            },
            RTwebrtc_icon_audio : function (event, that) {
                if (that.model.get('state') == "callvideo" || that.model.get('state') == "callaudio") that.toggleAudio();
            },
            RTwebrtc_icon_video : function (event, that) {
                if (that.model.get('isMyVideoOn')) that.toggleVideo();
				else that.switchFromAudioToVideo();
				//else logger.error("RTwebrtc_icon_video clicked but state is "+that.model.get('state'));
            },
            RTwebrtc_icon_phone_linked : function (event, that) {
                that.dispatchEvent("acceptCall",{room_id:that.model.get('room_id')});
                that.minimize();
                that.model.set({linkToOrder:true});
            },
            RTwebrtc_icon_phone : function (event, that) {
                that.dispatchEvent("acceptCall",{room_id:that.model.get('room_id')});
				that.maximize();
				that.removeIconsButHangUp();
				that.stopRingtone();
				that.tooltips['RTwebrtc_icon_phone'].destroy();
            },
            RTwebrtc_icon_phoneOFF : function (event, that) {
                //that.hide(); // will be hided when callEnded will be sent by the server
                that.dispatchEvent("endCall");
				that.stopRingtone();
            },
            RTCallingComponent_buttons : function (event, that) {
                if (event.target.classList.contains('fonticon-resize-small')) that.minimize();
                else that.maximize();
            }
        },

		getOnClickListener: function (id) {
			var listener = this.onClickListeners[id];
			if (!listener) return logger.error("getOnClickListener id does not exist : "+id);
			return (function(that) {
				return function(event) { return listener(event,that) };
			} )(this);
		},

		addTooltip : function (div, message, position) {
			if (!div || !div.id || !message) return logger.error("addTooltip missing args");
			if (!this.tooltips) this.tooltips = {};
			if(this.tooltips[div.id] && this.tooltips[div.id].destroy)
            {
                this.tooltips[div.id].destroy();
                delete this.tooltips[div.id];
            }
            //if(this.tooltips[div.id] && this.tooltips[div.id].destroy) this.tooltips[div.id].destroy();
			this.tooltips[div.id] = new Tooltip({target: div, body: message, position: position || 'left'});
			this.tooltips[div.id].getContent().style.zIndex = 1403;
		},

        removeTooltip : function (div) {
			if (!div || !this.tooltips ) return logger.error("removeTooltip missing args");
			if(this.tooltips[div.id] && this.tooltips[div.id].destroy)
            {
                this.tooltips[div.id].destroy();
                delete this.tooltips[div.id];
            }
		},

        render: function () {
            this.container.setContent([
                {   id: 'RTCallingComponent_avatar', tag: 'div',
                    html: [{ tag: 'img', src: this.model.get('avatarUrl') }]
                },{ id: 'RTCallingComponent_video', tag: 'div', 'class': 'hidden',
                    html: [{ id: 'RTCallingComponent_video_local', tag: 'video', playsinline:'playsinline', muted: 'true', autoplay: 'true', 'class': 'RTCallingComponent_video_local hidden' },
                           { id: 'RTCallingComponent_video_distant', tag: 'video', playsinline:'playsinline'},
						   { id: 'RTCallingComponent_video_null', tag: 'span', "class" : "fonticon fonticon-videocamera-off hidden" }]
                },{ id: 'RTCallingComponent_infos', tag: 'div',
                    html: [{ id: 'RTCallingComponent_username', tag: 'span', text: this.model.get('username')},
                           { id: 'RTCallingComponent_subtitle', tag: 'span', text: this.model.get('subtitle') ? this.model.get('subtitle') : ""},
                           { id: 'RTCallingComponent_callDuration', tag: 'span', 'class': "hidden", text: '00:00'/*this.model.get('callDuration')*/}]
                },{ id: 'RTCallingComponent_title', tag: 'div', text: this.model.get('title')
				},{ id: 'RTCallingComponent_callDuration_video', tag: 'span', 'class': "hidden", text: '00:00'
                },{ id: 'RTCallingComponent_icons', tag: 'div', 'class': 'RTCallingComponent_icons_calling',
                    html: [
						{ id:'RTwebrtc_icon_audio', tag: 'span', 'class': 'RTwebrtc_icon RTwebrtc_icon_audio fonticon fonticon-audio handler hidden',
                             html: svg_icons.RTwebrtc_icon_audio,
                             events: { click: this.getOnClickListener('RTwebrtc_icon_audio') }
                         },{ id:'RTwebrtc_icon_mic', tag: 'span', 'class': 'RTwebrtc_icon fonticon fonticon-microphone  handler hidden',
                             html: svg_icons.RTwebrtc_icon_mic,
							 events: { click: this.getOnClickListener('RTwebrtc_icon_mic') }
                         },{ id:'RTwebrtc_icon_video', tag: 'span', 'class': 'RTwebrtc_icon fonticon fonticon-videocamera handler hidden',
                             html: svg_icons.RTwebrtc_icon_video,
							 events: { click: this.getOnClickListener('RTwebrtc_icon_video') }
                         },{ id:'RTwebrtc_icon_phone_linked', tag: 'span', 'class': 'RTwebrtc_icon RTwebrtc_icon_phoneON fonticon fonticon-phone handler',
                             html: svg_icons.RTwebrtc_icon_phone_linked,
                             events: { click: this.getOnClickListener('RTwebrtc_icon_phone_linked') }
                         },{ id:'RTwebrtc_icon_phone', tag: 'span', 'class': 'RTwebrtc_icon RTwebrtc_icon_phoneON fonticon fonticon-phone handler',
                             html: svg_icons.RTwebrtc_icon_phone,
							 events: { click: this.getOnClickListener('RTwebrtc_icon_phone') }
                         },{ id:'RTwebrtc_icon_phoneOFF', tag: 'span', 'class': 'RTwebrtc_icon fonticon fonticon-phone hangup handler',
                             html: svg_icons.RTwebrtc_icon_phoneOFF,
							 events: { click: this.getOnClickListener('RTwebrtc_icon_phoneOFF') }
                        }]
                },{ id: 'RTCallingComponent_buttons', tag: 'div', 'class': 'RTwebrtc_start_buttons fonticon fonticon-resize-small handler',
				    events: { click: this.getOnClickListener('RTCallingComponent_buttons') } }
            ]);
			// Set reference to elements
			this.buttons = this.container.children.RTCallingComponent_buttons;
			this.localDivVideo = this.container.children.RTCallingComponent_video.children.RTCallingComponent_video_local;
			// ToolTips
			//this.addTooltip(this.buttons, NLS.minimize || "Minimize");


			//this.addTooltip(this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_mic, NLS.muteAudio || "Mute");
			//this.addTooltip(this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_video, NLS.muteVideo || "Hide camera");
			this.addTooltip(this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_phone, NLS.acceptCall || "Answer");
			this.addTooltip(this.container.children.RTCallingComponent_icons.children.RTwebrtc_icon_phoneOFF, NLS.refuseCall || "Hang up");

			// render has been done, now display what we want depending on the sate (here we are either receiving or sending the call : the call has not been accepted yet)
            if ( this.model.get('state').indexOf('incoming') == -1 )
                this.showOnCallIcons();
			if (this.model.get('state') == 'calling')
                this.removeIconsButHangUp(this.model.get('state'));
			this.hideButtons();
			this.detectDoubleTapOnVideoAndAvatar();
            return this;
        },
		destroy : function () {
			try {
				for (var i in this.tooltips)
					this.tooltips[i].destroy();
			} catch(e) {

			}
			this._parent();
		},

		displaySpinner : function() {
			//if (!this.spinner)
				//this.spinner = new Spinner().inject(this.container).show();
			if (!this.spinner)
				this.spinner = new Spinner().inject(this.container.children.RTCallingComponent_title).show();
			else
				this.spinner.show();
			this.showTitle();
		},
		hideSpinner : function() {
			if (this.spinner) this.spinner.hide();
			this.hideTitle();
		}
    });
});

define('DS/InstantMessagingWebRTC/js/model/RTCallingComponentModel',
    [
    'UWA/Class', 'UWA/Class/Model', 'UWA/Class/Timed',
    'DS/RTProxyDriver/RTLogger',
    'i18n!DS/InstantMessagingWebRTC/assets/nls/feed'
    ], function(
        Class, Model, Timed,
        logger,
        NLS
    ){
    'use strict';
	var Chrono = Class.extend(Timed, {
		increment : function() {
			this.set({callDuration : this.get('callDuration') + 1 }); // binded to model
		},
		run : function(model) {
			this.setPeriodical('second',this.increment,1000,true,model);
		},
		stop : function() {
			this.clearPeriodical('second');
		}
	});
    return Model.extend({
        defaults : {
            type : "video",
            devEnv : false,
            avatarUrl : './resources/en/1/webapps/InstantMessaging/assets/avatarDefault.png',
            username : 'John Smith',
            title : NLS.calling || 'Calling...',
            subtitle:null,
            login:'pne1',
            state:'calling',
            room_id:undefined,
            localVideo:true,
			localAudio:true,
            callDuration:0,
            linkToOrder:false,
			IamTheCaller:false,
			nway:false
        },
        setup: function(options) {
             if (options.devEnv) this.set({avatarUrl:'./assets/avatarDefault.png'});
             if (options.state && options.state !== 'calling')
                 this.set({ title : NLS[options.state == 'incoming' ? options.state+this.get('type') : options.state] || options.state});
             this.chrono = new Chrono();
			 if (options.orderId) this.set({subtitle : (NLS['Order'] || 'Order') + " #" + options.orderId});
	   },
        setTitleToNLS : function (NLSkey) {
            if (!NLSkey) return logger.error("setTitleToNLS no NLSkey provided");
			if (!NLS[NLSkey] && (NLSkey == "callaudio" || NLSkey == "callvideo")) {
				//if (this.get('IamTheCaller'))
					NLSkey = "Call";
				//else
				//	NLSkey = NLSkey.replace("call","incoming"); // bug IR-535349-3DEXPERIENCER2018x : this message should not be displayed, display something else while the state "call ended" is coming from the server
            }
			this.set({ title : NLS[NLSkey] || NLSkey});
        },
        setState : function (newState) {
            if (!newState) return logger.error("setState no newState provided");
            var etat = newState == 'call' ? newState+this.get('type') : newState;
            this.set({ state : etat });
            logger.WebRTC("RTCallingComponentModel setState to "+etat);
            this.setTitleToNLS(etat);
        },
		startCallDuration : function () {
			this.set({callDuration : 0 });
			this.chrono.run(this);
        },
		stopCallDuration : function () {
			this.set({callDuration : 0 });
			this.chrono.stop();
        },
    });
});



/**
* @module InstantMessagingWebRTC RTCallingComponent
*
*/

define('DS/InstantMessagingWebRTC/js/controller/RTCallingComponent',
['UWA/Class',
'UWA/Class/Events',
'UWA/Class/Model',
'UWA/Class/Debug',
'UWA/Class/View',
'DS/RTProxyDriver/RTLogger',
'DS/PlatformAPI/PlatformAPI',
'DS/RTProxyDriver/RTProxyDriver',
'i18n!DS/InstantMessagingWebRTC/assets/nls/feed',
'DS/InstantMessagingWebRTC/js/model/RTCallingComponentModel',
'DS/InstantMessagingWebRTC/js/view/RTCallingComponentView'],
function (Class, Events, Model, Debug, View, logger, PlatformAPI, RTProxyDriver, NLS, RTCallingComponentModel, RTCallingComponentView) {
'use strict';

var RTCallingComponent = Class.extend(Events, {
    init: function (options) {
        if (!options)
			return logger.error("no arg provided");
		this.nwayActivated = options.nwayActivated;
        this.user = options.user;
        logger.WebRTC("RTCallingComponent init for user "+this.user.login);
        var params = Object.assign(options.user, options); // copier les infos du user au premier niveau pour les init de UWA
        this.callingmodel = new RTCallingComponentModel(params);
        this.callingview = new RTCallingComponentView({model:this.callingmodel, nwayActivated : this.nwayActivated});
        this.callingview.render();
        this.callingview.inject(options.container || document.body);
        this.type=params.type;
        this.room_id=params.room_id;
        this.IamTheCaller=params.IamTheCaller;
        this.IacceptedCallOnRoom=params.IacceptedCallOnRoom; //multi-device flag
        this.endCall = function(dontEndCallOnRoom, reason) {
             RTProxyDriver.dispatch("endCall",[{room_id:this.room_id, reason:reason, user_id:this.user.user_id, dontEndCallOnRoom:dontEndCallOnRoom}]);
        }

        /* Buttons Listeners */
        this.addEventToView = function (eventName, callback) {
            this.callingview.addEvent(eventName, (function(that) { return function(opts){
                callback(opts, that);
            }})(this));
        };

        this.addEventToView('endCall', function(opts, that){that.endCall();});

        this.acceptCall = function(opts, that) {
            this.IacceptedCallOnRoom = this.room_id;
            RTProxyDriver.dispatch("acceptCall",[{room_id:this.room_id,type:this.type,user_id:this.user.user_id}]);
            clearTimeout(this.callMissed);
        }; this.addEventToView('acceptCall', function(opts, that){that.acceptCall();});

        this.stopLocalVideo = function(opts, that) {
            this.callingmodel.set({ localVideo : false });
            this.stopLocalVideoTrack();
        }; this.addEventToView('stopLocalVideo', function(opts, that){that.stopLocalVideo();});

        this.startLocalVideo = function(opts, that) {
            this.callingmodel.set({ localVideo : true });
            this.startLocalVideoTrack();
        }; this.addEventToView('startLocalVideo', function(opts, that){that.startLocalVideo();});

        this.stopLocalAudio = function(opts, that) {
            this.stopLocalAudioTrack();
            this.callingmodel.set({ localAudio : false });
        }; this.addEventToView('stopLocalAudio', function(opts, that){that.stopLocalAudio();});

        this.startLocalAudio = function(opts, that) {
            this.startLocalAudioTrack();
            this.callingmodel.set({ localAudio : true });
        }; this.addEventToView('startLocalAudio', function(opts, that){that.startLocalAudio();});

        this.switchToVideo = function(opts, that) {
            this.type="video";
            this.callingmodel.setState('callvideo');
            this.callingmodel.set('type','video');
            var that = this;
            this.getLocalMedia( function(error,stream) {
                if (error) return null; // display error message and endCall already called in getLocalMedia
                that.createPeer(true);
                if (that.peer3)
                    that.peer3.addStreamOrTracks(stream);
                else
                    that.peer2.addStreamOrTracks(stream);
                logger.WebRTC("Local Media Stream added to RTCPeerConnection");
                that.renegotiating = true;
                that.sendOffer(that.room_id, true, that.peer3 != undefined);// TOREMOVE when onnegotiationneeded official
            },true, true, false, true); // TODO mute audio in third param here
        }; this.addEventToView('switchToVideo', function(opts, that){that.switchToVideo();});

        this.callMissed = setTimeout((function(that) { return function(){ /* endCall after some time (IR-529597-3DEXPERIENCER2018x) */
            logger.WebRTC("RTCallingComponent call timeout");
            if (that.IamTheCaller) that.displayErrorAndEndCall('callTimeout', 10000, true);
            else that.displayErrorAndEndCall('callMissed', 10000);
        }})(this), 30000 );
    },

    updateUsername : function (username) {
        if (!username || typeof username != "string") return logger.error("RTCallingComponent updateUsername bad arg");
        logger.WebRTC("RTCallingComponent updateUsername from "+this.user.username+" to "+username);
        this.user.username = username;
        this.callingmodel.set({username:username}); // will update the view
    },

    setVarOrDefault : function (defaultvalue, value) {
        return value === undefined ? defaultvalue : value;
    },

    getLocalMedia : function (callback, video, audio, dontDisplay, renegotiating ) {

        var isVideo = this.setVarOrDefault(true, video);
        var isAudio = this.setVarOrDefault(true, audio);
		if (isVideo) this.callingmodel.set('isMyVideoOn',true);

      //  if((navigator.platform.indexOf("iPhone") != -1) || (navigator.platform.indexOf("iPod") != -1) || (navigator.platform.indexOf("iPad") != -1)) {
      //      return this.displayErrorAndEndCall('localMediaError_TypeError');
      //  }

        var successCallback = (function(that){ return function(stream) {
			/*if (that.localStream) {
				var i, track, tracks = that.localStream.getTracks();
				for (i in tracks) {
					track = tracks[i];
					track.stop();
				}
			}*/
            that.localStream = stream;
			logger.WebRTC("RTCallingComponent getLocalMedia got stream "+stream.id);

            /*if (!document.userMediaSteam || document.userMediaSteam.getTracks().length < stream.getTracks().length)
                document.userMediaSteam = stream;*/

            //if (!dontDisplay) that.callingview.showLocalStream(that.localStream, video);
            if (! callback && that.peer) that.peer.addStreamOrTracks(stream);
            callback(null,that.localStream);
        }})(this);
		
		var failCallback = (function(that){ return function(err) {
			logger.error(err);
			var errorMessages = {
				NotFoundError                   : 'localMediaError_NotFoundError',
				SecurityError                   : 'localMediaError_SecurityError',
				AbortError                      : 'localMediaError_AbortError',
				NotAllowedError                 : 'localMediaError_NotAllowedError',
				NotReadableError                : 'localMediaError_NotReadableError',
				OverConstrainedError            : 'localMediaError_OverConstrainedError',
				TypeError                       : 'localMediaError_TypeError',
				/* chrome specific */
				TrackStartError                 : 'localMediaError_NotReadableError',
				PermissionDeniedError           : 'localMediaError_NotAllowedError',
				InvalidStateError               : 'localMediaError_NotReadableError',
				DevicesNotFoundError            : 'localMediaError_NotFoundError',
				ConstraintNotSatisfiedError     : 'localMediaError_OverConstrainedError',
				MediaDeviceFailedDueToShutdown  : 'localMediaError_NotReadableError',
				MediaDeviceKillSwitchOn         : 'localMediaError_NotReadableError',
				/* edge specific */
				InternalError                   : 'localMediaError_NotReadableError',
				NotSupportedError               : 'localMediaError_TypeError'
			}
			var errorMessage = errorMessages[err.name] || err.name;
			that.displayErrorAndEndCall(errorMessage);
			callback(err);
		}})(this);

        var streamLengthAsked = video ? 2 : 1 ;
        /*if (document.userMediaSteam && document.userMediaSteam.getTracks().length >= streamLengthAsked)
            return successCallback(document.userMediaSteam);*/

        if (!navigator.getUserMedia) navigator.getUserMedia = navigator.webkitGetUserMedia || navigator.mozGetUserMedia; //useless
		if (this.localStream && !renegotiating) successCallback(this.localStream);// if an offer has already be received
		else this.dispatchEvent("getLocalMediaNway",{
			failCallback : failCallback,
			successCallback : successCallback,
			isVideo : isVideo,
			isAudio : isAudio,
			streamLengthAsked : streamLengthAsked
		});
		/*else if (navigator.mediaDevices) { // if navigator.mediaDevices exists, use it
            navigator.mediaDevices.getUserMedia({video: isVideo,
                audio: isAudio,
                googTypingNoiseDetection: false,
                googEchoCancellation: true,
                googAutoGainControl: false,
                googNoiseSuppression: false,
                googHighpassFilter: false
            }).then(successCallback, failCallback);
        } else navigator.getUserMedia({video: isVideo && {
                //width: { min: 1024, ideal: 1280, max: 1920 },
                //height: { min: 576, ideal: 720, max: 1080 },
                // "width": {
                    // "min": "300",
                    // "max": "640"
                // },
                // "height": {
                    // "min": "200",
                    // "max": "480"
                // },
                // "frameRate": {
                    // "max": "25"
                // }
            },
            audio: isAudio,
            googTypingNoiseDetection: false,
            googEchoCancellation: true,
            //googEchoCancellation2: true,
            googAutoGainControl: false,
            //googAutoGainControl2: false,
            googNoiseSuppression: false,
            //googNoiseSuppression2: false,
            googHighpassFilter: false
        }, successCallback, failCallback);*/
    },

    callEnded : function (data) {
        if (this.callingmodel.get("state").indexOf('incoming') == -1)// the call has been accepted then the ringtone has been muted
            document.ringtone.muted = false;

        clearTimeout(this.callMissed);
        this.callingmodel.setState('ended');
        this.callingmodel.stopCallDuration();

		if (data && data.reason == 'callMissed' && this.IamTheCaller) data.reason = 'callTimeout';

        this.displayErrorAndEndCall(data ? data.reason : null,undefined,true,true);
        this.isStarted=false;
        //this.stopLocalTracks();

        if (this.peer) {
            this.peer.close();
            delete this.peer;
            this.peer = null;
        } else logger.WebRTC("callEnded but no peer");
        if (this.peer2) {
            this.peer2.close();
            delete this.peer2;
            this.peer2 = null;
        } else logger.WebRTC("callEnded no second peer to close");
        if (this.peer3) {
            this.peer3.close();
            delete this.peer3;
            this.peer3 = null;
        } else logger.WebRTC("callEnded no third peer to close");

    },

    forEachLocalTrack : function (callback) {
        if (!callback) return false;
        if (!this.peer && !this.peer2 && !this.peer3) return null;
        var i, j, track, tracks, stream, streams;
        if (!this.peer.getLocalStreams) return null;
        streams = this.peer.getLocalStreams();
		if (streams.length == 0) streams = [this.localStream];
        if (this.peer2)
            streams = Object.assign(streams, this.peer2.getLocalStreams());
        if (this.peer3)
            streams = Object.assign(streams, this.peer3.getLocalStreams());
        for (j in streams) {
            stream = streams[j];
			if (!stream) continue;
            tracks = stream.getTracks();
            for (i in tracks) {
                track = tracks[i];
                if (callback(track)) break;
            }
        }
    },
    logLocalTracks : function () {
        return this.forEachLocalTrack(logger.WebRTC);
    },
    stopLocalTracks : function () {
        return this.forEachLocalTrack(function(track){ track.stop(); });
    },
    enableLocalTracks : function () {
        return this.forEachLocalTrack(function(track){
            track.enabled=true;
        });
    },
    stopLocalVideoTrack : function () {
        logger.WebRTC("stopLocalVideoTrack");
        return this.forEachLocalTrack(function(track){
            if (track.kind === 'video') {
                //track.stop();
                track.enabled=false;
                return true;
            } return false;
        });
    },
    stopLocalAudioTrack : function () {
        logger.WebRTC("stopLocalAudioTrack");
        return this.forEachLocalTrack(function(track){
            if (track.kind === 'audio') {
                track.enabled=false;
                //track.stop();
                return true;
            } return false;
        });
    },
    startLocalVideoTrack : function () {
        logger.WebRTC("startLocalVideoTrack");
        return this.forEachLocalTrack(function(track){
            if (track.kind === 'video') {
                track.enabled=true;
                return true;
            } return false;
        });
    },
    startLocalAudioTrack : function () {
        logger.WebRTC("startLocalAudioTrack");
        return this.forEachLocalTrack(function(track){
            if (track.kind === 'audio') {
                track.enabled=true;
                return true;
            } return false;
        });
    },
    muteLocalAudioTrack  : function () { // remove echo
        return this.forEachLocalTrack(function(track){
            if (track.kind === 'audio') {
                track.muted=true;
            }
            return false;
        });
    },
    onSDP : function (data) {
        if (data.user.login != this.user.login) return logger.error("onSDP received from "+data.user.login+" instead of "+this.user.login);
        if (data.isCaller) this.onOffer(data);
        else this.onAnswer(data);
    },
    onAnswer : function (data) {
        logger.WebRTC("onAnswer "+this.peer.signalingState);
        var peer = this.peer3 || this.peer2 || this.peer; // TODO faire passer le parem renogiating par le serveur (idem que l'event IceCandidate)
        var peer2 = this.peer2;
        var peer3 = this.peer3;
        if (data.secondSwitch) peer = this.peer3;
        else if (data.renegotiating) peer = this.peer2;
        else peer = this.peer;

        peer.setRemoteDescription(new RTCSessionDescription(data.sdp)).catch(function(error) {
            logger.WebRTC("onAnswer setRemoteDescription failed, trying on other peer");
            if (peer.RTCidentifier == "peer2") peer = peer3;
            else if (peer.RTCidentifier == "peer3") peer = peer2;
            else return logger.error(error);
            peer.setRemoteDescription(new RTCSessionDescription(data.sdp))
            .catch(function(error) {
                logger.error("onAnswer failed to setRemoteDescription " + error);
            });
        });

        /*
        peer.setRemoteDescription(new RTCSessionDescription(data.sdp), function () {
            logger.WebRTC("onAnswer setRemoteDescription success");
        }, function (error) {
            logger.WebRTC("onAnswer setRemoteDescription failed, trying on other peer");
            if (peer.RTCidentifier == "peer2") peer = peer3;
            else if (peer.RTCidentifier == "peer3") peer = peer2;
            else return logger.error(error);
            peer.setRemoteDescription(new RTCSessionDescription(data.sdp), function () {
                logger.WebRTC("onAnswer setRemoteDescription success");
            },logger.error);
        });
        */
    },
    onOffer : function (data) {
        logger.WebRTC("onOffer ");
        var peer, callback= function (that, done) {
                done(); // if scondSwitch or renegotiating, then we receive a switch to video from interlocutor, and no need to getlocalmedia
        };
        if (data.secondSwitch) {
            if (!this.peer3) this.createPeer(true);
            peer = this.peer3;
        }
        else if (data.renegotiating) {
            if (!this.peer2) this.createPeer(true);
            peer = this.peer2;
        }
        else {
            if (!this.peer) this.createPeer(false);
            peer = this.peer;
            callback = function (that, done) { // if no switch then the call is new and need to getlocalmedia
				//return done();
                that.getLocalMedia(function(error,stream) {
                    if (error) return null; // display error message and endCall already called in getLocalMedia
                    peer.addStreamOrTracks(stream);
                    logger.WebRTC("Local Media Stream added to RTCPeerConnection");
                    done();
                }, that.type === 'video'); // TODO mute audio in third param here
            };
        }

        var that = this;

        peer.setRemoteDescription(new RTCSessionDescription(data.sdp))
        .then(function (){
            logger.WebRTC("onOffer setRemoteDescription success");
            callback(that, function() {
                peer.createAnswer()
                .then( function(answer) {
                    peer.setLocalDescription(answer)
                    .then(function () {
                        logger.WebRTC("onOffer setLocalDescription success");
                        RTProxyDriver.dispatch("SDP",[{room_id:data.room_id, user_id:that.user.user_id, sdp:answer, isCaller:false, renegotiating:data.renegotiating, secondSwitch:data.secondSwitch }]);
                    }).catch();
                }).catch(function(reason) {

                });
            });
        })
        .catch(function(reason) {
            logger.error("onOffer failed to setRemoteDescription " + reason);
        });

        /*
        peer.setRemoteDescription(new RTCSessionDescription(data.sdp), (function(that) { return function() {
            logger.WebRTC("onOffer setRemoteDescription success");
            callback(that, function() {
                peer.createAnswer( function(answer) {
                    peer.setLocalDescription(answer, function () {
                        logger.WebRTC("onOffer setLocalDescription success");
                        RTProxyDriver.dispatch("SDP",[{room_id:data.room_id, user_id:that.user.user_id, sdp:answer, isCaller:false, renegotiating:data.renegotiating, secondSwitch:data.secondSwitch }]);
                    }, logger.error);
                }, logger.error, {
                //mandatory: { OfferToReceiveAudio: true, OfferToReceiveVideo: true }
                });
            });
          }})(this), logger.error);
          */

    },
    sendOffer : function (room_id, renegotiating, secondSwitch) {
        if (!room_id) return logger.error("RTCallingComponent sendOffer arg room_id needed");
        var peer;
        if (secondSwitch) peer = this.peer3;
        else if (renegotiating) peer = this.peer2;
        else peer = this.peer;
		logger.WebRTC("createOffer on peer "+peer.RTCidentifier+" and send it to "+this.user.login+" on room "+room_id);

        var that = this;

        peer.createOffer().then(function(offer) {
            return peer.setLocalDescription(offer);
        })
        .then(function() {
            RTProxyDriver.dispatch("SDP",[{room_id:room_id, user_id:that.user.user_id, sdp:peer.localDescription, isCaller : true, renegotiating:renegotiating, secondSwitch:secondSwitch }]);
        })
        .catch(function(reason) {
            logger.error("sendOffer failed to createOffer " + reason);
        });

        /*
        peer.createOffer((function(that) { return function(offer){
            peer.setLocalDescription(offer, function () {
                logger.WebRTC("sendOffer setLocalDescription success");
                RTProxyDriver.dispatch("SDP",[{room_id:room_id, user_id:that.user.user_id, sdp:offer, isCaller : true, renegotiating:renegotiating, secondSwitch:secondSwitch }]);
            }, function (error) {
                logger.error("sendOffer failed to setLocalDescription "+error);
            });
        }})(this), function (error) {
            logger.error("sendOffer failed to createOffer "+error);
        }, {
            //mandatory: { OfferToReceiveAudio: true, OfferToReceiveVideo: true }
        });
        */
    },
    handleNegotiationNeededEvent : function (that) {
		return function() {
			logger.WebRTC("handleNegotiationNeededEvent "+that.isCaller);
			return true;
			if (that.isCaller) that.sendOffer(that.room_id);
		}
    },
    callAccepted : function (data) {
        this.callingmodel.startCallDuration();
        clearTimeout(this.callMissed);//P8D - IR-536472-3DEXPERIENCER2018x
        this.room_id = data.room_id;
        if (!this.IacceptedCallOnRoom || this.IacceptedCallOnRoom != data.room_id) {
            this.callEnded();
            return logger.WebRTC("callAccepted on other device");
        }
        this.type = data.type;
        this.webrtcConfig = data.webrtcConfig;
        this.isCaller = data.isCaller;
        this.callingmodel.setState('call');
        this.isStarted=true;
        document.ringtone.muted = true;

        logger.WebRTC("callAccepted of type "+data.type+" in room "+data.room_id+" isCaller : "+data.isCaller);
        logger.table(data.webrtcConfig.iceServers);
		this.callingview.displaySpinner();

        if ( ! this.isCaller) return true;

        /* Create RTCPeerConnection */
        this.createPeer();
        this.peer.onnegotiationneeded = this.handleNegotiationNeededEvent(this); // send Offer when RTCPeerConnection is ready
		logger.WebRTC("callAccepted RTCPeerConnection created. Getting local media...");

        /* Get Local Media and add it to RTCPeerConnection */
        this.getLocalMedia((function(that) { return function(error,stream) {
			logger.WebRTC("callAccepted getLocalMedia done.");
            if (error) return null; // display error message and endCall already called in getLocalMedia
            that.peer.addStreamOrTracks(stream);
            logger.WebRTC("Local Media Stream added to RTCPeerConnection");
			if (that.isCaller)
				that.sendOffer(that.room_id); // TOREMOVE when onnegotiationneeded official
        }})(this),this.type === 'video'); // TODO mute audio in third param here
        return true;
    },

    createPeer : function (renegotiating) {
        if (this.peer && !renegotiating) return logger.error("RTCallingComponent can not createPeer that already exists");
        if (!this.webrtcConfig || !this.webrtcConfig.iceServers) return logger.error("RTCallingComponent failed to createPeer without webrtcConfig.iceServers");
        var peer;
        try {
            peer = new RTCPeerConnection(this.webrtcConfig); /* WebRTC Protocol starts here */
            if (renegotiating) {
                if (this.peer2) {
                    this.peer3 = peer;
                    this.peer3.RTCidentifier = "peer3";
                }
                else {
                    this.peer2 = peer;
                    this.peer2.RTCidentifier = "peer2";
                }
            } else {
                this.peer = peer;
                this.peer.RTCidentifier = "peer1";
            }
        }
        catch(e) {
            this.displayErrorAndEndCall('localMediaError_TypeError');
            return logger.error("RTCallingComponent failed to createPeer : RTCPeerConnection is undefined");
        }
        logger.WebRTC("RTCallingComponent createPeer RTCPeerConnection done");

        /*  Add Listeners of Stream and Ice to RTCPeerConnection */
		peer.onnegotiationneeded = this.handleNegotiationNeededEvent(this);
        peer.addStreamOrTracks = function (stream) {
            if (!stream) return logger.error("RTCallingComponent addStreamOrTracks called without stream "+peer.RTCidentifier);
			logger.WebRTC("addStreamOrTracks");
            if (this.addTrack) {
                try {
                    var i, tracks = stream.getTracks();
                    for (i=0; i<tracks.length; i++)
                        this.addTrack(tracks[i], stream); //experimental (june2017)
                } catch (e) { logger.error(e); }
            }
            else if (this.addStream) {
                try {                this.addStream(stream); } //deprecated (june2017)
                catch(e){
                     logger.error("RTCallingComponent addStreamOrTracks failed to addStream");
                }
            }
            else logger.error("RTCallingComponent addStreamOrTracks called but addTrack & addStream unexist "+peer.RTCidentifier);
        };
        peer.ontrack = (function(that) { return function (e) {
            var stream = e.stream || e.streams[0];
            if (!stream) return logger.error("ontrack raised but stream not found "+peer.RTCidentifier);
            logger.WebRTC("Remote stream received !");
            var tracks = stream.getTracks();
            if (tracks.length >= 2 || tracks[0].kind=='video' ) {
                that.callingmodel.setState('callvideo');
				that.callingmodel.set({type:'video'});
			}
            that.callingview.showDistantStream(stream); /* WebRTC Protocol ends here */
			that.callingview.hideSpinner(); //useless since hideTitle is already called (spinner is in the title)
            that.callingview.showCallDuration();
            //that.callingview.showSelfVideo();
            //that.callingview.playLocalVideo();
            //that.callingmodel.startCallDuration();
            //that.muteLocalAudioTrack();
            that.logLocalTracks();
			that.distantStream = stream;
/*
			if((navigator.platform.indexOf("iPhone") != -1) || (navigator.platform.indexOf("iPod") != -1) || (navigator.platform.indexOf("iPad") != -1))
				if (peer.RTCidentifier != "peer2" && peer.RTCidentifier != "peer3")
					if (peer.iceConnectionState != 'connected' && peer.iceConnectionState != 'completed')
						that.sendOffer(that.room_id);// only for iOS
*/
            //that.getRTConf(); // log ice server currently used
        } })(this);
        peer.onaddstream = peer.ontrack; // deprecated (june2017)
        peer.onicecandidate = (function(that) { return function (icedata) {
            logger.WebRTC("onicecandidate");
            if(that.renegotiating)    return;
            if (icedata.candidate) {
                RTProxyDriver.dispatch("webrtcIceCandidate",[{room_id:that.room_id, user_id:that.user.user_id, candidate:icedata.candidate, renegotiating:renegotiating }]);
            }
        } })(this);
        peer.onsignalingstatechange = (function(that) { return function (event) {
            if (peer) logger.WebRTC('ICE Signaling state changed to '+peer.signalingState);
            else return logger.WebRTC('onsignalingstatechange changed but RTCPeerConnection is null');
            if (peer.signalingState == 'stable') that.renegotiating = false;
            else if (peer.signalingState == 'have-remote-offer') that.renegotiating = true;
        } })(this);
        peer.onicegatheringstatechange = (function(that) { return function (event) {
            if (peer) logger.WebRTC('ICE Gathering state changed to '+peer.iceGatheringState+" "+peer.RTCidentifier);
        } })(this);
        peer.oniceconnectionstatechange = (function(that) { return function (event) {
            if (!peer) {
                return logger.WebRTC('ICE Connection state changed but no peer '+peer.RTCidentifier);
                //return that.endCall();
            }
            var state = peer.iceConnectionState;
            logger.WebRTC('ICE Connection state changed to '+state+" "+peer.RTCidentifier);
            //if (state == "disconnected" && !that.renegotiating) return that.displayErrorAndEndCall(NLS.ICEdisconnected);
            if (state == "failed") return that.displayErrorAndEndCall('ICEfailed');
        } })(this);
    },

    displayErrorAndEndCall : function (errorMessage, msBeforeEndCallArg, dontEndCallOnRoom, dontSendEndCall, reason) {
		var msBeforeEndCall = msBeforeEndCallArg || 10000;
        if ( ! this.callingview ) return logger.error("RTCallingComponent displayErrorAndEndCall but no callingview ");
        if ( ! this.room_id ) return logger.error("RTCallingComponent displayErrorAndEndCall but no room_id ");
        if ( errorMessage ) this.callingview.displayError(errorMessage);
        if (!dontSendEndCall) this.endCall(dontEndCallOnRoom, errorMessage, reason);
        else if(!errorMessage) this.callingview.endCall();
        else {
            setTimeout((function(that) {return function(){
                that.callingview.endCall();
                that.callingmodel.setState('ended');
                setTimeout(function(){ if (that.callingview && that.callingview.remove) that.callingview.remove(); },10000); // after another 10s if callEnded not received then remove the view
            }})(this), msBeforeEndCall); // 10s to read the error
        }
        logger.WebRTC("displayErrorAndEndCall "+errorMessage);
    },

	addCachedIceCandidates : function() {
		if (!this.peer || this.peer.signalingState != 'stable' || this.peer.iceGatheringState != 'complete')  {
			logger.error("addCachedIceCandidates unavailable "+(this.peer ? this.peer.signalingState + this.peer.iceConnectionState + this.peer.iceGatheringState : ''));
		}
		var iceCand, i;
		for (i in this.iceCandidates) {
			iceCand = this.iceCandidates[i];
			this.onWebRTCIceCandidate({candidate : iceCand}, true);
		}
	},

    onWebRTCIceCandidate : function (data, cached) {
        if (!this.peer /*|| this.peer.signalingState != 'stable' || this.peer.iceGatheringState != 'complete'*/)  {
            logger.error("Received an ICE candidate but no peer. Storing it for later");
            if (!this.iceCandidates) this.iceCandidates = [];
            return this.iceCandidates.push(data.candidate);
        }

        var peer = this.peer3 || this.peer2 || this.peer;//TODO faire passer le param renegotiating par le serveur
        var peer2 = this.peer2;
        var peer3 = this.peer3;

        logger.WebRTC("onWebRTCIceCandidate " + (cached ? 'cached' : '') + this.peer.signalingState + this.peer.iceConnectionState + this.peer.iceGatheringState/*+JSON.stringify(data)*/);
        peer.addIceCandidate(new RTCIceCandidate(data.candidate),function(){
            logger.WebRTC("onWebRTCIceCandidate success");
        }, function (error) {
            logger.WebRTC("onWebRTCIceCandidate addIceCandidate failed, trying on other peer. "+error);
            if (peer.RTCidentifier == "peer2") peer = peer3;
            else if (peer.RTCidentifier == "peer3") peer = peer2;
            else return logger.error(error);
            peer.addIceCandidate(new RTCIceCandidate(data.candidate),function(){
                logger.WebRTC("onWebRTCIceCandidate success");
            },logger.error);
        });
    },
	
	onCallEvent : function (data) {
		if (data.action == "mute") {
			logger.WebRTC("track of type "+data.type+" has been muted by "+data.login);
		} else logger.WebRTC("onCallEvent "+JSON.stringify(data));
	},

    nway : function () {
        this.callingmodel.set({nway:true});
        //this.callingview.minimize();
        this.callingview.container.draggable = false;
    }
});
return RTCallingComponent;
});

define('DS/InstantMessagingWebRTC/js/view/RTCallingComponentViewNway',
    [
		'UWA/Class',
		'DS/InstantMessagingWebRTC/js/view/RTCallingComponentView'
    ], function(
		Class,
		RTCallingComponentView
    ){
    'use strict';
	// TODO2 : quand hauteur > largeur, direction column
	// TODO2 : vérifier que le nway disparait quand on passe de 2 à 1 call
	// TODO : bug endCall all on error instead of the one in error only
	// TODO : on voit pas le username au doublickik
	// TODO : fx end au last cc
	// TODO : gérer les components avant le lancement de l'appel

    return RTCallingComponentView.extend({
		init: function(options){
			this._parent( options );
			this.normalCameraIcon = true;
			this.normalMicIcon = true;
		},
		displayMutedCameraIcon: function(options){
			this._parent( options );
			this.normalCameraIcon = false;
		},
		displayNormalCameraIcon: function(options){
			this._parent( options );
			this.normalCameraIcon = true;
		},
		toggleVideo: function(){
			if (this.normalCameraIcon) this.displayMutedCameraIcon();
			else this.displayNormalCameraIcon();
		},
		displayMutedMicIcon: function(options){
			this._parent( options );
			this.normalMicIcon = false;
		},
		displayNormalMicIcon: function(options){
			this._parent( options );
			this.normalMicIcon = true;
		},
		toggleAudio: function(){
			if (this.normalMicIcon) this.displayMutedMicIcon();
			else this.displayNormalMicIcon();
		},
		setTypeTo: function(type){
			if (type==='video') this.displayNormalCameraIcon();
			if (type==='audio') this.displayMutedCameraIcon();
		},
        onClickListeners : {
            RTwebrtc_icon_mic : function (event, that) {
				that.toggleAudio();
				that.dispatchEvent("RTwebrtc_icon_mic", {enabled:that.normalMicIcon});
			},
            RTwebrtc_icon_audio : function (event, that) {
				that.dispatchEvent("RTwebrtc_icon_audio");
			},
            RTwebrtc_icon_video : function (event, that) {
				that.toggleVideo();
				that.dispatchEvent("RTwebrtc_icon_video", {enabled:that.normalCameraIcon});
			},
            RTwebrtc_icon_phoneOFF : function (event, that) {
                that.dispatchEvent("RTwebrtc_icon_phoneOFF");
            },
            RTCallingComponent_buttons : function (event, that) {
                if (that.container.parentElement.hasClassName("minimized")){
					that.maximize();
				} else {
					that.minimize();
				}
            }
        },

		minimize : function() {
			this.container.parentElement.addClassName("minimized");
            /*
            var fx = new UWA.Fx(this.container.parentElement,{
                duration : 600,
                transition: 'linear'
            });
            fx.start({width:250,height:200});
            */
			this.setSizeButtonFull();
			this.removeIconsButHangUp();
			//this.hideSelfVideo();
			//this.hideVideo();
			this.dispatchEvent("minimizeNWAY");
			this.hideCallDureeVid();
            if((navigator.platform.indexOf("iPhone") === -1) && (navigator.platform.indexOf("iPod") === -1) && (navigator.platform.indexOf("iPad") === -1)) {
                this.setDraggable(this.container.parentElement);
            }
		},
		maximize : function() {

            this.container.parentElement.style.top = "";
            this.container.parentElement.style.left = "";
            this.container.parentElement.style.bottom = "";

			this.container.parentElement.removeClassName("minimized");
            /*
            var offW = this.container.parentElement.offsetWidth;
            var offH = this.container.parentElement.offsetHeight;

            var fx = new UWA.Fx(this.container.parentElement,{
                duration : 600,
                transition: 'linear'
            });
            fx.start({width:[250,offW],height:[200,offH]});
            */
			this.setSizeButtonSmall();
			this.showOnCallIcons();
            //this.hideSelfVideo();
			//this.showSelfVideo();
			//this.showVideo();
			this.dispatchEvent("maximizeNWAY");
		},
		render : function(options) {
			this._parent( options );
			this.container.addClassName("nwaycontainer");
			this.hideAvatar();
			this.hideTitle();
			this.hideInfos();
			this.showOnCallIcons();
			if(options.container)
			{
				this.container.children.RTCallingComponent_buttons.inject(options.container);
			}
		},

		endCall : function() {
			logger.error("no way to get here");
		}


	});
});

/**
* @module InstantMessagingWebRTC RTCallingComponent
*
*/

define('DS/InstantMessagingWebRTC/js/controller/RTCallingComponentNway',
['UWA/Class',
'UWA/Class/Events',
'UWA/Class/Model',
'UWA/Class/Debug',
'UWA/Class/View',
'DS/RTProxyDriver/RTLogger',
'DS/PlatformAPI/PlatformAPI',
'DS/RTProxyDriver/RTProxyDriver',
'i18n!DS/InstantMessagingWebRTC/assets/nls/feed',
'DS/InstantMessagingWebRTC/js/model/RTCallingComponentModel',
'DS/InstantMessagingWebRTC/js/view/RTCallingComponentViewNway'],
function (Class, Events, Model, Debug, View, logger, PlatformAPI, RTProxyDriver, NLS, RTCallingComponentModel, RTCallingComponentViewNway) {
'use strict';

var RTCallingComponentNway = Class.extend(Events, {
    init: function (options) {
        if (!options) { return logger.error("no arg provided"); }
		this.nwayActivated = options.nwayActivated;
        logger.WebRTC("RTCallingComponentNway init");
		
		this.failCallbacks = [];
		this.successCallbacks = [];
/*
        this.infoRoom = UWA.createElement('div', {'class':'RTOnCallComponents-info'});
        this.infoRoom.style.display = 'none';
        this.infoRoom.inject(options.container || document.body);

        this.infoRoomView = new IMWInfoRoomView({display3dplayer:function(){}});
        this.infoRoomView.inject(this.infoRoom);
*/
		this.onCallComponentsView = UWA.createElement('div', {'id':'RTOnCallComponents','draggable':'true'});
		this.onCallComponentsView.inject(options.container || document.body);
		this.onCallComponentsView.hide();
		/*
		var that = this;
		this.infoIcon = UWA.createElement('span', {
			'class':'RTOnCallComponents-info-icon fonticon fonticon-info handler',
			events:{
				click:function(evt){

					if (that.infoRoom.style.display === 'none'){
						that.infoRoom.style.display = 'block';
						var fx = new UWA.Fx(that.infoRoom,{
			                duration : 300,
			                transition: 'sineOut'
			            });

			            var fxVideo = new UWA.Fx(that.onCallComponentsView,{
			                duration : 300,
			                transition: 'sineOut'
			            });
			            fxVideo.start({right: 400});

			            fx.start({right: 0});
					}
					else{

						var fx = new UWA.Fx(that.infoRoom,{
			                duration : 300,
			                transition: 'sineOut',
			                events: {
			                    onComplete: function(evt){
			                        that.infoRoom.style.display = 'none';
			                    }
			                }
			            });
			            var fxVideo = new UWA.Fx(that.onCallComponentsView,{
			                duration : 300,
			                transition: 'sineOut'
			            });
			            fxVideo.start({right: 0});
			            fx.start({right: -401});
					}
				}
			}
		});
		this.infoIcon.inject(this.onCallComponentsView);
		*/
		this.callingmodel = new RTCallingComponentModel(options);
		this.callingmodel.setState('callvideo');
		this.callingview = new RTCallingComponentViewNway({model:this.callingmodel});
        this.callingview.render({container : this.onCallComponentsView});
		this.callingview.hide();

		this.callingComponents = [];

        /* Buttons Listeners */
		this.addEventToView = function (eventName, callback) {
			this.callingview.addEvent(eventName, (function(that) { return function(opts){
				callback(opts, that);
			}})(this));
		};
		var butt, nwayButtons = ['RTwebrtc_icon_phoneOFF', 'RTwebrtc_icon_mic', 'RTwebrtc_icon_audio', 'RTwebrtc_icon_video']; // those events will be broadcasted to all the CC
		for (var i in nwayButtons) {
			butt = nwayButtons[i];
			(function (butt, self) {
				self.addEventToView(butt, function(opts, that) {
					var cc;
					for (var i in self.callingComponents) {
						cc = self.callingComponents[i];
						cc.callingview.onClickListeners[butt](null,cc.callingview);
					}
				});
			})(butt, this);
		}
		this.addEventToView('RTwebrtc_icon_phoneOFF', function(opts, that) {
			that.remove(); // TODO don't overwrite remove and use the one of a simple CallingView without onCallComponentsView
		});
		this.addEventToView('RTwebrtc_icon_mic', function(opts, that) {
			opts.type="audio";
			opts.action="mute";
			opts.room_id=that.room_id;
			RTProxyDriver.dispatch("callEventFromView",opts);
		});
		this.addEventToView('RTwebrtc_icon_video', function(opts, that) {
			opts.type="video";
			opts.action="mute";
			opts.room_id=that.room_id;
			RTProxyDriver.dispatch("callEventFromView",opts);
		});
		this.addEventToView("minimizeNWAY", function(opts, that) {
			that.isMaximized = false;
			that.onCallComponentsView.draggable = true;
			if (that.nwayActivated) {
				//that.callViewMethodOfAllComponents('hideInfos');
				//that.callViewMethodOfAllComponents('hideUsername');
				if (that.isNway()) that.callViewMethodOfAllComponents('hideAvatar');
			} else that.callViewMethodOfAllComponents('minimize');
		});
		this.addEventToView("maximizeNWAY", function(opts, that) {
			that.isMaximized = true;
			that.onCallComponentsView.draggable = false;
			if (that.nwayActivated) {
				//that.callViewMethodOfAllComponents('showOnlyUsername');
				if (that.isNway()) that.callViewMethodOfAllComponents('showAvatar');
			} else that.callViewMethodOfAllComponents('maximize');
		});
    },
	remove: function () {
		this.onCallComponentsView.style.transform = "scale(0)";
		this.callingview.hide();
		setTimeout((function(that) { return function(){
			that.onCallComponentsView.hide();
		}})(this),500); // CSS transition is set to 0.5s
	},
	updateComponentsClassName : function () {
		var length = this.callingComponents.length;
		var offset = 0;
		if (this.fulledCC) offset = -1;
		var cc;
		for (var i in this.callingComponents) {
			cc = this.callingComponents[i];
			if (cc === this.fulledCC) continue;
			cc.callingview.container.removeClassName("qty"+(length>10?'Infinite':(length-1+offset)));
			cc.callingview.container.removeClassName("qty"+(length>10?'Infinite':(length+1+offset)));
			cc.callingview.container.addClassName("qty"+(length>10?'Infinite':(length+offset)));
		}
	},
	removeClassFromAllComponents : function (className) {
		var cc;
		for (var i in this.callingComponents) {
			cc = this.callingComponents[i];
			cc.callingview.container.removeClassName(className);
		}
	},
	callViewMethodOfAllComponents : function(method_name,data) {
		var cc;
		for (var i in this.callingComponents) {
			cc = this.callingComponents[i];
			cc.callingview[method_name](data);
		}
	},
	addComponent : function (callingComponent) {
		if (!callingComponent)  return logger.error("addComponent bad arg");
		this.room_id = callingComponent.room_id;
		this.show();
		callingComponent.callingview.inject(this.onCallComponentsView);

		this.callingComponents.push(callingComponent);
		this.callingview.setTypeTo(callingComponent.type);
		
		// force mic unmute IR-661154-3DEXPERIENCER2019x
		this.callingview.displayNormalMicIcon();
		this.callingview.displayNormalCameraIcon();
		this.callViewMethodOfAllComponents('toggleMic',true);
		
		callingComponent.nway();

		if (this.nwayActivated) {
			if (!this.isMaximized) //refresh
				this.callingview.dispatchEvent("minimizeNWAY");
			else this.callingview.dispatchEvent("maximizeNWAY");
		}


		callingComponent.addEventToView("doubleClick",(function (that) { return function(opts, cc) {
			that.removeClassFromAllComponents("fulled");
			if (that.fulledCC != cc) {
				cc.callingview.container.addClassName("fulled");
				that.fulledCC = cc;
			} else that.fulledCC = null;
			that.updateComponentsClassName();
		}})(this));

		//if (this.isNway())
		//{
			this.callingview.show();
			this.onCallComponentsView.addClassName("nway");
			this.callingview.inject(this.onCallComponentsView);
			this.callingview.showButtons();
			this.updateComponentsClassName();

			if ( ! this.isNway()) {
				this.callingview.minimize();
			}

			for (var cc in this.callingComponents) {
				if (this.callingComponents[cc] && this.callingComponents[cc].isStarted && this.callingComponents[cc].callingview && this.callingComponents[cc].callingview.container)
					this.callingComponents[cc].nway();
			}

			//this.addEventToCCView(callingComponent,'localStreamLoad', function(opts, that){that.updateLocalVideo();});
			this.addEventToCC(callingComponent,'getLocalMediaNway', function(opts, that){that.getLocalMedia(opts);});
		//}
    },
	addEventToCCView : function (cc, eventName, callback) {
		cc.callingview.addEvent(eventName, (function(that) { return function(opts){
			callback(opts, that);
		}})(this));
	},	
	addEventToCC : function (cc, eventName, callback) {
		cc.addEvent(eventName, (function(that) { return function(opts){
			callback(opts, that);
		}})(this));
	},
	getLocalMedia : function(opts) {
		this.failCallbacks.push(opts.failCallback);
		this.successCallbacks.push(opts.successCallback);
		var isVideo = opts.isVideo;
		var isAudio = opts.isAudio;
		var streamLengthAsked = opts.streamLengthAsked;
		var successCallback = (function(that){ return function(stream) {
			that.localStream = stream;
			logger.WebRTC("RTCallingComponentNway getLocalMedia ending with stream "+stream.id);
			for (var i in that.successCallbacks) {
				that.successCallbacks[i](stream);
				delete that.successCallbacks[i];
				delete that.failCallbacks[i];
				that.mutexGetLocalMedia = false;
			}
			that.callingview.showLocalStream(stream);
		}})(this);		
		var failCallback = (function(that){ return function(reason) {
			for (var i in that.failCallbacks) {
				that.failCallbacks[i](reason);
				delete that.failCallbacks[i];
				delete that.successCallbacks[i];
				that.mutexGetLocalMedia = false;
			}
		}})(this);
				
		if (this.localStream && this.localStream.active && this.localStream.getTracks().length >= streamLengthAsked) 
			return successCallback(this.localStream);
		else this.localStream = null;
		
		if ( ! this.mutexGetLocalMedia ) {
			this.mutexGetLocalMedia = true;
			logger.WebRTC("RTCallingComponentNway getLocalMedia starting");
		}
		else return logger.WebRTC("RTCallingComponentNway getLocalMedia waiting");
		
		if (navigator.mediaDevices) { // if navigator.mediaDevices exists, use it
            navigator.mediaDevices.getUserMedia({video: isVideo,
                audio: isAudio,
                googTypingNoiseDetection: false,
                googEchoCancellation: true,
                googAutoGainControl: false,
                googNoiseSuppression: false,
                googHighpassFilter: false
            }).then(successCallback, failCallback);
        } else navigator.getUserMedia({video: isVideo && {
                //width: { min: 1024, ideal: 1280, max: 1920 },
                //height: { min: 576, ideal: 720, max: 1080 },
                // "width": {
                    // "min": "300",
                    // "max": "640"
                // },
                // "height": {
                    // "min": "200",
                    // "max": "480"
                // },
                // "frameRate": {
                    // "max": "25"
                // }
            },
            audio: isAudio,
            googTypingNoiseDetection: false,
            googEchoCancellation: true,
            //googEchoCancellation2: true,
            googAutoGainControl: false,
            //googAutoGainControl2: false,
            googNoiseSuppression: false,
            //googNoiseSuppression2: false,
            googHighpassFilter: false
        }, successCallback, failCallback);
	},
	updateLocalVideo : function (stream) {
		/*if ( ! this.onCallComponentsView.children.RTCallingComponent_video_local) {
			this.callingComponents[0].callingview.showSelfVideo();
			this.callingComponents[0].callingview.localDivVideo.inject(this.onCallComponentsView);
		} else
			this.onCallComponentsView.children.RTCallingComponent_video_local.load();*/
		this.callingview.localDivVideo.src = stream || this.callingComponents[0].callingview.localDivVideo.src;
		this.callingview.localDivVideo.load();
        this.callingview.localDivVideo.muted = true;
		//this.callingview.showVideo();
        //this.callingview.showSelfVideo();
        this.callingview.hideVideoNull();
		this.callViewMethodOfAllComponents('pauseLocalVideo'); //perf
	},
	removeComponent : function (callingComponent,reason) {
		if (!callingComponent || this.callingComponents.indexOf(callingComponent) == -1) {
			logger.WebRTC("removeComponent bug, update container anyway");
		} else {
			logger.WebRTC("removeComponent "+callingComponent.room_id+callingComponent.user.login);
			this.callingComponents.splice(this.callingComponents.indexOf(callingComponent),1);
			this.updateComponentsClassName();
		}
		if (this.callingComponents.length == 0)
		{
			this.removeCCtimeout = setTimeout((function(that) {return function(){
				that.stopLocalTracks();
				that.remove();
			}})(this), reason ? 10000 : 1000); // if there is an error message then wait longer
			return false;
		}
		logger.WebRTC("there is still at least one another CC "+this.callingComponents.length);
		//this.updateLocalVideo();
		return true;
	},
	stopLocalTracks : function() {
		var stream = this.localStream;
		if (!stream) return true;
		var track, tracks = stream.getTracks();
		for (var i in tracks) {
			track = tracks[i];
			track.stop();
		}
	},
	/*hide : function () {
		this.callingview.remove();
		var onCallComponentsView = this.onCallComponentsView;
		setTimeout(function(){
			onCallComponentsView.hide();
		},3000);
	},*/
	show : function () {
		this.callingview.show();
		this.onCallComponentsView.show();
		this.onCallComponentsView.style.transform = "";
		if (this.removeCCtimeout) {
			clearTimeout(this.removeCCtimeout);
			this.removeCCtimeout = null;
		}
	},
	isNway : function (callingComponent) {
		return this.callingComponents.length > 1;
	}
});
return RTCallingComponentNway;
});

/**
 * @module InstantMessagingWebRTC
 *
 */
define('DS/InstantMessagingWebRTC/InstantMessagingWebRTC',[
'UWA/Class',
'UWA/Class/Events',
'UWA/Class/Options',
'DS/WAFData/WAFData',
'DS/UWPClientCode/PublicAPI',
'DS/RTProxyDriver/RTLogger',
'DS/RTProxyDriver/RTProxyDriver',
'i18n!DS/InstantMessagingWebRTC/assets/nls/feed',
'DS/PlatformAPI/PlatformAPI',
'DS/RTColors/RTColors',
'DS/InstantMessagingWebRTC/js/controller/RTCallingComponent',
'DS/InstantMessagingWebRTC/js/controller/RTCallingComponentNway'
],
function ( Class, Events, Options, WAFData, PublicAPI , logger, RTProxyDriver, NLS, PlatformAPI, colors, RTCallingComponent, RTCallingComponentNway) {
    'use strict';

    logger.addLevel('WebRTC','purple');
    logger.WebRTC('InstantMessagingWebRTC load 04/18/2019');

    var IMWebRTC = Class.extend(Events, Options, {

    init : function (options) {
		if (!options) return logger.WebRTC("InstantMessagingWebRTC needs params");
        this.setOptions(options);
        if (!options.url) return logger.WebRTC("InstantMessagingWebRTC needs url");
       // if (!options.login) return logger.WebRTC("InstantMessagingWebRTC needs login");
        this.url = options.url;
        this.baseurl = options.url.replace(":5281","").replace(":443","").replace(":3480","").replace("/rest","/");
        this.platformId = options.platformId;
        this.login = options.login;
        var me = PlatformAPI.getUser();
        if (me) this.username = me.firstName+' '+me.lastName;
        this.jid = this.login + '@' + this.platformId.toLowerCase() + '.im.3ds.com';
        this.nwayActivated = true;//options.nwayActivated;
        this.credential = options.credential;
        this.devEnv=options.devEnv;
        this.container = options.container; // null
        this.swymUrl = options.swymUrl;
        this.passportUrl = options.passportUrl;
        this.doLogRTC = options.doLogRTC;
        this.ringtoneURL = options.ringtoneURL;
        this.callingComponents = {};
        this.callingComponentsView = UWA.createElement('div', {'id':'RTCallingComponents'});
        this.callingComponentsView.inject(document.body);
        this.onCallComponents = new RTCallingComponentNway({nwayActivated:this.nwayActivated});
        //this.onCallComponentsView = this.onCallComponents.callingview;
        //this.onCallComponentsView = UWA.createElement('div', {'id':'RTOnCallComponents'});
        //this.onCallComponentsView.inject(document.body);
        if (options.doLogRTC) { // WE ARE IN PRINT
		        try { /*this.callingComponentsView.container.style.right="30px";*/ } // there is no RTC buble
				catch(e) {logger.WebRTC('failed to move cc in print');}
            //this.callingComponentsView.container.style.right="30px"; // there is no RTC buble
            var ringtoneURL = '../../resources/en/1/webapps/InstantMessagingWebRTC/assets/ringtone.wav';
        }
        else 
            var ringtoneURL = this.ringtoneURL || './resources/en/1/webapps/InstantMessagingWebRTC/assets/ringtone.wav';
        
        try {
            document.ringtone = new Audio(ringtoneURL); // here in order to preload and to share the audio between callingcomponents
        } catch(e) {
            logger.WebRTC("Unable to load ringtone "+e);
        }

        this.setStatus = function (presence) {
            RTProxyDriver.dispatch(RTProxyDriver.eventName.SETSTATUS,{myStatus:presence, statusMsg:presence});
        }
        
        this.logIntoRTC = function (that) {
            var passportUrl = that.passportUrl;
            var iam = passportUrl + '/login?service=3DSIM';                
            var driverOpts = {
                nameApp:'3DIM',
                driverName:'NODE',
                url: that.url,
                domaineName:that.platformId,
                username : that.username,
				passportUrl : passportUrl,
                credentials: { jid: that.jid, user: that.login, password: null }
            };
			// 17/12/2018 : service  ticket is now retrieved in driver 
			RTProxyDriver.dispatch(RTProxyDriver.eventName.SETDRIVER,[driverOpts]);
            /*var onComplete = function(ptData){
                    driverOpts.credentials.password = JSON.parse(ptData).access_token;
                    RTProxyDriver.dispatch(RTProxyDriver.eventName.SETDRIVER,[driverOpts]);
            };
            var requestOpt = {
                onComplete: onComplete,
                onFailure: function (resp) { logger.WebRTC(resp); },
                onTimeout: function(resp) { logger.WebRTC(resp); }};
            if (that.devEnv) return onComplete('{"access_token":"osef"}');
            WAFData.authenticatedRequest(iam, requestOpt) ;*/
        };
        if (this.doLogRTC) this.logIntoRTC(this);

        /* Add Listeners for RTPresenceAPI and RTWebRTCAPI */
        this.presenceListener = (function (that) {return function (contact) {
            if (!contact || ! contact.status || ! contact.status.toLowerCase || ! contact.userId) return logger.WebRTC("ONPRESENCERECEIVED bad params");
            var loginContact = contact.userId.split('@');
            var color = colors[contact.status.toLowerCase()];
            PlatformAPI.publish(contact.userId, { 'login' :  loginContact[0], 'action' : 'setStatus', 'status':contact.status, 'presence':contact.status, 'color':color } );
        }})(this);
        var platformId = this.platformId; // TODO closure
        this.platformListener = (function (that) {return function (data) {
            switch (data.action) {
                case 'getStatus':
                    var contact = {
                        userName: data.username,
                        login: data.login,
                        userId : data.login
                    };
                    RTProxyDriver.dispatch(RTProxyDriver.eventName.GETSTATUS,[contact]);
                break;
                case 'startCall':
                    RTProxyDriver.dispatch("startCall",[{
                        login:data.login,
                        logins:data.logins,
                        username:data.username,
                        type:data.type,
                        options:{orderId:data.orderId}}]);
                break;
                case 'whoami':
                     PlatformAPI.publish('im.ds.com', { 'action' : 'youare', 'login':that.login, 'userId':that.login,
                        'username':that.username//useless
                     } ); //TODO a tester en 420
                break;
            }
        }})(this);
        PlatformAPI.subscribe('im.ds.com', this.platformListener);
                
        /* Init Manager View */
        this.connectedListener = (function (that) { return function(data) {
            that.user_id = data.user_id;
			that.clientDevice = data.clientDevice;
        };})(this);

        this.disconnectedListener = (function (that) { return function() {
                for (var cc in that.callingComponents) {
                    if (that.callingComponents[cc] && that.callingComponents[cc].callingview && that.callingComponents[cc].callingview.container)
                        that.callingComponents[cc].callingview.container.hide();
                }
        };})(this)

        this.findCallingComponent = function(data) {
            if (!this.user_id) logger.WebRTC("findCallingComponent called but no user_id loaded !!");
            var key = (data.room_id || data.room.room_id)+(data.user_id || data.user.user_id);
             return {
                 key:key,
                 callingComponent : (this.callingComponents ? this.callingComponents[key] : null)
             }
        }
        this.findAllCCOfRoom = function (room_id) {
            if (!room_id) return logger.error("IMWebRTC findAllCCOfRoom called without room_id");
            var callingComponentsOfRoom={};
            for (var key in this.callingComponents) {
                if (key.indexOf(room_id) != -1)
                    callingComponentsOfRoom[key]=this.callingComponents[key];
            }
            return callingComponentsOfRoom;
        };
        /*this.isNway = function (room_id) {
            if (!room_id) return logger.error("IMWebRTC isNway called without room_id");
            var foundAtLeastOneRoom=false;
            for (var key in this.callingComponents)
                if (key.indexOf(room_id) != -1)
                {
                    if (foundAtLeastOneRoom) return true;
                    foundAtLeastOneRoom = true;
                }
            return false;
        };*/

        /* WebRTC Protocol */
        this.sendBrowserNotif = function (data) {
			PlatformAPI.publish("3dnotifinterne",{
				username : data.user.username,
				login : data.user.login,
				type : data.type,
				tenant : this.platformId,
				textNotif : "You are being "+data.type+" called by "+data.user.username,
				titleNotif : "Call incoming",
				action : "notifyBrowser"
			});
		};
        this.spawnCallingComponent = function (data) {
            var params = data;
			data.clientDevice = this.clientDevice;
            params.room_id = data.room.room_id;
            params.devEnv = this.devEnv;
            params.nwayActivated = this.nwayActivated;
            params.avatarUrl = (this.swymUrl) ? this.swymUrl + '/api/user/getpicture/login/' + data.user.login + '/format' : undefined; //TODO factoriser
            params.orderId = data.orderId || (data.options ? data.options.orderId : null);
            params.IamTheCaller = data.IamTheCaller;
            params.container = this.callingComponentsView;
            //params.username = data.user.username;
            var cc = this.findCallingComponent(data).callingComponent;
            if (cc) cc.callEnded();
            this.callingComponents[this.findCallingComponent(data).key] = new RTCallingComponent(params);
            cc = this.findCallingComponent(data).callingComponent;
				if (data.youHaveToAccept) {
					if (!this.checkIfIAlreadyAcceptedTheCall(data.room.room_id))
						return logger.error("Spawing a CallingComponent with auto accept, but I didn't accept the call !!!");
					logger.WebRTC("auto accept the call");
					cc.acceptCall(null,cc);
					cc.nway();//useless
				}
            if (data.error) 
                return cc.displayErrorAndEndCall(data.error, undefined, true, true);
			if (data.clientDevice && ! data.clientDevice.WebRTCCompatible)
				return cc.displayErrorAndEndCall("localMediaError_TypeError", undefined, false, false, 'noCompatibleBrowser');
           cc.sentPresenceListener = function (contact) { // if the interlocutor goes away before answering then end call
                if (!contact || ! contact.status || ! contact.status.toLowerCase || ! contact.userId) return logger.WebRTC("ONPRESENCERECEIVED bad params");
                var loginContact = contact.userId.split('@')[0];
                if (data.user.login != loginContact) return;
                if (contact.status == "Offline") {
                    //cc.callEnded();
                    logger.WebRTC(loginContact+" goes offline then endCall");
					cc.displayErrorAndEndCall("ICEdisconnected",undefined,true);
                }
                if (contact.username && contact.username != contact.login && contact.username != cc.user.username) // update username if needed
                    cc.updateUsername(contact.username);
            };
            RTProxyDriver.addEvent(RTProxyDriver.eventName.ONPRESENCERECEIVED, cc.sentPresenceListener);
        };
        this.spawnSentCallingComponent = (function (that) { return function (data) {
            data.IamTheCaller = true;
            data.IacceptedCallOnRoom = data.room_id || data.room.room_id;
			if (data.error && data.error == "noConnectedClient") return logger.WebRTC('The user '+data.user.login+' is offline.');
            that.spawnCallingComponent(data);
        } })(this);
        this.spawnReceivedCallingComponent = (function (that) { return function (data) {
            data.IamTheCaller = false;
            data.state = "incoming";
            that.spawnCallingComponent(data);
			that.sendBrowserNotif(data);
        } })(this);
        this.checkIfIAlreadyAcceptedTheCall = function (room_id) {
            var allCCofRoom = this.findAllCCOfRoom(room_id);
            for (var cc in allCCofRoom) {
                if (allCCofRoom[cc] && allCCofRoom[cc].isStarted)
                    return true;
            }
            return false;
        }
		this.endAllCalls = (function (that) { return function(reason) {
			var callingComponent;
			logger.WebRTC("endAllCalls ");
			for (var ccIndex in that.callingComponents) {
				callingComponent=that.callingComponents[ccIndex];
				callingComponent.endCall(false,reason);
			}
		};})(this);
        this.callEndedListener = (function (that) { return function(data) {
            var callingComponent, callingComponents = {};
            if (data.user_id) { // end call with the specified user only
				logger.WebRTC('end call with '+data.user_id+' on the room '+data.room_id);
                var cc = that.findCallingComponent({room_id : data.room_id, user_id:data.user_id});
                callingComponents[cc.key] = cc.callingComponent;
            } else {
				logger.WebRTC('end call with everybody on the room '+data.room_id);
				callingComponents = that.findAllCCOfRoom(data.room_id || data.room.room_id); // end call with all the room
			}
            
            for (var ccIndex in callingComponents) {
                callingComponent=that.callingComponents[ccIndex];
                if (callingComponent) {
                    callingComponent.callEnded(data);
					RTProxyDriver.removeEvent(RTProxyDriver.eventName.ONPRESENCERECEIVED, callingComponent.sentPresenceListener);
                    delete that.callingComponents[ccIndex];
                }
                else logger.WebRTC('callingComponent of the room '+(data.room_id || data.room.room_id)+' does not exist anymore !');

                var isThereAnotherCall = that.onCallComponents.removeComponent(callingComponent,data.reason);/* = false;
                for (var cc in that.callingComponents)
                    if (that.callingComponents[cc].isStarted) {
                        isThereAnotherCall = true;
                        break;
                    }*/
                if (!isThereAnotherCall) {
                    that.setStatus('Online');
					//window.removeEventListener('beforeunload', that.beforeUnload);
                     // same as RTCallingComponentView.endCall()
                }
            }
            if (!callingComponent) logger.WebRTC('A call has been ended on another device.');
        };})(this);
        this.webrtcIceCandidateReceivedListener = (function (that) { return function(data) {
            var callingComponent = that.findCallingComponent(data).callingComponent;
            if (!callingComponent) return logger.WebRTC("webrtcIceCandidateReceived on another device or for another user of the room");
            callingComponent.onWebRTCIceCandidate(data);
        };})(this);
		this.beforeUnload = (function (that) { return function() {
			that.setStatus('Online'); // TODO revenir au status précédent
			that.endAllCalls('ICEdisconnected');
		};})(this);
        this.callAcceptedListener = (function (that) { return function(data) {
            if (!data || ! data.webrtcConfig || ! data.webrtcConfig.iceServers) 
                return logger.error('callAccepted without webrtcConfig.iceServers');
            var ccInfos = that.findCallingComponent(data);
            var callingComponent = ccInfos.callingComponent;
            var callingComponentKey = ccInfos.key;
            for (var i = 0; i < data.webrtcConfig.iceServers.length; i++) {
                data.webrtcConfig.iceServers[i].urls = data.webrtcConfig.iceServers[i].url.replace("REPLACEMEWITHRTCDNS:3478",that.baseurl+'/coturn');
                data.webrtcConfig.iceServers[i].url = data.webrtcConfig.iceServers[i].url.replace("REPLACEMEWITHRTCDNS:3478",that.baseurl+'/coturn');
				//data.webrtcConfig.iceServers[i].urls = data.webrtcConfig.iceServers[i].url.replace("REPLACEMEWITHRTCDNS",that.baseurl).replace("https://","");
                //data.webrtcConfig.iceServers[i].url = data.webrtcConfig.iceServers[i].url.replace("REPLACEMEWITHRTCDNS",that.baseurl).replace("https://",""); // iceServer.url is deprecated
            }
            logger.WebRTC("callAccepted callingComponent id searched and "+(callingComponent?"":"not")+" found : "+that.findCallingComponent(data).key);
            if (callingComponent && !callingComponent.isStarted) { 
                callingComponent.callingview.show();
				that.onCallComponents.addComponent(callingComponent);
                if (!callingComponent.callAccepted(data)) {
                    that.callingComponents[callingComponentKey] = null;
					that.onCallComponents.removeComponent(callingComponent);
				}
				
				if ( ! that.nwayActivated)
					for (var cc in that.callingComponents) // if several calls have been received, then end them
						if (cc != callingComponentKey) {
							that.callingComponents[cc].displayErrorAndEndCall(null);
							that.callingComponents[cc].callEnded(); // direclty end the view (the previous command also result in ending the view but after i/o of server)
						}
                //callingComponent.callingview.inject(that.onCallComponentsView);// remove the view from the container and inject in direclty in the body to have so it can be free. Delayed to let other incoming calls end
                //if (that.onCallComponentsView.getElementsByClassName('RTCallingComponent').length > 1) // that.isNway(data.room_id)
            }
            else {
                if (data.nway) {
                    if (!that.checkIfIAlreadyAcceptedTheCall(data.room_id))
                        return logger.WebRTC('A call has been accepted by another user in the room, but I still don\'t have answered the call, then do nothing.');
                    var ccObject = that.findCallingComponent(data);
                    if (ccObject.callingComponent)
                        return logger.WebRTC('A call has been accepted by another user in the room and I already am in call with him, then do nothing.');
                    logger.WebRTC('A call has been accepted by another user in the room, we need to create a new CallingComponent with him');
                    RTProxyDriver.dispatch("startCall",[{login:data.user.login,type:data.type,alreadyStarted:true,room_id:data.room_id}]);
                }
                else {
                    return logger.WebRTC('A call has been received on another device.');
                }
            }
            if (options.doLogRTC) { // WE ARE IN PRINT
                try {/*callingComponent.callingview.container.style.right="30px";*/} // there is no RTC buble
				catch(e) {logger.WebRTC('failed to move cc in print');}
			}
			that.setStatus('Busy');
			//window.addEventListener('beforeunload', that.beforeUnload);
        };})(this);
        this.SDPreceivedListener = (function (that) { return function(data) {
            var callingComponent = that.findCallingComponent(data).callingComponent;
            if (!callingComponent) return logger.WebRTC("SDPreceived on another device or for another user of the room");
            callingComponent.onSDP(data);
        };})(this)        
		this.callEventListener = (function (that) { return function(data) {
            var callingComponent = that.findCallingComponent(data).callingComponent;
            if (!callingComponent) return logger.WebRTC("SDPreceived on another device or for another user of the room");
            callingComponent.onCallEvent(data);
        };})(this)
        RTProxyDriver.addEvent('CONNECTED', this.connectedListener);
        RTProxyDriver.addEvent('DISCONNECTED', this.disconnectedListener);
        RTProxyDriver.addEvent(RTProxyDriver.eventName.ONPRESENCERECEIVED, this.presenceListener);
        RTProxyDriver.addEvent('inviteSent',this.spawnSentCallingComponent);
        RTProxyDriver.addEvent('inviteToCall',this.spawnReceivedCallingComponent);
        RTProxyDriver.addEvent('callEnded',this.callEndedListener);
        RTProxyDriver.addEvent('callAccepted',this.callAcceptedListener);
        RTProxyDriver.addEvent('webrtcIceCandidateReceived',this.webrtcIceCandidateReceivedListener);
        RTProxyDriver.addEvent('SDPreceived',this.SDPreceivedListener);
        RTProxyDriver.addEvent('callEvent',this.callEventListener);
        
        return true;

       }

    });
return IMWebRTC;
});

