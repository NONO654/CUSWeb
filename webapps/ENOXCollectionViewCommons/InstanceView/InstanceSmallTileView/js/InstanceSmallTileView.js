define('DS/ENOXCollectionViewCommons/InstanceView/InstanceSmallTileView/js/InstanceSmallTileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'DS/UIKIT/DropdownMenu',
    'text!DS/ENOXCollectionViewCommons/InstanceView/InstanceSmallTileView/html/InstanceSmallTileView.html',
    'css!DS/ENOXCollectionViewCommons/InstanceView/InstanceSmallTileView/css/InstanceSmallTileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, DropdownMenu, Template) {
    'use strict';

    var template = Handlebars.compile(Template);

    var InstanceSmallTileView = ControlsAbstract.inherit({
        name: 'InstanceSmallTileView',

        publishedProperties: {
        	shading: 'string',
            isSelected: 'boolean',
            isMainSelection: 'boolean',
            referenceName: 'string',
            referenceMainAttribute: 'object',
            attributes: 'array',
            instanceName: 'string',
            instanceMainAttribute: 'object',
            effectivity: 'string'
        },

        _postBuildView: function (options) {
            var that = this;

            that._parent(options);

            /** Use template as boilerplate for creation of the tile */
            that.elements.container.setHTML(template());
            that.elements.container.draggable = "true";

            /** Encapsulate styles behind a CSS class */
            that.elements.container.addClassName('instance-small-tile-view');
        },
        _applyIsMainSelection: function () {
        	if (this.isMainSelection) {
                this.elements.container.addClassName('selected');
        	} else {
                this.elements.container.removeClassName('selected');
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
            this.elements.container.getElement('.instance-small-tile-view-checkbox').checked = this.isSelected;
        },

        _applyReferenceName: function () {
            this.elements.container.getElement('.instance-small-tile-view-reference-name').textContent = this.referenceName;
        },

        _applyReferenceMainAttribute: function () {
            var text = (this.referenceMainAttribute.name === undefined) ? '': this.referenceMainAttribute.name + ': ';
            this.elements.container.getElement('.instance-small-tile-view-reference-state').textContent = text + this.referenceMainAttribute.value;
        },

        _applyAttributes: function () {
        	var that = this;

        	that.attributes.forEach(function (attribute, idx) {
        		if (idx > 3) {
        			return;
        		}
                var elt = that.elements.container.getElement('.instance-small-tile-view-attribute[data-index="' + idx + '"]');
                elt.getElement('.instance-small-tile-view-attribute-name').textContent = attribute.name + ': ';
                elt.getElement('.instance-small-tile-view-attribute-value').textContent = attribute.value;
            });
        },

        _applyInstanceName: function () {
            this.elements.container.getElement('.instance-small-tile-view-name').textContent = this.instanceName;
        },

        _applyInstanceMainAttribute: function () {
            var text = (this.instanceMainAttribute.name === undefined) ? '': this.instanceMainAttribute.name + ': ';
            this.elements.container.getElement('.instance-small-tile-view-effectivity').textContent = text + this.instanceMainAttribute.value;
        },
    });

    return InstanceSmallTileView;
});
