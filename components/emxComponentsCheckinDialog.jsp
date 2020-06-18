<%-- emxComponentsCheckinDialog.jsp - used for Checkin Dialog Page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsCheckinDialog.jsp.rca 1.6 Wed Oct 22 16:18:20 2008 przemek Experimental przemek $"
--%>
<% 
	String charset = request.getParameter("checkinEncoding");
    String contentType = "MS932".equalsIgnoreCase(charset) ? "text/html; charset=MS932" :
        				 "iso-8859-1".equalsIgnoreCase(charset) ? "text/html; charset=iso-8859-1" :
						 "MS936".equalsIgnoreCase(charset) ? "text/html; charset=MS936" :
						 "MS949".equalsIgnoreCase(charset) ? "text/html; charset=MS949" :
						 "MS950".equalsIgnoreCase(charset) ? "text/html; charset=MS950" : 
						 "GB2312".equalsIgnoreCase(charset) ? "text/html; charset=GB2312" : "text/html; charset=UTF-8";
        				         
    response.setContentType(contentType);
%>
<%@include file = "emxComponentsCheckinDialogCode.inc"%>
