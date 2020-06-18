<%--
  ProductDerivationInsertPostProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.productline.Product"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="matrix.db.JPO"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>

<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%

// Note: this Post Process JSP will NEVER be invoked if we are creating the Root Product.
// Only called if we are creating a Revision or Derivation in the context of a Model.

try {
    String newObjectId = emxGetParameter(request, "newObjectId");
    String strModelId = emxGetParameter(request,"modelID");
    String strDerivationType = emxGetParameter(request, "DerivationType");
    String relId = emxGetParameter(request, "relId");
    String strDerivedToID = emxGetParameter(request, "DerivedTo");
    String strDerivedFromID = emxGetParameter(request, "DerivedFrom");
    String isProductContext = emxGetParameter(request,"isProductContext");
    boolean boolFromProduct = Boolean.valueOf(isProductContext).booleanValue();
    String derivedToLevel = emxGetParameter(request,"derivedToLevel");
    String isRootSelected = emxGetParameter(request,"isRootSelected");
    boolean boolRootSelected = Boolean.valueOf(isRootSelected).booleanValue();
    String appDirectory = emxGetParameter(request, "emxSuiteDirectory");
    String jsTreeID = emxGetParameter(request,"jsTreeID");
    
    //if (appDirectory == null) {
    //    appDirectory = (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteProductLine" + ".Directory");
    //}
    
    matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
    ContextUtil.commitTransaction(ctx);
    
    String strObjectId = emxGetParameter(request,"objectId");
    String strLevel = emxGetParameter(request,"Level");
    String strSelParentId = emxGetParameter(request,"SelParentId");
    
    Map programMap = new HashMap();
	programMap.put("objectId", newObjectId);
	programMap.put("selId", strObjectId);
	programMap.put("selParentId", strSelParentId);
	programMap.put("DerivationType", strDerivationType);
	programMap.put("derivedToLevel", strLevel);
	String[] methodargs = JPO.packArgs(programMap);
	   
	String xml = (String)JPO.invoke(context, "emxProduct", null, "postInsertGetRowXML", methodargs, String.class);
	xml = "<mxRoot><action>add</action><data status=\"committed\" pasteBelowOrAbove=\"true\">" + xml + "</data></mxRoot>"; 
	
    //Map programMap=new HashMap();
    //programMap.put("objectId", newObjectId);
    //programMap.put("selId", strDerivedToID);
    //programMap.put("DerivationType", strDerivationType);
    //programMap.put("selParentId", strDerivedFromID);
    //programMap.put("derivedToLevel", derivedToLevel);
    //String[] methodargs = JPO.packArgs(programMap);
                
    String xmlMessage = null;
    //xmlMessage = (String)JPO.invoke(context, "emxProduct", null, "postInsertGetRowXML", methodargs, String.class);
    //xmlMessage = "<mxRoot><action>add</action><data status=\"committed\" pasteBelowOrAbove=\"true\"" + ">" + 
    //          xmlMessage + "</data></mxRoot>";
                
%>
    <script language="javascript" type="text/javascript">
    
        var contentFrameObj = findFrame(getTopWindow(),"PLCModelDerivationsTreeCategory");
        if(contentFrameObj == null) {
            contentFrameObj = findFrame(getTopWindow(),"PLCProductDerivationsTreeCategory");                        
        }        
        if(contentFrameObj == null) {
            contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");                        
        }        
        
        if(contentFrameObj == null) {
        	var strXml = '<%=xml%>';
        	contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),"content");  
        	contentFrameObj.emxEditableTable.addToSelected(strXml);
			//contentFrameObj.emxEditableTable.refreshRowByRowId(rowID);
        }
        else{
        // TODO: Refresh the Structure Browser
        var isRootSelected="<xss:encodeForJavaScript><%=boolRootSelected%></xss:encodeForJavaScript>";
	    var strDerivationType="<%=XSSUtil.encodeForJavaScript(context,strDerivationType)%>";
        var strDerivedToID = "<%=XSSUtil.encodeForJavaScript(context,strDerivedToID)%>";
        var strObjInsertedID ="<%=XSSUtil.encodeForJavaScript(context,newObjectId)%>";
        //var derivedToRow = emxUICore.selectSingleNode(contentFrameObj.oXML.documentElement,"/mxRoot/rows//r[@o ='" + strDerivedToID + "']");
    
        //var oId = derivedToRow.attributes.getNamedItem("o").nodeValue;
        //var rId = derivedToRow.attributes.getNamedItem("r").nodeValue;
        //var pId = derivedToRow.attributes.getNamedItem("p").nodeValue;
        //var lId = derivedToRow.attributes.getNamedItem("id").nodeValue;
        //var parentRowIDs = rId+"|"+oId+"|"+pId+"|"+lId
        //var parentRowIds = new Array(1);
        //parentRowIds[0] = parentRowIDs;
               
        //if ((isRootSelected=="true" && strDerivationType == "Revision") || strDerivationType == "Revision") {
            
            contentFrameObj.refreshSBTable(contentFrameObj.configuredTableName);
            
        //} else {
        //    contentFrameObj.emxEditableTable.addToSelected('<%=xmlMessage%>');
        //    contentFrameObj.emxEditableTable.removeRowsSelected(parentRowIds);
        //    var objInsertedRow = emxUICore.selectSingleNode(contentFrameObj.oXML.documentElement,"/mxRoot/rows//r[@o ='" + strObjInsertedID + "']");
        //    var lId1 = objInsertedRow.attributes.getNamedItem("id").nodeValue;
        //    var insertRowIDs = new Array(1);
        //    insertRowIDs[0] = lId1;
        //    contentFrameObj.emxEditableTable.expand(insertRowIDs,null);
        //}
        
        // Refresh the Structure Tree
            var contentFrameObj1 = findFrame(parent.getTopWindow(),"content");
            if(contentFrameObj1!=null){
             if(contentFrameObj1.addStructureTreeNode){
                contentFrameObj1.addStructureTreeNode("<%=XSSUtil.encodeForJavaScript(context,newObjectId)%>","<%=XSSUtil.encodeForJavaScript(context,strModelId)%>","<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>","Productline");
    	        try
    	        {        
    	           var topFrameObj = findFrame(parent.getTopWindow(),"_top");
    	           topFrameObj.window.focus();
    	        }catch(e){
    	            alert(e);      
    	        }
            }
           }
        }
    </script>   
<%
                
}catch(Exception exp){
    session.putValue("error.message", exp.getMessage());    
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
