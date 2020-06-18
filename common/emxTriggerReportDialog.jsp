<%--  emxTriggerReportDialog.jsp  -   Content page to display admin object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTriggerReportDialog.jsp.rca 1.2.5.4 Wed Oct 22 15:48:12 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<script language="JavaScript">

// this function is invoked when admin type is changed
function whenAdminObjectSelected(adminObject)
{
    document.triggerForm.action="../common/emxTriggerReportDialog.jsp"
    document.triggerForm.submit();
}

// this function is invoked when the page is submitted to get triggers.
function whenSubmit()
{
    if(((new String(document.triggerForm.adminObjectType.value)).length==0)||((new String(document.triggerForm.adminObjectName.value)).length==0))
    {
       alert("<emxUtil:i18nScript localize="i18nId">emxFramework.TriggerReport.PleaseSelectRequiredFields</emxUtil:i18nScript>");
       return;
    }
    document.triggerForm.header.value = "emxFramework.TriggerReport."+document.triggerForm.adminObjectType.value;
    document.triggerForm.subHeader.value="emxFramework."+document.triggerForm.adminObjectType.value+"."+(document.triggerForm.adminObjectName.value).replace(/ /g, "_");
    document.triggerForm.objectId.value = document.triggerForm.adminObjectType.value;
    document.triggerForm.relId.value = document.triggerForm.adminObjectName.value;

    document.triggerForm.action="emxTriggerReportProcess.jsp";
    document.triggerForm.target="pagehidden";
    document.triggerForm.submit();
}
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
    String languageStr      = request.getHeader("Accept-Language");
    String suiteKey         = emxGetParameter(request, "suiteKey");
    String message          = "";
    TreeSet adminObjects    = new TreeSet();
    String adminObjectType  = emxGetParameter(request, "adminObjectType");

    if(adminObjectType == null || "null".equals(adminObjectType) || "".equals(adminObjectType))
    {
        adminObjectType = emxGetParameter(request, "objectId");
        if(adminObjectType == null || "null".equals(adminObjectType))
        {
            adminObjectType = "";
        }
    }
    
    String adminObjectName = "";
    if(!"".equals(adminObjectType))
    {
        adminObjectName = emxGetParameter(request, "adminObjectName");
        if(adminObjectName == null || "null".equals(adminObjectName) || "".equals(adminObjectName))
        {
            adminObjectName = emxGetParameter(request, "relId");
            if(adminObjectName == null || "null".equals(adminObjectName))
            {
                adminObjectName = "";
            }
        }
        adminObjects=TriggerUtil.getAllAdminObjects(context,adminObjectType);
    }

%>
<form name="triggerForm" action="" method="post" >
    <table  align="center" width="100%" cellpadding="5" cellspacing="3" border="0">
    <tr>
        <td class="labelRequired" width="40%"><emxUtil:i18n localize="i18nId">emxFramework.TriggerReport.AdminObjectType</emxUtil:i18n></td>
        <td class="inputField" width="60%">
        <select name="adminObjectType" onchange="whenAdminObjectSelected(this.value)">
        <option value=""><emxUtil:i18n localize="i18nId">emxFramework.TriggerReport.Select</emxUtil:i18n></option>
<%
        String []adminObjectTypes = {"Attribute", "Policy", "Relationship", "Type"};
            String displayValue = "";
            for(int arrIndex=0 ; arrIndex < adminObjectTypes.length; arrIndex++)
            {
                displayValue = i18nNow.getI18nString("emxFramework.TriggerReport."+adminObjectTypes[arrIndex],"emxFrameworkStringResource",languageStr);
%>
                <!-- //XSSOK -->
                <option value="<%=adminObjectTypes[arrIndex]%>" <%=(adminObjectTypes[arrIndex].equals(adminObjectType))?"selected":""%>><%=displayValue%></option>
<%
            }
%>
        </select>
        </td>
    </tr>
    <tr>
        <td class="labelRequired" ><emxUtil:i18n localize="i18nId">emxFramework.TriggerReport.AdminObjectName</emxUtil:i18n></td>
        <td class="inputField">
        <select name="adminObjectName">
        <option value=""><emxUtil:i18n localize="i18nId">emxFramework.TriggerReport.Select</emxUtil:i18n></option>
<%
        String adminObjectName1 = "";
        String adminObjectNameDisplay = "";
        for(Iterator objItr=adminObjects.iterator();objItr.hasNext();)
        {
            adminObjectName1 = (String)objItr.next();
            if("Attribute".equals(adminObjectType))
            {
                adminObjectNameDisplay = i18nNow.getAttributeI18NString(adminObjectName1,languageStr);
            }
            else if("Policy".equals(adminObjectType))
            {
                adminObjectNameDisplay = i18nNow.getAdminI18NString("Policy",adminObjectName1,languageStr);
            }
            else if("Relationship".equals(adminObjectType))
            {
                adminObjectNameDisplay = i18nNow.getAdminI18NString("Relationship",adminObjectName1,languageStr);
            }
            else if("Type".equals(adminObjectType))
            {
                adminObjectNameDisplay = i18nNow.getTypeI18NString(adminObjectName1,languageStr);
            }
%>
			<!-- //XSSOK -->
            <option value="<%=XSSUtil.encodeForHTMLAttribute(context,adminObjectName1)%>" <%=(adminObjectName1.equals(adminObjectName)?"selected":"")%>><%=XSSUtil.encodeForHTML(context, adminObjectNameDisplay)%></option>
<%
        }
%>
        </td>
    </tr>
    <tr>

<!-- //XSSOK -->
<tr><td colspan="2" class="errorMessage"><%=message%></td></tr>

</table>

<input type="hidden" name="table" value="AEFTriggerReportSummary" />
<input type="hidden" name="selection" value="none" />
<input type="hidden" name="toolbar" value="AEFTriggerReportToolBar" />
<input type="hidden" name="program" value="emxTriggerReport:getListOfTriggers" />
<input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%=languageStr%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="CancelButton" value="true" />
<input type="hidden" name="Style" value="Dialog" />
<input type="hidden" name="CancelLabel" value="emxFramework.GlobalSearch.Close" />
<input type="hidden" name="HelpMarker" value="emxhelptriggerreportresults" />
<input type="hidden" name="subHeader" value="" />
<input type="hidden" name="header" value="" />

<input type="hidden" name="contentPageIsDialog" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "contentPageIsDialog")%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="usepg" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "usepg")%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="warn" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "warn")%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "portalMode")%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="launched" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request, "launched")%></xss:encodeForHTMLAttribute>"/>

<input type="hidden" name="objectId" value="" />
<input type="hidden" name="relId" value="" />

</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
