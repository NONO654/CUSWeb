<%--
  EffectivityServices.jsp
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

<%@page import = "com.matrixone.apps.effectivity.EffectivityFramework"%>
<%@page import = "com.matrixone.apps.effectivity.EffectivitySettingsManager"%>

<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
 <%@page import="com.matrixone.apps.domain.util.MapList"%>
<script language="JavaScript" type="text/javascript" src="../common/emxUIConstantsJavaScriptInclude.jsp"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<%@include file = "../emxTagLibInclude.inc"%>
<%
String acceptLanguage = request.getHeader("Accept-Language");
%>
<%-- XSSOK --%>
<framework:localize id="i18nId" bundle="EffectivityStringResource" locale='<%=acceptLanguage%>'/>

<%
  out.clear();
  boolean bIsError = false;
  try
  {
     String strMode = emxGetParameter(request, "mode");
     String menuName = emxGetParameter(request, "menuName");
     String effMode = emxGetParameter(request,"EffectivityMode");
     if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equals("getModes"))
     {
    	   String effCmdName = emxGetParameter(request, "effActual");
           out.write(EffectivitySettingsManager.getEffectivityModesJSON(context, effCmdName));
    	   out.flush();
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equals("getSettings"))
     {
    	 String sEffActual = emxGetParameter(request, "effActual");
    	 String sModeActual = emxGetParameter(request, "modeActual");
    	 out.write(EffectivitySettingsManager.getAllEffectivitySettingsJSON(context, sEffActual, sModeActual));
    	 out.flush();
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equals("blankRoot"))
     {
    	%>
    	<html>
    	<head>
    	<link rel="stylesheet" type="text/css" media="screen" href="../effectivity/styles/emxUIExpressionBuilder.css" />
    	</head>
    	<body>
    	<table width="100%">
    	<tr class="even">
    	<td align="center">
    	<emxUtil:i18n localize="i18nId">Effectivity.Root.Missing</emxUtil:i18n>
    	</td>
    	</tr>
    	</table>
    	</body>
    	</html>
        <%
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("EffTypeMode"))
     {
    	 EffectivityFramework eff = new EffectivityFramework();
         Map cmd = eff.getModeSettings(context, effMode);
         StringBuffer sb = new StringBuffer();
         
         sb.append("<Mode");
         String expandProgram = (String)cmd.get(EffectivityFramework.CMD_SETTING_EXPANDPROGRAM);
         String relationship = (String)cmd.get(EffectivityFramework.CMD_SETTING_RELATIONSHIP);
         String table = (String)cmd.get(EffectivityFramework.CMD_SETTING_TABLE);
         String selection = (String)cmd.get(EffectivityFramework.CMD_SETTING_SELECTION);
         String allowRange = (String)cmd.get(EffectivityFramework.CMD_SETTING_ALLOWRANGE);
         String registeredSuite = (String)cmd.get(EffectivityFramework.CMD_SETTING_REGISTEREDSUITE);
         sb.append(" table=");
         sb.append("\"");
         sb.append(table);
         sb.append("\"");
         sb.append(" relationship=");
         sb.append("\"");
         sb.append(relationship);
         sb.append("\"");
         sb.append(" expandProgram=");
         sb.append("\"");
         sb.append(expandProgram);
         sb.append("\"");
         sb.append(" selection=");
         sb.append("\"");
         sb.append(selection);
         sb.append("\"");
         sb.append(" allowRange=");
         sb.append("\"");
         sb.append(allowRange);
         sb.append("\"");
         sb.append(" registeredSuite=");
         sb.append("\"");
         sb.append(registeredSuite);
         sb.append("\"");
         sb.append(">");
         sb.append("</Mode>");
         out.write(sb.toString());
         out.flush();
         
     }
     
  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
  }// End of main Try-catck block
%>
