

<%--  CreateResourceUsageDialog.jsp

   Display Page for the Create New Resource Usage
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
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxValidationInclude.inc" %>
<%@include file = "GlobalSettingInclude.inc"%>


<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@page import="java.util.Vector"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.configuration.ResourceUsage"%>
<%@page import="com.matrixone.apps.configuration.RuleProcess"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Arrays"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>


<%
 String strResourceId = "";
 String strProductId = "";
 String objectId  = "";
 String strMode = "";
 short sRecurse= 1;
 try{
     String[] arrRowIds = emxGetParameterValues(request, "emxTableRowId");
     strMode = emxGetParameter(request,"mode");
     
     Vector vctDetails = new Vector();
     Vector vctRelIDs = new Vector();         
     ResourceUsage resourceusage = null;
     MapList mapConfigurationStructure = new MapList();
     
      if( strMode.equalsIgnoreCase("createResourceUsage") ){

    	  strResourceId = emxGetParameter(request, "RuleId");
    	  strResourceId =  strResourceId.trim();

    	  /* To obtain the Id of the product to which this resource is connected to */
    	  StringList objSelects =new StringList(1);
    	  objSelects.add(ConfigurationConstants.SELECT_ID);
    	  
    	  StringList relSelects = new StringList(1);
    	  relSelects.add(ConfigurationConstants.SELECT_RELATIONSHIP_ID);
    	  
    	  DomainObject domParentId = new DomainObject(strResourceId);
          StringBuffer sbTypePattern = new StringBuffer();
          sbTypePattern
                  .append(ConfigurationConstants.TYPE_CONFIGURATION_FEATURES);
          sbTypePattern.append(",");
          sbTypePattern
          .append(ConfigurationConstants.TYPE_LOGICAL_STRUCTURES);
          sbTypePattern.append(",");
          sbTypePattern
          .append(ConfigurationConstants.TYPE_PRODUCTS);
          sbTypePattern.append(",");
          sbTypePattern
          .append(ConfigurationConstants.TYPE_PRODUCT_LINE);
          sbTypePattern.append(",");
          sbTypePattern
          .append(ConfigurationConstants.TYPE_MODEL);
    	  String strObjPattern =sbTypePattern.toString();
    	  String strRelPattern = ConfigurationConstants.RELATIONSHIP_RESOURCE_LIMIT;
    	  MapList productMapList = new MapList();

    	  productMapList = domParentId.getRelatedObjects(context, strRelPattern, strObjPattern, objSelects, relSelects, true,true,  sRecurse,"", "");
    	  resourceusage= new ResourceUsage(strResourceId);
    	  // Prepare a MapList(mapConfigurationStructure) for all Feature/Options of all Products Connected to Resource Rule.
          for(int i = 0; i < productMapList.size(); i++)
          {
        	  strProductId = (String)( ((Map)productMapList.get(i)).get(ConfigurationConstants.SELECT_ID));
			  if(strProductId != null && !strProductId.equals("")){
        	   	MapList featureoptionMapList = resourceusage.getFeatureOptionsPairs(context,strProductId);
                mapConfigurationStructure.addAll(featureoptionMapList);
			}
          }
    	  
      }else if( strMode.equalsIgnoreCase("AssignResourceUsage") ){
    	 if (arrRowIds.length !=1 ){
    	         %>
    	         <script language="javascript" type="text/javaScript">
    	         var msg = "<%=i18nNow.getI18nString("emxProduct.Alert.SelectOne",bundle,acceptLanguage)%>";
    	         alert(msg);
    	         getTopWindow().closeWindow();
    	         </script>
    	        <%} 
    	 else{
    	        Hashtable objectIds = new Hashtable(2);
    	        objectIds = (Hashtable)ProductLineUtil.getObjectIdsRelIds(arrRowIds);
    	        String[] arrRelIds=(String[])(objectIds).get("RelId");
    	        String[] arrObjIds=(String[])(objectIds).get("ObjId");
    	        
    	        StringList strSelect = new StringList(DomainConstants.SELECT_CURRENT);
    	        strSelect.add(DomainConstants.SELECT_POLICY);
    	        
    	        String sObjIds = arrObjIds[0];
    	        StringTokenizer strTokenizer = new StringTokenizer(sObjIds , "|");
    	        String strRuleID = (String)strTokenizer.nextToken();
    	        DomainObject domRuleId = DomainObject.newInstance(context,strRuleID);
    	        Map mapTemp = domRuleId.getInfo(context, strSelect);
    	        
    	        String strCurrentState = (String)mapTemp.get(DomainConstants.SELECT_CURRENT);
    	        String strPolicy = (String)mapTemp.get(DomainConstants.SELECT_POLICY);
    	        
    	        String strRelease = FrameworkUtil.lookupStateName(context, strPolicy, "state_Release");

    	        if (strCurrentState.equalsIgnoreCase(strRelease)){
    	            %>
    	            <script language="javaScript">
    	            var msg = "<%=i18nNow.getI18nString("emxProduct.Alert.RuleinRelease",bundle,acceptLanguage)%>";
    	            alert(msg);
    	            getTopWindow().closeWindow();
    	            </script>
    	            <%
    	            return;
    	        }else{
    	            /* Indirect Mode will have the Product Id as the request parameter objectId */
    	            strProductId = emxGetParameter(request, "objectId");
    	            strResourceId = strRuleID;
    	            objectId = strProductId;
    	            String objectType = (UINavigatorUtil.getParsedHeaderWithMacros(context,acceptLanguage,"TYPE",objectId)).trim();   
    	 			resourceusage= new ResourceUsage(strResourceId);
					if(strProductId != null && !strProductId.equals("")){
							 mapConfigurationStructure=resourceusage.getFeatureOptionsPairs(context,strProductId);
	    	       	}
    	        }
    	   }
    	 
   
        }
    	      
      
      String strFO="";
      for(int i=0;i<mapConfigurationStructure.size();i++)
      {
          String strRelId =(String)((Map)mapConfigurationStructure.get(i)).get(ConfigurationConstants.SELECT_RELATIONSHIP_ID);
          String strNameO = (String)((Map)mapConfigurationStructure.get(i)).get("attribute["+ConfigurationConstants.ATTRIBUTE_DISPLAY_NAME+"]");
          String strToName = (String)((Map)mapConfigurationStructure.get(i)).get(ConfigurationConstants.SELECT_NAME);
          String strFromName = (String)((Map)mapConfigurationStructure.get(i)).get(ConfigurationConstants.SELECT_FROM_NAME);
          String fromMarketingName=(String)((Map)mapConfigurationStructure.get(i)).get("from."+ ConfigurationConstants.SELECT_ATTRIBUTE_MARKETING_NAME);
          String fromDisplayName=(String)((Map)mapConfigurationStructure.get(i)).get("from."+ ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME);
          String strNameF=fromMarketingName;
          if(strNameF==null ||strNameF.trim().isEmpty() )
        	  strNameF=fromDisplayName;
          strRelId =  strRelId.trim();
          int ruleDisplay=RuleProcess.getRuleDisplaySetting(context);
          //For Fixing IR-240758V6R2014x ,Used XSSUtil.encodeForURL() for strFromName ,strToName ,strNameF and strNameO
          if(ruleDisplay==RuleProcess.RULE_DISPLAY_FULL_NAME){
        	  strFO = XSSUtil.encodeForURL(context,strFromName) + " ~ " +XSSUtil.encodeForURL(context,strToName) ;
          }else{
        	  strFO = XSSUtil.encodeForURL(context,strNameF) + " ~ " + XSSUtil.encodeForURL(context,strNameO);  
          }        	  
          
          vctDetails.add(strFO);
          vctRelIDs.add(strRelId);
      }
    	         
      String strRelIds ="";
      for(int u=0;u<vctRelIDs.size();u++){
    	  strRelIds += strRelIds.equals("")?(String)vctRelIDs.get(u):","+(String)vctRelIDs.get(u);          
      } 
      
      String strDetails ="";
      for(int u=0;u<vctDetails.size();u++){
    	  strDetails += strDetails.equals("")?(String)vctDetails.get(u):","+(String)vctDetails.get(u);
      } 
      
      
    /* Prepare a String List of the selection choices of the Resource Usage Relation*/
     String languageStr = request.getHeader("Accept-Language");
     
     AttributeType atrrType = new AttributeType(ConfigurationConstants.ATTRIBUTE_RESOURCE_OPERATION);
     atrrType.open(context);
     StringList sLOperation = atrrType.getChoices();
     String[] strArr = new String[sLOperation.size()];     
     
     String strOperation = "";     
     for(int m=0;m<sLOperation.size();m++){
    	 strOperation += strOperation.equals("")?(String)sLOperation.get(m):","+(String)sLOperation.get(m);
     }
     
     atrrType.close(context);
    	                
     if( vctRelIDs.size()==0){
             %>
             <script>
             var msg = "<%=i18nNow.getI18nString("emxProduct.Alert.NoFeatureOptionParis",bundle,acceptLanguage)%>";
             alert(msg);
             getTopWindow().window.closeWindow();
            </script>
       <%}



/* boolean, set to true, incase of any error */
	boolean bFlag=false;
/* Resource Id to connect the Feature List to the Fixed Resource */
	
      //String[] vctDetails = emxGetParameterValues(request, "Details"); //not referenced or used      
      String tempRelIds = strRelIds;      
      String[] RelIds = null; 
      if(tempRelIds != null && tempRelIds.length() > 0){
    	  RelIds = tempRelIds.split(",");    	  
      }      

      String tempOperation = strOperation;      
      String[] sArrOperation = null; 
      if(tempOperation != null && tempOperation.length() > 0){
    	  sArrOperation = tempOperation.split(",");    	  
      }     
      
      //String[] arrRowIds = emxGetParameterValues(request, "emxTableRowId"); //not referenced or used
      String strRuleId = strResourceId;
      
      resourceusage= new ResourceUsage(strRuleId);
      mapConfigurationStructure=resourceusage.getFeatureOptionPairsEncoded(context,RelIds);
      
      /* Prepare a String List of the selection choices of the Resource Usage Relation*/      
      sLOperation= new StringList();
      if(sArrOperation != null && sArrOperation.length > 0){
      	  List lOperation =Arrays.asList(sArrOperation);
      	sLOperation.addAll(lOperation);
      }      

      languageStr = request.getHeader("Accept-Language");
      StringList sLI18NOperation=new StringList(3);
      sLI18NOperation=(i18nNow.getAttrRangeI18NStringList(ConfigurationConstants.ATTRIBUTE_RESOURCE_OPERATION,sLOperation,languageStr));            
   %>
  

<form method="post" name="ResourceUsage" onsubmit="submitForm(); return false">
   <%@include file="../common/enoviaCSRFTokenInjection.inc" %>
   
   <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <tr>
     <td width="150" class="labelRequired"><emxUtil:i18n localize="i18nId"> emxProduct.Table.FeatureOptionName </emxUtil:i18n> </td>
     <td class="inputField"><select name="selFOPair">
        <% for(int i=0;i<mapConfigurationStructure.size();i++)
         { Map mp= (Map)mapConfigurationStructure.get(i);
         String relID= (String)mp.get(DomainConstants.SELECT_ID);
         String fromMarketingName= (String)mp.get("from."
                 + ConfigurationConstants.SELECT_ATTRIBUTE_MARKETING_NAME);
         String toMarketingName= (String)mp.get("to."
                 + ConfigurationConstants.SELECT_ATTRIBUTE_MARKETING_NAME);
         String fromDisplayName= (String)mp.get("from."
                 + ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME);
         String toDisplayName= (String)mp.get("to."
                 + ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME);

         String strFromName= (String)mp.get("from."
                 + ConfigurationConstants.SELECT_NAME);
         String strToName= (String)mp.get("to."
                 + ConfigurationConstants.SELECT_NAME);

         String strNameF=fromMarketingName;
         if(strNameF==null ||strNameF.trim().isEmpty() )
             strNameF=fromDisplayName;
         String strNameO=toMarketingName;
         if(strNameO==null ||strNameO.trim().isEmpty() )
        	 strNameO=toDisplayName;
         int ruleDisplay=RuleProcess.getRuleDisplaySetting(context);
         strFO="";
         if(ruleDisplay==RuleProcess.RULE_DISPLAY_FULL_NAME){
             strFO = strFromName + " ~ " +strToName ;
         }else{
             strFO = strNameF + " ~ " + strNameO;  
         }
         %>
          <option value= "<xss:encodeForHTMLAttribute><%=relID%></xss:encodeForHTMLAttribute>" > <%=XSSUtil.encodeForHTML(context,strFO)%></option>
        <%}%>
        </select></td>
    </tr>

    <tr>
      <td width="150" class="labelRequired"> <emxUtil:i18n localize="i18nId"> emxProduct.Table.Usage </emxUtil:i18n> </td>
      <td class="inputField"><input type="text" size="20" value="" name="txtUsage"/></td>
    </tr>

    <tr>
      <td width="150" class="labelRequired"><emxUtil:i18n localize="i18nId"> emxProduct.Dialog.Label.ResourceOperation </emxUtil:i18n></td>
      <td class="inputField">
      <table border="0">
    </tr>

    <tr>
      <%for(int j=0;j<sLI18NOperation.size();j++){
        if(j==0){%>
        <tr>
           <td><input type="radio" name="radOperation" value="<xss:encodeForHTMLAttribute><%=sArrOperation[j]%></xss:encodeForHTMLAttribute>" checked /> <%=sLI18NOperation.get(j)%></td>
        </tr>
      <%}else{%>
        <tr>
          <td><input type="radio" name="radOperation"  value= "<xss:encodeForHTMLAttribute><%=sArrOperation[j]%></xss:encodeForHTMLAttribute>" /> <%=sLI18NOperation.get(j)%></td>
        </tr>
       <%}
      }%>
      </table>
     </td>
    </tr>
  </table>

      <input type="hidden" size="20" value="" name="ObjId"></input>
      <!-- NextGen UI Adoption : Commented below image-->
      <!-- Modified for removing unnecessary link on Page  -->
      <!-- <input type="image" value="" height="1" width="1" border="0" />  -->
      </form>

<script language = "JavaScript" >
//When Enter Key Pressed on the form
   function submitForm()
   {
    submit();
   }
  function submit()
 {
    var formName = document.ResourceUsage;
    var iValidForm = functionValidate();
    if (!iValidForm) {
        return;
    }
    
    var vResourceId ="<%=XSSUtil.encodeForJavaScript(context,strResourceId)%>";
    formName.ObjId.value = vResourceId;
    var vResourceId = formName.ObjId.value;
    formName.action = "../configuration/AssignResourceUsagePostProcess.jsp?mode=create&PRCFSParam1=Product&RuleId="+vResourceId;
    formName.submit();
 }

  function functionValidate()
  {
   var msg = "";
   var formName = document.ResourceUsage;  
   var fieldName = "<%=i18nNow.getI18nString("emxProduct.Table.Usage", bundle,acceptLanguage)%> ";
   var field = formName.txtUsage;
   var iValidForm = true;
   
   if (iValidForm) {
         iValidForm = basicValidation(formName,field,fieldName,true,true,false,false,false,false,false);
   }

   if (iValidForm){
         iValidForm = basicValidation(formName,field,fieldName,false,false,false,true,false,false,false);
   }

   return iValidForm
  }

  function closeWindow(){
      parent.window.closeWindow();
  }     
</script>



<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

<%
// In case of any type of error, display the error message

if (bFlag)
{%>
    <script language="javascript" type="text/javaScript">
    //hide JavaScript from non-JavaScript browsers
    history.back();
    </script>

<%} // End of if
}
catch(Exception e)
{
	   //This alert message is for Mode "createResourceUsage" hence the check added. 
	  if(strMode.equalsIgnoreCase("createResourceUsage") && (strProductId.equalsIgnoreCase("") || strProductId.length()<=0 || "".equalsIgnoreCase(strProductId))){
	  %>
	     <script>
	       var msg = "<%=i18nNow.getI18nString("emxProduct.Alert.NoProductInProductLine",bundle,acceptLanguage)%>";
	       alert(msg);
	       getTopWindow().window.closeWindow();
	     </script>
	  <%}
   else {
 	   e.printStackTrace();
	       String strAlertString = "emxProduct.Alert." + e.getMessage();
	       String i18nErrorMessage = i18nNow.getI18nString(strAlertString,bundle,acceptLanguage);
	       if(i18nErrorMessage.equals(DomainConstants.EMPTY_STRING)){
	    	    session.putValue("error.message", e.getMessage());
	       }else{
	    	   session.putValue("error.message", i18nErrorMessage);
	      }
	  }
}%> 


