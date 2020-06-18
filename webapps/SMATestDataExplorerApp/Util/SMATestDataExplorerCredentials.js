define('DS/SMATestDataExplorerApp/Util/SMATestDataExplorerCredentials',
        ['UWA/Core',
         'UWA/Controls/Abstract',
         'DS/Controls/Button',
         'DS/Windows/Dialog',
         'DS/WebappsUtils/WebappsUtils',
         'DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
         'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
         'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels',
         'css!DS/SMATestDataExplorerApp/SMATestDataExplorerApp'
        ],
    function ( UWA, Abstract, WUXButton, WUXDialog, WebappsUtils, TestDataMessage, TestDataSession, i18n) {
    'use strict';

    // Dialog for obtaining the server and login credentials for an ASAM database
    var Credentials = UWA.Class.singleton({
        init: function() {
            this._app = TestDataSession.get( 'app' );
            var immersiveFrame = TestDataSession.get( 'immersiveFrame' );

            var dialogContent = new UWA.Element('div', { 'class': 'tde-dialog-content' });  
            this._form = new UWA.Controls.Form({
                fields: [
                    { type: 'text',     name: 'asamHost',     label: i18n['asam-host'],    value: widget.getValue( 'asamHost' ),     autocomplete: 'asam-host' },
                    { type: 'text',     name: 'asamPort',     label: i18n['asam-port'],    value: widget.getValue( 'asamPort' ),     autocomplete: 'asam-port' },
                    { type: 'text',     name: 'asamService',  label: i18n['asam-service'], value: widget.getValue( 'asamService' ),  autocomplete:'asam-service' },
                    { type: 'text',     name: 'asamUsername', label: i18n.username,        value: widget.getValue( 'asamUsername' ), autocomplete: 'username' },
                    { type: 'password', name: 'asamPassword', label: i18n.password,        value: widget.getValue( 'asamPassword' ), autocomplete: 'current-password'  }
                ]
            }).inject(dialogContent);

            var self = this;
            
            this._form.getFields().forEach( function( field ) {
                field.addClassName( 'tde-asam-credential' );
                field.addEventListener('input', function() {
                    self._validate();
                });
                if( field.name === 'asamPort' ) {
                    field.addEventListener('change', function() {
                        self._validatePort();
                    });
                }
            });

            this._credentialDialog = new WUXDialog({
                title: i18n['asam-server-details'],
                content: dialogContent,
                immersiveFrame: immersiveFrame,
                modalFlag: true,
                movableFlag: true,
                resizableFlag: true,
                visibleFlag: true,
                closeButtonFlag: false,
                titleBarVisibleFlag: true,
                position: { at: 'center', my: 'top left', offsetX: 100, offsetY: 60 },
                buttons: {
                    Cancel: new WUXButton({
                        onClick: function (e) {
                            e.dsModel.dialog.hide();
                        }
                    }),
                    Ok: new WUXButton({
                        onClick: function (e) {
                            var prefs = self._form.getFormValues();
                            self._app.setPreferences( prefs );
                            self._app.onCredentialsChange();
                            e.dsModel.dialog.hide();
                        }
                    })
                }

            });
            this._credentialDialog.hide();
        },

        _validate: function() {
            var prefs = this._form.getFormValues();

            // check that all fields are populated
            var allFieldsFilled = false;
            if( prefs.asamHost && prefs.asamPort && prefs.asamService && prefs.asamUsername && prefs.asamPassword ) {
                allFieldsFilled = prefs.asamHost.length > 0 && 
                prefs.asamPort.length > 0 && 
                prefs.asamService.length > 0 && 
                prefs.asamUsername.length > 0 && 
                prefs.asamPassword.length > 0;
            }

            // mask OK button if any field is empty
            if( allFieldsFilled && this._isPortNumeric() ) {
                this._credentialDialog.buttons.Ok.disabled = false;
            } else {
                this._credentialDialog.buttons.Ok.disabled = true;
            }
        },

        _validatePort: function() {
            // check that the port value is numeric
            if( !this._isPortNumeric() ) {
                TestDataMessage.displayMessage( 'error', i18n['bad-port'], i18n['bad-val'] );
            }
        },

        _isPortNumeric: function() {
            var prefs = this._form.getFormValues();
            var portIsNumeric = false;
            if( prefs.asamPort.length > 0 ) {
                var portnum = parseInt( prefs.asamPort );
                portIsNumeric = !isNaN( portnum ) && portnum.toString().length === prefs.asamPort.length;
            }
            return portIsNumeric;
        },

        _changed: function( prefs ) {
            return  prefs.asamHost     !== widget.getValue( 'asamHost' ) || 
            prefs.asamPort     !== widget.getValue( 'asamPort' ) ||
            prefs.asamService  !== widget.getValue( 'asamService' ) ||
            prefs.asamUsername !== widget.getValue( 'asamUsername' ) ||
            prefs.asamPassword !== widget.getValue( 'asamPassword' );
        },

        getServerCredentials: function() {
            var prefs = [];
            prefs.push( { name: 'host',        widgetName: 'asamHost',     value: widget.getValue( 'asamHost' ) } );
            prefs.push( { name: 'port',        widgetName: 'asamPort',     value: widget.getValue( 'asamPort' ) } );
            prefs.push( { name: 'servicename', widgetName: 'asamService',  value: widget.getValue( 'asamService' ) } );
            prefs.push( { name: 'username',    widgetName: 'asamUsername', value: widget.getValue( 'asamUsername' ) } );
            prefs.push( { name: 'password',    widgetName: 'asamPassword', value: widget.getValue( 'asamPassword' ) } );

            var count = 0;
            prefs.forEach( function ( pref ) {
                pref.value.length > 0 && ++count;
            });
            return { credentials: prefs, valid: count === prefs.length };
        },

        showDialog: function ( options ) {
            var form = this._form;

            var credentials = [];
            if( options && options.host && options.port && options.service) {
                credentials.push( { name: 'host',        widgetName: 'asamHost',     value: options.host } );
                credentials.push( { name: 'port',        widgetName: 'asamPort',     value: options.port } );
                credentials.push( { name: 'servicename', widgetName: 'asamService',  value: options.service } );
                credentials.push( { name: 'username',    widgetName: 'asamUsername', value: '' } );
                credentials.push( { name: 'password',    widgetName: 'asamPassword', value: '' } );

            } else {
                credentials = this.getServerCredentials().credentials;
            }

            credentials.forEach( function( item ) {
                var field = form.getField( item.widgetName );
                field.value = item.value;
                field.disabled = false;
                if( options && 
                    ( item.widgetName === 'asamHost' || 
                      item.widgetName === 'asamPort' ||
                      item.widgetName === 'asamService' ) ) {
                    field.disabled = true;
                }
            });

            this._validate();
            this._credentialDialog.show();
            this._credentialDialog.bringToFront();
        }
    });
    return Credentials;
}
);

