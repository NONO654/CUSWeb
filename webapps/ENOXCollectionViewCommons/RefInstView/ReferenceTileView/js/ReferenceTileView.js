define('DS/ENOXCollectionViewCommons/RefInstView/ReferenceTileView/js/ReferenceTileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'DS/UIKIT/DropdownMenu',
    'DS/UIKIT/Tooltip',
    'text!DS/ENOXCollectionViewCommons/RefInstView/ReferenceTileView/html/ReferenceTileView.html',
    'i18n!DS/ENOXCollectionViewCommons/assets/nls/collectionView.json',
    'css!DS/ENOXCollectionViewCommons/RefInstView/ReferenceTileView/css/ReferenceTileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, DropdownMenu, Tooltip, Template, nls) {
    'use strict';

    var template = Handlebars.compile(Template);

    var TileView = ControlsAbstract.inherit({
        name: 'ReferenceTileView',

        publishedProperties: {
        	shading: 'string',
        	isExpanded: 'boolean',
            isSelected: 'boolean',
            isLastVersion: 'boolean',
            isMainSelection: 'boolean',
            quantity: 'integer',
            thumbnail: 'string',
            referenceName: 'string',
            version:'string',
            attributes: 'array'
        },

        _postBuildView: function (options) {
            var that = this;

            that._parent(options);

            /** Use template as boilerplate for creation of the tile */
            that.elements.container.setHTML(template());

            /** Encapsulate styles behind a CSS class */
            that.elements.container.addClassName('reference-tile-view');


        },

        _applyShading: function () {
        	if (this.shading === undefined || this.shading === null) {
        		this.elements.container.style.removeProperty('border-left');
        	} else {
                this.elements.container.style.borderLeft = 'solid 5px ' + this.shading;
        	}
        },

        _applyIsExpanded: function () {
        	// if (this.isExpanded) {
        	// 	this.elements.container.classList.add('expanded');
        	// 	this.elements.container.getElement('.reference-tile-view-expander .fonticon').removeClassName('fonticon-expand-right').addClassName('fonticon-expand-down');
        	// } else {
        	// 	this.elements.container.classList.remove('expanded');
        	// 	this.elements.container.getElement('.reference-tile-view-expander .fonticon').removeClassName('fonticon-expand-down').addClassName('fonticon-expand-right');
        	// }
        },
        _applyIsMainSelection: function () {
          this.elements.container.getElement('.reference-tile-view-checkbox').checked = this.isMainSelection; //hack
          if (this.isMainSelection) {
                this.elements.container.addClassName('selected');
        	} else {
                this.elements.container.removeClassName('selected');
        	}
        },

        _applyIsSelected: function () {
            this.elements.container.getElement('.reference-tile-view-checkbox').checked = this.isSelected;
        },

        _applyQuantity: function () {
            this.elements.container.getElement('.reference-tile-view-quantity-label').textContent = this.quantity;

            if (this.quantity <= 1) {
                this.elements.container.getElement('.reference-tile-view-quantity-sublabel').textContent = this.quantity + ' instance';
            } else {
                this.elements.container.getElement('.reference-tile-view-quantity-sublabel').textContent = this.quantity + ' instances';
            }
        },

        _applyThumbnail: function () {
            this.elements.container.getElement('.reference-tile-view-thumbnail-icon').src = this.thumbnail;
        },

        _applyReferenceName: function () {
            this.elements.container.getElement('.reference-tile-view-reference-name').textContent = this.referenceName;
        },
        
        
        _applyVersion: function () {
            this.elements.container.getElement('.reference-tile-view-version').textContent = this.version;
        },
        
        
        _applyIsLastVersion: function(){
            if (this.isLastVersion === false) {
              this.elements.container.getElement('.reference-tile-view-version').addClassName('not-last-version');
              this.elements.container.getElement('.fonticon.fonticon-attention').addClassName('not-last-version');
              new Tooltip({
            	    target: this.elements.container.getElement('.fonticon.fonticon-attention'),
            	    body: nls.get("IsNotLastVersion")
            	});
            } else {
              this.elements.container.getElement('.reference-tile-view-version').removeClassName('not-last-version');
              this.elements.container.getElement('.fonticon.fonticon-attention').removeClassName('not-last-version');
            }
        },
        

        _applyAttributes: function () {
        	var that = this;

        	that.attributes.forEach(function (attribute, idx) {
                var elt = that.elements.container.getElement('.reference-tile-view-attribute[data-index="' + idx + '"]');
                elt.getElement('.reference-tile-view-attribute-name').textContent = attribute.nls + ': ';
                elt.getElement('.reference-tile-view-attribute-value').textContent = attribute.value;
            });
        }
    });

    return TileView;
});
