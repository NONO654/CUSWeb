<%--
  MyDeskCreateVariabilityOptionPostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="java.util.HashMap"%>

<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>

<%
  try
  {
	  HashMap paramMap     = new HashMap();    
	  String  relType      = "";  
      String  strNewObjId  = emxGetParameter(request, "newObjectId");
      String  strJsTreeID  = emxGetParameter(request, "jsTreeID");
      String  strObjectId  = emxGetParameter(request, "objectId");
      String  strParentOID = emxGetParameter(request, "parentOID");
      String  featureType  = emxGetParameter(request,"TypeActual");
      
      if(featureType != null && !"".equals(featureType))
      {
          relType = "relationship_GroupedVariabilityCriteria";
      }       
  		
      // Create Variability Option Object from My Desk Context under Variability Group.
      paramMap.put("newObjectId", strNewObjId);
      paramMap.put("languageStr",(String) emxGetParameter(request,"languageStr"));
      paramMap.put("relId",(String) emxGetParameter(request,"relId"));
      paramMap.put("objectCreation","New");
      paramMap.put("objectId", strObjectId);  
      paramMap.put("parentOID", strParentOID);
          
      String xml = ConfigurationFeature.getXMLForSBCreate(context, paramMap, relType);
      xml = xml.replaceAll("pending", "committed");
      %>
      	  <script language="javascript" type="text/javaScript">
                var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),"content");                
                contentFrameObj.emxEditableTable.addToSelected(strXml);
          </script>
      <%    
  }
  catch(Exception e)
  {
	  String strErrorMessage = e.getMessage();
	  if(strErrorMessage.contains("1500789")){
		  strErrorMessage = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.NotUniqueMsg", new Locale(request.getHeader("Accept-Language")));
	  }
	  session.putValue("error.message", strErrorMessage);
  }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
