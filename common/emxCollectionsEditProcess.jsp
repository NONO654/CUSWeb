<%--  emxCollectionsEditProcess.jsp  - To edit Collections
 Copyright (c) 2003-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program

   static const char RCSID[] = $Id: emxCollectionsEditProcess.jsp.rca 1.20 Wed Oct 22 15:48:56 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.SetUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<!-- Import the java packages -->
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
  //Reading the system generated collection name and label name
  String strSystemGeneratedCollectionLabel  = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(request.getHeader("Accept-Language")), "emxFramework.ClipBoardCollection.NameLabel");
  String strSetId                           = emxGetParameter(request, "relId");
  String objectName                         = SetUtil.getCollectionName(context, strSetId);
  String sCharSet                           = Framework.getCharacterEncoding(request);
  String newSetName                         = emxGetParameter(request, "collectionName");
  String description                        = emxGetParameter(request, "description");
  String nameChanged                        = emxGetParameter(request, "nameChanged");
  String jsTreeID                           = emxGetParameter(request,"jsTreeID");
  String suiteKey                           = emxGetParameter(request,"suiteKey");
  StringBuffer reloadURL                    = null;

  try {
       if(nameChanged.equalsIgnoreCase("true")){
           boolean setExists = SetUtil.exists(context, newSetName);
           if (setExists || strSystemGeneratedCollectionLabel.equals(newSetName))// To validate system generated collection label
           {
              reloadURL = new StringBuffer(100);
              reloadURL.append("../common/emxTree.jsp?AppendParameters=true&mode=replace&treeMenu=AEFCollectionsMenu&treeLabel=");
              reloadURL.append(XSSUtil.encodeForURL(context, objectName));
              reloadURL.append("&jsTreeID=");
              reloadURL.append(XSSUtil.encodeForURL(context,jsTreeID));
              reloadURL.append("&suiteKey=");
              reloadURL.append(XSSUtil.encodeForURL(context, suiteKey));
              reloadURL.append("&objectName=");
              reloadURL.append(XSSUtil.encodeForURL(context, newSetName));
              reloadURL.append("&relId=");
              reloadURL.append(XSSUtil.encodeForURL(context,strSetId));
 %>
             
<script language="Javascript">
             var alertMsg = "<emxUtil:i18n localize="i18nId">emxFramework.Collections.CollectionError</emxUtil:i18n>";
             alertMsg += " ";
             alertMsg += "<%=XSSUtil.encodeForJavaScript(context, newSetName)%>";
             alertMsg += " ";
             alertMsg += "<emxUtil:i18n localize="i18nId">emxFramework.Collections.AlreadyExists</emxUtil:i18n>";
             alert(alertMsg);
             parent.location.href=parent.location.href;
             </script>
 <%
           }
           else
           {
                matrix.db.Set newSet    = SetUtil.rename(context, objectName, newSetName);
                String output           = MqlUtil.mqlCommand(context, "Modify set $1 property description value $2 ;",newSetName,description);
                strSetId                = SetUtil.getCollectionId(context, newSetName);
                reloadURL               = new StringBuffer(100);
                reloadURL.append("../common/emxTree.jsp?AppendParameters=true&mode=replace&treeMenu=AEFCollectionsMenu&treeLabel=");
                reloadURL.append(XSSUtil.encodeForURL(context, newSetName));
                reloadURL.append("&jsTreeID=");
                reloadURL.append(jsTreeID);
                reloadURL.append("&suiteKey=");
                reloadURL.append(XSSUtil.encodeForURL(context ,suiteKey));
                reloadURL.append("&relId=");
                reloadURL.append(XSSUtil.encodeForURL(context,strSetId));
           }
        }else{
                String output   = MqlUtil.mqlCommand(context, "Modify set $1 property description value $2 ;",newSetName,description);
                reloadURL       = new StringBuffer(100);
                
                reloadURL.append("../common/emxTree.jsp?AppendParameters=true&mode=replace&treeMenu=AEFCollectionsMenu&treeLabel=");
                reloadURL.append(XSSUtil.encodeForURL(context ,newSetName));
                reloadURL.append("&jsTreeID=");
                reloadURL.append(jsTreeID);
                reloadURL.append("&suiteKey=");
                reloadURL.append(XSSUtil.encodeForURL(context ,suiteKey));
                reloadURL.append("&relId=");
                reloadURL.append(XSSUtil.encodeForURL(context,strSetId));
       }
  }
  catch(Exception e)
  {
    throw e;
  }

%>
<script language="javascript" src="scripts/emxUICore.js"></script>
<script language="javascript" src="scripts/emxUIConstants.js"></script> 
<script language="Javascript">
<%
    if("true".equals(nameChanged))
    {
        
%>
        var treeDisplayFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "treeContent");
        if(treeDisplayFrame != null){
        	//XSSOK
            treeDisplayFrame.document.location.href = "<%=reloadURL.toString()%>";
        }else{
           //Added to refresh the collections summary on editing the name of the collection  
            if(getTopWindow().getWindowOpener().getTopWindow().getWindowOpener()) {
                getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().document.location.href   = getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().document.location.href
            }
           //XSSOK
            getTopWindow().getWindowOpener().document.location.href = "<%=reloadURL.toString()%>";
        }
	getTopWindow().getWindowOpener().getTopWindow().changeObjectLabelInTree("<%=XSSUtil.encodeForURL(context,jsTreeID)%>","<%=XSSUtil.encodeForJavaScript(context, newSetName)%>", true, false, false);

	var bclist = getTopWindow().bclist;
	if(bclist == null){
		bclist = getTopWindow().getWindowOpener().getTopWindow().bclist;
	}
	var currbc = bclist.getCurrentBC();
	if(currbc){
		currbc.categoryObj.items.forEach(function(item){
			item.url = updateURLParameter(item.url, "relId", "<%=XSSUtil.encodeForURL(context,strSetId)%>");
			item.url = updateURLParameter(item.url, "treeLabel", "<%=XSSUtil.encodeForJavaScript(context, newSetName)%>");
		});
			
		currbc.label = "<%=XSSUtil.encodeForJavaScript(context, newSetName)%>";
		currbc.treeURL = updateURLParameter(currbc.treeURL, "treeLabel", "<%=XSSUtil.encodeForJavaScript(context, newSetName)%>");
		currbc.treeURL = updateURLParameter(currbc.treeURL, "relId", "<%=XSSUtil.encodeForURL(context,strSetId)%>");
		currbc.pageURL = updateURLParameter(currbc.pageURL, "treeLabel", "<%=XSSUtil.encodeForJavaScript(context, newSetName)%>");
		currbc.pageURL = updateURLParameter(currbc.pageURL, "relId", "<%=XSSUtil.encodeForURL(context,strSetId)%>");
	}
<%
    }
    else
    {
%>
        var treeDisplayFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "treeContent");
        if(treeDisplayFrame != null){
            getTopWindow().getWindowOpener().document.location.href = getTopWindow().getWindowOpener().document.location.href;
        }else{
            getTopWindow().getWindowOpener().document.location.href = getTopWindow().getWindowOpener().document.location.href;
        }

<%
    }
%>
  getTopWindow().closeWindow();
</script>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
