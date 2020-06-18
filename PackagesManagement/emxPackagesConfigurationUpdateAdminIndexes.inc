<%-- emxPackagesConfigurationUpdateAdminIndexes.inc   -

   Copyright (c) 1992-2011 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.   
--%>
<%
// Update the HttpSession with the current Admin Indexes value
String sCacheIndex = "DataCustoCacheIndex";
String[] methodStringArgs = new String[] {} ;
String[] initargs = new String[] {};
String strAdmIndex = (String) JPO.invoke(context, "emxPackagesConfigurationProgram", initargs, "getCacheIndexAdmin", methodStringArgs, String.class);
session.setAttribute(sCacheIndex,strAdmIndex);  
%>
