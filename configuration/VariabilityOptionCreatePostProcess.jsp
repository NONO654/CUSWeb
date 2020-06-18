<%--
  VariabilityOptionCreatePostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>

<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>

<%
  try
  {
	  HashMap paramMap     = new HashMap();    
	  String  relType      = "";  
      String  strNewObjId  = emxGetParameter(request, "newObjectId");
      String  strJsTreeID  = emxGetParameter(request, "jsTreeID");
      String  strObjectId  = emxGetParameter(request, "objectId");
      String  strParentOID = emxGetParameter(request, "parentOID");
      String  featureType  = emxGetParameter(request,"TypeActual");
      String  contextObjID = emxGetParameter(request,"contextObjID");
      
      // To get the relationship id between newly created Variability Option and Variability Group under which it is created.
      matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
	  ContextUtil.commitTransaction(ctx);
      DomainObject domObj = new DomainObject(strNewObjId);
	  String relId = domObj.getInfo(context, "to["+ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA+"].id");
	  
      if(featureType != null && !"".equals(featureType))
      {
          relType = "relationship_GroupedVariabilityCriteria"; 
      }       
  		
      // Create Variability Option Object from Product Line/ Product/ Variability Group Context under Variability Group.
      paramMap.put("newObjectId", strNewObjId);
      paramMap.put("languageStr",(String) emxGetParameter(request,"languageStr"));
      paramMap.put("relId", relId);
      paramMap.put("objectCreation","New");
      paramMap.put("objectId", strObjectId);  
      paramMap.put("parentOID", strParentOID);
          
      String xml = ConfigurationFeature.getXMLForSBCreate(context, paramMap, relType);
      xml = xml.replaceAll("pending", "committed");
      boolean isProductContext = false;
      if(ProductLineCommon.isNotNull(contextObjID))
      {
      	 DomainObject domainObj = new DomainObject(contextObjID);
      	 isProductContext = domainObj.isKindOf(context, ConfigurationConstants.TYPE_PRODUCTS);
      }
      %>
      <script language="javascript" type="text/javaScript">
           var varGroupId      = "<%=strObjectId%>";
           var detailsFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),"detailsDisplay");           
           var oXML            = detailsFrameObj.oXML;
	       var selectedRow     = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + varGroupId + "']");
	       var rowId           = selectedRow[0].getAttribute("id");
	       var strXml          = "<%=XSSUtil.encodeForJavaScript(context,xml)%>";
	       var selectSBrows    = [];
	       selectSBrows.push(rowId);
	       detailsFrameObj.emxEditableTable.addToSelected(strXml, selectSBrows);
	       
	       // Code will get call for Model Version - To add the Created object in Structure Tree
           var isProductContext = "<%=isProductContext%>";
           if("true" == isProductContext){
             var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");          
             contentFrame.addMultipleStructureNodes("<%=strNewObjId%>", "<%=strParentOID%>", '', '', false);
           }
      </script>
      <%
  }
  catch(Exception e)
  {
	  String strErrorMessage = e.getMessage();
	  if(strErrorMessage.contains("1500789")){
		  strErrorMessage = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.NotUniqueMsg", new Locale(request.getHeader("Accept-Language")));
	  }
	  session.putValue("error.message", strErrorMessage);
  }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
