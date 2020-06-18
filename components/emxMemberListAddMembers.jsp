<%--  emxMemberListAddMembers.jsp   -  Adding the members in member list
   Copyright (c) 1993-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject,
                   com.matrixone.apps.common.util.ComponentsUIUtil,
                   com.matrixone.apps.common.MemberList" %>

<%
  String memberType     = emxGetParameter(request, "memberType");
  String[] memberID     = ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));
 
  boolean showSelectItemAlert = false;
  if(memberID == null || memberID.length == 0) {
      showSelectItemAlert = true;
  } else {
      String sMemberListId  = emxGetParameter(request, "objectId");
       if(sMemberListId != null && (!sMemberListId.equals(""))) {
          DomainObject doObj1 = new DomainObject(sMemberListId);
          doObj1.open(context);
            	// Set the domain object as Member List to connect persons.
                try {
                   MemberList.addMembersToMemberList(context, sMemberListId,memberType,memberID);
                } catch(Exception ex) { 
                    ex.printStackTrace();
    %>
                    <script language="javascript">
                    	alert("<%=ex.getMessage()%>");
                    </script>
    <%
               }
            
            doObj1.close(context);
    	}
    }
%>


<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
//XSSOK
<framework:ifExpr expr="<%=showSelectItemAlert%>">
	alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Search.Error.24</emxUtil:i18nScript>");
</framework:ifExpr>

<framework:ifExpr expr="<%=!showSelectItemAlert%>">
    getTopWindow().getWindowOpener().refreshSBTable(getTopWindow().getWindowOpener().configuredTableName, getTopWindow().getWindowOpener().lSortColumnName.join(","), getTopWindow().getWindowOpener().lSortColumnDirection.join(","));
	getTopWindow().closeWindow();
</framework:ifExpr>
</script>

