define('DS/SMATestDataExplorerApp/SMATestDataExplorerPanel',
   ['UWA/Core',
    'UWA/Controls/Abstract',
    'DS/Controls/ProgressBar',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerSkeleton',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerSession',
    'DS/SMATestDataExplorerApp/SMATestDataExplorerMessage',
    'i18n!DS/SMATestDataExplorerApp/assets/nls/SMATestDataExplorerLabels'
   ],
function ( UWA, Abstract, WUXProgress, TestDataSkeleton, TestDataSession, TestDataMessage, i18n) {

    'use strict';

    var TestDataPanel = Abstract.extend({
        init: function( options ) {
            this._parent( options );
            this._buildPanel();
        },

     // DEBUG
 	   destroy: function() {
 	   },

        _buildPanel: function() {
            this.elements.container = UWA.createElement( 'div', {
                id: 'testDataPanel',
                'class': 'tde-panel',
                styles: {
                    'padding': 	'2px',
                    'position': 'absolute',
                    'top': 		'2px',
                    'bottom': 	'5px',
                    'left': 	'5px',
                    'right': 	'5px'
                }
            });

            this.buildSkeleton();
            this.onResize();
            
             TestDataMessage.init();
       		 var spinner = new WUXProgress( { shape: 'circular', statusFlag: false, infiniteFlag: true } );
             var spinnerContent = spinner.getContent();
             spinnerContent.classList.add( 'tde-spinner' );
             this.elements.container.appendChild( spinnerContent );
             TestDataSession.set( 'spinner', spinnerContent );
        },
        
        buildSkeleton: function() {
            var self = this;
            this.skeletonContainer = UWA.createElement( 'div', {
            	'class':'tde-skeleton',
                styles: {
                    'position': 		'absolute',
                	'height': 			'100%',
                    'width':  			'100%',
                    'background-color': 'white'
                }
            }).inject( this.elements.container );

            this._skeleton = new TestDataSkeleton( { panel: self } );
            this.skeletonContainer.setContent( this._skeleton.render() );
            this._skeleton.getContent().getParent().show();
            self.elements.container.show();
        },

        getSkeleton: function() {
            return this._skeleton;
        },

        onCancel: function() {
        },

        onImport: function() {
        },

        onSelect: function() {
            var self = this;            
            var skeleton = self.getSkeleton();
        },

        onEdit: function() {
            var skeleton = this.getSkeleton();
            var facet = skeleton.getCurrentPanelIndex();
            if( facet > 0 ) {
                var view = skeleton.getViewAt( facet );
                if( UWA.typeOf( view.onEdit) === 'function' ) {
                    view.onEdit();
                }
            }
        },

        onResize: function() {
            var skeleton = this.getSkeleton();
            var facet = skeleton.getCurrentPanelIndex();
            if( facet > 0 ) {
                var view = skeleton.getViewAt( facet );
                if( view && UWA.typeOf( view.resize ) === 'function' ) {
                    view.resize();
                }
            }
        }
    });

    return TestDataPanel;
});
