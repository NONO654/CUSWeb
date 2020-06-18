define('DS/ENOXCollectionViewCommons/RefInstView/InstanceTileView/js/InstanceTileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'DS/UIKIT/DropdownMenu',
    'DS/UIKIT/Tooltip',
    'text!DS/ENOXCollectionViewCommons/RefInstView/InstanceTileView/html/InstanceTileView.html',
    'i18n!DS/ENOXCollectionViewCommons/assets/nls/collectionView.json',
    'css!DS/ENOXCollectionViewCommons/RefInstView/InstanceTileView/css/InstanceTileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, DropdownMenu, Tooltip, Template, nls) {
    'use strict';

    var template = Handlebars.compile(Template);

    var TileView = ControlsAbstract.inherit({
        name: 'InstanceTileView',

        publishedProperties: {
            shading: 'string',
            isSelected: 'boolean',
            isCut: 'boolean',
            thumbnail: 'string',
            isLastChild: 'boolean',
            isLastVersion: 'boolean',
            referenceQuantity: 'integer',
            referenceName: 'string',
            version:'string',
            instanceName: 'string',
            effectivity: 'string',
            attributes: 'array',
            noExpander: 'boolean'
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
        _applyShading: function () {
          if (this.shading === undefined || this.shading === null) {
            this.elements.container.style.removeProperty('border-left');
          } else {
                this.elements.container.style.borderLeft = 'solid 5px ' + this.shading;
          }
        },

        _applyIsCut: function () {
          if(this.isCut && this.isCut == true) {
            this.elements.container.addClassName('cut-item');
          } else {
            this.elements.container.removeClassName('cut-item');
          }
        },

        _applyIsSelected: function () {
            if ( this.isSelected) {
                  this.elements.container.addClassName('selected');
                  this.elements.container.getElement('.instance-tile-view-checkbox').checked = true;
          	} else {
                  this.elements.container.removeClassName('selected');
                  this.elements.container.getElement('.instance-tile-view-checkbox').checked = false;
          	}
        },
        _applyNoExpander : function(){
          if (this.noExpander) {
            this.elements.container.getElement('.instance-tile-view-quantity-container').addClassName('hidden');
          }
        },

        _applyThumbnail: function () {
            this.elements.container.getElement('.instance-tile-view-thumbnail-icon').src = this.thumbnail;
        },

        _applyReferenceName: function () {
            var refNameElement =  this.elements.container.getElement('.instance-tile-view-reference-name');
            refNameElement.textContent = this.referenceName;

            new Tooltip({
              target: refNameElement,
              trigger: 'hover touch',
              autoHide: true,
              body: this.referenceName
            });
        },
        
        _applyVersion: function () {
            this.elements.container.getElement('.instance-tile-view-version').textContent = this.version;
        },
        
        
        _applyIsLastVersion: function(){
            if (this.isLastVersion === false) {
              this.elements.container.getElement('.instance-tile-view-version').addClassName('not-last-version');
              this.elements.container.getElement('.fonticon.fonticon-attention').addClassName('not-last-version');
              new Tooltip({
            	    target: this.elements.container.getElement('.fonticon.fonticon-attention'),
            	    body: nls.get("IsNotLastVersion")
            	});
            } else {
              this.elements.container.getElement('.instance-tile-view-version').removeClassName('not-last-version');
              this.elements.container.getElement('.fonticon.fonticon-attention').removeClassName('not-last-version');
            }
        },

        _applyInstanceName: function () {
            this.elements.container.getElement('.instance-tile-view-instance-name').textContent = this.instanceName;
        },

        _applyEffectivity: function () {
            this.elements.container.getElement('.instance-tile-view-effectivity').textContent = this.effectivity;
        },

        _applyIsLastChild: function(){
          if (this.isLastChild) {
            this.elements.container.getElement('.instance-tile-view-expander').addClassName('last-group-node');
          } else {
            this.elements.container.getElement('.instance-tile-view-expander').removeClassName('last-group-node');
          }
        },
        _applyReferenceQuantity: function () {
        	if (this.referenceQuantity !== null) {
            this.elements.container.getElement('.instance-tile-view-expander').addClassName('first-group-node');
        		this.elements.container.getElement('.instance-tile-view-quantity-label').textContent = this.referenceQuantity;
        		this.elements.container.getElement('.instance-tile-view-quantity').removeClassName('hidden');
        	} else {
        		this.elements.container.getElement('.instance-tile-view-quantity').addClassName('hidden');
            this.elements.container.getElement('.instance-tile-view-expander').removeClassName('first-group-node');
        	}
        },

        _applyAttributes: function () {
        	var that = this;
          for (var i = 0; i < 6; i++) {
            var elt = that.elements.container.getElement('.instance-tile-view-attribute[data-index="' + i + '"]');
            elt.getElement('.instance-tile-view-attribute-name').textContent = '';
            elt.getElement('.instance-tile-view-attribute-value').textContent = '';
          }
        	that.attributes.forEach(function (attribute, idx) {
                var elt = that.elements.container.getElement('.instance-tile-view-attribute[data-index="' + idx + '"]');
                elt.getElement('.instance-tile-view-attribute-name').textContent = attribute.nls + ': ';
                elt.getElement('.instance-tile-view-attribute-value').textContent = attribute.value;
            });
        }
    });

    return TileView;
});
