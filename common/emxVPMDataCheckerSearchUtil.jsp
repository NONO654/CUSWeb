<%--  emxVPMDataCheckerSearchUtil.jsp   -   Page to Search Data for Validation
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   @quickreview E25 17:05:23 [Fix for	IR-523570-3DEXPERIENCER2018x].
--%>
<%@ page
	import="com.dassault_systemes.vplmintegration.VPLMIntegSynchronizerObject"%>
<%@ page
	import="com.dassault_systemes.vplmintegration.sdk.VPLMIntegException"%>
<%@ page
	import="com.dassault_systemes.vplmintegration.sdk.enovia.VPLMBusObject"%>
<%@ page import="com.matrixone.apps.domain.DomainConstants"%>
<%@ page import="com.matrixone.apps.framework.taglib.*"%>
<%@ page import="com.matrixone.apps.framework.ui.*"%>
<%@ page
	import="com.matrixone.vplmintegration.util.VPLMIntegSessionUtils"%>
<%@ page
	import="com.matrixone.vplmintegrationitf.itf.IVPLMChgOperations"%>
<%@ page
	import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@ page
	import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationReporter"%>
<%@ page import="com.matrixone.vplmintegration.util.VPLMIntegTraceUtil" %>
<%@ page
	import="com.dassault_systemes.vplmintegration.sdk.enovia.VPLMBusObject"%>
<%@ page
	import="com.dassault_systemes.collaborationmodelerchecker.VPLMJCollaborationModelerChecker"%>
<%@ page import="java.util.Set" %>
<%@ page import="matrix.db.*"%>
<%@ page import="java.util.List"%>
<%@ include file="emxNavigatorInclude.inc"%>
<%@ include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
String objectId="";	
objectId= emxGetParameter(request, "objectId");
//String strObjId = emxGetParameter(request, "objectId");
	String selPartIds[] = emxGetParameterValues(request,
			"emxTableRowId");
		
		for (int i=0; i < selPartIds.length ;i++){
		StringTokenizer strTokens = new StringTokenizer(selPartIds[i],
				"|");
			if (strTokens.hasMoreTokens()){
			        objectId= strTokens.nextToken();
				}
		}
System.out.println(" Selected object is "+objectId);
VPLMBusObject boToSync  = new VPLMBusObject(context,objectId);
String languageStr           = request.getHeader("Accept-Language");
    String strBundle             = "emxVPLMSynchroStringResource";
	String strSelectObject = EnoviaResourceBundle.getProperty(context,
			strBundle, context.getLocale(),
			"emxVPLMJCollab.Selection.Object");
	String strSelectChecker = EnoviaResourceBundle.getProperty(context,
			strBundle, context.getLocale(),
			"emxVPLMJCollab.Selection.Checker");
	String strExpandStruct = EnoviaResourceBundle.getProperty(context,
			strBundle, context.getLocale(),
			"emxVPLMSynchro.Synchronization.ExpandStructure");
%>
<script language="javascript" type="text/javaScript">
	    	 //XSSOK
	    	    var url = "../common/emxSynchronizeVPLMDataCheckerDialogFS.jsp?titleKey=emxVPLMSynchro.Synchronization.Command.SyncDataChecker.Title&objectId=<%=objectId%>";
	//fix for IR-523570-3DEXPERIENCER2018x
	var frame = openerFindFrame(getTopWindow(), "content");
	frame.location.href = url;
	getTopWindow().closeWindow();
	        </script>
