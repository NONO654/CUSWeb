<%--
  GBOMAddExistingPostProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.configuration.PartFamily"%>

<html>
<head>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreTree.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
</head>
<%
String strContext = emxGetParameter(request,"context");
boolean boo = false;
  try
  {
     //this will be logical feature
     String strObjId = emxGetParameter(request, "objectId");
     //get the selected Objects from the Full Search Results page
     String[] strContextObjectId    = emxGetParameterValues(request, "emxTableRowId");
     //If the selection is empty given an alert to user
     if(strContextObjectId==null){   
     %>    
       
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%
     }
     //If the selection are made in Search results page then     
     else{
           LogicalFeature logicalFTR= new LogicalFeature(strObjId);
           ProductLineUtil utilBean = new ProductLineUtil();         
           String strObjIds[]=null;
           strObjIds= (String[])utilBean.getObjectIds(strContextObjectId);
           if(strContext.equalsIgnoreCase("Part")){            
               StringList slPartToAdd= new StringList(strObjIds);
               boo= logicalFTR.addPart(context,slPartToAdd);
           }else if(strContext.equalsIgnoreCase("PartFamily")){
               boolean flag= false;
               if(strContextObjectId.length>1){
               boolean isConnectAllowed=PartFamily.isMultiplePartFamilyAllowed(context,strObjId);
               if (isConnectAllowed){
                   flag=true;
               }
               else{
                   %>    
                   <script language="javascript" type="text/javaScript">
                       alert("<emxUtil:i18n localize='i18nId'>emxConfiguration.Alert.AddPartFamily</emxUtil:i18n>");
                         var fullSearchReference = findFrame(getTopWindow(), "structure_browser");
            	    	 fullSearchReference.setSubmitURLRequestCompleted();
                   </script>
                 <%
               }
              }else{
                   flag =true;
              }
              boo=false;
              if(flag){
               StringList slPartFamilyToAdd= new StringList(strObjIds);
               boo=logicalFTR.addPartFamily(context,slPartFamilyToAdd);
              }
           }
           if(boo)
           {
           %>
           <script language="javascript" type="text/javaScript">
           var cntFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
           var parentId = "<%=XSSUtil.encodeForJavaScript(context,strObjId)%>"
           </script>
           <%
           
           for(int i=0;i<strObjIds.length;i++){
        		String objectId = strObjIds[i];
                %>
                <script language="javascript" type="text/javaScript">
                var objectId = "<%=XSSUtil.encodeForJavaScript(context,objectId)%>"
                if(cntFrame !== null && cntFrame !== undefined){
                	if(typeof cntFrame.addMultipleStructureNodes !== 'undefined' && 
                			typeof cntFrame.addMultipleStructureNodes === 'function')
                	{
                		cntFrame.addMultipleStructureNodes(objectId, parentId, '', '', false);
                	}
                }
                </script>
                <%
           }

            %>
            <script language="javascript" type="text/javaScript"> 
            //debugger;
            var contentFrameObj = openerFindFrame(getTopWindow().getWindowOpener().parent, "FTRProductContextGBOMPartTable");
            if(contentFrameObj==null)
                contentFrameObj =findFrame(getTopWindow().getWindowOpener().parent, "FTRContextGBOMPartTable");
            if(contentFrameObj==null)
            	contentFrameObj =findFrame(getTopWindow().getWindowOpener().parent, "detailsDisplay");
            contentFrameObj.editableTable.loadData();
            contentFrameObj.rebuildView();
            //contentFrameObj.location.href = contentFrameObj.location.href;
            getTopWindow().window.closeWindow();  
            </script>
            <%     
           }
    }
  }catch(Exception e)
  {     
        %>
        <script language="javascript" type="text/javaScript">
         alert("<%=XSSUtil.encodeForJavaScript(context,e.getMessage())%>");                 
        </script>
        <%    
  }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
