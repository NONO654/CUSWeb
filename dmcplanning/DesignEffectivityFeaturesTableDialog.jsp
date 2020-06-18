<%--  DesignEffectivityFeaturesTableDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/dmcplanning/DesignEffectivityFeaturesTableDialog.jsp 1.1.1.1 Mon Jan 12 12:49:53 2009 GMT ds-shbehera Experimental$";

--%>
<%-- Common Includes --%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>

<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>

<%-- Imports --%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.dmcplanning.Product"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.dmcplanning.MasterFeature"%>
<%@page import="java.util.Enumeration"%>

<SCRIPT language="javascript" src="../common/scripts/emxJSValidationUtil.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICalendar.js"></SCRIPT>

    <script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>
    <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
	  String featureOptions = "DMCPlanning.Heading.FeaturesAndOptions";
	  String usage = "DMCPlanning.Table.Usage";
      String strFromContext = emxGetParameter(request,"fromcontext");
      String relId = emxGetParameter(request, "relId");
      String jsTreeId = emxGetParameter(request, "jsTreeID");
      String strObjId           = emxGetParameter(request, "objectId");
      String MarketingName = emxGetParameter(request, "strMarketingName");
      String strTimeStamp = emxGetParameter(request, "timeStamp");
      String strAction = emxGetParameter(request, "PRCFSParam2");
      String productEffectivityId = emxGetParameter(request, "productEffectivityId");
      String strParentProductID = emxGetParameter(request, "ParentProductID");
      String strCreateRevise = emxGetParameter(request,"createRevise");
      String productId = "";
      String modelId = "";
      
      Enumeration eNumParameters = emxGetParameterNames(request);
      while( eNumParameters.hasMoreElements() ) 
      {
          String parmName = (String)eNumParameters.nextElement();
          String parmValue = (String)emxGetParameter(request,parmName);
          
      }
      String mode = emxGetParameter(request,"mode");
      //setting context id in global variable
      DomainObject domObj = new DomainObject(strObjId);
      String contextObjectType = domObj.getInfo(context,DomainConstants.SELECT_TYPE);
      if(mxType.isOfParentType(context,contextObjectType,ManufacturingPlanConstants.TYPE_PRODUCTS))
      {
    	  MasterFeature masterFeature = new MasterFeature(strObjId);
          masterFeature.setContextId(context,strObjId);
      }      
  
      if(mode != null && mode.equalsIgnoreCase("editOptions"))
      {
          session.removeAttribute("productId");
          %>
         <script language="javascript" type="text/javaScript">      
          contextMode = '<%=XSSUtil.encodeForJavaScript(context,String.valueOf(ManufacturingPlanConstants.MODE_EDIT))%>';
          contextObjectType = '<%=XSSUtil.encodeForJavaScript(context,contextObjectType)%>';
          </script>
          <%          
      }
      
 String language  = request.getHeader("Accept-Language");
%>



<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlan"%><html>
<head>
  <link rel="stylesheet" type="text/css" media="screen" href="./styles/emxUIConfigurator.css">
</head>
<Script>

</Script>
 
<%
if(mode != null && mode.equalsIgnoreCase("editOptions"))
      {
	
          %>
          <body > 
          <%
      }
else
{
%>

<body>
<%} %>
<form name="featureOptions" method="post">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>

  <div id="mx_divBasePrice">
    <table border="0" cellpadding="0" cellspacing="0">
      <thead>
        <tr>

          <th class="mx_name"></th>
          <th class="mx_usage">&#160;</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          
          <td class="mx_name"><framework:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,featureOptions)%></framework:i18n></td>
          <td class="mx_usage" style="align:left"><b><framework:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,usage)%></framework:i18n></b></td>
        </tr>
      </tbody>
    </table>
  </div>
  
  <div id="editResponse"></div>
  
  
<%
    if("edit".equalsIgnoreCase(strAction))
    {
    	productId = productEffectivityId;
    	//DomainObject domProduct = new DomainObject(productId);
        //modelId = domProduct.getInfo(context, "to["+ManufacturingPlanConstants.RELATIONSHIP_PRODUCTS+"].from.id");
    	ManufacturingPlan mPlan = new ManufacturingPlan();
        modelId = mPlan.getMasterFromContext(context, productId);
    }
    else
    {
    	modelId = productEffectivityId;
        productId = 	strParentProductID;
        
    }
    
    
    com.matrixone.apps.dmcplanning.Product product = new com.matrixone.apps.dmcplanning.Product(productId);
    MapList mapModelMasterFeaturestrructure = (MapList)product.getEffectivityStructure(context,modelId);
    session.setAttribute("ProductId",productId);
    
    String component = product.getEffectivityStructureHTMLDisplay(context, mapModelMasterFeaturestrructure);
    out.print(component);
%>
</form>
<script language="javascript" type="text/javaScript">   

function submit()
{
	var formObject = self.document.featureOptions;

	var element;
	var arrElements = formObject.elements;
	var strSelectedIdList = "";
    var strUsage = "";
    var strUnselectedIdList = "";
	for(var i=0; i< arrElements.length; i++)
	{
	    element = arrElements[i];
	    strUsage = element.getAttribute("usage");
	    if(element.checked && (element.getAttribute("level") != 1))
	    {
	        // then get the id of the element & form a string & now pass this ',' seperated string as a paramenter to the bellow url
	        // now get this list in util.jsp & toknize & get the id's & make the connection
	        strSelectedIdList +=element.getAttribute("id") + "|" + strUsage + ",";
		}
	   else if(!element.checked && (element.getAttribute("level") != 1))
	   {
	            // then get the id of the element & form a string & now pass this ',' seperated string as a paramenter to the bellow url
	            // now get this list in util.jsp & toknize & get the id's & make the connection
	            strUnselectedIdList +=element.getAttribute("id")+ ",";
	   }
			
	}

	strUnselectedIdList+=revisionsDeSelectionList;
	strSelectedIdList+=revisionSelectionList;
    //as we will be having ajax call on submit,we will remove hidden elements if exists
	var effectivityselectionsElem = document.getElementById("effectivityselections");
	if(effectivityselectionsElem!=null){
		formObject.removeChild(effectivityselectionsElem);
	}

	var effectivitydeselectionsElem = document.getElementById("effectivitydeselections");
	if(effectivitydeselectionsElem!=null){
		formObject.removeChild(effectivitydeselectionsElem);
	}
	
	var newElementSelected = document.createElement("input");
	newElementSelected.setAttribute("type", "hidden");
	newElementSelected.setAttribute("name", "effectivityselections");
	newElementSelected.setAttribute("id", "effectivityselections");
	newElementSelected.setAttribute("value", strSelectedIdList);

    var newElementUnSelected = document.createElement("input");
    newElementUnSelected.setAttribute("type", "hidden");
    newElementUnSelected.setAttribute("name", "effectivitydeselections");
    newElementUnSelected.setAttribute("id", "effectivitydeselections");
    newElementUnSelected.setAttribute("value", strUnselectedIdList);


    formObject.appendChild(newElementSelected);
	formObject.appendChild(newElementUnSelected);
	
    //AJAX call to check if selection/deselection will break MP breakdown, i.e. design change
	var strAction1 = '<%=XSSUtil.encodeForJavaScript(context,strAction)%>';
    var url="../dmcplanning/DesignEffectivityUtil.jsp";
    var queryString ="mode=checkDesignChangeConfirm"+
    "&effectivityselections="+strSelectedIdList+
    "&effectivitydeselections="+strUnselectedIdList+
    "&PRCFSParam2="+strAction1;
    var vRes = emxUICore.getDataPost(url,queryString);
    var iIndex = vRes.indexOf("bdesignChange=");
    var iLastIndex = vRes.indexOf("#");
    var bdesignChange = vRes.substring(iIndex+"bdesignChange=".length , iLastIndex );
    if(trim(bdesignChange)== "true"){
      //on design change will show confirm box 
 	  var confirmmsg = "<%=i18nStringNowUtil("DMCPlanning.Alert.EditManufacturingPlanBreakdownNotInSync","dmcplanningStringResource",language)%> ";
      //if user click on OK, we will go ahead and disconnect MP breakdown and MPI
  	  if(confirm(confirmmsg)){  	  	
 			var strAction = '<%=XSSUtil.encodeForJavaScript(context,strAction)%>';
 		    formObject.action="../dmcplanning/DesignEffectivityUtil.jsp?mode=create&PRCFSParam2="+strAction;
 		    if (jsDblClick()){ 	 		    
 		    	formObject.submit();
 		    }
 	  }
 	  else{ 	 	 
 	 	  //if click on cancel, no form submit
 		 return;
 	  }
    }else{
        //if there is no Design chnage, there will be disconnect MP breakdown and MPI     
    	var strAction = '<%=XSSUtil.encodeForJavaScript(context,strAction)%>';
        formObject.action="../dmcplanning/DesignEffectivityUtil.jsp?mode=create&PRCFSParam2="+strAction;
        if (jsDblClick()){
        	formObject.submit();
        }
    }
    return;
 }


function closeWindow() {
	self.document.featureOptions.action="DesignEffectivityUtil.jsp?mode=cleanupsession";
	self.document.featureOptions.submit();
    parent.window.closeWindow();
}

function movePrevious()
{
  document.featureOptions.target="_top";
  document.featureOptions.method ="post";
  var timeStamp = '<%=XSSUtil.encodeForJavaScript(context,strTimeStamp)%>'; 
  var strCreateRevise = '<%=XSSUtil.encodeForJavaScript(context,strCreateRevise)%>'
  document.featureOptions.action="../components/emxCommonFS.jsp?StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeId)%>&functionality=ProductRevisionReviseFlatViewFSInstance&suiteKey=DMCPlanning&PRCFSParam1=Product&PRCFSParam3=getfromsession&relId=<%=XSSUtil.encodeForURL(context,relId)%>&fromcontext=<%=XSSUtil.encodeForURL(context,strFromContext)%>&objectId=<%=XSSUtil.encodeForURL(context,strObjId)%>";
  document.featureOptions.submit();
}

function showSubfeaturesChooser(modelTemplateId,productId) 
{
    showChooser('../common/emxFullSearch.jsp?includeOIDprogram=MasterFeature:getManagedSeriesForDB&field=TYPES=type_LogicalFeature,type_Products&table=FTRFeatureSearchResultsTable&showInitialResults=false&selection=multiple&parentID='+modelTemplateId+'&HelpMarker=emxhelpfullsearch&mode=DesignEffectivityChooser&suiteKey=DMCPlanning&submitURL=../dmcplanning/DesignEffectivityUtil.jsp?parentFeatureId='+modelTemplateId+'&contextBusId=' + productId, 850, 630);
}
var revisionsDeSelectionList = new Array();
var revisionSelectionList = new Array();
function removeAddedRows(strManagedRevisionId)
{
    
    var tBody = document.getElementById("featureOptionsBody");
    var targetRowId = strManagedRevisionId;
    var targetRow = document.getElementById(targetRowId);   
    var nxtSibling;
    if(tBody && targetRow)
    {
        tBody.removeChild(targetRow);
        revisionsDeSelectionList.push(targetRow.getAttribute("id"));
        
    }
}

function addNewRow(rowInnerHtml, modelTemplateId,managedRevisionId,usage)
{
	var tBody = document.getElementById("featureOptionsBody");
    var targetRowId = modelTemplateId;
    if(tBody)
    {
        var newDiv = document.createElement("div");
        newDiv.innerHTML = rowInnerHtml;
        var newRow = newDiv.firstChild.firstChild.firstChild;
        var targetRow = document.getElementById(targetRowId);
        insertAfter(newRow, targetRow);
        revisionSelectionList.push(managedRevisionId+"|"+usage);
    }
}  

// to insert an element after the targeted element 
function insertAfter(newElement,targetElement) {
    var parent = targetElement.parentNode;
    if (parent.lastChild == targetElement) {
        parent.appendChild(newElement);
    } else {
        parent.insertBefore(newElement,targetElement.nextSibling);
    }
}

function validateObsolete(strState,objid){
		
	var formObject = self.document.featureOptions;
	var arrElements="";
	arrElements = formObject.elements;
	
	for(var i=0; i< arrElements.length; i++)
	{
	    element = arrElements[i];
	   var strId= element.getAttribute("id");
	 
	    if(strId == objid && element.checked && strState == "Obsolete"){
	    	alert("<%=i18nStringNowUtil("DMCPlanning.Alert.EditAndAddNotAllowedinObsolete","dmcplanningStringResource",context.getSession().getLanguage())%>");  
	    	element.checked=false;
	    }
	}
	
	
	
}

</script>
   
</body>
</html>
   
   
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
