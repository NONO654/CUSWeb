<%--
  MyDeskLFSummaryPreProcess.jsp
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
	  strAppendURL= "VariantEffectivityNoToolbarNoMassUpdate|Effectivity"; //After Decoupling- exepected-VariantEffectivityNoToolbarNoMassUpdate

              %>
              <script language="javascript" type="text/javaScript">          
                    var url= "../common/emxIndentedTable.jsp?program=LogicalFeature:getTopLevelOwnedLogicalFeatures,LogicalFeature:getTopLevelLogicalFeatures&expandProgram=LogicalFeature:getLogicalFeatureStructure&programLabel=emxProduct.Filter.Owned,emxProduct.Filter.All&table=FTRMyDeskLogicalFeatureTable&selection=multiple&toolbar=FTRMyDeskLogicalFeatureToolbar,FTRLogicalFeatureCustomFilterToolbar&editRootNode=true&header=emxConfiguration.MyDesk.Heading.LogicalFeatures&HelpMarker=emxhelplogicalfeaturespage&massPromoteDemote=false&objectCompare=false&FromContext=Logical"+
                    		"&appendURL=<%=strAppendURL%>&effectivityRelationship=relationship_LogicalFeatures&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&emxSuiteDirectory=configuration&editLink="+<%=XSSUtil.encodeForJavaScript(context,editLink)%>;
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
