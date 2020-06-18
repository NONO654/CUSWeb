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

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="java.util.ArrayList"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%><html>

<%
         
         String languageStr = context.getSession().getLanguage();
         String functionality = emxGetParameter(request,"functionality");
         String strvariabilityMode = emxGetParameter(request,"variabilityMode");
         String[] strTableRowIds = (String[])session.getAttribute("selectedValues");
         String sSuiteKey = "eServiceSuite"+emxGetParameter(request, "suiteKey");         
         String sObjectId = emxGetParameter(request, "objectId");
         String strObjIdContext = emxGetParameter(request, "objIdContext");
         String type = "";
         String strParentType = "";
         String strInclusionFeatureTypes = "";
         DomainObject bus = null;                 
         boolean disableShareOption = false;
         String isFromPropertyPage = emxGetParameter(request, "isFromPropertyPage");
%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script>
             var action = "<%= XSSUtil.encodeForJavaScript(context,functionality )%>";
         </script>
<%         
         
         
         bus = new DomainObject(strObjIdContext);
         %>
<script> 
                 var objID = "<%= XSSUtil.encodeForJavaScript(context,sObjectId)%>";          
             </script>
<%       
         if(functionality!=null && functionality.equals("ConfigurationFeatureCopyTo")){
             StringTokenizer strTokenizer;
             String strPrevFeatureId = "";
             String strParentId = "";
             String strFeatureId = "";
//             StringList slObjSelected= new StringList();
             for(int iCount=0;iCount<strTableRowIds.length;iCount++)
             {   
                   strTokenizer = new StringTokenizer(strTableRowIds[iCount] , "|");
                   strTokenizer.nextToken();
                   strFeatureId = strTokenizer.nextToken();
//                   slObjSelected.add(strFeatureId);
                   strParentId = strTokenizer.nextToken();
                   if(strParentId.equals(strPrevFeatureId) && !strPrevFeatureId.equals("")){
                       disableShareOption = true;
                       break;
                   }
                   strPrevFeatureId = strFeatureId;
             } 
             
/*              if(!disableShareOption){
            	 // check if selected object are all of CO type
            	 boolean isAllVV=ConfigurationUtil.isListContainsAllTypeOfKind(context,slObjSelected,ConfigurationConstants.TYPE_VARIANTVALUE);
            	 boolean isAllVRO=ConfigurationUtil.isListContainsAllTypeOfKind(context,slObjSelected,ConfigurationConstants.TYPE_VARIABILITYOPTION);
                 if(isAllVV || isAllVRO){
                     disableShareOption = true;
                 }
             } */
             }
/*         boolean isVariantSelected = false;
        boolean isVBGSelected = false;
		if(functionality!=null && functionality.equals("ConfigurationFeatureCopyFrom")){
		    StringList slObjSelected= new StringList();
		    for(int iCount=0;iCount<strTableRowIds.length;iCount++) {   
		          StringList slobjIDs=FrameworkUtil.split(strTableRowIds[iCount], "|");
		          if(slobjIDs.size()==4)//Non Root Node
		               slObjSelected.add((String)slobjIDs.get(1));
		          else//Root node
		        	  slObjSelected.add((String)slobjIDs.get(0));
		    } 
		   	 // check if selected object is of CF type
		   	  isVariantSelected=ConfigurationUtil.isListContainsTypeOfKind(context,slObjSelected,ConfigurationConstants.TYPE_VARIANT);
		   	 isVBGSelected=ConfigurationUtil.isListContainsTypeOfKind(context,slObjSelected,ConfigurationConstants.TYPE_VARIABILITYGROUP);
		        if(isVariantSelected || isVBGSelected){
		            disableShareOption = true;
		        }
		}  */
         
         if(bus.isKindOf(context, ConfigurationConstants.TYPE_PRODUCT_LINE)){
             strParentType = ConfigurationConstants.TYPE_PRODUCT_LINE;
         }else if(bus.isKindOf(context, ConfigurationConstants.TYPE_PRODUCT_VARIANT)){
             strParentType = ConfigurationConstants.TYPE_PRODUCT_VARIANT;
         }else if(bus.isKindOf(context, ConfigurationConstants.TYPE_VARIANT)){
             strParentType = ConfigurationConstants.TYPE_VARIANT;
         }else if(bus.isKindOf(context, ConfigurationConstants.TYPE_VARIABILITYGROUP)){
                 strParentType = ConfigurationConstants.TYPE_VARIABILITYGROUP;    
         }else if(bus.isKindOf(context, ConfigurationConstants.TYPE_PRODUCTS)){
             strParentType = ConfigurationConstants.TYPE_PRODUCTS;
         }else if(bus.isKindOf(context, ConfigurationConstants.TYPE_CONFIGURATION_FEATURE)){
             strParentType = ConfigurationConstants.TYPE_CONFIGURATION_FEATURE;    
         }           
              
         type = FrameworkUtil.getAliasForAdmin(context,ConfigurationConstants.SELECT_TYPE,strParentType,true);
         
         if(functionality!=null && (functionality.equals("ConfigurationFeatureCopyFrom") || functionality.equals("ConfigurationFeatureCopyTo"))){
             strInclusionFeatureTypes = ConfigurationUtil.getInclusionFeatureTypes(context, sSuiteKey, functionality, type);
         }
         
         // 
         /* if("Variant".equalsIgnoreCase(strvariabilityMode)){
        	 strInclusionFeatureTypes = strInclusionFeatureTypes.replaceAll("type_ConfigurationFeature", "type_Variant");
         }else if("VariabilityGroup".equalsIgnoreCase(strvariabilityMode)){
        	 strInclusionFeatureTypes = strInclusionFeatureTypes.replaceAll("type_ConfigurationFeature", "type_VariabilityGroup");
         } */
         strInclusionFeatureTypes += ",type_Variant,type_VariabilityGroup"; 
         String strEnableMultilvel = EnoviaResourceBundle.getProperty(context,"emxConfiguration.Copy.MultiLevelSelection.Enabled");                 
         if (strEnableMultilvel == null || strEnableMultilvel.equalsIgnoreCase("No")){
             disableShareOption = false;
         }                  
         String strDisableParam = "";
         String strFont = "black";         
         if(disableShareOption)
         {
             strDisableParam="DISABLED";
             strFont = "gainsboro";
         }         
         String IncludedData = EnoviaResourceBundle.getProperty(context,sSuiteKey + "." + functionality + ".IncludedData");
         StringTokenizer st = new StringTokenizer(IncludedData, ",");
         ArrayList  includedOption = new ArrayList();         
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

    <%   if(functionality.equalsIgnoreCase("ConfigurationFeatureCopyFrom"))
                  { 
                   %>
    <tr>
        <td width="30%" nowrap="nowrap" class="labelRequired"><emxUtil:i18n
            localize='i18nId'>emxConfiguration.CopyDialog.Source</emxUtil:i18n></td>
        <%
                  }
                  else
                  {
                  %>
        <td width="30%" nowrap="nowrap" class="labelRequired"><emxUtil:i18n
            localize='i18nId'>emxConfiguration.CopyDialog.Destination</emxUtil:i18n>
        </td>
        <%
                  }
                  %>
        <%-- DO NOT FORMAT CONTENT IN TD BELOW. --%>
        <td width="70%" nowrap="nowrap" class="field"><input type="text" id="txtSourceObject" name="txtSourceObject" size="20" readonly="readonly" value="" onChange="javascript:checkAll()" /><input type="hidden" id="txtToFeatureId" name="txtToFeatureId" value="" /> <input class="button" type="button" name="btnProduct" size="200" value="..." alt="" onClick="javascript:showProductChooser()" /></td>
    </tr>
    
    <tr>
        <td width="30%" nowrap="nowrap" class="label"><emxUtil:i18n
            localize='i18nId'>emxConfiguration.CopyDialog.CopyOptions</emxUtil:i18n>
        </td>
        <%-- DO NOT FORMAT CONTENT IN TD BELOW. --%>
        <td width="70%" nowrap="nowrap" class="field"><input type="radio" name="Clone" size="20" checked="checked" onClick="Disable(this,'')" /> <emxUtil:i18n localize='i18nId'>emxConfiguration.CopyDialog.CloneSelectedFeatures</emxUtil:i18n>&nbsp
<input type="radio" name="Share" size="20" onClick="Disable(this,'true')" <xss:encodeForHTMLAttribute><%=strDisableParam%></xss:encodeForHTMLAttribute> /> <font color="<xss:encodeForHTMLAttribute><%=strFont%></xss:encodeForHTMLAttribute>"><emxUtil:i18n localize='i18nId'>emxConfiguration.CopyDialog.ShareSelectedFeatures</emxUtil:i18n></font><input type="hidden" name="destinationObjectId" value="" /></td>
    </tr>

    <tr>
        <td width="30%" nowrap="nowrap" class="label"><emxUtil:i18n
            localize='i18nId'>emxConfiguration.CopyDialog.IncludeRelatedData</emxUtil:i18n>
        </td>
        <%-- DO NOT FORMAT CONTENT IN TD BELOW. --%>
        <td width="70%" nowrap="nowrap" class="field"><input type="checkbox" name="All" size="20" checked="checked" onClick="checkAll();" /><%=XSSUtil.encodeForHTML(context,EnoviaResourceBundle.getProperty(context,"Configuration", "emxConfiguration.CoptFunctionality.All",languageStr))%><%
                             String sOptionValue = "";
                             String strOptions=null;
                             String sOption=null;
                             String strDisplayValue = null;
                                 for(int row=includedOption.size()-1;row>=0;row--) {
                                     sOption = (String)includedOption.get(row);
                                     strDisplayValue= sOption;
                                     if(ConfigurationConstants.TYPE_PRODUCT_LINE.equalsIgnoreCase(strParentType) && "Effectivity".equalsIgnoreCase(strDisplayValue)){
                                     }else{
                                           strDisplayValue = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.CoptFunctionality."+strDisplayValue.replaceAll(" ","_"),languageStr);
                                        %> <BR><input type="checkbox" name="<xss:encodeForHTMLAttribute><%=sOption %></xss:encodeForHTMLAttribute>" checked="checked" size="20" onclick="deselectALL();selectALL()" /><%=XSSUtil.encodeForHTML(context,strDisplayValue)%>
                                        <%
                                        }
                                      }
                                      %></td>
    </tr>
</table>
</form>

<script language="javascript" type="text/javaScript">
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
          {  
             if(allElements[i].type == "checkbox"){
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
     var submitURL = "../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForURL(context,strInclusionFeatureTypes.toString())%>&table=FTRConfigurationFeaturesSearchResultsTable&showInitialResults=false&Registered Suite=Configuration&selection=single&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../configuration/SearchUtil.jsp?mode=Chooser&chooserType=CustomChooser&fieldNameActual=txtToFeatureId&fieldNameDisplay=txtSourceObject&objIdContext=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,sObjectId)%>&value=<%=XSSUtil.encodeForURL(context,functionality)%>&variabilityMode=<%=strvariabilityMode%>&excludeOIDprogram=ConfigurationFeature:excludeAvailableConfigurationFeature";
     showModalDialog(submitURL,575,575,"true","Medium");
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

  </script>
</body>
</html>
