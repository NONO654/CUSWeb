<%--  emxStructureCompareCriteriaProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxStructureCompareProcess.jsp.rca 1.1.3.2 Wed Oct 22 15:48:52 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%
    String emxTableRowId        = emxGetParameter(request,"emxTableRowId");
    String isSelected           = "false";
    String strCallbackFunc      = XSSUtil.encodeForJavaScript(context, emxGetParameter(request,"callbackFunction"));    
    String selectedId           = "";
    
    if(emxTableRowId != null){
        selectedId = (String)com.matrixone.apps.domain.util.FrameworkUtil.split(emxTableRowId,"|").elementAt(0);
        isSelected = "true";
    }   
%>
<script src="scripts/emxUICore.js" type="text/javascript"></script>
<script type="text/javascript">
    try{
        //XSSOK
        if("<%=isSelected%>" == "true"){
            var callback = eval(getTopWindow().getWindowOpener().<%=strCallbackFunc%>);
            callback("<xss:encodeForJavaScript><%=selectedId%></xss:encodeForJavaScript>");
            getTopWindow().closeWindow();
        }else{
            var alertMsg = "<emxUtil:i18n localize='i18nId'>emxFramework.Common.PleaseMakeASelection</emxUtil:i18n>";
            alert(alertMsg);
        }       
    } catch (ex){
        alert(ex.message);
    }   
</script>
