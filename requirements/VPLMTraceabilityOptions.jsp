<%--
  VPLMTraceabilityOptions.jsp

  Copyright (c) 2007-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program.
--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet--%>
<%-- @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget. --%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxTagLibInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
   function alertForm() {
     alert(document.myForm.rootobj);
     return(false);
   }

   function validateForm() {
     var fullHref = "";
     if (document.myForm.plmreports.length) {
       for (k = 0; k < document.myForm.plmreports.length; k++) {
         if (document.myForm.plmreports[k].checked)
           fullHref = document.myForm.plmreports[k].value;
       }
     }
     else {
       fullHref = document.myForm.plmreports.value;
     }

     var objectid = document.myForm.objectid.value;
     var functionid = "";
     var logicalid = "";
     var rootobj = checkedvalue(document.myForm.rootobj);
     if (rootobj != null) {
	   fullHref = fullHref + "&objectId=" + objectid + "&rootObjId=" + rootobj;
	   var frame = findFrame(getTopWindow(),"RMTSpecificationsBlankTraceabilityCommandForPowerView");
		frame.location = fullHref;
       
	   //showNonModalDialog(fullHref, 975, 700, true);
     }
     return(false);
  }

   function checkedvalue(buttons) {
     var value = "";
     if (buttons.length) {
       for (ii = 0; ii < buttons.length; ii++) {
         if (buttons[ii].checked)
           value = buttons[ii].value;
       }
     }
     else {
       value = buttons.value;
     }
     return(value);
   }

   function cancel() {
    //KIE1 ZUD TSK447636 
     parent.closeWindow();
     return(true);
   }
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>

<%!
   // This method returns the setting property value:
   private static String getSettingProperty(Context context, String settingKey)
   {
      String settingVal = "";
      try {
         settingVal = EnoviaResourceBundle.getProperty(context, settingKey);
      } catch (Exception e) {
         // Missing property - do nothing
      }
      return(settingVal);
   }

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
boolean debugTrace = false;
String debugTraceVal = getSettingProperty(context, "emxRequirements.VPLMTraceabilityReport.DebugTraces");
debugTraceVal = debugTraceVal.trim();
//System.out.println("\n\n|===>VPLMTraceabilityOptions.jsp...value of DebugTraces=" + debugTraceVal);
if(debugTraceVal.equals("1"))
  debugTrace = true;
else{
  //System.out.println("|===>WARNING: Debug has been disabled. Traces will not be printed...");
  //System.out.println("              To enable, set emxRequirements.VPLMTraceabilityReport.DebugTraces to 1 in emxRequirements.properties\n");
}

String lang = request.getHeader("Accept-Language");
printDebugTrace("lang",lang,debugTrace);

String objectId = emxGetParameter(request, "objectId");
printDebugTrace("objectId",objectId,debugTrace);

String selectType = emxGetParameter(request, "selectedType");
printDebugTrace("selectType",selectType,debugTrace);

String reportType = emxGetParameter(request, "reportType");
printDebugTrace("reportType",reportType,debugTrace);

String tableRowId = emxGetParameter(request,"emxTableRowId");
printDebugTrace("tableRowId",tableRowId,debugTrace);

String[] rowIds = tableRowId.split(",");
printDebugTraces("rowIds",rowIds,debugTrace);
//Added:OEP:07-APR-09:BUG 372530
String selectOneObject = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxRequirements.Alert.MissingSelection"); 
if(rowIds != null && rowIds.length >1)
{
%>
	<script type="text/javascript">
           alert("<xss:encodeForJavaScript><%=selectOneObject%></xss:encodeForJavaScript>");
	    //KIE1 ZUD TSK447636 
           parent.closeWindow();
    </script>
<%
return;   
}
//END:OEP:07-APR-09:BUG 372530
String ReportName = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.ReportName");
String ReportDesc = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.ReportDesc");
String FunctionRoot = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.VPLMTraceabilityReport.FunctionRoot");
String LogicalRoot = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.VPLMTraceabilityReport.LogicalRoot");
String PhysicalRoot = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.VPLMTraceabilityReport.PhysicalRoot");
String VPLMCentralMsg = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.VPLMTraceabilityReport.VPLMCentralMsg");

String NoFunctionalRootsMsg = VPLMCentralMsg = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.VPLMTraceabilityReport.NoFunctionalRootsMsg");
String NoLogicalRootsMsg = VPLMCentralMsg = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.VPLMTraceabilityReport.NoLogicalRootsMsg");
String NoPhysicalRootsMsg = VPLMCentralMsg = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.VPLMTraceabilityReport.NoPhysicalRootsMsg");

String rootTitle="";
String rootId = "";
String rootName = "";
%>

<form name="myForm" method="post" enctype="multipart/form-data" onsubmit="return alertForm();">
   <input name="objectid" type="hidden" value="<xss:encodeForHTMLAttribute><%=(objectId == null? rowIds[0]: objectId)%></xss:encodeForHTMLAttribute>"/>

   <table border="0" width="100%">
      <tr>
         <th width="20"></th>
         <th><xss:encodeForHTML><%=ReportName%></xss:encodeForHTML></th>
         <th><xss:encodeForHTML><%=ReportDesc%></xss:encodeForHTML></th>
      </tr>
<%
int reportCount = 1;
String reportTypeKey = "emxRequirements.VPLMTraceabilityReport.Requirement." + reportType + ".Report" + reportCount;
String reportNameKey = getSettingProperty(context, reportTypeKey + ".Name");

while (reportNameKey != null && !reportNameKey.equals(""))
{
   String reportName = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), reportNameKey);
   String reportDescKey = getSettingProperty(context, reportTypeKey + ".Desc");
   String reportDesc = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), reportDescKey);
   String reportHeadKey = getSettingProperty(context, reportTypeKey + ".Header");
   String reportHeader = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), reportHeadKey);

   String reportProgram = getSettingProperty(context, reportTypeKey + ".Program");
   String reportTable = getSettingProperty(context, reportTypeKey + ".Table");
   String reportSortColumn = getSettingProperty(context, reportTypeKey + ".SortColumn");
   String reportSortDirection = getSettingProperty(context, reportTypeKey + ".SortDirection");

   String reportHref = "../common/emxTable.jsp?customize=true";
   reportHref += "&program=" + reportProgram;
   reportHref += "&table=" + reportTable;
   reportHref += "&header=" + reportHeader;
   reportHref += "&sortColumnName=" + reportSortColumn;
   reportHref += "&sortDirection=" + reportSortDirection;
   reportHref += "&reportType=" + reportType;
   reportHref += "&CancelButton=true&CancelLabel=emxFramework.Common.Close";
   reportHref += "&HelpMarker=emxhelptraceabilityreportfinal";
%>
      <tr class="<xss:encodeForHTMLAttribute><%=((reportCount-1)%2 == 0? "even": "odd")%></xss:encodeForHTMLAttribute>">
         <td><input name="plmreports" type="radio" <%=(reportCount == 1? "checked": "")%> value="<xss:encodeForHTMLAttribute><%=reportHref%></xss:encodeForHTMLAttribute>"/></td>
         <td><xss:encodeForHTML><%=reportName%></xss:encodeForHTML></td>
         <td><xss:encodeForHTML><%=reportDesc%></xss:encodeForHTML></td>
      </tr>
<%
   reportCount++;
   reportTypeKey = "emxRequirements.VPLMTraceabilityReport.Requirement." + reportType + ".Report" + reportCount;
   reportNameKey = getSettingProperty(context, reportTypeKey + ".Name");
}
%>
   </table>
   <br/>
   <br/>

<%
if(selectType.equals("Specification")) {
  MapList plmList = new MapList();
  boolean vplmCentralMsg = false;

  if (reportType.equals("Function")) {
    String[]  auth = new String[2];
    auth[0] = "JPO Constructor argument0";
    auth[1] = "JPO Constructor argument2";
    if(debugTrace) {
      System.out.println("|===>inside report type=" + reportType);
	}
	try {
      plmList = (MapList) JPO.invoke(context, "emxVPLMTraceabilityReport", auth, "getVPLMFunctionalRoots", rowIds, MapList.class);
    }
	catch(Exception e) {
      e.printStackTrace(System.err);
      vplmCentralMsg = true;
%>
  <script type="text/javascript">
            alert("<xss:encodeForJavaScript><%=VPLMCentralMsg%></xss:encodeForJavaScript>");
	     //KIE1 ZUD TSK447636 
            parent.closeWindow();
  </script>
<%
     }
	 if((plmList.size()==0) && !(vplmCentralMsg)) {
%>
  <script type="text/javascript">
            alert("<xss:encodeForJavaScript><%=NoFunctionalRootsMsg%></xss:encodeForJavaScript>");
	     //KIE1 ZUD TSK447636 
            parent.closeWindow();
  </script>
<%
	 }
     else {
	   rootTitle = FunctionRoot;
	 }
	 rootId = "PLM_FunctionRoot";
     rootName = "PLM_FunctionName";
   } //end-if Function
   else if (reportType.equals("Logical"))
   {
     String[]  auth = null;
     if(debugTrace) {
	   System.out.println("|===>inside report type=" + reportType);
	 }
	 try {
       plmList = (MapList) JPO.invoke(context, "emxVPLMTraceabilityReport", auth, "getVPLMLogicalRoots", rowIds, MapList.class);
     }
	 catch(Exception e) {
       e.printStackTrace(System.err);
	   vplmCentralMsg = true;
%>
  <script type="text/javascript">
            alert("<xss:encodeForJavaScript><%=VPLMCentralMsg%></xss:encodeForJavaScript>");
	     //KIE1 ZUD TSK447636 
            parent.closeWindow();
  </script>
<%
      }
	  if((plmList.size()==0) && !(vplmCentralMsg)) {
%>
  <script type="text/javascript">
            alert("<xss:encodeForJavaScript><%=NoLogicalRootsMsg%></xss:encodeForJavaScript>");
	     //KIE1 ZUD TSK447636 
            parent.closeWindow();
  </script>
<%
	  }
      else {
	    rootTitle = LogicalRoot;
	  }
      rootId = "PLM_LogicalRoot";
      rootName = "PLM_LogicalName";
  } //end-if Logical
   else if (reportType.equals("Physical"))
   {
     String[]  auth = null;
     if(debugTrace) {
	   System.out.println("|===>inside report type=" + reportType);
	 }
	 try {
       plmList = (MapList) JPO.invoke(context, "emxVPLMTraceabilityReport", auth, "getVPLMPhysicalRoots", rowIds, MapList.class);
     }
	 catch(Exception e) {
       e.printStackTrace(System.err);
	   vplmCentralMsg = true;
%>
  <script type="text/javascript">
            alert("<xss:encodeForJavaScript><%=VPLMCentralMsg%></xss:encodeForJavaScript>");
	     //KIE1 ZUD TSK447636 
            parent.closeWindow();
  </script>
<%
      }
	  if((plmList.size()==0) && !(vplmCentralMsg)) {
%>
  <script type="text/javascript">
            alert("<xss:encodeForJavaScript><%=NoPhysicalRootsMsg%></xss:encodeForJavaScript>");
	     //KIE1 ZUD TSK447636 
            parent.closeWindow();
  </script>
<%
	  }
      else {
	    rootTitle = PhysicalRoot;
	  }
      rootId = "PLM_PhysicalRoot";
      rootName = "PLM_PhysicalName";
  } //end-if Physical
%>
   <table border="0" width="100%">
      <tr>
         <th width="20"></th>
         <th><xss:encodeForHTML><%=rootTitle%></xss:encodeForHTML></th>
      </tr>
<%
  for (int j = 0; j < plmList.size(); j++) {
     Map root=(Map) plmList.get(j);
     String   rId = (String) root.get(rootId);
	 printDebugTrace("rId",rId,debugTrace);
     String   rName = (String) root.get(rootName);
     printDebugTrace("rName",rName,debugTrace);
%>
      <tr class="<xss:encodeForHTMLAttribute><%=(j%2 == 0? "even": "odd")%></xss:encodeForHTMLAttribute>">
         <td><input name="rootobj" type="radio" <%=(j == 0? "checked": "")%> onClick="validateForm()" value="<xss:encodeForHTMLAttribute><%=rId%></xss:encodeForHTMLAttribute>"/></td>
         <td><xss:encodeForHTML><%=(rName == null? "-": rName)%></xss:encodeForHTML></td>
      </tr>
<% } //end-for
%>
   </table>
   <br/>
<%
} //end-if Specification
%>
</form>
<script type="text/javascript">
//display default report
validateForm();
</script type="text/javascript">
<%@include file="../emxUICommonEndOfPageInclude.inc"%>
