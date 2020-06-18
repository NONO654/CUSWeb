

<%-- AssignResourceUsagePostProcess.jsp  -

   Display Page for the Create New Resource Usage
   Copyright (c) 1999-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/ResourceUsageCreateDialog.jsp 1.4.2.2.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>

<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxValidationInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "GlobalSettingInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.configuration.ResourceUsage"%>

<%
	/* boolean, set to true, incase of any error */
	boolean bFlag=false;
	/* Resource Id to connect the Feature List to the Fixed Resource */
	String strResourceId = "";
	String strMode = emxGetParameter(request,"mode");
	
try{
	
    if ( strMode.equalsIgnoreCase("create")  )
    {
      
      StringBuffer strBuffer = new StringBuffer();
      Enumeration enumParamNames = emxGetParameterNames(request);
      while(enumParamNames.hasMoreElements())
      {
        String paramName = (String) enumParamNames.nextElement();
        String paramValue = emxGetParameter(request,paramName);
        strBuffer.append("&");
        strBuffer.append(paramName);
        strBuffer.append("=");
        strBuffer.append(paramValue);
      }
      
      String strUsageValue = emxGetParameter(request, "txtUsage");
      String strRadOperation = emxGetParameter(request, "radOperation");
      String strRelId = emxGetParameter(request, "selFOPair");
      strResourceId = emxGetParameter(request, "RuleId");
      
      
      HashMap objAttributeMap = new HashMap();
      objAttributeMap.put("strUsage",strUsageValue);
      objAttributeMap.put("strResourceOperation",strRadOperation);
      
      ResourceUsage ResrcUsage = new ResourceUsage();
      ResrcUsage.createResourceUsageConnection(context,	strResourceId, strRelId, objAttributeMap);    		                                                                
    } // End of create
} catch(Exception e) {
    bFlag=true;
    session.putValue("error.message", e.getMessage());
 } // End of try
%>	
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>


<%
    if (bFlag)
    {
%>
    <!--Javascript to bring back to the previous page-->
    <script language="javascript" type="text/javaScript">
    history.back();
    </script>
<%
    }else{%>
    <script language="javascript" type="text/javaScript">
   
    var isFF  = Browser.FIREFOX;
    
    var refFrameObj1 = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"FTRResourceRulesCommand"); 
    var refFrameObj2 = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"FTRProductVariantResourceRulesCommand");
    
    if(refFrameObj1 != null){
    	refFrameObj1.location.href = refFrameObj1.location.href;
    }else if(refFrameObj2 != null)
    {
    	refFrameObj2.location.href = refFrameObj2.location.href;
    }else {
    	getTopWindow().getWindowOpener().parent.location = getTopWindow().getWindowOpener().parent.location;
    }
    
    if(isFF){
    	getTopWindow().close();
    }else{
    	getTopWindow().closeWindow();
    }
    
    </script>
<%}
%>
