<%-- emxVPMProposedReplaceHidden.jsp

    Copyright (c) 1992-2010 Enovia Dassault Systemes.All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only and does not evidence any actual
    or intended publication of such program

    static const char RCSID[] =$Id: /web/common/emxVPMProposedAddExistingHidden.jsp 1.1 Fri Oct 1 16:45:25 2010 GMT ds-panem Experimental$

	RCI - Wk01 2011 - RI 88526 - jsp hidden pour eviter ecrasement du à emxFullSearch.jsp
	RCI - Wk19 2011 - RI 104628  - Perfos showProposeCmds - On decale le check de la validité de la commande au lancement de la commande
	OWX - Wk29 2011 - RI 120818 - Do not show Search Panel when proposal log has not been created + enhance error message
    RCI - Wk02 2013 - RI 202511 - Reprise gestion ctx : remplacer getMainContext par getFrameContext
    RCI - Wk22 2013 - RI 202511 - Reprise gestion ctx : remplacer getMainContext par getFrameContext

--%>

<html>
<head>
<title></title>
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

<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../components/emxComponentsCommonInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>

<!--emxUIConstants.js is included to call the findFrame() method to get a frame-->
<jsp:useBean id="tableBean"
	class="com.matrixone.apps.framework.ui.UITable" scope="session" />
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
</head>

<body>
<%
	String strObjId = emxGetParameter(request, "objectId");
	String strMode = emxGetParameter(request,"mode");
	
		String treeRoot = emxGetParameter(request, "objectId");
    	String selectedOIDs[] = emxGetParameterValues(request, "emxTableRowId");
    	String selectedOID = selectedOIDs[0];

		//System.out.println("....................... Hidden Replace treeRoot = "+treeRoot);
		//System.out.println("....................... Hidden Replace objectId = "+strObjId);
		//System.out.println("....................... Hidden Replace selectedOID = "+selectedOID);
	    //System.out.println("....................... Hidden Replace strMode = "+strMode);
	
	
	    String jsTreeID = emxGetParameter(request, "jsTreeID");
		String uiType = emxGetParameter(request,"uiType");
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
			String msgTitle = UINavigatorUtil.getI18nString("emxVPMSRMPropCmds.Command.Undefined.Error",  "emxVPLMSRMServicesStringResource",  request.getHeader("Accept-Language"));
			emxNavErrorObject.addMessage(msgTitle); 
		}
				
		
		if ( true == isValid ) // show search panel only of check validity has been successful
		{
			if(strMode.equalsIgnoreCase("product"))
			{
                //MUT R217 NameMappingRemoval Migration
                if(com.matrixone.vplm.m1mapping.MappingManager.nameMapping())
                {
                    %>
                    <script language="javascript" type="text/javaScript">
	                        var sURL="../common/emxFullSearch.jsp?treeRoot=<%=treeRoot%>&selectedOID=<%=selectedOID%>&field=TYPES=type_VPLMtyp@VPMReference&table=AEFGeneralSearchResults&selection=multiple&showInitialResults=false&submitAction=refreshCaller&header=searchresult&submitURL=../common/emxVPMProposeReplace.jsp";
		                    showChooser(sURL, 850, 630);
	                        </script>
                    <%
                }
                else
                {
                    // new names
                    %>
                    <script language="javascript" type="text/javaScript">
	                        var sURL="../common/emxFullSearch.jsp?treeRoot=<%=treeRoot%>&selectedOID=<%=selectedOID%>&field=TYPES=type_VPMReference&table=AEFGeneralSearchResults&selection=multiple&showInitialResults=false&submitAction=refreshCaller&header=searchresult&submitURL=../common/emxVPMProposeReplace.jsp";
		                    showChooser(sURL, 850, 630);
	                        </script>
                    <%
                }
                //MUT R217 NameMappingRemoval Migration
    		}
			else if (strMode.equalsIgnoreCase("rep"))
			{
                //MUT R217 NameMappingRemoval Migration
                if(com.matrixone.vplm.m1mapping.MappingManager.nameMapping())
                {
                    %>
                    <script language="javascript" type="text/javaScript">
	                        var sURL="../common/emxFullSearch.jsp?treeRoot=<%=treeRoot%>&selectedOID=<%=selectedOID%>&field=TYPES=type_VPLMtyp@VPMRepReference&table=AEFGeneralSearchResults&selection=multiple&showInitialResults=false&submitAction=refreshCaller&header=searchresult&submitURL=../common/emxVPMProposeReplace.jsp";
			                    showChooser(sURL, 850, 630);
				                        </script>
                    <%
                }
                else
                {
                    // new names
                    %>
                    <script language="javascript" type="text/javaScript">
	                        var sURL="../common/emxFullSearch.jsp?treeRoot=<%=treeRoot%>&selectedOID=<%=selectedOID%>&field=TYPES=type_VPMRepReference&table=AEFGeneralSearchResults&selection=multiple&showInitialResults=false&submitAction=refreshCaller&header=searchresult&submitURL=../common/emxVPMProposeReplace.jsp";
			                    showChooser(sURL, 850, 630);
				                        </script>
                    <%
                }
                //MUT R217 NameMappingRemoval Migration
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

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
