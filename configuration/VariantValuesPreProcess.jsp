<%--
  VariantValuesPreProcess.jsp
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
	  
	  String strObjIdContext = emxGetParameter(request, "objectId");
	  %>
          <script language="javascript" type="text/javaScript">       
		        var url= "../common/emxIndentedTable.jsp?toolbar=FTRVariantValuesToolbar,FTRProductConfigurationFeatureCustomFilterToolbar&expandLevelFilter=false&expandLevelFilterMenu=false&expandProgram=ConfigurationFeature:expandVariantStucture&table=FTRVariantValuesTable&editRootNode=false&selection=multiple&featureType=Marketing&header=emxConfiguration.Heading.ConfigFeatures&HelpMarker=emxhelpvariantvaluespage&massPromoteDemote=false&objectCompare=false&SuiteDirectory=configuration&suiteKey=Configuration&mode=<%=XSSUtil.encodeForJavaScript(context,mode)%>&editLink=<%=XSSUtil.encodeForJavaScript(context,editLink)%>&parentOID=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjIdContext)%>";
                self.location.href = url;    
      	  </script>
      <%  
	  
  }
  catch(Exception e){
    	    session.putValue("error.message", e.getMessage());
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
