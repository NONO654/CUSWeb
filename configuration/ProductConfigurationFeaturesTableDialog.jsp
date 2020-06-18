<%-- ProductConfigurationFeaturesTableDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/ProductConfigurationFeaturesTableDialog.jsp 1.16.2.3.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";
 
--%>
<%-- Common Includes --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%
String strErrHeader = i18nNow.getI18nString("emxConfiguration.Alert.ConflictCompatibility","emxConfigurationStringResource",context.getSession().getLanguage());
%>
<SCRIPT>
var strConflictAlertHeader = "<%=XSSUtil.encodeForJavaScript(context,strErrHeader)%>";
</SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIJson.js"></SCRIPT>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%-- Imports --%>
<%@ page import="com.matrixone.apps.configuration.ProductConfiguration" %>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>


<%
	  String strPurpose = emxGetParameter(request, "radProductConfigurationPurposeValue");
      String strFromContext = emxGetParameter(request,"fromcontext");
      String relId = emxGetParameter(request, "relId");
      String jsTreeId = emxGetParameter(request, "jsTreeID");
    
      String topLevelPart = emxGetParameter(request, "topLevelPart");
      String topLevelPartDisplay = emxGetParameter(request, "topLevelPartDisplay");
      String productConfigurationId = emxGetParameter(request, "productConfigurationId");
      String productConfigurationMode = emxGetParameter(request,"productConfigurationMode");
      
      String startEffValue = emxGetParameter(request,"startEffValue");
      String endEffValue = emxGetParameter(request,"endEffValue");
      String mode = emxGetParameter(request,"mode");
      String functionality = emxGetParameter(request,"functionality");
      if(functionality == null)
    	  functionality = "edit";
      ProductConfiguration pconf = null;
      if(mode != null && mode.equalsIgnoreCase("editOptions"))
      {
          session.removeAttribute("productConfiguration");
      }
      pconf = (ProductConfiguration)session.getAttribute("productconfiguration");          
      /*if(pconf!=null)
      {
		  boolean bValidConfiguration = pconf.isValidConfiguration();   
      }*/
      
   %>
<SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxJSValidationUtil.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICalendar.js"></SCRIPT>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><html>
<head>
<link rel="stylesheet" type="text/css" media="screen" href="./styles/emxUIProductConfiguration.css" />
<link rel="stylesheet" type="text/css" media="screen" href="./styles/emxUILayerDialog.css" />
<link rel="stylesheet" type="text/css" media="screen" href="../common/styles/emxUIMenu.css" />
</head>

<%
if(mode != null && mode.equalsIgnoreCase("editOptions"))
      {
          %>
          <body onload="putMaskOnLoad();calculateTotalPrice();">
          <%
      }
else
{
%>


<body onload="calculateTotalPrice();">
<%} %>
  
  <div id="mx_divBody">
<%
String lstTrueMPRId = "";
String strExcludeListMPR = "";
	if(pconf!= null)
	{
//   String component = "<table id='featureOptionsTable' cellspacing='0' cellpadding='0' border='0'><tbody id='featureOptionsBody'><tr class='' id='MprRow1' istoplevel='true'><td class='mx_status'><div/></td><td><table class='mx_feature-option' cellspacing='0' cellpadding='0' border='0'><tbody><tr><td class='mx-spacer-cell level-0'><img src='../common/images/utilSpacer.gif'/></td><td class='' mx_icon=''><img src='../common/images/iconSmallConfigurableFeature.gif'/></td><td class='mx_feature-option'>ConEngine</td></tr></tbody></table></td><td class='mx_info'><a class='mx_button-info' href='javascript:fnloadHelp('55344.35180.39328.19607')'><img border='0' src='../common/images/utilSpacer.gif'/></a></td><td class='mx_quantity'></td><td class='mx_each-price'></td><td class='mx_extended-price'></td></tr></table>";//<tr class='" id='MprRow1.1'><td class='mx_status'><div/></td><td><table class='mx_feature-option' cellspacing='0' cellpadding='0'><tbody><tr><td class='mx-spacer-cell level-2'><img src='../common/images/utilSpacer.gif'/></td><td class='mx_input-cell'><div/></td><td class='mx_option'>ConPetrol</td></tr></tbody></table></td><td class='mx_info'><a class='mx_button-info' href='javascript:fnloadHelp('55344.35180.33473.339')'><img border='0' src='../common/images/utilSpacer.gif'/></a></td><td class='mx_quantity'><a id='1OrderedQuantity'>0.0</a></td><td class='mx_each-price'><input id='lEachPrice' type='text' readonly='' value='0.0' name='EachPrice'/></td><td class='mx_extended-price'><input id='lExtPrice' type='text' readonly='' value='0.0' name='ExtPrice'/></td></tr><tr class='' id='MprRow1.2'><td class='mx_status'><div/></td><td><table class='mx_feature-option' cellspacing='0' cellpadding='0'><tbody><tr><td class='mx-spacer-cell level-2'><img src='../common/images/utilSpacer.gif'/></td><td class='mx_input-cell'><div/></td><td class='mx_option'>ConDiesel</td></tr></tbody></table></td><td class='mx_info'><a class='mx_button-info' href='javascript:fnloadHelp('55344.35180.46560.50058')'><img border='0' src='../common/images/utilSpacer.gif'/></a></td><td class='mx_quantity'><a id='1OrderedQuantity'>0.0</a></td><td class='mx_each-price'><input id='lEachPrice' type='text' readonly='' value='0.0' name='EachPrice'/></td><td class='mx_extended-price'><input id='lExtPrice' type='text' readonly='' value='0.0' name='ExtPrice'/></td></tr></tbody></table>;//pconf.getXML(); //pconf.getFeatureOptionsHTMLDisplay(context);
	ServletContext svltContext = getServletConfig().getServletContext();
	java.io.InputStream inputStream=null;
	try{
		 inputStream = svltContext.getResourceAsStream("/configuration/ProductConfigurationDisplay.xsl");
	}catch (Exception e){
		throw new FrameworkException(e.getMessage());
	}
	      String component = pconf.getHTMLForOptionsDisplay(context,inputStream,functionality);
          out.print(component);%>
          <script language="javascript" type="text/javaScript">
          var pageHeader = getTopWindow().document.getElementById('pageheader');
          var progressDiv = "";
          if(pageHeader)
          {
        	  if(isIE)
        	  {
            	if(pageHeader.document){  
       		       progressDiv = pageHeader.document.getElementById("imgProgressDiv");
            	}
       		    if(progressDiv == null || progressDiv ==""){
           		    if(pageHeader.contentWindow.document){
       		          progressDiv = pageHeader.contentWindow.document.getElementById("imgProgressDiv");
					}
			    }
        	  }else{
        		 progressDiv = pageHeader.contentDocument.getElementById("imgProgressDiv");
                 if(progressDiv == null || progressDiv ==""){
        		  progressDiv = pageHeader.contentWindow.document.getElementById("imgProgressDiv");
                 }
        	  }
              //if progress div exist
              if(progressDiv){
            	   progressDiv.style.visibility='hidden';
              }
          }
          </script>
          <%
        //lstTrueMPRId = pconf.getTrueMPRList();
        //strExcludeListMPR = pconf.getExcludeList();
	}
        
          
%>
</div>


   <input type="hidden" name="PRCFSParam2" value="<xss:encodeForHTMLAttribute><%=(emxGetParameter(request, "PRCFSParam2"))%></xss:encodeForHTMLAttribute>"/>
   <%if(pconf != null)
  {%>
   <input type="hidden" id="ruleEvalMembrsElmntId" value="<%=0/*(pconf.getRuleEvaluationMembersList())*/%>"/>
   <%}
   else
   {%>
      <input type="hidden" id="ruleEvalMembrsElmntId" value=""/>
      <%} %>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" type="text/javaScript">      
     function movePrevious() 
      {
        document.featureOptions.target="_top";
        document.featureOptions.method ="post";
        document.featureOptions.action="../components/emxCommonFS.jsp?StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=product&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeId)%>&functionality=ProductConfigurationCreateFlatViewFSInstance&relId=&suiteKey=Configuration&PRCFSParam1=ProductConfiguration&PRCFSParam3=getfromsession&relId=<%=XSSUtil.encodeForURL(context,relId)%>&fromcontext=<%=XSSUtil.encodeForURL(context,strFromContext)%>&radProductConfigurationPurposeValue=<%=XSSUtil.encodeForURL(context,strPurpose)%>&topLevelPart=<%=XSSUtil.encodeForURL(context,topLevelPart)%>&topLevelPartDisplay=<%=XSSUtil.encodeForURL(context,topLevelPartDisplay)%>&startEffValue=<%=XSSUtil.encodeForURL(context,startEffValue)%>&endEffValue=<%=XSSUtil.encodeForURL(context,endEffValue)%>";
        document.featureOptions.submit();
      }
	function fnloadHelp(strFeatureIdentifier) {
	  if(strFeatureIdentifier != null)
      showModalDialog('../components/emxCommonFS.jsp?functionality=ContextualHelpFSInstance&suiteKey=Configuration&PRCFSParam1='+strFeatureIdentifier,400,400,false);
      }


	
       function showValidationAlertMessage() {
         if(ValidationAlertMsg!=null && ValidationAlertMsg!="null" && ValidationAlertMsg!="") {
            alert(ValidationAlertMsg);
            return false;
         } else {
            return true;
         }
      }
      
//Modified for  IR: Mx376489    
var ARR_NAME_BAD_CHARS = new Array('#', '+', '|');
function checkForBadChars(strVal, ignoreWhiteSpace)  // for input and textArea type of keyin features
{
	var containsBadChar = true;
	containsBadChar = isAlphanumeric(strVal, ignoreWhiteSpace);
    if(!containsBadChar)
    {
    
		alert("<%=i18nNow.getI18nString("emxProduct.Error.NoSpecialCharacter",bundle,acceptLanguage)%>");
		return "";
	}else
		return strVal;
}
var callbackForDateKeyIn = function()
{
	var field = this.field;
	var value = field.value;
	if(field.length > 0)
	{
		field=field[field.length - 1];
	}
	var id = field.id;
	updateKeyInValue(value,id);
}
function updateKeyInValue(strVal, id, divId)
{
   //var url="ProductConfigurationResponse.jsp?mode=updateKeyInValue&value=" +encodeURIComponent(strVal)+ "&featureId=" +id+"&time="+ new Date().getTime()//to prevent browser caching;
   // var html = emxUICore.getDataPost(url);
    var url="ProductConfigurationResponse.jsp";
    var queryString ="mode=updateKeyInValue&value=" +encodeURIComponent(strVal)+ "&featureId=" +id+"&time="+ new Date().getTime();
    var html = emxUICore.getDataPost(url,queryString);
    var bodyDiv = document.getElementById("mx_divBody");
    if(bodyDiv)
        bodyDiv.innerHTML = html;
    if(strVal.replace(/\s/g,"") != "")
    {
        var selectedDiv = document.getElementById(divId);
        if(selectedDiv!=null)
        {
            var innerhtmlid = selectedDiv.getAttribute("innerHTMLId");
            var selectedElement = document.getElementById(innerhtmlid);
            if(selectedElement != null)
                selectedElement.checked = true;
        validate(divId, null, null ,null, null);
        } 
    }
}
      

function readFromStringResource(stringToBei18ned)
{
	if(stringToBei18ned == "CANT_BE_AUTOSELECTED"){
		return "<%=i18nNow.getI18nString("emxProduct.Error.ProductConfigurationProhibitAutoSelection",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "ALREADY_AUTOSELECTED"){
		return "<%=i18nNow.getI18nString("emxProduct.Error.ProductConfigurationPreSelection",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "ALREADY_SELECTED"){
		return "<%=i18nNow.getI18nString("emxProduct.Error.ProductConfigurationPreSelectionByUser",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "CANT_BE_EXCLUDED"){
		return "<%=i18nNow.getI18nString("emxProduct.Error.ProductConfigurationUserSelectionPreference",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "GOT_AUTOSELECTED_TO"){
		return "<%=i18nNow.getI18nString("emxProduct.Message.GotAutoselectedTo",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "GOT_DESELECTED_BASED_ON_SELECTION"){
		return "<%=i18nNow.getI18nString("emxProduct.Message.GotDeselected",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "BASED_ON_SELECTION"){
		return "<%=i18nNow.getI18nString("emxProduct.Message.BasedOnTheSelectionOf",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "INHERITED_RULE_MESSAGE"){
		return "<%=i18nNow.getI18nString("emxProduct.Message.InheritedRule",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "GOT_DESELECTED"){
		return "<%=i18nNow.getI18nString("emxProduct.Message.GotDeselected",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "CONFLICTING_RULES_RESULT"){
		return "<%=i18nNow.getI18nString("emxProduct.Error.ConflictingMPRRules",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "CANT_REMOVE_AS_ALREADY_SELECTED"){
		return "<%=i18nNow.getI18nString("emxProduct.Error.CannotRemobeAsSelected",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "STR_PCVALIDATION_HEADERMSG1"){
		return "<%=i18nNow.getI18nString("emxProduct.Message.PCValidationHeaderMessage1",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "STR_PCFTR_SELECTIONMSG1"){
		return "<%=i18nNow.getI18nString("emxProduct.Message.PCSelectionMessage",bundle,acceptLanguage)%>";
	}else if(stringToBei18ned == "STR_PCFTRSELECTIONVALIDATION_WAIT"){
		return "<%=i18nNow.getI18nString("emxProduct.Message.PCFtrSelectionValidationWait",bundle,acceptLanguage)%>";
	}
	else if(stringToBei18ned == "STR_PCEDITHEADERMSG1")
	{
		return "<%=i18nNow.getI18nString("emxProduct.Message.PCEditHeaderMessage1",bundle,acceptLanguage)%>";
	}
	else if(stringToBei18ned == "STR_PCEDITBODYMSG1")
	{
		return "<%=i18nNow.getI18nString("emxProduct.Message.PCEditMessage",bundle,acceptLanguage)%>";
	}
	else{
		return stringToBei18ned;
	}
}

      
function giveAlert(alertFlag, ftrName)
{
	if(alertFlag == "MAX_QTY_MSG")
	{
		alert("<%=i18nNow.getI18nString("emxProduct.Alert.MaximumQuantityValidation",bundle,acceptLanguage)%>");
	}else if(alertFlag == "MIN_QTY_MSG"){
		alert("<%=i18nNow.getI18nString("emxProduct.Alert.MinimumQuantityValidation", bundle,acceptLanguage)%>");
	}else if(alertFlag == "PC_INVALID_MSG"){
		alert("<%=i18nNow.getI18nString("emxProduct.Alert.PCInvalid", bundle,acceptLanguage)%>");
	}else if(alertFlag == "PC_VALID_MSG"){
		alert("<%=i18nNow.getI18nString("emxProduct.Alert.PCValid", bundle,acceptLanguage)%>");
	}else if(alertFlag == "FIRST_VALIDATE_MSG"){
		alert("<%=i18nNow.getI18nString("emxProduct.Alert.FirstValidate", bundle,acceptLanguage)%>");
	}else if(alertFlag == "ENT_INT_MSG"){
		alert("<%=i18nNow.getI18nString("emxProduct.Alert.EnterInteger", bundle,acceptLanguage)%>");
	}else if(alertFlag == "ENT_DEC_MSG"){
		alert("<%=i18nNow.getI18nString("emxProduct.Alert.EnterDecimal", bundle,acceptLanguage)%>");
	}else if(alertFlag == "SelectAtLeastOneFTR" && ftrName != null){
		alert("<%=i18nNow.getI18nString("emxProduct.Error.SelectAtleastOne", bundle,acceptLanguage)%> "+ftrName);
		//Added for  IR: Mx376489      
	}else if(alertFlag == "ENT_INVALIDCHAR_MSG"){
        alert("<%=i18nNow.getI18nString("emxProduct.Alert.InValidCharacter", bundle,acceptLanguage)%>");
	}else if(alertFlag == "ENT_VALUE_MSG"){
        alert("<%=i18nNow.getI18nString("emxProduct.Alert.EnterValue", bundle,acceptLanguage)%>");
    }
	
}
            
            
      function calculateTotalPrice()
      {
      	var form = document.forms["featureOptions"];
      	var basePriceElement;
      	var totalPriceElement;
      	var basePrice;
      	var TotalPrice;
      	var extPriceId;
      	var relatedFtrElementId;
      	var relatedFtrElement;
      	var selectElementText;
      	var isChecked;
      	var elementType;
      	var featurerowlevel;
      	var relatedRowId;
      	var relatedRow;
      	if(form)
      	{
      		basePriceElement = form.elements["BasePrice"];
      		totalPriceElement = form.elements["TotalPrice"];
      		if(basePriceElement)
      		{
      			basePrice = basePriceElement.value;
      			totalPrice = totalPriceElement.value;
      		}
      		numTP = parseFloat(basePrice);
		var extPriceElements = document.getElementsByName("ExtPrice");
	 	for(var i=0; i<extPriceElements.length; i++)
	      	{
	 		var extPriceElement = extPriceElements[i];
	      		if(extPriceElement)
	      		{
	      			relatedFtrElementId = extPriceElement.getAttribute("relatedftrelementid");
	      			relatedFtrElement = document.getElementById(relatedFtrElementId);
	      			if(relatedFtrElement)
	      			{
		      			elementType = relatedFtrElement.type;
		      			if(elementType == "radio" || elementType == "checkbox")
		      			{
							featurerowlevel = relatedFtrElement.getAttribute("featurerowlevel");
			      			relatedRowId = "MprRow"+featurerowlevel;
			      			relatedRow = document.getElementById(relatedRowId);
			      			if(relatedRow.style.visibility != "hidden")
			      			{
			      				numExtP = parseFloat(extPriceElement.value);
		      					numTP = numTP + numExtP;
			      			}			      			
		      			}else{
	      			numExtP = parseFloat(extPriceElement.value);
	      			numTP = numTP + numExtP;
	    			}
	      			}else{
	      				numExtP = parseFloat(extPriceElement.value);
		      			numTP = numTP + numExtP;
	      			}
	      		}
	      	}
      	   //Modified for IR:Mx376519  
	 	   totalPriceElement.value = numTP.toFixed(2);
      	}
}
      	
<%if(pconf != null)
{%>
      lstTrueMPRId = "<%=XSSUtil.encodeForJavaScript(context,lstTrueMPRId)%>";
      strExcludeListMPR = "<%=XSSUtil.encodeForJavaScript(context,strExcludeListMPR)%>";
<%
}
%>
   function showSubfeaturesChooser(parentFeatureId, parentFeatureListId, featureRowDispayLevel, selection,contextObjId,startEffectivity) 
   {
          var SearchSelectionType = "multiple";
          if(selection == "Single")
              SearchSelectionType = 'single';
          var mprId;
          var mpr;
          var index;
          var lstMPRIDs="";
          var obj = document.getElementById("lstTrueMPRId");
          var str = obj.getAttribute("lstTrueMPRId");

          if(str != null && str != "undefined" && str != "")
          {
             var strArr = str.split("|");
             for(var iStrArr = 0; iStrArr < strArr.length; iStrArr++)
      {
                mpr = strArr[iStrArr].split("_");
                mprId = mpr[0];
                if(mpr[0]=="")
                {
                    break;
                }
                index = mpr[1].search(parentFeatureId);
                if(index > -1)
      {
                    lstMPRIDs = lstMPRIDs+mprId;
                    lstMPRIDs = lstMPRIDs+",";
                }
             }
             if(lstMPRIDs.lastIndexOf(",")==(lstMPRIDs.length-1))
          {
                lstMPRIDs = lstMPRIDs.slice(0,lstMPRIDs.length-1);
             }
        }
        
      if(parentFeatureId != null)
          {
    	   showChooser('../common/emxFullSearch.jsp?field=TYPES=type_CONFIGURATIONFEATURES,type_Products:CONFIG_FEATURE_ID='+parentFeatureId+'&parentId='+contextObjId+'&startEffectivity='+encodeURIComponent(startEffectivity)+'&includeOIDprogram=emxProductConfiguration:getDBChooserFeatureOptions&MPRIds='+lstMPRIDs+'&table=FTRConfigurationFeaturesSearchResultsTable&selection='+SearchSelectionType+'&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&mode=ProductConfigurationChooser&showInitialResults=false&formName=featureOptions&frameName=pagecontent&suiteKey=Configuration&formInclusionList=DISPLAY_NAME&submitURL=../configuration/ProductConfigurationDBChooser.jsp?parentFeatureId='+parentFeatureId+'&parentFeatureListId='+parentFeatureListId+'&featureRowDispayLevel='+featureRowDispayLevel+'&contextBusId=' + parentFeatureId, 850, 630);
         /* if(lstMPRIDs.length > 0)
         {
             showChooser('../common/emxFullSearch.jsp?field=TYPES=type_CONFIGURATIONFEATURES,type_Products:CONFIG_FEATURE_ID='+parentFeatureId+'&parentId='+contextObjId+'&startEffectivity='+encodeURIComponent(startEffectivity)+'&includeOIDprogram=emxProductConfiguration:getDBChooserFeatureOptions&MPRIds='+lstMPRIDs+'&table=FTRConfigurationFeaturesSearchResultsTable&selection='+SearchSelectionType+'&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&mode=ProductConfigurationChooser&showInitialResults=false&formName=featureOptions&frameName=pagecontent&suiteKey=Configuration&formInclusionList=DISPLAY_NAME&submitURL=../configuration/ProductConfigurationDBChooser.jsp?parentFeatureId='+parentFeatureId+'&parentFeatureListId='+parentFeatureListId+'&featureRowDispayLevel='+featureRowDispayLevel+'&contextBusId=' + parentFeatureId, 850, 630);
         }else
         {
        	  showChooser('../common/emxFullSearch.jsp?field=TYPES=type_CONFIGURATIONFEATURES,type_Products:CONFIG_FEATURE_ID='+parentFeatureId+'&parentId='+contextObjId+'&startEffectivity='+encodeURIComponent(startEffectivity)+'&includeOIDprogram=emxProductConfiguration:getDBChooserFeatureOptions&table=FTRConfigurationFeaturesSearchResultsTable&selection='+SearchSelectionType+'&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&mode=ProductConfigurationChooser&formName=featureOptions&showInitialResults=false&frameName=pagecontent&suiteKey=Configuration&formInclusionList=DISPLAY_NAME&submitURL=../configuration/ProductConfigurationDBChooser.jsp?parentFeatureId='+parentFeatureId+'&parentFeatureListId='+parentFeatureListId+'&featureRowDispayLevel='+featureRowDispayLevel+'&contextBusId=' + parentFeatureId, 850, 630);
         }*/
   }
 }
   


  
         
function putMaskOnLoad()
{
  	addMask("STR_PCEDITHEADERMSG1","STR_PCEDITBODYMSG1","STR_PCFTRSELECTIONVALIDATION_WAIT");
  	eval("setTimeout(\"loadProductConfiguration('<%=XSSUtil.encodeForJavaScript(context,productConfigurationId)%>','<%=XSSUtil.encodeForJavaScript(context,productConfigurationMode)%>')\", 5);");
}
      </script>
   
</body>
</html>
   
   
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
