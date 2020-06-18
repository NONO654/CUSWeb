
<%--
  EffectivityUtil.jsp
  Copyright (c) 1993-2015 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException" %>
<%@page import = "com.matrixone.apps.effectivity.EffectivityFramework"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="java.util.HashMap"%>

<%@page import="org.apache.http.entity.StringEntity"%>
<%@page import = "com.matrixone.json.JSONObject"%>
<%@page import = "com.dassault_systemes.enovia.changeaction.interfaces.IChangeAction"%>
<%@page import = "com.dassault_systemes.enovia.changeaction.factory.ChangeActionFactory"%>
<%@page import = "com.dassault_systemes.enovia.changeaction.interfaces.IChangeActionServices"%>

<script language="JavaScript" type="text/javascript" src="../common/emxUIConstantsJavaScriptInclude.jsp"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

<%@ page import="com.matrixone.apps.common.Person,com.matrixone.apps.domain.util.PersonUtil,java.net.URL,java.net.URLConnection,java.net.HttpURLConnection" %>
<%@ page import="java.lang.reflect.*,java.net.URLEncoder,org.apache.http.StatusLine,org.apache.http.params.*,org.apache.http.client.methods.*,org.apache.http.impl.client.DefaultHttpClient,org.apache.commons.io.IOUtils,org.apache.http.HttpEntity,org.apache.http.HttpResponse" %>
<%
  out.clear();
  boolean bIsError = false;
  String display = "";
  try
  {
	 
     String strMode = emxGetParameter(request, "mode");
     String effType = emxGetParameter(request, "effType");
     String effExpr = emxGetParameter(request,"effExpr");

     String strDisplay = emxGetParameter(request, "displayString");
     String strActual = emxGetParameter(request, "actualString");
     String keyInValue = emxGetParameter(request, "keyInValue");
     String currentEffExprActual = emxGetParameter(request, "currentEffExprActual");
     String includeContextList = emxGetParameter(request, "includeContextList");
     String globalContextPhyId = emxGetParameter(request, "globalContextPhyId");
     
     String strChangeActionId = emxGetParameter(request, "CAPID");

	 if("CAApplicability".equalsIgnoreCase(strMode))
     {
         try
         {
  
          	 ContextUtil.startTransaction(context, true);
             String streffExpr = emxGetParameter(request, "actualExp");            
 			 HashMap paramMap = new HashMap();
             HashMap programMap = new HashMap();
             paramMap.put("New Value", streffExpr);
             programMap.put("paramMap", paramMap);
             String[] args = JPO.packArgs(programMap);
             EffectivityFramework ef = new EffectivityFramework();
             String strXMLExpression = ef.getXMLExpressionForApplicability(context, args);
             strXMLExpression=strXMLExpression.replace("\\\"","\"");           
             IChangeActionServices iCaServices = ChangeActionFactory.CreateChangeActionFactory();
     		IChangeAction iCa = iCaServices.retrieveChangeActionFromDatabase(context, strChangeActionId);
     		iCa.SetApplicabilityExpression(context, strXMLExpression);
     		 ContextUtil.commitTransaction(context);
         }catch(Exception ex)
         {
        	 ContextUtil.abortTransaction(context);
             out.println("ERROR:"+ex.getMessage());
         }
     }	 
  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
  }// End of main Try-catck block
%>

