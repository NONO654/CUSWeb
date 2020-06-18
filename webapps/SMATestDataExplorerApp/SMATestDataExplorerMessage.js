define('DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
        [ 'WebappsUtils/WebappsUtils',
          'DS/Notifications/NotificationsManagerUXMessages',
          'DS/Notifications/NotificationsManagerViewOnScreen',
          'DS/Notifications/NotificationsManagerViewOnTreeListView'],
    function( WebappsUtils, WUXNotificationMessages, WUXNotificationViewOnScreen, WUXNotificationViewOnTreeView ) {
	'use strict';

    var SMATestDataExplorerMessage = {
		composerMessages: null,
		notificationPref: "warning",
		notificationClassNames: ["info", "success", "warning", "error"],
		notificationPrefIndex: -1,

		init: function( ){
		    window.notifs = WUXNotificationMessages;
		    WUXNotificationViewOnScreen.setNotificationManager( window.notifs );
//		    WUXNotificationViewOnTreeView.setNotificationManager( window.notifs );
		},

        displayMessage: function( messageType, message, title, subtitle ) {
        	if( this.notificationClassNames.indexOf(messageType) != -1 ) {
        	    var errmsg = message && message.message ? message.message : message;
        		var notificationOptions = {
                        level: messageType,
                        title: title,
                        subtitle: subtitle,
                        message: errmsg, 
                        sticky: false,
                    };
            	window.notifs.addNotif(notificationOptions);
        	}
        }
	};
    return SMATestDataExplorerMessage;
});
