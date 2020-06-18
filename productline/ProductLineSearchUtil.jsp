<%--
  ProductLineSearchUtil.jsp
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

<%@page import="com.matrixone.apps.common.util.FormBean"%> 
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%> 
<%@page import="com.matrixone.apps.productline.Product"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%> 
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%> 
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.db.Context"%> 
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
boolean bIsError = false;
boolean isRefreshTree = false;
String action = "";
String msg = "";
String strMode = emxGetParameter(request,"mode");
  try
  {
     String strObjId = emxGetParameter(request, "objectId");
     String strContext = emxGetParameter(request,"context");
     String strRelName = emxGetParameter(request,"relName");   
     String strIsUNTOper = emxGetParameter(request,"isUNTOper");   
     String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
     String strToConnectObjectType = "";
     String strTypeAhead = emxGetParameter(request,"typeAhead");
     String strAppendRevision = emxGetParameter(request,"appendRevision");
	 if (strMode.equalsIgnoreCase("Chooser"))
	 {
			 String strSearchMode = emxGetParameter(request, "chooserType");
		     if (strSearchMode.equals("CustomChooser") || strSearchMode.equals("FormChooser"))
	         {
                 String strModeValue = emxGetParameter(request, "value");
                 String fieldNameActual = emxGetParameter(request, "fieldNameActual");
                 String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
                 
                 StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                 String strObjectId = strTokenizer.nextToken() ; 
                 
                 DomainObject objContext = new DomainObject(strObjectId);
                 String strContextObjectName = objContext.getInfo(context,DomainConstants.SELECT_NAME);
                 %>
                 <script language="javascript" type="text/javaScript">
                     var vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                     var vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                     if(!vfieldNameActual || !vfieldNameDisplay[0]){
                          vfieldNameActual = getTopWindow().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                          vfieldNameDisplay = getTopWindow().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                      }
                     vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                     vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
                 </script>
                 <%
                 if (strTypeAhead ==null || !strTypeAhead.equalsIgnoreCase("true")){
	                 %>
	                 <script language="javascript" type="text/javaScript">  
	                     //getTopWindow().location.href = "../common/emxCloseWindow.jsp";  
						 closePopupWindow(getTopWindow());	
	                     //getTopWindow().close();
	                 </script>
	                  <%
                  }
	            }
		     }
   }
   catch(Exception e)
   {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
   }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
if(!bIsError && strMode.equalsIgnoreCase("searchDelete"))
{       
      action = "remove";
      msg = "";
      out.clear();
      response.setContentType("text/xml");
    %>
    <mxRoot>
        <!-- XSSOK -->
        <action><![CDATA[<%= action %>]]></action>
        <!-- XSSOK -->
        <message><![CDATA[    <%= msg %>    ]]></message>    
    </mxRoot>
    <%
    }
 %>
