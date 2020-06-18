<%-- 
  ManufacturingPlanDerivationCreatePostProcess.jsp

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


<%@page import="com.matrixone.apps.productline.DerivationUtil"%>

<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>

<%      
try {
    String newObjectId = emxGetParameter(request, "newObjectId");
    String strDerivationType = emxGetParameter(request, "DerivationType");
    String strDerivedFromID = emxGetParameter(request, "DerivedFromOID");
    String isFromProductContext = emxGetParameter(request,"isFromProductContext");
    boolean boolFromProduct=Boolean.valueOf(isFromProductContext).booleanValue();

    
    String isRootSelected = emxGetParameter(request,"isRootSelected");
    boolean boolRootSelected=Boolean.valueOf(isRootSelected).booleanValue();
    String newMPContextID = emxGetParameter(request, "ContextOID");
    String currentContextID = emxGetParameter(request,"parentOID");
    String xmlMessage = "";
    
    matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
    ContextUtil.commitTransaction(ctx);
    Map programMap=new HashMap();
    programMap.put("objectId", newObjectId);
    programMap.put("selId", strDerivedFromID);
    programMap.put("DerivationType", strDerivationType);
    String[] methodargs = JPO.packArgs(programMap);
                    
    xmlMessage = (String)JPO.invoke(context, "ManufacturingPlan", null, "postCreateGetRowXML", methodargs, String.class);
    xmlMessage = "<mxRoot><action>add</action><data status=\"committed\"" + ">" + 
    xmlMessage + "</data></mxRoot>";
%>

<script language="javascript">
    var isFromProduct="<%=XSSUtil.encodeForJavaScript(context,String.valueOf(boolFromProduct))%>";
    var isRootSelected="<%=XSSUtil.encodeForJavaScript(context,String.valueOf(boolRootSelected))%>";
    var strDerivationType="<%=XSSUtil.encodeForJavaScript(context,strDerivationType)%>";
    var newMPContextID="<%=XSSUtil.encodeForJavaScript(context,newMPContextID)%>";
    var currentContextID="<%=XSSUtil.encodeForJavaScript(context,currentContextID)%>";
    var contentFrameObj = findFrame(getTopWindow(),"CFPModelManufacturingPlanDerivation");
    if(isFromProduct=="true" && currentContextID==newMPContextID) {
        var contentFrameObj = findFrame(getTopWindow(),"CFPProductManufacturingPlanComposition");
        contentFrameObj.refreshSBTable(contentFrameObj.configuredTableName);
    } else if(isFromProduct=="false") {
        contentFrameObj.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context,xmlMessage)%>');
    }
</script>   

<%
    } catch(Exception exp) {
        session.putValue("error.message", exp.getMessage());    
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

