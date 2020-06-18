<%--
  ConfigurationFeatureCopyDialog.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxProductCommonInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="emxValidationInclude.inc"%>

<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><html>

<%
   String strParentSymType = FrameworkUtil.getAliasForAdmin(context,ConfigurationConstants.SELECT_TYPE,ConfigurationConstants.TYPE_PRODUCTS,true);
   String strInvalidStatesTypes = EnoviaResourceBundle.getProperty(context, "Configuration.FrozenState."+strParentSymType);
   String LogicalFeatureCopyTo="LogicalFeatureCopyTo";
   String LogicalFeatureCopyFrom="LogicalFeatureCopyFrom";
   String isFromPropertyPage = emxGetParameter(request, "isFromPropertyPage"); 
 
        String destName="";
        String languageStr = context.getSession().getLanguage();
        String functionality = emxGetParameter(request, "functionality");       
        String[] strTableRowIds = (String[])session.getAttribute("selectedValues");
        String sSuiteKey = "eServiceSuite"+ emxGetParameter(request, "suiteKey");               
        String sObjectId = emxGetParameter(request, "objectId");
        String sObjIdContext = emxGetParameter(request, "objIdContext");
        String type = "";
        String strParentType = "";
        String strInclusionFeatureTypes = "";
        DomainObject bus = new DomainObject(sObjIdContext);
        String sSelObjId = "";
        boolean disableShareOption = false;
%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script>
var action = "<%=XSSUtil.encodeForJavaScript(context,functionality )%>";
 
</script>

<%
if(functionality!=null && functionality.equals(LogicalFeatureCopyTo)){
    StringTokenizer strTokenizer;
    String strPrevFeatureId = "";
    String strParentId = "";
    String strFeatureId = "";
    
    for(int iCount=0;iCount<strTableRowIds.length;iCount++)
    {   
          strTokenizer = new StringTokenizer(strTableRowIds[iCount] , "|");
          strTokenizer.nextToken();
          strFeatureId = strTokenizer.nextToken();
          strParentId = strTokenizer.nextToken();
          if(strParentId.equals(strPrevFeatureId) && !strPrevFeatureId.equals("")){
           disableShareOption = true;                              
          }
          strPrevFeatureId = strFeatureId;
    }             
}       
        
        if(bus.isKindOf(context, ConfigurationConstants.TYPE_PRODUCT_LINE)){
            strParentType = ConfigurationConstants.TYPE_PRODUCT_LINE;
        }else if(bus.isKindOf(context, ConfigurationConstants.TYPE_PRODUCT_VARIANT)){
            strParentType = ConfigurationConstants.TYPE_PRODUCT_VARIANT;
        }else if(bus.isKindOf(context, ConfigurationConstants.TYPE_CONFIGURATION_FEATURE)){
            strParentType = ConfigurationConstants.TYPE_CONFIGURATION_FEATURE;
        }else if(bus.isKindOf(context, ConfigurationConstants.TYPE_PRODUCTS)){
            strParentType = ConfigurationConstants.TYPE_PRODUCTS;
        }else if(bus.isKindOf(context, ConfigurationConstants.TYPE_LOGICAL_FEATURE)){
            strParentType = ConfigurationConstants.TYPE_LOGICAL_FEATURE;
        }             
             
        type = FrameworkUtil.getAliasForAdmin(context,ConfigurationConstants.SELECT_TYPE,strParentType,true);
        
        if (functionality != null
                && (functionality.equals("LogicalFeatureCopyFrom") || functionality
                        .equals("LogicalFeatureCopyTo"))) {
            strInclusionFeatureTypes = EnoviaResourceBundle.getProperty(context, sSuiteKey + "." + functionality
                            + "AllowedSourceTypesForDestination."
                            + type);
        }

        String strEnableMultilvel = EnoviaResourceBundle.getProperty(context,"emxConfiguration.Copy.MultiLevelSelection.Enabled");

        if (strEnableMultilvel == null
                || strEnableMultilvel.equalsIgnoreCase("No")) {
            disableShareOption = false;
        }

        String strDisableParam = "";
        String strFont = "black";

        if (disableShareOption) {
            strDisableParam = "DISABLED";
            strFont = "gainsboro";
        }

        String IncludedData = EnoviaResourceBundle.getProperty(context,sSuiteKey
                + "." + functionality + ".IncludedData");
        StringTokenizer st = new StringTokenizer(IncludedData, ",");
        ArrayList includedOption = new ArrayList();

        boolean isREQInstalled = FrameworkUtil.isSuiteRegistered(context, "appVersionRequirementsManagement", false, null, null);
        
        while(st.hasMoreTokens())
        { 
               String includeData = st.nextToken();
               if(includeData!=null && includeData.equals("Use Case")){
                   if(isREQInstalled){
                       includedOption.add(includeData);
                   }
               }
               else{
                   includedOption.add(includeData);
               }               
        }

%>
<body>
<form name="ProductCopy" method="post" action="moveNext()"><input
    type="hidden" name="sourceObjectId" value="" />
    <input type="hidden" name="isFromPropertyPage" value="<%=XSSUtil.encodeForHTMLAttribute(context,isFromPropertyPage)%>" />
    

<table border="0" cellpadding="5" cellspacing="2" width="100%">
    <%-- Display the input fields. --%>

    <%
        if (functionality.equalsIgnoreCase(LogicalFeatureCopyFrom)) {
        
        if(sSelObjId!=null && !sSelObjId.trim().isEmpty()){
           destName=new DomainObject(sSelObjId).getInfo(context,DomainObject.SELECT_NAME);
        }
    %>
    <tr>
        <td width="150" nowrap="nowrap" class="labelRequired"><emxUtil:i18n
            localize='i18nId'>emxConfiguration.CopyDialog.Source</emxUtil:i18n></td>
        <%
            } else {
        %>
    
    <tr>
        <td width="150" nowrap="nowrap" class="labelRequired"><emxUtil:i18n
            localize='i18nId'>emxConfiguration.CopyDialog.Destination</emxUtil:i18n>
        </td>
        <%
            }
        %>
<%-- DO NOT FORMAT CONTENT IN TD BELOW. --%>
        <td nowrap="nowrap" class="field"><input type="text" id="txtSourceObject" name="txtSourceObject" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=destName%></xss:encodeForHTMLAttribute>" /><input type="hidden" id="txtToFeatureId" name="txtToFeatureId" value="<xss:encodeForHTML><%=sSelObjId%></xss:encodeForHTML>" /><input class="button" type="button" name="btnProduct" size="200" value="..." alt="" onClick="javascript:showProductChooser()" /></td>
    </tr>
<tr>
<td width="30%" nowrap="nowrap" class="label" >
<emxUtil:i18n localize='i18nId'>emxConfiguration.CopyDialog.CopyOptions</emxUtil:i18n>
</td>
<%-- DO NOT FORMAT CONTENT IN TD BELOW. --%>
<td width="70%" nowrap="nowrap" class="field" ><input type="radio" name="Clone" size="20" checked="checked" onClick="Disable(this,'')" /><emxUtil:i18n localize='i18nId'>emxConfiguration.CopyDialog.CloneSelectedFeatures</emxUtil:i18n>&nbsp
<input type="radio" name="Share" size="20" onClick="Disable(this,'true')" <xss:encodeForHTMLAttribute><%=strDisableParam%></xss:encodeForHTMLAttribute> /><font color="<xss:encodeForHTMLAttribute><%=strFont%></xss:encodeForHTMLAttribute>"><emxUtil:i18n localize='i18nId'>emxConfiguration.CopyDialog.ShareSelectedFeatures</emxUtil:i18n></font>
<input type="hidden" name="destinationObjectId" value="" /></td><tr>
                            <td width="30%" nowrap="nowrap" class="label" >
                                    <emxUtil:i18n localize='i18nId'>emxConfiguration.CopyDialog.IncludeRelatedData</emxUtil:i18n>
                            </td>
                             <%-- DO NOT FORMAT CONTENT IN TD BELOW. --%>
                            <td width="70%" nowrap="nowrap" class="field"><input type="checkbox" name="All" size="20" checked="checked"  onClick="checkAll()" /><%=XSSUtil.encodeForHTML(context,EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.CoptFunctionality.All",languageStr))%><%
                             String sOption=null;
                             String strDisplayValue = null;
                             for(int row=includedOption.size()-1;row>=0;row--) {
                              sOption = (String)includedOption.get(row);
                              strDisplayValue= sOption;
                              strDisplayValue = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.CoptFunctionality."+strDisplayValue.replaceAll(" ","_"),languageStr);
                             %><BR><input type="checkbox" name="<xss:encodeForHTMLAttribute><%=sOption%></xss:encodeForHTMLAttribute>" checked="checked"  size="20" onclick="deselectALL();selectALL()" /><%=XSSUtil.encodeForHTML(context,strDisplayValue)%><%                                 
                             } 
                            %>
                            </td>
                          </tr>
</table>
</form>

<script language="javascript" type="text/javaScript">
  //<![CDATA[
    var  formName = document.ProductCopy;

  function checkAll()
  {  
	var allElements = formName.getElementsByTagName("input");
	var isAllChecked = false;
	for (var i = 0; i < allElements.length; i++) 
    {         
	    if((allElements[i].type == "checkbox") && (allElements[i].name == "All") && (allElements[i].checked==true)){
	    isAllChecked = true;
	    }      
    } 
    
    if(isAllChecked){
        for (var i = 0; i < allElements.length; i++) 
        {          
    	   if(allElements[i].type == "checkbox"){
           formName.elements[i].checked = true;    
    	   }  
        } 
    }
    else{
        for (var i = 0; i < allElements.length; i++) 
        {   if(allElements[i].type == "checkbox"){        
                formName.elements[i].checked = false; 
            }     
        }
        } 
  }

  function Disable(form,value1)
  { 
	 var allElements = formName.getElementsByTagName("input");
     if(value1 == "")
     {
         
         for (var i = 0; i < allElements.length; i++) 
         { 
           if(allElements[i].type == "checkbox"){
               formName.elements[i].checked = true;
	           if(formName.elements[i].name == "Effectivity"){
	        	   formName.elements[i].disabled=false;
	           }else{
	        	   formName.elements[i].disabled=value1;   
	           } 
           }
           else if((allElements[i].type == "radio") && (allElements[i].name == "Share")){
   		   formName.elements[i].checked = false;
   		   }      
         } 
     }
     else
     {
        for (var i = 0; i < allElements.length; i++) 
        { 
          if(allElements[i].type == "checkbox"){
	          formName.elements[i].checked = false;
	          if(formName.elements[i].name == "Effectivity"){
	       	   formName.elements[i].disabled=false;
	          }else{
	       	   formName.elements[i].disabled=value1;   
	          } 
          }
          else if((allElements[i].type == "radio") && (allElements[i].name == "Clone")){
 		  formName.elements[i].checked = false;
 		  }     
        } 
     } 
 } 
  function deselectALL()
  {
	  var allElements = formName.getElementsByTagName("input");
	  var isUnchecked = false;
	  for (var i = 0; i < allElements.length; i++) 
	  { 
		 if((allElements[i].type == "checkbox") && (allElements[i].checked == false) && (allElements[i].name != "All"))
		 {
			 isUnchecked = true;
		 }  
	  } 

	  if(isUnchecked){
	  for (var i = 0; i < allElements.length; i++) 
	  {         
		   if((allElements[i].type == "checkbox") && (allElements[i].name == "All")){
		   allElements[i].checked=false;
		   }      
	  }
	  } 
  } 

    
 function showProductChooser()
 {
     if(action=='LogicalFeatureCopyTo'){
     //var submitURL="../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForURL(context,strInclusionFeatureTypes.toString())%>:Type!=type_ProductVariant:CURRENT!=<%=XSSUtil.encodeForURL(context,strInvalidStatesTypes)%>&excludeOIDprogram=LogicalFeature:filterLeafLevel&table=FTRLogicalFeatureSearchResultsTable&showInitialResults=false&Registered Suite=Configuration&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../configuration/SearchUtil.jsp?mode=Chooser&chooserType=CustomChooser&fieldNameActual=txtToFeatureId&fieldNameDisplay=txtSourceObject&objIdContext=<%=XSSUtil.encodeForURL(context,sObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,sObjectId)%>&value=<%=XSSUtil.encodeForURL(context,functionality)%>&excludeOIDprogram=LogicalFeature:excludeAvailableLogicalFeature";
     var submitURL="../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForURL(context,strInclusionFeatureTypes.toString())%>:Type!=type_ProductVariant:CURRENT!=<%=XSSUtil.encodeForURL(context,strInvalidStatesTypes)%>:LEAFLEVEL!=Yes&table=FTRLogicalFeatureSearchResultsTable&showInitialResults=false&Registered Suite=Configuration&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../configuration/SearchUtil.jsp?mode=Chooser&chooserType=CustomChooser&fieldNameActual=txtToFeatureId&fieldNameDisplay=txtSourceObject&objIdContext=<%=XSSUtil.encodeForURL(context,sObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,sObjectId)%>&value=<%=XSSUtil.encodeForURL(context,functionality)%>&excludeOIDprogram=LogicalFeature:excludeAvailableLogicalFeature";
     showModalDialog(submitURL,575,575,"true","Medium");
     }else{
         var submitURL="../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForURL(context,strInclusionFeatureTypes.toString())%>:Type!=type_ProductVariant:CURRENT!=<%=XSSUtil.encodeForURL(context,strInvalidStatesTypes)%>&table=FTRLogicalFeatureSearchResultsTable&showInitialResults=false&Registered Suite=Configuration&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../configuration/SearchUtil.jsp?mode=Chooser&chooserType=CustomChooser&fieldNameActual=txtToFeatureId&fieldNameDisplay=txtSourceObject&objIdContext=<%=XSSUtil.encodeForURL(context,sObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,sObjectId)%>&value=<%=XSSUtil.encodeForURL(context,functionality)%>&excludeOIDprogram=LogicalFeature:excludeAvailableLogicalFeature";
         showModalDialog(submitURL,575,575,"true","Medium");
         }   
 }
 
 function selectALL()
 {
	  var allElements = formName.getElementsByTagName("input");
	  var count = 0;
	  var elem = null;
	  var checkboxes = 0;
	  
	  for (var i = 0; i < allElements.length; i++) 
	  { 
		 if((allElements[i].type == "checkbox"))
		 {
			 checkboxes = checkboxes + 1;
		 }  
		 
		 if((allElements[i].type == "checkbox") && (allElements[i].checked == true) && (allElements[i].name != "All"))
		 {
			 count = count + 1;
		 }  
		 	       
		 if((allElements[i].type == "checkbox") && (allElements[i].name == "All")){
			 elem = allElements[i];
		 		 	
		 }      
	  } 
  	 	  
	  if(elem != null && count == (checkboxes-1))
	  {
		  elem.checked = true;
	  }
 } 
  //]]>
  </script>
</body>
</html>
