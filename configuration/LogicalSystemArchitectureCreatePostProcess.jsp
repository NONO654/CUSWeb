<%--
  LogicalSystemArchitectureCreatePostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Enumeration"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%  
  try
  {
	  com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
      formBean.processForm(session,request); 
      String strUIContext = (String)formBean.getElementValue("UIContext");
      String strObjIdContext = emxGetParameter(request, "parentOID");
      Map paramMap = new HashMap();
       
      paramMap.put("suiteKey",(String)formBean.getElementValue("suiteKey"));  
      paramMap.put("newObjectId",(String)formBean.getElementValue("newObjectId"));
      paramMap.put("localeObj",(String)formBean.getElementValue("localeObj"));
      paramMap.put("languageStr",(String)formBean.getElementValue("languageStr"));
      paramMap.put("SelectionType",(String)formBean.getElementValue("Selection Type"));
      paramMap.put("relId",(String)formBean.getElementValue("relId"));
      paramMap.put("PartFamily",(String)formBean.getElementValue("PartFamilyOID"));
      paramMap.put("PartFamilyDisplay",(String)formBean.getElementValue("PartFamilyDisplay"));
      paramMap.put("RDO",(String)formBean.getElementValue("DesignResponsibilityOID"));
      paramMap.put("objectCreation","New");
      
      String xml = "";
      
      
	  paramMap.put("objectId", (String)formBean.getElementValue("objectId"));
	  paramMap.put("parentOID", strObjIdContext);
	  xml = LogicalFeature.getXMLForSB(context, paramMap,"relationship_LogicalFeatures");  
	  if(strUIContext!=null && strUIContext.equalsIgnoreCase("MyDesk")){
		  %>
          <script language="javascript" type="text/javaScript">
                 var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                 var contentFrameObj = findFrame(getTopWindow(),"content");
                 contentFrameObj.emxEditableTable.addToSelected(strXml);
          </script>
      <%  
		  
		  
	  }			  
	  else if(strUIContext!=null && strUIContext.equalsIgnoreCase("LogicalFeature")){
          %>
       <script language="javascript" type="text/javaScript">
                 var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";
                 var contentFrameObj = findFrame(getTopWindow(),"FTRContextLFLogicalFeatures");               
                 contentFrameObj.emxEditableTable.addToSelected(strXml);
          </script>
      <%  
          
      }	
	  else{
		  %>
          <script language="javascript" type="text/javaScript">
                 var strXml="<%=XSSUtil.encodeForJavaScript(context,xml)%>";              
                 var contentFrameObj = findFrame(getTopWindow(),"FTRSystemArchitectureLogicalFeatures");    
                 //the following code is required when we do launch (product-->logical structures-->click on the launch icon on the toolbar)                 
                 if(contentFrameObj == null){
                	 contentFrameObj = findFrame(getTopWindow(),"content");                 	   
                 }        
                 contentFrameObj.emxEditableTable.addToSelected(strXml);
          </script>
      <%  
		  
	  }
	
        
  }
  catch(Exception e)
  {
    session.putValue("error.message", e.getMessage());    
  }// End of main Try-catck block
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

    
