define('DS/ENOXCollectionViewCommons/ReferenceView/ReferenceSmallTileView/js/ReferenceSmallSubtileView', [
    'DS/Handlebars/Handlebars',
    'DS/Controls/Abstract',
    'text!DS/ENOXCollectionViewCommons/ReferenceView/ReferenceSmallTileView/html/ReferenceSmallSubtileView.html',
    'css!DS/ENOXCollectionViewCommons/ReferenceView/ReferenceSmallTileView/css/ReferenceSmallSubtileView.css',
    'css!DS/UIKIT/UIKIT.css'
], function (Handlebars, ControlsAbstract, Template) {
    'use strict';

    var template = Handlebars.compile(Template);

    var ReferenceSmallSubtileView = ControlsAbstract.inherit({
        name: 'ReferenceSmallSubtileView',

        publishedProperties: {
            isSelected: 'boolean',
            name: 'string',
            effectivity: 'string',
            isLast: 'boolean'
        },

        _postBuildView: function (options) {
            var that = this;

            that._parent(options);

            /** Use template as boilerplate for creation of the tile */
            that.elements.container.setHTML(template());

            /** Encapsulate styles behind a CSS class */
            that.elements.container.addClassName('reference-small-subtile-view');
        },

        _applyIsSelected: function () {
            this.elements.container.getElement('.reference-small-subtile-view-checkbox').checked = this.isSelected;
        },

        _applyName: function () {
            this.elements.container.getElement('.reference-small-subtile-view-name').textContent = this.name;
        },

        _applyEffectivity: function () {
            this.elements.container.getElement('.reference-small-subtile-view-effectivity').textContent = 'Effectivity: ' + this.effectivity;
        },
        
        _applyIsLast: function () {
        	if (this.isLast) {
        		this.elements.container.classList.add('last-subtile');
        	} else {
        		this.elements.container.classList.remove('last-subtile');
        	}
        }
    });

    return ReferenceSmallSubtileView;
});
