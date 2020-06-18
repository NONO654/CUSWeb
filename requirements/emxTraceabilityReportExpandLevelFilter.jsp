<%--  emxTraceabilityReportExpandLevelFilter.jsp  -  It will present the filter page for the Requirement Allocation Report

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.
--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
      are added under respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
--%>
<%-- @quickreview T25 OEP 21 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags and tag Lib are included--%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<script type="text/javascript">
       addStyleSheet("emxUIToolbar");
       addStyleSheet("emxUIDefault");
       addStyleSheet("emxUIList");
</script>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<jsp:useBean id="tableBean"
	class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<!-- Page display code here -->

<%
    try {
        // Get the table id
        String strTableId = emxGetParameter(request, "tableID");
        Map mapReqParam = tableBean.getRequestMap(strTableId);
        
        // What was the previous expand level selection?
        //
        String strPrevExpandLevel = (String)mapReqParam.get("expandLevel");
		int nPrevExpandLevel = -1; //i.e. dont' know
		try
		{
		    if (strPrevExpandLevel != null)
		    {
		    	nPrevExpandLevel = Integer.parseInt(strPrevExpandLevel);
		    }
		}
		catch (Exception exp) 
		{
		    // Ok the provided value was not numeric.
		}
        
        String strLanguage = request.getHeader("Accept-Language");
        i18nNow i18n = new i18nNow();
        final String STRING_EXPAND_LEVEL = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.ExpandLevel");
        final String STRING_EXPAND_LEVEL_ALL = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.TraceabilityReport.ExpandLevel.All"); 
        
        // Get the user configured expand levels
        //
        String strExpandLevels = EnoviaResourceBundle.getProperty(context, "emxRequirements.TraceabilityReport.DerivedRequirementsOnly.ExpandLevels");        
		StringList slExpandLevels = FrameworkUtil.split(strExpandLevels, ",");
        
%>
<form name="formFilter">
	<div id="divToolbar" class="toolbar-container">
		<div id="divToolbar" class="toolbar-frame">
			<table>
				<tr>
					<td><xss:encodeForHTML><%=STRING_EXPAND_LEVEL%></xss:encodeForHTML>:</td>
					<td>
						<select name="expandLevel" onchange="applyFilter(this.value)">
<%
							for (StringItr stringItr = new StringItr(slExpandLevels); stringItr.next();) 
							{
							    int nExpandLevel = Integer.parseInt(stringItr.obj());
							    
							    String strExpandLevel = String.valueOf(nExpandLevel);
							    if (nExpandLevel == 0) 
							    {
									strExpandLevel = STRING_EXPAND_LEVEL_ALL;
							    }
							    
							    // Check if we need default selection for the expand level filter
							    //
							    String strSelected = "";
							    if (nPrevExpandLevel != -1 && nExpandLevel == nPrevExpandLevel)
							    {
									strSelected = "selected";
							    }
%>						
								<option value="<xss:encodeForHTMLAttribute><%=nExpandLevel%></xss:encodeForHTMLAttribute>" <%=strSelected%>><%=strExpandLevel%></option>
<%
							}
%>							
						</select>
					</td>
				</tr>
			</table>
		</div>
	</div>
</form>
<%
            // Do something here
    } catch (Exception ex) {
         if (ex.toString() != null && ex.toString().length() > 0) {
            emxNavErrorObject.addMessage(ex.toString());
         }
         ex.printStackTrace();
    } finally {
        // Add cleanup statements if required like object close, cleanup session, etc.
    }
%>

<script language="javascript">
function applyFilter(strValue) {
		var strURL = parent.location.href;
		var strarURL = strURL.split("&");
		var strarURL2 = new Array;
		for (var i = 0; i < strarURL.length; i++){
			var strParams = strarURL[i].split("=");
			if (strParams.length > 0) {
				if (strParams[0] != "expandLevel") {
					strarURL2.push(strarURL[i]);
				}
			}
			else {
				strarURL2.push(strarURL[i]);
			}
		}
		strarURL2.push("expandLevel=" + strValue);
		strURL = strarURL2.join("&");
		parent.location.href = strURL;
	}
</script>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>
<script language="javascript">
	//window.document.body.style.marginLeft = "0px";
	//window.document.body.style.marginRight = "0px";
</script>
