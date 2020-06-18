<%--
  MyDeskCFSummaryPreProcess.jsp
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

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
                 
<%
  try
  {	  
	  String editLink="true";
	  boolean isMobileMode = UINavigatorUtil.isMobile(context);
	  if(isMobileMode){
		  editLink="false";
	  }
	  String strAppendURL= "";
	  //strAppendURL= "StructureEffectivityNoToolbarNoMassUpdate|Effectivity"; //Before Decoupling
	  strAppendURL= "EvolutionEffectivityNoToolbarNoMassUpdate|Effectivity"; //After Decoupling- exepected-EvolutionEffectivityNoToolbarNoMassUpdate
    		  %>
              <script language="javascript" type="text/javaScript">          
    		        var url= "../common/emxIndentedTable.jsp?program=ConfigurationFeature:getTopLevelOwnedConfigurationFeatures,ConfigurationFeature:getTopLevelConfigurationFeatures&expandProgram=ConfigurationFeature:getConfigurationFeatureStructure&programLabel=emxProduct.Filter.Owned,emxProduct.Filter.All&table=FTRMyDeskConfigurationFeatureTable&selection=multiple&toolbar=FTRMyDeskConfigurationFeaturesTopActionBar,FTRConfigurationFeatureCustomFilterToolbar&editRootNode=true&header=emxProduct.Tree.ConfigurationFeatures&HelpMarker=emxhelpconfigurationfeaturelist&massPromoteDemote=false&objectCompare=false"
    		        +"&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&emxSuiteDirectory=configuration&editLink="+<%=XSSUtil.encodeForJavaScript(context,editLink)%>;
    		        var contentFrame = findFrame (getTopWindow(), "content");
                    contentFrame.location.href = url;
          	  </script>
              <%  
  }
  catch(Exception e){
    	    session.putValue("error.message", e.getMessage());
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
