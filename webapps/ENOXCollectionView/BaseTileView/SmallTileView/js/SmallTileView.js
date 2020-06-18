define('DS/ENOXCollectionView/BaseTileView/SmallTileView/js/SmallTileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'DS/UIKIT/DropdownMenu',
    'text!DS/ENOXCollectionView/BaseTileView/SmallTileView/html/SmallTileView.html',
    'css!DS/ENOXCollectionView/BaseTileView/SmallTileView/css/SmallTileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, DropdownMenu, Template) {
    'use strict';

    var template = Handlebars.compile(Template);

    var SmallTileView = ControlsAbstract.inherit({
        name: 'SmallTileView',

        publishedProperties: {
        	disabled: 'boolean',
            shading: 'string',
            isSelected: 'boolean',
            isActive: 'boolean',
            typeIcon: 'string',
            title: 'string',
            version: 'string',
            primaryAttribute: 'object',
            secondaryAttribute: 'object',
            attributes: 'array'
        },

        _postBuildView: function (options) {
            var that = this;

            that._parent(options);

            /** Use template as boilerplate for creation of the tile */
            that.elements.container.setHTML(template());
            that.elements.container.draggable = 'true';

            /** Encapsulate styles behind a CSS class */
            that.elements.container.addClassName('small-tile-view');
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

        _applyIsSelected: function () {
            this.elements.container.getElement('.small-tile-view-checkbox').checked = this.isSelected;
        },

        _applyIsActive: function () {
            if (this.isActive) {
                this.elements.container.addClassName('selected');
            } else {
                this.elements.container.removeClassName('selected');
            }
        },

        _applyTitle: function () {
            this.elements.container.getElement('.small-tile-view-title').textContent = this.title;
        },

        _applyVersion: function () {
        	this.elements.container.getElement('.small-tile-view-version').textContent = this.version;
        },

        _applyPrimaryAttribute: function () {
            var text = (typeof this.primaryAttribute === 'string') ? this.primaryAttribute : (this.primaryAttribute.name + ' : ' + this.primaryAttribute.value);
            this.elements.container.getElement('.small-tile-view-primary-attribute').textContent = text;
        },

        _applySecondaryAttribute: function () {
            var text = (typeof this.secondaryAttribute === 'string') ? this.secondaryAttribute : (this.secondaryAttribute.name + ' : ' + this.secondaryAttribute.value);
            this.elements.container.getElement('.small-tile-view-secondary-attribute').textContent = text;
        },

        _applyAttributes: function () {
            var that = this;

            that.attributes.forEach(function (attribute, idx) {
                if (idx > 3) {
                    return;
                }
                var elt = that.elements.container.getElement('.small-tile-view-attribute[data-index="' + idx + '"]');
                elt.getElement('.small-tile-view-attribute-name').textContent = attribute.name + ': ';
                elt.getElement('.small-tile-view-attribute-value').textContent = attribute.value;
            });
        }
    });

    return SmallTileView;
});
