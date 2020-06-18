<%--
  DesignVariantAddPostProcess.jsp
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
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import = "com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
try
{   
      String strObjId = emxGetParameter(request, "objectId");      
      String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
      String strdvMode = emxGetParameter(request, "dvMode");
      boolean isSlideInDV=false;
      if("slideindv".equalsIgnoreCase(strdvMode)){
    	  isSlideInDV=true;
      }
      if (strContextObjectId == null) {
      %>
		<script language="javascript" type="text/javaScript">
		alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
		</script>
      <%}
      else {
          for (int i = 0; i < strContextObjectId.length; i++) {
              String strOJectRel = strContextObjectId[i];
              if(strOJectRel.indexOf("|")!= -1){
              strOJectRel = strOJectRel.substring(1, strOJectRel.length());
               strOJectRel = strOJectRel.substring(0, strOJectRel.indexOf("|"));
              }

              strContextObjectId[i] = strOJectRel;
          }
          if(strObjId.indexOf(",")!= -1){
              strObjId = strObjId.substring(0, strObjId.indexOf(","));
          }
          
          String strToConnectObject = "";
          Object objToConnectObject = "";
          StringList strLst = new StringList(strContextObjectId.length);
          //Extracting the Object Id from the String.
          for (int i = 0; i < strContextObjectId.length; i++) {
              StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i], "|");
              for (int j = 0; j < strTokenizer.countTokens(); j++) {
                  objToConnectObject = strTokenizer.nextElement();
                  strToConnectObject = objToConnectObject.toString();
                  strLst.addElement(strToConnectObject);
              }
          }
	      try{
	       	  // code to call he addDesignVariant routine and return boolean on success       	  
	       			  LogicalFeature lfBean = new LogicalFeature(strObjId);
	     	  boolean bAddDV = lfBean.addDesignVariants(context,strLst);  
	          if (bAddDV) {
	           %>
				<script language="javascript" type="text/javaScript">
		          var isSlideInDV='<%=isSlideInDV%>';
		          if(isSlideInDV  == 'true'){
	         		var slideInFrame = findFrame(getTopWindow(),"slideInFrame");
	         		slideInFrame.editableTable.loadData();
	         		slideInFrame.emxEditableTable.refreshStructureWithOutSort(); 
	         		//getTopWindow().closeWindow();
		         }else{
	                var openerParent=getTopWindow().getWindowOpener().parent.parent;
	                var frameName = null;
					var parentFrame = findFrame(getTopWindow(),"detailsDisplay");
					frameName = findFrame(parentFrame,"FTRContextGBOMPartTable");
	                if(frameName == null || frameName == "undefined"){
	                		frameName = findFrame(parentFrame,"FTRDVConfigurationFeatureContextCommand");
	                }
					if(frameName !== null && frameName !== "undefined"){
						openerParent = frameName ;
	                }
					var isChrome = Browser.CHROME;
		            if(isChrome){
		            	openerParent.location.href = openerParent.location.href;
						getTopWindow().window.closeWindow();
		            }else{
		            	getTopWindow().closeWindow();
		            	openerParent.location.href=openerParent.location.href;
		            }      
		         }
				</script>
	           <%} else {
	        	   // write the exception block here.
	           }
	          }catch(Exception e){
	        	  throw new FrameworkException(e.getMessage());
              }
      }
    }catch(Exception e)
     { 
            session.putValue("error.message", e.getMessage());
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
