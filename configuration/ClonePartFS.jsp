<%--
  ClonePartFS.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>  
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
    String appendParams = emxGetQueryString(request);
    //XSSOK -JSP is DEPRECATED- will be removed as part of JSP REDUCTION
	String strPartId = emxGetParameter(request, "partId");
	//XSSOK -JSP is DEPRECATED- will be removed as part of JSP REDUCTION
    String strobjectId  = emxGetParameter(request, "objectId");
    
    String strBodyURL = null;
    String strFooterURL = null;       
    strBodyURL = "../configuration/ClonePartContentFSDialog.jsp?objectId="+strobjectId+"&partId="+strPartId;
    strFooterURL = "ClonePartFooter.jsp?" + appendParams;
%>
  
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><frameset rows="*,40,0" framespacing="0" frameborder="no" border="0" >
       <!-- XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.-->
       <frame name="pagecontentBody" src="<%=strBodyURL%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"  framespacing="5" />
       <!-- XSSOK :: This is a Deprecated JSP.Need to remove it in coming release.-->
       <frame name="pagefooter" src="<%=strFooterURL%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>
       <frame name="pagehidden" src="" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>
  </frameset>
