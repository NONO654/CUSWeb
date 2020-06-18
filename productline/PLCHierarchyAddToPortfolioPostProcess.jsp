<%--
  PLCHierarchyAddToPortfolioPostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%--Common Include File --%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
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
	  String strLanguage      = context.getSession().getLanguage();
	  String strAlertMessage  = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.AlreadyExistsInPortfolio", strLanguage);
      String strTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
      String strRelName       = ProductLineConstants.TYPE_PORTFOLIO;
      String strObjectIds     = emxGetParameter(request, "ObjectIds");
      String[] arrObjectIds   = strObjectIds.split(",");
      DomainObject domObject  = null;
      StringList lstPortfolioIds     = new StringList();
      boolean isConnectedToPortfolio = false;
      
      if(strTableRowIds.length >= 1)
      { 
    	  for(int i = 0; i < strTableRowIds.length; i++)
    	  {
    		  StringList strTableIdArr = FrameworkUtil.split(strTableRowIds[i].toString(), "|");
        	  String strPortfolioId    = (String)strTableIdArr.get(0); 
        	  domObject = new DomainObject(strPortfolioId);
        	  lstPortfolioIds.add(strPortfolioId);
        	  
        	  StringList strSelect = new StringList();
        	  strSelect.add("from["+ ProductLineConstants.TYPE_PORTFOLIO +"].to.id");
        	  DomainObject.MULTI_VALUE_LIST.add("from["+ ProductLineConstants.TYPE_PORTFOLIO +"].to.id");
        	  Map listOfObjects = domObject.getInfo(context, strSelect);
        	  DomainObject.MULTI_VALUE_LIST.remove("from["+ ProductLineConstants.TYPE_PORTFOLIO +"].to.id");
        	  
        	  StringList listConnectedIds = (StringList) listOfObjects.get("from["+ ProductLineConstants.TYPE_PORTFOLIO +"].to.id");
        	  
        	  if(listConnectedIds != null){
	        	  for(int j = 0; j < arrObjectIds.length; j++)
	        	  {
	        		  if(listConnectedIds.contains(arrObjectIds[i]))
	        		  {
	        			  isConnectedToPortfolio = true;
	        			  break;
	        		  }
	        	  }
        	  }
        	  if(isConnectedToPortfolio)
        	  {
        		  break;
        	  }
        			  
    	  }
    	  
    	  if(isConnectedToPortfolio)
    	  {
%>   	 
    	      <Script language="javascript" type="text/javaScript">
    	      alert("<%=strAlertMessage%>");
    	      getTopWindow().closeWindow();
    	      </Script>  	  
<%      		  
    	  }
    	  else
    	  {
    		  for(int k = 0; k < lstPortfolioIds.size(); k++)
    		  {
    			  domObject = new DomainObject(lstPortfolioIds.get(k).toString());
    			  DomainRelationship.connect(context, domObject, strRelName,true,arrObjectIds);
    		  }
%>   	 
  	          <Script language="javascript" type="text/javaScript">
  	          getTopWindow().closeWindow();
  	          </Script>  	  
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
