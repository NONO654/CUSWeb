<%-- emxJobProcessFS.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxJobProcessFS.jsp.rca 1.1.2.1.1.4 Wed Oct 22 15:48:58 2008 przemek Experimental przemek $
--%>
<%@include file= "emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<%
    String appDirectory=(String)EnoviaResourceBundle.getProperty(context, "eServiceSuiteFramework.Directory");
    

    framesetObject fs = new framesetObject();
    fs.setDirectory(appDirectory);
    fs.setSubmitMethod(request.getMethod());

    String objectId     = emxGetParameter(request,"objectId");
    String submitURL     = emxGetParameter(request,"submitURL");
    String submitURLTarget     = emxGetParameter(request,"submitURLTarget");
    if(submitURL == null || "null".equalsIgnoreCase(submitURL) ){
    	submitURL = "" ; 
    } 
    fs.setObjectId(objectId);
    if(submitURLTarget == null || "null".equalsIgnoreCase(submitURLTarget) ){
    	submitURLTarget = "" ; 
    } 

    // Specify URL to come in middle of frameset
    String contentURL = "emxJobProcess.jsp";
    // add these parameters to each content URL, and any others the App needs
    contentURL += "?objectId=" + objectId + "&submitURL="+submitURL+"&submitURLTarget="+submitURLTarget;

    // Page Heading - Internationalized
    String PageHeading  = "emxFramework.JobMonitor.Heading";

    // Marker to pass into Help Pages icon launches new window with help frameset inside
    String HelpMarker = "emxhelpjobproperties";

    fs.initFrameset(PageHeading,HelpMarker,contentURL,false,false,false,false);
    fs.setStringResourceFile("emxFrameworkStringResource");
    fs.setCategoryTree(emxGetParameter(request,"categoryTreeName"));
    fs.writePage(out);
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
