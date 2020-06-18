<%--
  ManufacturingPlanCreateInsertSearchUtil.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.util.StringTokenizer"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
boolean bIsError = false;
try
{
   String strObjId = emxGetParameter(request, "objectId");
   String strContext = emxGetParameter(request,"context");
   String strRelName = emxGetParameter(request,"relName");
   String strMode = emxGetParameter(request,"mode");
   String strIsUNTOper = emxGetParameter(request,"isUNTOper");   
   String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
   String strToConnectObjectType = "";
   String strTypeAhead = emxGetParameter(request,"typeAhead");
   
   String strAppendRevision = emxGetParameter(request,"appendRevision");
   if (strMode.equalsIgnoreCase("Chooser")){
	String strSearchMode = emxGetParameter(request, "chooserType");
	 if (strSearchMode.equals("CustomChooser") || strSearchMode.equals("FormChooser")){   
           String fieldNameActual = emxGetParameter(request, "fieldNameActual");
           String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
           String fieldNameDType = emxGetParameter(request, "fieldNameDType");
           String fieldNameDName = emxGetParameter(request, "fieldNameDName");
           String fieldNameName = emxGetParameter(request, "fieldNameName");
           
           String fieldNameIntent = emxGetParameter(request, "fieldNameIntent");
           String fieldNameType = emxGetParameter(request, "fieldNameType");
           String fieldNamePolicy = emxGetParameter(request, "fieldNamePolicy");
           
           StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
           String strObjectId = strTokenizer.nextToken() ; 
           DomainObject objContext = new DomainObject(strObjectId);
           StringList sl= new StringList(DomainObject.SELECT_NAME);
           sl.add(DomainObject.SELECT_REVISION);
           sl.add(ManufacturingPlanConstants.SELECT_ATTRIBUTE_MARKETING_NAME);
           sl.add(ManufacturingPlanConstants.SELECT_ATTRIBUTE_TITLE);
           sl.add(ManufacturingPlanConstants.SELECT_ATTRIBUTE_MANUFACTURING_INTENT);
           sl.add(ManufacturingPlanConstants.SELECT_TYPE);
           sl.add(ManufacturingPlanConstants.SELECT_POLICY);
           java.util.Map objInfo = objContext.getInfo(context,sl);
           String strContextObjectName="";
           String strNameOfMP=(String)objInfo.get(ManufacturingPlanConstants.SELECT_NAME);
           String displayName= (String)objInfo.get(ManufacturingPlanConstants.SELECT_ATTRIBUTE_MARKETING_NAME);
           if(displayName==null ||displayName.trim().isEmpty())
        	   displayName= (String)objInfo.get(ManufacturingPlanConstants.SELECT_ATTRIBUTE_TITLE);
           if(displayName==null ||displayName.trim().isEmpty())
        	   displayName= (String)objInfo.get(ManufacturingPlanConstants.SELECT_NAME);
           
           if("true".equalsIgnoreCase(strAppendRevision)){
          	  strContextObjectName = displayName + " " + (String)objInfo.get(DomainObject.SELECT_REVISION);
            }
           boolean isLastNodeInDerivationChain=false;
           if(objContext.isKindOf(context,ManufacturingPlanConstants.TYPE_MANUFACTURING_PLAN)){
        	   isLastNodeInDerivationChain = DerivationUtil.isLastNodeInRevisionChain(context, strObjectId);
           }
           //-----------------------------------
           String type= (String)objInfo.get(ManufacturingPlanConstants.SELECT_TYPE);
           String displayType =ManufacturingPlanUtil.geti18FrameworkString(context,type);
           
           String policy= (String)objInfo.get(ManufacturingPlanConstants.SELECT_POLICY);
           String displayPolicy =i18nNow.getAdminI18NString("Policy", policy,acceptLanguage);
           boolean isRetrofit=false;
           String mp_Intent= (String)objInfo.get(ManufacturingPlanConstants.SELECT_ATTRIBUTE_MANUFACTURING_INTENT);
           if(mp_Intent.equalsIgnoreCase(ManufacturingPlanConstants.RANGE_VALUE_RETROFIT)){
        	   isRetrofit=true;
           }
           //-----------------------------------
           %>
           
           
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.productline.DerivationUtil"%>

<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanUtil"%>

<%@page import="com.matrixone.apps.domain.util.i18nNow"%><script language="javascript" type="text/javaScript">
           var vfieldNameActual="";	
     	   var vfieldNameDisplay="";
     	   var vfieldNameDType="";
     	   var vfieldNameDName="";
     	  var vfieldNameName="";

     	 var vfieldNameIntent="";
     	var vfieldNameType="";
     	var vfieldNamePolicy="";
           if(getTopWindow().getWindowOpener()){
                vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                vfieldNameDType = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDType)%>");
                vfieldNameDName = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDName)%>");
                vfieldNameName = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameName)%>");

                vfieldNameIntent = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameIntent)%>");
                vfieldNameType = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameType)%>");
                vfieldNamePolicy = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNamePolicy)%>");
            }else{
                vfieldNameActual = parent.frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                vfieldNameDisplay = parent.frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
                vfieldNameDType = parent.frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDType)%>");
                vfieldNameDName = parent.frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDName)%>");
                vfieldNameName = parent.frames[0].document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameName)%>");

                vfieldNameIntent = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameIntent)%>");
                vfieldNameType = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameType)%>");
                vfieldNamePolicy = getTopWindow().getWindowOpener().document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNamePolicy)%>");
                
           }
           vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
           vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
           vfieldNameDType[0].value ="<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isLastNodeInDerivationChain))%>" ;
           vfieldNameDName[0].value ="<%=XSSUtil.encodeForJavaScript(context,displayName)%>" ;
           vfieldNameName[0].value ="<%=XSSUtil.encodeForJavaScript(context,strNameOfMP)%>" ;

           vfieldNameIntent[0].value ="<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isRetrofit))%>" ;
           vfieldNameType[0].value ="<%=XSSUtil.encodeForJavaScript(context,type+"|"+displayType)%>" ;
           vfieldNamePolicy[0].value ="<%=XSSUtil.encodeForJavaScript(context,policy+"|"+displayPolicy)%>" ;
           
           vfieldNameDisplay[0].onchange();
           
           </script>
           <%
            if(strTypeAhead ==null || !strTypeAhead.equalsIgnoreCase("true")){ %>
                 <script language="javascript" type="text/javaScript">
                   //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                   getTopWindow().closeWindow();
                 </script>
            <%}
	     }else if (strSearchMode.equals("SlideInFormChooser")){
             String fieldNameActual = emxGetParameter(request, "fieldNameActual");
             String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
             
             StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
             String strObjectId = strTokenizer.nextToken() ; 
                      
             DomainObject objContext = new DomainObject(strObjectId);
             StringList sl= new StringList(DomainObject.SELECT_NAME);
             sl.add(DomainObject.SELECT_REVISION);
             sl.add(ManufacturingPlanConstants.SELECT_ATTRIBUTE_MARKETING_NAME);
             java.util.Map objInfo = objContext.getInfo(context,sl);
             String strContextObjectName="";
             if("true".equalsIgnoreCase(strAppendRevision)){
            	  strContextObjectName = (String)objInfo.get(ManufacturingPlanConstants.SELECT_ATTRIBUTE_MARKETING_NAME) 
            	  + " " + (String)objInfo.get(DomainObject.SELECT_REVISION);
              }
           %>
              <script language="javascript" type="text/javaScript">
               var openerObj = getTopWindow().getWindowOpener();
               if(openerObj != null){
             	  var vfieldNameActual = openerObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                   var vfieldNameDisplay = openerObj.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");

                   vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                   vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;

                   //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
                   getTopWindow().closeWindow();
               }
               else{
             	  var vfieldNameActual = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
                   var vfieldNameDisplay = self.parent.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");

                   vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,strContextObjectName)%>" ;
                   vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>" ;
               }
              </script>
           <%
       }
  }
}
catch(Exception e)
{
  bIsError=true;
  session.putValue("error.message", e.toString());
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

