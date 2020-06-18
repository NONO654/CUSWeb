<%--
  ProductDerivationCreatePostProcess.jsp
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
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="matrix.db.JPO"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>


<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
                 
<%

try {
    String strProductId = emxGetParameter(request,"newObjectId");
    String strModelId = emxGetParameter(request,"modelID");
    String strDerivationType = emxGetParameter(request,"DerivationType");
    String relId = emxGetParameter(request,"relId");
    String strParentId = emxGetParameter(request,"objectID");
    String strDerivedFromID = strParentId;
    String strProductContext = emxGetParameter(request,"UIContext");
    boolean isProductContext = strProductContext.equals("product");
    String strRootProduct = emxGetParameter(request,"isRootProduct");
    boolean isRootProduct = strRootProduct.equalsIgnoreCase("true");
    String strLevel = emxGetParameter(request,"derivedToLevel");
    String appDirectory = emxGetParameter(request, "emxSuiteDirectory");
    String strJsTreeID = (String)emxGetParameter(request, "jsTreeID");
    if (strParentId == null) {
        strParentId = strModelId;
    }
    
    if (appDirectory == null) {
        appDirectory = (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteProductLine" + ".Directory");
    }
    
    matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
    ContextUtil.commitTransaction(ctx);

    boolean isRootSelected = false;
    StringList slLevels = FrameworkUtil.split(strLevel , ",");
    if (slLevels.size() == 2) {
        isRootSelected=true;
    }

    Map programMap = new HashMap();
    programMap.put("objectId", strProductId);
    programMap.put("selId", strDerivedFromID);
    programMap.put("DerivationType", strDerivationType);
    programMap.put("Level", strLevel);
    String[] methodargs = JPO.packArgs(programMap);
    
    String xmlMessage = null;
    xmlMessage = (String)JPO.invoke(context, "emxProduct", null, "postCreateGetRowXML", methodargs, String.class);
    xmlMessage = "<mxRoot><action>add</action><data status=\"committed\">" + xmlMessage + "</data></mxRoot>";
            
%>
    <script language="javascript" type="text/javascript">

	    // Refresh the Structure Browser
        var isRootSelected = "<xss:encodeForJavaScript><%=isRootSelected%></xss:encodeForJavaScript>";
	    var strDerivationType = "<%=XSSUtil.encodeForJavaScript(context,strDerivationType)%>";
        var isProductContext = "<xss:encodeForJavaScript><%=isProductContext%></xss:encodeForJavaScript>";
	    
		var contentFrameObj = findFrame(getTopWindow(),"PLCModelDerivationsTreeCategory");
		if (contentFrameObj == null) {
		 contentFrameObj = findFrame(getTopWindow(),"PLCProductDerivationsTreeCategory");
		}      
		if (contentFrameObj == null) {
            contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");                        
        }

        contentFrameObj.emxEditableTable.addToSelected('<%=XSSUtil.encodeForJavaScript(context,xmlMessage)%>');
        //Start-------Refresh Tree: Derivation Create update Left Tree to add Product under Model
        var contentFrameObj1 = findFrame(parent.getTopWindow(),"content");
        if(contentFrameObj1 != null){
	        if(contentFrameObj1.addStructureTreeNode){
	          var objStructureTree = getTopWindow().objStructureFancyTree;
	          if(objStructureTree && objStructureTree.isActive){
	              var node = objStructureTree.getNodeById("<%=XSSUtil.encodeForJavaScript(context, strModelId)%>");
		          if (node) {
			          contentFrameObj1.addStructureTreeNode("<%=XSSUtil.encodeForJavaScript(context,strProductId)%>","<%=XSSUtil.encodeForJavaScript(context,strModelId)%>","<%=XSSUtil.encodeForJavaScript(context,strJsTreeID)%>","Productline");
		          }
	          }
	        }
        }
        //END-------Refresh Tree: Derivation Create update Left Tree to add Product under Model
    </script>   
<%
            
}catch (Exception exp) {
    session.putValue("error.message", exp.getMessage());    
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
