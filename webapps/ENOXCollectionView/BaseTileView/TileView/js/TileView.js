define('DS/ENOXCollectionView/BaseTileView/TileView/js/TileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'DS/UIKIT/DropdownMenu',
    'text!DS/ENOXCollectionView/BaseTileView/TileView/html/TileView.html',
    'css!DS/ENOXCollectionView/BaseTileView/TileView/css/TileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, DropdownMenu, Template) {
    'use strict';

    var template = Handlebars.compile(Template);

    var TileView = ControlsAbstract.inherit({
        name: 'TileView',

        publishedProperties: {
        	disabled: 'boolean',
            shading: 'string',
            isSelected: 'boolean',
            isActive: 'boolean',
            thumbnail: 'string',
            typeIcon: 'string',
            cue: 'string',
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
            that.elements.container.addClassName('tile-view');
        },

        _applyDisabled: function () {
        	if (this.disabled) {
        		this.elements.container.classList.add('disabled');
        		//this.elements.container.getElement('.tile-view-checkbox').disabled = true;
        	} else {
        		this.elements.container.classList.remove('disabled');
        		//this.elements.container.getElement('.tile-view-checkbox').disabled = false;
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
            this.elements.container.getElement('.tile-view-checkbox').checked = this.isSelected;
        },

        _applyIsActive: function () {
            if (this.isActive) {
                this.elements.container.addClassName('selected');
            } else {
                this.elements.container.removeClassName('selected');
            }
        },

        _applyThumbnail: function () {
            this.elements.container.getElement('.tile-view-thumbnail-icon').src = this.thumbnail;
        },

        _applyCue: function () {
        	if (this.cue !== undefined && this.cue !== null) {
                this.elements.container.getElement('.tile-view-cue-icon').src = this.cue;
        	} else {
                this.elements.container.getElement('.tile-view-cue-icon').src = '';
        	}
        },

        _applyTitle: function () {
            this.elements.container.getElement('.tile-view-title').textContent = this.title;
        },

        _applyVersion: function () {
        	this.elements.container.getElement('.tile-view-version').textContent = this.version;
        },

        _applyPrimaryAttribute: function () {
        	var text = (typeof this.primaryAttribute === 'string') ? this.primaryAttribute : (this.primaryAttribute.name + ' : ' + this.primaryAttribute.value);
            this.elements.container.getElement('.tile-view-primary-attribute').textContent = text;
        },

        _applySecondaryAttribute: function () {
        	var text = (typeof this.secondaryAttribute === 'string') ? this.secondaryAttribute : (this.secondaryAttribute.name + ' : ' + this.secondaryAttribute.value);
            this.elements.container.getElement('.tile-view-secondary-attribute').textContent = text;
        },

        _applyAttributes: function () {
            var that = this;

            // Clean old attributes
            that.elements.container.getElements('.tile-view-attribute').forEach(function (elt) {
                elt.getElement('.tile-view-attribute-name').textContent = '';
                elt.getElement('.tile-view-attribute-value').textContent = '';
            });

            that.attributes.forEach(function (attribute, idx) {
                var elt = that.elements.container.getElement('.tile-view-attribute[data-index="' + idx + '"]');
                elt.getElement('.tile-view-attribute-name').textContent = attribute.name + ': ';
                elt.getElement('.tile-view-attribute-value').textContent = attribute.value;
                if (attribute.type === 'link') {
                    elt.getElement('.tile-view-attribute-value').classList.add('link');
                } else {
                    elt.getElement('.tile-view-attribute-value').classList.remove('link');
                }
            });
        }
    });

    return TileView;
});
