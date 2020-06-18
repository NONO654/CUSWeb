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
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>

<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ProductVariant"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>

<script language="JavaScript" type="text/javascript" src="../configuration/scripts/emxUIDynamicProductVariant.js"></script>

<%
  //Retrieves Objectid in context
  String strObjectId = emxGetParameter(request, "objectId");
  String jsTreeId = emxGetParameter(request, "jsTreeID");
  String relId = emxGetParameter(request, "relId");
  String strVariantName = emxGetParameter(request, "variantName");
  String strProductVariantId = emxGetParameter(request, "productVariantId");
  String strMode = emxGetParameter(request, "mode");
  String strContext = emxGetParameter(request, "context");
  
  String strTimeStamp = emxGetParameter(request, "timeStamp");
  String strSelectedFeatures = emxGetParameter(request, "selectedFeatures");
  String strproductId = emxGetParameter(request, "parentID");
  
  String selectedData = emxGetParameter(request, "selectedData");
    
  // IVU - Start 
      String featureOptions = "emxProduct.Header.FeaturesAndOptions";
      String type= "emxProduct.Table.Type";
      String usage = "emxProduct.Table.Usage";
      
   // IVU - End
  
  %>
  
  <html>
  <head>
    <link rel="stylesheet" type="text/css" media="screen" href="./styles/emxUIConfigurator.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="./styles/emxUILayerDialog.css" />
  </head>
        <body onload="setDIVProperty()">
        <form name="featureOptions" method="post">
        <%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
          <div id="mx_divBasePrice">
            <table border="0" cellpadding="0" cellspacing="0">
              <thead>
                 <tr>
                  <th class="mx_status">&#160;</th>
                  <th class="mx_name"><framework:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,featureOptions)%></framework:i18n></th>
                  <th class="mx_info">&#160;&#160;<framework:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,type)%></framework:i18n></th>
                  <th class="mx_usage">&#160;&#160;<framework:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,usage)%></framework:i18n></th>
                </tr>
              </thead>
              <tbody>
                  <tr>
                  <td class="mx_status">&#160;</td>
                  <td class="mx_name"></td>
                  <td class="mx_info">&#160;</td>
                  <td class="mx_usage">&#160;</td>
                </tr>
              </tbody>
            </table>
          </div>
        <%
        ProductVariant prodVar = new ProductVariant();
        if(selectedData!=null){
            String[] selectedDataArr = selectedData.split(",");
            prodVar.selectedDataList = ConfigurationUtil.getCollectionArray(selectedDataArr);   
        } 
        
        MapList relatedObjectsList = new MapList();
        String component = null;
        if(strContext!=null && (strContext.equalsIgnoreCase("clone") || strContext.equalsIgnoreCase("viewClone")) )
        {
            relatedObjectsList = prodVar.getEffectivityStructure(context,strProductVariantId,strproductId);
            component = prodVar.getEffectivityStructureHTMLDisplay(context, relatedObjectsList, strProductVariantId, strproductId);
        }
        else{
             relatedObjectsList = prodVar.getEffectivityStructure(context,strObjectId,strproductId);
             component = prodVar.getEffectivityStructureHTMLDisplay(context, relatedObjectsList, strObjectId, strproductId);            
        }               
        
        session.setAttribute("DataToLoad",component);
        out.print(component);
        %>
        
        <input type="hidden" name="logicalfeaturerels" id="hlogicalfeaturerels" value = "" />
        <input type="hidden" name="connectedrels" id="hconnectedrels" value = "" />
        <input type="hidden" name="PFLIds" id="hPFLIds" value = "" />
        <input type="hidden" name="PFLUsage" id="hPFLUsage" value = "" />
        </form>
        </body>

<SCRIPT language="javascript" type="text/javaScript" ><!--
  var jsTreeId = '<%=XSSUtil.encodeForJavaScript(context,jsTreeId)%>';
  var relId = '<%=XSSUtil.encodeForJavaScript(context,relId)%>';
  var objId = '<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>';
  var variantName = "<%=XSSUtil.encodeForJavaScript(context,strVariantName)%>";
  var productVariantId= '<%=XSSUtil.encodeForJavaScript(context,strProductVariantId)%>';
  var strContext = '<%=XSSUtil.encodeForJavaScript(context,strContext)%>';
  var strSelectedFeatures = '<%=XSSUtil.encodeForJavaScript(context,strSelectedFeatures)%>';
  
  function setDIVProperty(){
      if(isIE){
          //var divElem = document.getElementById("mx_divConfiguratorBody");
          //divElem.style.position = "relative";
          //divElem.style.width = "97.7%";
      }
  }
  
  function movePrevious() 
  {
     var formName = document.featureOptions;
     var strContext = '<%=XSSUtil.encodeForJavaScript(context,strContext)%>';
     //For Persisting the selected Features.
     var selectedFeatures;
     var timeStamp = '<%=XSSUtil.encodeForJavaScript(context,strTimeStamp)%>';
     formName.target = "_top";
     
     var selectedArray = document.getElementsByTagName("input");     
     var selectedData = ""; 
     var i=0;
     for(i=0; i< selectedArray.length; i++){
         var elem = selectedArray[i];
         if((elem.type == "checkbox" || elem.type == "radio") && elem.checked){             
             selectedData = selectedData + "," +elem.id;
         }
     }
     selectedData = selectedData.substring(1);
          
    if ((strContext=="create" ||strContext=="viewCreate") && selectedFeatures != null)
    {
        formName.action="../components/emxCommonFS.jsp?mode=create&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&functionality=ProductVariantCreateFSInstance&PRCFSParam1=ProductVariant&jsTreeID="+jsTreeId+"&relId="+relId+"&objectId="+objId+"&FTRParam=getFromSession&selectedFeatures="+selectedFeatures+"&timeStamp="+timeStamp+"&selectedData="+selectedData;
    }
    else if(strContext=="clone")
    {
        formName.action="../components/emxCommonFS.jsp?mode=clone&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&functionality=ProductVariantCloneFSInstance&PRCFSParam1=ProductVariant&jsTreeID="+jsTreeId+"&relId="+relId+"&objectId="+objId+"&FTRParam=getFromSession&productVariantId="+productVariantId+"&timeStamp="+timeStamp+"&selectedData="+selectedData;
    }
    else if(strContext=="viewClone")
    {
        formName.action="../components/emxCommonFS.jsp?mode=viewClone&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&functionality=ProductVariantCloneFSInstance&PRCFSParam1=ProductVariant&jsTreeID="+jsTreeId+"&relId="+relId+"&objectId="+objId+"&FTRParam=getFromSession&timeStamp="+timeStamp+"&selectedData="+selectedData;
    }
    else
    {
        formName.action="../components/emxCommonFS.jsp?mode=create&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&functionality=ProductVariantCreateFSInstance&PRCFSParam1=ProductVariant&jsTreeID="+jsTreeId+"&relId="+relId+"&objectId="+objId+"&FTRParam=getFromSession&timeStamp="+timeStamp+"&selectedData="+selectedData;
    }
     formName.submit();
  }

  function closeWindow()
  {
       var formName = document.featureOptions;
       formName.action="../configuration/ProductVariantUtil.jsp?mode=cleanupsession";
       formName.submit();
       parent.window.closeWindow();
  }

function submit()
{
    var formName = document.featureOptions;
    var selectedFeatures="";
    var isSelectedFromClone = "";     
    var featureUnSelected="";
    
    var msg;
    var submitURL;
    var strMode = '<%=XSSUtil.encodeForJavaScript(context,strMode)%>';
    var disableFeature;
    var featureSelected="";
    var timeStamp = '<%=XSSUtil.encodeForJavaScript(context,strTimeStamp)%>';
    var varContext = "<%=XSSUtil.encodeForJavaScript(context,strContext)%>";
    var productVariantId = "<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>";
    var arrid = new Array();
    var dynamicEvaluation = false;
    var arrInput = formName.getElementsByTagName("input");
    var connectedids = new Array();
    var PFLIds = new Array();
    var count1 = 0;
    var count2 = 0;
    var inputtagslength = arrInput.length;//3 is substracted because three input tags are added as type=hidden to pass the array

    var toplevelSelectedCount = 0;
    for(var n=0;n<inputtagslength;n++){
        var inputType = arrInput[n];
        if(inputType.getAttribute("type") == "checkbox" 
            && inputType.getAttribute("level") == "1" 
                && inputType.checked ){
            toplevelSelectedCount++;
        }
    } 
    if(toplevelSelectedCount<1){
        var AlertMsg = "<%=i18nNow.getI18nString("emxProduct.Alert.PleaseSelectAtleastOneTopLevelLogicalFeature",bundle,acceptLanguage)%>";
        alert(AlertMsg); 
        return;
    }
        
    var arrPFLUsage = new Array();
          
         for(var n=0;n<inputtagslength;n++)
         {             
             var objInp = arrInput[n];
             var selected = objInp.getAttribute("selected");
             var parentID = objInp.getAttribute("parentid");  
            if(objInp.checked || (selected != null && selected == "DBChooser"))
             {
                           
                var ifAllSelected = checkParentSelected(parentID);
                 if(!ifAllSelected){        
            
                 arrid[count1] = objInp.setAttribute("relid","");  
                 
                 arrPFLUsage[count1]= objInp.setAttribute("relid","") +"^"+objInp.parentNode.getAttribute("usage");             
                 count1++;                      
            }else{ 
                        
                arrid[count1] = objInp.getAttribute("relid");    
                arrPFLUsage[count1]= objInp.getAttribute("relid") +"^"+objInp.parentNode.getAttribute("usage");             
                count1++;
               }
                
             }
         }         
         if(arrid.length == 0){
             var AlertMsg = "<%=i18nNow.getI18nString("emxProduct.Alert.PleaseSelectAtleastOneLogicalFeature",bundle,acceptLanguage)%>";
             alert(AlertMsg); 
             return;
         }
         

         document.getElementById('hlogicalfeaturerels').value =arrid ;
         

         for(var n=0;n<inputtagslength;n++)
         {
             var newObj = arrInput[n];
             var prevfeature = newObj.getAttribute("Flag");
             var selected = newObj.getAttribute("selected");
             if(prevfeature=="true")
             {                 
                 connectedids[count2] = newObj.getAttribute("relid");
                 PFLIds[count2] = newObj.getAttribute("pflid");
                 count2++;
             }
         }
         
         document.getElementById('hconnectedrels').value = document.getElementById('hconnectedrels').value+","+connectedids ;
         document.getElementById('hPFLIds').value =document.getElementById('hPFLIds').value+","+PFLIds ;
         document.getElementById('hPFLUsage').value =arrPFLUsage ;
         
     if(strMode=="editOptions" || strMode=="viewEdit")
         {
                submitURL = "../configuration/ProductVariantUtil.jsp?mode=editVariant&variantName="+variantName+"&objectId="+productVariantId+"&context=<%=XSSUtil.encodeForURL(context,strContext)%>";
             }
      else{
                submitURL = "../configuration/ProductVariantUtil.jsp?mode=createVariant&variantName="+variantName+"&objectId="+objId+"&jsTreeID="+jsTreeId+"&relId="+relId+"&context=<%=XSSUtil.encodeForURL(context,strContext)%>&timeStamp="+timeStamp;
             }
      formName.action = submitURL;
      formName.submit();       
  }
  

function showSubfeaturesChooser(parentFeatureId, parentFeatureListId, parentPFLid, featureRowDispayLevel, selection) 
{
    selection = selection.toLowerCase();
     showChooser('../common/emxFullSearch.jsp?field=TYPES=type_LogicalFeature,type_Products:LOGICAL_FEATURE_ID='+parentFeatureId+'&table=FTRLogicalFeatureSearchResultsTable&showInitialResults=false&selection='+selection+'&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&mode=EffectivityChooser&formName=featureOptions&frameName=pagecontent&suiteKey=Configuration&formInclusionList=DISPLAY_NAME,PARTFAMILY&submitURL=../configuration/ProductFeatureDBChooser.jsp?parentFeatureId='+parentFeatureId+'&parentFeatureListId='+parentFeatureListId+'&parentPFLid=' + parentPFLid + '&featureRowDispayLevel='+featureRowDispayLevel+'&contextBusId=<%=XSSUtil.encodeForURL(context,strproductId)%>&selection='+selection, 850, 630);
}
   
</SCRIPT>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
</html>

