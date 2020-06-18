define('DS/ENOLifecycleConceptExplorer/data/DebugTreeData',[],function()
{
var treeJson =
{
  "settings" : {"format" : "1", "refresh" : "full", "direction": "south", "treetype": "balanced", "path" : "./assets/icons", "error":
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque at sagittis eros. Vivamus semper vel sapien vitae viverra. Maecenas fringilla ligula sed vestibulum hendrerit. Vivamus.",
"readonly":"false"},
  "nodes" :
  [
    { "id":"1", "on" : "y", "name" : "ProductA1234567890", "imageurl" : "SWXabc.png", "rmbmenu":"2", "type":"nonleaf",  "desc" : "This is product A", "createdby":"Shrikanth Ananthakrishnan", "createddate":"1421440429"},
    { "id": "2", "on": "y", "name": "ProductB123456789012364528", "imageurl": "SWXabc.png", "rmbmenu": "2", "type": "nonleaf", "desc": "This is product B", "createdby": "Shrikanth Ananthakrishnan", "createddate": "1421440429", "status": "deleted"},
    { "id":"3", "on" : "y", "name" : "ProductC", "imageurl" : "SWXabc.png", "rmbmenu":"1", "type":"leaf", "desc" : "This is product C that was created by james on tuesday for demoing to the external customer and the VP of our company", "createdby":"Shrikanth Ananthakrishnan", "createddate":"1421440429"},
    { "id":"4", "on" : "y", "name" : "ProductD", "imageurl" : "SWXabc.png", "rmbmenu":"1", "type":"leaf", "desc" : "This is product D", "createdby":"Shrikanth Ananthakrishnan", "createddate":"1421440429"}
  ],
  "connections" :
  [
    { "id":"1", "on" : "y", "src" : "1", "trg" : "2", "type":"iteration"},
    { "id":"2", "on" : "y", "src" : "1", "trg" : "3", "type":"variant"},
    { "id":"3", "on" : "y", "src" : "2", "trg" : "4", "type":"iteration"}
  ],
  "rmbmenuitems" : 
  [
    {
      "id": "0",
      "text": "Separator",
      "icon": "SWXUiPDMViewReadOnly.png"
    },
    {
      "id": "1",
      "text": "View (Read-only)",
      "icon": "SWXUiPDMViewReadOnly.png",
      "externalcommand": "no",
      "maxnodes":"1"
    },
    {
      "id": "2",
      "text": "Create Concept Branch",
      "icon": "SWXUiPDMCreateBranch.png",
      "externalcommand": "no",
      "maxnodes":"1"
    },
    {
      "id": "3",
      "text": "Comments",
      "icon": "SWXUiPDMAddViewComment.png",
      "externalcommand": "no",
      "maxnodes":"1"
    },
    {
      "id": "4",
      "text": "All Comments",
      "icon": "SWXUiPDMAddViewComment.png",
      "externalcommand": "no",
      "maxnodes":"1"
    },
    {
      "id": "5",
      "text": "Create Concept Point",
      "icon": "SWXUiPDMCreateDesignPoint.png",
      "externalcommand": "no",
      "maxnodes":"1"
    },
    {
      "id": "6",
      "text": "Open",
      "icon": "SWXUiPDMViewReadOnly.png",
      "externalcommand": "no",
      "maxnodes":"1"
    },
    {
      "id": "7",
      "text": "Properties",
      "icon": "ENOLifecycleConceptExplorerNodeProperties.png",
      "externalcommand": "no",
      "maxnodes":"1",
    },
    {
      "id": "1008",
      "text": "MergeFeatures",
      "icon": "assets/icons/SWXUiMerge.png",
      "externalcommand": "yes",
      "maxnodes":"1",
      "uniqueid":"abc123"
    }

  ],
  "rmbmenu" :
  [
    {
     "id": "1",
      "rmbitems": [
        {
          "item": "8"
        },
        {
          "item": "2"
        },
        {
          "item": "5"
        },
        {
          "item": "0"
        },
        {
          "item": "3"
        },
        {
          "item": "1008"
        }
      ]
    },
    {
      "id": "2",
      "rmbitems": [
        {
          "item": "1"
        },
        {
          "item": "2"
        },
        {
          "item": "0"
        },
        {
          "item": "7"
        },
        {
          "item": "3"
        },
        {
          "item": "1008"
        }
      ]
    }
  ],
  "people" :
  [
    { "id":"1", "on" : "y", "login" : "c1i", "name" : "Christopher Ryan", "image" : "SWXc1i.png"},
    { "id":"2", "on" : "y", "login" : "yxf", "name" : "Neal Appel",       "image" : "SWXyxf.png"}
  ],
  "comments" :
  [
    { "id":"1", "on" : "y", "who" : "1", "when" : "1421440429", "node" : "1", "text" : "Is this OK?"},
    { "id":"2", "on" : "y", "who" : "2", "when" : "1421440429", "node" : "1", "text" : "Could be better. But i have to pu in a really long comment to test for the the paragraph and line breaks on the comments table."},
    { "id":"3", "on" : "y", "who" : "2", "when" : "1421440429", "node" : "3", "text" : "This is the best design"}, 
    { "id":"4", "on" : "y", "who" : "2", "when" : "1421440429", "node" : "1", "text" : "Could be better. But i have to pu in a really long comment to test for the the paragraph and line breaks on the comments table."},
    { "id":"5", "on" : "y", "who" : "2", "when" : "1421440429", "node" : "1", "text" : "Could be better. But i have to pu in a really long comment to test for the the paragraph and line breaks on the comments table."},
    { "id":"6", "on" : "y", "who" : "2", "when" : "1421440429", "node" : "1", "text" : "Could be better. But i have to pu in a really long comment to test for the the paragraph and line breaks on the comments table."},
    { "id":"7", "on" : "y", "who" : "2", "when" : "1421440429", "node" : "1", "text" : "Could be better. But i have to pu in a really long comment to test for the the paragraph and line breaks on the comments table."},
    { "id":"8", "on" : "y", "who" : "2", "when" : "1421440429", "node" : "1", "text" : "Could be better. But i have to pu in a really long comment to test for the the paragraph and line breaks on the comments table."},
    { "id": "9", "on": "y", "who": "2", "when": "1421440429", "node": "1", "text": "Could be better. But i have to pu in a really long comment to test for the the paragraph and line breaks on the comments table." },
    { "id": "10", "on": "y", "who": "2", "when": "1421440429", "node": "2", "text": "This is the best design" }
  ], 
  "nodeproperties" :
  [
    { "id":"1", "productid":"0000031", "repid":"000032", "reptime":"20141105110000", "vault":"iteration" },
    { "id":"2", "productid":"0000033", "repid":"000034", "reptime":"20141105120000", "vault":"normal" },
    { "id":"3", "productid":"0000035", "repid":"000036", "reptime":"20141105130000", "vault":"normal" } 
  ]
};
return treeJson;
}
);
