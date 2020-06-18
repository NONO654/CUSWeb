<%--
  VariantsStructureComparePreProcess.jsp
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
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
                 
<%
  try
  {	  
	 String strLanguage     = context.getSession().getLanguage();      
	 String strObjIdContext = emxGetParameter(request, "objectId");
	 String strArrSelectedTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
	 String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.RowSelect.Single", strLanguage);
	 
	 if(strArrSelectedTableRowId != null && strObjIdContext == null){
		 
		 String[] strTableRowId = strArrSelectedTableRowId[0].toString().split("\\|");
	     strObjIdContext = strTableRowId[1].trim();
		%>
	     <script language="javascript" type="text/javaScript">          
		      var url = "../common/emxForm.jsp?form=FTRVariantStructureCompareForm&mode=Edit&formHeader=emxConfiguration.Command.CompareVariantViews&editLink=true&suiteKey=Configuration&featureType=Variant&isSelfTargeted=true&cancelProcessURL=../common/emxCloseWindow.jsp&postProcessURL=../configuration/StructureCompareProcess.jsp&HelpMarker=emxhelpvariantstructurecompare&objectId=<%=strObjIdContext%>";
		      showModalDialog(url,850,630,true);
		 </script>
	     <%
	 }
	 else
	 {
		 %>
         <script language="javascript" type="text/javaScript">          
	           	 var url = "../common/emxForm.jsp?form=FTRVariantStructureCompareForm&mode=Edit&formHeader=emxConfiguration.Command.CompareVariantViews&editLink=true&suiteKey=Configuration&featureType=Variant&isSelfTargeted=true&cancelProcessURL=../common/emxCloseWindow.jsp&postProcessURL=../configuration/StructureCompareProcess.jsp&HelpMarker=emxhelpvariantstructurecompare&objectId=<%=strObjIdContext%>";
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
