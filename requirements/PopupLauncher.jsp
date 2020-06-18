<%--  PopupLauncher.jsp
   Copyright (c) 2008-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%-- @quickreview LX6 QYG 08.24.2012  IR-123051V6R2013x  "FIR : No message on invoking invalid commands for Group in list view --%>
<%-- @quickreview QYG     09.03.2012  IR-187170V6R2013x  "SCE is not getting invoked for requirement and requirement specification from structure content editor button -->
<%-- @quickreview T25 OEP 12.10.2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet--%>
<%-- @quickreview OEP DJH 02.28.2013  IR-218082V6R2014 Removing code related to tableMenu --%>
<%-- @quickreview JX5 QYG 06.11.2013  IR-238835V6R2014 replacing emxNavigatorDialog by emxRequirementDialog --%>
<%-- @quickreview JX5     06.23.2014  IR-305271-3DEXPERIENCER2015x : Embedded SB in CATIA --%>
<%-- @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget. --%>
<%@page import = "java.util.*,com.matrixone.apps.domain.util.*"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxTagLibInclude.inc"%>

<%@page import="com.matrixone.apps.requirements.RequirementGroup"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<html>
<head>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script type="text/javascript">
//<![CDATA[
$.getScript("../webapps/AmdLoader/AmdLoader.js", function (){
	window.dsDefaultWebappsBaseUrl = "../webapps/";
	$.getScript("../webapps/WebappsUtils/WebappsUtils.js", function (){
		require(['DS/ENORMTCustoSB/panelRightContext'], function(){
		    var detailDisplay =  findFrame(getTopWindow(),'detailsDisplay');
		    if(detailDisplay != null){
		    	var dashboardSlideIn = $('#dashBoardSlideIn',findFrame(getTopWindow(),'detailsDisplay').document);
		    	if(dashboardSlideIn.is(':visible')==true){
		    		$(getTopWindow().document).ready(function() {	
		    			resizeTable();
		    		});	
		    		$(getTopWindow).resize(function(){				
		    			resizeTable();
		    		});	
		    		closePanel();
		    	} 
		    }
		});
	});
});
       
function removeParameter(url, paramName)
{
	var prefix = paramName + "=";
	var start = url.indexOf(prefix);
	if( start == -1)
		return url;
	var end = url.indexOf("&", start + 1);
	return url.substring(0, start) + (end == -1 ? "" : url.substring(end));
}
<%

//Start:IR:1230516R2013x:LX6
  boolean isError = false;
  try
  {
//End:IR:1230516R2013x:LX6
		//This case is specific to specificationb list
		String table = emxGetParameter(request, "table");
		if(table ==  null)
		{
			table = "";
		}
		if(((table.equals("RMTRequirementSpecificationsList"))||(table.equals("RMTMyDeskRequirementList"))))
		{
			String selectedDefaultlistFilter = "";
			String program = "";
			String programLabel = "";
			program = emxGetParameter(request, "program");
			programLabel = emxGetParameter(request, "programLabel");
			//get the preference for program
			if(table.equals("RMTRequirementSpecificationsList"))
			{
				selectedDefaultlistFilter = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "DefaultSpecListFilter");
				%>
				var href = location.href.replace("requirements/PopupLauncher.jsp", "common/emxIndentedTable.jsp");
				<%
			}
			else
			{
				selectedDefaultlistFilter = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "DefaultReqListFilter");
				%>
				var href = location.href.replace("requirements/PopupLauncher.jsp", "common/emxIndentedTable.jsp");
				<%
			}
				
			
			if(program.contains(selectedDefaultlistFilter))
			{
				//plit the program and pragramLabel lists
				String[] programTable = program.split(",");
				String[] programLabelTable = programLabel.split(",");
				for(int i = 1; i < programTable.length; i++ )
				{
					//first index is ignored because in this case there's no modification
					if(programTable[i].equals(selectedDefaultlistFilter))
					{
						//change the list order of program
						String firstProgram = programTable[0];
						programTable[0] = selectedDefaultlistFilter;
						programTable[i] = firstProgram;
						//change the list order of programLabel
						String firstProgramLabel = programLabelTable[0];
						programLabelTable[0] = programLabelTable[i];
						programLabelTable[i] = firstProgramLabel;
					}
				}
				program = "";
				programLabel = "";
				//recreate string with the good order
				for(int i = 0 ; i < programTable.length ; i++ )
				{
					program += programTable[i];
					programLabel += programLabelTable[i];
					if(i != (programTable.length -1))
					{
						program += ",";
						programLabel += ",";
					}
				}
				%>
				//delete previous program and programLabel in href
				href = removeParameter(href, "program");
				href = removeParameter(href, "programLabel");
				//replace it by the new ones
				href += "&program=" + "<xss:encodeForJavaScript><%=program%></xss:encodeForJavaScript>";
				href += "&programLabel=" + "<xss:encodeForJavaScript><%=programLabel%></xss:encodeForJavaScript>";
				<%
			}
		}
		else
		{
			%>
			var href = location.href;
			<%
			String ExpandOption = "";
			String TypeView = "";
			String TargetView = emxGetParameter(request, "TargetView");
			if(TargetView == null)
			{
				TargetView = "";
			}
			else
			{
				//suppress Parameter when after been use to avoid persistent data
				%>
				href = removeParameter(href, "TargetView");
				<%
			}
			//JX5 Embedded SB : no inline edition
			String isEmbedded = emxGetParameter(request,"isEmbedded");
			String inlineEdit = "&insertNewRow=true&showTreeExplorer=true";
			if(isEmbedded != null && isEmbedded.equalsIgnoreCase("true"))
				inlineEdit = "&insertNewRow=false&showTreeExplorer=true";
				
			%>
            // Inline Data Entry + Structure Explorer
            //JX5 Embedded SB : no inline edition
			href += "<%=inlineEdit%>";
		
            <%
            
			String SelectedProgram = emxGetParameter(request, "selectedProgram");
			if(SelectedProgram == null)
			{
				if(emxGetParameter(request, "table").equals("RMTRequirementStatusView"))
				{
					SelectedProgram = "emxRequirement:getSubRequirements";
				}
				else
				{
					SelectedProgram = "emxSpecificationStructure:expandTreeWithAllRequirements";
				}
			}
			
			if((SelectedProgram != null)&&(SelectedProgram.equals("") == false))
			{
				ExpandOption = "&selectedProgram=" + SelectedProgram;	
			}
		
			if(TargetView.equals("sb"))
			{
				%>
				href = href.replace("requirements/PopupLauncher.jsp", "common/emxIndentedTable.jsp");
				<%
				String objectId = emxGetParameter(request, "objectId");
				if(objectId != null && objectId.length() > 0 && "FALSE".equalsIgnoreCase(DomainObject.newInstance(context, objectId).getInfo(context, "current.access[modify]"))) {
					System.out.println("value: " + "FALSE".equalsIgnoreCase(DomainObject.newInstance(context, objectId).getInfo(context, "current.access[modify]")));
				%>
					href += "&editRootNode=false";
				<%
				}
			}
			else
			{
				
				// Start:IR:123051V6R2013x:LX6
				String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId");
				if(tableRowIds == null) //IR-187170V6R2013x 
				{
					String objectId = emxGetParameter(request, "objectId");
					tableRowIds = new String[]{objectId};
				
				}
		    boolean isRequirementGroupInList = RequirementGroup.isRequirementGroupObject(context,tableRowIds);
		    if(isRequirementGroupInList == true)
		    {
		    	isError = true;
		      throw new Exception("invalidForReqGroup");
		    }
			    // End:IR:123051V6R2013x:LX6
				%>
				href = href.replace("PopupLauncher.jsp", "RichTextEditorLayout.jsp");
				<%
							
			}
			%>
		    if((href.indexOf("selectedProgram")==-1))
		 	{  		
		    	href += "<xss:encodeForJavaScript><%=ExpandOption%></xss:encodeForJavaScript>";
		 	}
		   	if(href.indexOf("selectedTable")==-1)
		 	{
		  		href += "<xss:encodeForJavaScript><%=TypeView%></xss:encodeForJavaScript>";
	
		 	}
			<%
		}
	%>
	if(getTopWindow() == self)
	{
	   window.location = "emxRequirementDialog.jsp?contentURL=" + escape(href +  
	   	    			"<xss:encodeForJavaScript><%=emxGetParameter(request, "emxTableRowId") == null ? "" : "&emxTableRowId=" + emxGetParameter(request, "emxTableRowId")%></xss:encodeForJavaScript>");
	}
	else
	{
			window.location = href + "<xss:encodeForJavaScript><%=emxGetParameter(request, "emxTableRowId") == null ? "" : "&emxTableRowId=" + emxGetParameter(request, "emxTableRowId")%></xss:encodeForJavaScript>";
	}
<%
}
//Start:IR:1230516R2013x:LX6
catch (Exception ex)
{
    String strAlertString = "emxRequirements.Alert." + ex.getMessage();
    String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), strAlertString);
    if (i18nErrorMessage.equals(DomainConstants.EMPTY_STRING))
    {
        session.putValue("error.message", ex.getMessage());
    }
    else
    {
        session.putValue("error.message", i18nErrorMessage);
    }
} // End of catch
%>
//]]>
</script>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
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
<!-- //End:IR:1230516R2013x:LX6 -->
</head>
</html>
