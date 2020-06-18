
    //directories
    var DIR_IMAGES = "../common/images/";

    //images
    var IMG_SPACER = DIR_IMAGES + "utilSpacer.gif";

    //strings
    var STR_LOADING = "Loading...";

    //local copy of the table
    var localTable = null;

    //local copy of the tree
    var localTree = null;

    //directories
    var DIR_TREE = DIR_IMAGES;
        
    //images
    var IMG_LOADING = DIR_TREE + "utilLoading.gif";

    //tree images defined here
    var IMG_LINE_VERT = DIR_TREE + "utilTreeLineVert.gif";
    var IMG_LINE_LAST = DIR_TREE + "utilTreeLineLast.gif";
    var IMG_LINE_LAST_OPEN = DIR_TREE + "utilTreeLineLastOpen.gif";
    var IMG_LINE_LAST_CLOSED = DIR_TREE + "utilTreeLineLastClosed.gif";
    var IMG_LINE_NODE = DIR_TREE + "utilTreeLineNode.gif";
    var IMG_LINE_NODE_OPEN = DIR_TREE + "utilTreeLineNodeOpen.gif";
    var IMG_LINE_NODE_CLOSED = DIR_TREE + "utilTreeLineNodeClosed.gif";

    // indent in pixels
    var NODE_INDENT = 19;

    //store the selected node
    var selectedNode = null;
    var selectedNodeBOId = null;

    //Baseline document object

    // note: Stylesheet is written inline because of netscape issues with external stylesheets in multiple frames
    function jsDocument() {
        this.text = new Array();        //array to store the string
        this.write = function (str) { this.text[this.text.length] = str; }
        this.writeln = function (str) { this.text[this.text.length] = str + "\n"; }
        this.toString = function () { return this.text.join(""); }

        this.writeHTMLHeader = function () {
            this.write("<html><head>");
            this.writeln("");
            this.writeln("<style type=text/css >");
            for (var i=0; i < jsStyles.length; i++) {
              this.writeln(jsStyles[i]);
            }
            this.writeln("</style>");
            this.writeln("");
            this.write("</head>");
        }
        this.writeBody = function (style) { this.writeln("<body" + (style ? " class=\"" + style + "\"" : "") + " >"); }
        this.writeHTMLFooter = function () { this.writeln("</body></html>"); }
    }



    function jsTable(tablewidth,numOfCols) {


        //the root node of the tree
        this.root = null;
        //heading
        this.heading = "";
        //scrolling information
        this.scrollX = 0;
        this.scrollY = 0;
        //map of all nodes in the tree
        this.nodes = new Array;
        //frame name
        this.treeFrame = "tableDisplay";
        //width
        this.width = tablewidth;
        //number of columns in table
        this.numOfCols = numOfCols;
        //methods

        this.draw = _jsTable_draw;

        this.drawChild = _jsTable_drawChild;
        
        this.refresh = _jsTable_refresh;
        this.createRoot = _jsTable_createRoot;
        this.toggleExpand = _jsTable_toggleExpand;
        
        //save local copy of the tree
        localTable = this;

    }


    function jsTree(relatedTable,backId,tableName,relName,expandToFrom, allRelationsFlag, header, suiteKey, defaultTableFlag, adminTableName, wsFilterName, popupFlag) 
    {

        //heading
        this.heading = "";

        // mxtable name used in rendering
        this.tableName = tableName;

        // mxrelationship name used in rendering
        this.relName = relName;

        //save bus obj id of obj to go back to. If id = 0, there is no back obj (first display of obj)
        this.backId = backId;

        //expand to and from
        this.expandToFrom = expandToFrom;
        this.allRelationsFlag = allRelationsFlag;
      
        //flag to indicate if the Navigator is opened in a pop up window
        this.popupWindowFlag = popupFlag;

        //set the related table for this tree
        this.table = relatedTable;
        this.defaultTableFlag = defaultTableFlag;
        this.adminTableName = adminTableName;

        this.wsFilterName = wsFilterName;

        //the root node of the tree
        this.root = null;

        //scrolling information
        this.scrollX = 0;
        this.scrollY = 0;

        //map of all nodes in the tree
        this.nodes = new Array;

        //frame name
        this.treeFrame = "treeDisplay";

        //header & suitekey info
        this.header = header;
        this.suiteKey = suiteKey;

        //declare the variables ..these gets set when the user sorts
        this.reSortKey = "Name";
        this.sortDirection = "ascending";

        //methods


        this.draw = _jsTree_draw;
        this.drawChild = _jsTree_drawChild;
        this.drawLoadingMessage = _jsTree_drawLoadingMessage;
        this.drawMiscImages = _jsTree_drawMiscImages;
        this.drawPlusMinusImage = _jsTree_drawPlusMinusImage;
        this.getScrollPosition = _jsTree_getScrollPosition;
        this.refresh = _jsTree_refresh;
        this.createRoot = _jsTree_createRoot;
        this.setScrollPosition = _jsTree_setScrollPosition;
        this.toggleExpand = _jsTree_toggleExpand;

        //Function to synchronize the data between the client & server
        this.updateServerData = _jsTree_updateServerData;

        //function to get the currently expanded nodes
        this.expandedNodes = _jsTree_expandedNodes;

        //save local copy of the tree
        localTree = this;
    }


    function _jsTree_draw() {

        //check for error
        if (this.root) {
            //create string holder
            var d = new jsDocument;
            //write the header
            d.writeHTMLHeader();
            d.write("<body >");
        //start tree table
          d.write("<table border=0 cellspacing=0 cellpadding=0>");
          //write top heading (all 1 cell)
          d.write(this.heading);

            //draw the root, which will recursively draw the tree
            this.drawChild(d, this.root);

          d.write("</table>");

            //write the footer
            d.writeHTMLFooter();
            //draw to the frame
            with (frames[this.treeFrame].document) {
                open();
                write(d);
                close();
            }
        } else {
        //No Root Specified
      }

      return;

    }


    function _jsTree_drawChild(d, node) {

        //check for no child objects found by testing relImage
        // if null, don't write link logic
        var children_found = true;

        if ((node.relImage == null) && (node.indent > 0)){
            children_found = false;
        }

        //begin table
        if (node.selected == true){
          d.write("<tr class=selected height=\"20\" >");
        }else{
          d.write("<tr height=\"20\">");
        }
        d.write(node.cueStyle);
        d.write("<td nowrap class='"+node.cueClass+"' title='"+node.objTip+"' alt='"+node.objTip+"'>&nbsp;");

        if (node.indent > 0) {
            //determine what needs to be added
            this.drawMiscImages(d, node);

            //get whether this node has children and if it's expanded or not
            this.drawPlusMinusImage(d, node);
        }

        //draw relationship arrow with link
        if (children_found){
            if (varViewRelArrows){
                if (node.indent > 0) {

                    //Open the details in a pop up window               
                    var nodeCueStyle = node.cueStyle.replace('#', 'h_a_s_h');
                    var pageURL = "";
                    if(varRelDetailsPage.indexOf("?")==-1)
                        pageURL =varRelDetailsPage + "?objectId=" + node.id + "&relId=" + node.relId;
                    else
                        pageURL =varRelDetailsPage + "&objectId=" + node.id + "&relId=" + node.relId;

                    
                    if(nodeCueStyle != ''){
                        nodeCueStyle = nodeCueStyle.replace('>', '$');
                        nodeCueStyle = nodeCueStyle.replace('>', '$');
                        nodeCueStyle = nodeCueStyle.replace('<', '@');
                        nodeCueStyle = nodeCueStyle.replace('<', '@');                  
                    }
                    var cuetip =  "&strCueClassName=" + node.cueClass + "&strCueClassStyle=" + nodeCueStyle;
                    while(cuetip.indexOf("'")!=-1){
                        cuetip = cuetip.replace('\'','');
                    }

                    while(cuetip.indexOf(" ")!=-1){
                        cuetip = cuetip.replace(' ','+');
                    }

                    if(nodeCueStyle != ''){
                        pageURL = pageURL + cuetip;             
                    }
                  d.write(node.relImage + "&nbsp;");
            
                }
            }
        }

        //set active row with javascript link and icon as image
        if (varViewIcons){
            //do not allow selection on the root node
            node.readAccess = true;
            if (children_found && node.nodeID != "root" && node.readAccess==true){
              d.write("<a href=\"javascript:parent.setActive('" + node.nodeID + "')\"");
              d.write("\">");
            }
            var sIconToolTip;
            
            if(node.objTip != ""){
                sIconToolTip = node.objTip;
            }else{
                sIconToolTip = varIconToolTip;
            }

            d.write("&nbsp;<img src=\"");
            
            d.write(node.icon);
                    
            d.write("\" border=\"0\" width=\"16\" height=\"16\" align=absmiddle alt=\"" +  sIconToolTip + "\">&nbsp;");

            if (children_found){
                d.write("</a>");
            }
        }



        //write TNR with href to details page
        if (children_found)
        {
            if( localTree.popupWindowFlag )
            {
                if(node.readAccess==true){
                var pageURL = varBusObjectDetailsPage + "?treeMenu=" + node.menuName + "&objectId=" + node.id ;
                d.write("&nbsp;<a href=javascript:parent.openModelessDialog(\"" + pageURL + "\") class='"+node.cueClass+"' title='"+node.objTip+"' alt='"+node.objTip+"'>");            
                }
                
            }
            else 
            {
                var pageURL = varBusObjectDetailsPage + "?treeMenu=" + node.menuName + "&objectId=" + node.id ;
                d.write("&nbsp;<a href=javascript:parent.openModelessDialog(\"" + pageURL + "\") class='"+node.cueClass+"' title='"+node.objTip+"' alt='"+node.objTip+"'>");            
            }
        }

        //TNR
        d.write(node.name);

        //close up link and table
        if (children_found){
            d.write("</a>");
        }



        d.writeln("</td></tr>");
        d.writeln("<tr><td class=line colspan=2><img src='../common/images/utilSpacer.gif' width=1 height=1></td></tr>");

        //fun part, draw your children!
        if (node.hasChildNodes && node.expanded) {
            if (node.loaded) {
                for (var i=0; i < node.childNodes.length; i++)
                    this.drawChild(d, node.childNodes[i]);
            } else {
                    getTopWindow().window.status = "LOADING...";
            }
        }

        return;

    }

    function _jsTree_drawMiscImages(d, node) {
        
        var str="", tempstr="";
        var cur = node, par = node.parent;
        var i=0;

        //no indent needed if root or top level
        if (node.indent < 2)
            return;

        //add spacers
        while (i < node.indent - 1) {

            //begin cell
            tempstr = "<img src=\"";

            if ((cur.isLast && par.isLast) || (!cur.isLast && par.isLast))
                tempstr += IMG_SPACER;
            else
                tempstr += IMG_LINE_VERT;
            tempstr += "\" width=\"19\" height=\"16\" border=\"0\"  align=absmiddle >&nbsp;"

            cur = par;
            par = par.parent;
            i++;

            str = tempstr + str;
        }

        d.write(str);

        return;

    }


    function _jsTree_drawPlusMinusImage(d, node) {
        
        var par = node.parent;          //pointer to parent
        //begin link
        if (node.hasChildNodes) {
            d.write("<a href=\"javascript:parent.syncFrames('");
            d.write(node.nodeID);
            d.write("')\" >");
        }

        //nasty part, figure out which graphic to use
        d.write("<img src=\"");

        //if this node is the last in the list
        if (node.isLast) {
            if (!node.hasChildNodes)
                d.write(IMG_LINE_LAST);
            else {
                if (node.expanded)
                    d.write(IMG_LINE_LAST_OPEN);
                else
                    d.write(IMG_LINE_LAST_CLOSED);
            }
        } else {
            if (!node.hasChildNodes)
                d.write(IMG_LINE_NODE);
            else {
                if (node.expanded)
                    d.write(IMG_LINE_NODE_OPEN);
                else
                    d.write(IMG_LINE_NODE_CLOSED);
            }
        }

        d.write("\" border=\"0\" width=\"19\" height=\"16\" name=\"node");
        d.write(node.nodeID);
        
        d.write("\"  align=absmiddle alt=\"" + varExpandToolTip + "\">&nbsp;");

        if (node.hasChildNodes)
            d.write("</a>");

        return;

    }



    function _jsTree_drawLoadingMessage(d, node) {

        d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");

        //determine what needs to be added
        this.drawMiscImages(d, node.indent + 2);

        //begin link
        d.write("<td nowrap><img src=\"");
        d.write(IMG_LOADING);
        d.write("\" border=\"0\" width=\"16\" height=\"16\"></td><td nowrap class=\"loading\">");
        d.write(STR_LOADING);
        d.write("</td></tr></table>");

        //spacer table
        d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td><img src=\"");
        d.write(IMG_SPACER);
        d.write("\" width=\"1\" height=\"3\" border=\"0\"></td></tr></table>");
        return;
    }

    //draw specified object (either indented tree or corresponding table)

    function _jsTable_refresh() 
    {
        table.draw();
        return;
    }

    function _jsTree_refresh() 
    {
        tree.draw();
        return;
    }

    //function to create root tree node
    function _jsTree_createRoot(strName,strIcon,strRelImage, strRelId, strId, strRootId,boolHasChildren,sCueStyleRoot,sCueClass,sObjTip , sMenuName) {

        //set the root
        this.root = new treeNode(strName,strIcon,strRelImage, strRelId, strId, strRootId,boolHasChildren);

        //make sure it's expanded
        this.root.expanded = true;

        //set the tree
        this.root.tree = this;

        //set ID
        this.root.nodeID = "root";
        this.nodes["root"] = this.root;

        //set as loaded
        this.root.loaded = true;

        this.root.cueStyle = sCueStyleRoot;
        this.root.cueClass = sCueClass;
        this.root.objTip = sObjTip;
        this.root.menuName = sMenuName;
    }


    function _jsTree_toggleExpand(strNodeID) {

        var node = this.nodes[strNodeID];
        //change the expansion
        node.expanded = !node.expanded;

        return;
    }

    //Function to synchronize the data between the client and server
    function _jsTree_updateServerData( strCurNodeID, strPreviousSelectionID)
    {
        //Update the server side data also
        var url = varToggleExpandPage + "?CurrentSelID="+ strCurNodeID +"&PreviousSelID=" + strPreviousSelectionID+ "&TimeStamp="+ varTimeStamp;
        frames["treeTableDataLoad"].document.location.href = url;

    }

    //Function to return the number of currently expanded nodes
    function _jsTree_expandedNodes( rootNodeName )
    {
        var rootNode = this.nodes[rootNodeName];
        
        if( !rootNode )
            return 0;

        var nodeID;
        var expandedNodes = rootNode.childNodes.length;

        //count the expanded childs too
        for(var i=0; i<expandedNodes; i++ )
        {
            nodeID = rootNodeName + "_" + i; //node will be with the name root_1 etc 
            var childNode = rootNode.childNodes[i];
            if( childNode && childNode.expanded)
                expandedNodes += childNode.expandedNodes( nodeID );
        }
        
        return  expandedNodes;
    }

    //Function to return the number of currently expanded nodes
    //this has to be different from the above as the same function can be reference from both the tree & tree node
    function _treeNode_expandedNodes( rootNodeName )
    {
        var nodeID;
        var expandedNodes = this.childNodes.length;

        //count the expanded childs too
        for(var i=0; i<expandedNodes; i++ )
        {
            nodeID = rootNodeName + "_" + i; //node will be with the name root_1 etc 
            var childNode = this.childNodes[i];
            if( childNode && childNode.expanded)
                expandedNodes += childNode.expandedNodes( nodeID );
        }

        return  expandedNodes;
    }


    function _jsTree_getScrollPosition() {
        if (document.layers) {
            this.scrollX = frames[this.treeFrame].pageXOffset;
            this.scrollY = frames[this.treeFrame].pageYOffset;
        } else if (document.all) {
            this.scrollX = frames[this.treeFrame].document.body.scrollLeft;
            this.scrollY = frames[this.treeFrame].document.body.scrollTop;
        }
        return;
    }



    function _jsTree_setScrollPosition() {
        frames[this.treeFrame].scrollTo(this.scrollX, this.scrollY);
        frames['tableDisplay'].scrollTo(this.scrollX, this.scrollY);
        return;
    }


    function treeNode (strName,strIcon,strRelImage, strRelId, strId, strRootId,boolHasChildren) {

        //properties
        this.name = strName;
        this.icon = strIcon;
        this.nodeID = "-1";
        this.isLast = false;
        this.id = strId;
        this.selected = false;

        if (boolHasChildren) {
            this.hasChildNodes = true;
            this.loaded = false
        } else {
            this.hasChildNodes = false;
            this.loaded = true;
        }

        //rel vars.
        this.relImage= strRelImage;
        this.relId = strRelId;

        //root info
        this.rootId = strRootId;

        this.childNodes = new Array;
        this.expanded = false;
        this.parent = null;
        this.indent = 0;
        this.tree = null;
        this.cueStyle = "";
        this.cueClass = "";
        this.objTip = "";
        this.readAccess=true;

        //methods
        this.addChild = _treeNode_addChild;
        //function to return child count
        this.expandedNodes = _treeNode_expandedNodes;

    }

    function _treeNode_addChild(strName,strIcon,strRelImage, strRelId, strId, strRootId,boolHasChildren, sCueStyle, sCueClass, sObjTip , sMenuName,readAccess ) {


        //create the new node
        var node = new treeNode(strName,strIcon,strRelImage, strRelId, strId, strRootId,boolHasChildren);

        node.cueStyle = sCueStyle;
        node.cueClass = sCueClass;
        node.objTip = sObjTip;
        node.readAccess=readAccess;

        node.menuName = sMenuName;

        //add the child to the array
        this.childNodes[this.childNodes.length] = node;

        //set hasChildNodes flag
        this.hasChildNodes = true;

        //set the parent
        node.parent = this;

        //assign the tree
        node.tree = this.tree;

        //change the last info
        node.isLast = true;

        if (this.childNodes.length > 1)
            this.childNodes[this.childNodes.length - 2].isLast = false;

        //set the indent
        node.indent = this.indent + 1;

        //assign ID
        node.nodeID = (this.nodeID == "-1" ? "" : this.nodeID + "_")  + String(this.childNodes.length - 1);

        //place into node map
        if (strId)
            this.tree.nodes[strId] = node;
        this.tree.nodes[node.nodeID] = node;
        this.tree.nodes[strName] = node;

        return node;
    }



    function _jsTable_addChild(strName, strURL, strTarget, strIcon, strExpandURL, strID) {

        //create the new node
        var node = new tableNode(strName, strURL, strTarget, strIcon, strExpandURL, strID);
        //add the child to the array
        this.childNodes[this.childNodes.length] = node;
        //set hasChildNodes flag
        this.hasChildNodes = true;
        //set the parent
        node.parent = this;
        //assign the tree
        node.tree = this.tree;
        //change the last info
        node.isLast = true;
        if (this.childNodes.length > 1)
            this.childNodes[this.childNodes.length - 2].isLast = false;
        //set the indent
        node.indent = this.indent + 1;
        //assign ID
        node.nodeID = (this.nodeID == "-1" ? "" : this.nodeID + "_")  + String(this.childNodes.length - 1);
        //place into node map
        if (strID)
            this.tree.nodes[strID] = node;
        this.tree.nodes[node.nodeID] = node;
        this.tree.nodes[strName] = node;
        return node;
    }



    function tableNode (strName, strID, strRootId,boolHasChildren) {

        //properties
        this.name = strName;
        this.nodeID = "-1";
        this.isLast = false;
        this.id = strID;

        if (boolHasChildren) {
            this.hasChildNodes = true;
            this.loaded = false
        } else {
            this.hasChildNodes = false;
            this.loaded = true;
        }

        this.rootId = strRootId;
        this.selected = false;

        this.childNodes = new Array;
        this.expanded = false;
        this.parent = null;
        this.indent = 0;
        this.tree = null;

        //methods
        this.addChild = _jsTable_addChild;

    }


    function _jsTable_createRoot(strName, strID, strRootId, boolHasChildren) {
        //set the root
        this.root = new tableNode(strName, strID, strRootId,boolHasChildren);
        //make sure it's expanded
        this.root.expanded = true;
        //set the tree
        this.root.tree = this;
        //set ID
        this.root.nodeID = "root";
        this.nodes["root"] = this.root;

        //set as loaded
        this.root.loaded = true;

    }


    function _jsTable_toggleExpand(strNodeID) {
        //get the node
        var node = this.nodes[strNodeID];
        //change the expansion
        node.expanded = !node.expanded;
        return;
    }


    function _jsTable_drawChild(d, node) {

        //begin table
        if (node.selected == true){
          d.write("<tr height=\"20\" class=selected >");
        }else{
          d.write("<tr height=\"20\">");
        }

        //node.name has complete formatting including <td> tags
    /*
        while(node.name.indexOf("v_a_l_q_u_o_t_e")!=-1){
            node.name = node.name.replace('v_a_l_q_u_o_t_e','\\\"');
        }
        
        while(node.name.indexOf("v_a_l_a_p_o_s")!=-1){
            node.name = node.name.replace('v_a_l_a_p_o_s','\'');
        }
        while(node.name.indexOf("v_a_l_f_o_r_s_l_a_s_h")!=-1){
            node.name = node.name.replace('v_a_l_f_o_r_s_l_a_s_h','\\\\');
        }
    */
        d.write(node.name);


        //close up link and table
        d.writeln("</tr>");

        //small lines under table rows
        d.writeln("<tr><td class=line colspan=" + (localTable.numOfCols + 3) + " ><img src='../common/images/utilSpacer.gif' width=1 height=1></td></tr>");


        //fun part, draw your children!
        if (node.hasChildNodes && node.expanded) {
            if (node.loaded) {
                for (var i=0; i < node.childNodes.length; i++)
                    this.drawChild(d, node.childNodes[i]);
            } else {
                    getTopWindow().window.status = "LOADING...";
            }
        }

        return;
    }



    function _jsTable_draw() {
        //check for error
        if (this.root) 
        {
            //create string holder
            var d = new jsDocument;

            //write the header
            d.writeHTMLHeader();

            d.write("<body leftmargin=0 marginwidth=0 >");
            d.write("<form name=\"emxNavigatorTableForm\" method=\"post\">");
            d.write("<table cellpadding=0 cellspacing=0 border=0 >");
            d.write("<tr>" + this.heading + "</tr>");
            //draw the root, which will recursively draw the tree
            this.drawChild(d, this.root);
            d.write("</table>");
            d.write("<div id=\"tooltip\" style=\"position:absolute;visibility:hidden;border:1px solid black;font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt;\" ></div>");
            //write the footer
            d.write("</form>");
            d.write("</body></html>");

            //draw to the frame
            with (frames[this.treeFrame].document) {
                open();
                write(d);
                close();
            }
        } else 
        {
            //No Root Specified
        }
        return;
    }


    // set the heading to be written out for table or tree
    function setHeading(str,obj){
      obj.heading = str;
      return;
    }


    function clickPlusMinus(nodeID) {
        //save the current scroll position
        localTree.getScrollPosition();

        //mark as selected
        var treeNode = localTree.nodes[nodeID];
        var tableNode = localTable.nodes[nodeID];
        treeNode.selected = true;
        tableNode.selected = true;
        if (selectedNode){
            if (selectedNode != nodeID){
                //toggle selectedNode to false
                localTree.nodes[selectedNode].selected = false;
                localTable.nodes[selectedNode].selected = false;
            }
        }

        //Update the server side data
        var previousSelNode = selectedNode;
        //localTree.updateServerData(nodeID, previousSelNode);

        //set selectedNode
        selectedNode = nodeID;
        selectedNodeBOId = treeNode.id;

        //before proceeding with forwarding to the jsp ...check the number of expanded nodes
        //we need this while expanding only ..not while collapsing
        var expandedNodes = 0;
        if (! treeNode.expanded ) 
        {
            expandedNodes = localTree.expandedNodes("root");
        }

        //expand the given node
        localTree.toggleExpand(nodeID);
        localTable.toggleExpand(nodeID);
         // #load children
        treeNode.loaded = false;

        if(!treeNode.expanded) {
            treeNode.childNodes = new Array;
            if(tableNode.childNodes != null) {
                tableNode.childNodes = new Array;
            }
            
      }
        //check to see if data has to be loaded
        if (treeNode.hasChildNodes && treeNode.expanded && !treeNode.loaded) {
            
            var strURL = varLoadChildrenPage + "&jsTreeID=" + nodeID + "&objectId=" + treeNode.id + "&rootId=" + localTree.root.id + "&WSTable=" + localTree.tableName + "&RelationshipName=" + localTree.relName + "&toFrom="+ localTree.expandToFrom  + "&AllRelations="+ localTree.allRelationsFlag+ "&TimeStamp="+ varTimeStamp;
            strURL += "&PageRowCount=" + expandedNodes + "&header=" + localTree.header+ "&suiteKey=" + localTree.suiteKey + "&IsDefaultTable=" + localTree.defaultTableFlag + "&table=" + localTree.adminTableName + "&WSFilter=" + localTree.wsFilterName;
            strURL += "&reSortKey=" + localTree.reSortKey + "&sortDirection=" + localTree.sortDirection;
            frames[localTree.treeFrame].document.location.href = strURL;
        }else{
        
            var strURL1 = varLoadChildrenPage + "&jsTreeID=" + nodeID + "&objectId=" + treeNode.id + "&rootId=" + localTree.root.id + "&WSTable=" + localTree.tableName + "&RelationshipName=" + localTree.relName + "&toFrom="+ localTree.expandToFrom  + "&AllRelations="+ localTree.allRelationsFlag+ "&TimeStamp="+ varTimeStamp;
            strURL += "&PageRowCount=" + expandedNodes + "&header=" + localTree.header+ "&suiteKey=" + localTree.suiteKey + "&IsDefaultTable=" + localTree.defaultTableFlag + "&table=" + localTree.adminTableName + "&WSFilter=" + localTree.wsFilterName;
            strURL += "&reSortKey=" + localTree.reSortKey + "&sortDirection=" + localTree.sortDirection;
            frames[localTree.treeFrame].document.location.href = strURL1;
        
            //refresh the screen
            //localTree.refresh();
            //localTable.refresh();
        }
        return;
    }


    function hideAlt(){
        if (document.layers){
            var doc = window.frames[2].document;
            doc.tooltip.visibility="hidden";
        }
        return;
    }

    function syncFrames(nodeId){
        clickPlusMinus(nodeId);
        return;
    }

    function setActive(strNodeId){
        tree.nodes[strNodeId].selected = true;
        table.nodes[strNodeId].selected = true;

        //check if selectedNode exists
        if (selectedNode){
            if (selectedNode != strNodeId){
              tree.nodes[selectedNode].selected = false;
              table.nodes[selectedNode].selected = false;
          }
        }
        //if not the same, update display and refresh
        if (selectedNode != strNodeId){
            selectedNode = strNodeId;
            selectedNodeBOId = tree.nodes[strNodeId].id;

            tree.getScrollPosition();
            tree.refresh();
            table.refresh();
            tree.setScrollPosition();
        }

        return;
    }

    function showAlt(th,e,text){
        if (text != 'none')
        {
            var doc = window.frames[2].document;
            if (document.layers )
            {
                doc.tooltip.document.write('<layer bgColor="#ffffc0" style="border:1px solid black;font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt;color:#00000"><font face=arial size=2>'+text+'</font></layer>');
                doc.tooltip.document.close();
                doc.tooltip.left=e.pageX+5;
                doc.tooltip.top=e.pageY+5;
                doc.tooltip.visibility="show";
            }
        }
        return;
    }

    function scrollCheck() {
        if (document.all){
            when = this.setTimeout('scrollCheck()',500);
            if( frames['tableDisplay'] && frames['tableDisplay'] && frames['treeDisplay'].document.body)
            frames['tableDisplay'].scrollTo(frames['tableDisplay'].document.body.scrollLeft,frames['treeDisplay'].document.body.scrollTop);
        }
        else{
            when = this.setTimeout('scrollCheck()',500);
            if( frames['tableDisplay'] && frames['tableDisplay'] )
                frames['tableDisplay'].scrollTo(frames['tableDisplay'].pageXOffset,frames['treeDisplay'].pageYOffset);
        }
        return;
    }


    //Function to show busy mouse cursor
    function setMousePointer() 
    { 
        if (document.all) 
            for (var i=0;i < document.all.length; i++) 
                document.all(i).style.cursor = 'wait'; 
    } 

    //Function to show normal mouse cursor
    function resetMousePointer() 
    { 
        if (document.all) 
            for (var i=0;i < document.all.length; i++) 
                document.all(i).style.cursor = 'default'; 
    }

    //function to open the pop up dialogs for relation ship details & object details
    function openModelessDialog( varURL )
    {
        window.open( varURL,'','toolbar=no,status=no,scrollbars=yes, resizable=yes,location=no,menubar=no,directories=no,width=700,height=500');
    }
