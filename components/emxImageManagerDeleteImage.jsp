<%--  emxComponentUnlockDocument.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxImageManagerDeleteImage.jsp.rca 1.1.2.6 Wed Oct 22 16:18:53 2008 przemek Experimental przemek $
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="javax.json.*"%>

<%

  String[] fileNames = emxGetParameterValues(request, "emxTableRowId");
    int fileNamesLength = fileNames.length;
    StringBuffer strBuffAltPathImages = new StringBuffer();
    StringList strListDelete = new StringList();
    String traveseAttValue = "";
    String isPrimaryFromAltPath = "No";
    String primaryImage = "";
    String imageHolderId = null;

    String ATTRIBUTE_TRAVERSE_ALTPATH = PropertyUtil.getSchemaProperty(context,"attribute_TraverseAltPath");
    String PRIMARY_IMAGE_FROM_ALTPATH = PropertyUtil.getSchemaProperty(context,"attribute_PrimaryImageFromAltPath");
    String ATTR_PRIMARY_IMAGE = PropertyUtil.getSchemaProperty(context,"attribute_PrimaryImage");

    for(int i=0; i < fileNamesLength; i++)
    {
        String strFileName = fileNames[i];
        String strTemp = "";
        int pipeIndex = strFileName.indexOf("|");
        if (pipeIndex != -1)
        {
            strTemp = strFileName.substring(0, pipeIndex);
            strFileName = strFileName.substring(pipeIndex+1, strFileName.length());
        }
        if ("AltPath".equalsIgnoreCase(strTemp))
        {
            if(strBuffAltPathImages.length() > 0)
            {
                strBuffAltPathImages.append(", ");
            }
            strBuffAltPathImages.append(strFileName);
        }
        else
        {
            strListDelete.add(strFileName);
        }
    }
try
{
        int strListDeleteSize = strListDelete.size();
        if (strListDeleteSize > 0)
        {
            String [] delFilesArray = new String [strListDeleteSize];
            for (int j=0; j < strListDeleteSize; j++)
            {
                delFilesArray[j] = (String)strListDelete.get(j);
            }
            String objectId = emxGetParameter(request, "objectId");
            DomainObject object = DomainObject.newInstance(context, objectId);
            Image image = object.getImageObject(context);
            StringList selList = new StringList();
            selList.add(ATTRIBUTE_TRAVERSE_ALTPATH);
            selList.add(PRIMARY_IMAGE_FROM_ALTPATH);
            selList.add(ATTR_PRIMARY_IMAGE);

            AttributeList imageHolderAttrValues = (AttributeList) image.getAttributeValues(context,selList);
            traveseAttValue = ((Attribute)imageHolderAttrValues.get(0)).getValue();
            isPrimaryFromAltPath = ((Attribute)imageHolderAttrValues.get(1)).getValue();
            primaryImage = ((Attribute)imageHolderAttrValues.get(2)).getValue();
            boolean isPrimaryImageDeleted = primaryImage == null || primaryImage.equals("");
            
            if(!isPrimaryImageDeleted) {
                String primaryImageBasePart = com.matrixone.apps.common.util.ImageManagerUtil.getFileBaseName(primaryImage);
                for (int i = 0; i < delFilesArray.length; i++) {
                    if(primaryImageBasePart.equals(com.matrixone.apps.common.util.ImageManagerUtil.getFileBaseName(delFilesArray[i]))) {
                        isPrimaryImageDeleted = true;
                        break;
                    }
                }
            } 
            
            image.deleteImages(context, delFilesArray);
            imageHolderId = object.getInfo(context, DomainObject.SELECT_IMAGE_HOLDER_ID);
            if (imageHolderId !=null && !"".equals(imageHolderId) && !"null".equals(imageHolderId))
            {
                if (strListDelete.contains(primaryImage))
                {
                    String xmlFormat = PropertyUtil.getSchemaProperty(context,"format_3DXML");
                    String xmlFormatName = "format["+xmlFormat+"].file.name";
                    StringList xmlImages=image.getInfoList(context,xmlFormatName);
                    primaryImage = (String)image.getAttributeValue(context,ATTR_PRIMARY_IMAGE);
                    if(primaryImage!=null && !"".equals(primaryImage.trim()))
                    {
                        int extIndex = primaryImage.lastIndexOf(".");
                        if(extIndex!=-1)
                        {
                            String temp3dxmlFileName = primaryImage.substring(0,extIndex)+".3dxml";
                            if(xmlImages!=null && xmlImages.contains(temp3dxmlFileName))
                            {
                                image.setAttributeValue(context, ATTR_PRIMARY_IMAGE, temp3dxmlFileName);
                            }
                        }
                    }

                }

            }
            if (imageHolderId == null || "null".equals(imageHolderId) || "".equals(imageHolderId) )
            {
                if (traveseAttValue.equalsIgnoreCase("No") || (traveseAttValue.equalsIgnoreCase("Yes") && isPrimaryFromAltPath.equalsIgnoreCase("Yes"))) {
                    DomainObject imageObject = DomainObject.newInstance(context, DomainObject.TYPE_IMAGE_HOLDER);
                    ContextUtil.pushContext(context);
                    imageObject.createAndConnect(context, DomainObject.TYPE_IMAGE_HOLDER, DomainObject.RELATIONSHIP_IMAGE_HOLDER, object, false);
                    ContextUtil.popContext(context);
                    StringList selects = new StringList(2);
                    selects.add(DomainObject.SELECT_ID);
                    Map objectSelectMap = imageObject.getInfo(context,selects);
                    imageHolderId = (String)objectSelectMap.get(DomainObject.SELECT_ID);
                    Map attValue = new Hashtable();
                    attValue.put(ATTRIBUTE_TRAVERSE_ALTPATH,traveseAttValue);
                    attValue.put(PRIMARY_IMAGE_FROM_ALTPATH,isPrimaryFromAltPath);
                    if(isPrimaryFromAltPath.equalsIgnoreCase("Yes"))
                    {
                        attValue.put(ATTR_PRIMARY_IMAGE,primaryImage);
                    }
                    imageObject.setAttributeValues(context, attValue);
                }
            }
        }
} catch (Exception ex)
{
    session.setAttribute("error.message" , ex.toString());
}

if(request.getHeader("Accept").toLowerCase().indexOf("json") > -1){
	JsonObjectBuilder outputBuilder = Json.createObjectBuilder();

	
	if(session.getAttribute("error.message") != null){
        String emxSessionErrorMsg = (String)session.getAttribute("error.message");
        session.removeAttribute("error.message");
        outputBuilder.add("action", "error");
        outputBuilder.add("message", EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", "emxComponents.3dxml.CannotDeleteImage", sLanguage) + ":\n" + emxSessionErrorMsg);
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
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript" >
<%
    String strAltPathImages = strBuffAltPathImages.toString();
    if (strAltPathImages.length() > 0)
    {
%>
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.3dxml.CannotDeleteImage</emxUtil:i18nScript>");
<%
    }
%>
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
<%}%>

