define('DS/ENOLifecycleTreeView/ENOLifecyleNodeEdgeViewCreator', 
    [
        'DS/etree/tree', 
        'DS/egraph/utils', 
        'DS/egraph/views', 
        'DS/egraph/core',
    ],

    function(tree, utils, views, core) {

    'use strict';
    var exports={};

    /*A wrapper class around the NodeView constructor
        options={
        node_elem: Either a DOM selector or the node DOM element to be cloned
        onSetNodeData: Function to apply the data to fill nodes content
    }
    */

    exports.ENOLifecyleNodeViewCreator=function(options){

        var nodeTemplate=null;
        
        if (typeof options.node_elem ==='string'){
            
            nodeTemplate=templates.querySelector(options.node_elem);
        }
        else
        {
            nodeTemplate=options.node_elem;
        }

        var NodeView=function(){
             views.HTMLNodeView.call(this);
        }
        utils.inherit(NodeView, views.HTMLNodeView);

        NodeView.prototype.buildNodeElement = function buildNodeElement(n) {
            return nodeTemplate.cloneNode(true);
        };

        NodeView.prototype.onmodifyDisplay = function onmodifyDisplay(n, changes) {
            
            views.HTMLNodeView.prototype.onmodifyDisplay.apply(this, arguments);
            
            var elt = this.display.elt;
            
            if (core.inPathSet(changes, 'data', 'data', 'nodeData')) {
                elt.nodeData=n.data.data.nodeData;
                //code to set Node content
                options.onSetNodeData.call(elt, n.data.data.nodeData);
            }
			
        }

        return NodeView;
    }

    return exports;
});
