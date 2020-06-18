<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>
<% response.setContentType("text/xml; charset=UTF-8"); %><?xml version="1.0" encoding="UTF-8"?>

<%-- emxSearchGetSavedSearch.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchGetSavedSearch.jsp.rca 1.15.2.1 Fri Nov  7 09:40:53 2008 ds-kvenkanna Experimental $
--%>
<%@ page import="com.matrixone.jdom.*,
                 com.matrixone.jdom.Document,
                 com.matrixone.jdom.input.*,
                 com.matrixone.jdom.output.*" %>                 
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%!
	public static String decodeSaveSearchName(String strEncodedSaveSearchName) throws Exception
	{
		StringTokenizer st = new StringTokenizer(strEncodedSaveSearchName,".");
		StringBuffer strbufDecodedSaveSearchName = new StringBuffer(16);
		while(st.hasMoreTokens())
		{
			String strToken = st.nextToken();
			char ch = (char)Integer.parseInt(strToken);
			strbufDecodedSaveSearchName.append(ch);
		}
		return strbufDecodedSaveSearchName.toString();
	}
%>

<%
String saveName = emxGetParameter(request,"saveName");

saveName = decodeSaveSearchName(saveName);


String str = "";
XMLOutputter outputter = MxXMLUtils.getOutputter();

try
{
	boolean isIE = EnoviaBrowserUtility.is(request,Browsers.IE);

	boolean isUTF8Encoding = "UTF-8".equalsIgnoreCase(request.getCharacterEncoding()) ||
		                     "UTF8".equalsIgnoreCase(request.getCharacterEncoding());


	if (!isIE && !isUTF8Encoding && request.getCharacterEncoding() != null)
	{
		//only if encoding not UTF-8 and non IE browser
		saveName = FrameworkUtil.decodeURL(saveName, request.getCharacterEncoding()); 
	}


	ContextUtil.startTransaction(context, true);

	String searchData = UISearch.getSearchData(context, saveName);
	// to support + symbol in saved search 	
	searchData = FrameworkUtil.findAndReplace(searchData,"+","%2B");
    str = FrameworkUtil.decodeURL(searchData, "UTF-8");

%><% out.clear(); %><%= str %><%  

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());
%><%@include file = "emxNavigatorBottomErrorInclude.inc"%><%  
} finally {
    ContextUtil.commitTransaction(context);
}
%>
