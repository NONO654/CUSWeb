<%-- RuleDialogCommonInclude.inc
Copyright (c) 1992-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of MatrixOne,
Inc.  Copyright notice is precautionary only and does not evidence any actual
or intended publication of such program.
--%>

<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import = "com.matrixone.apps.configuration.RuleProcess"%>
<%@page import = "com.matrixone.apps.domain.util.XSSUtil"%>

<%@page import = "com.matrixone.apps.domain.util.i18nNow"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="matrix.util.List"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import = "matrix.util.StringList"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>
<%@page import="matrix.db.JPO"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<%String strRuleDialogTitle = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Label.Rule_Dialog",request.getHeader("Accept-Language"));%>

 <title><%=strRuleDialogTitle%></title>
        
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css"/>
        <link rel="stylesheet" type="text/css" media="screen" href="styles/emxUIRuleLayerDialog.css" />
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIToolbar.css"/>
        <link rel="stylesheet" type="text/css" href="styles/emxUIExpressionBuilder.css"/>
        <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDialog.css"/>
       
       <script language="javascript" src="../common/scripts/emxUICore.js"></script>    
       <script language="javascript" src="../emxNavigatorInclude.inc"></script>
       <script language="JavaScript" type="text/javascript" src="../common/emxUIConstantsJavaScriptInclude.jsp"></script>
       <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
       <script language="javascript" src="../configuration/scripts/emxUIFeatureSelectableTree.js"></script>   
       <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
       <script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
    
<SCRIPT language="javascript" src="./scripts/RuleDialogCommonOperations.js"></SCRIPT>
<script language="javascript" src="../configuration/scripts/HashMap.js"></script>

 <%!
  private static final String ID = DomainConstants.SELECT_ID;
%>

<%
    
    String Directory = emxGetParameter(request,"SuiteDirectory");
    String SuiteKey = emxGetParameter(request,"suiteKey");
  
    if( Directory == null || "".equals(Directory) || "null".equals(Directory) ){
      Directory = emxGetParameter(request,"Directory");
    }
    
    String langStr = request.getHeader("Accept-Language");
    String lStr = i18nNow.getI18nString("emxFramework.HelpDirectory","emxFrameworkStringResource", langStr);
    if(lStr == null || "".equals(lStr)){
        lStr = "en";
    }
    String langOnlineStr = i18nNow.getI18nString("emxFramework.OnlineXML.HelpDirectory", "emxFrameworkStringResource", langStr);
    if (langOnlineStr == null || "".equals(langOnlineStr)) {
        langOnlineStr = "English";
    }
    
     String strSubmitRule = emxGetParameter(request, "submitURL");
     String strCmdName = emxGetParameter(request,"commandName");
     String strMode = emxGetParameter(request,"modetype");
     String strRowLevel = emxGetParameter(request,"rowLevel");
     String strCntxtObjId = emxGetParameter(request,"objectId");
     String strParOID = emxGetParameter(request,"parentOID");
     String strRelId = emxGetParameter(request,"relId");
     String strRulType = emxGetParameter(request,"ruleType");
     //if GBOM or Feature inclusion Rule
     String strContext = emxGetParameter(request,"context");
     
    
     String strDescriptionValue = "";
     String strErrorMessageValue = "";
     String strRuleClassification = "";
     String strDesignResponsibilty = "";
     String strDesignResponsibiltyID="";
     String strRuleDisplay = "";
     String strContextObjectId = "";
     String strContextObjectIdPass = "";
     String strDefaultPolicy = "";
     String strRuleName = "";
     Map mRuleInfo = new HashMap();
    
     int itemp = 0  ;
     String[] strPolicies = new String[10];
     
     String strRuleId = "";
     String strLEText = "";
     String strLEValue = "";
     String strREText = "";
     String strREValue = "";
     String strparentOID ="";
     String strLEFeatTypeValue = "";
     String strREFeatTypeValue = "";
     
     com.matrixone.apps.configuration.RuleProcess ruleProcess = new com.matrixone.apps.configuration.RuleProcess();
    
    //Get the name of the context object id and name.
    if ((strMode.compareTo("create")==0)){
        strContextObjectId  = emxGetParameter(request,"objectId");
        //try
        if(strRulType.equalsIgnoreCase("InclusionRule") && strContext!=null && strContext.equalsIgnoreCase("GBOM")){
            //context ID will be its parent ID(LF/PRD)-----
            strContextObjectId  = emxGetParameter(request,"parentOID");
        }
        strparentOID  = emxGetParameter(request,"parentOID");
    }
    
    if ((strMode.compareTo("edit")==0)){
        //try
        
        if(strRulType.equalsIgnoreCase("InclusionRule") && strContext==null){
            //context ID will be its parent ID(LF/PRD)-----
            strContextObjectId  = emxGetParameter(request,"objectId");
        }else if(strRulType.equalsIgnoreCase("InclusionRule") && strContext!=null && strContext.equalsIgnoreCase("GBOM")){
            strContextObjectId  = emxGetParameter(request,"parentOID");
        }else{
            strContextObjectId  = emxGetParameter(request,"parentOID");
        }
        strparentOID  = emxGetParameter(request,"parentOID");
    }
    if ((strMode.compareTo("copy")==0)){
         strContextObjectId  = emxGetParameter(request,"productID");             
         strContextObjectIdPass  = emxGetParameter(request,"productID");
         strparentOID  = emxGetParameter(request,"productID");         
    }
      
       %>
       <SCRIPT LANGUAGE="JavaScript">
          var DVValuesAddedMap = new jsHashMap();
       </SCRIPT>
        <%
    String strObjId = "";
    
    if((strMode.compareTo("edit")==0)||(strMode.compareTo("copy")==0) ){

       //Need to check whether it "Rule Id" or not
       if(strCntxtObjId!=null){
       
       DomainObject domBCR = new DomainObject(strCntxtObjId);
       String strCntxtObjType  = domBCR.getInfo(context,DomainConstants.SELECT_TYPE);
       
       if(mxType.isOfParentType(context,strCntxtObjType,ConfigurationConstants.TYPE_RULE)){

          strObjId = emxGetParameter(request,"objectId");
         }
         else{
          strObjId  = emxGetParameter(request,"ruleId");
         }
         
         if(strObjId==null)
         strObjId = emxGetParameter(request,"iRuleId");
         
       }
       
       if(strObjId!=null && strObjId.length()!=0){
           //Get LE and RE details
        mRuleInfo = ruleProcess.getRuleBasicDetails(context,strObjId,strRelId);
        

strRuleClassification = (String) mRuleInfo.get("Rule Classification");
        String strLeftExpressionForEdit = (String) mRuleInfo.get("Left Expression");
        mRuleInfo.put("attribute["+ConfigurationConstants.ATTRIBUTE_LEFT_EXPRESSION+"]",strLeftExpressionForEdit);
        if(strMode.compareTo("copy")==0)
         strLeftExpressionForEdit= ruleProcess.getExpressionsForRuleCopy(strLeftExpressionForEdit);
        
        String strRightExpressionForEdit = (String) mRuleInfo.get("Right Expression");
        mRuleInfo.put("attribute["+ConfigurationConstants.ATTRIBUTE_RIGHT_EXPRESSION+"]",strRightExpressionForEdit);
        if(strMode.compareTo("copy")==0)
         strRightExpressionForEdit= ruleProcess.getExpressionsForRuleCopy(strRightExpressionForEdit);
        
        //strDesignResponsibilty = (String) mRuleInfo.get("to["+ ConfigurationConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.name");
        strDesignResponsibilty = (String) mRuleInfo.get("altowner1");
        strDesignResponsibiltyID = (String) mRuleInfo.get("to["+ ConfigurationConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY+"].from.id");
        mRuleInfo.put("Design Responsibility",strDesignResponsibilty);
        //mRuleInfo.put("Design Responsibility ID",strDesignResponsibiltyID);
        strRuleId =  (String) mRuleInfo.get(DomainConstants.SELECT_ID);
        String strRuleRev =  (String) mRuleInfo.get(DomainConstants.SELECT_REVISION);
        String strRuleRelId =  (String) mRuleInfo.get(DomainConstants.SELECT_RELATIONSHIP_ID);
        strRuleName =  (String) mRuleInfo.get(DomainConstants.SELECT_NAME);   

     
        if(mRuleInfo.size()>0){
            Iterator itrd = mRuleInfo.entrySet().iterator();
            while (itrd.hasNext()){
        
            //Code to get Keys
            Map.Entry pairs = (Map.Entry) itrd.next();
            String divIds = (String) pairs.getKey(); 
        
            //Code to get values
            String divIdsValue = (String) pairs.getValue();
            if(divIdsValue!=null)
            {
                divIdsValue = ConfigurationUtil.putEscapeCharacter(divIdsValue);
                //MapList mapList2MapList = (MapList) pairs.getValue();
                
                if(divIdsValue.length()==0)
                {
                //changed null to empty string for IR-141864V6R2013
                   divIdsValue = "";
                }
            }

           %>         
            <SCRIPT LANGUAGE="JavaScript">
                DVValuesAddedMap.put("<%=divIds%>" ,"<%=divIdsValue%>" );
            </SCRIPT>
            
           <%
          }
        }
        
        MapList objectList = new MapList();
        objectList.add(mRuleInfo);
        
        Map programMap = new HashMap();
        programMap.put("objectList",objectList);
        
        String[] arrJPOArgs = (String[])JPO.packArgs(programMap);
        StringList strLeftExpressionList = (StringList)ruleProcess.getExpressionForEditRuleDisplay(context, arrJPOArgs,ConfigurationConstants.ATTRIBUTE_LEFT_EXPRESSION);
        StringList strRightExpressionList = (StringList)ruleProcess.getExpressionForEditRuleDisplay(context, arrJPOArgs,ConfigurationConstants.ATTRIBUTE_RIGHT_EXPRESSION);
                
        if(!strLeftExpressionList.isEmpty()){
        strLEText = (String)strLeftExpressionList.get(0);
        strLEFeatTypeValue = (String)strLeftExpressionList.get(1);
        strLEValue = strLeftExpressionForEdit;
        }
        
        if(!strRightExpressionList.isEmpty()){
        strREText = (String)strRightExpressionList.get(0);
        strREFeatTypeValue = (String)strRightExpressionList.get(1);
        strREValue = strRightExpressionForEdit;
        }
     }
    }

    String strLocale = context.getSession().getLanguage();

    //For subtitle
    
    DomainObject domObj=null;  
    
        String strContextType   =""; 
        String strContextNameForIR   ="";  
    //either Part -in case of GBOM IR/LF- in other case
    if(strRulType.equalsIgnoreCase("InclusionRule") && strContext!=null && strContext.equalsIgnoreCase("GBOM")){
        String partID  = emxGetParameter(request,"objectId");
        domObj= DomainObject.newInstance(context,strContextObjectId);
        strContextType=domObj.getInfo(context,DomainConstants.SELECT_TYPE);
        domObj= DomainObject.newInstance(context,partID);
        
        strContextNameForIR=RuleProcess.getDisplayExpression(context,partID,null).toString();
    }if(strRulType.equalsIgnoreCase("InclusionRule") && strContext==null){
        domObj= DomainObject.newInstance(context,strContextObjectId);
        //strContextNameForIR=domObj.getInfo(context,DomainConstants.SELECT_TYPE)+" "+domObj.getInfo(context,DomainConstants.SELECT_NAME) +" "+domObj.getInfo(context,DomainConstants.SELECT_REVISION);
        strContextNameForIR=RuleProcess.getDisplayExpression(context,strContextObjectId,null).toString();
        strContextType=domObj.getInfo(context,DomainConstants.SELECT_TYPE);
    }
    else{
        domObj= DomainObject.newInstance(context,strContextObjectId);
        strContextType=domObj.getInfo(context,DomainConstants.SELECT_TYPE);
    }
    //----------------
    StringList slObjSel = new StringList(ConfigurationConstants.SELECT_NAME);
    slObjSel.add(ConfigurationConstants.SELECT_TYPE);
    slObjSel.add(ConfigurationConstants.SELECT_ATTRIBUTE_MARKETING_NAME);
    slObjSel.add(ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME);
    slObjSel.add(ConfigurationConstants.SELECT_REVISION);
    String strMarketingName=""; 
    Map contextNameMap = domObj.getInfo(context, slObjSel);
    if (contextNameMap.containsKey(ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME))
       strMarketingName = (String) contextNameMap.get(ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME);
    if (strMarketingName == null || strMarketingName.trim().isEmpty())
       strMarketingName = (String) contextNameMap.get(ConfigurationConstants.SELECT_ATTRIBUTE_MARKETING_NAME);
    String strContextRevision= (String) contextNameMap.get(ConfigurationConstants.SELECT_REVISION);
    String strContextName= (String) contextNameMap.get(ConfigurationConstants.SELECT_NAME);
    
    //----------------
    //String strContextRevision = domObj.getRevision(context);
   //String strContextType   = domObj.getInfo(context,DomainConstants.SELECT_TYPE);  
   // String strContextName   = domObj.getInfo(context,DomainConstants.SELECT_NAME);  

    //To display type, Name and Rev in Context field of Feature Selector
    String language = context.getSession().getLanguage();
    i18nNow i18Object = new i18nNow();
     
    String strContextTypeName ="";
    if(strContextType.indexOf(" ") > 0){
        strContextTypeName = strContextType.replaceAll(" ","_");
    }else{
        strContextTypeName = strContextType;
    }
    
     StringBuffer sbTempForContext = new StringBuffer();
    //String i18ObjectType=EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Type."+strContextTypeName,language);
    String i18ObjectType=ConfigurationUtil.geti18FrameworkString(context,strContextTypeName);
    int ruleSetting1 = RuleProcess.getRuleDisplaySetting(context);
    if (ruleSetting1 == RuleProcess.RULE_DISPLAY_FULL_NAME) {
        sbTempForContext = sbTempForContext.append(i18ObjectType)
                   .append("::")
                   .append(strContextName)
                   .append("::")
                   .append(strContextRevision);
    
    }else if (ruleSetting1 == RuleProcess.RULE_DISPLAY_MARKETING_NAME) {
        sbTempForContext = sbTempForContext.append(strMarketingName);
    
    }else if (ruleSetting1 == RuleProcess.RULE_DISPLAY_MARKETING_NAME_REV) {
        sbTempForContext = sbTempForContext.append(strMarketingName)
                   .append(" ")
                   .append(strContextRevision);
    
    }
    String strContextNameDispaly = sbTempForContext.toString();
    
    DomainObject domObjPar = DomainObject.newInstance(context,strparentOID);
    
    StringList slObjSel2 = new StringList(ConfigurationConstants.SELECT_NAME);
    slObjSel2.add(ConfigurationConstants.SELECT_TYPE);
    slObjSel2.add(ConfigurationConstants.SELECT_ATTRIBUTE_MARKETING_NAME);
    slObjSel2.add(ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME);
    slObjSel2.add(ConfigurationConstants.SELECT_REVISION);
    String strMarketingName1=""; 
    Map contextNameMap2 = domObjPar.getInfo(context, slObjSel2);
    if (contextNameMap2.containsKey(ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME))
       strMarketingName1 = (String) contextNameMap2.get(ConfigurationConstants.SELECT_ATTRIBUTE_DISPLAY_NAME);
    if (strMarketingName1 == null || strMarketingName1.trim().isEmpty())
       strMarketingName1 = (String) contextNameMap2.get(ConfigurationConstants.SELECT_ATTRIBUTE_MARKETING_NAME);
    String strContextParentType =  (String) contextNameMap2.get(ConfigurationConstants.SELECT_TYPE);
    String strContextParentRevision= (String) contextNameMap2.get(ConfigurationConstants.SELECT_REVISION);
    String strContextParentActualName= (String) contextNameMap2.get(ConfigurationConstants.SELECT_NAME);
    
    String strContextParentTypeName ="";
    if(strContextParentType.indexOf(" ") > 0){
       strContextParentTypeName = strContextParentType.replaceAll(" ","_");
    }else{
        strContextParentTypeName = strContextParentType;
    }
    
    
    String i18ParentObjectType=EnoviaResourceBundle.getProperty(context,"Framework","emxFramework.Type."+strContextParentTypeName,language);
    StringBuffer sbTemp = new StringBuffer();
    int ruleSetting = RuleProcess.getRuleDisplaySetting(context);
    if (ruleSetting == RuleProcess.RULE_DISPLAY_FULL_NAME) {
        sbTemp = sbTemp.append(i18ParentObjectType)
                   .append("::")
                   .append(strContextParentActualName)
                   .append("::")
                   .append(strContextParentRevision);
    
    }else if (ruleSetting == RuleProcess.RULE_DISPLAY_MARKETING_NAME) {
        sbTemp = sbTemp.append(strMarketingName1);
    
    }else if (ruleSetting == RuleProcess.RULE_DISPLAY_MARKETING_NAME_REV) {
        sbTemp = sbTemp.append(strMarketingName1)
                   .append(" ")
                   .append(strContextParentRevision);
    
    }
    String strContextParentNameDispaly = sbTemp.toString();

    // get the vault 
    matrix.db.Vault defaultVault=context.getVault();
    String formattedDefaultVault=i18nNow.getI18NVaultNames(context, defaultVault.toString(),request.getHeader("Accept-Language") );

    String strName = ""; 
    String strRightExpressionValue = "";
    String strLeftExpIDs = "";
    String strTempLeftExp = "";
    String strRightExpIDs = "";
    String strTempRightExp = "";
    String strEditRDO = "";
    String strEditVault = "";
    String formattedstrEditVault = "";
    
    StringBuffer sbHeading = new StringBuffer("");
    sbHeading.append("emxProduct.Label");
    sbHeading.append(".");
    sbHeading.append(strMode);
    sbHeading.append(".");
    sbHeading.append(strRulType);
    String strHeading = sbHeading.toString();
    
    
    StringBuffer sbSubHeading = new StringBuffer("");
    sbSubHeading.append("emxProduct.Label");
    sbSubHeading.append(".");
    sbSubHeading.append("subHeading");
    sbSubHeading.append(".");
    sbSubHeading.append(strRulType);
    String strSubHeading = sbSubHeading.toString();
    
    String strRuleHeading = EnoviaResourceBundle.getProperty(context,"Configuration",strHeading, request.getHeader("Accept-Language"));
    String strRuleSubHeading = EnoviaResourceBundle.getProperty(context,"Configuration",strSubHeading, request.getHeader("Accept-Language"));    

    String strBasicsHeader = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Label.Basics", request.getHeader("Accept-Language"));
    String strFeatureSelectorHeader =EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Label.FeatureSelector", request.getHeader("Accept-Language"));
    
    if(strCmdName!=null && strCmdName.equals("FTRProductCompatibilityRuleSettings")){
        strFeatureSelectorHeader = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Label.ProductSelector", request.getHeader("Accept-Language"));
    }
    
    String strContextNameForDisp = "" ;
    strContextNameForDisp = strContextName;  
    
    
    
    
    //Processing to get the Command Setting values.
    String strURL= "";
    Map mCommandSettings = ruleProcess.getAllCommandSettings(context, strCmdName);
    
    //Default Settings provided by Rule Component
    ArrayList arrCommandSettings = new ArrayList(5);
    arrCommandSettings.add(0, "Basics");
    arrCommandSettings.add(1, "ValidationForBasics");
    
    arrCommandSettings.add(2, "Context Selector");
    arrCommandSettings.add(3, "ValidationForContextSelector");
    
    arrCommandSettings.add(4, "Left Expression");
    arrCommandSettings.add(5, "ValidationForLeftExpression");
    
    arrCommandSettings.add(6, "Comparison Operator");
    arrCommandSettings.add(7, "ValidationForComparisonOperator");
    
    arrCommandSettings.add(8, "Right Expression");
    arrCommandSettings.add(9, "ValidationForRightExpression");
    
    arrCommandSettings.add(10, "Completed Rule");
    arrCommandSettings.add(11, "ValidationForCompletedRule");
    
    Map mJSPPageValues = new HashMap();
    for(int i=0; i<arrCommandSettings.size(); i++)
    {
      String strSettingName = (String)arrCommandSettings.get(i);
      Map mJSPPageValue = ruleProcess.getJSPPageNameFromSettings(context,mCommandSettings,strSettingName);
      mJSPPageValues.putAll(mJSPPageValue);
    }
    
   // getting the querystring for passing to all JSP components
   StringBuffer sQueryString = new StringBuffer("");
   StringBuffer sQueryStringForBasics = new StringBuffer("");
   StringBuffer sQueryStringForContxtSel = new StringBuffer("");
   StringBuffer sQueryStringForLE = new StringBuffer("");
   StringBuffer sQueryStringForCompOper = new StringBuffer("");
   StringBuffer sQueryStringForRE = new StringBuffer("");
   StringBuffer sQueryStringForCompletedRule = new StringBuffer("");
   
   
   Enumeration eNumParameters = emxGetParameterNames(request);
   while( eNumParameters.hasMoreElements() ) {
   String strParamName = (String)eNumParameters.nextElement();
   String strParamValue = emxGetParameter(request, strParamName);
   if(!strParamName.equals("calcAlert") && !strParamName.equals("chartAlert"))
      sQueryString.append("&" + strParamName + "=" + strParamValue);
   }
   
   sQueryString.append("&ContextType=" + strContextType);
   sQueryString.append("&ContextParentType=" + strContextParentType);
   
   sQueryString.append("&ContextName=" + XSSUtil.encodeForURL(context,strContextNameDispaly));
   sQueryString.append("&ContextParentNameDispaly=" + XSSUtil.encodeForURL(context,strContextParentNameDispaly));
   
   sQueryStringForBasics.append(sQueryString);
   sQueryStringForBasics.append("&description=" + strDescriptionValue);
   sQueryStringForBasics.append("&errorMessage=" + strErrorMessageValue);
   sQueryStringForBasics.append("&ruleClassification=" + strRuleClassification);
   sQueryStringForBasics.append("&designResponsibility=" + strDesignResponsibilty);
   sQueryStringForBasics.append("&name=" + com.matrixone.apps.domain.util.XSSUtil.encodeForURL(context,strRuleName));
   
   sQueryStringForBasics.append("&validation=" + (String)mJSPPageValues.get("strValidationForBasics"));
   
   sQueryStringForContxtSel.append("&ruleClassification=" + strRuleClassification);
   sQueryStringForContxtSel.append("&validation=" + (String)mJSPPageValues.get("strValidationForContextSelector"));
   sQueryStringForContxtSel.append(sQueryString);
   
   sQueryStringForLE.append("&validation=" + (String)mJSPPageValues.get("strValidationForLeftExpression"));
   sQueryStringForLE.append(sQueryString);
   
   sQueryStringForCompOper.append("&validation=" + (String)mJSPPageValues.get("strValidationForComparisonOperator"));
   sQueryStringForCompOper.append(sQueryString);
     
   sQueryStringForRE.append("&validation=" + (String)mJSPPageValues.get("strValidationForRightExpression"));
   sQueryStringForRE.append(sQueryString);
   
   sQueryStringForCompletedRule.append("&validation=" + (String)mJSPPageValues.get("strValidationForCompletedRule"));
   sQueryStringForCompletedRule.append(sQueryString);
   
   String strQueryString = sQueryString.toString();
   
   String strSubmitRuleJS = (String)mJSPPageValues.get("strValidationForCompletedRule");
   
%>

<SCRIPT language="javascript" src="./scripts/<%=strSubmitRuleJS%>"></SCRIPT>
<script type="text/javascript" language="javascript">
 
   var vMode = "<xss:encodeForJavaScript><%=strMode %></xss:encodeForJavaScript>";
    
   function displayExp()
   {
     if(document.getElementById('hleftExpObjIdsForEdit')!=null){
       displayLeftExp();
     }
     
      if(document.getElementById('hrightExpObjIdsForEdit')!=null){
       displayRightExp();
     }
   } 
   //Set the values for LE text box
   function displayLeftExp(){
     var leValue= "<xss:encodeForJavaScript><%=strLEValue%></xss:encodeForJavaScript>";
     leValue= leValue.trim();
     if((vMode=="edit" ||vMode=="copy") && !leValue==""){
      document.getElementById('hleftExpObjIdsForEdit').value = "<xss:encodeForJavaScript><%=strLEValue%></xss:encodeForJavaScript>";
      document.getElementById('hleftExpObjTxtForEdit').value = "<xss:encodeForJavaScript><%=strLEText%></xss:encodeForJavaScript>";

      document.getElementById('hleftExpFeatTypeVal').value = "<xss:encodeForJavaScript><%=strLEFeatTypeValue%></xss:encodeForJavaScript>";
      document.getElementById('hleftExpRCVal').value = "<xss:encodeForJavaScript><%=strRuleClassification%></xss:encodeForJavaScript>";
      
      formExp('left');
      }
    }
  if(typeof String.prototype.trim !== 'function') {
    String.prototype.trim = function() {
    return this.replace(/^\s+|\s+$/g, ''); 
    }
  }
    function displayRightExp(){
    var reValue= "<xss:encodeForJavaScript><%=strREValue%></xss:encodeForJavaScript>";
    reValue= reValue.trim();
       if((vMode=="edit" ||vMode=="copy") && !reValue==""){
       
        document.getElementById('hrightExpObjIdsForEdit').value = "<xss:encodeForJavaScript><%=strREValue%></xss:encodeForJavaScript>";
        document.getElementById('hrightExpObjTxtForEdit').value = "<xss:encodeForJavaScript><%=strREText%></xss:encodeForJavaScript>";

        document.getElementById('hrightExpFeatTypeVal').value = "<xss:encodeForJavaScript><%=strREFeatTypeValue%></xss:encodeForJavaScript>";
        document.getElementById('hrightExpRCVal').value = "<xss:encodeForJavaScript><%=strRuleClassification%></xss:encodeForJavaScript>";
        
        formExp('right','<%=XSSUtil.encodeForJavaScript(context,strRulType)%>');
      }
    }

</script>

<%
     String strUrlForBasics = "../"+XSSUtil.encodeForURL(context,Directory)+"/"+(String)mJSPPageValues.get("strBasics")+"?"+sQueryStringForBasics;
     String strUrlForContextSelector = "../"+XSSUtil.encodeForURL(context,Directory)+"/"+(String)mJSPPageValues.get("strContextSelector")+"?"+sQueryStringForContxtSel; 
     String strUrlForLeftExpression = "../"+XSSUtil.encodeForURL(context,Directory)+"/"+(String)mJSPPageValues.get("strLeftExpression")+"?"+sQueryStringForLE;
     String strUrlForComparisonOperator = "../"+XSSUtil.encodeForURL(context,Directory)+"/"+(String)mJSPPageValues.get("strComparisonOperator")+"?"+sQueryStringForCompOper;
     String strUrlForRightExpression = "../"+XSSUtil.encodeForURL(context,Directory)+"/"+(String)mJSPPageValues.get("strRightExpression")+"?"+sQueryStringForRE;
     String strUrlForCompletedRule = "../"+XSSUtil.encodeForURL(context,Directory)+"/"+(String)mJSPPageValues.get("strCompletedRule")+"?"+sQueryStringForCompletedRule;
     
     String strHelpCreateTopic="";
     String strHelpEditTopic ="";
     if(strRulType.equalsIgnoreCase("InclusionRule")) {
        strHelpCreateTopic = "emxhelpinclusionruleedit";
        strHelpEditTopic = "emxhelpinclusionruleedit";
     } else if (strRulType.equalsIgnoreCase("QuantityRule")) {
        strHelpCreateTopic = "emxhelpquantityrulecreate";
        strHelpEditTopic = "emxhelpquantityruleedit";
     } else if(strRulType.equalsIgnoreCase("BooleanCompatibilityRule")) {
        strHelpCreateTopic = "emxhelpbooleancreate";
        strHelpEditTopic = "emxhelpbooleancreate";
     }  else if(strRulType.equalsIgnoreCase("MarketingPreferenceRule")){
        strHelpCreateTopic = "emxhelpmarketingpreferencerulecreate";
        strHelpEditTopic = "emxhelpmarketingpreferencerulecreate";
     }  else if(strRulType.equalsIgnoreCase("ProductCompatibilityRule")){
        strHelpCreateTopic = "emxhelpglobalcompatrulecreate";
        strHelpEditTopic = "emxhelpglobalcompatruleedit";
     }
         
    %>

 </head>
  <body onload="selectorTable();mx_setHeight();displayExp();emptyRuleExpression('<%=XSSUtil.encodeForJavaScript(context,strMode)%>','<%=XSSUtil.encodeForJavaScript(context,strRulType)%>');getRuleBasics(DVValuesAddedMap,'<%=XSSUtil.encodeForJavaScript(context,strMode)%>');displayComputedRule('<%=XSSUtil.encodeForJavaScript(context,strMode)%>')">
   <form action="#" method="post" name="RuleForm" id="RuleForm">
   <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
    <div id="pageHeadDiv">
     <table>
        <tr>
       <td class="page-title">
          <h2><%=strRuleHeading%></h2>
          <%if(!strRulType.equalsIgnoreCase("InclusionRule")){%>
          <h3><%=strRuleSubHeading%><%=strContextNameForDisp + " " + strContextRevision%></h3>
          <%}else{%> 
          <h3><%=strRuleSubHeading%><%=strContextNameForIR%></h3>
          <%}%>
       </td>
            
       <td class="buttons">
        <table>
         <tr>
          <%if((strMode.compareTo("create")==0)){%>
           <td>
            <a href='javascript:openHelp("<%=XSSUtil.encodeForJavaScript(context,strHelpCreateTopic)%>","Configuration","<%=XSSUtil.encodeForJavaScript(context,lStr)%>","<%=XSSUtil.encodeForJavaScript(context,langOnlineStr)%>","<%=XSSUtil.encodeForJavaScript(context,SuiteKey)%>")'><img src="../common/images/iconActionHelp.gif" border="0" title="<emxUtil:i18n localize="i18nId">emxProduct.Heading.ContextualHelp</emxUtil:i18n>"/></a>
           </td>
             
           <td><div class="separator"></div></td>
          
           <td>
              <input type="button" name="done" value="<emxUtil:i18n localize="i18nId">emxProduct.Button.Done</emxUtil:i18n>" class="btn-primary" onClick="submitRule('create','<%=XSSUtil.encodeForJavaScript(context,strSubmitRule)%>'); return false" />
           </td>
             
           <td>
              <input type="button" name="cancel" value="<emxUtil:i18n localize="i18nId">emxProduct.Button.Cancel</emxUtil:i18n>" class="mx_btn-cancel" onClick="JavaScript:window.close();" />
           </td>
          <%}%>
          
          <%if((strMode.compareTo("edit")==0)){%>
              <td>
                <a href='javascript:openHelp("<%=XSSUtil.encodeForJavaScript(context,strHelpEditTopic)%>","Configuration","<%=XSSUtil.encodeForJavaScript(context,lStr)%>","<%=XSSUtil.encodeForJavaScript(context,langOnlineStr)%>","<%=XSSUtil.encodeForJavaScript(context,SuiteKey)%>")'><img src="../common/images/iconActionHelp.gif" border="0" title="<emxUtil:i18n localize="i18nId">emxProduct.Heading.ContextualHelp</emxUtil:i18n>"/></a>
              </td>
              
           <td><div class="separator"></div></td>
          
           <td>
              <input type="button" name="done" value="<emxUtil:i18n localize="i18nId">emxProduct.Button.Done</emxUtil:i18n>" class="btn-primary" onClick="submitRule('edit','<%=XSSUtil.encodeForJavaScript(context,strSubmitRule)%>'); return false" />
           </td>
             
           <td>
              <input type="button" name="cancel" value="<emxUtil:i18n localize="i18nId">emxProduct.Button.Cancel</emxUtil:i18n>" class="mx_btn-cancel" onClick="JavaScript:window.close();" />
           </td>
              <%}%>

          <%if((strMode.compareTo("copy")==0)){%>
              <td>
                <a href='javascript:openHelp("<%=XSSUtil.encodeForJavaScript(context,strHelpEditTopic)%>","Configuration","<%=XSSUtil.encodeForJavaScript(context,lStr)%>","<%=XSSUtil.encodeForJavaScript(context,langOnlineStr)%>","<%=XSSUtil.encodeForJavaScript(context,SuiteKey)%>")'><img src="../common/images/iconActionHelp.gif" border="0" title="<emxUtil:i18n localize="i18nId">emxProduct.Heading.ContextualHelp</emxUtil:i18n>"/></a>
              </td>
              
           <td><div class="separator"></div></td>
          
           <td>
              <input type="button" name="done" value="<emxUtil:i18n localize="i18nId">emxProduct.Button.Done</emxUtil:i18n>" class="btn-primary" onClick="submitRule('create','<%=XSSUtil.encodeForJavaScript(context,strSubmitRule)%>'); return false" />
           </td>
             
           <td>
              <input type="button" name="cancel" value="<emxUtil:i18n localize="i18nId">emxProduct.Button.Cancel</emxUtil:i18n>" class="mx_btn-cancel" onClick="JavaScript:window.close();" />
           </td>
          <%}%>
          </tr>
         </table>
        </td>
       </tr>
     </table>
    </div><!-- /#pageHeadDiv -->
 
  <div id="divPageBody">
   <div id="divContent">
     <div id="divSource">
      <%if(((String)mJSPPageValues.get("bIsBasics")).compareTo("true")==0)
      {%>
      <div id="divBasics">
         <div class="header">
           <table>
              <tr>
                 <td>
                    <a>
                      <img id="img1" src="../common/images/utilChannelClose.gif" border="0" onclick="toggleBox('divBasics','divFeatureSelector');" />
                    </a>
                 </td>
                 <td class="section-title">
                      <%=strBasicsHeader%>
                 </td>
              </tr>
           </table>
         </div><!-- /Basics #divheader -->
         
             <!-- XSSOK -->
            <jsp:include page="<%=strUrlForBasics%>" flush="true" />
         </div><!-- /#divBasics -->
     <%}   
      if(((String)mJSPPageValues.get("bIsContextSelector")).compareTo("true")==0)
      {%>  
       <div id="divFeatureSelector">
         <div class="header">
           <table>
              <tr>
                <td>
                <%if(!strRulType.equalsIgnoreCase("InclusionRule")){%>
                   <a>
                     <img id="img2" src="../common/images/utilChannelClose.gif" onclick="toggleBox('divFeatureSelector','divBasics');" />
                   </a>
                <%}%>  
                </td>
                <td class="section-title">
                     <%=strFeatureSelectorHeader%>
                </td>
              </tr>
           </table>            
        </div><!-- /Feature Selector #divheader -->
                        
          <!-- XSSOK -->
          <jsp:include page="<%=strUrlForContextSelector%>" flush="true" />
        </div><!-- /#divFeatureSelector -->
      <%}%>
     </div><!-- /#divSource -->
    
     <div id="divExpression">
     
      <%if(((String)mJSPPageValues.get("bIsLeftExpression")).compareTo("true")==0){%>
          <!-- XSSOK -->
          <jsp:include page="<%=strUrlForLeftExpression%>" flush="true" />
      <%}%>    
      
      <%if(((String)mJSPPageValues.get("bIsComparisonOperator")).compareTo("true")==0){%>  
        <div id="comparision-operator">
           <!-- XSSOK -->
           <jsp:include page="<%=strUrlForComparisonOperator%>" flush="true" />
        </div>
      <%}%>
    
      <%if(((String)mJSPPageValues.get("bIsRightExpression")).compareTo("true")==0){%>
          <!-- XSSOK -->
          <jsp:include page="<%=strUrlForRightExpression%>" flush="true" />
      <%}%>    
      
      <%if(((String)mJSPPageValues.get("bIsCompletedRule")).compareTo("true")==0){%>  
        <div id="divCompletedRule">
           <!-- XSSOK -->         
           <jsp:include page="<%=strUrlForCompletedRule%>" flush="true" />
        </div>
      <%}%>
      
     </div><!-- /#divExpression -->
   </div><!-- /#divContent -->
  </div><!-- /#divPageBody -->
 
    <input type="hidden" name="hContextId" value="<xss:encodeForHTMLAttribute><%=strContextObjectId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="hContextType" value="<xss:encodeForHTMLAttribute><%=strContextType%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="hContextName" value="<xss:encodeForHTMLAttribute><%=strContextName%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="hContextNameForIR" value="<xss:encodeForHTMLAttribute><%=strContextNameForIR%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="hRelId" value="<xss:encodeForHTMLAttribute><%=strRelId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="hRuleId" value="<xss:encodeForHTMLAttribute><%=strRuleId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="hRuleType" value="<xss:encodeForHTMLAttribute><%=strRulType%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="hmObjId" value="<xss:encodeForHTMLAttribute><%=strCntxtObjId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="hmRuleInfo" value = eval(DVValuesAddedMap) />
    <input type="hidden" name="hParentOID" value="<xss:encodeForHTMLAttribute><%=strParOID%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="hRowLevel" value="<xss:encodeForHTMLAttribute><%=strRowLevel%></xss:encodeForHTMLAttribute>" />
  </form>
 </body>
</html>

