<%--  emxCommonFS.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.   Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxCommonFS.jsp.rca 1.16 Wed Oct 22 16:18:47 2008 przemek Experimental przemek $";
--%><%@page import = "com.matrixone.apps.domain.*,
				  com.matrixone.apps.domain.util.*,
				  com.matrixone.apps.framework.ui.*"%>
<%@include file="../emxUITopInclude.inc"%><%@include file="emxCommonFSUtil.inc"%><%

/*

Typical Instance Definition
< suite Key > . < Instance Name > . < option > = < value >
eServiceSuiteSpecificationCentral.CreateATS.heading=eServiceSuiteSpecificationCentral.CreateATS.heading
eServiceSuiteSpecificationCentral.CreateATS.buttons =Done,Cancel
eServiceSuiteSpecificationCentral.CreateATS.options=false|false|false
eServiceSuiteSpecificationCentral.CreateATS.contentURL=emxSpecCentralSpecCreateATSDialog.jsp

Command Href:
${COMPONENT_DIR}/emxCommonFS.jsp?functionality=CreateATS

*/

try{
  // Read and store all the parameters passed
  String sFunctionality = emxGetParameter(request, "functionality");
  if (sFunctionality == null) {
    throw new FrameworkException("The parameter 'functionality' should be provided");
  }

  String strMultipleTableRowId = emxGetParameter(request, "multipleTableRowId");
  StringBuffer sQueryString = new StringBuffer();
  Enumeration eNumParameters = emxGetParameterNames(request);
  while( eNumParameters.hasMoreElements() ) {
    String strParamName = (String)eNumParameters.nextElement();
    String strParamValue = null;
    if ("true".equalsIgnoreCase(strMultipleTableRowId) && "emxTableRowId".equals(strParamName)) {
      // If multiple table row-id is expected then concatenate using comma seperator
      String[] strParamValues = emxGetParameterValues(request,  strParamName);
      StringBuffer tmpStrBuf = new StringBuffer();
      if (strParamValues!= null) {
        for(int i=0; i<strParamValues.length; i++) {
          tmpStrBuf.append(",");
          tmpStrBuf.append(strParamValues[i]);
        }
        // Remove the first comma seperator
        tmpStrBuf.deleteCharAt(0);
        strParamValue = tmpStrBuf.toString();
      }
    } else {
      strParamValue = emxGetParameter( request,  strParamName);
    }
    if(strParamValue != null){
		strParamValue = FrameworkUtil.findAndReplace(strParamValue,"&","%26");
    }
    sQueryString.append("&" + strParamName + "=" + strParamValue);
  }
  sQueryString.deleteCharAt(0);

  String sSuiteKey = XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "suiteKey"));
  if (sSuiteKey == null) {
    throw new FrameworkException("The parameter 'suiteKey' should be provided");
  }
  if (sSuiteKey.indexOf("eServiceSuite") != 0){
      sSuiteKey = "eServiceSuite" + sSuiteKey;
  }
  // Initialize the frameset object to bring up the dialog page
  framesetObject fs = new framesetObject();

  // Obtain the object id
  String strObjectId= emxGetParameter(request, "objectId");
  if (strObjectId != null) {
    fs.setObjectId ( strObjectId );
  }
  // Define the Propery file String Resource
  String sStrResNameKey = sSuiteKey + ".StringResourceFileId";
  String sStrResName = EnoviaResourceBundle.getProperty(context,sStrResNameKey);
  fs.setStringResourceFile(sStrResName);

  // Sets the application directory
  String sAppDirectory = EnoviaResourceBundle.getProperty(context,sSuiteKey + ".Directory");
  fs.setDirectory(sAppDirectory);

  String sKeyPrefix = XSSUtil.encodeForJavaScript(context, sFunctionality);

  String sHeadingKey = sSuiteKey + "." + sKeyPrefix + ".heading";
  String sHeading = emxGetParameter(request,"heading");
  if(sHeading == null)
  {
    sHeading = EnoviaResourceBundle.getProperty(context,sHeadingKey).trim();
  }

  // Get content url
  String sContentURLKey = sSuiteKey + "." + sKeyPrefix + ".contentURL";
  String sContentURL = EnoviaResourceBundle.getProperty(context,sContentURLKey).trim();
  sContentURL =  "../" + sAppDirectory + "/" + sContentURL + "?" + sQueryString;

  // Get help string
  String sHelpStrKey = sSuiteKey + "." + sKeyPrefix + ".help";
  String sHelpStr = emxGetParameter(request,"help");
  if(sHelpStr == null)
  {
    sHelpStr = EnoviaResourceBundle.getProperty(context,sHelpStrKey).trim();
  }
  

  //Get the required Notice
    boolean bRequiredNotice = true;
    String strrequiredNoticeKey = sSuiteKey + "." + sKeyPrefix + ".requiredNotice";


    //This property is not expected in the property file.Hence the method getProperty  throws and exception when the key is not found
    //When an exception is encountered the required notice is not shown.
   String strrequiredNotice = null;
    try
    {
       strrequiredNotice = EnoviaResourceBundle.getProperty(context,strrequiredNoticeKey);
    }catch(FrameworkException e){
        strrequiredNotice = "false";
    }

    if(strrequiredNotice == null || strrequiredNotice.equals(""))
    {

      bRequiredNotice = true;
    }
    else if(strrequiredNotice.equals("false"))
    {
      bRequiredNotice = false;
    }
    else
    {
      bRequiredNotice = true;
    }

  if (sHelpStr == null) {
    sHelpStr = "";
  }

  // Get "PrinterFriendly", "ShowPagination", "ShowConversion" configurations
  String sOptionsKey = sSuiteKey + "." + sKeyPrefix + ".options";
  String sOptions = EnoviaResourceBundle.getProperty(context,sOptionsKey).trim();
  if (sOptions == null) {
    sOptions = "";
  }
  StringTokenizer st = new StringTokenizer(sOptions, "|");
  boolean bPrinterFriendly = true;
  boolean bShowPagination = true;
  boolean bShowConversion = false;
  if (st.hasMoreTokens()) {
    bPrinterFriendly = Boolean.parseBoolean(st.nextToken());
    if (st.hasMoreTokens()) {
      bShowPagination = Boolean.parseBoolean(st.nextToken());
      if (st.hasMoreTokens()) {
        bShowConversion = Boolean.parseBoolean(st.nextToken());
      }
    }
  }

  // Get button name keys
  String sButtonsKey = sSuiteKey + "." + sKeyPrefix + ".buttons";
  //String sButtons = getApplicationProperty(application, sSuiteKey, sButtonsKey);
  String sButtons = EnoviaResourceBundle.getProperty(context,sButtonsKey).trim();
  if (sButtons == null) {
    sButtons = "";
  }
  java.util.List buttonNameKeys = new ArrayList();
  st = new StringTokenizer(sButtons, ",");
  while (st.hasMoreTokens()) {
    buttonNameKeys.add(st.nextToken());
  }


  // Get button roles
  java.util.List buttonRoles = new ArrayList();
  for (int iIndex=0; iIndex<buttonNameKeys.size(); iIndex++) {
    String sKey = sSuiteKey + "." + sKeyPrefix + ".buttons." + buttonNameKeys.get(iIndex) + ".roles";
    String sButRoles = null;

    try{
      sButRoles = EnoviaResourceBundle.getProperty(context,sKey).trim();
    }catch(Exception noroles){
      sButRoles = "role_GlobalUser";
    }

    if (sButRoles == null || "".equals(sButRoles)) {
      sButRoles = "role_GlobalUser";
    }

    buttonRoles.add(sButRoles);
    }


  // Initialize the frameset
  fs.initFrameset(sHeading,sHelpStr,sContentURL,bPrinterFriendly,true,bShowPagination,bShowConversion);

// get the header links
String sHeaderLinksKey = sSuiteKey + "." + sKeyPrefix +".header.links";
String sHeaderLinks = null;
  try {
 sHeaderLinks = EnoviaResourceBundle.getProperty(context,sHeaderLinksKey).trim();
} catch (Exception e){
   sHeaderLinks = "";
}

// tokenize the links into an arraylist
  java.util.List lstHeaderLinkNameKeys = new ArrayList();
  st = new StringTokenizer(sHeaderLinks, ",");
  while (st.hasMoreTokens()) {
    lstHeaderLinkNameKeys.add(st.nextToken());
  }

String sLinkName = null;
String sLinkNameKey = null;
String sLinkRoles = null;

// get the roles associated with each link
 java.util.List headerLinkRoles = new ArrayList();
  for (int iIndex=0; iIndex<lstHeaderLinkNameKeys.size(); iIndex++) {
    String sKey = sSuiteKey + "." + sKeyPrefix + ".header.links." + lstHeaderLinkNameKeys.get(iIndex) + ".roles";

    try{
      sLinkRoles = EnoviaResourceBundle.getProperty(context,sKey).trim();
    }catch(Exception noroles){
      sLinkRoles = "role_GlobalUser";
    }

    if (sLinkRoles == null || "".equals(sLinkRoles)) {
      sLinkRoles = "role_GlobalUser";
    }

    headerLinkRoles.add(sLinkRoles);
  }

// add the links to the header
for (int iIndex=0; iIndex < lstHeaderLinkNameKeys.size(); iIndex++) {
sLinkName = (String)lstHeaderLinkNameKeys.get(iIndex);
sLinkNameKey = "emxCommonLink." + sLinkName;
sLinkRoles = (String)headerLinkRoles.get(iIndex);
fs.createHeaderLink(sLinkNameKey, "action"+sLinkName+"()", sLinkRoles,
      false,true, "../common/images/iconSmallCategory.gif", 3);

}




  // Configure the buttons in the bottom action bar
  for (int iIndex=0; iIndex < buttonNameKeys.size(); iIndex++) {
    String sButName = (String)buttonNameKeys.get(iIndex);
    String sButNameKey = "emxCommonButton." + sButName;
    String sButRoles = (String)buttonRoles.get(iIndex);

    String sJs = null;
    String sImage = null;
    if (sButName.equals("Done")) {
      sJs = "submit()";
      sImage = "common/images/buttonDialogDone.gif";
    }
    else if (sButName.equals("Cancel")) {
		if(sQueryString.indexOf("targetLocation=slidein") != -1){
    		 sJs = "closeSlideInDialog()";
    	}else{
      sJs = "closeWindow()";
    	}
      sImage = "common/images/buttonDialogCancel.gif";
    }
    else if (sButName.equals("Previous")) {
      sJs = "movePrevious()";
      sImage = "common/images/buttonDialogPrevious.gif";
    }
    else if (sButName.equals("Next")) {
      sJs = "moveNext()";
      sImage = "common/images/buttonDialogNext.gif";
    }  
   else if (sButName.equals("Apply")) {
          sJs = "apply()";
          sImage = "common/images/buttonDialogApply.gif";
    }
    else if (sButName.equals("CreateIssue")) {
          sJs = "apply()";
          sImage = "common/images/buttonDialogApply.gif";
    }
    else if (sButName.equals("ClearAll")) {
          sJs = "clearAll()";
          sImage = "common/images/buttonDialogApply.gif";
    }

    fs.createFooterLink(sButNameKey, sJs, sButRoles,
      false, true, sImage, 3);
  }

  //To remove the dialog warning depending on the property file entry
  //if there is no entry then the dialog warning will not be shown
  if(!bRequiredNotice)
  {
      fs.removeDialogWarning();
  }
		String pageTitle = EnoviaResourceBundle.getProperty(context, sStrResName , context.getLocale(), sHeading);
		fs.setPageTitle(pageTitle);
  
  // Send the output to the browser
  fs.writePage(out);

}catch(Exception e){
%>
  <html><body>
  <br/><br/>
    <b>Error in emxCommonFS.jsp URL or instance configuration:</b> <br/><br/>Exception: <%=e%><br/><br/>
    Possible causes include:<br/>
    1. Missing String in property file<br/>
    2. Incorrect Suite Key<br/>
    3. Instance definition in app property file is incorrect<br/>
  </body></html>
<%
}
%>
