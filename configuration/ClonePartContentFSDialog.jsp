<%--
  ProductVariantContentFSDialog.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  //Retrieves Objectid in context
String strPartId = emxGetParameter(request, "partId");
String strobjectId  = emxGetParameter(request, "objectId");
//String strBodyURL = "../common/emxIndentedTable.jsp?expandProgram=emxFeature:expandTechnicalStructure&Export=false&PrinterFriendly=false&table=FTRClonePartTable&header=emxProduct.Heading.ClonePart.SelecteFeatures&objectId="+strobjectId+"&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&expandLevelFilterMenu=FTRExpandAllLevelFilter&HelpMarker=emxhelptechnicalfeaturepartclone";
String strBodyURL = "../common/emxIndentedTable.jsp?expandProgram=LogicalFeature:getLogicalFeatureStructure&Export=false&PrinterFriendly=false&table=FTRClonePartTable&header=emxProduct.Heading.ClonePart.SelecteFeatures&objectId="+strobjectId+"&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&expandLevelFilterMenu=FTRExpandAllLevelFilter&HelpMarker=emxhelptechnicalfeaturepartclone";
%>

<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<SCRIPT language="javascript" type="text/javaScript" >
  var objId = '<%=XSSUtil.encodeForJavaScript(context,strobjectId)%>'; 
  var strPartId = '<%=XSSUtil.encodeForJavaScript(context,strPartId)%>';
  

  function moveNext()
  {
     var formName = document.VariantFSDialogPage;
     var jselectedFeatures='';
     var the_inputs = window.frames['FeatureSelection'].document.forms[0].getElementsByTagName("input");
     var the_TR = window.frames['FeatureSelection'].document.forms[0].getElementsByTagName("tr");
     
     var tempArray = new Array();
     var msg;
     
     var submitURL;
     
   
         for(var n=0;n<the_inputs.length;n++)
         {
            if(the_inputs[n].type=="checkbox")
            {
                if(the_inputs[n].checked)                    
                {      
                    var featureChecked= the_inputs[n].name
                    tempArray = featureChecked.split("|");        	
                	if(jselectedFeatures==''){
                		
                	    jselectedFeatures=tempArray[0];
                	    
                	}else{                		
                		 jselectedFeatures=jselectedFeatures+'-'+tempArray[0];
                	}
                }
            }
           
         }
         if(!jselectedFeatures)
         {
         	 //need to give the appropriate message in the string resource.
             var alertMsg = "<%=i18nNow.getI18nString("emxProduct.Alert.ClonePart.FeatureSelection",bundle,acceptLanguage)%>"
             alert(alertMsg);
         }
         else
         { 
                         
             
        	 //formName.selectedObjectIds.value = jselectedFeatures;
        	
         	//Will go to the next page (Preview BOM)         	
         	//submitURL ="../common/emxIndentedTable.jsp?expandProgram=emxGeneratePreciseBOM:getLogicalFeatureStructureForSelectFeatures&massUpdate=false&editRootNode=false&header=emxProduct.Heading.ClonePart.GenerateBOM&objectId="+objId+"&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&table=FTRClonePartPreviewBOMTable&selection=none&editLink=true&Export=false&PrinterFriendly=false&toolbar=FTRClonePartToolbarMenu&expandLevelFilterMenu=FTRExpandAllLevelFilter&HelpMarker=emxhelptechnicalfeaturepartclone&contextPartId="+strPartId;
			submitURL ="../common/emxIndentedTable.jsp?expandProgram=emxGeneratePreciseBOM:getLogicalFeatureStructureForSelectFeatures&header=emxProduct.Heading.ClonePart.GenerateBOM&objectId="+objId+"&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&table=FTRClonePartPreviewBOMTable&selection=none&editLink=false&Export=false&PrinterFriendly=false&&toolbar=FTRClonePartToolbarMenu&expandLevelFilterMenu=FTRExpandAllLevelFilter&HelpMarker=emxhelptechnicalfeaturepartclone&SelectedFeature="+jselectedFeatures+"&contextPartId="+strPartId;
		   // formName.action=submitURL;	
		    // formName.submit();		      
		    getTopWindow().document.location.href=submitURL;
		   
         }
  }
  
  function movePrevious() 
  {
  <%
	  session.setAttribute("partId",strPartId);
  %>
	 // getTopWindow().parent.location.href=
//	  "../components/emxCommonSearch.jsp?formName=ProductCopy&frameName=pageContent&fieldNameActual=txtToFeatureId&fieldNameDisplay=txtSourceObject&searchmode=chooser&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&searchmenu=SearchAddExistingChooserMenu&searchcommand=PLCSearchProductsCommand,FTRSearchFeaturesCommand&SubmitURL=../configuration/ClonePartUtil.jsp?mode=ClonePart";
       getTopWindow().location.href= "../common/emxFullSearch.jsp?objectId="+strPartId+"&field=TYPES=type_LogicalFeature,type_HardwareProduct,type_SoftwareProduct,type_ServiceProduct&table=FTRFeatureSearchResultsTable&selection=single&showInitialResults=false&hideHeader=true&submitURL=../configuration/SearchUtil.jsp?functionality=ClonePart&HelpMarker=emxhelptechnicalfeaturepartclone";

  }

  function closeWindow()
  {
       var formName = document.VariantFSDialogPage;
       formName.action="../configuration/ClonePartUtil.jsp?mode=cleanupsession";
       formName.submit();
       getTopWindow().window.closeWindow();
  }
  
  
</SCRIPT>

<html>
<body >
   <form  name="VariantFSDialogPage"  method="post" id="VariantFSDialogPage">
   <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
   
   <input type="hidden" name="selectedObjectIds" />
  </form>
   <iframe  src="<xss:encodeForHTMLAttribute><%=strBodyURL%></xss:encodeForHTMLAttribute>" height="100%" width="100%"" frameborder="0" scrolling="no" name="FeatureSelection">
   </iframe>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
   </body>
</html>
