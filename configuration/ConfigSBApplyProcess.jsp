<%--
  ConfigSBApplyProcess.jsp
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

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%@ page import="com.matrixone.jdom.Element"%>
<%@ page import="com.matrixone.jdom.Document"%>

<%
  try
  {  
     String strObjIdContext = emxGetParameter(request, "objectId");
     System.out.println(strObjIdContext);
     
     Document tableDoc = (Document) request.getAttribute("XMLDoc");
     if(tableDoc!=null)
     {
         Element rootElement =  tableDoc.getRootElement();  
         for(int j=0;j < rootElement.getChildren().size();j++)
         {
              Element docEle = (Element) rootElement.getChildren().get(j);
              String elementName =  docEle.getName();
              if("object".equals(elementName))
              {               
                  Element columnEle = (Element) docEle.getChild("column");
                  String strColumnName = columnEle.getAttributeValue("name");
                  if(strColumnName.equalsIgnoreCase("StructureEffectivityExpression")){
                	  break;
                  }
              }            
          }
     }
  /*   if(bEffectivityEdited){
    	 LogicalFeature lf = new LogicalFeature(rootId);
    	 lf.connectDesignVariantsToGlobalContext(context);
     }
  */
  }catch(Exception e)
  {
        session.putValue("error.message", e.getMessage());
  }
  %>
  
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
