
<%--  GBOMReplacePostProcess.jsp-- Will redirect to GBOMReplaceDialog with proper params
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   
--%>

<%@include file= "../common/emxNavigatorInclude.inc"%>
<%@include file= "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>

<html>
<head>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
</head>
<%  
    String strSourceGBOM = (String)emxGetParameter(request, "objectId");
    String strParentOID =(String)emxGetParameter(request, "parentOID");
    String strDestGBOM ="";
    String strSourceGBOMRelID = "";
    String strAuthorizingECID = "";
    strSourceGBOMRelID = (String)emxGetParameter(request, "relId");
    String strMode = (String)emxGetParameter(request, "mode1");
    if(strMode!=null &&  (strMode.equalsIgnoreCase("ActionIcon") || strMode.equalsIgnoreCase("fromContext"))){
    	String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
        StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
        strDestGBOM = strTokenizer.nextToken() ;         
    }
    else{
    strDestGBOM =(String)emxGetParameter(request, "ReplaceWith2OID");
    if(strDestGBOM==null)
    	strDestGBOM =(String)emxGetParameter(request, "ReplaceWithOID");
            strAuthorizingECID=(String)emxGetParameter(request, "AuthorizingECOID");    	
    }   
    
    try
    {
        LogicalFeature  logicalFtr= new LogicalFeature(strParentOID);
        if(!strSourceGBOM.trim().equals(strDestGBOM.trim()))
            logicalFtr.replaceGBOM(context,strSourceGBOMRelID,strDestGBOM,strAuthorizingECID);
        
    }
    catch(Exception ex)
    {
    	//TODO-- ?
        session.putValue("error.message", ex.getMessage());
    }
%>

<script language="javascript" type="text/javaScript">
      var refFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
      var stMode = '<%=XSSUtil.encodeForJavaScript(context,strMode)%>';
      var strParentOID = "<%=XSSUtil.encodeForJavaScript(context,strParentOID)%>"
      var strDestGBOM = "<%=XSSUtil.encodeForJavaScript(context,strDestGBOM)%>"
      var strSourceGBOM = "<%=XSSUtil.encodeForJavaScript(context,strSourceGBOM)%>"
      if(refFrameObj != null)
      {   
       <%   
          if(!strSourceGBOM.equals(strDestGBOM)){    
       %>
            refFrameObj.parent.getTopWindow().refreshTreeDetailsPage();
        	if(typeof refFrameObj.deleteObjectFromTrees !== 'undefined' && 
        			typeof refFrameObj.deleteObjectFromTrees === 'function'){
        		refFrameObj.deleteObjectFromTrees(strSourceGBOM, false);
        	}
        	if(typeof refFrameObj.addMultipleStructureNodes !== 'undefined' && 
        			typeof refFrameObj.addMultipleStructureNodes === 'function'){
        		refFrameObj.addMultipleStructureNodes(strDestGBOM, strParentOID, '', '', false);
        	}            
            parent.window.closeWindow();
            parent.getTopWindow().window.closeWindow();
            
       <%
        } else {
       %>
           refFrameObj.parent.getTopWindow().refreshTablePage();
       <%
       }
       %>
      }
      else if(stMode == "ActionIcon")
      {
    	  getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
          getTopWindow().window.closeWindow(); 
          
      }
      else if(stMode == "fromReleaseContext")
      {
    	  getTopWindow().getWindowOpener().parent.location.reload();          
      }
      else if(stMode == "fromContext")
      {	    
    	  //getTopWindow().getWindowOpener().parent.location.reload();
    	  var listFrame = getTopWindow().getWindowOpener().parent;
    	  listFrame.editableTable.loadData();
          listFrame.rebuildView();
          parent.getTopWindow().closeWindow();      
      }
      else {   	
    	   
          parent.window.getWindowOpener().location.reload();
          parent.window.closeWindow();
     }
 </script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>

