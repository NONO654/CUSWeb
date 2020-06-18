<%--  ECMChangeAssessment.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "ECMDesignTopInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<jsp:useBean id="changeUtil" class="com.dassault_systemes.enovia.enterprisechangemgt.util.ChangeUtil" scope="session"/>
<jsp:useBean id="changeUXUtil" class="com.dassault_systemes.enovia.enterprisechangemgtapp.common.ChangeUXUtil" scope="session"/>

<%
  	String strId = "";
	StringList slTableRowIds = new StringList(10); 
  	String[] arrTableRowIds = emxGetParameterValues(request,"emxTableRowId");
  	String[] strArrObjectId = emxGetParameterValues(request,"objectId");
  	String strObjectId = strArrObjectId[0];
  	i18nNow i18nnow = new i18nNow();
  String strSelectAlertMessage = EnoviaResourceBundle.getProperty(context, "emxEnterpriseChangeMgtStringResource", context.getLocale(),"EnterpriseChangeMgt.Alert.SelectOne");
  String strHeader = EnoviaResourceBundle.getProperty(context, "emxEnterpriseChangeMgtStringResource", context.getLocale(),"EnterpriseChangeMgt.Command.ChangeAssesment");
  	
	// Getting Object Ids From the tableRowId
  	StringList slObjectIds = changeUXUtil.getAffectedItemsIds(context, arrTableRowIds);
    
%>

<html>
<head/>
<body>
<div id="pageHeadDiv">
    <table>
        <tr>
        <td>
		<iframe name="AddAllRelated" border="0" frameborder="0" height="700" src="../common/emxIndentedTable.jsp?program=enoECMChangeAssessment:getChangeAssessmentItems&Level=All&table=ECMRelatedItemTable&toolbar=ECMRelatedItemToolbar&header=<%=XSSUtil.encodeForHTML(context, strHeader)%>&selection=multiple&massPromoteDemote=false&editRootNode=false&hideRootSelection=true&contextCOId=<%=XSSUtil.encodeForHTML(context, strObjectId)%>&selectedItem=<%=XSSUtil.encodeForHTML(context, (String)slObjectIds.get(0))%>&rowGroupingColumnNames=CustomLabel&rowGrouping=false&autoFilter=false&export=false&multiColumnSort=false&printerFriendly=false&objectCompare=false&triggerValidation=false&showClipboard=false&customize=false&expandLevelFilterMenu=false&displayView=details">
        	
        </iframe>
        </td>
        </tr>
        </table>
        </div>
        <div id="footer">
        <a href="javascript:getTopWindow().closeSlideInDialog()"><img src="../common/images/buttonDialogCancel.gif" align="right" /></a>
        </div>
        </body>
        </html>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
