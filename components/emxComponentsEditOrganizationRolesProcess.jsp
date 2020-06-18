<%--  emxComponentsEditOrganizationRolesProcess.jsp   -   Edit a persons roles

   Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsEditOrganizationRolesProcess.jsp.rca 1.8 Wed Oct 22 16:18:15 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.common.Organization"%>

<%
  String objectId = emxGetParameter(request,"objectId");
  String relId = emxGetParameter(request,"relId");
  
  String selectedRoles[] = emxGetParameterValues(request, "roleAlias");
  
  Organization.setMemberRoles(context, relId, selectedRoles);
/*Begin of add by Infosys for Bug # 301242 on 3/31/2005*/
  //clear the persons RDO cache
  BusinessObject personBusObj = new BusinessObject(objectId);
  personBusObj.open(context);
  String userName = personBusObj.getName();
  personBusObj.close(context);
  PersonUtil.clearUserCacheProperty(context, userName, "RDO");
  // clear application cache too
  HashMap paramMap = new HashMap();
  paramMap.put("userName", userName);
  paramMap.put("propertyName", "RDO");
  String[] methodargs = JPO.packArgs(paramMap);
  JPO.invoke(context, "emxUtil", null, "clearPersonCacheProperty", methodargs);
/*End of add by Infosys for Bug # 301242 on 3/31/2005*/

  String selectedLeadRoles[] = emxGetParameterValues(request, "LeadRole");
  int iResult = Organization.checkOrganizationRole(context,objectId,relId,selectedLeadRoles);
  String iResult2 = Organization.checkLeadRoleAssign(context,objectId,relId,selectedLeadRoles);
  
  if(iResult!=1 && iResult2.equals(""))
  {

	  int iResult3 = Organization.setLeadRoles(context,objectId,relId,selectedLeadRoles);
  }


%>
<script language="javascript">
	<% if (iResult==1) { %>
		alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.CheckOrganizationRole</emxUtil:i18nScript>");
		history.back();
	<% } else { %>

	<% 	if (!iResult2.equals("")) {  String sIDs[] = iResult2.split("#");  
			
		 for(int index = 0; index < sIDs.length-1; index+=2)
		{
			String attValue = DomainRelationship.getAttributeValue(context,sIDs[index],DomainConstants.ATTRIBUTE_PROJECT_ROLE);
						String attPutValue = "";
			if(attValue.contains("~")) {
			String attValueArr [] = attValue.split("~");
			for(int index1 = 0; index1<attValueArr.length ; index1++)
			{
				if(!(sIDs[index+1].equals(attValueArr[index1])))
				{
					attPutValue += attValueArr[index1] + "~" ;
			}
			}
			attPutValue = attPutValue.substring(0,attPutValue.length()-1);
			}
			DomainRelationship.setAttributeValue(context,sIDs[index],DomainConstants.ATTRIBUTE_PROJECT_ROLE,attPutValue);
		}
			Organization.setLeadRoles(context,objectId,relId,selectedLeadRoles);
	} %>
      parent.window.getWindowOpener().location.href=parent.window.getWindowOpener().location.href;
      window.closeWindow();
  <% } %>

</script>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
