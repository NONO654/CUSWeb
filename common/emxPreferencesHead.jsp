<%--  emxPreferencesHead.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPreferencesHead.jsp.rca 1.13 Wed Oct 22 15:48:09 2008 przemek Experimental przemek $
--%>

<%@include file="emxNavigatorNoDocTypeInclude.inc"%>
<link rel="stylesheet" type="text/css"
	href="../common/mobile/styles/emxUIMobile.css">
<jsp:useBean id="emxMenu" class="com.matrixone.apps.framework.ui.UIMenu"
	scope="request" />
<%

  String sHelpMarker=emxGetParameter(request, "HelpMarker");
  String suiteDir=emxGetParameter(request, "SuiteDirectory");
  String languageStr = request.getHeader("Accept-Language");

  if(suiteDir==null && sHelpMarker==null)
  {
                   String cmdSuite="";
                   String cmdHelpMarker="";
                   boolean noMenuFound=false;
                   String prefBodyHRef = null;

                    try
                    {

                    ContextUtil.startTransaction(context, false);
                    Vector userRoleList = PersonUtil.getAssignments(context);
                    String propName = "menu_Preferences";
                    String menuName = PropertyUtil.getSchemaProperty(context, propName);
                    MapList menuMapList = emxMenu.getOnlyMenus(context, menuName, userRoleList);
                    if (menuMapList.size() == 0)
                    {
                       noMenuFound=true;
                    }
                    else
                            {
                                for (int i = 0; i < menuMapList.size(); i++)
                                {
                                    HashMap subMenuItem = (HashMap)menuMapList.get(i);
                                    String subMenuName = emxMenu.getName(subMenuItem);
                                    MapList cmdMapList = emxMenu.getOnlyCommands(context, subMenuName, userRoleList);
                                    boolean commandfound=false;
                                    for (int j = 0; j < cmdMapList.size(); j++)
                                    {
                                        HashMap cmdItem = (HashMap)cmdMapList.get(j);
                                        String cmdStringResFileId = "emxFrameworkStringResource";
                                        cmdSuite = emxMenu.getSetting(cmdItem, "Registered Suite");
                                        if ( (cmdSuite != null) && (cmdSuite.trim().length() > 0 ) )
                                        {
                                            suiteDir = UINavigatorUtil.getRegisteredDirectory(context,cmdSuite);
                                        }
                                        sHelpMarker = emxMenu.getSetting(cmdItem, "Help Marker");
                                        commandfound=true;
                                        break;
                                    } //END OF INNER FOR

                                 if(commandfound){
                                   break;
                                 }


                                }
                            }
                    }catch (Exception ex) {
                                ContextUtil.abortTransaction(context);
                    }
                    finally
                    {
                        ContextUtil.commitTransaction(context);
                    }

 }else{

                  if (suiteDir == null || suiteDir.trim().length() == 0)
                  {
                    suiteDir = "common";
                  }

                  if (sHelpMarker == null || sHelpMarker.trim().length() == 0)
                  {
                    sHelpMarker = "emxhelppreferences";
                  }

  } //END OF IF

  String strHelp = UINavigatorUtil.getI18nString("emxFramework.Common.Help","emxFrameworkStringResource",languageStr);
  String strTitle = UINavigatorUtil.getI18nString("emxFramework.Preferences.Title","emxFrameworkStringResource",languageStr);  
 
%>
<table>
	<tr>
		<td class="page-title">
			<!-- //XSSOK -->
			<h2 id="ph"><%=strTitle%></h2>
		</td>
		<td class="functions">
			<table>
				<tr>
					<td class="progress-indicator"><div id="imgProgressDiv"></div></td>
					<td class="header-action">
						<a href="javascript:openHelp('<xss:encodeForJavaScript><%=sHelpMarker%></xss:encodeForJavaScript>', '<xss:encodeForJavaScript><%=suiteDir%></xss:encodeForJavaScript>', '<xss:encodeForJavaScript><%=langStr%></xss:encodeForJavaScript>', '<xss:encodeForJavaScript><%=langOnlineStr%></xss:encodeForJavaScript>')">
							<!-- //XSSOK -->
							<img src="images/iconActionHelp.png" title="Help" border="0">
						</a>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

