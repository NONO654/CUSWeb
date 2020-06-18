<%--  emxVPMProductAddExisting.jsp   -   FS page for Create CAD Drawing dialog
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTestDelete.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $

   RCI - Wk03 2010 - 18 Janv - fix issue for updating tree after add
   RCI - Wk03 2010 - 19 Janv - enable multiselection for addExisting
--%>

<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMDebugUtil"%> 
<%@include file = "../components/emxComponentsUtil.inc"%> 
<%@include file = "../emxUICommonAppInclude.inc"%>

<%

	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    //VPLMDebugUtil.dumpObject(requestMap);
    String objectId = (String) requestMap.get("objectId");
	String strLoadPageMode = (String) requestMap.get ("loadPageMode");
    String prdToAddIds[] = emxGetParameterValues(request, "emxTableRowId");
    String role = (String) requestMap.get("role");
  
try
{
  ContextUtil.startTransaction(context, true);		

  Map programMap = new HashMap();
  programMap.put("objectId", objectId ); // parent Id
  programMap.put("emxTableRowId", prdToAddIds );
  programMap.put("role", role);
     

  String[] methodargs =JPO.packArgs(programMap);
				
JPO.invoke(context, "emxVPLMProdEdit", null,"addExistingPrd", methodargs);
	
ContextUtil.commitTransaction(context);
 }
catch (Exception ex)
{
	   ex.printStackTrace();
}
%>
<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUIUtility.js" type="text/javascript"></script>
<script language="Javascript" >
   top.opener.top.refreshTablePage();
   top.window.close();
  	
</script>

</body>
</html>






