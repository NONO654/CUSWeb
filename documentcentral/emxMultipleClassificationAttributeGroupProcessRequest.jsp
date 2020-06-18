<%--
   emxMultipleClassificationAttributeGroupProcessRequest.jsp

   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: Create a business object of a sub-type of
                Document Classification
   Parameters : Request Object
                Form : Attributes/Values collected from Dialog Page

   Author     :
   Date       :
   History    :

   static const char RCSID[] = $Id: emxMultipleClassificationAttributeGroupProcessRequest.jsp.rca 1.6 Wed Oct 22 16:54:23 2008 przemek Experimental przemek $
--%>

<%@ page import="com.matrixone.apps.framework.ui.*" %>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file="../documentcentral/emxMultipleClassificationUtils.inc"%>
<%
	Enumeration enumParam = emxGetParameterNames(request);
	String strName = "";
	String strvalue = "";
	StringBuffer appendParams = new StringBuffer();
	String strAGName = emxGetParameter(request,"objectName");
	while(enumParam.hasMoreElements())
	{
		 strName = (String)enumParam.nextElement();
		 if(strName != null)
		 {
			strvalue = emxGetParameter(request,strName);

		 }
		 appendParams.append(strName);
		 appendParams.append("=");
		 appendParams.append(strvalue);
		 appendParams.append("&");
	}
String strParams = appendParams.toString();
strParams = strParams.substring(0,strParams.length()-1);
if(strAGName != null)
{
	session.setAttribute("LCATTRIBUTEGROUPNAME",strAGName);
}
String strForwardURL = "../common/emxTree.jsp?"+appendParams.toString();
response.sendRedirect(strForwardURL);
%>
