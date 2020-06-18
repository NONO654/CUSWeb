<%-- 
      LogicalFeatureNameLimitFilterProcess.jsp
      Copyright (c) 1993-2018 Dassault Systemes.
      All Rights Reserved.
      This program contains proprietary and trade secret information of Dassault Systemes.
      Copyright notice is precautionary only and does not evidence any actual
      or intended publication of such program
--%>


<!-- Include file for error handling -->
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<!-- Include directives -->
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<!-- Page directives -->
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

       String limitErr =  com.matrixone.apps.domain.util.EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.checkPositiveInteger", context.getSession().getLanguage());

       // Get user inputs from HTML controls
       String sNameFilterValue = emxGetParameter(request, "FTRLogicalFeatureNameFilterCommand");
       String sLimitFilterValue = emxGetParameter(request, "FTRLogicalFeatureLimitFilterCommand");
       
       if(uiContext!=null && uiContext.equals("myDesk")){%>
      <script language="javascript">
      fUrl = "../common/emxIndentedTable.jsp?program=LogicalFeature:getTopLevelLogicalFeatures&expandProgram=LogicalFeature:getLogicalFeatureStructure&table=FTRMyDeskLogicalFeatureTable&selection=multiple&toolbar=FTRMyDeskLogicalFeatureToolbar,FTRLogicalFeatureCustomFilterToolbar&editRootNode=false&editLink=true&header=emxConfiguration.MyDesk.Heading.LogicalFeatures&HelpMarker=emxhelpallfeatureview&massPromoteDemote=false&objectCompare=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRLogicalFeatureNameFilterCommand=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRLogicalFeatureLimitFilterCommand=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>";
      refreshObject = window.parent.frames;
      </script>
      <%}else if(uiContext!=null && uiContext.equals("context")){%>
      <script language="javascript">
      fUrl = "../common/emxIndentedTable.jsp?expandProgram=LogicalFeature:getLogicalFeatureStructure&table=FTRLogicalFeatureTable&selection=multiple&toolbar=FTRLogicalFeatureToolbar,FTRProductLogicalFeatureCustomFilterToolbar&editRootNode=false&editLink=true&header=emxConfiguration.Heading.LogicalView&HelpMarker=emxhelpallfeatureview&massPromoteDemote=false&objectCompare=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRLogicalFeatureNameFilterCommand=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRLogicalFeatureLimitFilterCommand=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>";
      refreshObject = window.parent.frames;
      </script>
      <%}
      else if(uiContext!=null && uiContext.equals("ruleFilter")){
          sNameFilterValue = emxGetParameter(request, "FTRLogicalFeatureNameFilterForRuleDialog");
          sLimitFilterValue = emxGetParameter(request, "FTRLogicalFeatureLimitFilterForRuleDialog");
      %>  
       <script language="javascript">    
        fUrl = "../common/emxIndentedTable.jsp?expandProgram=LogicalFeature:getLogicalFeatureStructure&table=<%=XSSUtil.encodeForURL(context,strTable)%>&hideHeader=true&selection=multiple&toolbar=<%=XSSUtil.encodeForURL(context,strToolbar)%>&editRootNode=false&massPromoteDemote=false&objectCompare=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRLogicalFeatureNameFilterForRuleDialog=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRLogicalFeatureLimitFilterForRuleDialog=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>&editLink=false&hideHeader=true&PrinterFriendly=false&objectCompare=false&customize=false&export=false&showClipboard=false&multiColumnSort=false&showPageURLIcon=false&displayView=details&autoFilter=false&HelpMarker=false&triggerValidation=false";
        refreshObject = window.parent.frames;
       </script>
     <%}else if(uiContext!=null && uiContext.equals("ruleFilterInPVContext")){
         sNameFilterValue = emxGetParameter(request, "FTRLogicalFeatureNameFilterForRuleDialog");
         sLimitFilterValue = emxGetParameter(request, "FTRLogicalFeatureLimitFilterForRuleDialog");
     %>  
              <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
              <script language="javascript">
              fUrl = "../common/emxIndentedTable.jsp?expandProgram=emxProductVariant:expandLogicalStructureForProductVariant&table=<%=XSSUtil.encodeForURL(context,strTable)%>&hideHeader=true&selection=multiple&toolbar=<%=XSSUtil.encodeForURL(context,strToolbar)%>&editRootNode=false&massPromoteDemote=false&objectCompare=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRLogicalFeatureNameFilterForRuleDialog=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRLogicalFeatureLimitFilterForRuleDialog=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>&editLink=false&hideHeader=true&PrinterFriendly=false&objectCompare=false&customize=false&export=false&showClipboard=false&multiColumnSort=false&showPageURLIcon=false&displayView=details&autoFilter=false&HelpMarker=false&triggerValidation=false";
              refreshObject = window.parent.frames;
              </script>
     <%}else if(uiContext!=null && uiContext.equals("productvariant")){
         %>
              <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
              <script language="javascript">
              fUrl = "../common/emxIndentedTable.jsp?expandProgram=emxProductVariant:expandLogicalStructureForProductVariant&table=FTRLogicalFeatureTable&selection=multiple&toolbar=FTRLogicalFeatureToolbar,FTRProductVariantLogicalFeatureCustomFilterToolbar&editRootNode=false&editLink=true&header=emxConfiguration.Heading.LogicalView&HelpMarker=emxhelpallfeatureview&massPromoteDemote=false&objectCompare=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRLogicalFeatureNameFilterCommand=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRLogicalFeatureLimitFilterCommand=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>";
              refreshObject = window.parent.frames;
              </script>
     <%}else if(uiContext!=null && uiContext.equals("ruleFilterForPCR")){
         sNameFilterValue = emxGetParameter(request, "FTRLogicalFeatureNameFilterForRuleDialog");
         sLimitFilterValue = emxGetParameter(request, "FTRLogicalFeatureLimitFilterForRuleDialog");
     %>  
      <script language="javascript">    
       fUrl = "../common/emxIndentedTable.jsp?expandProgram=LogicalFeature:getProductsAsLogicalFeatures&table=<%=XSSUtil.encodeForURL(context,strTable)%>&hideHeader=true&selection=multiple&toolbar=<%=XSSUtil.encodeForURL(context,strToolbar)%>&editRootNode=false&massPromoteDemote=false&objectCompare=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRLogicalFeatureNameFilterForRuleDialog=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRLogicalFeatureLimitFilterForRuleDialog=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>&editLink=false&hideHeader=true&PrinterFriendly=false&objectCompare=false&customize=false&export=false&showClipboard=false&multiColumnSort=false&showPageURLIcon=false&displayView=details&autoFilter=false&HelpMarker=false&triggerValidation=false";
       refreshObject = window.parent.frames;
      </script>
    <%}else if(uiContext!=null && uiContext.equals("ruleFilterForPCRModel")){
         sNameFilterValue = emxGetParameter(request, "FTRLogicalFeatureNameFilterForRuleDialog");
         sLimitFilterValue = emxGetParameter(request, "FTRLogicalFeatureLimitFilterForRuleDialog");
     %>  
      <script language="javascript">    
       fUrl = "../common/emxIndentedTable.jsp?expandProgram=emxBooleanCompatibility:getValidProductsForPCR&table=<%=XSSUtil.encodeForURL(context,strTable)%>&hideHeader=true&selection=multiple&toolbar=<%=XSSUtil.encodeForURL(context,strToolbar)%>&editRootNode=false&massPromoteDemote=false&objectCompare=false&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&FTRLogicalFeatureNameFilterForRuleDialog=<%=XSSUtil.encodeForURL(context,sNameFilterValue)%>&FTRLogicalFeatureLimitFilterForRuleDialog=<%=XSSUtil.encodeForURL(context,sLimitFilterValue)%>&suiteKey=<%=XSSUtil.encodeForURL(context,suiteKey)%>&initSource=<%=XSSUtil.encodeForURL(context,initSource)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&parentOID=<%=XSSUtil.encodeForURL(context,strParentId)%>&editLink=false&hideHeader=true&PrinterFriendly=false&objectCompare=false&customize=false&export=false&showClipboard=false&multiColumnSort=false&showPageURLIcon=false&displayView=details&autoFilter=false&HelpMarker=false&triggerValidation=false";
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

