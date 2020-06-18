<%--  emxTreeSubmenuExpand.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<html>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="emxTreeObject" class="com.matrixone.apps.framework.ui.UIMenu" scope="request"/>

<%
String languageStr = request.getHeader("Accept-Language");
Vector userRoleList = PersonUtil.getAssignments(context);

String objectId = emxGetParameter(request, "objectId");
String relId = emxGetParameter(request, "relId");
String mode = emxGetParameter(request, "mode");
String selectedNode = emxGetParameter(request, "jsTreeID");
String appendParamFlag = emxGetParameter(request, "AppendParameters");
String treeScope = emxGetParameter(request, "treeScope");
String emxSuiteDirectory = emxGetParameter(request, "emxSuiteDirectory");

String insertNodeLabel = emxGetParameter(request, "nodeLabel");
String insertNodeOID = emxGetParameter(request, "nodeOID");
String insertNodeRelID = emxGetParameter(request, "nodeRelID");

String expandNodeObjectId=objectId;

String  nodeName  = emxGetParameter(request, "nodeName");
%>
<script language="javascript">
    var selectedAlreadyset="false";

    //holder for new node
    var objNewNode = null;

    //array of parameters to add to URLs
    var arrAppendParams = new Array;

    //get reference to tree
    var objStructureTree = getTopWindow().objStructureTree;

    //get the selected node in the tree
    var objParentNode = objStructureTree.nodes["<xss:encodeForJavaScript><%=selectedNode%></xss:encodeForJavaScript>"];

    //remove any nodes under this parent
    objParentNode.removeChildByID(objParentNode.childNodes[0].nodeID, false);

    //store request parameters
    var strRequestURLParams = "<%=XSSUtil.encodeURLwithParsing(context, (String)request.getQueryString())%>";

    //if the request parameter contains "AppendParameters=true" add it to the arrAppendParams
    if (strRequestURLParams.toLowerCase().indexOf("appendparameters=true") > -1) {

        //var strAppendParams = strRequestURLParams.substring(0, strRequestURLParams.length);

        //split into its individual parameters
        var arrTemp = strRequestURLParams.split("&");

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
String nodeObjectId = objectId;
String treeScopeIDParams = "";


BusinessObject busObj = null;


try {

    if ( !(ContextUtil.isTransactionActive(context)) )
        ContextUtil.startTransaction(context, false);

    if (nodeName != null && nodeName.trim().length() > 0)
    {


		if (objectId != null)
		{
			if (objectId.trim().length() == 0 || objectId.equals("null") )
			{
				objectId = null;
			}
			else
			{
				objectId = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(objectId);
				objectId = objectId.trim();

				busObj = new BusinessObject(objectId);
				busObj.open(context);
				boolean showAccess = UINavigatorUtil.checkShowAccess(context, busObj);

				if (!showAccess)
				{
					response.setStatus(HttpServletResponse.SC_FORBIDDEN);
%>
					getTopWindow().findFrame(getTopWindow(),"content").document.location.href = "emxTreeNoDisplay.jsp";
<%
				}//if
			}//else
		}//if








            MapList childNodeList = UITreeUtil.getTreeChildNodeList(context, nodeName, userRoleList);

	    //Added for Dynamic Categories for Tree Feature
	    HashMap requestMap	= UINavigatorUtil.getRequestParameterMap(request);
	    HashMap paramMap    = new HashMap();
	    paramMap.put("objectId",objectId);
	    paramMap.put("relId",relId);
	    paramMap.put("mode",mode);
	    paramMap.put("treeMenu",nodeName);
	    paramMap.put("requestMap",requestMap);
	    childNodeList       = UITreeUtil.loadDynamicCategories(context, nodeName,childNodeList,paramMap);
	    //Added for Dynamic Categories for Tree Feature

            // Get tree node Categories
            if (childNodeList != null && childNodeList.size() > 0)
            {
                for (int k = 0; k < childNodeList.size(); k++)
                {
                    HashMap commandJSNodeMap = new HashMap();
                    HashMap catMap = (HashMap)childNodeList.get(k);
                    boolean showNode = true;

                    // Check if the item is command
                    if (catMap != null)
                    {
                         HashMap allSettings = emxTreeObject.getSettings(catMap);
                         commandJSNodeMap = UITreeUtil.getJSNodeMap(application, session, request, context, catMap, objectId, relId);



						// Check the access for this node
                        if (busObj != null && !UITreeUtil.isDynamicCategory(catMap)) // Modified for Dynamic Categories for Tree Feature
                        {
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
								}//if
							}//else
                        }







                    }

                    String childNodeURL = (String)commandJSNodeMap.get("nodeURL");
                    String childNodeExpandURL = (String)commandJSNodeMap.get("nodeExpandURL");

                    if (treeScopeIDParams != null && treeScopeIDParams.trim().length() > 0)
                        childNodeURL = childNodeURL + "&" + treeScopeIDParams;

                    if (emxSuiteDirectory != null && emxSuiteDirectory.trim().length() > 0 && childNodeExpandURL != null && childNodeExpandURL.trim().length() > 0)
                        childNodeExpandURL = childNodeExpandURL + "&emxSuiteDirectory=" + XSSUtil.encodeForURL(context, emxSuiteDirectory);

                    if (commandJSNodeMap != null)
                    {
%>
        // Javascript CODE START
        var JumpOnTree="false"; //JUMP ON TREE

        var strTreeScopeID = "";//"<%--treeScopeIDParams--%>";
        var strURL = "<%=childNodeURL%>";//XSSOK
        //XSSOK
        var strLabel = "<%=(String)commandJSNodeMap.get("nodeLabel")%>";
        //XSSOK
        var strIcon = "<%=(String)commandJSNodeMap.get("nodeIcon")%>";
        //XSSOK
        var strExpandURL = "<%=childNodeExpandURL%>";
        var strObjectId = "<xss:encodeForJavaScript><%=expandNodeObjectId%></xss:encodeForJavaScript>";
        var strRelId = "<xss:encodeForJavaScript><%=relId%></xss:encodeForJavaScript>";

        //add the parameters to the URL
        for (var i=0; i < arrAppendParams.length; i++){
            strURL = getTopWindow().addUniqueURLParam(strURL, arrAppendParams[i]);
        } //End: for (var i=0; i < arrAppendParams.length; i++)

        //create new node
        var wTop = getTopWindow();
        objNewNode = new wTop.emxUICategoryNode(strLabel, strURL, strObjectId, strRelId, "<xss:encodeForJavaScript><%=nodeName%></xss:encodeForJavaScript>",strExpandURL);

        //create child node
        objNewNode = objParentNode.addChild(objNewNode);

        //add node scope ID
        objNewNode.addNodeScopeID(strTreeScopeID);

        // Added for Dynamic Categories for Tree Feature
	var dynamicParentNode = objNewNode;
	<%if(UITreeUtil.isDynamicMenuCategory(catMap)){	%>
		<%=UITreeUtil.loadDynamicMenuCategory(application,session,request,context,catMap,objectId,relId,treeScopeIDParams,emxSuiteDirectory)%>//XSSOK
	<%}%>
       // Added for Dynamic Categories for Tree Feature
// Javascript CODE END
<%
                    }
                } // If Tree menu check
            } // if expandTreeMap null check
        //}
    } else {  //Else for if the nodeName is null
    }
%>
// Javascript CODE START

    if (objNewNode) {

        //expand the parent so you can see the new child nodes
        objParentNode.expanded = true;

        objStructureTree.doNavigate = (typeof objParentNode.url == "string" && objParentNode.url != "");
        // Modified for Dynamic Categories for Tree Feature
        objParentNode.loaded = true;
     }

// Javascript CODE END

<%
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if(ex.toString()!=null && ex.toString().trim().length() > 0)
        emxNavErrorObject.addMessage(ex.toString());
} finally {
    ContextUtil.commitTransaction(context);
}
%>

</script>

<script language="javascript">
function loadTree()
{
    //set loaded flag to true
    objParentNode.loaded = true;

    //refresh the tree
    objStructureTree.refresh();
}
</script>
<body onload="loadTree()">
<emxUtil:i18nScript localize="i18nId">emxNavigator.UIMenuBar.Loading</emxUtil:i18nScript>
</body>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</html>
