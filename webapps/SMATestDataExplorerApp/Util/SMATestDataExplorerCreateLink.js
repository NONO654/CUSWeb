define('DS/SMATestDataExplorerApp/Util/SMATestDataExplorerCreateLink',
    ['UWA/Core',
     'UWA/Controls/Abstract',
     'DS/Controls/Button',
     'DS/Windows/Dialog',
     'DS/WebappsUtils/WebappsUtils',
     'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
     'DS/SMATestDataExplorerApp/SMATestDataExplorerQuery',
     'DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
     'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels',
     'css!DS/SMATestDataExplorerApp/SMATestDataExplorerApp'
    ],
    function ( UWA, Abstract, WUXButton, WUXDialog, WebappsUtils, TestDataSession, TestDataQuery, TestDataMessage, i18n) {
    'use strict';

    // Dialog for setting the title of links on creation
    var Dialog = UWA.Class.singleton( {
        init: function() {
            var immersiveFrame = TestDataSession.get( 'immersiveFrame' );
            
            var dialogContent = new UWA.Element( 'div', { 'class': 'tde-inline-container' } ); 
            var lbl = new UWA.Element( 'label', { 'class': 'tde-flex-fixed' } ).inject(dialogContent);
            lbl.textContent = i18n.title + ':';
            this._linkTitle = new UWA.Element( 'input', 
                    { 'class': 'tde-flex-grow', type: 'text', placeholder: i18n[ 'enter-link-title' ] } ).inject(dialogContent);

            var self = this;
            this._linkTitle.addEventListener('input', function() {
                self._validate();
            });

            this._linkDialog = new WUXDialog({
                title: i18n['create-link'],
                content: dialogContent,
                immersiveFrame: immersiveFrame,
                modalFlag: true,
                movableFlag: true,
                resizableFlag: true,
                closeButtonFlag: false,
                visibleFlag: true,
                titleBarVisibleFlag: true,
                position: { at: 'top left', my: 'top left', offsetX: 100, offsetY: 60 },
                buttons: {
                    Cancel: new WUXButton({
                        onClick: function (e) {
                            e.dsModel.dialog.hide();
                        }
                    }),
                    Ok: new WUXButton({
                        onClick: function (e) {
                            if( self._link && self._linkTitle && self._linkTitle.value ) {
                                self._link.title = self._linkTitle.value;

                                // make web service call to create the link
                                var app = TestDataSession.get('app');
                                if( app ) {
                                    var uri = app.baseUrl() + '/Link';
                                    var request = { href: uri, payload: self._link };
                                    var options = { spinner: TestDataSession.get( 'spinner' ), method: 'POST', request: request } ;
                                    
                                    TestDataQuery.getWAFData( options )
                                    .then( function( response ) {
                                        TestDataMessage.displayMessage( 'info', i18n['link-created'] + response.title, i18n.note, i18n.info );
                                    })
                                    .catch( function( err, errobj, errctx ) {
                                        e.dsModel.dialog.hide();
                                        var errorMessage = (err && err.message) || i18n[ 'link-create-fail' ];
                                        TestDataMessage.displayMessage( 'error', errorMessage);
                                    });
                                }
                            }
                            e.dsModel.dialog.hide();
                        }
                    })
                }
            });
            
            this._linkDialog.addEventListener('close', function (e) {
        	   e.dsModel.dialog.hide();
        	});
            
            this._linkDialog.hide();
        },

        _validate: function() {
            // TODO verify title entered is a valid name - check with Ganesh
            // for now just checking if it is not empty
            if( this._linkTitle.value ) {
                this._linkDialog.buttons.Ok.disabled = false;
            } else {
                this._linkDialog.buttons.Ok.disabled = true;
            }
        },

        showDialog: function ( link ) {
            this._link = link;
            this._linkTitle.value = link.title;
            this._linkDialog.show();
            this._linkDialog.bringToFront();
        },
        
        
    });
    return Dialog;
}
);

