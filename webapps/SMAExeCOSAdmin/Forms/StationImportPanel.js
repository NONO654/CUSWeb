define('DS/SMAExeCOSAdmin/Forms/StationImportPanel',
   ['UWA/Core',
    'UWA/Controls/Abstract',
    'DS/UIKIT/Input/File',
    'DS/Controls/ProgressBar',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminWebServiceUtils',
    'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
   ],
   function (UWA,  Abstract,
       UploadFile,  WUXProgressBar,  COSUtils,  WSUtils, COSInfo, NLS) {

       'use strict';

       var ImportPanel = Abstract.extend({


    	   // creates a div containing a UIKit file chooser
    	   // with a browse button

    	   // assumes that options will contain an importOK function
    	   // to process the file string that is read in

    	   init: function (options) {
               this._parent(options);
               this._buildPanel();
           },

           _buildPanel: function () {

               var me = this;

               // create div with UIKit file chooser element
               me.elements.container = UWA.createElement('div',  {
                   id: 'importPanel',
                   styles: {
                       padding: '5px',
                       width: '100%',
                       'max-width': '400px',
                       'min-width': '260px',
                       'min-height': '80px'
                   }
               });

               me.elements.fileElement = new UploadFile({
                   multiple: false,
                   buttonBefore: false,
                   name: 'file-input',
                   placeholder: 'JSON File...',
                   events: {
                       onChange: function (evt) {

                    	   // get selected file
                           var file = evt.target.files[0];
                           me.setStatus('');

                           // make sure json file was chosen
                           if (!file.name.toLowerCase().endsWith('.json')) {
                               me.setStatus(NLS.get('jsonChoose'));
                               return;
                           }
                           // call read file with following functions
                           //onStart,  onProgress,  onComplete,  onError
                           COSUtils.readFile(file,
                               function () {
                                   me.elements.progressElement.value = 0;
                               },
                               function (val) {
                                   me.elements.progressElement.value = val;
                               },

                               // on complete get the file content and
                               // call import processing function passed in
                               function (content) {
                                   me.elements.progressElement.value = 100;
                                   me.fileContent = content;
                                   try {
                                       if (me.options && me.options.importOK &&
                                    		   UWA.typeOf(me.options.importOK) === 'function') {
                                    	   me.options.importOK(content);
                                    	   me.close();
                                       }
                                   }

                                   // display alert for any errors during import processing
                                   catch (err) {
                                	   COSUtils.displayError(err.message, true);
                                   }
                               },

                               function (msg) {
                            	   COSUtils.displayError(msg, true);
                               });
                       }
                   }
               }).inject(me.elements.container);

               me.elements.progressElement = new WUXProgressBar({
                   displayStyle: 'lite'
               }).inject(me.elements.container);

               me.elements.statusElement = UWA.createElement('div',  {
                   styles: {
                       height: '2 rem'
                   }
               }).inject(me.elements.container);

           },


           ok: function () {
               UWA.log('upload file');
               var me = this;
               me.close();
           },

           close: function () {
               var me = this;
               me.dispatchEvent('onClose');
           },


           setStatus: function (message) {
               this.elements.statusElement.setText(message);
           },

           getStatus: function () {
        	   return this.elements.statusElement.getText();
           },

           destroy: function () {
               this.elements.progressElement.destroy();
               this.elements.fileElement.destroy();
               this._parent();
           }
       });

       return ImportPanel;
   }
);
