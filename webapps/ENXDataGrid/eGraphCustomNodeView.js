/**
 * @exports etree/syncviews
 *
 * @see module:etree
 *
 * @return {undefined}
 */
define('DS/ENXDataGrid/eGraphCustomNodeView', ['DS/egraph/utils', 'DS/egraph/views', 'DS/egraph/core', 'DS/etree/tree', 'DS/Utilities/Dom'],
  function (utils, views, core, tree, Dom) {
    'use strict';

    var exports = {};

    /* DOM templates */

    // Don't put draggable' on 'etree-sync-node-widget', it doesn't work correctly in Firefox

    var templates = document.createElement('div');
    templates.innerHTML = [
      '<div class="etree-sync-node">',
      '  <div class="etree-sync-node-widget">',
      '    <div class="etree-sync-node-color"></div>',
      '    <div class="etree-sync-node-thumbnail"></div>',
      '		<div class="etree-sync-customnode-caption">',
      '			<div class="caption-titlebar">',
      '		    	<div class="caption-type-icon"></div>',
      '		    	<a class="caption-title-link" target="content">',
      '					<div class="caption-title"></div>',
      '				</a>',
      '			</div>',
      '		<a class="caption-colInfo2-link" target="content">',
      '			<div class="caption-colInfo2"></div>',
      '		</a>',
      '		<a class="caption-colInfo3-link" target="content">',
      '			<div class="caption-colInfo3"></div>',
      '		</a>',
      '	   </div>',
      '  </div>',
      '  <div class="etree-sync-node-collapse-expand" data-egraph-subelt="collapse-expand">',
      '    <div class="etree-sync-node-collapse-expand-spinner"></div>',
      '  </div>',
      '</div>',
      '<div class="etree-sync-temp-node">',
      '</div>',
      '<div class="etree-sync-group">',
      '</div>'
    ].join('\n');

    var nodeTemplate = templates.querySelector('.etree-sync-node');
    var tempNodeTemplate = templates.querySelector('.etree-sync-temp-node');
    var groupTemplate = templates.querySelector('.etree-sync-group');

    /* GroupView */

    var GroupView = function GroupView() {
      views.HTMLNodeView.call(this);
    };
    utils.inherit(GroupView, views.HTMLNodeView);

    GroupView.prototype.buildNodeElement = function buildNodeElement() {
      return groupTemplate.cloneNode(true);
    };

    /* NodeView */

    var NodeView = function NodeView() {
      views.HTMLNodeView.call(this);
    };
    utils.inherit(NodeView, views.HTMLNodeView);

    NodeView.prototype.buildNodeElement = function buildNodeElement() {
    	var node = nodeTemplate.cloneNode(true);
    	node.addEventListener("mouseover", function(nodeTemplate){
    		this.firstElementChild.lastElementChild.className = 'etree-sync-customnode-caption onmouseover';
        });
    	
    	node.addEventListener("mouseout", function(nodeTemplate){
    		this.firstElementChild.lastElementChild.className = 'etree-sync-customnode-caption';
	    });
    	
    	
    	node.firstElementChild.lastElementChild.firstElementChild.lastElementChild.addEventListener("onmousedown",function(){
    		e.preventDefault();
    		console.log("click fired");
    	});
    	
      return node;
    };

    NodeView.prototype.onmodifyDisplay = function onmodifyDisplay(n, changes) {
      var elt, subelt, cl, thumb;

      views.HTMLNodeView.prototype.onmodifyDisplay.apply(this, arguments);

      elt = this.display.elt;

      if (core.inPathSet(changes, 'data', 'data', 'options', 'isBeingCut')) {
        if (n.data.data.options.isBeingCut) {
          elt.classList.add('is-being-cut');
        } else {
          elt.classList.remove('is-being-cut');
        }
      }

      if (core.inPathSet(changes, 'data', 'data', 'options', 'icons')) {
          subelt = elt.querySelector('.caption-type-icon');
          //subelt.classList.remove('hidden');
          //Clean all old classes to remove font-icon added classes
          subelt.className = '';
          subelt.classList.add('caption-type-icon');

          if (n.data.data.options.icons && n.data.data.options.icons.length > 0) {
              Dom.generateIcon(n.data.data.options.icons[0], { target: subelt });
          } else {
              subelt.classList.add('hidden');
          }
      }

      if (core.inPathSet(changes, 'data', 'data', 'options', 'color')) {
        subelt = elt.querySelector('.etree-sync-node-color');
        if (n.data.data.options.color) {
          elt.classList.add('colorized');
          subelt.style.backgroundColor = n.data.data.options.color;
        } else {
          elt.classList.remove('colorized');
        }
      }

     if (core.inPathSet(changes, 'data', 'data', 'options', 'egraph_colInfo1')) {
    	 var colInfo1 = "";
    	 if(n.data.data.options.egraph_colInfo1 != undefined){
    		var tempcolInfo1 = n.data.data.options.egraph_colInfo1.split(":");
	        colInfo1 = tempcolInfo1[0];
	        var alternText = n.data.data.options.alternText;
	        subelt = elt.querySelector('.caption-title');
	        if (colInfo1 && typeof colInfo1 !== 'object') {
	          subelt.textContent = colInfo1;
	        } else if (alternText) {
	          subelt.textContent = alternText;
	        }
	        
	        if(tempcolInfo1.length > 1){
	        	var href = tempcolInfo1[1];
	            var link = elt.querySelector('.caption-title-link');
	             if (href && typeof href !== 'object') {
	               link.href = href;
	             } 
	        }
    	 }
        
		// IR-508665
        elt.querySelector('.etree-sync-node-widget').setAttribute('title', colInfo1);
	}
     
     if (core.inPathSet(changes, 'data', 'data', 'options', 'egraph_colInfo2')) {
    	 if(n.data.data.options.egraph_colInfo2 != undefined){
	   	  	 var tempcolInfo2 = n.data.data.options.egraph_colInfo2.split(":");
	         var colInfo2 = tempcolInfo2[0];
	         subelt = elt.querySelector('.caption-colInfo2');
	         if (colInfo2 && typeof colInfo2 !== 'object') {
	           subelt.textContent = colInfo2;
	         } 
	         
	         if(tempcolInfo2.length > 1){
	        	 var href = tempcolInfo2[1];
	        	 var link = elt.querySelector('.caption-colInfo2-link');
	             if (href && typeof href !== 'object') {
	                 link.href = href;
	               } 
	         }
    	 }
 	}
     
    if (core.inPathSet(changes, 'data', 'data', 'options', 'egraph_colInfo3')) {
    	if(n.data.data.options.egraph_colInfo3 != undefined){
	    	 var tempcolInfo3 = n.data.data.options.egraph_colInfo3.split(":");
	         var colInfo3 = tempcolInfo3[0];
	         subelt = elt.querySelector('.caption-colInfo3');
	         if (colInfo3 && typeof colInfo3 !== 'object') {
	           subelt.textContent = colInfo3;
	         } 
	         
	         if(tempcolInfo3.length > 1){
	        	 var href = tempcolInfo3[1];
	        	 var link = elt.querySelector('.caption-colInfo3-link');
	             if (href && typeof href !== 'object') {
	                 link.href = href;
	               } 
	         }
    	}
 	}
     
     if (core.inPathSet(changes, 'data', 'data', 'options', 'href')) {
         var href = n.data.data.options.href;
         subelt = elt.querySelector('.caption-title-link');
         if (href && typeof href !== 'object') {
           subelt.href = label;
         } 
 	}
      
     
      
     /* if (core.inPathSet(changes, 'data', 'data', 'options', 'showMoreInfo')) {
        subelt = elt.querySelector('.etree-sync-node-moreinfo');
        subelt.classList.remove('hidden');
        if (n.data.data.options.showMoreInfo === false) {
          subelt.classList.add('hidden');
        }
      }*/

      if (core.inPathSet(changes, 'data', 'data', 'options', 'thumbnail')) {
        subelt = elt.querySelector('.etree-sync-node-thumbnail');
        thumb = n.data.data.options.thumbnail;
        if (!thumb) {
          thumb = '../ENXDataGrid/assets/icon120x80ImageNotFound.png';
        }
        subelt.style.backgroundImage = 'url("' + thumb + '")';
      }

      if (core.inPathSet(changes, 'data', 'displayFlags')) {
        if (n.data.displayFlags & tree.DisplayFlags.DRAGGED) {
          elt.classList.add('dragged');
        } else {
          elt.classList.remove('dragged');
        }

        if (n.data.displayFlags & tree.DisplayFlags.DRAG_NODE) {
          elt.classList.add('drag-node');
        } else {
          elt.classList.remove('drag-node');
        }
      }

      if (core.inPathSet(changes, 'data', 'data', '_isHighlighted') ||
        core.inPathSet(changes, 'data', 'data', '_isSelected')) {
        if (n.data.data._isHighlighted || n.data.data._isSelected) {
          elt.classList.add('highlighted');
        } else {
          elt.classList.remove('highlighted');
        }
      }

      if (core.inPathSet(changes, 'data', 'data', '_isMatchingSearch')) {
        if (n.data.data._isMatchingSearch) {
          elt.classList.add('matching-search');
        } else {
          elt.classList.remove('matching-search');
        }
      }

      if (core.inPathSet(changes, 'data', 'data', '_expandState')) {
          cl = elt.querySelector('.etree-sync-node-collapse-expand').classList;
          cl.remove('expanded');
          cl.remove('collapsed');
          cl.remove('expanding');
          cl.remove('partiallyExpanded');
          cl.remove('hidden');
          switch (n.data.data._expandState) {
            case 'collapseState':
              cl.add('expanded');
              break;
            case 'expandingState':
              cl.add('expanding');
              break;
            case 'expandState':
              cl.add('collapsed');
              break;
            case 'partiallyExpandedState':
              cl.add('partiallyExpanded');
              break;
            default:
              cl.add('hidden');
              break;
          }
        }

      
      if (core.inPathSet(changes, 'data', '*drawingModifiers*') && n.data.document) { // n.data.document is null for the clone node used for dragging
        elt.classList.remove('root-on-left');
        elt.classList.remove('root-on-right');
        elt.classList.remove('root-on-bottom');
        if (n.data.document.drawingModifiers & tree.DrawingModifiers.HORIZONTAL) {
          if (n.data.document.drawingModifiers & tree.DrawingModifiers.MIRROR_DEPTH) {
            elt.classList.add('root-on-right');
          } else {
            elt.classList.add('root-on-left');
          }
        } else if (n.data.document.drawingModifiers & tree.DrawingModifiers.MIRROR_DEPTH) {
          elt.classList.add('root-on-bottom');
        }
      }

      // change vertical collapser content depending on the height value
      if (core.inPathSet(changes, 'data', 'height')) {
        if (isNaN(n.data.height)) {
          elt.classList.remove('v-collapsed');
        } else {
          elt.classList.add('v-collapsed');
        }
      }
    };

    /* EdgeView */

    var EdgeView = function EdgeView() {
      return new views.SVGEdgeView('etree-sync-edge');
    };

    /* TempNodeView */

    var TempNodeView = function TempNodeView() {
      views.HTMLNodeView.call(this);
    };
    utils.inherit(TempNodeView, views.HTMLNodeView);

    TempNodeView.prototype.buildNodeElement = function buildNodeElement() {
      return tempNodeTemplate.cloneNode(true);
    };

    /* TempEdgeView */

    var TempEdgeView = function TempEdgeView() {
      return new views.SVGEdgeView('etree-sync-temp-edge');
    };

    /* exports */

    exports.newNodeView = function newNodeView() {
      return new NodeView();
    };
    exports.newEdgeView = function newEdgeView() {
      return new EdgeView();
    };
    exports.newGroupView = function newGroupView() {
      return new GroupView();
    };
    exports.newTempNodeView = function newTempNodeView() {
      return new TempNodeView();
    };
    exports.newTempEdgeView = function newTempEdgeView() {
      return new TempEdgeView();
    };
    exports.newTempGroupView = function newTempEdgeView() {
      return new TempNodeView();
    };

    return exports;
  });

// For compatibility with previous names of require modules at Dassaut, i.e. without the DS/ prefix
define('ENXDataGrid/eGraphCustomNodeView', ['DS/ENXDataGrid/eGraphCustomNodeView'], function mod(m) {
  return m;
});
