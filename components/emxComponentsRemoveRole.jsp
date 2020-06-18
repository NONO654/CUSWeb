<%--  emxComponentsRemoveRole.jsp   - The Person remove Role processing page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsRemoveRole.jsp.rca 1.12 Wed Oct 22 16:18:29 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  /* Bug 356691 */
  if (!UICache.checkAccess(context, "command_CreatePersonActions")) {
    out.println("Denied");
    return;
  }

  com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person)DomainObject.newInstance(context,
                      DomainConstants.TYPE_PERSON);

  String strRole[]      = emxGetParameterValues(request, "chkRole");
  strRole = strRole == null ? com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId")) : strRole;
  String objectId       = emxGetParameter(request,"objectId");
  person.setId(objectId);
  boolean hasException = false;
  try {
	  //Added for IR-054764V6R2011x    

	  if(strRole != null)
	  {
      person.removeRoles(context, strRole);
	  }
	  else
	  {
		  %>
		  <script>
		  var strErrMsg = "<emxUtil:i18nScript localize = 'i18nId'>emxComponents.RemoveSelected.EmployeeRole</emxUtil:i18nScript>";      
		  alert(strErrMsg);
		  </script>
		<%   
	  } //Added for IR-054764V6R2011x ends   
  } catch (com.matrixone.apps.domain.util.FrameworkException ex) {
      ex.printStackTrace();
      hasException = true;
  }
%>

<script>

<%
  if(!hasException)
  {
%>
    parent.location.href = parent.location.href;
<%
  }
%>

</script>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
