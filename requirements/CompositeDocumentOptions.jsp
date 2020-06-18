<%--
  CompositeDocumentOptions.jsp

  Copyright (c) 2007-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program.
--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
are added under respective scriplet
     @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
--%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxTagLibInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="javascript" type="text/javascript">
   function alertForm()
   {
        alert(document.myForm.rootobj);
        return(false);
    }

   function validateForm()
   {
      var fullHref = "";
      if (document.myForm.exportHref.length)
      {
         for (ii = 0; ii < document.myForm.exportHref.length; ii++) 
         {
            if (document.myForm.exportHref[ii].checked) 
               fullHref = document.myForm.exportHref[ii].value;
         }
      }
      else
      {
         fullHref = document.myForm.exportHref.value;
      }

      var objectid = document.myForm.objectid.value;
      var functionid = "";
      var logicalid = "";
      var physicalid = ""

      var rootobj = checkedvalue(document.myForm.rootobj);
      if (rootobj != null)
      {
         var sep = rootobj.indexOf("|");
         if (sep >= 0)
         {
        	 var ids = rootobj.split('|');
            functionid = ids[0];
            logicalid = ids[1];
            physicalid = ids[2];
            fullHref = fullHref + "&objectId=" + objectid + "&functionId=" + functionid + "&logicalId=" + logicalid + "&physicalId=" + physicalid;
         }
         else
         {
            objectid = rootobj;
            fullHref = fullHref + "&objectId=" + objectid;
         }

         showNonModalDialog(fullHref, 975, 700, true);
      }
  //KIE1 ZUD TSK447636 
      parent.closeWindow();
      return(false);
   }
   
   function checkedvalue(buttons) 
   {
        var value = "";
        if (buttons.length)
        {
            for (ii = 0; ii < buttons.length; ii++) 
            {
                if (buttons[ii].checked) 
                    value = buttons[ii].value;
            }
        }
        else
        {
            value = buttons.value;
        }
        return(value);
   }
   
   function cancel() 
   {
     //KIE1 ZUD TSK447636 
      parent.closeWindow();
   }
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
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
%>
<%
String objectId = emxGetParameter(request, "objectId");
String stylesheet = emxGetParameter(request, "stylesheet");
String selectType = emxGetParameter(request, "selectedType");
String exportType = emxGetParameter(request, "exportType");
String tableRowId = emxGetParameter(request, "emxTableRowId");
String[] rowIds = tableRowId.split(",");

// Added:OEP:07-APR-09:BUG 372530
String lang = request.getHeader("Accept-Language");
String selectOneObject = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.MissingSelection"); 


if(rowIds != null && rowIds.length > 1)
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
String SelectReport = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.CompositeDocument.SelectReport"); 
String SpecificationRoot = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.CompositeDocument.SpecificationRoot"); 
String FunctionRoot = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.CompositeDocument.FunctionRoot"); 
String LogicalRoot = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.CompositeDocument.LogicalRoot"); 
String PhysicalRoot = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.CompositeDocument.PhysicalRoot"); String NoRoots = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.VPLMTraceabilityReport.NoFunctionalRootsMsg"); 
%>

<form name="myForm" method="post" enctype="multipart/form-data" onsubmit="return alertForm();">
   <input name="objectid" type="hidden" value="<xss:encodeForHTMLAttribute><%=(objectId == null? rowIds[0]: objectId)%></xss:encodeForHTMLAttribute>"/>

   <table border="0" width="100%">
      <tr>
         <th width="20"></th>
         <th> <xss:encodeForHTML><%=SelectReport%></xss:encodeForHTML></th>
      </tr>  
<%
int exportCount = 1;
String exportTypeKey = "emxRequirements.CompositeDocument." + exportType + ".Export" + exportCount;
String exportNameKey = getSettingProperty(context, exportTypeKey + ".Name");

while (exportNameKey != null && !exportNameKey.equals(""))
{
   String exportName = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), exportNameKey); 
   String exportHeadKey = getSettingProperty(context, exportTypeKey + ".Header");
   String exportHeader = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), exportHeadKey); 

   String exportProgram = getSettingProperty(context, exportTypeKey + ".Program");

   String exportHref = "CompositeDocumentReport.jsp?";
   exportHref += "exportType=" + exportType;
   exportHref += "&program=" + exportProgram;
   exportHref += "&header=" + exportHeader;
   if (stylesheet != null && !stylesheet.equals(""))
      exportHref += "&stylesheet=" + stylesheet;
   exportHref += "&HelpMarker=emxhelpcontentexportfinal";
%>
      <tr class="<xss:encodeForHTMLAttribute><%=((exportCount-1)%2 == 0? "even": "odd")%></xss:encodeForHTMLAttribute>">
         <td><input name="exportHref" type="radio" <%=(exportCount == 1? "checked": "")%> value="<xss:encodeForHTMLAttribute><%=exportHref%></xss:encodeForHTMLAttribute>"/></td>
         <td><xss:encodeForHTML><%=exportName%></xss:encodeForHTML></td>
      </tr>
<%
   exportCount++;
   exportTypeKey = "emxRequirements.CompositeDocument." + exportType + ".Export" + exportCount;
   exportNameKey = getSettingProperty(context, exportTypeKey + ".Name");
}
%>
   </table> 
   <br/>
   <br/>

<%
if (selectType.equals("Specification"))
{
   if (exportType.equals("XML") || exportType.equals("RIF"))
   {
%>
   <table border="0" width="100%">
      <tr>
         <th width="20"></th>
         <th><xss:encodeForHTML><%=SpecificationRoot%></xss:encodeForHTML></th>
      </tr>
<%
      for (int ii = 0; ii < rowIds.length; ii++)
      {
         String rowId = rowIds[ii];
         DomainObject domObj = DomainObject.newInstance(context, rowId);
         String objName = domObj.getInfo(context, DomainConstants.SELECT_NAME) +
                    " " + domObj.getInfo(context, DomainConstants.SELECT_REVISION);
%>
      <tr class="<xss:encodeForHTMLAttribute><%=(ii%2 == 0? "even": "odd")%></xss:encodeForHTMLAttribute>">
         <td><input name="rootobj" type="radio" <xss:encodeForHTMLAttribute><%=(ii == 0? "checked": "")%></xss:encodeForHTMLAttribute> value="<xss:encodeForHTMLAttribute><%=rowId%></xss:encodeForHTMLAttribute>"/></td>
         <td><xss:encodeForHTML><%=objName%></xss:encodeForHTML></td>
      </tr>
<%    }
%>
   </table>
   <br/>
<%
   }
   else if (exportType.equals("ICD"))
   {
      String  errMess = "";
      MapList plmList = null;
      try
      {
         plmList = (MapList) JPO.invoke(context, "emxVPLMCompositeDocument", null, "getVPLMRoots", rowIds, MapList.class);
      }
      catch(Exception e)
      {
         errMess = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Error.MissingVPLMProduct"); 
         e.printStackTrace(System.err);
      }

%>
   <table border="0" width="100%">
      <tr>
         <th width="20"></th>
         <th><xss:encodeForHTML><%=FunctionRoot%></xss:encodeForHTML></th>
         <th><xss:encodeForHTML><%=LogicalRoot%></xss:encodeForHTML></th>
         <th><xss:encodeForHTML><%=PhysicalRoot%></xss:encodeForHTML></th>
      </tr>
<%
      if (plmList == null)
      {
%>       <script type="text/javascript">
            alert("<xss:encodeForJavaScript><%=errMess%></xss:encodeForJavaScript>");
	      //KIE1 ZUD TSK447636 
            parent.closeWindow();
         </script>
<%    }
      else if(plmList.size() == 0)
      {
%>       
         <script type="text/javascript">
            alert("<xss:encodeForJavaScript><%=NoRoots%></xss:encodeForJavaScript>");
	      //KIE1 ZUD TSK447636 
            parent.closeWindow();
         </script>    
<%    }
      else
      {
         for (int ii = 0; ii < plmList.size(); ii++)
         {
            Map      root = (Map) plmList.get(ii);
            String   fncId = (String) root.get("PLM_FunctionRoot");
            String   fncName = (String) root.get("PLM_FunctionName");
            String   logId = (String) root.get("PLM_LogicalRoot");
            String   logName = (String) root.get("PLM_LogicalName");
            String   phyId = (String) root.get("PLM_PhysicalRoot");
            String   phyName = (String) root.get("PLM_PhysicalName");
            String   rootids = (fncId == null? "": fncId) + "|" + (logId == null? "": logId) + "|" + (phyId == null? "": phyId);
%>
      <tr class="<xss:encodeForHTMLAttribute><%=(ii%2 == 0? "even": "odd")%></xss:encodeForHTMLAttribute>">
         <td><input name="rootobj" type="radio" <xss:encodeForHTMLAttribute><%=(ii == 0? "checked": "")%></xss:encodeForHTMLAttribute> value="<xss:encodeForHTMLAttribute><%=rootids%></xss:encodeForHTMLAttribute>"/></td>
         <td><xss:encodeForHTML><%=(fncName == null? "-": fncName)%></xss:encodeForHTML></td>
         <td><xss:encodeForHTML><%=(logName == null? "-": logName)%></xss:encodeForHTML></td>
         <td><xss:encodeForHTML><%=(phyName == null? "-": phyName)%></xss:encodeForHTML></td>
      </tr>
<%       }
      }
%>
   </table>
   <br/>
<%
   }
}
%>
</form>

<%@include file="../emxUICommonEndOfPageInclude.inc" %>
