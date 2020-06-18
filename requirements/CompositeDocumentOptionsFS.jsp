<%-- CompositeDocumentOptionsFS.jsp

Copyright (c) 2007-2018 Dassault Systemes.

All Rights Reserved.
This program contains proprietary and trade secret information
of MatrixOne, Inc.  Copyright notice is precautionary only and
does not evidence any actual or intended publication of such program.
--%>
<%-- 
* @quickreview QYG 12:09:06(IR-187893  "Fulfillment Report and Traceability Report from Product Context is KO, if no requirements selected from list")
* @quickreview LX6 QYG 12:08:24(IR-123051V6R2013x  "FIR : No message on invoking invalid commands for Group in list view. ")
* @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
* --%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>
<%@page import="com.matrixone.apps.requirements.RequirementGroup"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%
//Start:IR:1230516R2013x:LX6
boolean isError = false;
try
{
//End:IR:1230516R2013x:LX6
	// extract Table Row ids of the checkboxes selected.
	String[] rowIds = emxGetParameterValues(request,"emxTableRowId");
	String objectId = emxGetParameter(request,"objectId");
	//Start:IR:1230516R2013x:LX6
	if(rowIds != null){
	  boolean isRequirementGroupInList = RequirementGroup.isRequirementGroupObject(context,rowIds);
	  if(isRequirementGroupInList == true)
	  {
	    isError = true;
	    throw new Exception("invalidForReqGroup");
	  }
	}
//End:IR:1230516R2013x:LX6
	String strObjType = "Specification";
	String hiddenParams = "";
	if (objectId != null && !objectId.equals(""))
	{
	    hiddenParams = objectId;
	}
	else if (rowIds != null)
	{
	    for (int kk = 0; kk < rowIds.length; kk++)
	    {
	        if (hiddenParams.length() > 0)
	        hiddenParams += ",";
	
	        if (rowIds[kk].indexOf("|") >= 0)
	        {
	           String[] ids = rowIds[kk].split("[|]");
	            hiddenParams += ids[1];
	        }
	        else
	        {
	           hiddenParams += rowIds[kk];
	        }
	    }
	} 
	
	String exportType = emxGetParameter(request, "exportType");
	if (exportType == null || exportType.equals(""))
	{
	    exportType = "Specification";
	}
	
	framesetObject fs = new framesetObject();
	fs.setDirectory(appDirectory);
	fs.setStringResourceFile("emxRequirementsStringResource");
	
	// ----------------- Do Not Edit Above ------------------------------
	
	// Specify URL to come in middle of frameset
	String contentURL = "CompositeDocumentOptions.jsp";
	
	// add these parameters to each content URL, and any others the App needs
	contentURL += "?emxTableRowId=" + hiddenParams + "&selectedType=" + strObjType + "&exportType=" + exportType;
	
	String stylesheet = emxGetParameter(request, "stylesheet");
	if (stylesheet != null && !stylesheet.equals(""))
	{
	   contentURL += "&stylesheet=" + stylesheet;
	}
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	String HelpMarker = emxGetParameter(request, "HelpMarker");
	if(HelpMarker == null || HelpMarker.equals(""))
	{
		HelpMarker = "emxhelptraceabilityreportoptions";
	}
	
	fs.initFrameset("emxRequirements.CompositeDocument.OptionsHeader", HelpMarker,
						contentURL, false, false, false, false);
	
	fs.createFooterLink("emxRequirements.Button.Done", "validateForm()",
						"role_GlobalUser", false, true, "common/images/buttonDialogDone.gif", 1);
	
	fs.createFooterLink("emxRequirements.Button.Cancel", "cancel()",
						"role_GlobalUser", false, true, "common/images/buttonDialogCancel.gif", 1);
	
	// ----------------- Do Not Edit Below ------------------------------
	fs.writePage(out);
//Start:IR:1230516R2013x:LX6
}
catch(Exception e)
{
    String strAlertString = "emxRequirements.Alert." + e.getMessage();
    String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), strAlertString);
    if (i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
    {
        session.putValue("error.message", e.getMessage());
    }
    else
    {
        session.putValue("error.message", i18nErrorMessage);
    } 
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script type="text/javascript">
<%
if(isError == true)
{
%>
 //KIE1 ZUD TSK447636 
getTopWindow().closeWindow();
<%
}
%>
</script type="text/javascript">
<!-- End:IR:1230516R2013x:LX6 -->

