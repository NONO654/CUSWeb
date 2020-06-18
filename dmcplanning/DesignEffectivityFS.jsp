<%--  DesignEffectivityFS.jsp  -   FS page for Product Configuration feature select page

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or
  intended publication of such program

  static const char RCSID[] = "$Id: /web/dmcplanning/DesignEffectivityFS.jsp 1.1 Thu Dec 18 14:36:21 2008 GMT ds-pborgave Experimental$";

--%>
<%@include file = "../emxUICommonAppInclude.inc"%>  

<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<%
    String appendParams = emxGetQueryString(request);
    String strFromContext = emxGetParameter(request,"fromcontext");
    String strFunctionality = emxGetParameter(request, "functionality");
    String strAction = emxGetParameter(request, "PRCFSParam2");
   	String objectId = emxGetParameter(request,"objectId");
	String createRevise = emxGetParameter(request,"createRevise");
	String strParentProductID = emxGetParameter(request,"ParentProductID");
	String productEffectivityId = objectId;
    
    String strHelpMarker = "";
    if(strAction.equalsIgnoreCase("edit"))
    {
        strHelpMarker = "emxhelpeffectivitymatrixedit";
       
        
    } else {
        strHelpMarker = "emxhelpeffectivitymatrixcreate";
      
    }

    String strHeaderURL = "DesignEffectivityHeader.jsp?title=Product Revision&HelpMarker="+strHelpMarker+"&functionality=" + XSSUtil.encodeForURL(context,strFunctionality);
    String strFooterURL = "DesignEffectivityFooter.jsp?" + appendParams;
    String strBodyURL = "DesignEffectivityFeaturesTableDialog.jsp?fromcontext="+XSSUtil.encodeForURL(context,strFromContext)+"&objectId="+XSSUtil.encodeForURL(context,objectId)+"&createRevise="+XSSUtil.encodeForURL(context,createRevise)+"&ParentProductID="+XSSUtil.encodeForURL(context,strParentProductID)+"&PRCFSParam2="+strAction+"&productEffectivityId="+XSSUtil.encodeForURL(context,productEffectivityId)+"&" + XSSUtil.encodeForURL(context,appendParams);

%>  

  <frameset rows="100,*,55,0" framespacing="0" frameborder="no" border="0">
       <frame name="pageheader" src="<%=XSSUtil.encodeURLwithParsing(context,strHeaderURL)%>" noresize="noresize" marginheight="10" marginwidth="10" border="0" frameborder="no" scrolling="no" framespacing="5"/>
       <frame name="pagecontent" src="<%=XSSUtil.encodeURLwithParsing(context,strBodyURL)%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"  framespacing="5"/>
       <frame name="pagesignature" src="<%=XSSUtil.encodeURLwithParsing(context,strFooterURL)%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>
       <frame name="pagehidden" src="" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>
  </frameset>
