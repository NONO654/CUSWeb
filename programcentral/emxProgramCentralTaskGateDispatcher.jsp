<%--
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsCreatePeopleDialog.jsp.rca 1.29 Wed Oct 22 16:17:46 2008 przemek Experimental przemek $
--%>
<%@ page import="matrix.util.MatrixException, matrix.util.StringList,java.util.ListIterator" %>
<%@page import="com.matrixone.apps.domain.DomainConstants,com.matrixone.apps.domain.DomainObject" %>
<%@page import="com.matrixone.apps.program.ProjectSpace" %>
<%@page import="java.util.*" %>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%
  Enumeration requestParams = emxGetParameterNames(request);
  StringBuffer url = new StringBuffer();
  if(requestParams != null){
      while(requestParams.hasMoreElements()){
          String param = (String)requestParams.nextElement(); 
          //Added for special character.
          String value =  emxGetParameter(request,param);
          url.append("&" + XSSUtil.encodeForURL(context,param) + "=" + XSSUtil.encodeForURL(context,value));           
      }
  }
 
 String objectId = emxGetParameter(request,"objectId");
 DomainObject domObj = DomainObject.newInstance(context);
 String contentURL = "";
 try{
		if (null == objectId || "".equals(objectId)) {
			throw new Exception();
		}
		
		boolean isHoldOrCancelProject = false;
		boolean isCollabTask = false;
		domObj.setId(objectId);

		StringList selects = new StringList(6);
		selects.add(ProgramCentralConstants.SELECT_HAS_MODIFY_ACCESS);
		selects.add(ProgramCentralConstants.SELECT_PROJECT_POLICY_FROM_TASK);
		selects.add(ProgramCentralConstants.SELECT_IS_GATE);
		selects.add(ProgramCentralConstants.SELECT_IS_MILESTONE);
		selects.add(ProgramCentralConstants.SELECT_PROJECT_TYPE);
		selects.add(ProgramCentralConstants.SELECT_PROJECT_ACCESS_KEY_ID);
		
		Map objectInfo = domObj.getInfo(context, selects);

		String projectPolicy 		= (String) objectInfo.get(ProgramCentralConstants.SELECT_PROJECT_POLICY_FROM_TASK);
		String projectType 			= (String) objectInfo.get(ProgramCentralConstants.SELECT_PROJECT_TYPE);
		String projectAccessKeyId 	= (String) objectInfo.get(ProgramCentralConstants.SELECT_PROJECT_ACCESS_KEY_ID);

		boolean isGate 					= Boolean.parseBoolean((String) objectInfo.get(ProgramCentralConstants.SELECT_IS_GATE));
		boolean isMilesTone		 		= Boolean.parseBoolean((String) objectInfo.get(ProgramCentralConstants.SELECT_IS_MILESTONE));
		boolean isProjectBaselineTask 	= ProgramCentralConstants.TYPE_PROJECT_BASELINE.equalsIgnoreCase(projectType);
		boolean isProjectTemplate 		= ProgramCentralConstants.TYPE_PROJECT_TEMPLATE.equalsIgnoreCase(projectType);

		if (ProgramCentralConstants.POLICY_PROJECT_SPACE_HOLD_CANCEL.equalsIgnoreCase(projectPolicy)) {
			isHoldOrCancelProject = true;
		}

		if (ProgramCentralUtil.isNullString(projectAccessKeyId)) {
			isCollabTask = true;
		}

		if (isCollabTask) {
			contentURL = "../common/emxPortal.jsp?portal=PMCPropertiesPortal&header=emxProgramCentral.Gate.Portal.Properties&export=false&HelpMarker=emxhelpprojectproperties";
			contentURL += url.toString();

		} else if (isGate) { //Modified for type based bahavior
			if (isHoldOrCancelProject || isProjectBaselineTask) {
				contentURL = "../common/emxPortal.jsp?portal=PMCDefaultGatePortal&header=emxProgramCentral.Common.GatePowerView&HelpMarker=emxhelpgatedeliverables&suiteKey=ProgramCentral&massPromoteDemote=false&rowGrouping=false&objectCompare=false&showClipboard=false&showPageURLIcon=false&triggerValidation=false&displayView=details&multiColumnSort=false&showRMB=false"
						+ url.toString();
			} else {
				contentURL = "../common/emxPortal.jsp?portal=PMCDefaultGatePortal"
						+ "&header=emxProgramCentral.Common.GatePowerView&HelpMarker=emxhelpgatedeliverables&suiteKey=ProgramCentral"
						+ url.toString();//Modified:nr2:PRG:R212:30 July 2011:IR-089500V6R2012x
			}
		} else {
			String hasModifyAccess = (String) objectInfo.get(ProgramCentralConstants.SELECT_HAS_MODIFY_ACCESS);

			if (isHoldOrCancelProject || isProjectBaselineTask) {
				contentURL = "../common/emxIndentedTable.jsp?table=PMCWBSViewTable&expandProgramMenu=PMCWBSTaskListMenu&freezePane=Name&selection=multiple&HelpMarker=emxhelpwbstasklist&header=emxProgramCentral.Common.WorkBreakdownStructureSB&sortColumnName=ID&findMxLink=false&massPromoteDemote=false&rowGrouping=false&objectCompare=false&showClipboard=false&showPageURLIcon=false&triggerValidation=false&displayView=details&multiColumnSort=false&showRMB=false"
						+ url.toString();
			} else {
				contentURL = "../common/emxIndentedTable.jsp?table=PMCWBSViewTable"
						+ "&expandProgramMenu=PMCWBSTaskListMenu" + "&freezePane=Name" + "&selection=multiple"
						+ "&HelpMarker=emxhelpwbstasklist"
						+ "&header=emxProgramCentral.Common.WorkBreakdownStructureSB" + "&sortColumnName=ID"
						+ "&findMxLink=false";

				if (!isMilesTone) {
					contentURL += "&toolbar=PMCWBSToolBar";
					contentURL += "&editRelationship=relationship_Subtask";
					contentURL += "&resequenceRelationship=relationship_Subtask";
					contentURL += "&connectionProgram=emxTask:cutPasteTasksInWBS";
				}
				contentURL += url.toString();

				boolean isAnDInstalled = FrameworkUtil.isSuiteRegistered(context,
						"appVersionAerospaceProgramManagementAccelerator", false, null, null);
				if (isAnDInstalled) {
					boolean isLocked = Task.isParentProjectLocked(context, objectId);
					if (isLocked)
						contentURL = contentURL
								+ "&hideRootSelection=true&editRootNode=false&preProcessJPO=emxTask:preProcessCheckForLock";
				}
			}
			
			if ("true".equalsIgnoreCase(hasModifyAccess) && !isProjectBaselineTask) {
				contentURL = contentURL + "&editLink=true";
				contentURL += "&postProcessJPO=emxTask:updateScheduleChanges";
			}
		}
	} catch (Exception e) {
		throw new MatrixException(e);
	}
%>


<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
<title>Insert title here</title>
	<script language="javascript">
    <%-- XSSOK--%>
	this.location.href = "<%= contentURL %>";
	</script>
</head>
<body>

</body>
</html>
