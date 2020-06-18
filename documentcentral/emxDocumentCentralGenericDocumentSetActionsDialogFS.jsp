<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">

<%--  emxDocumentCentralGenericDocumentSetActionsDialogFS.jsp

   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   Description: Create Frameset for Aactions page of Doc Create Wizard

   Parameters : nonFrmBeanAction - Tells, Whether the user is coming to this
                                  page by pressing cancel button or Next button
                Standard Matrix Parameters

   Author     : Anil KJ
   Date       : 01/11/2003
   History    :

   static const char RCSID[] = "$Id: emxDocumentCentralGenericDocumentSetActionsDialogFS.jsp.rca 1.18 Wed Oct 22 16:02:19 2008 przemek Experimental przemek $";
--%>

<%@include file = "../emxUIFramesetUtil.inc" %>
<%@include file = "emxLibraryCentralUtils.inc" %>

<%-- Parameters from previous page put in session in the form of FormBean --%>


<%
    // --------------Create Frameset Object------------------------------
    framesetObject fs = new framesetObject();
    fs.useCache(false);

    fs.setDirectory(appDirectory);

    String initSource = emxGetParameter(request,"initSource");

    if(initSource == null)
    {
        initSource = "";
    }
	String objectId = "";
	String parentId = "";
    String jsTreeID = "";
    String suiteKey = "";
    String objectAction = "";
  
  
    Map requestMap   = (HashMap)request.getAttribute("requestMap");
    if ( requestMap != null )
    {
        parentId = (String)requestMap.get("parentId");
        jsTreeID = (String)requestMap.get("jsTreeID");
        suiteKey = (String)requestMap.get("suiteKey");
        objectAction = (String)requestMap.get("objectAction");
    }
    
    Map objectMap   = (HashMap)request.getAttribute("objectMap");
    if( objectMap != null )
    {
    	if((!objectAction.trim().equals("create")))
    	{
    		objectId = (String)objectMap.get("objectId");
    	}
    	else
    	{
        	StringList objectIdList = (StringList)objectMap.get("objectId");
	        StringItr objectListItr = new StringItr(objectIdList);
    	    objectListItr.next();
        	objectId = objectListItr.obj();
    	}
    }

    // --------------Specify URL to come in middle of frameset-----------

    StringBuffer  sContentUrl = new StringBuffer(
      "../documentcentral/emxDocumentCentralGenericDocumentCreateWizardActionsDialog.jsp");
    sContentUrl.append("?suiteKey=" + suiteKey);
    sContentUrl.append("&initSource=" + initSource);
    sContentUrl.append("&jsTreeID=" + jsTreeID);
    sContentUrl.append("&objectId=" + objectId);
    sContentUrl.append("&parentId=" + parentId);
    sContentUrl.append("&contentPageIsDialog=false");

    String contentURL = sContentUrl.toString();

    // ------------------Page Header Token ------------------------------
    String pageHeading = "emxDocumentCentral.Common.Actions";
			   
    // ------------------Help Marker-----------------------------------------
    String helpMarker = "emxhelpcreatedocument3";
						
    // ------------------frameset call  ---------------------------------
    //(String pageHeading,String helpMarker, String middleFrameURL,
    //boolean UsePrinterFriendly, boolean IsDialogPage, boolean ShowPagination,
    //boolean ShowConversion)
    fs.initFrameset(pageHeading,helpMarker,contentURL,false,true,false,false);

    // ------------------Setting String Resource File  -------------------
    fs.setStringResourceFile("emxDocumentCentralStringResource");

    // Page Title
    //
    fs.setPageTitle (
           EnoviaResourceBundle.getProperty(context,"emxDocumentCentralStringResource",new Locale(sLanguage),"emxDocumentCentral.GenericDocumentCreateWizard.Title"
                    ));

    // ------------------ Buttons ----------------------------------------
    //(String displayString,String href,String roleList, boolean popup, boolean
    //isJavascript,String iconImage, boolean isTopLink, int WindowSize)
    fs.createCommonLink("emxDocumentCentral.Button.Done",
                        "submitForm()",
                        "role_GlobalUser",
                        false,
                        true,
                        "emxUIButtonDone.gif",
                        false,
                        3);

    fs.createCommonLink("emxDocumentCentral.Button.Cancel",
                        "closeWindow()",
                        "role_GlobalUser",
                        false,
                        true,
                        "emxUIButtonCancel.gif",
                        false,
                        3);
                   
    fs.writePage(out);
%>
