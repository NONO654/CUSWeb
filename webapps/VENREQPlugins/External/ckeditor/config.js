CKEDITOR.editorConfig = function (config) {

    config.toolbar_Basic = [
        ['Bold', 'Italic', '-', 'Styles']
    ];

    /*config.toolbar_Rich = [
        ['Bold', 'Italic', 'Underline', '-', 'TextColor', 'BGColor', '-', 'PasteFromWord', '-', 'Table', '-', 'Image', '-', 'RCO']
    ];*/

    // to move the floating toolbar above the rich content title
    config.floatSpaceDockedOffsetY = 25;

    // To remove the bottom bar, we don't want to show the HTML tags
    //config.removePlugins = 'elementspath';
    config.removePlugins = 'image,forms,elementspath';

    config.allowedContent = true;

    // Paste from Word
    config.pasteFromWordPromptCleanup = true;
    config.pasteFromWordRemoveFontStyles = false;
    config.pasteFromWordRemoveStyles = false;

    config.extraAllowedContent = '*{*}';

    // Make dialogs simpler.
    config.removeDialogTabs = 'image:advanced;link:advanced';

    config.toolbar_Rich = [{
        name: 'basicstyles',
        items: ['Bold', 'Italic', 'Strike', '-', 'Link', 'Unlink']
    }, {
        name: 'styles',
        items: ['Styles', 'Format']
    }, {
        name: 'colors',
        items: ['TextColor', 'BGColor']
    },
    {
        name: 'clipboard',
        items: ['SelectAll', '-', 'Cut', 'Copy', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo'/*,'Find','Replace'*/]
    },
    {
        name: 'paragraph',
        items: ['NumberedList', 'BulletedList']
    },
    {
        name: 'insert',
        items: ['Table', '-', 'base64image', '-', 'rcowidgetCmd']
    }];

    config.toolbar_Container = [
        ['Cut', 'Copy', 'Paste', '-', 'Undo', 'Redo']
    ];
	//VMA10 ZUD: IR-694967
   config.linkShowTargetTab = false

};

//IR-497282-3DEXPERIENCER2018x
CKEDITOR.on('dialogDefinition', function (ev) {
    var dialogName = ev.data.name;
    var dialogDefinition = ev.data.definition;
    var dialog = dialogDefinition.dialog;
    var editor = ev.editor;

    console.log("dialog name = " + dialogName);
    if (dialogName == 'base64imageDialog') {
    	var oldOnOK = dialogDefinition.onOk;
        dialogDefinition.onOk = function (e) {
        	oldOnOK();
        	var selectedImg = editor.getSelection();
        	if(selectedImg) selectedImg = selectedImg.getSelectedElement();
        	if(!selectedImg || selectedImg.getName() !== "img") selectedImg = null;
        	if(selectedImg) {
        		selectedImg.setAttribute("data-cke-saved-src", selectedImg.getAttribute("src"));
        	}
        };
    }else if(dialogName == 'link') //VMA10 ZUD : IR-694967-3DEXPERIENCER2020x
    {
			var target = dialogDefinition.getContents('target').get('linkTargetType');
			target['default'] = '_blank';
	}
});

