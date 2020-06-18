<%--  emxVPLMRequestLaunchBatch.jsp   -   
   Copyright (c) 2010 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxVPLMRequestProposal.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $
   
   -- Wk22 2013 - RCI - RI 202511 - Reprise gestion ctx : remplacer getMainContext par getFrameContext
   
--%>
<%@ page import = "java.util.List" %>
<%@ page import = "java.util.ArrayList" %>

<%@ page import = "com.dassault_systemes.vplm.modeler.PLMCoreModelerSession" %>
<%@ page import = "com.dassault_systemes.vplm.productNav.interfaces.IVPLMProductNav" %>
<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMJWebToolsM1Util" %>
<%@ page import = "com.dassault_systemes.vplm.interfaces.access.IPLMxCoreAccess" %>

<%@include file = "../components/emxComponentsUtil.inc"%> 
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%

   HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
 
      String rowIds[] = emxGetParameterValues(request, "emxTableRowId");
      String role = (String) requestMap.get("role");
      String objectId = (String) requestMap.get("objectId");
      //String user = (String) requestMap.get("user");

	  Context frameCtx = Framework.getFrameContext(session);
	 try
	 {
      Map programMap = new HashMap();
	  //programMap.put("emxTableRowId", rowIds);
      programMap.put("objectId", objectId);
	  programMap.put("Context", frameCtx);
	 
	 List m1idList = new ArrayList(1); 
	m1idList.add(objectId);
       PLMCoreModelerSession sessionCore = PLMCoreModelerSession.getPLMCoreModelerSession(frameCtx.getUser(), frameCtx.getPassword(), frameCtx.getRole());
	   sessionCore.openSession();
	   IPLMxCoreAccess  coreAccess  =  sessionCore.getVPLMAccess(); 
	   IVPLMProductNav modelerNav = (IVPLMProductNav)sessionCore.getModeler("com.dassault_systemes.vplm.productNav.implementation.VPLMProductNav");
//	   VPLMJWebToolsM1Util    instM1UtilTools    =    VPLMJWebToolsM1Util.getM1UtilInstance();      
//	   String itemId  =  instM1UtilTools.getPlmExternalId(objectId,  modelerNav,  coreAccess); 
String itemId="";          // ATTENTION sur les  niveaux pre 2014x, iTemId non nul ....
	  
	  String[] plmId= ((IVPLMProductNav) modelerNav).getPLMObjectIdentifiers(m1idList);
	//  Attention doit être un plmExternalID, encodé Java 
		 programMap.put("CTF_Name",  itemId);
		
	String[] methodargs =JPO.packArgs(programMap);
	JPO.invoke(context, "RNDEX_Proposal", null,"createProposalFileJob", methodargs);	
	
 }
catch (Exception ex)
{
	ex.printStackTrace();
	   
}
finally
{
	frameCtx.shutdown();
}

%>
 <%@include file = "emxNavigatorBottomErrorInclude.inc"%>

<html>
<body>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" >

// remise à jour de la page

   // top.refreshTablePage();	
</script>


</body>
</html>

 


