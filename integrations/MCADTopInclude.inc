<%--  MCADTopInclude.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ page import="java.util.*,java.io.*, java.net.*,com.matrixone.MCADIntegration.server.*,com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*,com.matrixone.MCADIntegration.utils.customTable.*"  %>
<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*"%>
<%@page contentType="text/html; charset=UTF-8"%>

<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<%@ include file = "./MCADResponseHeaderInclude.inc" %>
<%@ include file = "../emxTagLibInclude.inc" %>

<%
	String lStr		= request.getHeader("Accept-Language");
	String langStr	= i18nStringNow("emxFramework.HelpDirectory", lStr);

	if(langStr == null || "".equals(langStr))
		langStr = "en";

	boolean isCustomLiveConnect	= false;
	String userAgent			= request.getHeader("USER-AGENT");
	if(userAgent.indexOf("IRIX") > -1 && userAgent.indexOf("Netscape") < 0)
	{
		isCustomLiveConnect = true;
	}
%>

<%!
	//Replace allthe HTML special characters with corrsponding HTML representation.
	static public String getHtmlSafeString(String inputString)
	{
		char[] htmlEncChar = {'&', '"', '<', '>', '\\', '\n'};
		String[] htmlEncStr = {"&amp;", "&quot;", "&lt;", "&gt;", "\\\\", "<br>"};


		StringBuffer strOut = new StringBuffer(inputString);
		//Browse all the special characters
		for (int i = 0; i < htmlEncChar.length; i++) 
		{
			int index = strOut.toString().indexOf(htmlEncChar[i]);
			while (index != -1) 
			{
				strOut.setCharAt(index, htmlEncStr[i].charAt(0));
				strOut.insert(index + 1, htmlEncStr[i].substring(1));
				//get next occurance
				index = index + htmlEncStr[i].length();
				index = strOut.toString().indexOf(htmlEncChar[i], index);
			}
		}
		return(strOut.toString());
	}
%>

<%!
	//
	// check for request Attribute if request.getParameter returns null
	// Also check if the value is "null" string and if so return null
	//
	static public String emxGetParameter(HttpServletRequest request, String parameter)
	{
		try
		{
			return com.matrixone.apps.domain.util.Request.getParameter(request, parameter);
		} 
		catch(Exception ex) 
		{
			System.out.println("EXCEPTION IN emxGetParameter()");
			return null;
		}
	}
%>

<%!
    static public String[] emxGetParameterValues(HttpServletRequest request, String parameter)
    {
        String parameterValues[] = request.getParameterValues(parameter);
        return parameterValues;
    }
%>

<%!
	//
	// return the list of parameter names
	//
	static Enumeration emxGetParameterNames(HttpServletRequest req)
	{
		Enumeration paramElements = req.getParameterNames();
		return (paramElements);
	}
%>

<%!
	static public String emxGetEncodedQueryString(Context context ,HttpServletRequest request)
	{
		String queryString = "";
		Enumeration enumParamNames = request.getParameterNames();
		while(enumParamNames.hasMoreElements()) 
		{
			String paramName =(String) enumParamNames.nextElement();
			String paramValue = com.matrixone.apps.domain.util.Request.getParameter(request, paramName);
			if (paramValue != null && paramValue.trim().length() > 0 )
				paramValue = XSSUtil.encodeForURL(XSSUtil.encodeForJavaScript(context,paramValue));
			queryString += "&"+paramName+ "=" +paramValue;
		}
		return queryString;
	}
%>


<%!
	//
	// return the Querystring of request
	//
	static public String emxGetQueryString(HttpServletRequest request)
	{
		String queryString = request.getQueryString();
		return queryString;
	}
%>

<%!
    // Call this method to internationalize variables in java.
    static public String i18nStringNow(String text, String languageStr) throws MatrixException
    {
        com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();

        String returnString = text;
        try{
            String I18NreturnString = (String) loc.GetString("emxFrameworkStringResource ", languageStr, text);
            if ((!"".equals(I18NreturnString)) && (I18NreturnString != null)){
                returnString = I18NreturnString;
            }

        } catch(Exception e) {

        // String must not have been in Property File or another Exception
        // Return the string id.
        }
        return returnString;
    }
%>
