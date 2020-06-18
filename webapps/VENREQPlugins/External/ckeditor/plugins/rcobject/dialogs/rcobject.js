CKEDITOR.dialog.add('rcoDialog', function(editor) {

    // Links to Office FIXME
    var links = {
        'Word': function(objectId) {
        	return 'ms-word:ofe|u|http://d1014eno.dsone.3ds.com:8090/enovia/resources/rmt/create/' + objectId + '/Word.docx';
        },
        'Excel': function(objectId) {
        	return 'ms-word:ofe|u|http://d1014eno.dsone.3ds.com:8090/enovia/resources/rmt/create/' + objectId + '/Word.docx';
        },
        'PowerPoint': function(objectId) {
        	return 'ms-word:ofe|u|http://d1014eno.dsone.3ds.com:8090/enovia/resources/rmt/create/' + objectId + '/Word.docx';
        }
    }

    // RegExp: 123, 123px, empty string ""
    var regexGetSizeOrEmpty = /(^\s*(\d+)(px)?\s*$)|^$/i,

        lockButtonId = CKEDITOR.tools.getNextId(),
        resetButtonId = CKEDITOR.tools.getNextId(),

        lang = editor.lang.rcobject,
        commonLang = editor.lang.common,

        helpers = CKEDITOR.plugins.rcobject,

        // Functions inherited from rcobject plugin.
        checkHasNaturalRatio = helpers.checkHasNaturalRatio,
        getNatural = helpers.getNatural,

        // Global variables referring to the dialog's context.
        doc = null,
        widget = null;



    // Create a "global" reference to edited widget.
    for (var entry in editor.widgets.instances);
    widget = editor.widgets.instances[entry];

    return {
        title: lang.dialogTitle,
        minWidth: 200,
        minHeight: 100,
        onLoad: function() {
            // Create a "global" reference to the document for this dialog instance.
            doc = this._.element.getDocument();

        },
        onShow: function() {
            // Create a "global" reference to edited widget.
            for (var entry in this._.editor.widgets.instances);
            widget = this._.editor.widgets.instances[entry];

            // Setup the content for ALL UI elements
            this.setupContent(widget);
        },
        onOk: function() {
            this.commitContent(widget);
        },
        contents: [{
            id: 'tab-edit',
            label: lang.dialogTabEdit,
            elements: [{
            	type: 'html',
                html: 'Select the Microsoft Office Application to open in order to create your rich content:'
            }, {
                type: 'hbox',
                widths: ['33%; text-align:center;', '33%; text-align:center;', '33%; text-align:center;'],
                children: [{
                    type: 'html',
                    style: 'text-align:center;',
                    id: 'editInWord',
                    html: '<a title="Word" href="' + links['Word'](editor.config.data['objectId']) + '">' + 
                    '<span class="icon-word"></span></a>'
                }, {
                	 type: 'html',
                     id: 'editInExcel',
                     html: '<a title="Excel" href="' + links['Excel'](editor.config.data['objectId']) + '">' + 
                     '<span class="icon-excel"></span></a>'
                }, {
                	 type: 'html',
                     id: 'editInPowerPoint',
                     html: '<a title="PowerPoint" href="' + links['PowerPoint'](editor.config.data['objectId']) + '">' + 
                     '<span class="icon-powerpoint"></span></a>'
                }]
            }]
        }, {
            id: 'tap-upload',
            filebrowser: 'uploadButton',
            label: lang.dialogTabUpload,
            elements: [{
                type: 'file',
                id: 'upload',
                label: lang.dialogUpload,
                style: 'height:40px',
                size: 38
            }, {
                type: 'html',
                html: '<div>DROP ZONE</div>'
            }]
        }]
    };
});
