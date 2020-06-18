define('DS/SMAExeCOSAdmin/Forms/EventTraceDialog',
    ['UWA/Core',
	 'DS/UIKIT/Form',
     'DS/UIKIT/Modal',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminInfo',
     'DS/SMAExeCOSAdmin/SMAExeCOSAdminUtils',
	 'i18n!DS/SMAExeCOSAdmin/assets/nls/SMAExeCOSAdmin'
    ],

    /*
     * function to display event log trace
     */
    function ( UWA,  UIForm, UIModal, COSInfo, COSUtils, NLS) {

         'use strict';
         var modal = null;


         // handles displaying event log trace
         var EventTraceDialog = {

                 // remove field identifiers from the exception object passed in
        		 // and set the display string in the form's text box
         		updateFields : function (trace) {
                    // define the form fields
        	         var myForm = {};
        	         var displayString = trace.replace(/"class":/g, '');
        	         displayString = displayString.replace(/, "method"/g, '');
        	         displayString = displayString.replace(/, "line"/g, '');
        	         myForm = new UIForm({
        	        	 className: 'vertical',
        	        	 fields: [{
        	        		 type: 'text',
        	        		 label: ' ',
        	        		 name: 'trace',
        	        		 multiline : true,
        	        		 rows: 20,
        	        		 value : displayString,
                             className: 'verticalResizeTextArea'
	         	        	 }]
	         	         });
                    return myForm;

        		},
        		// function to create the modal dialog from the form and show it
        		showDialog : function (myForm) {
                    modal = new UIModal({
                        closable : true,
                        header : NLS.get('trace'),
                        body: myForm
                    });

                    modal.inject(COSInfo.getContainer());
                    modal.show();
         		}
        };
        return EventTraceDialog;
});


