<%-- emxMQLNotice.jsp - included code to construct a JavaScript alert for MQL trigger Notices
		 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   code to promote given object set in request within main page
   
   static const char RCSID[] = $Id: emxMQLNotice.inc.rca 1.34 Wed Oct 22 16:09:49 2008 przemek Experimental przemek $  
--%>
<%@ page import = "matrix.db.*, matrix.util.* ,
                   com.matrixone.servlet.* ,
                   java.util.* ,
                   com.matrixone.apps.framework.ui.* ,
                   com.matrixone.apps.domain.util.*" %>
<%
    //test if we should use the script tag
    if(request.getAttribute("useScriptTags") == null){
        String dirPath = Framework.getPagePathURL("") ;
%>
<!-- //XSSOK -->
<script language="javascript" src="<%=dirPath%>common/scripts/emxUICore.js"></script>
<!-- //XSSOK -->
<script language="javascript" src="<%=dirPath%>common/scripts/emxUIModal.js"></script>
<script language="Javascript" >  
<%  }
    com.matrixone.apps.framework.ui.MqlNoticeUtil.writeMqlNotice(context,request,out);
    if(request.getAttribute("useScriptTags") == null){
%>
</script>
<% } %>
