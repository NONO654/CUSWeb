<%--  emxengchgAddRelatedValidation.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
  framesetObject fs = new framesetObject();
  fs.setDirectory(appDirectory);
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null) {
	initSource = "";
  }
  
  String objectId = emxGetParameter(request,"objectId");
  String emxTableRowId = emxGetParameter(request,"emxTableRowId");
  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  String helpmarker= emxGetParameter(request,"HelpMarker");
  StringTokenizer st = null;
  String sObjId = "";
  String sRelId = "";
  if(checkBoxId != null ) {
      try {                     
          for(int i=0;i<checkBoxId.length;i++) {
              if(checkBoxId[i].indexOf("|") != -1) {
                  st = new StringTokenizer(checkBoxId[i], "|");
                  sRelId = st.nextToken();
                  sObjId = st.nextToken();
              } else {
                  sObjId = checkBoxId[i];
              }
          }
      } catch (Exception e) {
          session.setAttribute("error.message", e.getMessage());
      }
  }
  
  DomainObject domObj = DomainObject.newInstance(context);
  domObj.setId(sObjId);
  String strBlValue = domObj.getInfo(context,"from["+DomainConstants.RELATIONSHIP_EBOM+"]");

	if( strBlValue != null && strBlValue.equals("True") ){
	%>
			<script language="Javascript">				
			//XSSOK
				emxShowModalDialog("../common/emxIndentedTable.jsp?expandProgram=emxECO:getAddRelatedPartsWithRelSelectables&table=ENCAffectedItemsAddRelatedItemsList&HelpMarker=<%=XSSUtil.encodeForJavaScript(context,helpmarker)%>&direction=from&Export=false&strChangeObjId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&emxTableRowId=<%=XSSUtil.encodeForJavaScript(context,emxTableRowId)%>&submitLabel=emxEngineeringCentral.Button.Submit&cancelLabel=emxEngineeringCentral.Common.Cancel&Registered Suite=EngineeringCentral&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&massPromoteDemote=false&triggerValidation=false&customize=false&submitURL=../engineeringcentral/emxengchgAddRelatedProcess.jsp", 750,600,false);
			</script>
	<%
	} else {
	%>
		   <script language="Javascript">
		   alert("<emxUtil:i18nScript  localize="i18nId">emxEngineeringCentral.Alert.AddRelated</emxUtil:i18nScript>");
		   </script>
	<%
	}
	%>
