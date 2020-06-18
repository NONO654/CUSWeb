<%-- emxLibraryCentralClassificationPostProcess.jsp

   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLibraryCentralPostProcess.jsp.rca 1.7 Wed Oct 22 16:02:39 2008 przemek Experimental przemek $
   
--%>

<html>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "../documentcentral/emxLibraryCentralUtils.inc"%>

<%
    String objectId           = emxGetParameter(request, "objectId");
    String selectedClassIds   = emxGetParameter(request, "selectedClassIds");
    String newClassIds        = emxGetParameter(request, "ClassOID");
    String classificationMode = emxGetParameter(request, "classificationMode");
    String rowId              = emxGetParameter(request, "rowId");
    
    
    boolean isReClassifyMode  = !UIUtil.isNullOrEmpty(classificationMode) && "reClassification".equalsIgnoreCase(classificationMode);
    
    if(!UIUtil.isNullOrEmpty(newClassIds)) {
    	newClassIds        = newClassIds.replace("|",",");
    }
   	selectedClassIds   = isReClassifyMode ? selectedClassIds+","+newClassIds:newClassIds;
    if(classificationMode.equals("reloadBOMCell")){
%>
<script language=javascript>
    var sbFrame = findFrame(getTopWindow(),"listHidden").parent;
    sbFrame.emxEditableTable.refreshRowByRowId("<xss:encodeForJavaScript><%=rowId%></xss:encodeForJavaScript>");
    var objectId = "<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>";
    var rows = emxUICore.selectNodes(sbFrame.oXML,"/mxRoot/rows//r[@o='"+objectId+"']");
    for(var i=0;i<rows.length;i++){
        var rowId = rows[i].getAttribute("id");
        sbFrame.emxEditableTable.refreshRowByRowId(rowId);
    }
    getTopWindow().closeSlideInDialog();
</script>
<%
    }else{
%>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language=javascript>
	var vParentObjectIds = "<xss:encodeForJavaScript><%=selectedClassIds%></xss:encodeForJavaScript>";
	var vAppDirectory    = "<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>";
	updateCountAndRefreshTree(vAppDirectory, getTopWindow(), vParentObjectIds );
    //getTopWindow().refreshTablePage();
</script>
<% } %>
</html>
