define('DS/ENOXCAD_Save/views/XCAD_NewFileNameView', [ 
	// -- Module Dependencies --
	'UWA/Core', 
	'DS/Core/Core', 
	'DS/ApplicationFrame/ContextualUIManager', 
	'DS/WebappsUtils/WebappsUtils', 
	'DS/Utilities/Dom', 
    'DS/Controls/LineEditor',
    'DS/Controls/Button',
	'DS/ENOXCAD_Save/controllers/XCAD_InteractionsWEB_CAD',
	'DS/Windows/Dialog',
	'DS/Windows/ImmersiveFrame'
], 
function(UWACore, WUXCore, ContextualUIManager, WebappsUtils, DomUtils, LineEditor, WUXButton, XCAD_InteractionsWEB_CAD,WUXDialog,WUXImmersiveFrame) {
	'use strict';
	
	var ENOUPSNewFileNameView= function(oldFileName, restrictedCharactersForFileName) {
		
		
		//create content 
		var myContent = new UWACore.Element('div', {styles: {height: '100%',width: '100%'}, html: '<p>New Filename:</p>' });
		//create line editor 
		var lineEditor = new LineEditor({
            value: oldFileName,
            touchMode: true,
            requireFlag: true,
            placeholder: 'Enter new file name here...',
            requiredFlag: true,
            autoCommitFlag: true,
            sizeInCharNumber:30
        });
        lineEditor.inject(myContent);
		// create new file name dialog 
		var dialog = new WUXDialog({
			   title: 'Rename Filename',
			   modalFlag : true,
			   content: myContent,
			   immersiveFrame: widget.XCAD_MainController.myImmersiveFrame,
			   buttons: {
			       Cancel: new WUXButton({
			           onClick: function (e) {
			               var button = e.dsModel;
			               var myDialog = button.dialog;
			               console.log('on Cancel button : dialog title = ' + myDialog.title);	
			               myDialog.close();
			           }
			       }),
			       Ok: new WUXButton({
			           onClick: function (e) {
			               var button = e.dsModel;
			               var myDialog = button.dialog;
			               console.log('on OK button : New file name = ' + lineEditor.value);
			               widget.XCAD_MainController.onNewFileNameOk(lineEditor.value);
			               myDialog.close();			               
			           }
			       })
			   }
			});
		        
        var paternContainRestrictedCharacters = '[]+';
        if (typeof restrictedCharactersForFileName != 'undefined')
        	paternContainRestrictedCharacters = '[' + restrictedCharactersForFileName + ']+';
        paternContainRestrictedCharacters = paternContainRestrictedCharacters.replace('\\', '\\\\');
        //var that=this;
        lineEditor.addEventListener('change', function(e) {
            var containRestrictedCharacters = RegExp(paternContainRestrictedCharacters).test(lineEditor.value);
            dialog.buttons.Ok.disabled = containRestrictedCharacters || lineEditor.value.length == 0 || lineEditor.value.length >= 206;
        });
     
	};
	return ENOUPSNewFileNameView;
});
