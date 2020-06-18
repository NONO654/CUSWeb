<%--
  ToggleAllocation.jsp
  Copyright (c) 1993-2017 Dassault Systemes.
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

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.*"%>
<%@page import = "java.util.Enumeration" %>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
StringList strObjectIdList = new StringList();

  try
  {	  
	  String strMode = emxGetParameter(request, "mode");
      String strRowId = emxGetParameter(request, "rowId");
      String isChecked = emxGetParameter(request, "isChecked");

      StringList slobjIDs = FrameworkUtil.split(strRowId, "|");
      String strCOId = slobjIDs.get(0);
      String strModelVersionId = slobjIDs.get(1);
      String[] arrCOIDs = {strCOId};
      DomainObject domObj = new DomainObject(strCOId);
      String strType = domObj.getInfo(context,DomainConstants.SELECT_TYPE);
      StringList variantValueSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIANTVALUE);
      StringList variabilityOptionSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIABILITYOPTION);
      
	  if(strMode != null && strMode.equals("toggleAllocation"))
      { 
      com.dassault_systemes.enovia.configuration.modeler.Product modelerProduct = new com.dassault_systemes.enovia.configuration.modeler.Product(strModelVersionId);
      
      Map<String,String> mapResult = new HashMap<String,String>();
      if(isChecked.equalsIgnoreCase("true")){
    	  //Call to Modeler API for Allocation
    	  if(variantValueSubTypes.contains(strType)){
        	  mapResult = modelerProduct.addVariantValues(context, arrCOIDs);    		  
    	  }else if(variabilityOptionSubTypes.contains(strType)){
        	  mapResult = modelerProduct.addVariabilityOptions(context, arrCOIDs);
    	  }
      }else if(isChecked.equalsIgnoreCase("false")){
    	  //Call to Modeler API for De-Allocation
    	  if(variantValueSubTypes.contains(strType)){
        	  mapResult = modelerProduct.removeVariantValues(context, arrCOIDs);    		  
    	  }else if(variabilityOptionSubTypes.contains(strType)){
        	  mapResult = modelerProduct.removeVariabilityOptions(context, arrCOIDs);
    	  }
      }
      
      String strStatus = (String) mapResult.get("status");
      if(strStatus.equalsIgnoreCase("SUCCESS")){
          out.println("toggleAllocation=" + strStatus + "$");
      }else{
    	  String strError = (String) mapResult.get("result");
    	  out.println("toggleAllocation=" + strError + "$");
      }

    }
	  
  }catch(Exception e)
     {
	    String strErrorMsg = e.getMessage();
  	    
  	    if(strErrorMsg.contains("Severity")){
  	    	strErrorMsg = strErrorMsg.substring(strErrorMsg.indexOf("#5000001:")+10, strErrorMsg.indexOf("Severity:"));
	    }
    	out.println("toggleAllocation=" + strErrorMsg + "$");
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
