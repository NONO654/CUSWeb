<%--
  PLCHierarchyProductLineAddExistingPreProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
   boolean bIsError=false;
   try
   {
	   String strLanguage         = context.getSession().getLanguage();
	   String strAlertMessage     = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.ParentShouldBeProductLine", strLanguage);
	   String strRowSelectSingle  = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProdutLine.RowSelect.Single", strLanguage);  
	   String strInactivePL       = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.InactiveProductLine", strLanguage);
	   String strTableRowIds[]    = emxGetParameterValues(request, "emxTableRowId");
	   StringList lstPLChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCT_LINE);
	   String strContextParentOID = emxGetParameter(request, "parentOID");
	   
	   if(strTableRowIds.length == 1)
	   {
			StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0],"|");
			String          strObjectID  = strTokenizer.nextToken();
			DomainObject    domainObj    = new DomainObject(strObjectID);
			StringList      lstSelect    = new StringList();
			lstSelect.add(DomainObject.SELECT_TYPE);
			lstSelect.add(DomainObject.SELECT_CURRENT);
			Map map = (Map) domainObj.getInfo(context, lstSelect);
			
			if(lstPLChildTypes.contains((String)map.get(DomainObject.SELECT_TYPE))){
				if(!ProductLineConstants.STATE_INACTIVE.equals((String)map.get(DomainObject.SELECT_CURRENT))){
%>
		        <script language="Javascript">
		        var submitURL = "../common/emxFullSearch.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&field=TYPES=type_ProductLine&excludeOIDprogram=emxPLCCommon:excludeAvailableProductLine&table=PLCSearchProductLinesTable&HelpMarker=emxhelpfullsearch&selection=multiple&showInitialResults=true&hideHeader=true&suiteKey=ProductLine&submitURL=../productline/PLCHierarchyProductLineAddExistingPostProcess.jsp?suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&objectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&ContextParentOID=<%=XSSUtil.encodeForURL(context,strContextParentOID)%>";
		        showModalDialog(submitURL,575,575,"true","Large");
		        </script>
<%          
				}else{
%>
				<script language="javascript" type="text/javaScript">
				alert("<%=strInactivePL%>");
				</script>
<%					
				}
            }
			else
			{
%>
			<script language="javascript" type="text/javaScript">
			alert("<%=strAlertMessage%>");
			</script>
<%
			}
	   }
	   else
	   {
%>
           <script language="javascript" type="text/javaScript">
           alert("<%=strRowSelectSingle%>");
           </script>
<%
	   }
   }
   catch(Exception e)
   {
	   bIsError=true;
	   session.putValue("error.message", e.getMessage());
   }
   
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
