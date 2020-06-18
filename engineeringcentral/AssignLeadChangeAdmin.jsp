<%--  AssignLeadChangeAdmin.jsp   -  This page disconnects the selected objectIds
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsConfigurableTablePeopleDisconnectProcess.jsp.rca 1.8 Wed Oct 22 16:18:25 2008 przemek Experimental przemek $
--%>


<%@include file = "../components/emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.common.Company" %>

<%
  DomainObject rel = DomainObject.newInstance(context);

  String jsTreeID 	= emxGetParameter(request,"jsTreeID");
  String objectId 	= emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey 	= emxGetParameter(request,"suiteKey");
  String summaryPage = emxGetParameter(request,"summaryPage");
  String relId = emxGetParameter(request,"relId");
  
  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");

	StringTokenizer st = new StringTokenizer(checkBoxId[0], "|");
	String sMemeberRelId = st.nextToken();
    String sPersonObjId = st.nextToken();
    String sCompanyOId = Company.getHostCompany(context);
	String result = MqlUtil.mqlCommand(context, "print bus $1 select $2 dump",sPersonObjId,"relationship[Lead Responsibility]");

	if ("True".equals(result))
		return;

		System.out.println("~~~Eng Debug: sMemeberRelId : "+sMemeberRelId);
		System.out.println("~~~Eng Debug: sPersonObjId : "+sPersonObjId);
		System.out.println("~~~Eng Debug: sCompanyOId : "+sCompanyOId);
	try {
	String iResult2 = Organization.checkLeadRoleAssign(context, sPersonObjId, sMemeberRelId, new String[] {"role_ECRChairman","role_ECRCoordinator"});
	System.out.println("~~~Eng Debug:  iResult2 : "+iResult2);

    if (UIUtil.isNullOrEmpty(iResult2)) {
	   MqlUtil.mqlCommand(context, "connect bus $1 rel $2 to $3 $4 $5", true,sCompanyOId,"Lead Responsibility",sPersonObjId,"Project Role","role_ECRCoordinator~role_ECRChairman");
    } else {
    	StringList leadRelList = FrameworkUtil.split(iResult2,"#");
    	DomainRelationship.disconnect(context, (String) leadRelList.get(0));
	MqlUtil.mqlCommand(context, "connect bus $1 rel $2 to $3 $4 $5", true,sCompanyOId,"Lead Responsibility",sPersonObjId,"Project Role","role_ECRCoordinator~role_ECRChairman");

    }
	} catch (Exception e) {
		   e.printStackTrace();
	}
%>

<%@include file = "../components/emxComponentsDesignBottomInclude.inc"%>
<script language="Javascript">
  var tree = getTopWindow().objDetailsTree;
  var isRootId = false;

    if(isRootId) {
      var url =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + parentId + "&emxSuiteDirectory=<%=XSSUtil.encodeForURL(context, appDirectory)%>";
      var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
      if (contentFrame) {
        contentFrame.location.replace(url);
      }
      else {
		 if(getTopWindow().refreshTablePage) {
        getTopWindow().refreshTablePage();
         }  
         else {   
         	getTopWindow().location.href = getTopWindow().location.href;
         }      
      }
    } else {
      	if(getTopWindow().refreshTablePage) {  
      getTopWindow().refreshTablePage();
        }  
        else {  
        	getTopWindow().location.href = getTopWindow().location.href;
        }
    }
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

