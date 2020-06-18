<%--  emxInfoActionBar.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page  import="com.matrixone.apps.framework.ui.UIMenu" %>

<%!
    static public String emxGetSessionParameter(HttpServletRequest request, String parameter)
    {
        String parameterValue = emxGetParameter(request,parameter);
		if(parameterValue==null || parameterValue.equals("null")){
		String timeStamp = request.getParameter("timeStamp");
		if(timeStamp!=null && timeStamp.trim().length()>0 && !timeStamp.equals("null")){
		HttpSession session = request.getSession();
		HashMap map = (HashMap)session.getAttribute("ParameterList" + timeStamp);
		if(map!=null)
		parameterValue =(String) map.get(parameter);
		}
		}
        return parameterValue;
     }
%>

<%!
    public static boolean hasExpressionFilterAccess(Context context, 
        BusinessObject busObj, 
        String expressionFilter) throws MatrixException
    {
        boolean accessFilterResult = false;
        try
        {
            expressionFilter = UIExpression.substituteValues(context, expressionFilter, busObj.getObjectId());
            MQLCommand objMQL  = new MQLCommand();
            objMQL.executeCommand(context,"eval expr $1 $2 $3 $4",expressionFilter,"on","bus",busObj.getObjectId());
            String slResult = objMQL.getResult().trim();

            if(slResult.equalsIgnoreCase("FALSE"))
            accessFilterResult=false;
            else
            accessFilterResult=true;
        }
        catch (Exception e)
        {
            throw new MatrixException(e.toString());
        }
        return accessFilterResult;
    }
%>

<%!
    public static boolean getAccess(Context context, BusinessObject busObj, HashMap paramMap,HashMap allSettings) throws MatrixException
    {
        boolean getAccessResult = true;
        boolean getAccessFilterResult = true;
        boolean getAccessProgramResult = true;
        boolean getAccessFinalResult = false;
        boolean hasAccess=true;
        boolean hasExpressionAccess=true;
        Boolean hasProgramAccess;
        String sProgramResponse="";
        String programName="";
        String methodName="";
        try
        {
            String sAccessMap = (String) allSettings.get("Access Map");
            String sAccessExpression = (String) allSettings.get("Access Expression");
            String sAccessProgram = (String) allSettings.get("Access Program");

            StringList listAccessMap = new StringList();
            if (sAccessMap != null && sAccessMap.trim().length() > 0)
            {
                StringTokenizer tokenAccess = new StringTokenizer(sAccessMap, ",");
                while (tokenAccess.hasMoreTokens())
                {
                    String strAccess =tokenAccess.nextToken().trim();
                    listAccessMap.addElement(strAccess);
                }
            }
            if ( listAccessMap != null & listAccessMap.size() > 0 )
            {
                hasAccess = FrameworkUtil.hasAccess(context, busObj, listAccessMap);
            }

            if(!(hasAccess))
                getAccessResult=false;

            if( ( sAccessExpression !=null )
                && ( sAccessExpression.trim().length()>0) )
                hasExpressionAccess=hasExpressionFilterAccess(context,busObj,sAccessExpression);

            if(!(hasExpressionAccess))
                getAccessFilterResult=false;

            if( ( sAccessProgram !=null ) && ( sAccessProgram.trim().length()>0) )
            {
                programName = (String) allSettings.get("Access Program");
                methodName = (String) allSettings.get("Access Program Method");
                if ((programName != null)  && (methodName != null) )
                {
                    String[] methodargs = JPO.packArgs(paramMap);
                    hasProgramAccess = (Boolean) JPO.invoke(context, programName, null, methodName, methodargs, Boolean.class);
                    sProgramResponse=hasProgramAccess.toString();
                }

                if(!sProgramResponse.equalsIgnoreCase("true"))
                    getAccessProgramResult=false;
            }

            if((getAccessProgramResult) && (getAccessFilterResult) && (getAccessResult))
                getAccessFinalResult=true;
            else
                getAccessFinalResult=false;
        }
        catch (Exception e)
        {
            throw new MatrixException(e.toString());
        }
        return getAccessFinalResult;
    }
%>

<%
    Vector userRoleList = (Vector)session.getValue("emxRoleList");
    String actionBarName = emxGetParameter(request, "actionBarName");
    String dispFrameType = emxGetParameter(request, "DisplayFrameType");
    String objectId = emxGetParameter(request, "objectId");
    String parentOID = emxGetParameter(request, "parentOID");
	String sRelDirection =emxGetSessionParameter(request,"sRelDirection");
    String sRelationName=emxGetSessionParameter(request,"sRelationName");
	String browser_agent = request.getHeader("USER-AGENT");
    if(!(browser_agent.indexOf("MSIE") > 0)){
      if(sRelationName!=null)
        sRelationName = java.net.URLEncoder.encode(sRelationName);   
      if(actionBarName!=null)
	    actionBarName = java.net.URLEncoder.encode(actionBarName);   
      if(sRelDirection!=null)
	  sRelDirection = java.net.URLEncoder.encode(sRelDirection);   
    }
    
    String timeStamp = emxGetParameter(request, "timeStamp");
    String sQueryLimit = emxGetParameter(request,"queryLimit");

    // Build the parameter/value HashMap for use with Program columns
    Enumeration enumParamNames = emxGetParameterNames(request);
    HashMap paramMap = new HashMap();
    while(enumParamNames.hasMoreElements()) 
    {
        String paramName = (String) enumParamNames.nextElement();
        String paramValue = (String)emxGetParameter(request, paramName);

        if (paramValue != null && paramValue.trim().length() > 0 )
            paramMap.put(paramName, paramValue);
    }
    paramMap.put("languageStr", request.getHeader("Accept-Language") );
    BusinessObject busObj = null;
    if (objectId != null && objectId.trim().length() > 0 && !objectId.equals("null"))
        busObj = new BusinessObject(objectId);

    // Get the Action list details - menu
    MapList listActions = new MapList();
    UIMenu emxActionBarObject=new UIMenu();
    listActions = emxActionBarObject.getMenu(context, actionBarName, userRoleList);
    boolean hasAccess = true;
    boolean hasExpressionAccess=true;
    String strErrorMsg = "";
    boolean sDisplayItem=true;
%>

<script language="javascript" />
    var cc = new jsActionBar;
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

</script>

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
                String sPopupModal = (String) allSettings.get("Popup Modal");

                String sConfirmMessage = emxActionBarObject.getSetting(commandMap, "Confirm Message");
                String sCode = emxActionBarObject.getCode(commandMap);

                // If we have valid busObj, get access map and get access
                if (busObj != null)
                {
                    //GET ACCESS INFORMATION TO DECIDE WHETHER TO DISPLAY OR NOT
                    sDisplayItem=getAccess(context,busObj,paramMap,allSettings);
                }
                // If No access skip this and continue to the next action
                if ( !(sDisplayItem))
                    continue;

                if ( sWindowWidth == null || sWindowWidth.trim().length() == 0 )
                    sWindowWidth = "600";

                if ( sWindowHeight == null || sWindowHeight.trim().length() == 0 )
                    sWindowHeight = "600";

                ////////////////////////////////
                // Get the directory and resourceFileId for the Registered Suite from
                String sRegisteredDir = "";
                String stringResFileId = "";
                String suiteKey = "";

                if ( (sRegisteredSuite != null) && (sRegisteredSuite.trim().length() > 0 ) )
                {
                    sRegisteredDir = UINavigatorUtil.getRegisteredDirectory(application, sRegisteredSuite);
                    stringResFileId = UINavigatorUtil.getStringResourceFileId(application, sRegisteredSuite);
                    suiteKey = "eServiceSuite" + sRegisteredSuite;
                }

                //BEGIN OF CHANGE
                //Check to see if message is null or not
                //String sConfirmationMessage = "";
                if( ( sConfirmMessage==null )
                    || ( sConfirmMessage.equalsIgnoreCase("null") )
                    || ( sConfirmMessage.equals("") ) )
                {
                    sConfirmMessage=null;
                }
                else
                {
                    sConfirmMessage=UINavigatorUtil.getI18nString(
                        sConfirmMessage.trim(), 
                        stringResFileId, 
                        request.getHeader("Accept-Language") );
                }

                if ( (sConfirmMessage != null) 
                    && (sConfirmMessage.trim().length() > 0) )
                {
                    if (sConfirmMessage.indexOf("${") >= 0 )
                        sConfirmMessage = UINavigatorUtil.parseHREF(application, 
                            sConfirmMessage.trim(), 
                            sRegisteredSuite);
                    else
                        sConfirmMessage = sConfirmMessage;
                }
                //END OF CHANGE

                // Get the command Label display value
                String sCommandLabelId = commandLabel;
                String sCommandLabel = "";

                if ( (sCommandLabelId == null) 
                    || (sCommandLabelId.trim().length() == 0) )
                {
                    sCommandLabel = commandLabel;
                } 
                else 
                {
                    //get i18n string of Suite Label from string resource file
                    sCommandLabel = UINavigatorUtil.getI18nString(sCommandLabelId, stringResFileId, request.getHeader("Accept-Language"));

                    if ( (sCommandLabel == null) 
                        || (sCommandLabel.trim().length() == 0) )
                        sCommandLabel = sCommandLabelId;
                }

                // parse HREF to check and replace the keywords "COMPONENT_DIR" and SUITE_DIR"
                // and relace them with appropriate value
                String sHREF = "";
                if ( (commandHRef != null) 
                    && (commandHRef.trim().length() > 0) )
                {
                    if (commandHRef.indexOf("${") >= 0 )
                        sHREF = UINavigatorUtil.parseHREF(application, commandHRef.trim(), sRegisteredSuite);
                    else
                        sHREF = commandHRef;
                }

                // Build the append URL
                String sAppendURL = "suiteKey=" + suiteKey;

                if ( stringResFileId != null && stringResFileId.trim().length() > 0 )
                    sAppendURL = sAppendURL+ "&StringResourceFileId=" + stringResFileId;
                if ( sRegisteredDir != null && sRegisteredDir.trim().length() > 0 )
                    sAppendURL = sAppendURL+ "&SuiteDirectory=" + sRegisteredDir;
                if ( sHelpMarker != null && sHelpMarker.trim().length() > 0 )
                    sAppendURL = sAppendURL+ "&HelpMarker=" + sHelpMarker;
                if ( sTipPage != null && sTipPage.trim().length() > 0 )
                    sAppendURL = sAppendURL+ "&TipPage=" + sTipPage;
                if ( sCurrencyConverter != null && sCurrencyConverter.trim().length() > 0 )
                    sAppendURL = sAppendURL+ "&CurrencyConverter=" + sCurrencyConverter;
                if ( sPrinterFriendly != null && sPrinterFriendly.trim().length() > 0 )
                    sAppendURL = sAppendURL+ "&PrinterFriendly=" + sPrinterFriendly;
		        if ( sRelDirection != null && sRelDirection.trim().length() > 0 )
                    sAppendURL = sAppendURL+ "&sRelDirection=" + sRelDirection;
		        if ( sRelationName != null && sRelationName.trim().length() > 0 )
                    sAppendURL = sAppendURL+ "&sRelationName=" + sRelationName;
		        if ( sQueryLimit != null && sQueryLimit.trim().length() > 0 && !sQueryLimit.equals("null"))
                    sAppendURL = sAppendURL+ "&queryLimit=" + sQueryLimit;
		 
                // Append this URL if the href is not a "javascript" function.
                // if "javascript" href need to be updated, the href must be parsed to add
                // the append URL appropriately -
                // This may require update later

                if ( (sHREF != null) && (!(sHREF.trim().startsWith("javascript:"))) )
                {
                    if ( sHREF.indexOf(".jsp") > 0 )
                    {
                        if ( sHREF.indexOf("?") > 0 )
                            sHREF = sHREF + "&parentOID="+parentOID +"&"+ sAppendURL;
                        else
                            sHREF = sHREF + "?parentOID="+parentOID+"&"+ sAppendURL;
                    }
                }

                //BEGIN OF CHANGE
                if ( (sRowSelect == null) || (sRowSelect.equals("")) )
                {
                    sRowSelect = "none";
                }
                else if (sRowSelect.equalsIgnoreCase("single"))
                {
                    sRowSelect="single";
                }
                else if(sRowSelect.equalsIgnoreCase("multiple"))
                {
                    sRowSelect="multiple";
                }
                //END OF CHANGE

                if ( (dispFrameType != null) && (dispFrameType.equals("Form")) )
                    sRowSelect = "none";

                if ( (sSubmitFlag == null) || (sSubmitFlag.equals("")) )
                    sSubmitFlag = "false";

                String popupFlag = "false";
                if ( (sTargetLocation != null) 
                    && (sTargetLocation.equalsIgnoreCase("popup")) )
                {
                    popupFlag = "true";
                    sTargetLocation = "null";
                    // If the HREF is a javascript: function, it cannot be submited from the data page.
                    if (sSubmitFlag.equals("false") && (!(sHREF.startsWith("javascript:"))) )
			        {
			            //Changed by MALLIK ...check for the option Popup Modal and accordingly display modal or modeless dialogs
			            if ( sPopupModal != null && sPopupModal.equalsIgnoreCase("true") )
					        sHREF = "javascript:showModalDialog('" + sHREF + "', '" + sWindowWidth + "', '" + sWindowHeight + "')";
				        else
        	                sHREF = "javascript:top.showNonModalDialog('" + sHREF + "', '" + sWindowWidth + "', '" + sWindowHeight + "')";
			        }
                }

                if ( ( sSubmitFlag != null ) && sSubmitFlag.equalsIgnoreCase("true") )
                {
                    // If the HREF is a javascript: function, it cannot be submited from the data page.
                    if (sHREF.startsWith("javascript:"))
                    {
                        //strErrorMsg = "Error in configuration of Action Link : '" + sCommandLabel + "'.";
                        //emxNavErrorObject.addMessage(strErrorMsg);
                        //strErrorMsg = "Cannot configure HREF parameter as javascript function : " + sHREF + " with 'Submit' flag set to 'true'..";
                        //emxNavErrorObject.addMessage(strErrorMsg);
                        continue;
                    }

                    String TargetLocationWithQoute = "";
                    if ( (sTargetLocation != null) 
                        && (sTargetLocation.equalsIgnoreCase("popup")) )
                    {
                        TargetLocationWithQoute = "null";
                    }
                    else
                    {
                        TargetLocationWithQoute = "'" + sTargetLocation + "'";
                    }

                    sHREF = "javascript:submitList('" + sHREF + "', " + TargetLocationWithQoute + ", '" + sRowSelect + "', " + popupFlag + ", '" + sWindowWidth + "', '" + sWindowHeight + "', '" + sConfirmMessage + "')";
                }
                if ( (sTargetLocation != null) 
                    && (!(sTargetLocation.equals("null"))) )
                    sTargetLocation = "'" + sTargetLocation + "'";

                if ( sTargetLocation == null )
                    sTargetLocation = "''";
%>
    <script language="javascript" />
	  //XSSOK
      cc.addLink("<%=sCommandLabel%>", "<%=sHREF%>", <%=sTargetLocation%>);
    </script>
<%
            } // end of if ( emxActionBarObject.isCommand(commandMap) )
        } // end of while (actionItr.hasNext())
    }//if (listActions != null)
%>
<script language="javascript" />
  cc.draw();
</script>
