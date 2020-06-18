<%-- CriteriaUtil.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
static const char RCSID[] = "$Id: enoTemplateUtil.jsp.rca 1.60 Wed Apr  2 16:23:14 2008 przemek Experimental przemek $";
--%>

<%@page import="com.dassault_systemes.enovia.criteria.interfaces.ENOCriteriaFactory"%>
<%@page import="com.dassault_systemes.enovia.criteria.interfaces.ENOICriteria"%>
<%@page import="com.dassault_systemes.enovia.criteria.util.CriteriaUtil"%>
<%@page import="com.dassault_systemes.enovia.criteria.interfaces.ENOCriteriaServices"%>
<%@page import="com.dassault_systemes.enovia.criteria.util.CriteriaConstants"%>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
	String mode 		= (String)emxGetParameter(request, CriteriaConstants.MODE);
	String parentOID  	= emxGetParameter(request, CriteriaConstants.PARENT_OID);
	String objectId  	= emxGetParameter(request, CriteriaConstants.OBJECT_ID);
	String[] strEmxTableRowIds = emxGetParameterValues(request, CriteriaConstants.EMX_TABLE_ROWID);
	String rowIds[]  = CriteriaUtil.parseTableRowId(strEmxTableRowIds, CriteriaConstants.OBJECT_ID);
	String actionURL = CriteriaConstants.EMPTY_STRING;
	boolean exceptionThrown = false;
	try {
		if(CriteriaConstants.DELETE.equalsIgnoreCase(mode)) {
			for(String criteriaId : rowIds){
				ENOICriteria iCriteria = ENOCriteriaFactory.getCriteriaById(context, criteriaId);
				iCriteria.delete(context);
			}

		} else if (CriteriaConstants.REVISE.equalsIgnoreCase(mode)){
			String revisedObjId = ENOCriteriaServices.reviseCriteria(context, objectId);
			actionURL = "../common/emxTree.jsp?AppendParameters=true&objectId=" + XSSUtil.encodeForURL(context, revisedObjId)+"&mode=basic";
		}
	} catch (Exception ex) {
		exceptionThrown = true;
		emxNavErrorObject.addMessage(ex.toString().trim());
    }
%>

<script type="text/javascript" src="../common/scripts/emxUIUtility.js"></script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<script type="text/javaScript">
	var action = "<%=XSSUtil.encodeForJavaScript(context, mode)%>";

	if("Delete" == action) {
		var tabFrame = findFrame(getTopWindow(), "content");
		if (tabFrame != 'undefined' && tabFrame != null) {
			//If we change the My Desk Criteria command "MyDeskCriteria" URL, then we to have change below URL also.
			tabFrame.location.href = "../common/emxIndentedTable.jsp?table=MyDeskCriteria&selection=multiple&Export=true&toolbar=MyDeskCriteriaToolbar&program=ENOCriteriaUI:getMyDeskCriterias&header=Criteria.Command.MyDesk&rowGroupingColumnNames=ApplicableType&massPromoteDemote=true&showRMB=false&suiteKey=Criteria&StringResourceFileId=enoCriteriaStringResource&SuiteDirectory=criteria";
		} else {
			refreshTablePage();
		}
	}
	//XSSOK
	var errorMsg = "<%=exceptionThrown%>";
	if(errorMsg == 'false') {
	  	if ("Revise" == action){
	  		//XSSOK
	  		var actionURL = "<%=actionURL%>";
	  		var detailsFrame = findFrame(getTopWindow(), 'detailsDisplay');
		 	detailsFrame.location.href = actionURL;
	  	}
	}
</script>


