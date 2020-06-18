<%--  CPVPostProcess.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
--%>
<!--This page is called when user sets his pref and clicks on done -->
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
Locale locale = new Locale((String)request.getHeader("Accept-Language"));

HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
//Saving user preferncesto db.
HashMap args = new HashMap();
args.put("requestMap", requestMap);
JPO.invoke(context, "DELJMyDeskUtil", null, "saveUserPreferences", JPO.packArgs(args), null);

String sPrefrenceLabel = EnoviaResourceBundle.getProperty(context,"emxVPLMProcessEditorStringResource", locale,"emxVPLMProcessEditor.Label.Preferences");
String sPPRObjectType = emxGetParameter(request,"PPRObjectType");
String sToDateMSValue = emxGetParameter(request,"ToDate_msvalue");
String sType = emxGetParameter(request,"type");
String sFrameName = emxGetParameter(request,"openerFrame");

//forming map for getSubHeaderForUI function
HashMap argsMap = new HashMap();
argsMap.put("type", sPPRObjectType);
argsMap.put("toDateMSValue", sToDateMSValue);

String sViewLabelSubHeader = (String) JPO.invoke(context, "DELJMyDeskUtil", null, "getSubHeaderForUI", JPO.packArgs(argsMap), String.class);
%>
<script language="javascript">

//froming the url for href
var url = window.location.href;
var replaceFrom = "emxFormEditProcess.jsp";
var appendURL   = "emxIndentedTable.jsp?program=DELJMyDeskUtil:findMyObjects&table=CPVMyDeskTable&sortColumnName=Name&sortDirection=ascending&massPromoteDemote=false&triggerValidation=false&selection=multiple&mode=view&header=<%=XSSUtil.encodeForJavaScript(context, sPrefrenceLabel)%>&PPRObjectType=<%=XSSUtil.encodeForJavaScript(context, sPPRObjectType)%>&type=<%=XSSUtil.encodeForJavaScript(context, sType)%>&toolbar=CPVPreferencesToolbar&showTabHeader=true&subHeader=<%=XSSUtil.encodeForJavaScript(context, sViewLabelSubHeader)%>";
url = url.replace(replaceFrom, appendURL);

//refreshing the iframe
var framewindow = getTopWindow().findFrame(getTopWindow(),"<%=XSSUtil.encodeForJavaScript(context, sFrameName)%>");
framewindow.location.href = url;

//closing the slidein window
var slideInFrame = getTopWindow().findFrame(getTopWindow(),"slideInFrame");
slideInFrame.close();

</script>



