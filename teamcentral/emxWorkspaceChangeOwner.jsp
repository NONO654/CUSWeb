<%--  emxWorkflowAction.jsp  --  
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxWorkflowChangeOwner.jsp.rca 1.2.2.1.7.5 Wed Oct 22 16:18:29 2008 przemek Experimental przemek $
 --%>
 
<%@page import="com.matrixone.apps.common.Person"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import = "com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
 <% 
 
 	 String URL = "";
 	 String [] workspaceId = ComponentsUIUtil.getSplitTableRowIds(request.getParameterValues("emxTableRowId"));
 	 DomainObject workspaceObj = new DomainObject(workspaceId[0]);
 	 String owner = workspaceObj.getInfo(context, DomainObject.SELECT_OWNER);
 	 String changeOwnerAccess = workspaceObj.getInfo(context, "current.access[changeowner]");
     String msg = EnoviaResourceBundle.getProperty(context, "emxTeamCentralStringResource", context.getLocale(), "emxTeamCentral.ChangeOwner.checkAccess");
     
     if("true".equalsIgnoreCase(changeOwnerAccess)) {
     	URL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&suiteKey=TeamCentral&showInitialResults=true&includeOIDprogram=emxWorkspace:getWorkspaceChangeOwnerInclusionIDs&type=PERSON_CHOOSER&selection=single&form=AEFSearchPersonForm&table=AEFPersonChooserDetails&objectId="+workspaceId[0]+"&submitURL=../teamcentral/emxWorkspaceChangeOwnerProcess.jsp";
     }
 %>
<script language="javascript">
var coa = "<%=XSSUtil.encodeForJavaScript(context,changeOwnerAccess)%>";

if("FALSE" == coa) {
	alert("<%=msg%>");
	getTopWindow().closeWindow();
} else if("TRUE" == coa){	
	getTopWindow().showModalDialog("<%=XSSUtil.encodeURLwithParsing(context, URL)%>");
} 

</script>



