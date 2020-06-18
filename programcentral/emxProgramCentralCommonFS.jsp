
<%--  emxProgramCentralCommonFS.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.   Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxProgramCentralCommonFS.jsp.rca 1.1.1.2.3.4 Tue Oct 28 18:55:16 2008 przemek Experimental przemek $
--%>

<%--
This page imports the required classes and defines some commonly
used methods
--%>

<%@include file="../emxUITopInclude.inc"%>
<%@include file="emxProgramCentralCommonFSUtil.inc"%>
<%@include file = "emxProgramGlobals2.inc" %>


<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  String objectId = "";
  String wizType = (String) emxGetParameter(request, "wizType");
  String buttonAction = (String) emxGetParameter(request,"p_button");
  String sFunctionality = emxGetParameter(request, "functionality");
  String sCharSet = Framework.getCharacterEncoding(request);
  String strPageName = (String) emxGetParameter(request,"pageName");
  String strProjectName = (String) emxGetParameter(request,"ProjectName");
  String strfromAction = (String) emxGetParameter(request,"fromAction");
  
  //
  // For navigation from import project summary page to project create dialog page, we do not
  // want the collected data in formBean to get cleared, as this data is essential when
  // Back button is clicked to navigate to import summary page.
  //
  
  if("CreateImportProjectSpaceStep3".equals(sFunctionality) && "Import".equals(wizType) && !"Back".equals(buttonAction)){
    formBean.processForm(session, request);
  }

  // Added for Related Projects
  String fromRelatedProjects = emxGetParameter(request,"fromRelatedProjects");
  String insertNewProject = emxGetParameter(request, "InsertNewProject");
  String insertExistingProject = emxGetParameter(request, "InsertExistingProject");

  String wizardType = emxGetParameter(request,"wizardType");
  String wizardPage = emxGetParameter(request,"wizardPage");

  String[] arrTableRowIds = emxGetParameterValues(request,"emxTableRowId");
  StringBuffer sbObjectIds = new StringBuffer(64);
  int numProjects = 0;
  boolean updateObjId = false;

  // If the user selects project(s) and clicks on 'Insert New', or 'Insert Existing'
  // pass all the selected project ids
  if("true".equals(fromRelatedProjects)){
    if("true".equalsIgnoreCase(insertNewProject) || "true".equalsIgnoreCase(insertExistingProject)){
      updateObjId = true;
      if(arrTableRowIds != null){
          numProjects = arrTableRowIds.length;
          for(int i=0; i<numProjects;i++){
              String temp = arrTableRowIds[i];
              String requiredObjectId = temp.substring(temp.indexOf("|")+1,temp.lastIndexOf("|"));
              sbObjectIds.append(requiredObjectId);

              if(i != numProjects-1){ // add seperator till the last element but not after it
                  sbObjectIds.append("|");
              }
          }
          objectId = sbObjectIds.toString();
		  objectId = objectId.substring(0,objectId.indexOf("|"));
      }
    }
  }
  // Addition ends


  // Read and store all the parameters passed
  String topLinks="";
  String bottomLinks="";
  String reqHeader = request.getHeader("Accept-Language");
  try{
    topLinks=emxGetParameter(request,"topLinks");
    bottomLinks=emxGetParameter(request,"bottomLinks");
  }
  catch(Exception e){
    e.printStackTrace();
  }

  if (sFunctionality == null) {

	  String  errMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			  "emxProgramCentral.Common.Functionality.errMsg", reqHeader); 
	  throw new FrameworkException(errMsg);
	  //throw new FrameworkException("The parameter 'functionality' should be provided");
  }

  StringBuffer sQueryString = new StringBuffer(64);
  Enumeration eNumParameters = emxGetParameterNames(request);
  while( eNumParameters.hasMoreElements() ) {
    String strParamName = (String)eNumParameters.nextElement();
    String strParamValue = emxGetParameter(request, strParamName);
    strParamValue = XSSUtil.encodeForURL(context,strParamValue);
  //Modified:25-Nov-2010:s4e:R210 PRG:IR-076702V6R2012
  //Added for special character.  
    /*if(strParamName.equalsIgnoreCase("ProgramName") || strParamName.equalsIgnoreCase("ProjectName") || strParamName.equalsIgnoreCase("ProjectDescription") || strParamName.equalsIgnoreCase("ProjectType")){
	    strParamValue = com.matrixone.apps.domain.util.FrameworkUtil.encodeNonAlphaNumeric(strParamValue,sCharSet);
	}*/
  //End:Modified:25-Nov-2010:s4e:R210 PRG:IR-076702V6R2012
    if(updateObjId){
      if("objectId".equals(strParamName)){
         strParamValue = objectId;
      }
    }

    sQueryString.append("&" + strParamName + "=" + strParamValue);
  }
  sQueryString.deleteCharAt(0);

  String strRegisteredSuite = emxGetParameter(request, "suiteKey");//As configured in command e.g. ProgramCentral
  strRegisteredSuite = XSSUtil.encodeURLForServer(context,strRegisteredSuite);
  if (strRegisteredSuite == null) {
	 
	  String  errMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			  "emxProgramCentral.Common.SuiteKey.errMsg", reqHeader);
	  throw new FrameworkException(errMsg);
	  //throw new FrameworkException("The parameter 'suiteKey' should be provided");
  }
  if (strRegisteredSuite.startsWith("eServiceSuite")) {
      strRegisteredSuite = FrameworkUtil.findAndReplace(strRegisteredSuite, "eServiceSuite", "");
  }
  
  String sSuiteKey = "eServiceSuite" + strRegisteredSuite;//As defined key in emxSystem.properties;
   
  //eServiceSuiteProgramCentral
  String sAppDirectory = emxGetParameter(request, "SuiteDirectory");
  if (sAppDirectory == null) {
        sAppDirectory = getSystemProperty(application, sSuiteKey + ".Directory");
      //sAppDirectory = FrameworkProperties.getProperty(sSuiteKey + ".Directory");
  }
  
  String sStrResName = emxGetParameter(request, "StringResourceFileId");
  if (sStrResName == null) {
      sStrResName = getSystemProperty(application, sSuiteKey + ".StringResourceFileId");
  }


  // Initialize the frameset object to bring up the dialog page
  framesetObject fs = new framesetObject();
  fs.setStringResourceFile(sStrResName);

  // Sets the application directory
  fs.setDirectory(sAppDirectory);

  String sKeyPrefix = sFunctionality;

  // Get heading
  String sHeadingKey = sSuiteKey + "." + sKeyPrefix + ".heading";
  //sHeadingKey = i18nStringNow(sHeadingKey,reqHeader);
 
  // Get content url
  String sContentURLKey = sSuiteKey + "." + sKeyPrefix + ".contentURL";
  String sContentURL = getApplicationProperty(application,  sContentURLKey);
  sContentURL =  "../" + sAppDirectory + "/" + sContentURL + "?" + sQueryString;

  // Get help string
  String sHelpStrKey = sSuiteKey + "." + sKeyPrefix + ".help";
  String sHelpStr = getApplicationProperty(application, sHelpStrKey);
  if (sHelpStr == null) {
    sHelpStr = "";
  }
  if("WizardClone".equals(strPageName) && ("CreateCloneProjectSpaceStep3".equals(sFunctionality))){
	  sHelpStr = "emxhelptaskdetailsspecify";
  }
	  

  //Get the required Notice
  boolean bRequiredNotice = true;
  String strrequiredNoticeKey = sSuiteKey + "." + sKeyPrefix + ".requiredNotice";
  // This property is not expected in the property file.Hence the method getProperty throws
  // an exception when the key is not found.When an exception is encountered the required notice is not shown.
  String strrequiredNotice = null;
  try
  {
    strrequiredNotice = EnoviaResourceBundle.getProperty(context, strrequiredNoticeKey);
  }
  catch(FrameworkException e){
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

  // Get "PrinterFriendly", "ShowPagination", "ShowConversion" configurations
  String sOptionsKey = sSuiteKey + "." + sKeyPrefix + ".options";
  String sOptions = getApplicationProperty(application, sOptionsKey);
  if (sOptions == null) {
    sOptions = "";
  }

  StringTokenizer st = new StringTokenizer(sOptions, "|");
  boolean bPrinterFriendly = false;
  boolean bShowPagination = false;
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
  String sButtons = getApplicationProperty(application, sButtonsKey);
  if (sButtons == null) {
    sButtons = "";
  }

  java.util.List buttonNameKeys = new ArrayList();
  st = new StringTokenizer(sButtons, ",");
  while (st.hasMoreTokens()) {
    buttonNameKeys.add(st.nextToken());
  }


  // Get the Top Action Links
  java.util.List topActionLinkNameKeys=new ArrayList();
  if(topLinks.equals("true"))
  {
    String sTopActionLinkKey = sSuiteKey + "." + sKeyPrefix + ".topLinks";
    String sTopActionLinks = getApplicationProperty(application, sTopActionLinkKey);
    if (sTopActionLinks == null) {
      sTopActionLinks = "";
    }
    if(sTopActionLinks.indexOf(",") != -1)
    {
      st = new StringTokenizer(sTopActionLinks, ",");
      while (st.hasMoreTokens()) {
        topActionLinkNameKeys.add(st.nextToken());
      }
    }
    else
    {
        topActionLinkNameKeys.add(sTopActionLinks);
    }
  }

 // Get the Bottom Action Links
 java.util.List bottomActionLinkNameKeys=new ArrayList();
 if(bottomLinks.equals("true"))
 {
    String sBottomActionLinkKey = sSuiteKey + "." + sKeyPrefix + ".bottomLinks";
    String sBottomActionLinks = getApplicationProperty(application, sBottomActionLinkKey);
    if (sBottomActionLinks == null) {
      sBottomActionLinks = "";
    }
    if(sBottomActionLinks.indexOf(",") != -1 )
    {
      st = new StringTokenizer(sBottomActionLinks, ",");
      while (st.hasMoreTokens()) {
        bottomActionLinkNameKeys.add(st.nextToken());
      }
    }
    else
    {
      bottomActionLinkNameKeys.add(sBottomActionLinks);
    }
  }

  // Get button roles
  java.util.List buttonRoles = new ArrayList();
  for (int iIndex=0; iIndex<buttonNameKeys.size(); iIndex++) {
    String sKey = sSuiteKey + "." + sKeyPrefix + ".buttons." + buttonNameKeys.get(iIndex) + ".roles";
    //String sButRoles = i18nStringNow(sKey,reqHeader);
    String sButRoles = getApplicationProperty(application, sKey);
    if (sButRoles.length() == 0) {
      sButRoles = "role_GlobalUser";
    }
    buttonRoles.add(sButRoles);
  }

  // Initialize the frameset
  fs.initFrameset(sHeadingKey,sHelpStr,sContentURL,bPrinterFriendly,true,bShowPagination,bShowConversion);

  // Configure the buttons in the bottom action bar
  for (int iIndex=0; iIndex < buttonNameKeys.size(); iIndex++)
  {
    String sButName = (String)buttonNameKeys.get(iIndex);
    String sButNameKey = "emxProgramCentral.Button." + sButName;

    String sButRoles = (String)buttonRoles.get(iIndex);

    String sJs = null;
    String sImage = null;
    if (sButName.equals("Done")) {
      sJs = "submit()";
      sImage = "common/images/buttonDialogDone.gif";
    }
    else if (sButName.equals("Cancel")) {
      sJs = "closeWindow()";
      sImage = "common/images/buttonDialogCancel.gif";
    }
    else if (sButName.equals("Back")) {
      sJs = "movePrevious()";
      sImage = "common/images/buttonDialogPrevious.gif";
    }
    else if (sButName.equals("Next")) {
      sJs = "validateForm()";
      sImage = "common/images/buttonDialogNext.gif";
    }
    else if (sButName.equals("Send")) {
      sJs = "submit()";
      sImage = "common/images/buttonDialogDone.gif";
    }
    else if (sButName.equals("RemoveSelected")) {
      sJs = "moveNext()";
      sImage = "common/images/buttonDialogNext.gif";
      fs.createHeaderLink(sButNameKey,sJs,sButRoles,false,false,sImage,1);
    }
  //[MODIFIED::Jan 22, 2011:S4E:version:IR-055432V6R2012 ::Start] 
    if(("CreateCloneProjectSpaceStep2".equalsIgnoreCase(sFunctionality) && sButName.equals("Next") && "Clone".equalsIgnoreCase(wizType) &&  ProgramCentralUtil.isNotNullString(strProjectName))||
       ("CreateImportProjectSpaceStep3".equalsIgnoreCase(sFunctionality) && sButName.equals("Next") && "Import".equalsIgnoreCase(wizType)) && "false".equalsIgnoreCase(strfromAction) ||
       ("CreateTemplateProjectSpaceStep3".equalsIgnoreCase(sFunctionality) && sButName.equals("Next") && "Template".equalsIgnoreCase(wizType) && "WizardTemplate".equalsIgnoreCase(strPageName) && ProgramCentralUtil.isNotNullString(strProjectName)))
    {
    	fs.createFooterLink("emxProgramCentral.Button.Done", sJs, sButRoles,false, true, "common/images/buttonDialogDone.gif", 3);
    }
    else{
    fs.createFooterLink(sButNameKey, sJs, sButRoles,false, true, sImage, 3);
  }
  //[MODIFIED::Jan 22, 2011:S4E:version:IR-055432V6R2012 ::End] 
    
  }

  // Configure the Actoin Links in the top action bar
  if(topLinks.equals("true"))
  {
    String sImage="";
    String sLinkRoles="";
    String sJs = "submit()";
    String sTopActionLinkNameKey ="";
    for(int iIndex=0; iIndex < topActionLinkNameKeys.size(); iIndex++) {
      String sTopActionLinkName = (String)topActionLinkNameKeys.get(iIndex);
      sTopActionLinkNameKey = "emxCommonLink." + sTopActionLinkName;
      sImage = "utilActionbarBullet.gif";
      sJs = "topActionLink('"+sTopActionLinkName+"')";
      fs.createCommonLink(sTopActionLinkNameKey,
                              sJs,
                              "role_GlobalUser",
                              false,
                              true,
                              "default",
                              true,
                      1);
      }
    }
    // Configure the Bottom Action Links in the top action bar
    if(bottomLinks.equals("true"))
    {
       String sImage="";
       String sLinkRoles="";
       String sJs = "submit()";
       String sBottomActionLinkNameKey ="";
       for (int iIndex=0; iIndex < bottomActionLinkNameKeys.size(); iIndex++) {
         String sBottomActionLinkName = (String)bottomActionLinkNameKeys.get(iIndex);
         sBottomActionLinkNameKey = "emxCommonLink." + sBottomActionLinkName;
         sImage = "utilActionbarBullet.gif";
         sJs = "bottomActionLink('"+sBottomActionLinkName+"')";
         fs.createFooterLink(sBottomActionLinkNameKey,
                                sJs,
                                "role_GlobalUser",
                                 false,
                                 true,
                                "default",
                             3);
        }
     }

  //To remove the dialog warning depending on the property file entry
  //if there is no entry then the dialog warning will not be shown
  if(!bRequiredNotice)
  {
    fs.removeDialogWarning();
  }
  // Send the output to the browser
  fs.writePage(out);

%>
