<%--
  VariabilityStructureComparePreProcess.jsp
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

<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
                 
<%
  try
  {	  
	 String strLanguage     = context.getSession().getLanguage();      
	 String strObjIdContext = emxGetParameter(request, "objectId");
	 DomainObject domObject = DomainObject.newInstance(context, strObjIdContext);
	 String strObjType      = domObject.getInfo(context, DomainConstants.SELECT_TYPE);
	 StringList PLSubTypes  = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_PRODUCT_LINE);
	 StringList PRDSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_PRODUCTS);
	 StringList vrSubTypes  = ProductLineUtil.getChildrenTypes(context, ConfigurationConstants.TYPE_VARIANT);
	 vrSubTypes.add(ConfigurationConstants.TYPE_VARIANT);
	 StringList vgSubTypes  = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIABILITYGROUP);
	 
	 if(PLSubTypes.contains(strObjType))
	 {
		 %>
         
	     <script language="javascript" type="text/javaScript">          
	           	 var url = "../common/emxForm.jsp?form=FTRProductLineVariabilityStructureCompareForm&mode=Edit&formHeader=emxConfiguration.Command.CompareVariabilityViews&editLink=true&suiteKey=Configuration&featureType=Variability&isSelfTargeted=true&cancelProcessURL=../common/emxCloseWindow.jsp&postProcessURL=../configuration/StructureCompareProcess.jsp&HelpMarker=emxhelpvariantstructurecompare&objectId=<%=strObjIdContext%>";
	           	 showModalDialog(url,850,630,true);
	     </script>
	     
        <%
	 }
	 else if(PRDSubTypes.contains(strObjType))
	 {
		 %>
         <script language="javascript" type="text/javaScript">  
	           	 var url = "../common/emxForm.jsp?form=FTRProductsVariantStructureCompareForm&mode=Edit&formHeader=emxConfiguration.Command.CompareVariabilityViews&editLink=true&suiteKey=Configuration&featureType=Variability&isSelfTargeted=true&cancelProcessURL=../common/emxCloseWindow.jsp&postProcessURL=../configuration/StructureCompareProcess.jsp&HelpMarker=emxhelpvariantstructurecompare&objectId=<%=strObjIdContext%>";
	           	 showModalDialog(url,850,630,true);
	     </script>
	     
        <%
	 }
	 else if(vrSubTypes.contains(strObjType))
	 {
		 %>
         <script language="javascript" type="text/javaScript">          
	           	 var url = "../common/emxForm.jsp?form=FTRVariantStructureCompareForm&mode=Edit&formHeader=emxConfiguration.Command.CompareVariantViews&editLink=true&suiteKey=Configuration&featureType=Variant&isSelfTargeted=true&postProcessURL=../configuration/StructureCompareProcess.jsp&HelpMarker=emxhelpvariantstructurecompare&objectId=<%=strObjIdContext%>";
	           	 showModalDialog(url,850,630,true);
	     </script>
	     
        <%
	 }
	 else if(vgSubTypes.contains(strObjType))
	 {
		 %>
         <script language="javascript" type="text/javaScript">          
	           	 var url = "../common/emxForm.jsp?form=FTRVariabilityGroupStructureCompareForm&mode=Edit&formHeader=emxConfiguration.Command.CompareVariantViews&editLink=true&suiteKey=Configuration&featureType=Variant&isSelfTargeted=true&postProcessURL=../configuration/StructureCompareProcess.jsp&HelpMarker=emxhelpvariantstructurecompare&objectId=<%=strObjIdContext%>";
	           	 showModalDialog(url,850,630,true);
	     </script>
	     
        <%
	 }
  }
  catch(Exception e){
    	    session.putValue("error.message", e.getMessage());
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
