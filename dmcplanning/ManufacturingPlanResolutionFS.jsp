<%--  ManufacturingPlanResolutionFS.jsp  -   FS page for Manufacturing Plan feature select resolution page

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or
  intended publication of such program

  static const char RCSID[] = "$Id: /web/dmcplanning/ManufacturingPlanResolutionFS.jsp 1.1 Thu Dec 18 14:36:21 2008 GMT ds-pborgave Experimental$";

--%>
<%@include file = "../emxUICommonAppInclude.inc"%>  

<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<%
    String appendParams = emxGetQueryString(request);
	String strMode = emxGetParameter(request,"mode");
   	String objectId = emxGetParameter(request,"objectId");
   	String parentOID = emxGetParameter(request,"parentOID");
   	String selObjId = emxGetParameter(request,"selObjId");
    
    String strHelpMarker = "";
//    if(strAction.equalsIgnoreCase("edit")){
//        strHelpMarker = "emxhelpeffectivitymatrixedit";
//    }else{
        strHelpMarker = "emxhelpeffectivitymatrixcreate";
//    }
    
    String strHeaderURL = "ManufacturingPlanResolutionHeader.jsp?title=Resolution&HelpMarker="+strHelpMarker;
    String strBodyURL = "ManufacturingPlanResolutionDialog.jsp?mode="+XSSUtil.encodeForURL(context,strMode)+"&objectId="+XSSUtil.encodeForURL(context,objectId)+"&parentOID="+XSSUtil.encodeForURL(context,parentOID)+"&selObjId="+XSSUtil.encodeForURL(context,selObjId)+"&"+XSSUtil.encodeForURL(context,appendParams);
    String strFooterURL = "ManufacturingPlanResolutionFooter.jsp?" + appendParams;
    
%>  

  <frameset rows="85,*,65,0" framespacing="0" frameborder="no" border="0">
       <frame name="pageheader" src="<%=XSSUtil.encodeURLwithParsing(context,strHeaderURL)%>" noresize="noresize" marginheight="10" marginwidth="10" border="0" frameborder="no" scrolling="no" framespacing="5"/>
       <frame name="pagecontent" src="<%=XSSUtil.encodeURLwithParsing(context,strBodyURL)%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"  framespacing="5"/>
       <frame name="pagesignature" src="<%=XSSUtil.encodeURLwithParsing(context,strFooterURL)%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>
       <frame name="pagehidden" src="" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>
  </frameset>
