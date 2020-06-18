/**
 * @license Copyright (c) 2003-2013, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

/*
 *                       MM:DD:YY
 * @quickreview HAT1 ZUD 06:01:16 : IR-441351-3DEXPERIENCER2017x: The error message that appears on the HTML content view is not been translated into Japanes.                          
 */


CKEDITOR.editorConfig = function (config) {


//    config.extraPlugins = 'quicktable,rcowidget,toolbarswitch,base64image,colorbutton';
    config.resize_enabled = false;

    // To remove the bottom bar, we don't want to show the HTML tags
    config.removePlugins = 'image,forms,elementspath,autogrow';

    
    //Unnecessary scroll bar removal, width decreased to 99%.
    config.width = '99%';
    
	config.allowedContent = true;
	
	// Paste from Word
	config.pasteFromWordPromptCleanup = true;
    config.pasteFromWordRemoveFontStyles = false;
    config.pasteFromWordRemoveStyles = false;

    config.toolbar = 'Full';
    config.toolbar_Full = [{
        name: 'basicstyles',
        items: ['Bold', 'Italic', 'Strike', '-', 'Link',
            'Unlink'
        ]
    }, {
        name: 'styles',
        items: ['Styles', 'Format']
    }, {
        name: 'clipboard',
        items: ['PasteText',
            'PasteFromWord', '-', 'Undo', 'Redo'
        ]
    }, {
        name: 'paragraph',
        items: ['NumberedList', 'BulletedList']
    }, {
        name: 'colors',
        items: ['TextColor', 'BGColor']
    }, {
        name: 'insert',
        items: ['Table', '-', 'base64image']
    }, {
        name: 'widgets',
        items: ['RCOWidget']
    }];

    config.toolbar_Basic = [{
        name: 'basicstyles',
        items: ['Bold', 'Italic', 'Strike'
        ]
    }, {
        name: 'colors',
        items: ['TextColor', 'BGColor']
    }, {
        name: 'insert',
        items: ['Table', '-', 'base64image']
    }, {
		name : 'tools',
		items : [ 'Toolbarswitch' ]
	} ];
	
	config.toolbar_MaximizedCreation = [{
        name: 'basicstyles',
        items: ['Bold', 'Italic', 'Strike', '-', 'Link',
            'Unlink'
        ]
    }, {
        name: 'styles',
        items: ['Styles', 'Format']
    }, {
        name: 'clipboard',
        items: ['PasteText',
            'PasteFromWord', '-', 'Undo', 'Redo'
        ]
    }, {
        name: 'paragraph',
        items: ['NumberedList', 'BulletedList']
    }, {
        name: 'colors',
        items: ['TextColor', 'BGColor']
    }, {
        name: 'insert',
        items: ['Table', '-', 'base64image']
    }, {
		name : 'tools',
		items : [ 'Toolbarswitch' ]
	} ];
	
	config.toolbar_Maximized = [{
        name: 'basicstyles',
        items: ['Bold', 'Italic', 'Strike', '-', 'Link',
            'Unlink'
        ]
    }, {
        name: 'styles',
        items: ['Styles', 'Format']
    }, {
        name: 'clipboard',
        items: ['PasteText',
            'PasteFromWord', '-', 'Undo', 'Redo'
        ]
    }, {
        name: 'paragraph',
        items: ['NumberedList', 'BulletedList']
    }, {
        name: 'colors',
        items: ['TextColor', 'BGColor']
    }, {
        name: 'insert',
        items: ['Table', '-', 'base64image']
    }, {
        name: 'widgets',
        items: ['RCOWidget']
    }, {
		name : 'tools',
		items : [ 'Toolbarswitch' ]
	} ];
	
	config.toolbar_CATIA = [{
        name: 'basicstyles',
        items: ['Bold', 'Italic', 'Strike']
    }, {
        name: 'clipboard',
        items: ['PasteText',
            'PasteFromWord', '-', 'Undo', 'Redo'
        ]
    }, {
        name: 'paragraph',
        items: ['NumberedList', 'BulletedList']
    }, {
        name: 'colors',
        items: ['TextColor', 'BGColor']
    }, {
        name: 'insert',
        items: ['Table']
    }];
    
    // Make dialogs simpler.
    config.removeDialogTabs = 'image:advanced;link:advanced';
    
    //ZUD HAT1: IR-441351-3DEXPERIENCER2017x fix
    config.language = language;
	//VMA10 ZUD: IR-683812-3DEXPERIENCER2019x
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
			
			var dropDownElements = $(".cke_dialog_ui_input_select");
			if(dropDownElements[1].selectedIndex==0)
			{
				dropDownElements[1].selectedIndex=3;
			}
        	oldOnOK();
        	var selectedImg = editor.getSelection();
        	if(selectedImg) selectedImg = selectedImg.getSelectedElement();
        	if(!selectedImg || selectedImg.getName() !== "img") selectedImg = null;
        	if(selectedImg) {
        		selectedImg.setAttribute("data-cke-saved-src", selectedImg.getAttribute("src"));
        	}
        };
    }
	else if(dialogName == 'tableProperties')		//++VMA10 added for IR-689358-3DEXPERIENCER2019
    {
    	dialogDefinition.getContents("info").get("cmbAlign")['items'].shift();
    }//--VMA10
	else if(dialogName == 'link')//++VMA10 ZUD added IR-691060-3DEXPERIENCER2019x
    {
    	var arr = dialogDefinition.getContents("info").get("linkType")['items'];
    	if(arr.length>2)
    	{
    		if(arr[2][1]=="email")
    		{
    			arr.length = 2;	
    		}
    	}
    }//--VMA10 ZUD added IR-691060-3DEXPERIENCER2019x
});

