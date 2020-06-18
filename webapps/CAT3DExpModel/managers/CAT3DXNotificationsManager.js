/**
 * @exports DS/CAT3DExpModel/managers/CAT3DXNotificationsManager
 */
define('DS/CAT3DExpModel/managers/CAT3DXNotificationsManager',
[
	'UWA/Core',
	'UWA/Class/Events',
	'DS/WebApplicationBase/W3AAManager'
],
function (UWA, Events, W3AAManager) {
	'use strict';
	/**
	* @name DS/CAT3DExpModel/managers/CAT3DXNotificationsManager
    * @category Manager
    *
    * @description
    * Manage app notifications. 
    *
    * @constructor
	* @augments DS/WebApplicationBase/W3AAManager
	* @augments UWA/Class/Listener
    */

	var CAT3DXNotificationsManager = UWA.Class.extend(W3AAManager, Events,
	/** @lends DS/CAT3DExpModel/managers/CAT3DXNotificationsManager.prototype **/
	{

		initialize: function () {
		},

		GetType: function () {
		    return 'CAT3DXNotificationsManager';
		},

		_logNotif: function (iNotificationOptions) {
		    var title = iNotificationOptions.title && iNotificationOptions.title.toString ? iNotificationOptions.title.toString().toUpperCase() : null;
		    var subtitle = iNotificationOptions.subtitle && iNotificationOptions.subtitle.toString ? iNotificationOptions.subtitle.toString() : null;
		    var message = iNotificationOptions.message && iNotificationOptions.message.toString ? iNotificationOptions.message.toString() : null;

		    if (iNotificationOptions.level === 'info' || iNotificationOptions.level === 'success') {
		        if (title) { console.log(title); }
		        if (subtitle) { console.log(subtitle); }
		        if (message) { console.log(message); }
		    } else if (iNotificationOptions.level === 'warning') {
		        if (title) { console.warn(title); }
		        if (subtitle) { console.warn(subtitle); }
		        if (message) { console.warn(message); }
		    } else if (iNotificationOptions.level === 'error') {
		        if (title) { console.error(title); }
		        if (subtitle) { console.error(subtitle); }
		        if (message) { console.error(message); }
		    }
		},

		addNotification: function (iNotificationOptions) {
		    iNotificationOptions.level = iNotificationOptions.level ? iNotificationOptions.level : 'info';
		    this._logNotif(iNotificationOptions);
		},

		addPromisedNotification: function (iNotificationOptions) {
		    iNotificationOptions.level = iNotificationOptions.level ? iNotificationOptions.level : 'info';
		    this._logNotif(iNotificationOptions);

		    var deferred = UWA.Promise.deferred();

		    var self = this;
		    deferred.promise.then(function (iSuccessNotificationOptions) {
		        iSuccessNotificationOptions.level = iSuccessNotificationOptions.level ? iSuccessNotificationOptions.level : 'success';
		        self._logNotif(iSuccessNotificationOptions);
		    })['catch'](function (iFailNotificationOptions) {
		        iFailNotificationOptions.level = iFailNotificationOptions.level ? iFailNotificationOptions.level : 'error';
		        self._logNotif(iFailNotificationOptions);
		    });

		    return deferred;
		},

		removeNotification: function (iNotification) {
		    console.log('variable used' + iNotification);
		}
	});
	return CAT3DXNotificationsManager;
});


