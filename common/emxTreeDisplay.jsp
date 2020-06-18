<%--  emxTreeDisplay.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<!DOCTYPE html>

<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="matrix.db.MQLCommand"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="emxTreeObject" class="com.matrixone.apps.framework.ui.UIMenu" scope="request"/>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>


<%
String stringResFileId="emxFrameworkStringResource";
String strLanguage = request.getHeader("Accept-Language");

String iconText = UINavigatorUtil.getI18nString("emxFramework.TreeComponent.Revision", stringResFileId, strLanguage);

String languageStr = request.getHeader("Accept-Language");
Vector userRoleList = PersonUtil.getAssignments(context);

String charSet=Framework.getCharacterEncoding(request);

HashMap treeMap = new HashMap();
HashMap treeMenuMap = new HashMap();
String objectId = emxGetParameter(request, "objectId");

String relId = emxGetParameter(request, "relId");

String mode = emxGetParameter(request, "mode");
String selectedNode = emxGetParameter(request, "jsTreeID");
String sTreeMenuName = emxGetParameter(request, "treeMenu");
String sTreeLabelName = emxGetParameter(request, "treeLabel");
String appendParamFlag = emxGetParameter(request, "AppendParameters");
String treeScope = emxGetParameter(request, "treeScope");
String collapseNavbar = emxGetParameter(request, "collapseNavbar");
String emxSuiteDirectory = emxGetParameter(request, "emxSuiteDirectory");
String DefaultCategoryQuerystring = emxGetParameter(request, "DefaultCategory"); //DEFAULT CATEGORY
String portalCmdName = emxGetParameter(request, "portalCmdName");

String typeName = "";
String mappedTreeName = "";
String treeScopeIDParams = "";
String emxErrorString = "";
String treeLabel = "";
String sTypeIconFromCache = "";
BusinessObject busObj = null;
boolean showAccess = false;

boolean isCurrentNode=false;
String treeDefaultCategory="";
//TMRF - Tree Menu Revision Filter
String blnRev="false";
//TMRF - Tree Menu Revision Filter ENDS
//OTI-starts
String strIconProg = "";
String strIconFun = "";
//OTI-ends

// If tree already present and no special mode defined
// then mode is always insert, else mode is replace
if ( (mode == null) || ( (selectedNode == null) || (selectedNode.length() == 0) ) )
{
    mode = "replace";
}
%>
<script language="javascript">
    var portalCmdName = "<xss:encodeForJavaScript><%=portalCmdName%></xss:encodeForJavaScript>";
    var selectedAlreadyset="false"; //JUMP ON TREE

    //array of parameters to add to URLs
    var arrAppendParams = new Array;

    //get reference to tree
    var objStructureTree = getTopWindow().objStructureTree;

    //get navbar setting
    var blnCollapseNavbar = "<%=XSSUtil.encodeForJavaScript(context, collapseNavbar)%>";
    if (blnCollapseNavbar == "true" && objStructureTree.getSelectedNode()){
           var selectnode = objStructureTree.getSelectedNode();
           objStructureTree.selectedID   = selectnode.nodeID;
                objStructureTree.doNavigate=true;

    }else{

    //get mode
    var strMode = "<xss:encodeForJavaScript><%=mode%></xss:encodeForJavaScript>";
    var objParentNode;
    //get the selected node in the tree

    if (objStructureTree.currentRoot) {
        objParentNode = objStructureTree.nodes["<xss:encodeForJavaScript><%=selectedNode%></xss:encodeForJavaScript>"];
        if(objParentNode == null){
	        strMode="replace";
        }
        // Commented as in portal the name link always popup,
        // this code is obselete with the changes made in emxTableDataInclude.inc.
        /*if (portalCmdName != null && portalCmdName != "null" && portalCmdName != "") {

                //find the node with the command name
                var i=0, blnFound = false;
                while(i < objParentNode.childNodes.length) {
                        if (objParentNode.childNodes[i].commandName == portalCmdName) {
                                objParentNode = objParentNode.childNodes[i];
                                blnFound = true;
                                break;
                        }
                        i++;
                }

                //if not found, pop it up
                if (!blnFound) {
                        strMode = "ignore";
                        getTopWindow().showModalDialog("emxTree.jsp?<%=(String)request.getQueryString()%>", 700, 600);
                }
        }*/
    }else{
        strMode="replace";
    }

    //store request parameters
    var strRequestURLParams = "<%=XSSUtil.encodeURLwithParsing(context, (String)request.getQueryString())%>";

    //if the request parameter contains "AppendParameters=true" add it to the arrAppendParams
    if (strRequestURLParams.toLowerCase().indexOf("appendparameters=true") > -1) {

        //Modified for Bug No:344896 Dated 12/03/2007 Begin.

        //Modified for Bug No:341849 Dated 11/5/2007 Begin.
        //var strAppendParams=strRequestURLParams.substring(strRequestURLParams.toLowerCase().indexOf("appendparameters=true"),strRequestURLParams.length);
        //var strAppendParams = strRequestURLParams.substring(0, strRequestURLParams.length);

        //split into its individual parameters
        //var arrTemp = strAppendParams.split("&");
        //Modified for Bug No:341849 Dated 11/5/2007 Ends.

        //split into its individual parameters
        var arrTemp = strRequestURLParams.split("&");
        //Modified for Bug No:344896 Dated 12/03/2007 Ends.

        //add each to the array parameters for the tree, but only if
        //the parameter isn't objectId, relId, jsTreeID, mode
        for (var i=0; i < arrTemp.length; i++) {
            if (    (arrTemp[i].indexOf("objectId=") == -1)
                &&  (arrTemp[i].indexOf("relId=") == -1)
                &&  (arrTemp[i].indexOf("jsTreeID=") == -1)
                &&  (arrTemp[i].indexOf("mode=") == -1)
                ) {
                arrAppendParams[arrAppendParams.length] = arrTemp[i];

            } //End: if
        } //End: for
    } //End: if (strRequestURLParams.toLowerCase().indexOf("appendparameters=true") > -1)

<%

try {

    // Start transactions
    if ( !(ContextUtil.isTransactionActive(context)) )
        ContextUtil.startTransaction(context, false);

    // check objectId for the valid string and trim if required
    if (objectId != null)
    {
        if (objectId.trim().length() == 0 || objectId.equals("null") )
        {
            objectId = null;
        } else {
            objectId = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(objectId);
            objectId = objectId.trim();

            busObj = new BusinessObject(objectId);
            busObj.open(context);
            showAccess = UINavigatorUtil.checkShowAccess(context, busObj);

            if ( !showAccess)
            {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
%> getTopWindow().findFrame(getTopWindow(),"content").document.location.href = "emxTreeNoDisplay.jsp"; <%
            }

            // Get the correct tree menu object to use
            mappedTreeName = UITreeUtil.getTreeMenuName(application, session, context, objectId, emxSuiteDirectory);

            if ( mappedTreeName == null )
            {
%> getTopWindow().findFrame(getTopWindow(),"content").document.location.href = "emxTreeNoDisplay.jsp"; <%
            }
        }
    }

    if ( sTreeMenuName != null && sTreeMenuName.trim().length() > 0)
    {

        sTreeMenuName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(sTreeMenuName);

        // Check if this is a valid menu name,
        // If not look up for symbolic name and then try validating
        HashMap altTreeMap = emxTreeObject.getMenu(context, sTreeMenuName);
    if (altTreeMap != null)
        {
            mappedTreeName = sTreeMenuName;
        } else {
            mappedTreeName = PropertyUtil.getSchemaProperty(context, sTreeMenuName);
        }

        if (mappedTreeName == null || mappedTreeName.length() == 0 )
        {
            mappedTreeName = sTreeMenuName;
        }

        typeName = mappedTreeName;

        // If there is no objectId used in this request URL, make the showAccess=true;
        if (objectId == null || objectId.trim().length() == 0)
            showAccess = true;
    }

    int catCount = 0;
    MapList nodeCategoryList = new MapList();
    String treeSuiteKey = "";

    HashMap menuJSNodeMap = new HashMap();
    boolean showTree = true;

    String showRev = "false";
    if ( (objectId != null && objectId.length() > 0)  || (mappedTreeName != null && mappedTreeName.length() > 0))
    {
        treeMenuMap = emxTreeObject.getMenu(context, mappedTreeName);
        //TMRF- Tree Menu Revision Filter
        showRev = UIToolbar.getSetting(treeMenuMap,"Revision Filter");
        //TMRF- Tree Menu Revision Filter ENDS

        if (treeMenuMap != null && emxTreeObject.isMenu(treeMenuMap))
        {

            // menuJSNodeMap = UITreeUtil.getJSNodeMap(application, session, context, treeMenuMap, objectId, relId, languageStr);
            menuJSNodeMap = UITreeUtil.getJSNodeMap(application, session, request, context, treeMenuMap, objectId, relId);

            if(DefaultCategoryQuerystring == null )
            {
               treeDefaultCategory = emxTreeObject.getSetting(treeMenuMap, "Default Category");
               if (treeDefaultCategory == null  || treeDefaultCategory.equalsIgnoreCase("null"))
               {
                  treeDefaultCategory="";
               }
            }else{

              treeDefaultCategory=DefaultCategoryQuerystring;
            }

            if (menuJSNodeMap == null)
            {
                showTree = false;
            }

        } else {
            showTree = false;
        }
    }

    // If "menuJSNodeMap" is null, the tree cannot be displayed
    if( !showTree)
    {
%> getTopWindow().findFrame(getTopWindow(),"content").document.location.href = "emxTreeNoDisplay.jsp"; <%
    }
        treeScopeIDParams = (String)menuJSNodeMap.get("treeScopeIDParams");
        if(sTreeLabelName != null && sTreeLabelName.indexOf("$")>-1){
            sTreeLabelName = UIExpression.substituteValues(context, pageContext, sTreeLabelName, objectId);
        }
        if(sTreeLabelName == null || sTreeLabelName.length() == 0)
        {
        	treeLabel = (String)menuJSNodeMap.get("nodeLabel");
        } else {
            treeLabel = FrameworkUtil.decodeURL(sTreeLabelName,charSet);
            //treeLabel = FrameworkUtil.decodeURL(treeLabel,charSet);
        }

        treeLabel = FrameworkUtil.findAndReplace(treeLabel, "\"", "\\\"");
		// to fix 362564
		treeLabel = FrameworkUtil.findAndReplace(treeLabel, "\n", " ");

        String treeNodeUrl=(String)menuJSNodeMap.get("nodeURL");
        if ( treeNodeUrl != null && treeNodeUrl.indexOf("?") > 0 ){
             treeNodeUrl=treeNodeUrl+"&emxSuiteDirectory="+XSSUtil.encodeForURL(context, emxSuiteDirectory);
             treeNodeUrl= treeNodeUrl + "&categoryTreeName=" + XSSUtil.encodeForURL(context, mappedTreeName);
             treeNodeUrl= treeNodeUrl + "&isStructure=true&otherToolbarParameters=isStructure";
             if(treeLabel != null && !"".equals(treeLabel)) {
                 treeNodeUrl += "&treeLabel=" + treeLabel;
             }
        }
        //Modified for OverRidden Type Icon -Starts
        strIconProg = emxTreeObject.getSetting(treeMenuMap, "Type Icon Program");
        strIconFun = emxTreeObject.getSetting(treeMenuMap, "Type Icon Function");
        if(strIconProg.length()<=0 && strIconFun.length()<=0)
        {
            try
            {
                String defaultProgramFunction = EnoviaResourceBundle.getProperty(context, "emxFramework.UIComponents.OverriddenTypeIcon.Program");
                if(defaultProgramFunction!=null && defaultProgramFunction.length()>0)
                {
                    StringList strList = FrameworkUtil.split(defaultProgramFunction, ":");
                    strIconProg = (String)strList.get(0);
                    strIconFun = (String)strList.get(1);
                }
            }
            catch(Exception e)
            {
                throw(new FrameworkException(e));
            }
        }
        if(strIconProg.length()>0 && strIconFun.length()>0 && objectId!=null){
            String strObjIds[] = new String[1];
            strObjIds[0]=objectId;
            Map mIconMap = (Map)UITreeUtil.getTreeIcon(context,strIconProg,strIconFun,strObjIds,null);
            sTypeIconFromCache = (String)mIconMap.get(objectId);
        }else{
            if (busObj != null){
                sTypeIconFromCache = UINavigatorUtil.getTypeIconFromCache(busObj.getTypeName());
            }else{
                sTypeIconFromCache = (String)menuJSNodeMap.get("nodeIcon");
            }
        }

        if(sTypeIconFromCache == null || sTypeIconFromCache.trim().length()==0){
              String strDefaultImage  = EnoviaResourceBundle.getProperty(context, "emxFramework.smallIcon.defaultType");
            if(strDefaultImage == null || strDefaultImage.trim().length() ==0){
              strDefaultImage="iconSmallDefault.gif";
            }
          sTypeIconFromCache=strDefaultImage;
        }
        //Modified for OverRidden Type Icon -Ends
%>
        //get tree data
        //XSSOK
        var strTreeScopeID = "<%=treeScopeIDParams%>";
      	//XSSOK
        var strURL = "<%=treeNodeUrl%>";
      	//XSSOK
        var strIcon = "<%=sTypeIconFromCache%>";
      	//XSSOK
        var strExpandURL = "<%=(String)menuJSNodeMap.get("nodeExpandURL")%>";
        var strObjectId = "<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>";
        var strRelId = "<xss:encodeForJavaScript><%=relId%></xss:encodeForJavaScript>";
      	//XSSOK
        var strLabel = "<%=treeLabel%>";

        //add the parameters to the URL
        for (var i=0; i < arrAppendParams.length; i++){
            strURL = getTopWindow().addUniqueURLParam(strURL, arrAppendParams[i]);
        } //End: for (var i=0; i < arrAppendParams.length; i++)

<%
//TMRF - Tree Menu Revision Filter
if(objectId != null){
        StringList strlObjectSelList = new StringList();
        strlObjectSelList.add("id");
        strlObjectSelList.add("name");
        strlObjectSelList.add("revision");
        DomainObject doObject = new DomainObject(objectId);
        treeLabel=doObject.getName(context);
        MapList mplObjectRev = doObject.getRevisions(context,strlObjectSelList,false);
        int revSize = mplObjectRev.size();
        if(revSize > 1)
        {
          blnRev = "true";
        }
}
//TMRF - Tree Menu Revision Filter ENDS
%>
        //TMRF - Tree Menu Revision Filter
        //Passing two new parameters to emxUIObjectNode()method 'blnRev' and  'showRev'
        //'blnRev' is a bolean to verify whether there are more than one revisions
        //'showRev' is a boolean to verify whether Revision Filter is enabled or Disabled for the tree menu
        //XSSOK
        var blnRev = "<%=blnRev%>";
        //XSSOK
        var showRev = "<%=showRev%>";
        //XSSOK
        var iconText= "<%=iconText%>";
        //create new node
        var wTop = getTopWindow();
        var objNewNode = new wTop.emxUIObjectNode(strIcon, strLabel, strURL, strObjectId, strRelId, strExpandURL, blnRev, showRev, iconText);
        //TMRF - Tree Menu Revision Filter ENDS

        //check to see what mode it is in
        if (strMode == "insert") {

            //create child node
            objNewNode = objParentNode.addChild(objNewNode);

         } else if (strMode == "replace"){

            //need to make a new tree, so clear its data
            objStructureTree.clear();

            //create the root
            objStructureTree.createRoot(objNewNode);

            //set pointer to root
            objNewNode = objStructureTree.root;

            //Set the title of window to root tree node, if tree is displayed in new window
            if(getTopWindow().hiddenTreeFrame){
            <%
                 String title = UIUtil.getWindowTitleName(context,relId,objectId,treeLabel);
                        title = FrameworkUtil.findAndReplace(title, "\"", "\\\"");

            %>
                var title="<%=title%>";
            	getTopWindow().document.title = title;

           }

         } //End: if (strMode == "insert")

         //add node scope ID
         objNewNode.addNodeScopeID(strTreeScopeID);
<%
            MapList childNodeList = UITreeUtil.getTreeChildNodeList(context, mappedTreeName, userRoleList);

	    //Added for Dynamic Categories for Tree Feature
	    HashMap requestMap	= UINavigatorUtil.getRequestParameterMap(request);
	    HashMap paramMap    = new HashMap();
	    paramMap.put("objectId",objectId);
	    paramMap.put("relId",relId);
	    paramMap.put("mode",mode);
	    paramMap.put("treeMenu",mappedTreeName);
	    paramMap.put("requestMap",requestMap);
	    childNodeList       = UITreeUtil.loadDynamicCategories(context, mappedTreeName,childNodeList,paramMap);
	    //Ended for Dynamic Categories for Tree Feature

            // Get tree node Categories
            if (childNodeList != null && childNodeList.size() > 0)
            {
                for (int k = 0; k < childNodeList.size(); k++)
                {
                    HashMap commandJSNodeMap = new HashMap();
                    HashMap catMap = (HashMap)childNodeList.get(k);

                    boolean showNode = true;
                    String COMMANDName = ""; //(JBB 12/5/2002)
                    // Check if the item is command
                    if (catMap != null)
                    {
                        COMMANDName=emxTreeObject.getName(catMap); //(JBB 12/5/2002)
                        HashMap allSettings = emxTreeObject.getSettings(catMap);

                        // Check the access for this node
                        if (busObj != null && !UITreeUtil.isDynamicCategory(catMap))
                        {
// Modified for Dynamic Categories for Tree Feature

              showNode = UINavigatorUtil.checkAccessForSettings(context, busObj, request, allSettings);
              if (!showNode)
              {
                continue;
              }

              else
              {
                String strType = (String)catMap.get("type");
                if ("menu".equalsIgnoreCase(strType))
                {//It is menu hence, find out if all the commands under it are to be shown or not ?

                  showNode = UITreeUtil.recursivelyCheckAccessForSettings(context,
                                                           busObj,
                                                           request,
                                                           catMap,
                                         userRoleList);

                  if (!showNode)
                  {
                    continue;
                  }
                }
              }


                        }

                        String nodeCOMMANDName = emxTreeObject.getName(catMap);
                        isCurrentNode=false;
                        if(nodeCOMMANDName != null && nodeCOMMANDName.equalsIgnoreCase(treeDefaultCategory))
                        {
                            isCurrentNode=true;
                        }
                        commandJSNodeMap = UITreeUtil.getJSNodeMap(application, session, request, context, catMap, objectId, relId);
                    }


                    String childNodeURL = (String)commandJSNodeMap.get("nodeURL");
                    String childNodeExpandURL = (String)commandJSNodeMap.get("nodeExpandURL");

          if (treeScopeIDParams != null && treeScopeIDParams.trim().length() > 0)
                    {
                        childNodeURL = childNodeURL + "&" + treeScopeIDParams;
                    }
          childNodeURL = childNodeURL + "&categoryTreeName=" + mappedTreeName;
          childNodeURL = childNodeURL + "&isStructure=true&otherToolbarParameters=isStructure";
          if(treeLabel != null && !"".equals(treeLabel)) {
        	  childNodeURL += "&treeLabel=" + treeLabel;
          }
          childNodeURL = childNodeURL + "&categoryTreeName=" + XSSUtil.encodeForURL(context, mappedTreeName);

                    if (emxSuiteDirectory != null && emxSuiteDirectory.trim().length() > 0 && childNodeExpandURL != null && childNodeExpandURL.trim().length() > 0)
                    {
                        childNodeExpandURL = childNodeExpandURL + "&emxSuiteDirectory=" +XSSUtil.encodeForURL(context, emxSuiteDirectory);
                    }
                    childNodeExpandURL = childNodeExpandURL + "&categoryTreeName=" + XSSUtil.encodeForURL(context, mappedTreeName);

          if (commandJSNodeMap != null)
                    {
                        if ( childNodeURL != null && childNodeURL.indexOf("?") > 0 )
                        {
                            childNodeURL=childNodeURL+"&emxSuiteDirectory="+XSSUtil.encodeForURL(context, emxSuiteDirectory);
                        }

                        String strTempNodeLabel = (String)commandJSNodeMap.get("nodeLabel");
                        strTempNodeLabel = FrameworkUtil.findAndReplace(strTempNodeLabel, "\"", "\\\"");
%>
                        //XSSOK
                        var defaultTree="<%=isCurrentNode%>";
                      	//XSSOK
                        strURL = "<%=childNodeURL%>";
                      	//XSSOK
                        strLabel = "<%=strTempNodeLabel%>";
                        //B&W End 2/9/2006
                        //XSSOK
                        strIcon = "<%=(String)commandJSNodeMap.get("nodeIcon")%>";
                        //XSSOK
                        strExpandURL = "<%=childNodeExpandURL%>";
                        strObjectId = "<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>";
                        strRelId = "<xss:encodeForJavaScript><%=relId%></xss:encodeForJavaScript>";

                        //add the request parameters to the URL
                        for (var i=0; i < arrAppendParams.length; i++) {
                            strURL = getTopWindow().addUniqueURLParam(strURL, arrAppendParams[i]);
                        } //End: for (var i=0; i < arrAppendParams.length; i++)

                        //create category node
                        var wTop = getTopWindow();
                        //XSSOK
                        objCategoryNode = objNewNode.addChild(new wTop.emxUICategoryNode(strLabel, strURL,strObjectId,strRelId,"<%=COMMANDName%>", strExpandURL));
            //alert("create catagory node name=<%=COMMANDName%> , expandurl="+strExpandURL);

			// Added for Dynamic Categories for Tree Feature
			var dynamicParentNode = objCategoryNode;
			<%if(UITreeUtil.isDynamicMenuCategory(catMap)){%>
				//XSSOK
				<%=UITreeUtil.loadDynamicMenuCategory(application,session,request,context,catMap,objectId,relId,treeScopeIDParams,emxSuiteDirectory)%>
			<%}%>
			// Ended for Dynamic Categories for Tree Feature

                        //add tree scope ID
                        objCategoryNode.addNodeScopeID(strTreeScopeID);

                       if(defaultTree=="true") {
                            objStructureTree.selectedID = objCategoryNode.nodeID;
                            selectedAlreadyset="true";
                        }
<%
                    }
                } // for loop childNodesList
            } // if childNodesList not null
%>

            if (strMode=="insert") {

                //set the selected node
                if(selectedAlreadyset != "true") {
                    objStructureTree.selectedID = objNewNode.nodeID;
                }

                //expand the parent so you can see the new child nodes
                objParentNode.expanded = true;

                objStructureTree.doNavigate=true;

                //close all nodes under this parent except the last one
                for (var i=0; i < objParentNode.childNodes.length-1; i++) {
                    if (objParentNode.childNodes[i].hasChildNodes)
                        objParentNode.childNodes[i].expanded = false;
                }

                objNewNode.expanded = true;
                objNewNode.loaded = true;

            } //End: if (strMode=="insert")

        //add to page history
        if (strMode != "ignore"){
                if(getTopWindow().historyControl){
                    if(!getTopWindow().historyControl.isMenuItemClicked){
                        objNewNode.addToHistory();
                    }
                    getTopWindow().historyControl.isMenuItemClicked=false;
                }
        }

<%

} catch (Exception e)  {
    ContextUtil.abortTransaction(context);
    emxErrorString=e.toString().trim();
} finally {
    ContextUtil.commitTransaction(context);
    if(emxErrorString!=null && emxErrorString.length()>0)
        emxNavErrorObject.addMessage(emxErrorString);
}
%>
}

</script>

<script language="javascript">
function loadTree()
{

    //set display frame
    objStructureTree.displayFrame = self;

    //refresh the tree
    objStructureTree.refresh();
}
</script>

<body onload="loadTree()">
<emxUtil:i18nScript localize="i18nId">emxNavigator.UIMenuBar.Loading</emxUtil:i18nScript>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
