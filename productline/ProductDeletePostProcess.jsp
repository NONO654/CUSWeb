<%--
  ModelRemoveDeletePostProcess.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>


<%@page import = "java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "matrix.util.StringList"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<%
    boolean bIsError = false;
    String action = "";
    String msg = "";

    String strMode = emxGetParameter(request, "mode");
    //Instantiate the common and util beans
    ProductLineCommon commonBean = new ProductLineCommon();
    //get the table row ids of the Model objects selected
    String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    String contextID = emxGetParameter(request, "objectId");
    
    // Determine whether we have the root node, so we can refresh correctly.  If the root is selected,
    // we have to refresh the entire page so the menus are recalculated as well.
    
    boolean isRootSelected=false;
    for (int i=0; i< arrTableRowIds.length; i++) {
	    StringList slParts = FrameworkUtil.split(arrTableRowIds[i] , "|");
	    String strLevel = slParts.get(slParts.size()-1).toString();
	    StringList slLevels = FrameworkUtil.split(strLevel , ",");
	    if (slLevels.size() == 2 && slLevels.get(0).equals("0") && slLevels.get(1).equals("0")) {
	        isRootSelected=true;
	        break;
	    }
    }    
    String arrObjectIds[] = null;
    try {
        //Instantiating ProductLineUtil.java bean
        com.matrixone.apps.productline.ProductLineUtil productlineUtil = new com.matrixone.apps.productline.ProductLineUtil();
        com.matrixone.apps.productline.Product productBean = (com.matrixone.apps.productline.Product)DomainObject.newInstance(context,ProductLineConstants.TYPE_HARDWARE_PRODUCT,"ProductLine");
        
        //Getting the object ids from the table row ids
        arrObjectIds = productlineUtil.getObjectIds(arrTableRowIds);            
        boolean bReturnVal= productBean.delete(context,arrObjectIds,strMode);     
        action = "removeandrefresh";
  
    } catch (Exception e) {
        bIsError=true;
        msg = e.toString();    
		if (msg!=null && msg.indexOf("Check trigger blocked event")>= 0) {
			action = "checkTrigger";
		}else{
        action = "error";
		}
        
    }
	
    //Modified for IR-IR-347270 - Page Refresh after deleting Product Revisions
    if (isRootSelected && !bIsError) {
%>
    	  <script language="javascript" type="text/javaScript">
	    	 var objStructureTree = getTopWindow().objStructureFancyTree;    	  
	         if(objStructureTree && objStructureTree.isActive){
	         var node = objStructureTree.getNodeById("<%=XSSUtil.encodeForJavaScript(context, arrObjectIds[0])%>");
	         if (node) {
	            node.removeChildren();
	            node.remove();
	            }
	          }    	  
              var contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");
              if(contentFrameObj == null){
               		var contentFrameObj = findFrame(getTopWindow(),"content");
              }			  
              contentFrameObj.refreshSBTable(contentFrameObj.configuredTableName);
    	  </script>
<%
	//Modified for IR-IR-347270 - Page Refresh after deleting Product Revisions
    } else if(bIsError) {
    	// Model->Product Evolution->Delete Product
    	// exclude Check trigger blocked event- message being put in to session so that it will be not dispayed
    	if("checkTrigger".equalsIgnoreCase(action)){
    		%>
    		<script language="javascript" type="text/javaScript">
    		window.location.href = "../components/emxMQLNotice.jsp";
    		</script>
    		<%
    	}else{
        out.clear();
        response.setContentType("text/xml");
%>
        <mxRoot>
            <!-- XSSOK -->
            <action><![CDATA[<%= action %>]]></action>
            <!-- XSSOK -->
            <message><![CDATA[<%= msg %>]]></message>    
        </mxRoot>
<%
    	}
    }else{%>
  <script language="javascript" type="text/javaScript">
      var objStructureTree = getTopWindow().objStructureFancyTree;
      var cBoxArray = new Array();
      <%
       String[] emxTableRowIdArray = new String[arrObjectIds.length];	
       for(int i = 0; i < arrObjectIds.length; i++){
  	      StringList slParts = FrameworkUtil.split(arrTableRowIds[i] , "|");
  	      String strLevel = slParts.get(slParts.size()-1).toString();
          emxTableRowIdArray[i]= " | | |"+strLevel;
       %>
       //TODO- BPS to FIX Undefined issue in removeChild; then we can uncomment code below and remove destroy init code below.
       if(objStructureTree && objStructureTree.isActive){
        var node = objStructureTree.getNodeById("<%=XSSUtil.encodeForJavaScript(context, arrObjectIds[i])%>");
        if (node) {
         node.removeChildren();
         node.remove();
        }
       }
       //objStructureTree.removeChild("<%=XSSUtil.encodeForJavaScript(context, arrObjectIds[i])%>");
       //if(objStructureTree && objStructureTree.isActive){
        //objStructureTree.destroy();
        //objStructureTree.init();
        //var win = getTopWindow();
        //win.jQuery('#leftPanelTree').css('top', '38px');
       //}
       cBoxArray["<%=i%>"]="<%=emxTableRowIdArray[i]%>";
       <%
      }
      %>
      var contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");
      if(contentFrameObj == null){
   		var contentFrameObj = findFrame(getTopWindow(),"content");
      }	
      contentFrameObj.emxEditableTable.removeRowsSelected(cBoxArray);
      contentFrameObj.emxEditableTable.refreshStructureWithOutSort();
  </script>    	
    <%}
%>
