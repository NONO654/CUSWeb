<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@ page import = "matrix.db.Context"%>
<%@ page import = "com.matrixone.servlet.Framework"%>

<%
    //IR-485253-3DEXPERIENCER2016x
    Context cntx = Framework.getFrameContext(session);
    if(!AdminUtilities.isCentralAdmin(cntx) &&  !AdminUtilities.isLocalAdmin(cntx) &&  !AdminUtilities.isProjectAdmin(cntx)) {
%>
        <jsp:forward page="../common/emxPLMOnlineAdminForbiddenAccess.jsp"/>
<%
    }
%>
