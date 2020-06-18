<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
                      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<%--
   emxDocumentCentralCommonTopInclude.inc   -
   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   Description: Common Top include page which has the try block start.

   Author     : Anil

   Date       : 12/1/2002

   History    :

   static const char RCSID[] = "$Id: emxDocumentCentralCommonTopInclude.inc.rca 1.7 Wed Oct 22 16:02:33 2008 przemek Experimental przemek $"
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%
    //Error Message

    String emxErrorString = "";

    //Error Handling try Block begin

    try {
%>
