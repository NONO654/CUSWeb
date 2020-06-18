<%--  emxPackagesManagementTableValidation.jsp
   Copyright (c) 1999-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program
 --%>

// This validation file should not contain any HTML or JavaScript tags.


<%@page contentType="text/javascript; charset=UTF-8"%>
<%@ page import="matrix.db.Context"%>
<%@page import="com.matrixone.servlet.Framework"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>


function nlsDisplay(str){
	var tmp = str.title;
 	str.title = tmp.replace(/\|/g,'\n'); 
}
