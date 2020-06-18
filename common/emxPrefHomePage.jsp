<%--  emxPrefHomePage.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefHomePage.jsp.rca 1.22 Wed Oct 22 15:48:03 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<HTML>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<HEAD>
<TITLE></TITLE>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@include file = "../emxStyleHomepageSelectorInclude.inc"%>
</HEAD>
<BODY topmargin="6" leftmargin="10" marginwidth="10" marginheight="6" onload="getTopWindow().turnOffProgress()">
<div style="overflow: auto;-webkit-overflow-scrolling: touch;position: absolute;top: 0;bottom: 0;right: 0;left: 0; padding: 20px 0">
<FORM action="emxPrefHomePageProcessing.jsp" method="post" name="form2" id="form2" target="hiddenPreferenceFrame" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
<%
String language = request.getHeader("Accept-Language");

try
{
    ContextUtil.startTransaction(context, false);

    HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);

    // Get MyDesk Toolbar
    HashMap mydeskToolbar = UIToolbar.getToolbar(context, "menu_MyDesk", paramMap, language);
    String mydeskMenuName = UIToolbar.getName(mydeskToolbar);

    // Get Home Page Menu preference set for logged in user
    String menuDefault = PersonUtil.getMenu(context);
    // Get Home Page Command preference set for logged in user
    String commandDefault = PersonUtil.getCommand(context);

	String defaultStr = UINavigatorUtil.getI18nString("emxFramework.Common.Default", "emxFrameworkStringResource", request.getHeader("Accept-Language"));

	String defaultOptionChecked = "";
    

%>
<TABLE border="0" cellpadding="0" cellspacing="0" width="130">

<%
	// Get Toolbar Map
    // HashMap mydeskToolbar = UINavigatorUtil.getMyDeskToolbar(context, paramMap, language);
    HashMap toolsToolbar = UIToolbar.getToolbar(context, "menu_Toolbar", paramMap, language);

	String powerViewCmdName = PropertyUtil.getSchemaProperty(context, "command_AEFPowerViewHome");

	if (powerViewCmdName == null || (powerViewCmdName.trim().length()) == 0)
	{
		powerViewCmdName = "AEFPowerViewHome";
	}

	HashMap powerViewCmd = UIToolbar.getCommand(context, powerViewCmdName, toolsToolbar);

	if (powerViewCmd != null  &&
	    UINavigatorUtil.isSelectableAsHomePreference(context, powerViewCmd))
	{
		String powerViewCmdLabel = UINavigatorUtil.getI18nString("emxFramework.HomePortal.HeaderDisplay", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
		String powerViewChecked = "";

	    if (menuDefault != null &&
	    	menuDefault.equalsIgnoreCase(powerViewCmdName))
	    {
			powerViewChecked = "checked";
	    }
	    if (menuDefault == null || menuDefault.length() == 0 || menuDefault.equals("default"))
	    {
			powerViewChecked = "checked";
	    }
%>
		<TR valign="top">
			<TD width="8" align="center"><IMG src="images/utilSpacer.gif" width="10" height="4" alt="" border="0" /></TD>
			<!-- //XSSOK -->
			<TD width="8" align="center"><INPUT type="radio" name="homePage" value="AEFPowerViewHome" <%=powerViewChecked%> /></TD>
			<TD><IMG src="images/utilSpacer.gif" width="4" height="4" alt="" border="0" /></TD>
			<TD valign="middle"><xss:encodeForHTML><%=powerViewCmdLabel%></xss:encodeForHTML></TD>
		</TR>
		<TR valign="top">
			<TD align="center" valign="top" colspan="2"><IMG src="images/utilSpacer.gif" width="16" height="4" alt="" border="0" /></TD>
			<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
			<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
		</TR>
<%
	}
%>

<%
    //Added for Metrics Dashboard for making it as home page
    HashMap metricsGlobalToolbar = UIToolbar.getToolbar(context, "menu_MetricsGlobalToolbar", paramMap, language);
    String dashboardCmdName = PropertyUtil.getSchemaProperty(context, "command_MetricsDashboard");

    if (dashboardCmdName == null || (dashboardCmdName.trim().length()) == 0)
    {
        dashboardCmdName = "MetricsDashboard";
    }

    HashMap dashboardCmd = UIToolbar.getCommand(context, dashboardCmdName, metricsGlobalToolbar);

    if (dashboardCmd != null  &&
        UINavigatorUtil.isSelectableAsHomePreference(context, dashboardCmd))
    {
        String dashboardCmdLabel = UIToolbar.getLabel(dashboardCmd);
        String dashboardChecked = "";

        if (commandDefault != null &&
            commandDefault.equalsIgnoreCase(dashboardCmdName))
        {
            dashboardChecked = "checked";
        }
%>
        
<%
    }
%>

<%
	//Added for Channl UI Home Page
    String ChannelUIcmdName = PropertyUtil.getSchemaProperty(context, "command_AEFChannelUIHomePage");

    if (ChannelUIcmdName == null || (ChannelUIcmdName.trim().length()) == 0)
    {
    	ChannelUIcmdName = "AEFChannelUIHomePage";
    }

    HashMap ChannelUIcmd = UIToolbar.getCommand(context, ChannelUIcmdName);

    if (ChannelUIcmd != null  && UINavigatorUtil.isSelectableAsHomePreference(context, ChannelUIcmd))
    {
        String ChannelUIcmdLabel = UIToolbar.getLabel(ChannelUIcmd);
        ChannelUIcmdLabel = UINavigatorUtil.getI18nString(ChannelUIcmdLabel, "emxFrameworkStringResource", request.getHeader("Accept-Language"));
        String ChannelUIcmdChecked = "";

        if (commandDefault != null &&
            commandDefault.equalsIgnoreCase(ChannelUIcmdName))
        {
        	ChannelUIcmdChecked = "checked";
        }
%>
        <TR valign="top">
            <TD width="8" align="center"><IMG src="images/utilSpacer.gif" width="10" height="4" alt="" border="0"></TD>
            <!-- //XSSOK -->
            <TD width="8" align="center"><INPUT type="radio" name="homePage" value="<%=ChannelUIcmdName%>" <%=ChannelUIcmdChecked%>></TD>
            <TD><IMG src="images/utilSpacer.gif" width="4" height="4" alt="" border="0"></TD>
            <TD valign="middle" nowrap><xss:encodeForHTML><%=ChannelUIcmdLabel%></xss:encodeForHTML></TD>
        </TR>
        <TR valign="top">
            <TD align="center" valign="top" colspan="2"><IMG src="images/utilSpacer.gif" width="16" height="4" alt="" border="0"></TD>
            <TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt=""></TD>
            <TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt=""></TD>
        </TR>
<%
	}
%>
<%
    if (mydeskToolbar != null)
    {
        MapList myDeskChildren = UIToolbar.getChildren(mydeskToolbar);

        if (myDeskChildren != null)
        {
            for (int j = 0; j < myDeskChildren.size(); j++)
            {
                HashMap myDeskChild = (HashMap) myDeskChildren.get(j);
                String menuName = UIToolbar.getName(myDeskChild);

                // Check if the menu/command is selectable in preferences
                if (!UINavigatorUtil.isSelectableAsHomePreference(context, myDeskChild))
                {
                    continue;
                }

	            // if the child is a menu or menu item
	            if (UIToolbar.isMenu(myDeskChild))
	            {
	            	String menuLabel = UIToolbar.getLabel(myDeskChild);
%>
					<TR valign="top">
						<TD align="center" valign="top" colspan="2"><IMG src="images/utilSpacer.gif" width="16"  height="4" alt="" border="0" /></TD>
						<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
						<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
					</TR>
                    </TABLE>
					  <TABLE border="0" cellpadding="0" cellspacing="0" width="130">
						<TR>
						  <TD width="8" background="images/utilNavBarTabTop.gif"> <IMG src="images/utilSpacer.gif" border="0" alt="" width="8" height="9" /></TD>
						  <TD background="images/utilNavBarTabTop.gif"><IMG src="images/utilSpacer.gif" border="0" alt="" width="16" height="9" /></TD>
						  <TD width="27" valign="top"><IMG src="images/utilNavBarTabTopSide.gif" border="0" alt="" width="27" height="10" /></TD>
						</TR>
						<TR>
						  <TD width="8" valign="top"><IMG src="images/utilSpacer.gif" border="0" alt="*" width="16" height="15" /></TD>
						  <TD><A class="menu" href="javascript:void(0)"><xss:encodeForHTML><%=menuLabel%></xss:encodeForHTML></A></TD>
						  <TD width="27" valign="top"><IMG src="images/utilNavBarTabSide.gif" border="0" alt="" width="27" height="14" /></TD>
						</TR>
					<TR valign="top">
						<TD align="center" valign="top" colspan="2"><IMG src="images/utilSpacer.gif" width="16"  height="8" alt="" border="0" /></TD>
						<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
						<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
					</TR>
					  </TABLE>
					  <TABLE border="0" cellpadding="0" cellspacing="0" width="100%">
<%
            	}else if (UIToolbar.isCommand(myDeskChild))
            	{
            		String myDeskCommandLabel = UIToolbar.getLabel(myDeskChild);

					String mydeskMenuItemChecked = "";
				    if (menuDefault.equals(mydeskMenuName) && commandDefault.equals(menuName))
				    {
				    	mydeskMenuItemChecked = "checked";
				    }
%>
						<TR valign="top">
							<TD width="8" align="center"><IMG src="images/utilSpacer.gif" width="10" height="4" alt="" border="0" /></TD>
							<TD width="8" align="center"><INPUT type="radio" name="homePage" value="<xss:encodeForHTML><%=mydeskMenuName%></xss:encodeForHTML>|<xss:encodeForHTML><%=menuName%></xss:encodeForHTML>" <%=mydeskMenuItemChecked%>></TD>
							<TD width="4"><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
							<TD valign="middle"><xss:encodeForHTML><%=myDeskCommandLabel%></xss:encodeForHTML></TD>
						</TR>

						<TR valign="top">
							<TD align="center" valign="top" colspan="2"><IMG src="images/utilSpacer.gif" width="16"  height="4" alt="" border="0" /></TD>
							<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
							<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
						</TR>
<%
	            }

	                //if the menu does not have any commands to display, don't display it
	                if (UIToolbar.isMenu(myDeskChild))
	                {
				        MapList children = UIToolbar.getChildren(myDeskChild);

				        for (int i = 0; i < children.size(); i++)
				        {
				            HashMap child = (HashMap) children.get(i);

			                // Check if the menu/command is selectable in preferences
			                if (!UINavigatorUtil.isSelectableAsHomePreference(context, child))
			                {
			                    continue;
			                }

						    // determine the type of child
						    if (UIToolbar.isCommand(child))
						    {

						        String cmdName = UIToolbar.getName(child);
						        String itemLabel = UIToolbar.getLabel(child);

								String menuItemChecked = "";
							    if (menuDefault.equals(menuName) && commandDefault.equals(cmdName))
							    {
							    	menuItemChecked = "checked";
							    }

%>
								<TR valign="top">
									<TD width="8" align="center"><IMG src="images/utilSpacer.gif" width="10" height="4" alt="" border="0" /></TD>
									<TD width="8" align="center"><INPUT type="radio" name="homePage" value="<xss:encodeForHTML><%=menuName%></xss:encodeForHTML>|<xss:encodeForHTML><%=cmdName%></xss:encodeForHTML>" <%=menuItemChecked%>></TD>
									<TD width="4"><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
									<TD valign="middle"><xss:encodeForHTML><%=itemLabel%></xss:encodeForHTML></TD>
								</TR>
								<TR valign="top">
									<TD align="center" valign="top" colspan="2"><IMG src="images/utilSpacer.gif" width="16"  height="4" alt="" border="0" /></TD>
									<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
									<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
								</TR>
<%
        					}
			        	}
			 		}
            	}
%>
					<TR valign="top">
						<TD align="center" valign="top" colspan="2"><IMG src="images/utilSpacer.gif" width="16"  height="4" alt="" border="0" /></TD>
						<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
						<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
					</TR>
					<TR valign="top">
						<TD align="center" valign="top" colspan="2"><IMG src="images/utilSpacer.gif" width="16"  height="4" alt="" border="0" /></TD>
						<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
						<TD><IMG src="images/utilSpacer.gif" width="4" height="4" border="0" alt="" /></TD>
					</TR>
				</TABLE>
<%
        	}

    	}
    }
    catch (Exception ex)
    {
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
<input type="hidden" name="reloadparent" value="false"/>
</FORM>
</div>
<P>&nbsp; </P>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</BODY>
</HTML>
