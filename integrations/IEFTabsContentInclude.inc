<%--  IEFTabsContentInclude.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%!
	public static String DIR_IMAGES					= "./images/";
	public static String IMG_SPACE					= DIR_IMAGES + "utilSpace.gif";
    public static String IMG_ICON_TAB_TOP           = DIR_IMAGES + "utilTabTop.gif";
    public static String IMG_ICON_TAB_TOP_SIDE      = DIR_IMAGES + "utilTabTopSide.gif";
    public static String IMG_ICON_TAB_SIDE          = DIR_IMAGES + "utilTabSide.gif";
%>

<%
	MCADLocalConfigObject localConfigObj  = integSessionData.getLocalConfigObject();
	Context context						  = integSessionData.getClonedContext(session);
		
	String tabsContentJPO	= request.getParameter("tabsJPO");
	String jpoMethod		= request.getParameter("jpoMethod");
	String activeTabName	= request.getParameter("activeTabName");

	Vector tabsList			= null;
	
	if(tabsContentJPO != null)
	{
		//Invoke JPO for getting Tabs content
		String[] init = new String[] {};
		String[] args = new String[3];
		
		String[] packedLCO = JPO.packArgs(localConfigObj);
	
		args[0]	 = packedLCO[0];
		args[1]	 = packedLCO[1];
		args[2]  = integSessionData.getLanguageName();
		tabsList = (Vector)JPO.invoke(context, tabsContentJPO, init, jpoMethod, args, Vector.class);
	}

	String activeTabSelectionArgumentsString = "";
	if(activeTabName == null || activeTabName.trim().equals(""))
	{
		Hashtable activeTabDataTable = (Hashtable)tabsList.elementAt(0);
		activeTabName = (String)activeTabDataTable.get("TabName");
	}
%>

	<tr>
		<td>
			<table align="left" border="0" cellpadding="0" cellspacing="0">
				<tr>
<%
	for(int i=0; i<tabsList.size(); i++)
	{
		Hashtable tabDataTable	= (Hashtable)tabsList.elementAt(i);

		String tabName	        = (String)tabDataTable.get("TabName");
		String tabLabel	        = (String)tabDataTable.get("Label");
		String headerPage	    = (String)tabDataTable.get("HeaderPage");
		String contentPage	    = (String)tabDataTable.get("ContentPage");
		String footerPage	    = (String)tabDataTable.get("FooterPage");
		String tabIcon          = (String)tabDataTable.get("TabIcon");

		StringBuffer tabSelectionArgumentsBuffer = new StringBuffer();
		tabSelectionArgumentsBuffer.append("'" + headerPage + "', '");
		tabSelectionArgumentsBuffer.append(contentPage + "?tabsJPO=" + tabsContentJPO);
		tabSelectionArgumentsBuffer.append("&jpoMethod=" + jpoMethod);
		tabSelectionArgumentsBuffer.append("&activeTabName=" + tabName);
		tabSelectionArgumentsBuffer.append("', '" + footerPage + "'");

		String tabSelectionArgumentsString	= tabSelectionArgumentsBuffer.toString();
		
		String tabIconString				= "";
		if(tabIcon != null)
		{
			tabIconString = "&nbsp&nbsp&nbsp<img src=\"" + DIR_IMAGES + tabIcon + "\" border=\"0\"/>";
		}
%>

		        <td>
					<table border="0" cellpadding="0" cellspacing="0" width="150">
					<tr>
					    <!--XSSOK-->
						<td onClick="parent.changeTabSelection(<%= tabSelectionArgumentsString %>)" background="<%= IMG_ICON_TAB_TOP %>"><img src="<%= IMG_SPACE %>" border="0" width="16" height="9" /></td>
						<!--XSSOK-->
						<td onClick="parent.changeTabSelection(<%=  tabSelectionArgumentsString %>)" width="12" valign="top"><img src="<%=  IMG_ICON_TAB_TOP_SIDE %>" border="0"/></td>
					</tr>
					<tr>
					    <!--XSSOK-->
						<td onClick="parent.changeTabSelection(<%= tabSelectionArgumentsString %>)" class="tab">&nbsp<a class="tab" href="javascript:parent.changeTabSelection(<%=  tabSelectionArgumentsString %>)"><%= tabLabel + tabIconString %></a></td>
						<!--XSSOK-->
						<td onClick="parent.changeTabSelection(<%= tabSelectionArgumentsString %>)" width="12" valign="top"><img src="<%=  IMG_ICON_TAB_SIDE %>" border="0"/></td>
					</tr>

					<tr>
<%
		if(tabName.equals(activeTabName))
		{
			activeTabSelectionArgumentsString = tabSelectionArgumentsString;
%>
                        <!--XSSOK-->
						<td class="tabLineSelected" colspan="2"><img src="<%= IMG_SPACE %>" width="1" height="2"></td>
<%
		}
		else
		{
%>
                        <!--XSSOK-->
						<td class="tabLineUnselected" colspan="2"><img src="<%= IMG_SPACE %>" width="1" height="2"></td>
<%
		}
%>
					</tr>
					</table>
				</td>
<%
	}
%>
	        </tr>
		</table>
	</td>
	</tr>

	<tr>
	    <!--XSSOK-->
		<td valign="top" background="./images/utilTabBoarderTop.gif" width="100%"><img src="<%= IMG_SPACE %>" border="0" height="5"></td>
	</tr>
