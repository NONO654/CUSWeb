<%--  emxRouteStopDemoteConnectedObjectDialog.jsp   -  Dialog page for Manual-Stop functionality

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxRouteStopDemoteConnectedObjectDialog.jsp.rca 1.2.3.2 Wed Oct 22 16:17:50 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%
    String strRouteId = emxGetParameter(request, "objectId");
	String demoteObjectKey = emxGetParameter(request, "demoteObjectKey");
%>
<SCRIPT LANGUAGE="JavaScript">
//<!--
    function done_onclick(){
        var demoteConnectedObject="";
        for (var i=0;i<document.formDemoteObject.elements.length;i++) {
            if(document.formDemoteObject.elements[i].name == "demoteConnectedObject") {
                if(document.formDemoteObject.elements[i].checked) {
                    demoteConnectedObject=document.formDemoteObject.elements[i].value;
                    break;
                }
            }
        }
        submitWithCSRF("emxStopRouteProcess.jsp?objectId=<%=XSSUtil.encodeForURL(context, strRouteId)%>&demoteObjectKey=<%=XSSUtil.encodeForURL(context, demoteObjectKey)%>&demoteConnectedObject="+demoteConnectedObject, window.getTopWindow().getWindowOpener().parent.frames["formViewHidden"]);        
        getTopWindow().closeWindow();
    }
     function cancel_onclick(){
         getTopWindow().closeWindow();
    }

//-->
</SCRIPT>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>

<!-- Page display code here -->
<FORM METHOD=POST ACTION="emxStopRouteProcess.jsp" Name="formDemoteObject">

    <TABLE width="100%" cellspacing="2" cellpadding="3">
        <TR>
        <%
		if(demoteObjectKey!=null && demoteObjectKey.equalsIgnoreCase("RouteAndSubRoute"))
		{
		%>
            <TD class="labelRequired" width="50%"><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxComponents.Common.DemoteConnectedObjects.ParentAndSubRoutes", "emxComponentsStringResource", lStr))%></TD>
        <%
		}else if(demoteObjectKey!=null && demoteObjectKey.equalsIgnoreCase("OnlyRoute"))
		{
		%>
            <TD class="labelRequired" width="50%"><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxComponents.Common.DemoteConnectedObjects", "emxComponentsStringResource", lStr))%></TD>
		<%
		}else if(demoteObjectKey!=null && demoteObjectKey.equalsIgnoreCase("OnlySubRoute"))
		{
		%>	 
			<TD class="labelRequired" width="50%" ><%=XSSUtil.encodeForHTML(context, i18nNow.getI18nString("emxComponents.Common.DemoteConnectedObjects.Sub-Route", "emxComponentsStringResource", lStr))%></TD>
		<%
		}
		%>	
            <TD class="inputField">
                <!-- //XSSOK -->
                <INPUT TYPE="radio" NAME="demoteConnectedObject" value="true" /><%=getI18NString("emxComponentsStringResource", "emxComponents.Common.Yes", lStr)%>
                <br/>
                <!-- //XSSOK -->
                <INPUT TYPE="radio" NAME="demoteConnectedObject" value="false" checked /><%=getI18NString("emxComponentsStringResource", "emxComponents.Common.No", lStr)%>
            </TD>
        </TR>
    </TABLE>
</FORM>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>
