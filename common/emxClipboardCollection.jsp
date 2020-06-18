<%--  emxClipboardCollection.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxClipboardCollection.jsp.rca 1.3.3.2 Wed Oct 22 15:48:39 2008 przemek Experimental przemek $
--%>


<%@include file="emxNavigatorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.SetUtil" %>

/*
	To create the System Generated Collection
*/

<%
//Modified for Bug 342586
String strClipboardName 		= EnoviaResourceBundle.getProperty(context, "emxFramework.ClipBoardCollection.Name");
String strClipboardDescription 	= EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", new Locale(request.getHeader("Accept-Language")), "emxFramework.ClipBoardCollection.Description");

// Validating if the System Generated Collection exists or not
boolean bflagExists = SetUtil.exists(context,strClipboardName);

if(!bflagExists)
{

	try
	{
	   String strResult = MqlUtil.mqlCommand(context,"add set $1 property description value $2 nothidden",strClipboardName,strClipboardDescription);
	}
	catch(Exception e)
	{
	    throw e;
	}
}
%>
