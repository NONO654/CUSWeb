<%--  emxComponentsAddMeetingAgendaReportedAgainst.jsp  -

   Intermediate JSP to update the fields by the object Id of the selected Object

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program   
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="../components/emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<%
try {
    String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    
    String strFormName = request.getParameter("formName");
    String strFieldNameDisplay = request.getParameter("fieldNameDisplay");
    String strFieldNameActual = request.getParameter("fieldNameActual");

    String strObjnames = "";
    String strObjIds = "";

    StringBuffer objectIdsBuf = new StringBuffer(strTableRowIds.length * 15);
    StringBuffer objectNamesBuf = new StringBuffer(strTableRowIds.length * 15);
    for (int i = 0; i < strTableRowIds.length; i++) {
    	String id = strTableRowIds[i];
        id = id.substring(1, id.indexOf('|', 1));
        objectIdsBuf.append(id).append(',');
        objectNamesBuf.append(new DomainObject(id).getInfo(context, DomainConstants.SELECT_NAME)).append(',');
    }
    if(objectIdsBuf.length() > 0)
    	objectIdsBuf.deleteCharAt(objectIdsBuf.length() -1);
        
    if(objectNamesBuf.length() > 0)
    	objectNamesBuf.deleteCharAt(objectNamesBuf.length() -1);
        
    strObjIds = objectIdsBuf.toString();
    strObjnames = objectNamesBuf.toString();

%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
function setAndRefresh()
{

    var formName="<%=XSSUtil.encodeForJavaScript(context, strFormName)%>";

    var fieldNameDisplay = "<%=XSSUtil.encodeForJavaScript(context, strFieldNameDisplay)%>";
    var fieldNameActual = "<%=XSSUtil.encodeForJavaScript(context, strFieldNameActual)%>" ;

    var elementCount;
    for(var i=0;i<getTopWindow().getWindowOpener().document.forms.length;i++)
    {
        if(getTopWindow().getWindowOpener().document.forms[i].name == formName){
            elementCount = i;
            break;
        }
    }

    var fieldDisplay = getTopWindow().getWindowOpener().document.forms[elementCount].elements[fieldNameDisplay];
    var fieldActual = getTopWindow().getWindowOpener().document.forms[elementCount].elements[fieldNameActual];

    fieldDisplay.value = "<%=XSSUtil.encodeForJavaScript(context, strObjnames)%>";
	fieldActual.value =  "<%=XSSUtil.encodeForJavaScript(context, strObjIds)%>";
    getTopWindow().closeWindow();
}

</script>

<html>
<body onload=setAndRefresh()>
</body>
</html>

<%} // End of try
            catch (Exception ex) {
                session.putValue("error.message", ex.getMessage());
            } // End of catch
        %>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
