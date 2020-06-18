<%--  emxComponentsLocationRemove.jsp  - Removes the Locations.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsLocationRemove.jsp.rca 1.9 Wed Oct 22 16:17:56 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>

<!-- content begins here -->

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  String strObjectId = emxGetParameter(request,"objectId");
  String strDelIds = "";

  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");

  String selectedRelIds[] = new String[checkBoxId.length];    
  if(checkBoxId != null)
  {
    StringTokenizer st = null;
    String sRelId = "";
    String sObjId = "";
    for(int i=0;i<checkBoxId.length;i++)
    {
        st = new StringTokenizer(checkBoxId[i], "|");
        sRelId = st.nextToken();
        sObjId = st.nextToken();
        
        strDelIds += sObjId + ";";
        selectedRelIds[i] = sRelId;
    }

    DomainRelationship.disconnect(context,selectedRelIds);
  }
%>
<script language="javascript">
    var tree = getTopWindow().objStructureTree;
    if(tree != null && tree.root != null)
    {

<%
  StringTokenizer sIdsToken = new StringTokenizer(strDelIds,";",false);
  String strObjId = "";
  while (sIdsToken.hasMoreTokens()) 
  {
    strObjId = sIdsToken.nextToken();
%>
    tree.deleteObject('<%=XSSUtil.encodeForJavaScript(context, strObjId)%>');
<%
  }
%>
    }
      getTopWindow().refreshTablePage();
</script>
  
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>  
