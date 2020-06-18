define('DS/ENOXCollectionView/ExpandableTileView/ExpandedTileView/js/ExpandedTileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'DS/UIKIT/DropdownMenu',
    'text!DS/ENOXCollectionView/ExpandableTileView/ExpandedTileView/html/ExpandedTileView.html',
    'css!DS/ENOXCollectionView/ExpandableTileView/ExpandedTileView/css/ExpandedTileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, DropdownMenu, Template) {
    'use strict';

    var template = Handlebars.compile(Template);

    var TileView = ControlsAbstract.inherit({
        name: 'ExpandedTileView',

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
            secondaryAttribute: 'object',
            attributes: 'array'
        },

        _postBuildView: function (options) {
            var that = this;

            that._parent(options);

            /** Use template as boilerplate for creation of the tile */
            that.elements.container.setHTML(template());

            /** Encapsulate styles behind a CSS class */
            that.elements.container.addClassName('expanded-tile-view');
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
            if (this.numberOfOccurences !== undefined && this.numberOfOccurences !== null) {
                this.elements.container.getElement('.expanded-tile-view-quantity-label').textContent = this.numberOfOccurences;
                this.elements.container.getElement('.expanded-tile-view-quantity').classList.remove('hidden');
            } else {
                this.elements.container.getElement('.expanded-tile-view-quantity').classList.add('hidden');
            }
        },

        _applyIsSelected: function () {
            this.elements.container.getElement('.expanded-tile-view-checkbox').checked = this.isSelected;
        },

        _applyIsActive: function () {
            if (this.isActive) {
                this.elements.container.addClassName('selected');
            } else {
                this.elements.container.removeClassName('selected');
            }
        },

        _applyThumbnail: function () {
            this.elements.container.getElement('.expanded-tile-view-thumbnail-icon').src = this.thumbnail;
        },

        _applyTitle: function () {
            this.elements.container.getElement('.expanded-tile-view-title').textContent = this.title;
        },

        _applyVersion: function () {
        	this.elements.container.getElement('.expanded-tile-view-version').textContent = this.version;
        },

        _applyPrimaryAttribute: function () {
            this.elements.container.getElement('.expanded-tile-view-primary-attribute').textContent = this.primaryAttribute;
        },

        _applySecondaryAttribute: function () {
            this.elements.container.getElement('.expanded-tile-view-secondary-attribute').textContent = this.secondaryAttribute;
        },

        _applyAttributes: function () {
            var that = this;

            that.attributes.forEach(function (attribute, idx) {
                var elt = that.elements.container.getElement('.expanded-tile-view-attribute[data-index="' + idx + '"]');
                elt.getElement('.expanded-tile-view-attribute-name').textContent = attribute.name + ': ';
                elt.getElement('.expanded-tile-view-attribute-value').textContent = attribute.value;
            });
        }
    });

    return TileView;
});
