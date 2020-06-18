/**
* @module RTPresenceAPI/RTPresenceAPI
*
*/

define('DS/RTPresenceAPI/RTPresenceAPI',
['UWA/Class',
'UWA/Class/Events',
'DS/PlatformAPI/PlatformAPI',
'DS/UIKIT/Input/Button',
'DS/UIKIT/Tooltip',
'i18n!DS/RTPresenceAPI/assets/nls/feed'],
function (Class, Events, PlatformAPI, Button, Tooltip, NLS) {
'use strict';
UWA.log('3DIM - RTPresenceAPI load');
var color = { offline:"#d1d4d4" };
var RTPresenceAPI = Class.extend(Events,{
	init: function (options) {
		if (!options) return UWA.log('3DIM - RTPresenceAPI Error : options missed.');
		this.login = options.login || options.userId;
		if (!this.login) return UWA.log('3DIM - RTPresenceAPI Error : login missed.');
		this.username = options.username || this.login;
		this.tenant = options.tenant;
		if (!this.tenant) return UWA.log('3DIM - RTPresenceAPI Error : tenant missed.');
		this.userId = options.userId ?  options.userId : this.login+'@'+this.tenant+".im.3ds.com";
		this.presence = 'Offline';
		var displayPresenceOnly = options.button === undefined ? false : !options.button;
		this.displayFonticon = options.fonticon;
		this.nodisplay = options.nodisplay;
		var clickable = options.clickable === undefined ? true : options.clickable;
		var that = this;

		if (options.callbacks) this.callbacks = options.callbacks;

		if (!this.nodisplay) {
			if (options.content) this.globalView = UWA.createElement('div', {styles:{'display':'inline-block'}}).inject(options.content);
			else UWA.log("3DIM - RTPresenceAPI init : no content to inject to.");

			if (clickable) this.globalView.addEvent('click', function () { that.startchat(); });
			this.statusIcon = UWA.createElement('span', {
				styles: {
					'border-radius': '10px',
					'border' : '2px solid white',
					'background': this.displayFonticon ? 'inherit' : color.offline,
					'color' : this.displayFonticon ? color.offline : 'white',
					'width': '20px',
					'height': '20px',
					'font-size':'9px',
					'font-weight':'bold',
					'line-height': '16px'
			}});
			this.statusIcon.addClassName("fonticon fonticon-minus");
			if (this.displayFonticon) this.statusIcon.addClassName("fonticon-chat");

			if (displayPresenceOnly) {
				this.statusIcon.inject(this.globalView);
				if(clickable) this.statusIcon.addEvent('mouseover', function () { this.style.cursor='pointer'; });
				if (this.displayFonticon) this.statusIcon.addClassName("fonticon-2x");
			} else {
				if (this.displayFonticon) this.statusIcon.style.fontSize = '1.5em';
				this.btView = new Button({ value: NLS.Contact || 'Contact' }).inject(this.globalView);
				this.btView.elements.container.style.lineHeight=this.btView.elements.container.clientHeight/2+'px';
				this.btView.elements.content.addClassName("btn-with-icon");
				this.btView.elements.content.insertBefore(this.statusIcon, this.btView.elements.content.firstChild);
			}
		}
		else if (options.statusIcon) this.statusIcon = options.statusIcon;

		if(clickable && false) // TODO bug when integrated in 3dd, maybe due to other pseudo-elements
		new Tooltip({
			target: displayPresenceOnly ? this.statusIcon : this.btView.getContent(),
			body: (NLS.Contact || 'Contact')+' '+this.username,
			position: 'right',
		});

		//this.globalView.children.item(0).style.display="none";

		PlatformAPI.subscribe(this.login, function(data){
			switch(data.action){
				case 'hide':
					that.globalView.style.display = 'none';
				break;
				case 'setStatus':
					if (data.login === that.login ) that.setStatus(data.status, data.color);
				break;
				case 'logout':
					that.setStatus('Offline', color.offline);
				break;
				case 'login':
					that.getStatus();
				break;
			}
		});

		this.getStatus();
		//this.getState();
	},

	setStatus : function(status, color) {
		this.presence = status;
		this.presenceColor = color;
		if (this.callbacks && this.callbacks.onPresenceChanged) {
			var callback = this.callbacks.onPresenceChanged
			callback(status, color);
		}
		if (this.nodisplay) return true;
		if (this.statusIcon) {
			this.globalView.children.item(0).style.display= 'inline-block';
			if(!color) return UWA.log("3DIM - RTPresenceAPI setStatus : presence color unknown");
			if ( this.displayFonticon) this.statusIcon.style.color = color;
			else {
				this.statusIcon.style.background = color;
				var class_base = this.clickable ? 'fonticon handler' : 'fonticon';
				switch (status) {
					case 'Online'	:	this.statusIcon.className  = class_base+' fonticon-check'; break;
					case 'Busy' 	: 	this.statusIcon.className  = class_base+' fonticon-minus'; break;
					case 'Away' 	: 	this.statusIcon.className  = class_base+' fonticon-cancel'; break;
					case 'Offline' 	: 	this.statusIcon.className  = class_base+' fonticon-record'; break;
				}
			}
		} else  UWA.log("3DIM - RTPresenceAPI setStatus : no statusIcon to update");
	},

	getStatus: function (){
		var data = { 'login' :  this.login, 'tenant':this.tenant, 'action' : 'getStatus' } ;
		PlatformAPI.publish('im.ds.com', data );
	},

	getState: function (){
		var data = { 'login' :  this.login, 'tenant':this.tenant, 'action' : 'getState' } ;
		PlatformAPI.publish('im.ds.com', data );
	},

	startchat: function (){
		UWA.log('3DIM - RTPresenceAPI startchat with '+this.login);
		var data = { 'login' :  this.login, 'tenant':this.tenant, 'username':this.username, 'presence': this.presence, 'action' : 'startChat' } ;
		PlatformAPI.publish('im.ds.com', data );
	},

	destroy : function(evt){
		if (this.login)
			PlatformAPI.unsubscribe(this.login);
		this._parent();
	}
});
return RTPresenceAPI;
});
