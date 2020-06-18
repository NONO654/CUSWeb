<%--  emxImageManagerSetTraverseAltPath.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program


--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>

<%

try
{
	String objectId = emxGetParameter(request, "objectId");
	String altPathToggleValue = emxGetParameter(request, "toggleValue");
	DomainObject object = null;
	String imageHolderId = null;
	if ( objectId != null && !"null".equals(objectId) && !"".equals(objectId) )
	{
		object = DomainObject.newInstance(context, objectId);
		imageHolderId = object.getInfo(context, DomainObject.SELECT_IMAGE_HOLDER_ID);
	}
	String ATTRIBUTE_TRAVERSE_ALTPATH = PropertyUtil.getSchemaProperty(context,"attribute_TraverseAltPath"); 
	DomainObject imageObject = null;
	if (imageHolderId == null || "null".equals(imageHolderId) || "".equals(imageHolderId) )
	{
		imageObject = DomainObject.newInstance(context, DomainObject.TYPE_IMAGE_HOLDER);
		ContextUtil.pushContext(context);
		imageObject.createAndConnect(context, DomainObject.TYPE_IMAGE_HOLDER, DomainObject.RELATIONSHIP_IMAGE_HOLDER, object, false);
		ContextUtil.popContext(context);
		StringList selects = new StringList(2);
		selects.add(DomainObject.SELECT_ID);
		Map objectSelectMap = imageObject.getInfo(context,selects);
		imageHolderId = (String)objectSelectMap.get(DomainObject.SELECT_ID);
		
	} else
	{
		imageObject = DomainObject.newInstance(context, imageHolderId);
	}
	imageObject.setAttributeValue(context, ATTRIBUTE_TRAVERSE_ALTPATH, altPathToggleValue);
} catch (Exception ex)
{
	session.setAttribute("error.message" , ex.toString());
	System.out.println("error.message"+ ex.toString());
}
%>
<html>
<body>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" >
      var frameContent = findFrame(getTopWindow(),"detailsDisplay");	
      if (frameContent != null ) {
        frameContent.document.location.href = frameContent.document.location.href;
      } else {
    	parent.document.location.href = parent.document.location.href;
      }
</script>

</body>
</html>

