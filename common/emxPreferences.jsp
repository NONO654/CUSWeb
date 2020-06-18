<%--  emxPreferences.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPreferences.jsp.rca 1.13 Wed Oct 22 15:48:03 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<HTML>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="emxMenu" class="com.matrixone.apps.framework.ui.UIMenu" scope="request"/>
  <HEAD>
        <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script> 
         <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
    <SCRIPT language="javascript" src="scripts/emxUIModal.js" type="text/javascript"></SCRIPT>
    <SCRIPT language="javascript" src="scripts/emxUIPopups.js" type="text/javascript"></SCRIPT>
    <SCRIPT language="javascript" src="scripts/emxUIPreferencesPane.js" type="text/javascript"></SCRIPT>
        <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
        <script language="JavaScript" src="../common/scripts/emxNavigatorHelp.js"></script>
        <script language="JavaScript" src="../emxUIPageUtility.js"></script>        
        <script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>      
        <link href="../common/styles/emxUIDefault.css" rel="stylesheet" />
        <link href="../common/styles/emxUIToolbar.css" rel="stylesheet" />
        <link href="../common/styles/emxUIMenu.css" rel="stylesheet" />
        <link href="../common/styles/emxUIDOMLayout.css" rel="stylesheet" />
        <link href="../common/styles/emxUIDialog.css" rel="stylesheet" />
    <script src="../webapps/c/UWA/js/UWA_W3C_Alone.js"></script>
    <SCRIPT language="JavaScript" type="text/javascript">
        var strTab = "";
        var strSearchType = "0";
        var objSP = new jsPreferencesPane("emxUIPreferencesPane.css");
<%
    String prefBodyHRef = null;
    try
    {

    ContextUtil.startTransaction(context, false);

    // Get role list
    Vector userRoleList = PersonUtil.getAssignments(context);

    // Get the Preference menu Name
    String propName = "menu_Preferences";
    String menuName = PropertyUtil.getSchemaProperty(context, propName);

    // Get all the menues connected to Preferences menu.
    MapList menuMapList = emxMenu.getOnlyMenus(context, menuName, userRoleList);

    // By default if no preferecne found then
    // display blank page at right
    // else display very first preference command href
    prefBodyHRef = "emxBlank.jsp";

    // If there are no preferences registered then
    // display message 'No Registered Preferences'
    if (menuMapList.size() == 0)
    {
%>
        objSP.addTab("<emxUtil:i18nScript localize="i18nId">emxFramework.UIPreferences.NoRegisteredPreferences</emxUtil:i18nScript>");
<%
    }
    else
    {
        // for each menu.
        for (int i = 0; i < menuMapList.size(); i++)
        {
            // Get sub menu info
            HashMap subMenuItem = (HashMap)menuMapList.get(i);

            // Get sub menu name
            String subMenuName = emxMenu.getName(subMenuItem);

            // Get registered suite
            String menuStringResFileId = "emxFrameworkStringResource";
            String subMenuSuite = emxMenu.getSetting(subMenuItem, "Registered Suite");
            if ( (subMenuSuite != null) && (subMenuSuite.trim().length() > 0 ) )
            {
                menuStringResFileId = UINavigatorUtil.getStringResourceFileId(context, subMenuSuite);
            }

            // Get sub menu label
            String subMenuLabel = UINavigatorUtil.getI18nString(emxMenu.getLabel(subMenuItem),
                                                                menuStringResFileId,
                                                                request.getHeader("Accept-Language"));

            MapList cmdMapList = emxMenu.getOnlyCommands(context, subMenuName, userRoleList);
            
            if (cmdMapList.size() > 0)
            {
%>
        var tab = objSP.addTab("<xss:encodeForHTML><%=subMenuLabel%></xss:encodeForHTML>");
<%
            // Get commands connected to sub menu.
            
            boolean firstDisplayedCommandFlag = false;
            int firstDisplayedCommandPosition =0;
            
            for (int j = 0; j < cmdMapList.size(); j++)
            {
                // Get command info
                HashMap cmdItem = (HashMap)cmdMapList.get(j);
                
                String sCmdItemName = emxMenu.getName(cmdItem);
                
               // Check if the Command is to be displayed based on Access Function/Expression on the Command object
                if (sCmdItemName != null  )
                {
                    BusinessObject personBusObj = PersonUtil.getPersonObject(context);
                    personBusObj.open(context);
                    HashMap allSettings=emxMenu.getSettings(cmdItem);
                    boolean hasAccess = UINavigatorUtil.checkAccessForSettings(context, personBusObj, request, allSettings);
                    personBusObj.close(context);

                    if(!hasAccess)
                    {
                         continue;
                    }
                    
                    else if (! firstDisplayedCommandFlag) {
                    	firstDisplayedCommandFlag= true;
                    	firstDisplayedCommandPosition= j;
                    }
                
                }

                // Get registered suite
                String cmdStringResFileId = "emxFrameworkStringResource";
                String cmdSuite = emxMenu.getSetting(cmdItem, "Registered Suite");
                String suiteDir = "";
                if ( (cmdSuite != null) && (cmdSuite.trim().length() > 0 ) )
                {
                    suiteDir = UINavigatorUtil.getRegisteredDirectory(context,cmdSuite);
                }
                String cmdHelpMarker = emxMenu.getSetting(cmdItem, "Help Marker");
                if ( (cmdSuite != null) && (cmdSuite.trim().length() > 0 ) )
                {
                    cmdStringResFileId = UINavigatorUtil.getStringResourceFileId(context, cmdSuite);
                }

                // Get command label
                String cmdLabel = UINavigatorUtil.getI18nString(emxMenu.getLabel(cmdItem),
                                                                cmdStringResFileId,
                                                                request.getHeader("Accept-Language"));

                // Get Href
                String cmdHref = emxMenu.getHRef(cmdItem);
                if (cmdHref != null)
                {
                    // parse HRef to replace macros
                    cmdHref = UINavigatorUtil.parseHREF(context, cmdHref.trim(), cmdSuite);

                    // encode the URL
                    cmdHref = UINavigatorUtil.encodeURL(cmdHref);

                    // show first displayed preference on right side
                    if (i == 0 && j==firstDisplayedCommandPosition)
                    {
                        prefBodyHRef = cmdHref;
                    }
                }
%>
        tab.addLink("<xss:encodeForHTML><%=cmdLabel%></xss:encodeForHTML>", "<%=cmdHref%>", "preferencesBody","<xss:encodeForHTML><%=cmdHelpMarker%></xss:encodeForHTML>","<xss:encodeForHTML><%=suiteDir%></xss:encodeForHTML>");
<%
            }
        }
    }
    }
    }
    catch (Exception ex) {
        ContextUtil.abortTransaction(context);

        if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        {
            emxNavErrorObject.addMessage("emxPrefHomePage:" + ex.toString().trim());
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }
%>
    </SCRIPT>
    <script language="JavaScript">
      var canSubmit = true;
      var strAppID = "common";
      var strXMLFile = "Preferences.xml";
      var strMode = "preferences";
      function doFind() {
        turnOnProgress();
        setTimeout("doFindNavigate()", 500);
      }

      function doFindNavigate() {
        getTopWindow().document.location.href = "emxPreferences.jsp?appid=" + strAppID + "&searchtype=" + getTopWindow().strSearchType + "&tab=" + getTopWindow().strTab + "&xml=" + strXMLFile + "&mode=" + strMode;
      }

      function doDone() {
        turnOnProgress();
        setTimeout("getTopWindow().closeWindow()", 500);
      }

    function processSubmit(closeWin){
		if(canSubmit)
		{
			
			canSubmit = false;
			//get the frame
			var prefBody = findFrame(getTopWindow(), "preferencesBody");

			//get the form
			var prefBodyForm = prefBody.document.forms[0];

			if(prefBodyForm.id == "LangPref" && getTopWindow().getWindowOpener().getTopWindow().passportURL){
				var selectedlang = prefBody.document.getElementById("language").value;
				getTopWindow().getWindowOpener().getTopWindow().updateLangPref(selectedlang);
			}
			

			//check for validation routine
			var validationRoutine = getValidationRoutine(prefBody);
			
			//top most window
			var frameTop=getTopWindow().getWindowOpener().getTopWindow();

			//set form target
			prefBodyForm.target="hiddenPreferenceFrame";
			addSecureToken(prefBodyForm);
			// if there is a validation routine, use it
			if(validationRoutine != null){
				if(validationRoutine()){
					prefBodyForm.submit();
				//don't close window if validation failed
				}else{
					closeWin = false;
				}
			//otherwise just submit
			}else{
				prefBodyForm.submit();
			}
			removeSecureToken(prefBodyForm);
			//reload top if required
			var pageReload ="false";
			if(prefBodyForm.reloadparent != null){
				pageReload=prefBodyForm.reloadparent.value;
				if((pageReload=="true")){
					if(frameTop){
						frameTop.document.location.href=frameTop.document.location.href;
					}
				}
			}

			//close preference window
			if(closeWin){
				setTimeout("getTopWindow().closeWindow()", 2500);
			}
			canSubmit = true;
		}
    }

    function submitAndUpdate() {
        var closeWin = false;
        processSubmit(closeWin);
    }


    function submitAndClose() {
        var closeWin = true;
        processSubmit(closeWin);
    }

    function getValidationRoutine(bodyFrame){
        if(typeof bodyFrame.validationRoutine == "function"){
            return bodyFrame.validationRoutine;
        }
        return null;
    }
    </script>    
        <TITLE><emxUtil:i18n localize="i18nId">emxFramework.Preferences.Title</emxUtil:i18n></TITLE>
  </HEAD>
        
        
   <body class="preferences-dialog" onload="javascript:loadPreferences(); turnOffProgress();">
   <div id="pageHeadDiv">
   
   </div>

   <div id="divPageBody">
   <div id="divSearchPane">
   	<iframe name="preferencesPane" src="emxPreferencesPane.jsp" allowtransparency="true" frameborder="0"></iframe>
   </div>
   <div id="divSearchCriteria">
   	<iframe name="preferencesBody" src="<xss:encodeForHTMLAttribute><%=prefBodyHRef%></xss:encodeForHTMLAttribute>" allowtransparency="true" frameborder="0"></iframe>
	<iframe name="hiddenPreferenceFrame" class="hidden-frame" src="emxBlank.jsp" allowtransparency="true" frameborder="0"></iframe>
   </div>
   </div>
   		<div id="divPageFoot">
<table>
            <tr>
                  <td class="functions"></td>
                  <td class="buttons">
					      <table>
					        <tr>
					                <td>
					                       <a class="footericon" href="Javascript:submitAndUpdate()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Preferences.Apply</emxUtil:i18n>" src="images/buttonDialogApply.gif" /></a>
					                </td>
					                <td>
					                  <a onClick="Javascript:submitAndUpdate()" class="button"><button class="btn-default" type="button"><emxUtil:i18n localize="i18nId">emxFramework.Preferences.Apply</emxUtil:i18n></button></a>
					                </td>
					                <td>
					                  <a class="footericon" href="Javascript:submitAndClose()"><img border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Preferences.Done</emxUtil:i18n>" src="images/buttonDialogDone.gif" /></a>
					                </td>
					                <td>
					                  <a onClick="Javascript:submitAndClose()" class="button"><button class="btn-primary" type="button"><emxUtil:i18n localize="i18nId">emxFramework.Preferences.Done</emxUtil:i18n></button></a>
					                </td>
					                <td>
					                  <a class="footericon" href="javascript:getTopWindow().closeWindow()"><img border="0" alt="Cancel" src="images/buttonDialogCancel.gif" /></a>
					                </td>
					                <td>
					                  <a class="button" onClick="javascript:getTopWindow().closeWindow()"><button class="btn-default" type="button"><emxUtil:i18n localize="i18nId">emxFramework.Preferences.Cancel</emxUtil:i18n></button></a>
					                </td>
					        </TR>
					      </table>

                  </td>
            </tr>
</table>   		
   		</div>
   		</body>
   		</html> 
</HTML>
