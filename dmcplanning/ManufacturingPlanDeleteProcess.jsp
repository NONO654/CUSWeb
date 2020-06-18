<%--
  ManufacturingPlanDeleteProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  
--%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="java.util.HashSet"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import = "java.util.Enumeration" %>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "matrix.util.StringList"%>


    
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
    
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlan"%>
    
<%@page import="com.matrixone.apps.productline.DerivationUtil"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

	<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
    <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
    <script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
    <script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
    

<%
boolean bIsError = false;
String action = "";
String msg = "";

String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
String strParentID = emxGetParameter(request,"objectId");
    
DomainObject objContext=new DomainObject(strParentID);
boolean isFromProductContext=false;
isFromProductContext=objContext.isKindOf(context,ManufacturingPlanConstants.TYPE_PRODUCTS);

	String arrObjIds[] = null;
	arrObjIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("ObjId");
 	ManufacturingPlan manPlan = new ManufacturingPlan();
 	boolean isFrozen = false; 
 	boolean isLastNode = false;
 	boolean isBreakDownMPSelected = false;
 	for(int i =0 ;i<arrObjIds.length;i++){
   		isFrozen = manPlan.isFrozenState(context,arrObjIds[i]);
   		isLastNode = DerivationUtil.isLastNode(context,arrObjIds[i]);
   		
	    StringList sl=FrameworkUtil.split(arrTableRowIds[0] , "|");
	    String strLevel=sl.get(sl.size()-1).toString();
	    StringList sl2=FrameworkUtil.split(strLevel , ",");
	    if(sl2.size()>2 && isFromProductContext){
	    	isBreakDownMPSelected=true;
	    }
   		if(isBreakDownMPSelected)
   			break;	
   		if(isFrozen)
   			break;	
   		if(!isLastNode)
   			break;
	}
    if(isBreakDownMPSelected){
		%>
        <script language="javascript" type="text/javaScript">
              alert("<emxUtil:i18n localize='i18nId'>DMCPlanning.Error.MPBreakdownSelected</emxUtil:i18n>");
        </script>
     <%
	}else if(isFrozen){
	    		%>
	            <script language="javascript" type="text/javaScript">
	                  alert("<emxUtil:i18n localize='i18nId'>DMCPlanning.Delete.FrozenState</emxUtil:i18n>");
	            </script>
	         <%
	}else if(!isLastNode){
	    		%>
	            <script language="javascript" type="text/javaScript">
	                  alert("<emxUtil:i18n localize='i18nId'>DMCPlanning.Delete.NonLastNode</emxUtil:i18n>");
	            </script>
	         <%
    }else{
    	try{
    	   ManufacturingPlan.delete(context, new StringList(arrObjIds));
           action = "removeandrefresh";
         }catch(Exception e){
           bIsError=true;
           action = "error";
           msg = e.getMessage();                                      
         }
                    out.clear();
                    response.setContentType("text/xml");
                   %>
                   <mxRoot>
                       <!-- XSSOK -->                   
                       <action><![CDATA[<%= action %>]]></action>
                       <!-- XSSOK -->
                       <message><![CDATA[    <%= msg %>    ]]></message>    
                   </mxRoot>
                   <% 
    		}
   %>
