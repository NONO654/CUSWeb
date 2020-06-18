/**
 * @license Copyright (c) 2003-2013, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */
 
 
CKEDITOR.plugins.addExternal('fmath_formula', 'plugins/fmath_formula/', 'plugin.js');

CKEDITOR.editorConfig = function( config ) {
	
	config.extraPlugins = 'fmath_formula,onchange,dragresize';
	config.skin = 'kama';
	
	config.resize_enabled = false;
	
	// To remove the bottom bar, we don't want to show the HTML tags
	config.removePlugins = 'elementspath'; 
	
	config.width = '100%'; 

	config.toolbar = 'Full';
	config.toolbar_Full =
	[ {
		name : 'basicstyles',
		items : [ 'Bold', 'Italic', 'Strike', '-', 'Link',
				'Unlink' ]
	},
	{
		name: 'styles', 
		items: [ 'Styles', 'Format' ]  
	},
	{
		name : 'clipboard',
		items : [ 'PasteText',
				'PasteFromWord', '-', 'Undo', 'Redo' ]
	}, {
		name : 'paragraph',
		items : [ 'NumberedList', 'BulletedList' ]
	}, {
		name : 'colors',
		items : [ 'TextColor', 'BGColor' ]
	}, {
		name : 'insert',
		items : [ 'Table', '-', 'Image', 'fmath_formula']
	} ];
	 
	config.toolbar_Basic =
	[ {
		name : 'basicstyles',
		items : [ 'Bold', 'Italic', 'Strike', '-', 'Link', 'Unlink' ]
    }, {
		name : 'colors',
		items : [ 'TextColor', 'BGColor' ]
	}, {
		name : 'clipboard', 
		items : [ 'PasteText', 'PasteFromWord' ]
	}, {
		name : 'tools',
		items : [ 'Maximize' ]
	} ];
};
