<%-- 
      ConfigurationFeatureNameLimitFilterProcess.jsp
      Copyright (c) 1993-2018 Dassault Systemes.
      All Rights Reserved.
      This program contains proprietary and trade secret information of Dassault Systemes.
      Copyright notice is precautionary only and does not evidence any actual
      or intended publication of such program
--%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
    var fUrl;
    var refreshObject;
</script>
<%
       // Get time stamp id for current table from request
       String jsTreeID = emxGetParameter(request,"jsTreeID");  
       String suiteKey = emxGetParameter(request,"suiteKey");    
       String initSource = emxGetParameter(request,"initSource");
       String strObjectId    = emxGetParameter(request, "objectId");     
       String strParentId = emxGetParameter(request, "parentOID");
       String uiContext = emxGetParameter(request, "UIContext");
       String strToolbar = emxGetParameter(request, "toolbar");
       String strTable = emxGetParameter(request, "table");
       String strTreeName = emxGetParameter(request, "categoryTreeName");
       String limitErr =  com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.checkPositiveInteger", context.getSession().getLanguage());
   

       // Get user inputs from HTML controls
       String sNameFilterValue = emxGetParameter(request, "FTRConfigurationFeatureNameFilterCommand");
       String sLimitFilterValue = emxGetParameter(request, "FTRConfigurationFeatureLimitFilterCommand");
              
       if(uiContext!=null && uiContext.equals("myDesk")){%>  
        <script language="javascript">    
         fUrl = "../common/emxIndentedTable.jsp?program=ConfigurationFeature:getTopLevelConfigurationFeatures&expandProgram=ConfigurationFeature:getConfigurationFeatureStructure&table=<%=XSSUtil.encodeForURL(context,strTable)%>&selection=multiple&toolbar=<%=XSSUtil.encodeForURL(context,strToolbar)%>&editRootNode=false&editLink=true&header=emxProduct.Tree.ConfigurationFeatures&HelpMarker=emxhelpconfigurationfeaturelist&massPromoteDemote=false&objectCompare=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRConfigurationFeatureNameFilterCommand=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRConfigurationFeatureLimitFilterCommand=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>";
         refreshObject = window.parent.frames;
        </script>
      <%}else if(uiContext!=null && uiContext.equals("context") && strParentId != null){
    	   DomainObject bus = new DomainObject(strParentId);
    	   String type = bus.getType(context);
    	   if(mxType.isOfParentType(context,type,ConfigurationConstants.TYPE_PRODUCT_LINE) || mxType.isOfParentType(context,type,ConfigurationConstants.TYPE_CONFIGURATION_FEATURE)){%>
           <script language="javascript">
             fUrl = "../common/emxIndentedTable.jsp?toolbar=<%=XSSUtil.encodeForURL(context,strToolbar)%>&expandProgram=ConfigurationFeature:getConfigurationFeatureStructure&table=<%=XSSUtil.encodeForURL(context,strTable)%>&editRootNode=false&selection=multiple&featureType=Marketing&editLink=true&editRelationship=relationship_ConfigurationFeatures,relationship_ConfigurationOptions&header=emxConfiguration.Heading.ConfigFeatures&HelpMarker=emxhelpconfigurationfeaturelist&massPromoteDemote=false&objectCompare=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRConfigurationFeatureNameFilterCommand=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRConfigurationFeatureLimitFilterCommand=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>&categoryTreeName=<%=XSSUtil.encodeForURL(context,strTreeName)%>";
             refreshObject = window.parent.frames;
           </script>
       <%}else{%>
         <script language="javascript">  
            fUrl = "../common/emxIndentedTable.jsp?toolbar=<%=XSSUtil.encodeForURL(context,strToolbar)%>&expandProgram=ConfigurationFeature:getConfigurationFeatureStructure&table=<%=XSSUtil.encodeForURL(context,strTable)%>&editRootNode=false&selection=multiple&featureType=Marketing&editLink=true&editRelationship=relationship_ConfigurationFeatures,relationship_ConfigurationOptions&header=emxConfiguration.Heading.ConfigFeatures&HelpMarker=emxhelpconfigurationfeaturelist&massPromoteDemote=false&objectCompare=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRConfigurationFeatureNameFilterCommand=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRConfigurationFeatureLimitFilterCommand=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>&categoryTreeName=<%=XSSUtil.encodeForURL(context,strTreeName)%>";                   
            refreshObject = window.parent;
         </script>
       <% }
       }else if(uiContext!=null && uiContext.equals("ruleFilter")){
    	   sNameFilterValue = emxGetParameter(request, "FTRConfigurationFeatureNameFilterForRuleDialog");
    	   sLimitFilterValue = emxGetParameter(request, "FTRConfigurationFeatureLimitFilterForRuleDialog");
       %>  
       <script language="javascript">    
        fUrl = "../common/emxIndentedTable.jsp?expandProgram=ConfigurationFeature:getConfigurationFeatureStructure&table=<%=XSSUtil.encodeForURL(context,strTable)%>&selection=multiple&toolbar=<%=XSSUtil.encodeForURL(context,strToolbar)%>&editRootNode=false&hideHeader=true&massPromoteDemote=false&objectCompare=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRConfigurationFeatureNameFilterForRuleDialog=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRConfigurationFeatureLimitFilterForRuleDialog=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>&editLink=false&hideHeader=true&PrinterFriendly=false&objectCompare=false&customize=false&export=false&showClipboard=false&multiColumnSort=false&showPageURLIcon=false&displayView=details&autoFilter=false&HelpMarker=false";
        refreshObject = window.parent.frames;
       </script>
     <%}%>
     
     
     <script language="javascript">
	     if((!isNaN("<%=XSSUtil.encodeForJavaScript(context,sLimitFilterValue)%>") && "<%=XSSUtil.encodeForJavaScript(context,sLimitFilterValue)%>" > 0 ) || "<%=XSSUtil.encodeForJavaScript(context,sLimitFilterValue)%>" == "*")
	     {
	         refreshObject.location.href = fUrl;
	     }
	     else
	     {
	          alert("<%=XSSUtil.encodeForJavaScript(context,limitErr)%>");
	     }
     </script>

     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

