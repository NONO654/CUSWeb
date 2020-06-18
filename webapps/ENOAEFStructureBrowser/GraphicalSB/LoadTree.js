/*jslint plusplus:true */
/*globals console*/

var swv6 = swv6 || {};
swv6.sample = swv6.sample || {};
swv6.sample.Action = swv6.sample.Action || {};


(function () {
    /**
	 * @class swv6.sample.Action.LoadTree
	 * @extends swv6.ui.Action.LoadTree TODO: description
	 */
    'use strict';
    var CLASS,
        BASE = swv6.ui.Action.LoadTree;

    CLASS =
        swv6.sample.Action.LoadTree =
        function (config) {
            CLASS.base.ctor.apply(this, arguments);
        };

    swv6.util.inherit(CLASS, BASE, {

        loadDataTree: function () {
            var tree = new swv6.data.Tree(),

            n, ns, i, child,
            addChild = function(parent, data) {
                return parent ? parent.addChild(data) : tree.setRoot(data);
            };

            var allrows = emxUICore.selectNodes(oXML, "/mxRoot/rows//r");
            var imageIds = [];
            for (i = 0; i < allrows.length; i++) {
                imageIds.push(allrows[i].getAttribute("id"));
            }
            var responseXML = emxUICore.getXMLDataPost("../common/emxFreezePaneGetData.jsp", getParams()+ "&rowIds=" + imageIds.join(":") + "&sbImages=ImageOnly");
            allrows = emxUICore.selectNodes(responseXML, "/mxRoot/rows//r");
            var imageMap= new Object();
            for (i = 0; i < allrows.length; i++) {
                var colNode = emxUICore.selectSingleNode(allrows[i], "c");
				colNode.setAttribute('GSBImgCol', 't');
                imageMap[allrows[i].getAttribute("id")] = colNode;
            }
            var rootRow = emxUICore.selectSingleNode(oXML, "/mxRoot/rows/r");
            rootRow.appendChild(imageMap[rootRow.getAttribute("id")]);
            ns = [addChild(null, { data: rootRow})];
            while (ns.length !== 0) {
                n = ns.shift();
                var expanded = n.data.getAttribute("expand");
                var filter = n.data.getAttribute("filter");
                var childRows = new Array();
                if ((!filter || filter == "false") && expanded == "true") {
                    childRows = emxUICore.selectNodes(n.data, "r");
                }
                if (childRows.length > 0) {
                    for (i = 0; i < childRows.length; i++) {
                        child = childRows[i];
                        child.appendChild(imageMap[child.getAttribute("id")]);
                        filter = child.getAttribute("filter");
                        if (!filter || filter == "false") {
                            ns.push(addChild(n, { data: child}));
                        }
                    }
                }
            }

            return tree;
        }

    });

}());
