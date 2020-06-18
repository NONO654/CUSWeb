define('DS/ENOXCAD_Save/views/XCAD_DuplicateView', [ 
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
	
	var ENOUPSDuplicateView= function(oldFileName, restrictedCharactersForFileName) {
		
		
		//create content 
		var myContent = new UWACore.Element('div', {styles: {height: '100%',width: '100%'}, html: '<p>Enter an optional prefix to prepend while duplicating:</p>' });
		
		//create line editor 
		var lineEditor = new LineEditor({
            value: oldFileName,
            touchMode: true,
            requireFlag: true,
            placeholder: 'Enter prefix here...',
            requiredFlag: true,
            autoCommitFlag: true,
            sizeInCharNumber:40
        });
        lineEditor.inject(myContent);
		// create new file name dialog 
		var dialog = new WUXDialog({
			   title: 'Save as Duplicate',
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
			               console.log('on OK button : Duplicate prefix= ' + lineEditor.value);
			               widget.XCAD_MainController.onDuplicateOk(lineEditor.value);
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
            dialog.buttons.Ok.disabled = containRestrictedCharacters || lineEditor.value.length >= 206;
        });
     
	};
	return ENOUPSDuplicateView;
});
