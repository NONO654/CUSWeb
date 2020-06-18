define('DS/ENOXCollectionView/ExpandableTileView/CollapsedTileView/js/CollapsedTileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'DS/UIKIT/DropdownMenu',
    'text!DS/ENOXCollectionView/ExpandableTileView/CollapsedTileView/html/CollapsedTileView.html',
    'css!DS/ENOXCollectionView/ExpandableTileView/CollapsedTileView/css/CollapsedTileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, DropdownMenu, Template) {
    'use strict';

    var template = Handlebars.compile(Template);

    var TileView = ControlsAbstract.inherit({
        name: 'CollapsedTileView',

        publishedProperties: {
        	disabled: 'boolean',
            shading: 'string',
            numberOfOccurences: 'number',
            isSelected: 'boolean',
            isActive: 'boolean',
            thumbnail: 'string',
            typeIcon: 'string',
            title: 'string',
            version: 'string',
            primaryAttribute: 'object',
            attributes: 'array'
        },

        _postBuildView: function (options) {
            var that = this;

            that._parent(options);

            /** Use template as boilerplate for creation of the tile */
            that.elements.container.setHTML(template());

            /** Encapsulate styles behind a CSS class */
            that.elements.container.addClassName('collapsed-tile-view');
        },

        _applyDisabled: function () {
        	if (this.disabled) {
        		this.elements.container.classList.add('disabled');
        	} else {
        		this.elements.container.classList.remove('disabled');
        	}
        },

        _applyShading: function () {
        	if (this.shading === undefined || this.shading === null) {
        		this.elements.container.style.removeProperty('border-left');
        	} else {
                this.elements.container.style.borderLeft = 'solid 5px ' + this.shading;
        	}
        },

        _applyNumberOfOccurences: function () {
            this.elements.container.getElement('.collapsed-tile-view-quantity-label').textContent = this.numberOfOccurences;
        },
        
        _applyIsSelected: function () {
            this.elements.container.getElement('.collapsed-tile-view-checkbox').checked = this.isSelected;
        },

        _applyIsActive: function () {
            if (this.isActive) {
                this.elements.container.addClassName('selected');
            } else {
                this.elements.container.removeClassName('selected');
            }
        },

        _applyThumbnail: function () {
            this.elements.container.getElement('.collapsed-tile-view-thumbnail-icon').src = this.thumbnail;
        },

        _applyTitle: function () {
            this.elements.container.getElement('.collapsed-tile-view-title').textContent = this.title;
        },

        _applyVersion: function () {
        	this.elements.container.getElement('.collapsed-tile-view-version').textContent = this.version;
        },

        _applyPrimaryAttribute: function () {
        	var text = (typeof this.primaryAttribute === 'string') ? this.primaryAttribute : (this.primaryAttribute.name + ' : ' + this.primaryAttribute.value);
            this.elements.container.getElement('.collapsed-tile-view-primary-attribute').textContent = text;
        },

        _applyAttributes: function () {
            var that = this;

            that.attributes.forEach(function (attribute, idx) {
                var elt = that.elements.container.getElement('.collapsed-tile-view-attribute[data-index="' + idx + '"]');
                elt.getElement('.collapsed-tile-view-attribute-name').textContent = attribute.name + ': ';
                elt.getElement('.collapsed-tile-view-attribute-value').textContent = attribute.value;
            });
        }
    });

    return TileView;
});
