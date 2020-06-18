<%--  emxComponentsPeopleDeactivateProcess.jsp   -  This page activates/deactivates the selected objectIds
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPeopleDeactivateProcess.jsp.rca 1.5.2.1 Wed Dec 17 10:28:41 2008 ds-arsingh Experimental $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import = "matrix.util.*,java.util.*,com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*" %>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<META http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<html><body></body></html>

<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />

<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  StringBuffer str = new StringBuffer();
  
  boolean userflag = false;
  boolean activeflag = false;
  String selectedUser = "";
  for (int i=0; i<checkBoxId.length; i++){
	  StringList ids = FrameworkUtil.split(checkBoxId[i], "|");
	  String personId = (String)ids.get(1);
	  
	  String stateActive = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_PERSON, "state_Inactive");
      DomainObject domObject = new DomainObject(personId);
      domObject.open(context);
      String sState = domObject.getInfo(context,DomainObject.SELECT_CURRENT);
      selectedUser = domObject.getInfo(context,DomainObject.SELECT_NAME); 
      if(selectedUser.equals(context.getUser())) {
          userflag = true;
          break;
      }
      if(sState.equals(stateActive))
      {
    	  activeflag = true;
    	  break;
      }
      str.append(personId).append(',');
  }   
 
if(userflag)
	{
%>
<script language="Javascript">
    alert("<emxUtil:i18n localize="i18nId">emxComponents.Alert.DeactivatePeopleErrorMessage</emxUtil:i18n>"+": <%=XSSUtil.encodeForJavaScript(context, selectedUser)%>");     
    </script>
    <%
	}
else if(activeflag)
{
%>
<script language="Javascript">
    alert("<emxUtil:i18n localize="i18nId">emxComponents.Alert.InactiveUserSelection</emxUtil:i18n>");     
    </script>
<% 	
}
else
	{
		if(str.length() > 0)
			str.deleteCharAt(str.length()-1);
	%>
<script language="Javascript">
    var removeLicenses;
    var strUrl;
    var answer = confirm ("<emxUtil:i18n localize="i18nId">emxComponents.Common.Licensing.InactiveUserConfirmation</emxUtil:i18n>");
    if (answer) {
        removeLicenses = "true";
    }else {
        removeLicenses = "false";
    }
    strUrl = "../components/emxComponentsPeopleDeactivatePostProcess.jsp?checkBoxIds=<%=XSSUtil.encodeForURL(context, str.toString())%>&jsTreeID=<%=XSSUtil.encodeForURL(context, jsTreeID)%>&initSource=<%=XSSUtil.encodeForURL(context, initSource)%>&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>&removeLicenses="+removeLicenses;
    var frameName = findFrame(getTopWindow(),"listHidden");
    submitWithCSRF(strUrl,frameName);
</script>	
<%
	}

%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

