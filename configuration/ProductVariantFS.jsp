<%--
  ProductVariantFS.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>  

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<%
    String appendParams = emxGetQueryString(request);
    String strobjectId  = XSSUtil.encodeForURL(context,emxGetParameter(request, "objectId"));
    String relId = XSSUtil.encodeForURL(context,emxGetParameter(request, "relId"));
    String strVariantName = XSSUtil.encodeForURL(context,emxGetParameter(request, "variantName"));
    String jsTreeID = XSSUtil.encodeForURL(context,emxGetParameter(request, "jsTreeID"));
    String strProductVariantId = XSSUtil.encodeForURL(context,emxGetParameter(request, "productVariantId"));
    String strIsClone = XSSUtil.encodeForURL(context,emxGetParameter(request, "clone"));
    String strMode = XSSUtil.encodeForURL(context,emxGetParameter(request, "mode"));
    String strContext = XSSUtil.encodeForURL(context,emxGetParameter(request, "context"));
    String strFunctionality = XSSUtil.encodeForURL(context,emxGetParameter(request, "functionality"));
    String strproductId = XSSUtil.encodeForURL(context,emxGetParameter(request, "parentID"));
    String selectedData = XSSUtil.encodeForURL(context,emxGetParameter(request, "selectedData"));
    
    String strSelectedFeatures = emxGetParameter(request, "selectedFeatures");
    String strHelpMarker = "";
    
    if(strMode.equalsIgnoreCase("edit"))
    {
        strHelpMarker = "emxhelpproductvariantedit";
    } else {
        strHelpMarker = "emxhelpproductvariantcreate";
    }
    

    String strTimeStamp = emxGetParameter(request, "timeStamp");

    String strBodyURL = null;

    String strFooterURL = "ProductVariantFooter.jsp?" + appendParams;
    String strHeaderURL = "ProductRevisionHeader.jsp?title=Product Revision&HelpMarker="+strHelpMarker+"&functionality=" + strFunctionality;

	if (strMode.equalsIgnoreCase("edit"))
	{
	    strBodyURL = "../configuration/ProductVariantContentFSDialog.jsp?objectId="+strobjectId+"&parentID="+strproductId+"&mode=editOptions&productEffectivityId="+strobjectId+"&selectedData="+selectedData;
	}
	else if (strMode.equalsIgnoreCase("viewEdit"))
	{
		if (strProductVariantId!=null)
		{
		   strBodyURL = "../configuration/ProductVariantContentFSDialog.jsp?objectId="+strobjectId+"&mode="+strMode+"&productVariantId="+strProductVariantId+"&selectedData="+selectedData;
		}
		else{
		    
		    strBodyURL = "../configuration/ProductVariantContentFSDialog.jsp?objectId="+strobjectId+"&mode="+strMode+"&variantName=All&selectedData="+selectedData;
		}
		
	}
	else
	{
		strproductId = strobjectId;
	    strBodyURL = "../configuration/ProductVariantContentFSDialog.jsp?objectId="+strobjectId+"&parentID="+strproductId+"&relId="+relId+"&variantName="+strVariantName+"&jsTreeID="+jsTreeID+"&productVariantId="+strProductVariantId+"&clone="+strIsClone+"&mode=create&context="+strContext+"&selectedFeatures="+XSSUtil.encodeForURL(context,strSelectedFeatures)+"&timeStamp="+strTimeStamp+"&selectedData="+selectedData;
	}
	
	
%>
   <frameset rows="100,*,50,0" framespacing="0" frameborder="no" border="0">
       <frame name="pageheader" src="<%=XSSUtil.encodeForHTMLAttribute(context,strHeaderURL)%>" noresize="noresize" marginheight="10" marginwidth="10" border="0" frameborder="no" scrolling="no" framespacing="5"/>
       <frame name="pagecontentBody" src="<%=XSSUtil.encodeForHTMLAttribute(context,strBodyURL)%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"  framespacing="5" />
       <frame name="pagefooter" src="<%=XSSUtil.encodeForHTMLAttribute(context,strFooterURL)%>" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>
       <frame name="pagehidden" src="" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"/>

  </frameset>
