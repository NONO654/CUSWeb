<%-- emxVPMProposedAddExistingHidden.jsp

    Copyright (c) 1992-2010 Enovia Dassault Systemes.All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only and does not evidence any actual
    or intended publication of such program

    static const char RCSID[] =$Id: /web/common/emxVPMProposedAddExistingHidden.jsp 1.1 Fri Oct 1 16:45:25 2010 GMT ds-panem Experimental$

	RCI - Wk44 2010 - RI 76435 / - jsp hidden pour eviter ecrasement du à emxFullSearch.jsp
	RCI - Wk45 2010 - RI 77706   - adaptation pour attachDocument ( ecrasement du à emxCommonSearch.jsp )
	RCI - Wk02 2011 - RI 77706   - suite ... on passe SubmitURL avec bonne info dans le cas attachExistingDocument
    RCI - Wk19 2011 - RI 104628  - Perfos showProposeCmds - On decale le check de la validité de la commande au lancement de la commande
    OWX - Wk29 2011 - RI 120818 - Do not show Search Panel when proposal log has not been created + enhance error message 
    RCI - Wk22 2013 - RI 202511 - Reprise gestion ctx : remplacer getMainContext par getFrameContext
    RCI - Wk44 2013 - RI 225093 - pb display Search panel ...due to html tags, and HTML5.0 and scripts order ...
    VZB - Wk40 2017 - FUN063474 - ENOVIA Classification WebProduct 3DSearch adoption

--%>

<!DOCTYPE html>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.MessageUtil"%>
<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.VPLMJSRMPropose.VPLMJProposeAccess"%>
<%@page import="com.dassault_systemes.vplm.modeler.exception.PLMxModelerException"%>
<%@page import="com.matrixone.vplm.m1mapping.MappingManager"%>

<%@page import="matrix.util.StringList"%>
<%@page import="matrix.util.Pattern"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../components/emxComponentsCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<!--emxUIConstants.js is included to call the findFrame() method to get a frame-->
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<body>
<%
	String strObjId = emxGetParameter(request, "objectId");
	String strMode = emxGetParameter(request,"mode");
	String treeRoot = emxGetParameter(request, "objectId");
    	String selectedOIDs[] = emxGetParameterValues(request, "emxTableRowId");
    	String selectedOID = selectedOIDs[0];

		//System.out.println("....................... Hidden treeRoot = "+treeRoot);
		//System.out.println("....................... Hidden objectId = "+strObjId);
		//System.out.println(".......................Hidden selectedOID = "+selectedOID);
	    //System.out.println("....................... strMode = "+strMode);
	
	
	    String jsTreeID = emxGetParameter(request, "jsTreeID");
		String uiType = emxGetParameter(request,"uiType");
		String strMode1 = emxGetParameter(request,"context");
		String suiteKey = emxGetParameter(request, "suiteKey");
		String registeredSuite = emxGetParameter(request,"SuiteDirectory");
		

	  
	   Context frameCtx = Framework.getFrameContext(session); 
		try
		{

       String role = frameCtx.getRole();
	    // Check PrivateRep validity
		Boolean isValid = false;
		Boolean bErrorCatched = true;
		try
		{
			VPLMJProposeAccess  proposeAccess  =  VPLMJProposeAccess.getInstance();
			isValid = proposeAccess.checkProposalValidity(frameCtx, strObjId, role);
			bErrorCatched = false;
		}
		catch (PLMxModelerException mEx)
		{
			// stream not found => process not initialized
			String msgTitle = UINavigatorUtil.getI18nString("emxVPMSRMPropCmds.Command.Initialization.Warning",  "emxVPLMSRMServicesStringResource",  request.getHeader("Accept-Language"));
			emxNavErrorObject.addMessage(msgTitle); 
		}
		catch (Exception ex)
		{ 
			// Undefined Error
			String msgTitle = UINavigatorUtil.getI18nString("emxVPMSRMPropCmds.Command.Undefined.Error",  "emxVPLMSRMServicesStringResource",  request.getHeader("Accept-Language"));
			emxNavErrorObject.addMessage(msgTitle); 
		}
		
		if ( true == isValid )
		{
			
			if(strMode.equalsIgnoreCase("addExisting"))
			{

                //MUT R217 NameMappingRemoval Migration
                if(com.matrixone.vplm.m1mapping.MappingManager.nameMapping())
                {
                    // old names
                    %>
	                        <script language="javascript" type="text/javaScript">
	                        var sURL="../common/emxFullSearch.jsp?treeRoot=<%=treeRoot%>&selectedOID=<%=selectedOID%>&field=TYPES=type_VPLMtyp@VPMReference,type_VPLMtyp@VPMRepReference&table=AEFGeneralSearchResults&selection=multiple&showInitialResults=false&submitAction=refreshCaller&header=searchresult&submitURL=../common/emxVPMProposeAddExisting.jsp";
		                    showChooser(sURL, 850, 630);
	                        </script>
                    <%
                }
                else
                {
                    // new names
                    %>
	                        <script language="javascript" type="text/javaScript">
	                        var sURL="../common/emxFullSearch.jsp?treeRoot=<%=treeRoot%>&selectedOID=<%=selectedOID%>&field=TYPES=type_VPMReference,type_VPMRepReference&table=AEFGeneralSearchResults&selection=multiple&showInitialResults=false&submitAction=refreshCaller&header=searchresult&submitURL=../common/emxVPMProposeAddExisting.jsp";
		                    showChooser(sURL, 850, 630);
	                        </script>
                    <%
                }
                //MUT R217 NameMappingRemoval Migration
    		}
			else if (strMode.equalsIgnoreCase("attachExistingDocument"))
			{
%>
               <script language="javascript" type="text/javaScript">
               var sURL="../common/emxFullSearch.jsp?treeRoot=<%=treeRoot%>&selectedOID=<%=selectedOID%>&objectId=<%=strObjId%>&field=TYPES=type_DOCUMENTS:IS_VERSION_OBJECT!=True&table=IssueSearchDocumentTable&selection=multiple&showInitialResults=false&submitAction=refreshCaller&header=searchresult&submitURL=../common/emxVPMProposeAddExistingDocument.jsp?selectedOID=<%=selectedOID%>";
               showChooser(sURL, 850, 630);
               </script>
<%
			}
		}
		else if(false == bErrorCatched)
		{
			// Exceptions have been catch earlier then we found stream and complete validation process 
			// stream not valid => case of duplicated reference (which lead to duplication of log proposal)
			// For now, no message, but in the future we may want a dedicated message to identify such a situation
			//String msgTitle = UINavigatorUtil.getI18nString("emxVPMSRMPropCmds.Command.ProposeCmds.Warning",  "emxVPLMSRMServicesStringResource",  request.getHeader("Accept-Language"));
			//emxNavErrorObject.addMessage(msgTitle); 
		}

		}
		catch(Exception e)
		{
		   session.putValue("error.message", e.toString());
			   e.printStackTrace();
		}

finally
{
	frameCtx.shutdown();
}
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
