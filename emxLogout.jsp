<%-- emxLogout.jsp - Main logout page for MatrixOne applications

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxLogout.jsp.rca 1.30 Wed Oct 22 16:09:15 2008 przemek Experimental przemek $";
--%>

<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*, java.io.*, java.util.*" errorPage="eServiceError.jsp"%>
<%@include file = "emxContentTypeInclude.inc"%>
<%@include file = "/common/emxNavigatorBaseInclude.inc"%>
<html>
<%
    //get target page defined in emxSystem.properties and forward when servlet is done
    String targetPage = Framework.getClientSideURL(response, FrameworkProperties.getProperty(context,"emxLogin.FrameworkTarget"));
    
    if (targetPage == null || targetPage.length() == 0)
    {
        targetPage = "/common/emxNavigator.jsp";
    }
    
    Framework.setTargetPage(session, targetPage);

    //get error from loading property files
    String emxNavigatorErrorMsg = (String)session.getAttribute("emxNavigator.error.message");
   
    if (emxNavigatorErrorMsg != null)
    {

%>
<script type="text/javascript">
    //XSSOK
    alert("<%=emxNavigatorErrorMsg%>");
</script>
<%
        session.removeAttribute("emxNavigator.error.message");
    }

%>
<!-- //XSSOK -->
<script language="javascript" src="<%=Framework.getClientSideURL(response, "common/scripts/emxUICore.js")%>"></script>
<script language="javascript">
// Following is the block for when the user opts for no browser toolbar
var strTopName = getTopWindow().name;
if(strTopName != null && strTopName != "" && strTopName.indexOf('NonModalWindow') > -1){
        //XSSOK
        var loginWindow = window.open("<%=LogoutServlet.getURL(false)%>");
        if(isIE){
        	loginWindow.getTopWindow().moveTo(-4,-4);
        	loginWindow.getTopWindow().resizeTo(screen.availWidth+8,screen.availHeight+8);
        }
        getTopWindow().closeWindow();
}else{
    //XSSOK
    getTopWindow().document.location.href = "<%=LogoutServlet.getURL(false)%>";
}
</script>

</html>
