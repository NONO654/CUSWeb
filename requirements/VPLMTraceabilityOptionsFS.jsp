<%-- VPLMTraceabilityOptionsFS.jsp

Copyright (c) 2007-2018 Dassault Systemes.

All Rights Reserved.
This program contains proprietary and trade secret information
of MatrixOne, Inc.  Copyright notice is precautionary only and
does not evidence any actual or intended publication of such program.
--%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../components/emxComponentsCommonUtilAppInclude.inc"%>
<%@page import="com.matrixone.apps.requirements.RequirementGroup"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%-- 
* @quickreview QYG --- 12:09:06(IR-187893  "Fulfillment Report and Traceability Report from Product Context is KO, if no requirements selected from list")
* @quickreview LX6 QYG 12:08:24(IR-123051V6R2013x  "FIR : No message on invoking invalid commands for Group in list view. ")
* @quickreview JX5 QYG 13:06:04(IR-235268V6R2014 STP: Multiple selection is KO for Traceability report for Specification or Requirement from list page.)
*--%>
<%!
  void printDebugTrace(String iName, String iVal, boolean iDebug) throws java.io.IOException {
    if(iDebug) {
	  if(iVal == null)
	    System.out.println("|===>" + iName + " is NULL !!");
	  else
		System.out.println("|===>"+ iName + "=" + iVal);
	}
  }

  void printDebugTraces(String iName, String[] iVal, boolean iDebug) throws java.io.IOException {
    if(iDebug) {
	  if(iVal == null)
	    System.out.println("|===>" + iName + " is NULL !!");
	  else{
		if(iVal.length ==0)
		  System.out.println("|===>" + iName + " is EMPTY !!");
		else{
		  for(int i=0; i<iVal.length; i++)
		    System.out.println("|===>"+iName+"["+i+"]=" + iVal[i]);
	    }
	  }
	}
  }
%>

<%
//Start:IR:1230516R2013x:LX6
boolean isError = false;
try
{
//Start:IR:1230516R2013x:LX6
	String lang = request.getHeader("Accept-Language");
	boolean debugTrace = false;
	String debugTraceVal = EnoviaResourceBundle.getProperty(context, "emxRequirements.VPLMTraceabilityReport.DebugTraces");  
	debugTraceVal = debugTraceVal.trim();
	//System.out.println("\n\n|===>VPLMTraceabilityOptionsFS.jsp...value of DebugTraces=" + debugTraceVal);
	if(debugTraceVal.equals("1"))
	  debugTrace = true;
	else {
	  //System.out.println("|===>WARNING: Debug has been disabled. Traces will not be printed...");
	  //System.out.println("              To enable, set emxRequirements.VPLMTraceabilityReport.DebugTraces to 1 in emxRequirements.properties\n");
	}
	  
	printDebugTrace("lang",lang,debugTrace);
	
	// extract Table Row ids of the checkboxes selected.
	//JX5 start IR-235268V6R2014
		String emxRowInfo = emxGetParameter(request,"RowInfo");
		String rowIds[];
		if(emxRowInfo == null || emxRowInfo.equals("") || emxRowInfo.equals("null"))
		{
			rowIds = emxGetParameterValues(request,"emxTableRowId");
		}
		else{
			rowIds = emxRowInfo.split(":");
		}
	//JX5 end IR-235268V6R2014
	printDebugTraces("rowIds",rowIds,debugTrace);
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
	String objectId = emxGetParameter(request,"objectId");
	printDebugTrace("objectId",objectId,debugTrace);
	
	String strObjType = "Specification";
	String hiddenParams = "";
	if (objectId != null && !objectId.equals("")) {
	  hiddenParams = objectId;
	}
	else if (rowIds != null) {
	  for (int i = 0; i<rowIds.length; i++) {
	    if (hiddenParams.length() > 0)
	      hiddenParams += ",";
	    if (rowIds[i].indexOf("|") >= 0) {
	      String[] ids = rowIds[i].split("[|]");
	      hiddenParams += ids[1];
	    }
	    else {
	      hiddenParams += rowIds[i];
	    }
	  }
	}
	printDebugTrace("hiddenParams",hiddenParams,debugTrace);
	
	String reportType = emxGetParameter(request, "reportType");
	if (reportType == null || reportType.equals("")) {
	  reportType = "Function";
	}
	
	framesetObject fs = new framesetObject();
	fs.setDirectory(appDirectory);
	fs.setStringResourceFile("emxRequirementsStringResource");
	
	// ----------------- Do Not Edit Above ------------------------------
	
	//Specify URL to come in middle of frameset
	String contentURL = "VPLMTraceabilityOptions.jsp";
	
	//add these parameters to each content URL, and any others the App needs
	contentURL += "?emxTableRowId=" + hiddenParams + "&selectedType=" + strObjType + "&reportType=" + reportType;
	printDebugTrace("contentURL",contentURL,debugTrace);
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	String HelpMarker = "emxhelptraceabilityreportoptions";
	
	fs.initFrameset("emxRequirements.TraceabilityReport.OptionsHeader", HelpMarker,
						contentURL, false, false, false, false);
	
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
getTopWindow().close();
<%
}
%>
</script type="text/javascript">
<!-- //End:IR:1230516R2013x:LX6 -->

