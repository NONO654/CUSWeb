<%--
  VariabilityPreProcess.jsp
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
	  String mode = "edit";
	  boolean isFTRUser=false;
	  String Licenses[] = {"ENO_FTR_TP","ENO_PLC_TP"};
	  try {
			FrameworkLicenseUtil.checkLicenseReserved(context,Licenses);
		    isFTRUser = true;
		}catch (Exception e){
			isFTRUser = false;
		}
	  boolean isMobileMode = UINavigatorUtil.isMobile(context);
	  if(isMobileMode || !isFTRUser){
		  editLink="false";
		  mode = "view";
	  }
	  String strMode = emxGetParameter(request, "mode");
	  String strObjIdContext = emxGetParameter(request, "objectId");
	  
	  if("ProductLineContext".equalsIgnoreCase(strMode))
	  {
		  %>
          <script language="javascript" type="text/javaScript">     
		        var url= "../common/emxIndentedTable.jsp?toolbar=FTRVariabilityToolbar&expandProgram=ConfigurationFeature:expandVariabilityStucture&table=FTRProductLineVariabilityTable&editRootNode=false&selection=multiple&featureType=Marketing&header=emxConfiguration.Heading.Table.VariabilitySummary&HelpMarker=emxhelpvariantoptionpage&massPromoteDemote=false&objectCompare=false&SuiteDirectory=configuration&suiteKey=Configuration&mode=<%=XSSUtil.encodeForJavaScript(context,mode)%>&editLink=<%=XSSUtil.encodeForJavaScript(context,editLink)%>&parentOID=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>";
                self.location.href = url;    
      	  </script>
          <%  
	  }
	  else if("ModelContext".equalsIgnoreCase(strMode))
	  {
		  %>
          <script language="javascript" type="text/javaScript">          
		        var url= "../common/emxIndentedTable.jsp?toolbar=FTRVariabilityToolbar&program=ConfigurationFeature:getVariabilityStructureForModelContext&table=FTRModelVariabilityTable&rowGrouping=false&rowGroupingColumnNames=Allocation&editRootNode=false&selection=multiple&featureType=Marketing&header=emxConfiguration.Heading.Table.VariabilitySummary&sortColumnName=DisplayName&HelpMarker=emxhelpvariantsmodel&objectCompare=false&SuiteDirectory=configuration&suiteKey=Configuration&parentOID=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>";
		        self.location.href = url;
      	  </script>
          <%  
	  }
	  else if("ProductContext".equalsIgnoreCase(strMode))
	  {
		  %>
          <script language="javascript" type="text/javaScript">          
		        var url= "../common/emxIndentedTable.jsp?toolbar=FTRVariabilityToolbar,FTRProductConfigurationFeatureCustomFilterToolbar&expandProgram=ConfigurationFeature:expandVariabilityStucture&table=FTRProductVariabilityTable&editRootNode=false&selection=multiple&featureType=Marketing&header=emxConfiguration.Heading.Table.VariabilitySummary&sortColumnName=DisplayName&HelpMarker=emxhelpvariantoptionpage&objectCompare=false&SuiteDirectory=configuration&suiteKey=Configuration&mode=<%=XSSUtil.encodeForJavaScript(context,mode)%>&editLink=<%=XSSUtil.encodeForJavaScript(context,editLink)%>&parentOID=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>";
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
