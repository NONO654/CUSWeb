define('DS/ENOXCollectionViewCommons/InstanceView/InstanceTileView/js/InstanceTileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'DS/UIKIT/DropdownMenu',
    'text!DS/ENOXCollectionViewCommons/InstanceView/InstanceTileView/html/InstanceTileView.html',
    // 'css!DS/ENOXCollectionViewCommons/InstanceView/InstanceTileView/css/InstanceTileView.css',
    'css!DS/ENOXCollectionViewCommons/RefInstView/InstanceTileView/css/InstanceTileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, DropdownMenu, Template) {
    'use strict';

    var template = Handlebars.compile(Template);

    var TileView = ControlsAbstract.inherit({
        name: 'ReferenceTileView',

        publishedProperties: {
            isSelected: 'boolean',
            thumbnail: 'string',
            isMainSelection: 'boolean',
            referenceQuantity: 'integer',
            isLastVersion: 'boolean',
            referenceName: 'string',
            instanceName: 'string',
            version:'string',
            effectivity: 'string',
            attributes: 'array'
        },

        _postBuildView: function (options) {
            var that = this;

            that._parent(options);

            /** Use template as boilerplate for creation of the tile */
            that.elements.container.setHTML(template());

            that.elements.container.draggable = "true";

            /** Encapsulate styles behind a CSS class */
            that.elements.container.addClassName('instance-tile-view');

        },
        _applyIsSelected: function () {
            this.elements.container.getElement('.instance-tile-view-checkbox').checked = this.isSelected;
            // if ( this.isSelected) {
            //       this.elements.container.addClassName('selected');
            // } else {
            //       this.elements.container.removeClassName('selected');
            // }
        },

        _applyIsMainSelection: function () {
          this.elements.container.getElement('.instance-tile-view-checkbox').checked = this.isMainSelection; //hack
          if (this.isMainSelection) {
                this.elements.container.addClassName('selected');
          } else {
                this.elements.container.removeClassName('selected');
          }
        },

        _applyThumbnail: function () {
            this.elements.container.getElement('.instance-tile-view-thumbnail-icon').src = this.thumbnail;
        },

        _applyReferenceName: function () {
            this.elements.container.getElement('.instance-tile-view-reference-name').textContent = this.referenceName;
        },

        _applyInstanceName: function () {
            this.elements.container.getElement('.instance-tile-view-instance-name').textContent = this.instanceName;
        },

        _applyEffectivity: function () {
            this.elements.container.getElement('.instance-tile-view-effectivity').textContent = this.effectivity;
        },



        _applyAttributes: function () {
          var that = this;

          that.attributes.forEach(function (attribute, idx) {
                var elt = that.elements.container.getElement('.instance-tile-view-attribute[data-index="' + idx + '"]');
                elt.getElement('.instance-tile-view-attribute-name').textContent = attribute.name + ': ';
                elt.getElement('.instance-tile-view-attribute-value').textContent = attribute.value;
            });
        }
    });

    return TileView;
});
