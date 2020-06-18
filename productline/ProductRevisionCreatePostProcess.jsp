<%--
  ProductRevisionCreatePostProcess.jsp
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

<%@page import="com.matrixone.apps.productline.DerivationUtil"%>
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
    StringBuffer xmlBuffer = new StringBuffer();
    xmlMessage = (String)JPO.invoke(context, "emxProduct", null, "postCreateGetRowXML", methodargs, String.class);

    if (strDerivationType.equals(DerivationUtil.DERIVATION_TYPE_DERIVATION)) {
        xmlMessage = "<mxRoot><action>add</action><data status=\"committed\">" + xmlMessage + "</data></mxRoot>";
    } else {
        xmlMessage = "<mxRoot><action>add</action><data status=\"committed\" pasteBelowOrAbove=\"true\">" + xmlMessage + "</data></mxRoot>";
    }
%>
    <script language="javascript" type="text/javascript">

	    // Refresh the Structure Browser
        var isRootSelected = "<xss:encodeForJavaScript><%=isRootSelected%></xss:encodeForJavaScript>";
	    var strDerivationType = "<%=XSSUtil.encodeForJavaScript(context,strDerivationType)%>";
        var isProductContext = "<xss:encodeForJavaScript><%=isProductContext%></xss:encodeForJavaScript>";
        var strRevision = "<xss:encodeForJavaScript><%=DerivationUtil.DERIVATION_TYPE_REVISION%></xss:encodeForJavaScript>";
        //var strLevel = "<%=strLevel%>";

        var contentFrameObj = findFrame(getTopWindow(),"PLCModelDerivationsTreeCategory");
		if (contentFrameObj == null) {
		 contentFrameObj = findFrame(getTopWindow(),"PLCProductDerivationsTreeCategory");
		}      
		if (contentFrameObj == null) {
            contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");                        
        }

        // If we are on the root level, refresh the entire table.
        // For anything below the root level, we can manipulate and update the XML.  For Revisions,
        // however, make sure to refresh the Selected Row also, since the new row will be at the same level and
        // the Latest flag may need to change!
        var contentFrameObj1 = findFrame(parent.getTopWindow(),"content");
        if(contentFrameObj1!=null){
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
        if (isRootSelected=="true") {
		    //contentFrameObj.refreshSBTable(contentFrameObj.configuredTableName);
			//Modify for PLC Categories consolidation
	        contentFrameObj.location.href = contentFrameObj.location.href;
		} else {
            contentFrameObj.emxEditableTable.addToSelected('<xss:encodeForJavaScript><%=xmlMessage%></xss:encodeForJavaScript>');
		    if (strDerivationType == strRevision) {
		    	contentFrameObj.emxEditableTable.refreshSelectedRows();
            }
        }
      

    </script>   
<%
            
} catch (Exception exp) {
	// Changes added for IR-584139-3DEXPERIENCER2019x
    //session.putValue("error.message", exp.getMessage());    
	String alertString = "emxProduct.Alert." + exp.getMessage();
	String i18nErrorMessage = i18nStringNowUtil(alertString,bundle,acceptLanguage);

	if ("".equals(i18nErrorMessage)){
	   
	   i18nErrorMessage = exp.getMessage();
	}
	i18nErrorMessage = i18nErrorMessage.trim();   
	if(i18nErrorMessage.contains("1500789")){
		String TNRNotUnique = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Alert.TNRNotUnique");
		throw new FrameworkException(TNRNotUnique);
	}
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
