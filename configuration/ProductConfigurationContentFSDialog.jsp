<%--  ProductConfigurationContentFSDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/ProductConfigurationContentFSDialog.jsp 1.15.2.4.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";

--%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "com.matrixone.apps.configuration.*"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIJson.js"></script>
<!-- SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT-->
<!-- SCRIPT language="javascript" src="./ProductConfigurationFeaturesTableDialog.jsp"></SCRIPT -->

<SCRIPT language="javascript" type="text/javaScript">

var validConfiguration;
var productConfigurationMode;

<% // if there are any validation errors, the parameter "valid" will be false;
  String strPurpose  = emxGetParameter(request, "radProductConfigurationPurposeValue");
  String topLevelPart = emxGetParameter(request, "topLevelPart");
  String topLevelPartDisplay = emxGetParameter(request, "topLevelPartDisplay");
  String productConfigurationId = emxGetParameter(request,"productConfigurationId");
  String productConfigurationMode = emxGetParameter(request,"productConfigurationMode");
  String startEffValue = emxGetParameter(request,"startEffValue");
  String endEffValue = emxGetParameter(request,"endEffValue");
  String applyURL = emxGetParameter(request,"applyURL");
  ProductConfiguration pConf = (ProductConfiguration)session.getAttribute("productconfiguration");
  String solverType = ConfigurationConstants.EMPTY_STRING;
  if(pConf!=null)
	  solverType = pConf.getSolverType();
  
  String strFormHeader = i18nNow.getI18nString("emxProduct.Heading.PCProperties",bundle,acceptLanguage);
  
  if((emxGetParameter(request, "valid") != null) && (emxGetParameter(request, "valid").equalsIgnoreCase("true"))){
%>
    validConfiguration = true;
<%} else  {%>
    validConfiguration = false;

<% }%>
    var actionParam = "<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "PRCFSParam2"))%>";
    var submitCount = 0;

  function moveNext() {
    self.frames[2].moveNext();
  }

  function movePrevious() {
    self.frames[2].movePrevious();
  }

  function actionValidateConfiguration() {
	  
     self.frames[2].fnValidateConfiguration("<%=XSSUtil.encodeForJavaScript(context,solverType)%>");
     // fnValidateConfiguration();
  }

  function actionSlideShow() {
      self.frames[0].showSlideshow();
  }

  function closeWindow() {
	self.frames[0].document.forms[0].action="../configuration/ProductConfigurationResponse.jsp?mode=cleanupsession";
        self.frames[0].document.forms[0].submit();
        parent.window.closeWindow();
  }

  productConfigurationMode = "<%=XSSUtil.encodeForJavaScript(context,PersonUtil.getProductConfigurationModePreference(context))%>";
  if(productConfigurationMode == "" || productConfigurationMode == null)
  	productConfigurationMode = "InteractiveMode";
  
  function giveAlert(alertFlag, ftrName)
{
	if(alertFlag == "SelectAtLeastOneFTR" && ftrName != null){
		alert("<%=i18nNow.getI18nString("emxProduct.Error.SelectAtleastOne", bundle,acceptLanguage)%> "+ftrName);
	}
}
  function submit() {
	  
	  var isEmptyKeyInValue = "false";
      var formObject = self.frames[2].document.featureOptions;
      var pcValidationStatus = true;
      //if((productConfigurationMode == "NonInteractiveMode") || (productConfigurationMode == "InteractiveMode"))
      //{
    	    // pcValidationStatus = self.frames[2].checkPCValidationStatus();
      //}
      if(pcValidationStatus)
      {
	     
		var dynamicEvaluation = false;
	 	bIsDynamic = false;
		var url="<%=XSSUtil.encodeForJavaScript(context,applyURL)%>";	
		var jsonString = null;
		jsonString = emxUICore.getDataPost(url);
		var jsonObject = jsonString.parseJSON();
		var Msg = jsonObject.message;
		var pcId = jsonObject.objectId;
		//var validationMsg = null;
		//var node = xmlDoc.getElementsByTagName("EcValidationMsg")[0];
		//validationMsg = node.getAttribute("validationMsg");
				if(Msg != null && Msg != "" && Msg != "null" && Msg.indexOf("null") == -1)
				{
				//	var arr = new Array();
				//	arr = validationMsg.split("-con6ftr-");
				//	var stringToBei18ned = arr[0];
				//	var ftrName = arr[1];
				//	giveAlert(stringToBei18ned, ftrName);
				alert(Msg);
				}
				var code = jsonObject.code;		
				var isFromRMB=jsonObject.isFromRMB;				
				if(code == "CREATE_SUCCESSFUL" && isFromRMB == "true" )
				{
					self.frames[0].document.forms[0].action="../configuration/ProductConfigurationResponse.jsp?mode=cleanupsession";
			        self.frames[0].document.forms[0].submit();
			        window.getTopWindow().closeWindow();
				}
				else if(code == "CREATE_SUCCESSFUL" ){
					self.frames[0].document.forms[0].action="../configuration/ProductConfigurationResponse.jsp?mode=cleanupsession";
			        self.frames[0].document.forms[0].submit();
			       
			        showModalDialog("../common/emxTree.jsp?form=type_ProductConfiguration&categoryTreeName=type_ProductConfiguration&AppendParameters=true&toolbar=FTRProductConfigurationPropertiesPageToolBar&formHeader="+"<%=XSSUtil.encodeForURL(context,strFormHeader)%>"+"&HelpMarker=emxhelpproductconfigurationdetails&objectId="+pcId,940,680,true,'MediumTall');
					//refresh summary page
			        window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;

			         window.getTopWindow().closeWindow(); // Code added for fixing IR-242839V6R2014x
			        }
		
				else if(code == "EDIT_SUCCESSFUL")
		{
			//var formViewFrame =  findFrame(getTopWindow().getWindowOpener().parent.window,"formViewDisplay");
			var formViewFrame =  findFrame(getTopWindow().getWindowOpener().parent.window,"detailsDisplay");
			if(formViewFrame != null && formViewFrame != "null")
			{    
				formViewFrame.location.href = formViewFrame.location.href;
			}    
			refreshTablePage();
			closeWindow();
		}

 	 }
  }


</SCRIPT>

<%
  //Retrieves Objectid in context
  String strProductId = emxGetParameter(request, "hidProductId");
  String strFromContext = emxGetParameter(request, "fromcontext");
  /*
   * The frameset mode determines if the review page or the
   * feature-select page is to be shown.
   */
  String strfunctionality = emxGetParameter(request,"functionality");
  String jsTreeId = emxGetParameter(request, "jsTreeID");
  String relId = emxGetParameter(request, "relId");

  ProductConfiguration prdConf = (ProductConfiguration)session.getAttribute("productconfiguration");

%>

  <FRAMESET COLS="200,*" frameborder="YES" border="1" framespacing="1">
        <FRAME NAME="Description" SRC="ProductConfigurationConfiguratorHeader.jsp?&productConfigurationId=<%=XSSUtil.encodeForJavaScript(context,productConfigurationId)%>&productId=<%=XSSUtil.encodeForJavaScript(context,strProductId)%>&functionality=<%=XSSUtil.encodeForJavaScript(context,strfunctionality)%>" TITLE="Description" marginwidth="2" marginheight="2" frameborder="YES" scrolling="yes"/>
         <FRAMESET ROWS="1,*" frameborder="NO" border="0" framespacing="0">
         <FRAME NAME="hidden" SRC="" frameborder="no" scrolling="no"/>//temporarily kept to be removed
         <FRAME NAME="Options" SRC="ProductConfigurationFeaturesTableDialog.jsp?functionality=<%=XSSUtil.encodeForJavaScript(context,strfunctionality)%>&mode=<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "mode"))%>&PRCFSParam2=<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "PRCFSParam2"))%>&jsTreeID=<%=XSSUtil.encodeForJavaScript(context,jsTreeId)%>&productConfigurationId=<%=XSSUtil.encodeForJavaScript(context,productConfigurationId)%>&productConfigurationMode=<%=XSSUtil.encodeForJavaScript(context,productConfigurationMode)%>&PRCFSParam1=<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "PRCFSParam1"))%>&PRCFSParam3=<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "PRCFSParam3"))%>&relId=<%=XSSUtil.encodeForJavaScript(context,relId)%>&functionality=<%=XSSUtil.encodeForJavaScript(context,strfunctionality)%>&fromcontext=<%=XSSUtil.encodeForJavaScript(context,strFromContext)%>&radProductConfigurationPurposeValue=<%=XSSUtil.encodeForJavaScript(context,strPurpose)%>&topLevelPart=<%=XSSUtil.encodeForJavaScript(context,topLevelPart)%>&topLevelPartDisplay=<%=XSSUtil.encodeForJavaScript(context,topLevelPartDisplay)%>&startEffValue=<%=XSSUtil.encodeForJavaScript(context,startEffValue)%>&endEffValue=<%=XSSUtil.encodeForJavaScript(context,endEffValue)%>" TITLE="Options" marginwidth="10" marginheight="2" frameborder="no" />
		           		
        </FRAMESET>
  </FRAMESET>
  <NOFRAMES>
    <BODY>
      This Wizard Requires Frames.
    </BODY>
  </NOFRAMES>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
