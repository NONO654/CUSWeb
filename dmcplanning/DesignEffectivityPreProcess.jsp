<%--
  MasterFeatureUtil.jsp
  
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of 
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>


<%@page import="java.util.HashMap"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.StringTokenizer"%><script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%
  String strMode = emxGetParameter(request,"mode");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String strObjId = emxGetParameter(request, "objectId");
  String strparentId = emxGetParameter(request, "parentOID");
  String uiType = emxGetParameter(request,"uiType");
  String strMode1 = emxGetParameter(request,"context");
  String strsuiteKey = emxGetParameter(request, "suiteKey");
  String strregisateredSuite = emxGetParameter(request,"SuiteDirectory");
  String params = "";
	 Enumeration enumParamNames = request.getParameterNames();
while(enumParamNames.hasMoreElements()) {
   String paramName = (String) enumParamNames.nextElement();
   String paramValue = (String)request.getParameter(paramName);

   if (paramValue != null ){
  	 params += "&" + paramName + "=" + paramValue; 
   }
}
  DomainObject dObj = new DomainObject(strObjId);
  String tempType = dObj.getInfo(context,"type");
  String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
  StringBuffer bn = new StringBuffer();
  
  if(arrTableRowIds != null){
	  StringList strObjectIdList = new StringList();
      StringBuffer sbObjectid = null;
      StringTokenizer strTokenizer = null;
      String tempRelID = "";
    	String strObjectID = "";
      for(int i=0;i<arrTableRowIds.length;i++)
	    {
	      
	    	if(arrTableRowIds[i].indexOf("|") > 0){
	              strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
	              tempRelID = strTokenizer.nextToken();				              				              
	              strObjectID = strTokenizer.nextToken() ;				              
	              strObjectIdList.add(strObjectID);
	          }
	          else{
	        	  strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
	        	  strObjectID = strTokenizer.nextToken() ;
	        	  strObjectIdList.add(strObjectID);				        	  
	          }
	    }
      for(int i=0;i<strObjectIdList.size();i++)
      {   
          bn.append((String)strObjectIdList.get(i));
          if(i<(strObjectIdList.size()-1)){
           bn.append(",");
          }
      }
  }  

  
  try {	     
         if(strMode.equalsIgnoreCase("ViewDerivationEffectivityReport"))   
	     {
	         %>
	         <script language="javascript" type="text/javaScript">
	         var objId = '<%=XSSUtil.encodeForURL(context,strObjId)%>'; 
	         var pobjId = '<%=XSSUtil.encodeForURL(context,strparentId)%>'; 
	         var selectId = '<%=XSSUtil.encodeForURL(context,bn.toString())%>';    
	        
	         strURL    = "../common/emxGridTable.jsp?expandLevelFilter=false&nameSelectable=name&table=CFPViewAllProductRevisionsReportGridTable&rowJPO=CFPModel:getRowsForDesignEffectivityMatrix&colJPO=CFPModel:getColValuesForDesignEffectivityMatrix&freezePane=Name,Revision,Usage&Registered Suite=DMCPlanning&header=DMCPlanning.Heading.ViewEffectivtyMatrixReport&subHeader=DMCPlanning.Heading.ViewEffectivtyMatrixReportSubHeader&objectId="+objId+"&selectId="+selectId+"&editLink=false&suiteKey=DMCPlanning&HelpMarker=emxhelpeffectivitymatrixreport&suiteKey=DMCPlanning&HelpMarker=emxhelpeffectivitymatrixview&suiteKey=DMCPlanning&StringResourceFileId=dmcplanningStringResource&parentOID="+objId+"&SuiteDirectory=dmcplanning";	        
		      showModalDialog(strURL,"","",true,"Large");
	         </script>
	         <% 
	     }
        
	 }
	 catch(Exception e)
	 {
		 throw new FrameworkException(e.getMessage());
	 }

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

