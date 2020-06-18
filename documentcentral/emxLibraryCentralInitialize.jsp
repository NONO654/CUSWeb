<%--  emxLibraryCentralInitialize.jsp
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description:
   Parameters :

   static const char RCSID[] = "$Id: emxLibraryCentralInitialize.jsp.rca 1.5 Wed Oct 22 16:02:23 2008 przemek Experimental przemek $"
--%>

<%@page import="com.matrixone.apps.library.LibraryCentralCommon"%>

<%@include file = "../emxUICommonAppInclude.inc"%>

<%

  //Fix 375995, load allowed types from the relations.
  try{
	  LibraryCentralCommon.loadImportSettings(context);
  } catch(Exception e) {
      e.printStackTrace();
  }
%>

