<%-- emxMultipleClassificationReclassifyFS.jsp

   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   static const char RCSID[] ="$Id: emxMultipleClassificationReclassifyFS.jsp.rca 1.5 Wed Oct 22 16:54:23 2008 przemek Experimental przemek $"
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="../documentcentral/emxMultipleClassificationUtils.inc"%>
<%
	final String MCM_STRING_RESOURCE = "emxLibraryCentralStringResource";

	String strLanguage     = request.getHeader("Accept-Language");
	String strAppDirectory = appDirectory;
	String strHelpMarker   = "emxhelpreclassifyaction";

	framesetObject fs = new framesetObject();
    fs.useCache(false);
    fs.setDirectory(strAppDirectory);
    fs.setStringResourceFile(MCM_STRING_RESOURCE);

    fs.setPageTitle (EnoviaResourceBundle.getProperty(context,MCM_STRING_RESOURCE,
            new Locale(strLanguage),"emxMultipleClassification.Common.Dialog"));

    String strPageHeading = "emxMultipleClassification.Common.ReclassifyAction";
	StringBuffer strbufContentUrl = new StringBuffer("emxMultipleClassificationReclassify.jsp");
    strbufContentUrl.append("?dir="+strAppDirectory);

	// Append the parameter to the content page
	for (Enumeration e = emxGetParameterNames (request); e.hasMoreElements();)
	{
		String strParamName  = (String)e.nextElement();
		String strParamValue = (String)emxGetParameter(request, strParamName);
		if (strbufContentUrl.length() > 0)
		{
			strbufContentUrl.append("&");
		}
		strbufContentUrl.append(strParamName+"="+strParamValue);
	}

	String strContentUrl = strbufContentUrl.toString();

    fs.initFrameset(strPageHeading,
	                strHelpMarker,
					strContentUrl,
					false,
					true,
					false,
					false);

	fs.createCommonLink("emxMultipleClassification.Common.Yes",
                        "submitForm()",
                        "role_GlobalUser",
                        false,
                        true,
                        "common/images/buttonDialogDone.gif",
                        false,
                        0);

    fs.createCommonLink("emxMultipleClassification.Common.No",
                        "closeWindow()",
                        "role_GlobalUser",
                        false,
                        true,
                        "common/images/buttonDialogCancel.gif",
                        false,
                        0);

    fs.writeSelectPage(out);
%>
