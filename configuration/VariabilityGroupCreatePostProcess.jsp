<%--
  ConfigurationFeatureCreatePostProcess.jsp
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
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>

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
      String  strUIContext = emxGetParameter(request,"UIContext");
      String  featureType  = emxGetParameter(request,"TypeActual");
      
      if(featureType != null && !"".equals(featureType))
      {
          relType = "relationship_ConfigurationFeatures"; 
      }       
  		
      // Create Variability Group Object from Global Actions.
      if("GlobalActions".equalsIgnoreCase(strUIContext))
      {
    	  matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
    	  ContextUtil.commitTransaction(ctx);
          %>
             <script language="javascript" type="text/javaScript">
                var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
                contentFrameObj.document.location.href= "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,strNewObjId)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,strJsTreeID)%>&treeMenu=type_VariabilityGroup";               
             </script>
          <%
      }
      else // Create Variability Group Object from Product Line/Product Context.
      {
    	  // To get the relationship id between newly created Variability Option and Variability Group under which it is created.
    	  matrix.db.Context ctx = (matrix.db.Context)request.getAttribute("context");
    	  ContextUtil.commitTransaction(ctx);
          DomainObject domObj = new DomainObject(strParentOID);
          
    	  String strWhereExp = "to["+ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES+"].to.id == "+strNewObjId;
    	  MapList mapModelStructure = domObj.getRelatedObjects(context, ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES, ConfigurationConstants.TYPE_VARIABILITYGROUP, null, new StringList(DomainRelationship.SELECT_ID),false,true,(short)1,strWhereExp,DomainConstants.EMPTY_STRING,1);
    	  Map relIdMap = (Map)mapModelStructure.get(0);
    	  String relId = (String) relIdMap.get(DomainRelationship.SELECT_ID);
    	  
    	  // To set default value for Configuration Selection Criteria(Must/May) attribute as May for Variability Group.
    	  DomainRelationship.setAttributeValue(context, relId, ConfigurationConstants.ATTRIBUTE_CONFIGURATION_SELECTION_CRITERIA, ConfigurationConstants.RANGE_VALUE_MAY);
    	  
          paramMap.put("newObjectId", strNewObjId);
          paramMap.put("languageStr",(String) emxGetParameter(request,"languageStr"));
          paramMap.put("SelectionType",(String) emxGetParameter(request,"Selection Type"));      
          paramMap.put("KeyInType", (String) emxGetParameter(request,"Key-In Type"));
          paramMap.put("relId", relId);
          paramMap.put("objectCreation","New");
          paramMap.put("objectId", strObjectId);  
          paramMap.put("parentOID", strParentOID);
          
    	  String xml = ConfigurationFeature.getXMLForSBCreate(context, paramMap, relType);
    	  xml = xml.replaceAll("pending", "committed");
    	  boolean isProductContext = domObj.isKindOf(context, ConfigurationConstants.TYPE_PRODUCTS);
    	  %>
          	<script language="javascript" type="text/javaScript">
                var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),"detailsDisplay");                           
                contentFrameObj.emxEditableTable.addToSelected(strXml);
                
                // Code will get call for Model Version - To add the Created object in Structure Tree
                var isProductContext = "<%=isProductContext%>";
                if("true" == isProductContext){
                  var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");          
                  contentFrame.addMultipleStructureNodes("<%=strNewObjId%>", "<%=strObjectId%>", '', '', false);
                }
          	</script>
          <% 
      }       
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
