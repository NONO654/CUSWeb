<%--  emxVPMProposeAddExistingDocument.jsp   -   
   Copyright (c) 2010 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTestDelete.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $

   RCI - Wk36 2010 - Creation
   RCI - Wk45 2010 - RI 77706   - adaptation à jsp hidden - ATTENTION pour correction complete, passer selectedOID comme objectId dans programMap
   RCI - Wk02 2011 - RI 77706   - ... suite ! on recupere selectedOID en argument de SubmitURL et c'est lui qu'on passe pour addExistingDocument

--%>


<%@include file = "../components/emxComponentsUtil.inc"%> 
<%@include file = "../emxUICommonAppInclude.inc"%>



<%

    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
//	System.out.println("sump en entree de Dco ");
//	VPLMDebugUtil.dumpObject(requestMap);
	
    String objectId      = (String) requestMap.get("objectId");
    String prdToAddIds[] = emxGetParameterValues(request, "emxTableRowId");
    String treeRoot      = (String ) requestMap.get("objectId");
	
    String selectedOID   = (String ) requestMap.get("selectedOID"); // to add to method Args as selectedOID
    String role = (String) requestMap.get("role");
	
	//System.out.println("....................... doc treeRoot = "+treeRoot);
	//System.out.println("....................... doc objectId = "+objectId);
	//System.out.println("....................... doc selectedOID = "+selectedOID); 
	
  try
{
  ContextUtil.startTransaction(context, true);		

  Map programMap = new HashMap();
  
  programMap.put("objectId", selectedOID ); // mettre selectedOID
  programMap.put("emxTableRowId", prdToAddIds );
  programMap.put("treeRoot", treeRoot );
  programMap.put("role", role);
 
  String[] methodargs =JPO.packArgs(programMap);
				
JPO.invoke(context, "emxVPLMPropose", null,"addExistingDocument", methodargs);
	
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








