<%-- 
  ManufacturingPlanCreateNewPostProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  
--%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlan"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="matrix.db.JPO"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>


<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="matrix.util.StringList"%>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%      
try{
    String newObjectId = emxGetParameter(request, "newObjectId");
    String strDerivationType = emxGetParameter(request, "DerivationType");
    String strDerivedToID = emxGetParameter(request, "DerivedTo");
    String strDerivedFromID = emxGetParameter(request, "DerivedFrom");
    String isFromProductContext = emxGetParameter(request,"isFromProductContext");
    boolean boolFromProduct=Boolean.valueOf(isFromProductContext).booleanValue();
    String derivedToLevel = emxGetParameter(request,"derivedToLevel");
    String isRootSelected = emxGetParameter(request,"isRootSelected");
    boolean boolRootSelected=Boolean.valueOf(isRootSelected).booleanValue();
    
    
    String xmlMessage = "";
    
    matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
    ContextUtil.commitTransaction(ctx);
    
//    Map programMap=new HashMap();
//    programMap.put("objectId", newObjectId);
//    programMap.put("selId", strDerivedToID);
//    programMap.put("DerivationType", strDerivationType);
//    programMap.put("selParentId", strDerivedFromID);
//    programMap.put("derivedToLevel", derivedToLevel);
//    String[] methodargs = JPO.packArgs(programMap);
                
//    xmlMessage = (String)JPO.invoke(context, "ManufacturingPlan", null, "postInsertGetRowXML", methodargs, String.class)
//  xmlMessage = "<mxRoot><action>add</action><data status=\"committed\" pasteBelowOrAbove=\"true\"" + ">" + 
//  xmlMessage + "</data></mxRoot>";
%>
<script language="javascript">
    var isFromProduct="<%=XSSUtil.encodeForJavaScript(context,String.valueOf(boolFromProduct))%>";
    var isRootSelected="<%=XSSUtil.encodeForJavaScript(context,String.valueOf(boolRootSelected))%>";
    var strDerivationType="<%=XSSUtil.encodeForJavaScript(context,strDerivationType)%>";
    var contentFrameObj = findFrame(getTopWindow(),"CFPModelManufacturingPlanDerivation");   

    var strDerivedToID = "<%=XSSUtil.encodeForJavaScript(context,strDerivedToID)%>";
    var strObjInsertedID ="<%=XSSUtil.encodeForJavaScript(context,newObjectId)%>";
    
    
//        var derivedToRow = emxUICore.selectSingleNode(contentFrameObj.oXML.documentElement,"/mxRoot/rows//r[@o ='" + strDerivedToID + "']");

//        var oId = derivedToRow.attributes.getNamedItem("o").nodeValue;
//        var rId = derivedToRow.attributes.getNamedItem("r").nodeValue;
//        var pId = derivedToRow.attributes.getNamedItem("p").nodeValue;
//        var lId = derivedToRow.attributes.getNamedItem("id").nodeValue;
//        var parentRowIDs = rId+"|"+oId+"|"+pId+"|"+lId
//        var prentRowIds = new Array(1);
//        prentRowIds[0] = parentRowIDs;
//           
//        if((isFromProduct=="false" && isRootSelected=="true" && strDerivationType == "Revision") || strDerivationType == "Revision") {
            contentFrameObj.refreshSBTable(contentFrameObj.configuredTableName);
//        } else {
//          contentFrameObj.emxEditableTable.addToSelected('<%=xmlMessage%>');
//          contentFrameObj.emxEditableTable.removeRowsSelected(prentRowIds);
//          var objInsertedRow = emxUICore.selectSingleNode(contentFrameObj.oXML.documentElement,"/mxRoot/rows//r[@o ='" + strObjInsertedID + "']");
//  
//          var lId1 = objInsertedRow.attributes.getNamedItem("id").nodeValue;
//          var insertRowIDs = new Array(1);
//          insertRowIDs[0] = lId1;
//          contentFrameObj.emxEditableTable.expand(insertRowIDs,null);
//        }

</script>   
<%
                
}catch(Exception exp){
    session.putValue("error.message", exp.getMessage());    
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


