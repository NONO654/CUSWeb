define('DS/ENOXCollectionViewCommons/ReferenceView/ReferenceTileView/js/ReferenceSubtileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'text!DS/ENOXCollectionViewCommons/ReferenceView/ReferenceTileView/html/ReferenceSubtileView.html',
    'css!DS/ENOXCollectionViewCommons/ReferenceView/ReferenceTileView/css/ReferenceSubtileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, Template) {
    'use strict';

    var template = Handlebars.compile(Template);

    var ReferenceSubtileView = ControlsAbstract.inherit({
        name: 'ReferenceSubtileView',

        publishedProperties: {
            isSelected: 'boolean',
            name: 'string',
            effectivity: 'string',
            thumbnail: 'string',
            referenceName: 'string',
            referenceMainAttribute: 'object',
            attributes: 'array',
            isLast: 'boolean'
        },

        _postBuildView: function (options) {
            var that = this;

            that._parent(options);

            /** Use template as boilerplate for creation of the tile */
            that.elements.container.setHTML(template());

            /** Encapsulate styles behind a CSS class */
            that.elements.container.addClassName('reference-subtile-view');
            
            /** Stop propagation on dropdown click */
            that.elements.container.getElement('.reference-subtile-view-dropdown-menu').addEventListener('click', function (e) {
            	e.stopPropagation();
            	widget.body.getElement('.wux-tree-treelistview').dispatchEvent(new CustomEvent('tile-menu-click', {detail:{itemView: that, event: e}}));
            });
        },

        _applyIsSelected: function () {
            this.elements.container.getElement('.reference-subtile-view-checkbox').checked = this.isSelected;
        },

        _applyName: function () {
            this.elements.container.getElement('.reference-subtile-view-name').textContent = this.name;
        },

        _applyEffectivity: function () {
            this.elements.container.getElement('.reference-subtile-view-effectivity').textContent = this.effectivity;
        },
        
        _applyIsLast: function () {
        	if (this.isLast) {
        		this.elements.container.classList.add('last-subtile');
        	} else {
        		this.elements.container.classList.remove('last-subtile');
        	}
        },
        
        _applyThumbnail: function () {
            this.elements.container.getElement('.reference-subtile-view-thumbnail-icon').src = this.thumbnail;
        },

        _applyReferenceName: function () {
            this.elements.container.getElement('.reference-subtile-view-reference-name').textContent = this.referenceName;
        },

        _applyReferenceMainAttribute: function () {
            var that = this, elt = that.elements.container.getElement('.reference-subtile-view-reference-state');
           
            elt.getElement('.reference-subtile-view-reference-state-name').textContent = this.referenceMainAttribute.name + ': ';
            elt.getElement('.reference-subtile-view-reference-state-value').textContent = this.referenceMainAttribute.value;
           
            if(this.referenceMainAttribute.isClickable && !this.referenceMainAttribute.bEventSet){
            	elt.getElement('.reference-subtile-view-reference-state-value').addClassName('clickable');
            	 elt.getElement('.reference-subtile-view-reference-state-value').addEventListener('click', function (e) {
                 	e.stopPropagation();
                 	console.log('that---'+that);
                 	widget.body.getElement('.wux-tree-treelistview').dispatchEvent(new CustomEvent('attribute-click', {detail:{itemView: that, event: e}}));
                 });
            	 this.referenceMainAttribute.bEventSet = true;
            }
        },

        _applyAttributes: function (context) {
        	var that = this;

        	that.attributes.forEach(function (attribute, idx) {
                var elt = that.elements.container.getElement('.reference-subtile-view-attribute[data-index="' + idx + '"]');
                elt.getElement('.reference-subtile-view-attribute-name').textContent = attribute.name + ': ';
                elt.getElement('.reference-subtile-view-attribute-value').textContent = attribute.value;
                
                if(attribute.isClickable && !attribute.bEventSet){
                	elt.getElement('.reference-subtile-view-attribute-value').addClassName('clickable');
                	 elt.getElement('.reference-subtile-view-attribute-value').addEventListener('click', function (e) {
                     	e.stopPropagation();
                     	console.log('that---'+that);
                     });
                	 attribute.bEventSet = true;
                }
               
            });
        }
    });

    return ReferenceSubtileView;
});
