<%--  emxCommonRouteTemplateRevise.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDocumentRevise.jsp.rca 1.14 Wed Oct 22 16:18:27 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>

<%
  //get document Id
  	String objectId = emxGetParameter(request, "objectId");
	String revisionId =objectId;
  if( objectId != null)
  {
    try
    {
    	RouteTemplate routetemplate = (RouteTemplate)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE_TEMPLATE);
    	routetemplate.setId(objectId);
    	revisionId = routetemplate.revise(context);
    	
    } catch (Exception ex)
    {
        session.setAttribute("error.message" , ex.toString());
    }
  }
%>
<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" >
function replaceObjectId(strHref,newObjectId)//function Added for Bug : 373517
{
        var stringIndex = strHref.indexOf("objectId=");     
        var startString = strHref.substring(0,stringIndex);
        var endString = strHref.substring(stringIndex,strHref.length);
        stringIndex = endString.indexOf("&");
        if (stringIndex>0)
        {
            endString = endString.substring(stringIndex,endString.length); 
        }
        else
        {
            endString = "";
        }
        strHref = startString+"objectId="+newObjectId+endString;
return strHref;
}
</script>
<script language="Javascript" >
  var frameContent = openerFindFrame(getTopWindow(),"detailsDisplay");
  var contentFrame = openerFindFrame(getTopWindow(), "content");
  //To update the count  
  if(contentFrame && contentFrame.document.location.href.indexOf("emxTree.jsp") >= 0){
	   //refresh complete tree
	   contentFrame.document.location.href = replaceObjectId(contentFrame.document.location.href,'<%=XSSUtil.encodeForJavaScript(context, revisionId)%>');
   } else {   
		frameContent.document.location.href = frameContent.document.location.href;
		if(getTopWindow().opener && getTopWindow().opener.getTopWindow().RefreshHeader){
			getTopWindow().opener.getTopWindow().RefreshHeader();      
		}else if(getTopWindow().RefreshHeader){
			getTopWindow().RefreshHeader();     
		}
   }

   
</script>

</body>
</html>
<%
   // } //check if doc Id is null
%>
