define('DS/ENOXCollectionViewCommons/ReferenceView/ReferenceSmallTileView/js/ReferenceSmallTileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'DS/UIKIT/DropdownMenu',
    'text!DS/ENOXCollectionViewCommons/ReferenceView/ReferenceSmallTileView/html/ReferenceSmallTileView.html',
    'css!DS/ENOXCollectionViewCommons/ReferenceView/ReferenceSmallTileView/css/ReferenceSmallTileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, DropdownMenu, Template) {
    'use strict';

    var template = Handlebars.compile(Template);

    var ReferenceSmallTileView = ControlsAbstract.inherit({
        name: 'ReferenceSmallTileView',

        publishedProperties: {
        	shading: 'string',
        	isExpanded: 'boolean',
            isSelected: 'boolean',
            quantity: 'integer',
            referenceName: 'string',
            referenceMainAttribute: 'object',
            attributes: 'array'
        },

        _postBuildView: function (options) {
            var that = this;

            that._parent(options);

            /** Use template as boilerplate for creation of the tile */
            that.elements.container.setHTML(template());

            /** Encapsulate styles behind a CSS class */
            that.elements.container.addClassName('reference-small-tile-view');

            /** Add dropdown menu */
            new DropdownMenu({
                target: that.elements.container.getElement('.reference-small-tile-view-dropdown-menu'),
                items: [
                    {text: 'Ruby', items: [{text: 'Crescent Rose'}]},
                    {text: 'Weiss', items: [{text: 'Myrtenaster'}]},
                    {text: 'Blake', items: [{text: 'Gambol Shroud'}]},
                    {text: 'Yang', items: [{text: 'Ember Celica'}]}
                ]
            });

            /** Stop propagation on dropdown click */
            that.elements.container.getElement('.reference-small-tile-view-dropdown-menu').addEventListener('click', function (e) {
            	e.stopPropagation();
            });
        },

        _applyShading: function () {
        	if (this.shading === undefined || this.shading === null) {
        		this.elements.container.style.removeProperty('border-left');
        	} else {
                this.elements.container.style.borderLeft = 'solid 5px ' + this.shading;
        	}
        },

        _applyIsExpanded: function () {
        	if (this.isExpanded) {
        		this.elements.container.classList.add('expanded');
        		this.elements.container.getElement('.reference-small-tile-view-expander .fonticon').removeClassName('fonticon-expand-right').addClassName('fonticon-expand-down');
        	} else {
        		this.elements.container.classList.remove('expanded');
        		this.elements.container.getElement('.reference-small-tile-view-expander .fonticon').removeClassName('fonticon-expand-down').addClassName('fonticon-expand-right');
        	}
        },

        _applyIsSelected: function () {
            this.elements.container.getElement('.reference-small-tile-view-checkbox').checked = this.isSelected;
        },

        _applyQuantity: function () {
        	this.elements.container.getElement('.reference-small-tile-view-quantity-label').textContent = this.quantity;
        },

        _applyReferenceName: function () {
            this.elements.container.getElement('.reference-small-tile-view-reference-name').textContent = this.referenceName;
        },

        _applyReferenceMainAttribute: function () {
            var text = (this.referenceMainAttribute.name === undefined) ? '': this.referenceMainAttribute.name + ': ';
            this.elements.container.getElement('.reference-small-tile-view-reference-state').textContent = text + this.referenceMainAttribute.value;
        },

        _applyAttributes: function () {
        	var that = this;

        	that.attributes.forEach(function (attribute, idx) {
                var elt = that.elements.container.getElement('.reference-small-tile-view-attribute[data-index="' + idx + '"]');
                elt.getElement('.reference-small-tile-view-attribute-name').textContent = attribute.name + ': ';
                elt.getElement('.reference-small-tile-view-attribute-value').textContent = attribute.value;
            });
        }
    });

    return ReferenceSmallTileView;
});
