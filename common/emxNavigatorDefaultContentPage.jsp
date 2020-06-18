<%--  emxNavigatorDefaultContentPage.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxNavigatorDefaultContentPage.jsp.rca 1.26 Wed Oct 22 15:48:02 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>

<HTML>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>

<jsp:useBean id="emxUIMenuObject" class="com.matrixone.apps.framework.ui.UIMenu" scope="request"/>
<%
try {
    ContextUtil.startTransaction(context, false);

    String sCommandName="AEFPreferenceToolbar";
    String sMenuName="Toolbar";
    Vector userRoleList = PersonUtil.getAssignments(context);
    MapList commandMap= emxUIMenuObject.getMenu(context, sMenuName,userRoleList);

    String sRegisteredDir = "";
    String stringResFileId = "";
    String suiteKey = "";
    String sHelpMarker ="";
    String sTargetLocation = "";
    String sRegisteredSuite = "";
    String sWindowHeight = "";
    String sWindowWidth = "";
    String commandHRef ="";
    String sHREF = "";
    HashMap commandItem=new HashMap();
    boolean isShowPreference = true;
    String welcomeMsg = UINavigatorUtil.getI18nString("emxNavigator.UIMenu.WelcomeTo", null, request.getHeader("Accept-Language"));
    String prefWelcomeMsg = UINavigatorUtil.getI18nString("emxNavigator.UIMenu.WelcomePreferenceMsg", null, request.getHeader("Accept-Language"));
    String welcomePLMMsg = UINavigatorUtil.getI18nString("emxNavigator.UIMenu.WelcomePLMMsg", null, request.getHeader("Accept-Language"));
    String pressHereMsg = UINavigatorUtil.getI18nString("emxNavigator.UIMenu.PressHere", null, request.getHeader("Accept-Language"));

    String deniedMsg= UINavigatorUtil.getI18nString("emxFramework.Access.Denied", null, request.getHeader("Accept-Language"));
    if (commandMap != null)
    {
      for (int i=0; i < commandMap.size(); i++)
      {
        commandItem = (HashMap)commandMap.get(i);
        if ( emxUIMenuObject.isCommand(commandItem) )
        {
            // Get the command name
            String sCmdItemName = emxUIMenuObject.getName(commandItem);
            if (sCmdItemName != null && sCmdItemName.equals(sCommandName) )
            {
            HashMap allSettings = emxUIMenuObject.getSettings(commandItem);
            sTargetLocation = (String) allSettings.get("Target Location");
            sRegisteredSuite = (String) allSettings.get("Registered Suite");
            sWindowHeight = (String) allSettings.get("Window Height");
            sWindowWidth = (String) allSettings.get("Window Width");
            sHelpMarker = (String) allSettings.get("Help Marker");
            commandHRef = emxUIMenuObject.getHRef(commandItem);

            // parse HREF to check and replace the keywords "COMPONENT_DIR" and SUITE_DIR"
            // and relace them with appropriate value
            if ( (commandHRef != null) && (commandHRef.trim().length() > 0) )
                sHREF = UINavigatorUtil.parseHREF(context, commandHRef.trim(), sRegisteredSuite);

            if ( sWindowWidth == null || sWindowWidth.trim().length() == 0 )
                sWindowWidth = "200";

            if ( sWindowHeight == null || sWindowHeight.trim().length() == 0 )
                sWindowHeight = "520";

            BusinessObject personBusObj = null;
            if(PersonUtil.isPersonObjectSchemaExist(context))
            {
                personBusObj =PersonUtil.getPersonObject(context);
                personBusObj.open(context);
            }

            if(!UINavigatorUtil.checkAccessForSettings(context, personBusObj, request, allSettings))
            {
                sHREF="";
            }

            if ( (sRegisteredSuite != null) && (sRegisteredSuite.trim().length() > 0 ) )
            {
                sRegisteredDir = UINavigatorUtil.getRegisteredDirectory(context, sRegisteredSuite);
                stringResFileId = UINavigatorUtil.getStringResourceFileId(context, sRegisteredSuite);
                suiteKey = sRegisteredSuite;
            }

            break;
          }
        }
      }
    }
%>

<script language="JavaScript">
function showHomepagePrefs(commandHRef,suiteKey,StringResourceFileId,SuiteDirectory,HelpMarker,sWidth,sHeight) {
    if (commandHRef == "")
    {
        //XSSOK
        alert("<%=deniedMsg%>");
        return;
    }

    //XSSOK
    getTopWindow().showModalDialog("<%=sHREF%>?suiteKey=<%=suiteKey%>&StringResourceFileId=<%=stringResFileId%>&SuiteDirectory=<%=sRegisteredDir%>&HelpMarker=<%=sHelpMarker%>",sWidth,sHeight, "popup");
}
</script>
<link rel="stylesheet" type="text/css" href="<%=Framework.getClientSideURL(response, "common/styles/emxUIDefault.css")%>"/>
<link rel="stylesheet" type="text/css" href="<%=Framework.getClientSideURL(response, "common/styles/emxUISplash.css")%>"/>
</HEAD>

<body>
<div id="divSplash">
    <div id="divSplashImage"></div>
    <!--<p><emxUtil:i18n localize="i18nId">emxFramework.Copyright</emxUtil:i18n></p>-->
</div>
<%
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);

    ex.printStackTrace();
    if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
}
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</body>
</html>
