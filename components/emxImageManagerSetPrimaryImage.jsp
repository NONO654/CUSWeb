<%--  emxComponentUnlockDocument.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxImageManagerSetPrimaryImage.jsp.rca 1.1.2.6 Wed Oct 22 16:18:05 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="javax.json.*"%>

<%

  String fileName = emxGetParameter(request, "emxTableRowId");
	boolean isPushed = false;
	String imageFromAltPath = "No";
	int pipeIndex = fileName.indexOf("|");
	if (pipeIndex != -1)
	{
		if ("AltPath".equals(fileName.substring(0, pipeIndex)))
		{
			imageFromAltPath = "Yes";
		}
		fileName = fileName.substring(pipeIndex+1, fileName.length());
	}
try
{

	    DomainObject object = DomainObject.newInstance(context, emxGetParameter(request, "objectId"));
  Image image = object.getImageObject(context);
	    if(image == null)
        {
            DomainObject imageObject = DomainObject.newInstance(context, DomainObject.TYPE_IMAGE_HOLDER);
            ContextUtil.pushContext(context);
            isPushed = true;
            imageObject.createAndConnect(context, DomainObject.TYPE_IMAGE_HOLDER, DomainObject.RELATIONSHIP_IMAGE_HOLDER, object, false);
            ContextUtil.popContext(context);
            isPushed = false;
            image = new Image(imageObject.getInfo(context, DomainConstants.SELECT_ID));
        }
       	String PRIMARY_IMAGE_FROM_ALTPATH = PropertyUtil.getSchemaProperty(context,"attribute_PrimaryImageFromAltPath"); 

		HashMap attrMap = new HashMap();	
        attrMap.put(DomainObject.ATTRIBUTE_PRIMARY_IMAGE, com.matrixone.apps.common.util.ImageManagerUtil.getPrimaryImageFileNameForImageManager(fileName));
        attrMap.put(PRIMARY_IMAGE_FROM_ALTPATH, imageFromAltPath);
        image.setAttributeValues(context, attrMap);		
} catch (Exception ex)
{
    session.setAttribute("error.message" , ex.toString());
}
%>
<%
if(request.getHeader("Accept").toLowerCase().indexOf("json") > -1){
	JsonObjectBuilder outputBuilder = Json.createObjectBuilder();

	
	if(session.getAttribute("error.message") != null){
        String emxSessionErrorMsg = (String)session.getAttribute("error.message");
        session.removeAttribute("error.message");
        outputBuilder.add("action", "error");
        outputBuilder.add("message", emxSessionErrorMsg);
	}
	else{
		outputBuilder.add("action", "success");
	}

	out.clear();
	response.setContentType("application/json; charset=UTF-8");
	out.write(outputBuilder.build().toString());
}
else{
%>
<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" >
  var frameContent = findFrame(getTopWindow(),"detailsDisplay");
      if (frameContent != null )
      {
        frameContent.document.location.href = frameContent.document.location.href;
      } else {
        parent.document.location.href = parent.document.location.href;
      }
</script>

</body>
</html>
<%} %>
