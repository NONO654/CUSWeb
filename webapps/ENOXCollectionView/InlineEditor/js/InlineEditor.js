define('DS/ENOXCollectionView/InlineEditor/js/InlineEditor', [
    'DS/Handlebars/Handlebars',
    'text!DS/ENOXCollectionView/InlineEditor/html/InlineEditor.html',
    'css!DS/ENOXCollectionView/InlineEditor/css/InlineEditor.css'
], function (Handlebars, Template) {
    
    var templateFn = Handlebars.compile(Template);
    
    var InlineEditor = function (container, value, modelEvents) {
    	this.oldValue = value;
        this.container = container;
        this.modelEvents = modelEvents;
    };
    
    InlineEditor.prototype.render = function () {
        var that = this;
    	that.container.classList.add('inline-editor');
        that.container.innerHTML = templateFn({text: that.oldValue});

        that.container.querySelector('.fonticon-check').addEventListener('click', function () {
        	that.modelEvents.publish({event: 'inline-editor-validated', data: {value: that.container.querySelector('.inline-editor-text').value}});
        });
        that.container.querySelector('.fonticon-wrong').addEventListener('click', function () {
        	that.modelEvents.publish({event: 'inline-editor-cancelled', data: {value: that.oldValue}});
        });
    };
    
    /** Call this method to replace an element by an inline editor */
    InlineEditor.replaceElementByInlineEditor = function (element, modelEvents) {
    	// Hide base element
    	element.classList.add('hidden');

    	// Create the inline editor and his container
    	var inlineEditorContainer = document.createElement('div');
    	var inlineEditor = new InlineEditor(inlineEditorContainer, element.textContent, modelEvents).render();
        element.parentNode.insertBefore(inlineEditorContainer, element.parentNode.firstChild);
        inlineEditorContainer.querySelector('.inline-editor-text').focus();

        return inlineEditorContainer;
    };
    
    /** Call this method on your onCellRequest callback to clean old inline editor component */
    InlineEditor.cleanOnCellRequest = function (cellInfos) {
        var inlineEditor = cellInfos.cellView.elements.container.getElement('.inline-editor');
        if (inlineEditor !== null) {
        	inlineEditor.parentNode.removeChild(inlineEditor);
        	cellInfos.cellView.elements.container.getElement('.tile-view-title').classList.remove('hidden');
        }
    };
    
    return InlineEditor;
});
