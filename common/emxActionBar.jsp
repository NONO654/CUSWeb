<%-- emxActionBar.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxActionBar.jsp.rca 1.29 Wed Oct 22 15:48:03 2008 przemek Experimental przemek $
--%>

<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>

<jsp:useBean id="emxActionBarObject" class="com.matrixone.apps.framework.ui.UIMenu" scope="request"/>

<%  boolean dodraw = true;
try {

  ContextUtil.startTransaction(context, false);

  Vector userRoleList = PersonUtil.getAssignments(context);
  String actionBarName = emxGetParameter(request, "actionBarName");
  String dispFrameType = emxGetParameter(request, "DisplayFrameType");
  String doDrawLinks = emxGetParameter(request, "doDrawLinks");

  String objectId = emxGetParameter(request, "objectId");
  String relId = emxGetParameter(request, "relId");
  String portalMode = emxGetParameter(request, "portalMode");
  String editLink = emxGetParameter(request, "editLink");
  String timeStamp = emxGetParameter(request, "timeStamp");
  String header = emxGetParameter(request, "header");
  String suiteKey = "";
  Locale locale = new Locale((String)request.getHeader("Accept-Language"));

  if(doDrawLinks!=null && doDrawLinks.trim().length() >0 && doDrawLinks.equalsIgnoreCase("false"))
  {
    dodraw=false;
  }

  String parentOID = emxGetParameter(request, "parentOID");
 String AEFMyDeskSuiteDir = (String)session.getAttribute("AEFMyDeskSuiteDir");
  // Build the parameter/value HashMap for use with Program columns
  HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
  if(paramMap==null){
      paramMap=new HashMap();
      paramMap.put("AEFMyDeskSuiteDir",AEFMyDeskSuiteDir);
  }else{
      paramMap.put("AEFMyDeskSuiteDir",AEFMyDeskSuiteDir);
  }


  BusinessObject busObj = null;
  if (objectId != null && objectId.trim().length() > 0 )
    busObj = new BusinessObject(objectId);

  // Get the Action list details - menu
  MapList listActions = new MapList();
  if(actionBarName != null && !"".equalsIgnoreCase(actionBarName)) {
    listActions = emxActionBarObject.getMenu(context, actionBarName, userRoleList);
  }

  String strErrorMsg = "";

%>

<script language="javascript">

if (cc == null)
{
  var cc = new jsActionBar;
<%
  if(portalMode != null && !"".equals(portalMode)) {
%>
    cc.top = 0;
    cc.left = 0;
    cc.stylesheet = emxUICore.getStyleSheet("emxUIChannelActionbar");
<%
  } else {
%>
      var topPos = 50;
      var leftPos = 10;
      var visible = 4;

      if (actionItemTopPos)
      topPos = actionItemTopPos;

      if (actionItemLeftPos)
      leftPos = actionItemLeftPos;

      if (visibleLinks)
      visible = visibleLinks;

      cc.top = topPos;
      cc.left = leftPos;
      cc.visibleLinks = visible;
<%
  }
%>
}
</script>
<form name="actionBar">
<%

  if (listActions != null)
  {
    Iterator actionItr = listActions.iterator();
    while (actionItr.hasNext())
    {
      HashMap commandMap = (HashMap)actionItr.next();

      // Check if the item is command
      if ( emxActionBarObject.isCommand(commandMap) )
      {
          // Get command Details
          String commandName = emxActionBarObject.getName(commandMap);
          String commandLabel = emxActionBarObject.getLabel(commandMap);
          String commandAlt = emxActionBarObject.getAlt(commandMap);
          String commandHRef = emxActionBarObject.getHRef(commandMap);
          HashMap allSettings = emxActionBarObject.getSettings(commandMap);

          if (allSettings == null)
            allSettings = new HashMap();

          String sTargetLocation = (String) allSettings.get("Target Location");
          String sRegisteredSuite = (String) allSettings.get("Registered Suite");
          String sWindowHeight = (String) allSettings.get("Window Height");
          String sWindowWidth = (String) allSettings.get("Window Width");
          String sHelpMarker = (String) allSettings.get("Help Marker");
          String sTipPage = (String) allSettings.get("Tip Page");
          String sCurrencyConverter = (String) allSettings.get("Currency Converter");
          String sPrinterFriendly = (String) allSettings.get("Printer Friendly");
          String sRowSelect = (String) allSettings.get("Row Select");
          String sSubmitFlag = (String) allSettings.get("Submit");

          String sConfirmMessage = emxActionBarObject.getSetting(commandMap, "Confirm Message");
          String sCode = emxActionBarObject.getCode(commandMap);
          ////////////////////////////////
          // Get the directory and resourceFileId for the Registered Suite from
          // the system.properties file
          String sRegisteredDir = "";
          String stringResFileId = "";

          if (sRegisteredSuite != null && sRegisteredSuite.length() > 0)
          {
              sRegisteredDir = UINavigatorUtil.getRegisteredDirectory(context,sRegisteredSuite);
              stringResFileId = UINavigatorUtil.getStringResourceFileId(context,sRegisteredSuite);
              suiteKey = sRegisteredSuite;
          }


          // Check if the Link has Access for the context User
          boolean showLink = true;
          //showLink = UINavigatorUtil.checkAccessForSettings(context, busObj, request, allSettings);
          paramMap.put("emxAEFAppSuiteDir",sRegisteredDir);
          showLink = UINavigatorUtil.checkAccessForSettings(context, busObj, paramMap, allSettings);
          if (!showLink)
            continue;

          if ( sWindowWidth == null || sWindowWidth.trim().length() == 0 )
            sWindowWidth = "600";

          if ( sWindowHeight == null || sWindowHeight.trim().length() == 0 )
            sWindowHeight = "600";



          //Check to see if message is null or not
          //String sConfirmationMessage = "";
          if(sConfirmMessage==null || sConfirmMessage.equalsIgnoreCase("null") || sConfirmMessage.equals("")){
            sConfirmMessage=null;
          }else{
            sConfirmMessage=EnoviaResourceBundle.getProperty(context, stringResFileId, locale, sConfirmMessage.trim());
          }
          if ( (sConfirmMessage != null) && (sConfirmMessage.trim().length() > 0) )
          {
            if (sConfirmMessage.indexOf("$<") >= 0 )
                sConfirmMessage = UIExpression.substituteValues(context, sConfirmMessage.trim(), objectId);
            else
                sConfirmMessage = sConfirmMessage;
          }

          // Get the command Label display value
          String sCommandLabelId = commandLabel;
          String sCommandLabel = "";

          if ( (sCommandLabelId == null) || (sCommandLabelId.trim().length() == 0) )
          {
            sCommandLabel = commandLabel;
          } else {
            //get i18n string of Suite Label from string resource file
            sCommandLabel = EnoviaResourceBundle.getProperty(context, stringResFileId, locale, sCommandLabelId);

            if ( (sCommandLabel == null) || (sCommandLabel.trim().length() == 0) )
              sCommandLabel = sCommandLabelId;
          }

          // parse HREF to check and replace the keywords "COMPONENT_DIR" and SUITE_DIR"
          // and relace them with appropriate value
          StringBuffer sHREF = new StringBuffer(100);

          if ( (commandHRef != null) && (commandHRef.trim().length() > 0) )
          {
            sHREF.append(commandHRef);
            if (commandHRef.indexOf("${") >= 0 )
            {
                 sHREF=new StringBuffer(100);
                 sHREF.append(UINavigatorUtil.parseHREF(context, commandHRef.trim(), sRegisteredSuite));
            }
            if (sHREF.indexOf("$<") >= 0 )
            {
                if (objectId != null && objectId.length() > 0)
                {
                  String hRef = sHREF.toString();
                  sHREF=new StringBuffer(100);
                  sHREF.append(UIExpression.substituteValues(context, hRef, objectId));
                }
            }
          }
          // Build the append URL
          StringBuffer sAppendURL = new StringBuffer(100);
          sAppendURL.append("suiteKey=");
          sAppendURL.append(suiteKey);
          
          if ( objectId != null && objectId.trim().length() > 0 ) {
            sAppendURL.append("&objectId=");
            sAppendURL.append(objectId);
          }
          if ( relId != null && relId.trim().length() > 0 ) {
            sAppendURL.append("&relId=");
            sAppendURL.append(relId);
          }
          if ( stringResFileId != null && stringResFileId.trim().length() > 0 ) {
            sAppendURL.append("&StringResourceFileId=");
            sAppendURL.append(stringResFileId);
          }
          if ( sRegisteredDir != null && sRegisteredDir.trim().length() > 0 ) {
            sAppendURL.append("&SuiteDirectory=");
            sAppendURL.append(sRegisteredDir);            
          }
          if ( sHelpMarker != null && sHelpMarker.trim().length() > 0 ){
            sAppendURL.append("&HelpMarker=");
            sAppendURL.append(sHelpMarker);                   
          }  
          if ( sTipPage != null && sTipPage.trim().length() > 0 ){
            sAppendURL.append("&TipPage=");
            sAppendURL.append(sTipPage);          
          }  
          if ( sCurrencyConverter != null && sCurrencyConverter.trim().length() > 0 ){
            sAppendURL.append("&CurrencyConverter=");
            sAppendURL.append(sCurrencyConverter);          
          }  
          if ( sPrinterFriendly != null && sPrinterFriendly.trim().length() > 0 ){
            sAppendURL.append("&PrinterFriendly=");
            sAppendURL.append(sPrinterFriendly);   
          }  
          // Append this URL if the href is not a "javascript" function.
          // if "javascript" href need to be updated, the href must be parsed to add
          // the append URL appropriately -
          // This may require update later

          if ( (sHREF.toString() != null) && (!(sHREF.toString().trim().startsWith("javascript:"))) )
          {
            if ( sHREF.toString().indexOf(".jsp") > 0 )
            {
                if ( sHREF.toString().indexOf("?") > 0 )
                {
                  sHREF.append("&parentOID=");
                  sHREF.append(parentOID);
                  sHREF.append("&");
                  sHREF.append(sAppendURL.toString());
                }
                else{
                  sHREF.append("?parentOID=");
                  sHREF.append(parentOID);
                  sHREF.append("&");
                  sHREF.append(sAppendURL.toString());
                }
             }
          }

          if ( (sRowSelect == null) || (sRowSelect.equals("")) ){
            sRowSelect = "none";
          }else if (sRowSelect.equalsIgnoreCase("single")){
            sRowSelect="single";
          }else if(sRowSelect.equalsIgnoreCase("multiple")){
            sRowSelect="multiple";
          }

          if ( (dispFrameType != null) && (dispFrameType.equals("Form")) )
            sRowSelect = "none";

          if ( (sSubmitFlag == null) || (sSubmitFlag.equals("")) )
            sSubmitFlag = "false";

          String popupFlag = "false";
          if ( (sTargetLocation != null) && (sTargetLocation.equalsIgnoreCase("popup")) )
          {
            popupFlag = "true";
            sTargetLocation = "null";
            // If the HREF is a javascript: function, it cannot be submited from the data page.
            if (sSubmitFlag.equals("false") && (!(sHREF.toString().startsWith("javascript:"))) )
            {
              sHREF.insert(0,"javascript:showModalDialog('");
              sHREF.append("', '");
              sHREF.append(sWindowWidth);
              sHREF.append("', '");
              sHREF.append(sWindowHeight);
              sHREF.append("')");
            }
          }

          if ( sSubmitFlag != null && sSubmitFlag.equalsIgnoreCase("true") )
          {
            // If the HREF is a javascript: function, it cannot be submited from the data page.
            if (sHREF.toString().startsWith("javascript:"))
            {
              strErrorMsg = "Error in configuration of Action Link : '" + sCommandLabel + "'.";
              emxNavErrorObject.addMessage(strErrorMsg);
              strErrorMsg = "Cannot configure HREF parameter as javascript function : " + sHREF.toString() + " with 'Submit' flag set to 'true'..";
              emxNavErrorObject.addMessage(strErrorMsg);
              continue;
            }

            String TargetLocationWithQoute = "";
            if ( (sTargetLocation != null) && (sTargetLocation.equalsIgnoreCase("popup")) ){
              TargetLocationWithQoute = "null";
            }else{
              TargetLocationWithQoute = "'" + sTargetLocation + "'";
            }

             %>
             <input type="hidden" name="<%=commandName%>" value="<%=sConfirmMessage%>"/><!-- XSSOK -->
             <%

            sHREF.insert(0,"javascript:submitList('");
            sHREF.append("', ");
            sHREF.append(TargetLocationWithQoute);
            sHREF.append(", '");
            sHREF.append(sRowSelect);
            sHREF.append("', ");
            sHREF.append(popupFlag);
            sHREF.append(", '");
            sHREF.append(", '");
            sHREF.append(sWindowWidth);
            sHREF.append("', '");
            sHREF.append(sWindowHeight);
            sHREF.append("', '");
            sHREF.append(commandName);
            sHREF.append("')");
          }
          if ( (sTargetLocation != null) && (!(sTargetLocation.equals("null"))) )
            sTargetLocation = "'" + sTargetLocation + "'";

          if ( sTargetLocation == null )
            sTargetLocation = "''";

        
        boolean isIE = EnoviaBrowserUtility.is(request,Browsers.IE);
        if(isIE)
        {
          if ( sHREF.toString().indexOf("$<") > 0 && sHREF.toString().indexOf(">") > 0 )
          {
                // Replace all "<" and ">" with "&lt;" and "&gt;"
                StringList hrefToks = FrameworkUtil.split(sHREF.toString(), "<");
                sHREF = new StringBuffer(100);
                sHREF.append(FrameworkUtil.join(hrefToks, "&lt;"));
                

                hrefToks = FrameworkUtil.split(sHREF.toString(), ">");
                sHREF = new StringBuffer(100);
                sHREF.append(FrameworkUtil.join(hrefToks, "&gt;"));
          }
        }
%>
<script language="javascript">
<%
  if(portalMode != null && !"".equals(portalMode)) {
%>
    cc.addItem(new emxUIActionbarItem(null,"<xss:encodeForJavaScript><%=sCommandLabel%></xss:encodeForJavaScript>", "<%=XSSUtil.encodeURLwithParsing(context, sHREF.toString())%>", <%=sTargetLocation%>));
<%
  } else {
%>
      cc.addLink("<xss:encodeForJavaScript><%=sCommandLabel%></xss:encodeForJavaScript>", "<%=XSSUtil.encodeURLwithParsing(context, sHREF.toString())%>", <%=sTargetLocation%>);
<%
  }
%>
</script>
<%
      }
    }
  }

  if(editLink != null && "true".equalsIgnoreCase(editLink)) {
    String sCmdLabel = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", locale, "emxFramework.TableEdit.Edit");
    StringBuffer hREF = new StringBuffer(100);
    hREF.append("emxTableEdit.jsp?header=");
    hREF.append(header);
    hREF.append("&timeStamp=");
    hREF.append(timeStamp);
    hREF.append("&suiteKey=");
    hREF.append(suiteKey);
    hREF.insert(0,"javascript:showModalDialog('");
    hREF.append("', '600', '600')");
    
    String sTarget = "'popup'";
%>
  <script type="text/javascript">
<%
    if(portalMode != null && !"".equals(portalMode)) {
%>
		//XSSOK
      cc.addItem(new emxUIActionbarItem(null,"<%=sCmdLabel%>", "<%=XSSUtil.encodeURLwithParsing(context, hREF.toString())%>", <%=sTarget%>));
<%
    } else {
%>
		//XSSOK
        cc.addLink("<%=sCmdLabel%>", "<%=XSSUtil.encodeURLwithParsing(context, hREF.toString())%>", <%=sTarget%>);
<%
    }
%>
  </script>
<%
  }
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);

    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        emxNavErrorObject.addMessage("emxActionBar:" + ex.toString().trim());

} finally {
    ContextUtil.commitTransaction(context);
}

if(dodraw){%>
<script language="javascript">
  cc.draw();
</script>
<%}%>
</form>
