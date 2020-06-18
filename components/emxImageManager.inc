<%--  emxImagemanger.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

 --%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "com.matrixone.apps.framework.ui.UIUtil,com.matrixone.apps.common.util.ImageManagerUtil,com.matrixone.apps.common.util.ImageManagerImageInfo,com.matrixone.apps.domain.Image"%>
<%@ page import="com.matrixone.apps.common.Part" %>

<%
	String ATTR_TRAVERSE_ALTPATH = PropertyUtil.getSchemaProperty(context,"attribute_TraverseAltPath");
    String ATTR_TRAVERSE_ALTPATH_SEL = "attribute["+ATTR_TRAVERSE_ALTPATH+"]";
    String PRIMARY_IMAGE_FROM_ALTPATH   = PropertyUtil.getSchemaProperty(context, "attribute_PrimaryImageFromAltPath");
    String PRIMARY_IMAGE_FROM_ALTPATH_SEL   = "attribute["+PRIMARY_IMAGE_FROM_ALTPATH+"]";
    String ATTR_PRIMARY_IMAGE           = PropertyUtil.getSchemaProperty(context,"attribute_PrimaryImage");
    
    String defaultToolBar	= PropertyUtil.getSchemaProperty(context,"menu_APPImageManagerToolBar");

    String objectId         = (String)emxGetParameter(request, "objectId");
    String helpMarker       = emxGetParameter(request, "HelpMarker");
    String toolbar          = emxGetParameter(request, "toolbar");
    String portalMode       = emxGetParameter(request, "portalMode");
    String suiteKey         = emxGetParameter(request, "suiteKey");
    String strLanguage      = request.getHeader("Accept-Language");
    String thumbnailFormat  = PropertyUtil.getSchemaProperty(context,FrameworkProperties.getProperty(context,"emxComponents.ImageManager.ViewerThumbnailFormat"));
    String imageHeight      = PropertyUtil.getAdminProperty(context, "format", thumbnailFormat, "mxImageSize");
	String TYPE_PART       = PropertyUtil.getSchemaProperty("type_Part");

    if(UIUtil.isNotNullAndNotEmpty(objectId)){
        DomainObject dom = DomainObject.newInstance(context, objectId);
        if(DomainConstants.TYPE_COMPANY.equals(dom.getType(context))){
        	defaultToolBar	= PropertyUtil.getSchemaProperty(context,"menu_APPCompanyImageManagerToolBar");
        }
    }
	

    helpMarker = UIUtil.isNullOrEmpty(helpMarker) ? "imagemanager" : helpMarker;
    suiteKey = UIUtil.isNullOrEmpty(suiteKey) ? "Components" : 
		       suiteKey.startsWith("eServiceSuite") ? suiteKey.substring(13) : suiteKey;

    String suiteDir         = UINavigatorUtil.getRegisteredDirectory(context,suiteKey);
    String stringResFileId  = UINavigatorUtil.getStringResourceFileId(context,suiteKey);

    String header = emxGetParameter(request, "header");
    header = UIUtil.isNullOrEmpty(header) ? "emxComponents.Image.ImageManagerHeading" : header;
    header = EnoviaResourceBundle.getProperty(context, stringResFileId,context.getLocale(), header);

    if (header.indexOf("$") >= 0 )
    {
        if (objectId != null && objectId.length() > 0 )
        {
            header = UIExpression.substituteValues(context, pageContext, header, objectId);
        }
        else
        {
            header = UIExpression.substituteValues(context, header);
        }
    }

    String isPopup  = emxGetParameter(request, "targetLocation");
        isPopup = "popup".equalsIgnoreCase(isPopup) ? "true" : "false";
    
	StringList selectsList  = new StringList(3);
	selectsList.add(DomainObject.SELECT_PRIMARY_IMAGE_ID);
	selectsList.add(DomainObject.SELECT_TYPE);
	selectsList.add(DomainObject.SELECT_IMAGE_PRIMARY_IMAGE_NAME);

	DomainObject object                 = DomainObject.newInstance(context, objectId);
	String objectType  = FrameworkUtil.getAliasForAdmin(context, "type", object.getInfo(context, DomainObject.SELECT_TYPE), true);
	
	Image image   = object.getImageObject(context);
	Map imageSelectsInfo = null;
	if(image != null) {
		selectsList.clear();
		selectsList.add(Image.SELECT_PRIMARY_IMAGE);
		selectsList.add(Image.SELECT_HAS_MODIFY_ACCESS);
		selectsList.add("format.hasfile");
		selectsList.add(PRIMARY_IMAGE_FROM_ALTPATH_SEL);
		selectsList.add(ATTR_TRAVERSE_ALTPATH_SEL);
		imageSelectsInfo = image.getInfo(context, selectsList);
	} else {
	    imageSelectsInfo = new java.util.HashMap();
	}
	
    String parentAltPath = ImageManagerUtil.getAltPathFromParent(context, objectType);
    
    StringList altPathCADImages 		= new StringList();
    String[] altPathCADImageURLs    	= new String[0];
    String[] altPathCADThumbnailURLs	= new String[0];
    
    boolean showCheckbox = false;
    boolean showOutSideImages = true;
    String traverseAttValue = "";
    
    String specType ="";
    Map partSpecMap = null;
    Part part = null;
    if(object.isKindOf(context, TYPE_PART)){

  	    part = new Part(objectId);
		partSpecMap = part.getInfoMap(context);
		specType=(String)partSpecMap.get("type");
	}

	
    int primaryImageIndex = 0;
    if(!"".equals(parentAltPath) && !("emxComponents.3DXML.AltPath." + objectType).equals(parentAltPath)) {
        if (image != null ) {
            traverseAttValue    = (String)imageSelectsInfo.get(ATTR_TRAVERSE_ALTPATH_SEL);
        }
        showOutSideImages = !"No".equalsIgnoreCase(traverseAttValue);
        HashMap imageData  = UINavigatorUtil.getImageData(context, pageContext);
        ArrayList methodargs    = new ArrayList();
        methodargs.add(objectId);
        methodargs.add(imageData);
        methodargs.add(specType);

        HashMap imagesMap       = (HashMap)JPO.invoke(context, "emxImageManager", null, "getAltPathImages", JPO.packArgs(methodargs), HashMap.class);

        showCheckbox    = "true".equalsIgnoreCase((String)imagesMap.get("modifyAccess"));
        altPathCADImages       = (StringList)imagesMap.get("CADImages");
        
        if(showOutSideImages) {
            altPathCADImageURLs        = (String[])imagesMap.get("CADImageURLs");
            altPathCADThumbnailURLs    = (String[])imagesMap.get("CADThumbnailURLs");
        }
    } else {
        showOutSideImages   = false;
    }
    
    java.util.List altPathImageInfoList = ImageManagerUtil.getAltPathImageViewerData(context, 
            																	altPathCADImages, 
            																	altPathCADImageURLs, 
            																	altPathCADThumbnailURLs);
    java.util.List imageInfoList = null;
    
    boolean showHolderImages = image != null && ((String)imageSelectsInfo.get("format.hasfile")).equalsIgnoreCase("true");
    
    toolbar = (UIUtil.isNullOrEmpty(toolbar)) && ("No".equalsIgnoreCase(traverseAttValue)) ?
	           defaultToolBar : toolbar;

    if(showHolderImages) {
        toolbar = (UIUtil.isNullOrEmpty(toolbar)) ?
	 	           defaultToolBar : toolbar;
        
        String primaryImage        = (String)imageSelectsInfo.get(Image.SELECT_PRIMARY_IMAGE);
        showCheckbox        = "true".equalsIgnoreCase((String)imageSelectsInfo.get(Image.SELECT_HAS_MODIFY_ACCESS));
        String primaryImageFromAltPath = (String)imageSelectsInfo.get(PRIMARY_IMAGE_FROM_ALTPATH_SEL);
        HashMap imageData  = UINavigatorUtil.getImageData(context, pageContext);
        imageInfoList = ImageManagerUtil.getImageViewerData(context, image, imageData, "../common/images/brokenimage.png");
        
        if("Yes".equalsIgnoreCase(primaryImageFromAltPath)) {
            int indexInAltPath = ImageManagerUtil.getIndexOfImageInImageInfoList(altPathImageInfoList, primaryImage);
            if(showOutSideImages && indexInAltPath != -1) {
                primaryImageIndex = imageInfoList.size() + indexInAltPath;
            }
            else {
                ImageManagerImageInfo imageInfo = (ImageManagerImageInfo) imageInfoList.get(0);
                Map attValue    = new Hashtable();
                attValue.put(ATTR_PRIMARY_IMAGE, ImageManagerUtil.getPrimaryImageFileNameForImageManager(imageInfo.getImageName()));
                attValue.put(PRIMARY_IMAGE_FROM_ALTPATH, "No");
                image.setAttributeValues(context, attValue);
                primaryImageIndex =0;
          }
        } else {
            primaryImageIndex = ImageManagerUtil.getIndexOfImageInImageInfoList(imageInfoList, primaryImage);
        }
        
        if(showOutSideImages) {
            imageInfoList.addAll(altPathImageInfoList);
        }
    }
    else if (showOutSideImages && altPathCADImages != null && altPathCADImages.size() >0) {
        toolbar = (UIUtil.isNullOrEmpty(toolbar)) ? defaultToolBar : toolbar;
                
        if(image != null)  {
            String primaryImageFromAltPath = (String)imageSelectsInfo.get(PRIMARY_IMAGE_FROM_ALTPATH_SEL);

            if("Yes".equalsIgnoreCase(primaryImageFromAltPath)) {
                String primaryImage        = (String)imageSelectsInfo.get(Image.SELECT_PRIMARY_IMAGE);
                int indexInAltPath = ImageManagerUtil.getIndexOfImageInImageInfoList(altPathImageInfoList, primaryImage);
                if(indexInAltPath == -1) {
                    ImageManagerImageInfo imageInfo = (ImageManagerImageInfo) imageInfoList.get(0);
                    Map attValue    = new Hashtable();
                    attValue.put(ATTR_PRIMARY_IMAGE, ImageManagerUtil.getPrimaryImageFileNameForImageManager(imageInfo.getImageName()));
                    attValue.put(PRIMARY_IMAGE_FROM_ALTPATH, "No");
                    image.setAttributeValues(context, attValue);
                }  else {
                    primaryImageIndex = indexInAltPath;
                }
            }
        }
        imageInfoList = altPathImageInfoList;        
    } else {
        imageInfoList = ImageManagerUtil.getImageViewerDataFromPrimaryImageRelObject(context, pageContext, object);
        if(imageInfoList.size() != 0) {
            showCheckbox = false;
            String primaryImageName = object.getInfo(context, DomainObject.SELECT_IMAGE_PRIMARY_IMAGE_NAME);
            primaryImageIndex = ImageManagerUtil.getIndexOfImageInImageInfoList(imageInfoList,
                    		object.getInfo(context, DomainObject.SELECT_IMAGE_PRIMARY_IMAGE_NAME));
        }
    }

 //   StringBuffer url2 = new StringBuffer();
 //   url2.append("emxImageManagerSetTraverseAltPath.jsp?objectId=");
 //   url2.append(objectId);
    
    // Assign the class ?mainContent? on the <BODY> element in case of content page else assign ?dialog?.
    boolean isPopUpWin = "true".equalsIgnoreCase(isPopup);
    boolean hasImages = !(imageInfoList == null || imageInfoList.size() == 0);
    primaryImageIndex = hasImages ? primaryImageIndex : -1;
    String strBodyClass = isPopUpWin ? "dialog" : "mainContent"; 
    String prevButtonClass = hasImages ? "btn previous" : "btn previous disabled";
    String nextButtonClass = hasImages ? "btn next" : "btn next disabled";
%>
