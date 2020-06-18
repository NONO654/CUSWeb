<%--
  FOEffectivitySearchUtil.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="java.util.Enumeration" %>
<%@page import="java.util.Map"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
String strMode = emxGetParameter(request,"mode");
  try
  {
     String strTypeAhead = emxGetParameter(request,"typeAhead");
     String strFunctionality = emxGetParameter(request,"functionality"); 

     if (strFunctionality!=null){
         strMode = "wizard";
     }
     //get the selected Objects from the Full Search Results page
     String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
     
     //If the selection is empty given an alert to user
     if(strContextObjectId==null){   
     %>    
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%}
     //If the selection are made in Search results page then     
     else{
        if(strMode.equalsIgnoreCase("Chooser"))
	    {
	       try{
	             //gets the mode passed
	              String strSearchMode = emxGetParameter(request, "chooserType");
	              // if the chooser is in the Custom JSP 
	              if (strSearchMode.equals("CustomChooser") || strSearchMode.equals("FormChooser"))
	              {   	                  
	                  //added for the CR no. 371091 
	                  
	                  String fieldNameActual = emxGetParameter(request, "fieldNameActual");
	                  String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
	                  
	                  StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                      String strObjectId = strTokenizer.nextToken() ; 
                      
	                  DomainObject objContext = new DomainObject(strObjectId);
	                  
	                  StringList selectables = new StringList();
	                  selectables.add(DomainConstants.SELECT_NAME);
	                  selectables.add(DomainConstants.SELECT_REVISION);
	                  
	                  Map mapUsedResult = objContext.getInfo(context, selectables);
	                  
	                  String strObjName = (String)mapUsedResult.get(DomainConstants.SELECT_NAME);
	                  String strObjRev = (String)mapUsedResult.get(DomainConstants.SELECT_REVISION);
	                  
	                  StringBuffer sBObjNameRev = new StringBuffer();
	                  sBObjNameRev.append(strObjName);
	                  sBObjNameRev.append(" ");
	                  sBObjNameRev.append(strObjRev);
	                  
	                  String strContextObjectName = sBObjNameRev.toString();
	                  
	                  %>
	                  <script language="javascript" type="text/javaScript">
	                  var vfieldNameActual ="";
	                  var vfieldNameDisplay ="";
	                  var vTypeAhead= "<%=XSSUtil.encodeForJavaScript(context,strTypeAhead)%>";
					  if(vTypeAhead!=null && vTypeAhead=="true"){
						  var contentFrameObj = findFrame(getTopWindow(),"mx_iframeFeatureOption");
					      vfieldNameActual = contentFrameObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
			              vfieldNameDisplay = contentFrameObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
					  }else{
						  vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
			              vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
					  }
		             
		              if(!vfieldNameActual || !vfieldNameDisplay[0]){
		                   vfieldNameActual = getTopWindow().frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
		                   vfieldNameDisplay = getTopWindow().frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
	                  }
	                     
                      vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                      vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
	                     
	                  </script>
		              <%
		              if (strTypeAhead ==null || !strTypeAhead.equalsIgnoreCase("true")){
	                  %>
	                  <script language="javascript" type="text/javaScript">  
	                  getTopWindow().location.href = "../common/emxCloseWindow.jsp";   
	                  </script>
                      <%
		              }
	              }
	         }   
	          catch (Exception e){
	              session.putValue("error.message", e.getMessage());  
	          }
	     }
     }
  }
  catch(Exception e)
  {
    session.putValue("error.message", e.getMessage());
  }// End of main Try-catck block
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
