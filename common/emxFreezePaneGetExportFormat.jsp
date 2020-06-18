<% response.setContentType("text/xml; charset=UTF-8"); %><?xml version="1.0" encoding="UTF-8"?>
<%-- emxFreezePaneExport.jsp
Copyright (c) 1992-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of MatrixOne,Inc.
Copyright notice is precautionary only
and does not evidence any actual or intended publication of such program

static const char RCSID[] = $Id: emxFreezePaneGetExportFormat.jsp.rca 1.4 Wed Oct 22 15:47:47 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>


<%
String exportFormat = "";
try
{
    response.addHeader("Cache-Control", "no-cache");
    ContextUtil.startTransaction(context, true);
	exportFormat = PersonUtil.getExportFormat(context);
    if (exportFormat == null || exportFormat.trim().length() == 0)
    {
        exportFormat = EnoviaResourceBundle.getProperty(context, "emxFramework.Preferences.ExportFormat.Default");
        if (exportFormat == null || exportFormat.trim().length() == 0)
        {
          exportFormat = "CSV";
        }
    }
    ContextUtil.commitTransaction(context);

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    ex.printStackTrace();
}

%>

<mxRoot>
<!-- //XSSOK -->
<format><![CDATA[<%= exportFormat %>]]></format>
</mxRoot>

