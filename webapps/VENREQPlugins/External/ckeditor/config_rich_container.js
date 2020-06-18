CKEDITOR.editorConfig = function(config) {
	

    config.toolbar_Container = [
        ['SelectAll','-','Cut','Copy','PasteText','-','Undo','Redo']
    ];
    
    config.extraAllowedContent = '*{*}';
    
    config.enterMode = '';
    
    config.autoParagraph = false;
    config.removePlugins = 'pastefromword'; 
    config.forcePasteAsPlainText = true;
};
