<%--
  showGBOMPartTablePreProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
                 
<%
  try
  {	  
	  String strObjIdContext = "";	  
	  String strContext = emxGetParameter(request, "context");
	  strObjIdContext = XSSUtil.encodeForURL(context,emxGetParameter(request, "objectId"));
	  boolean isEffGrid = ConfigurationUtil.isEffectivityGridActive(context);
	  boolean isMobileMode = UINavigatorUtil.isMobile(context);
	  boolean isFTRUser = ConfigurationUtil.isFTRUser(context);
	  boolean isCMMUser = ConfigurationUtil.isCMMUser(context);
	  String editLink="true";
	  String strEditMode="edit";
	  if(isMobileMode||(!isFTRUser&&!isCMMUser)){
		  editLink="false";
		  strEditMode="view";
	  }
	  // Frozen State check
      String strAppendURL = "VariantEffectivity|Effectivity";
	  Boolean isFrozenState = ProductLineUtil.isFrozenState(context,XSSUtil.decodeFromURL(strObjIdContext));
	  if(isFrozenState){
		  strAppendURL = "VariantEffectivityReadOnly|Effectivity";// TODO-- 
	  }
	  // Frozen State check		  
      if(ProductLineCommon.isNotNull(strContext) && strContext.equalsIgnoreCase("Product")){    	    
    		  %>
              <script language="javascript" type="text/javaScript">          
    		        var url= "../common/emxIndentedTable.jsp?expandProgram=LogicalFeature:getLogicalFeatureStructureForProductContext&mode=<%=XSSUtil.encodeForJavaScript(context,strEditMode)%>&isProductContext=true&parentOID=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>&productID=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>&portalMode=true&portalCmdName=FTRSystemArchitectureLogicalFeatures&portal=FTRSystemArchitecture&table=FTRLogicalFeatureTableProductContext&sortColumnName=DisplayName&selection=multiple&toolbar=FTRLogicalFeatureToolbar,FTRProductLogicalFeatureCustomFilterToolbar&editRootNode=false&editLink=<%=XSSUtil.encodeForJavaScript(context,editLink)%>&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&emxSuiteDirectory=configuration&effectivityRelationship=relationship_LogicalFeatures&header=emxConfiguration.Heading.LogicalView&HelpMarker=emxhelplogicalfeaturespage&massPromoteDemote=false&objectCompare=false&postProcessJPO=LogicalFeatureBase:refreshTree&editRelationship=relationship_LogicalFeatures&appendURL=<%=strAppendURL%>&effectivityFilterMode=150&postProcessURL=../configuration/ConfigSBApplyProcess.jsp?applyContext=Product";
    		        self.location.href = url;     
          	  </script>
              <%  
      }
      else if(ProductLineCommon.isNotNull(strContext) && strContext.equalsIgnoreCase("LogicalFeature")){
    		  %>
              <script language="javascript" type="text/javaScript">          
    		        var url= "../common/emxIndentedTable.jsp?expandProgram=LogicalFeature:getLogicalFeatureStructureForProductContext&mode=<%=XSSUtil.encodeForJavaScript(context,strEditMode)%>&isProductContext=false&parentOID=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>&table=FTRLogicalFeatureTableLogicalFeatureContext&sortColumnName=DisplayName&selection=multiple&toolbar=FTRLFContextLogicalFeatureToolbar,FTRProductLogicalFeatureCustomFilterToolbar&editRootNode=false&editLink=<%=XSSUtil.encodeForJavaScript(context,editLink)%>&suiteKey=Configuration&emxSuiteDirectory=configuration&StringResourceFileId=emxConfigurationStringResource&effectivityRelationship=relationship_LogicalFeatures&header=emxConfiguration.Heading.LogicalView&HelpMarker=emxhelplogicalfeaturespage&isStructure=true&massPromoteDemote=false&portalMode=true&portalCmdName=FTRContextLFLogicalFeatures&portal=FTRSystemArchitecture&objectCompare=false&postProcessJPO=LogicalFeatureBase:refreshTree&editRelationship=relationship_LogicalFeatures&UIContext=LogicalFeature&FromContext=Logical&appendURL=<%=strAppendURL%>&effectivityFilterMode=150&postProcessURL=../configuration/ConfigSBApplyProcess.jsp?applyContext=Product";
    		        self.location.href = url;     
          	  </script>
              <%  
      }      
  }
  catch(Exception e){
    	    session.putValue("error.message", e.getMessage());
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
