<%--  emxLibSkillDeleteProcess.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsSkillDeleteProcess.jsp.rca 1.7 Wed Oct 22 16:18:23 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil" %>
<%@page import="matrix.util.StringList"%>
<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

String[] strBusinessSkillRowId = emxGetParameterValues(request,"emxTableRowId");
StringList slBusinessSkillIds =  new StringList();
String[] strBusinessSkillIds =  new String[strBusinessSkillRowId.length];

    for(int i = 0; i < strBusinessSkillRowId.length; i++)
    {
        slBusinessSkillIds = FrameworkUtil.split(strBusinessSkillRowId[i], "|");
        strBusinessSkillIds[i] = (String)slBusinessSkillIds.get(1);
    }

try
{
 if (strBusinessSkillIds.length > 0 )
  {
    Object ob = JPO.invoke(context, "emxBusinessSkill", null, "DeleteBusinessSkills", strBusinessSkillIds, Object.class );
    %>
    <script language="javascript" src="../common/scripts/emxUICore.js"></script>
    <script language="javascript" type="text/javascript">
   // Modification for the IR  IR-011295V6R2010x 
    var objDetailsTree = getTopWindow().objDetailsTree;
    var objStructureTree = getTopWindow().objStructureTree;

 if(objDetailsTree != null)
    {
   	  parent.document.location.href = parent.document.location.href;
    <%
    for(int i = 0; i < strBusinessSkillIds.length; i++)
    {
%>
    	objDetailsTree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, strBusinessSkillIds[i])%>", false);
    	objStructureTree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, strBusinessSkillIds[i])%>",false);
<%
    }
%>
   objDetailsTree.refresh();
}
   var displayFrame = getTopWindow().findFrame(getTopWindow(),"emxUIStructureTree");
   if(displayFrame != null)
     {
	    objStructureTree.refresh();
     }
   //End of modification for the IR  IR-011295V6R2010x /
    </script>
    
  <%   
  }
} 
catch (Exception ex)
{
    throw ex;
}
%>
<script language="javascript" type="text/javascript">
//Modified:ixe:R210:bug-IR-014582
     window.parent.location = window.parent.location;
   // window.parent.location.reload(true);
     window.closeWindow();
  </script>

