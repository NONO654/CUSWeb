<!--  emxImportLogFileView.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.

  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program.

  static const char RCSID[] = $Id: emxImportLogFileView.jsp.rca 1.1.1.2.1.4 Wed Oct 22 15:48:59 2008 przemek Experimental przemek $
-->
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
    boolean showDebug = Boolean.parseBoolean(emxGetParameter(request, "showDebug"));
    String objectId = emxGetParameter(request, "jobid");

     String logFormat = PropertyUtil.getSchemaProperty(context, "format_Log");
	String fileName = "import_log.txt";

    com.matrixone.apps.domain.Job job = new com.matrixone.apps.domain.Job(objectId);
    String workspace = context.createWorkspace() + java.io.File.separator + job.getName(context) ;
    java.io.File file = new java.io.File(workspace);
    if ( !file.exists() && !file.mkdir() )
    {
    	workspace = context.createWorkspace();
    }
    file = new java.io.File(workspace + java.io.File.separator + fileName);
    try
    {
    	if(file.exists())  //Check if the "import_log.txt" file exists
            job.checkoutFile(context, false, logFormat, fileName, workspace);
    	else
    	{   //Start: Fix for issue while viewing Export logs in Background jobs.  
    		fileName = "export_log.txt";
    		file = new java.io.File(workspace + java.io.File.separator + fileName);
    		job.checkoutFile(context, false, logFormat, fileName, workspace);
    		//End: Fix for issue while viewing Export logs in Background jobs.
    	}        
    }
     catch(Exception e)
    {
//     	System.err.println(e);
//     	System.err.println("Now attempting direct access to " + file);
    }
    MapList finalList = new MapList();
    String eachLine = null;
    Map map = null;

    StringList sLineList = new StringList();
    String headers = "Code,Type,Name,Action,Status,Description";
    StringList listHeaders = FrameworkUtil.split(headers, ",");

    if (file.exists()) {
	    FileReader fr = new FileReader(file);
	    BufferedReader br = new BufferedReader(fr);

    while ((eachLine = br.readLine()) != null)
    {
        sLineList = FrameworkUtil.split(eachLine, "\t");
        map = new HashMap();
        if(sLineList.size()==listHeaders.size() && sLineList.get(0).equals("1"))
        {
            for (int cnt=0,siz=listHeaders.size();cnt<siz;cnt++)
            {
                String sTemp = (String) sLineList.get(cnt);
                sTemp = (sTemp != null)?sTemp:"";
                map.put (listHeaders.get(cnt),sTemp);
            }
        }
	        finalList.add (map);
	    }
    }

%>
<html>
<head><title><%=XSSUtil.encodeForHTML(context, job.getAttributeValue(context, "Title"))%></title></head>
<body>
<form>
    <table width="100%" border="0" cellpadding="3" cellspacing="2" >
    <tr>
    <th nowrap="nowrap"><emxUtil:i18n localize="i18nId">emxFramework.Common.Type</emxUtil:i18n></th>
    <th nowrap="nowrap"><emxUtil:i18n localize="i18nId">emxFramework.Common.Name</emxUtil:i18n></th>
    <th nowrap="nowrap"><emxUtil:i18n localize="i18nId">emxFramework.BackgroundProcess.Action</emxUtil:i18n></th>
    <th nowrap="nowrap"><emxUtil:i18n localize="i18nId">emxFramework.BackgroundProcess.Status</emxUtil:i18n></th>
    <th nowrap="nowrap"><emxUtil:i18n localize="i18nId">emxFramework.Common.Description</emxUtil:i18n></th>

    </tr>

	<% boolean filtered = false; %>
    <fw:mapListItr mapList="<%= finalList %>" mapName="logMap">

	<%
		boolean show=true;
		String style="";
		String status = (String)logMap.get("Status");
		String action = (String)logMap.get("Action");
		if ("WARNING".equalsIgnoreCase(status)) {
			style="font-weight:bold;font-style:italic;";
		} else if ("ERROR".equalsIgnoreCase(status) ||
			"EXCEPTION".equalsIgnoreCase(status) ||
			"ABORT".equalsIgnoreCase(action))
		{
			style = "font-weight:bold; color:#AA0000;";
		} else if ("IMPORT".equalsIgnoreCase(action) ||
			"PREVIEW".equalsIgnoreCase(action))
		{
			%><!-- <tr style='background:#000000'><td colspan="5"></td></tr> --><%
		} else if ("DEBUG".equalsIgnoreCase(status)) {
			style="font-style:italic;";
			show = showDebug;
			filtered |= !show;
		}
	%>

	<%if (show) { %>
    <tr class='<fw:swap id="0"/>'>
        <td style="<%=style%>" valign="top"><%=XSSUtil.encodeForHTML(context, (String)logMap.get ("Type")) %>&nbsp;</td>
        <td style="<%=style%>" valign="top"><%=XSSUtil.encodeForHTML(context, (String)logMap.get ("Name")) %>&nbsp;</td>
        <td style="<%=style%>" valign="top"><%=XSSUtil.encodeForHTML(context, (String)logMap.get ("Action")) %>&nbsp;</td>
        <td style="<%=style%>" valign="top"><%=XSSUtil.encodeForHTML(context, (String)logMap.get ("Status")) %>&nbsp;</td>
        <td style="<%=style%>" valign="top"><%=XSSUtil.encodeForHTML(context, (String)logMap.get ("Description")) %>&nbsp;</td>
    </tr>
	<%} %>
    </fw:mapListItr>
  </table>
</form>

<% if (filtered) { %>
	<a href="javascript:location=location+'&showDebug=true'">Show debug info</a>
<% } %>
</body>
</html>



