define('DS/ENOXCollectionViewCommons/ReferenceView/ReferenceTileView/js/ReferenceTileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'DS/UIKIT/DropdownMenu',
    'text!DS/ENOXCollectionViewCommons/ReferenceView/ReferenceTileView/html/ReferenceTileView.html',
    'css!DS/ENOXCollectionViewCommons/ReferenceView/ReferenceTileView/css/ReferenceTileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, DropdownMenu, Template) {
    'use strict';

    var template = Handlebars.compile(Template);

    var TileView = ControlsAbstract.inherit({
        name: 'ReferenceTileView',

        publishedProperties: {
        	shading: 'string',
        	isExpandable: 'boolean',
        	isExpanded: 'boolean',
            isSelected: 'boolean',
            quantity: 'integer',
            thumbnail: 'string',
            referenceName: 'string',
            referenceMainAttribute: 'object',
            attributes: 'array'
        },

        _postBuildView: function () {
            var that = this;

            that._parent();

            /** Use template as boilerplate for creation of the tile */
            that.elements.container.setHTML(template());

            /** Encapsulate styles behind a CSS class */
            that.elements.container.addClassName('reference-tile-view');

            /** Add dropdown menu */
            /*new DropdownMenu({
                target: that.elements.container.getElement('.reference-tile-view-dropdown-menu'),
                items: [
                    {text: 'Ruby', items: [{text: 'Crescent Rose'}]},
                    {text: 'Weiss', items: [{text: 'Myrtenaster'}]},
                    {text: 'Blake', items: [{text: 'Gambol Shroud'}]},
                    {text: 'Yang', items: [{text: 'Ember Celica'}]}
                ]
            });*/

            /** Stop propagation on dropdown click */
            that.elements.container.getElement('.reference-tile-view-dropdown-menu').addEventListener('click', function (e) {
            	e.stopPropagation();
            	widget.body.getElement('.wux-tree-treelistview').dispatchEvent(new CustomEvent('tile-menu-click', {detail:{itemView: that, event: e}}));
            });

            /*that.elements.container.getElement('.reference-tile-view-expander').addEventListener('click', function (e) {
            	e.stopPropagation();
            });*/
        },

        _applyShading: function () {
        	if (this.shading === undefined || this.shading === null) {
        		this.elements.container.style.removeProperty('border-left');
        	} else {
                this.elements.container.style.borderLeft = 'solid 5px ' + this.shading;
        	}
        },

        /*_applyIsExpandable: function () {
        	if (!this.isExpandable && this.elements.container.getElement('.reference-tile-view-quantity')) {
        		this.elements.container.getElement('.reference-tile-view-quantity').destroy();
        	}
        },*/

        _applyIsExpanded: function () {
        	//if (this.isExpandable && this.elements.container.getElement('.reference-tile-view-quantity')) {
	        	if (this.isExpanded) {
	        		this.elements.container.classList.add('expanded');
	        		this.elements.container.getElement('.reference-tile-view-expander .fonticon').removeClassName('fonticon-expand-right').addClassName('fonticon-expand-down');
	        	} else {
	        		this.elements.container.classList.remove('expanded');
	        		this.elements.container.getElement('.reference-tile-view-expander .fonticon').removeClassName('fonticon-expand-down').addClassName('fonticon-expand-right');
	        	}
        	//}
        },

        _applyIsSelected: function () {
            this.elements.container.getElement('.reference-tile-view-checkbox').checked = this.isSelected;
        },

        _applyQuantity: function () {
        	this.elements.container.getElement('.reference-tile-view-quantity-label').textContent = this.quantity;
        },

        _applyThumbnail: function () {
            this.elements.container.getElement('.reference-tile-view-thumbnail-icon').src = this.thumbnail;
        },

        _applyReferenceName: function () {
            this.elements.container.getElement('.reference-tile-view-reference-name').textContent = this.referenceName;
        },

        _applyReferenceMainAttribute: function () {
            var that = this, elt = that.elements.container.getElement('.reference-tile-view-reference-state');

            elt.getElement('.reference-tile-view-reference-state-name').textContent = this.referenceMainAttribute.name + ': ';
            elt.getElement('.reference-tile-view-reference-state-value').textContent = this.referenceMainAttribute.value;

            /*if(this.referenceMainAttribute.isClickable && !this.referenceMainAttribute.bEventSet){
            	elt.getElement('.reference-tile-view-reference-state-value').addClassName('clickable');
            	 elt.getElement('.reference-tile-view-reference-state-value').addEventListener('click', function (e) {
                 	e.stopPropagation();
                 	console.log('that---'+that);
                 	widget.body.getElement('.wux-tree-treelistview').dispatchEvent(new CustomEvent('attribute-click', {detail:{itemView: that, event: e}}));
                 });
            	 this.referenceMainAttribute.bEventSet = true;
            }*/
        },

        _applyAttributes: function () {
        	var that = this;

        	that.attributes.forEach(function (attribute, idx) {
                var elt = that.elements.container.getElement('.reference-tile-view-attribute[data-index="' + idx + '"]');
                elt.getElement('.reference-tile-view-attribute-name').textContent = attribute.nls + ': ';
                elt.getElement('.reference-tile-view-attribute-value').textContent = attribute.value;

                /*if(attribute.isClickable && !attribute.bEventSet){
                	elt.getElement('.reference-tile-view-attribute-value').addClassName('clickable');
                	 elt.getElement('.reference-tile-view-attribute-value').addEventListener('click', function (e) {
                     	e.stopPropagation();
                     	console.log('that---'+that);
                     });
                	 attribute.bEventSet = true;
                }*/

            });
        }
    });

    return TileView;
});
