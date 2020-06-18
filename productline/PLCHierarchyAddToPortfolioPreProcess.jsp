<%--
  PLCHierarchyAddToPortfolioPreProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%--Common Include File --%>
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
	  String strLanguage       = context.getSession().getLanguage();
	  String strAlertMessage   = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.AddPortfolioModelsProductsOnly", strLanguage);
      String strTableRowIds[]  = emxGetParameterValues(request, "emxTableRowId");
      String strPortfolioType  = ProductLineConstants.TYPE_PORTFOLIO;
      DomainObject domObject   = null;
      boolean isProductLine    = false;
      String strObjectIds      = "";
      String strParentOID      = "";
      String strObjectId       = "";
      StringList lstPLChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCT_LINE);
      
      if(strTableRowIds.length >= 1){
    	  
    	  for(int i = 0; i < strTableRowIds.length; i++)
    	  {
    		  StringList strTableIdArr  = FrameworkUtil.split(strTableRowIds[i].toString(), "|");
    		  if(strTableIdArr.size() >= 4){
        	       strObjectId    = (String)strTableIdArr.get(1);
        	       strParentOID   = (String)strTableIdArr.get(2);
    		  }else{
    			   strObjectId    = (String)strTableIdArr.get(0);
       	           strParentOID   = (String)strTableIdArr.get(1);
    		  }
        	  domObject                 = new DomainObject(strObjectId);
        	  String strType            = domObject.getType(context);
        	  strObjectIds += strObjectId + ",";
        	  
        	  if(lstPLChildTypes.contains(strType))
        	  {
        		  isProductLine = true;
        		  break;
        	  } 
    	  }
    	  strObjectIds = strObjectIds.substring(0, strObjectIds.lastIndexOf(","));   	 
    	  
    	  if(isProductLine)
    	  {
%>   	 
  	        <Script language="javascript" type="text/javaScript">
  	        alert("<%=strAlertMessage%>");
  	        </Script>  	  
<%    		  
    	  }
    	  else
    	  {  
%>
            <script language="javascript" type="text/javaScript">
            var submitURL = "../common/emxFullSearch.jsp?relName=relationship_Portfolio&field=TYPES=type_Portfolio&table=PLCSearchPortfoliosList&selection=multiple&submitAction=none&showInitialResults=true&hideHeader=true&HelpMarker=emxhelpfullsearch&objectId=<%=XSSUtil.encodeForURL(context,strParentOID)%>&submitURL=../productline/PLCHierarchyAddToPortfolioPostProcess.jsp?ObjectIds=<%=XSSUtil.encodeForURL(context,strObjectIds)%>&RelName=relationship_Portfolio";
            showModalDialog(submitURL,575,575,"true","Large");
            </script>
<%  		  
    	  }
      }
  }
  catch(Exception e)
  {
	  bIsError=true;
	  session.putValue("error.message", e.getMessage());	  
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
