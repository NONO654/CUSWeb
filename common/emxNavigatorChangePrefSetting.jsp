<%--  emxNavigatorChangePrefSetting.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxNavigatorChangePrefSetting.jsp.rca 1.8 Wed Oct 22 15:47:48 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
  String sPreferance = emxGetParameter(request, "preference");
  Vector userRoleList = PersonUtil.getAssignments(context);
  String sMode = "NOT_UPDATED";
  String ErrorMsg="";
  if (sPreferance != null && sPreferance.trim().length() > 0)
  {
      // Set the preference of content page on the property setting for Admin Person
      UINavigatorUtil.setPreferenceContentPage(context, sPreferance, userRoleList);
      sMode = "UPDATED";
  }

 if(sMode.equals("UPDATED")){
%>
<script>
	parent.window.getWindowOpener().location.reload();
	window.closeWindow();
</script>

<%}else{
 ErrorMsg = UINavigatorUtil.getI18nString("emxFramework.Commom.PreferencesError", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
%>
<script>
//XSSOK
alert("<%=ErrorMsg%>");
	window.closeWindow();
</script>
<%}%>
