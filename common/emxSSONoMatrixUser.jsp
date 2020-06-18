<%--  emxSSONoMatrixUser.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSSONoMatrixUser.jsp.rca 1.5 Wed Oct 22 15:48:57 2008 przemek Experimental przemek $
--%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@ page import="com.matrixone.servlet.Framework,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.FrameworkProperties" %>

<%
String sPreUserNameMessage = UINavigatorUtil.getI18nString("emxFramework.SSO.NoMatrixUser1", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
String sPostUserNameMessage = UINavigatorUtil.getI18nString("emxFramework.SSO.NoMatrixUser2", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
String sAdminMessage = UINavigatorUtil.getI18nString("emxFramework.SSO.NoMatrixUser3", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
String sErrorMessage =  sPreUserNameMessage + request.getRemoteUser() + sPostUserNameMessage;
String sBack =  UINavigatorUtil.getI18nString("emxFramework.SSO.NoMatrixUser.Back", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
String sError =  UINavigatorUtil.getI18nString("emxFramework.SSO.NoMatrixUser.Error", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
    matrix.db.Context context = Framework.getFrameContext(session);
String sMyAppName = EnoviaResourceBundle.getProperty(context, "emxFramework.Application.Name");
String sMyLoginImage = EnoviaResourceBundle.getProperty(context, "emxFramework.Application.LoginImage");

%>
<HTML>
  <HEAD>
    <TITLE>
      <%=sMyAppName%> Login Failure
    </TITLE>
    <LINK rel="stylesheet" type="text/css" href="styles/emxUIDefault.css" />
  </HEAD>
  <style>

	body.background {
	background-image: url(../utilSplashBodyBGD.gif); 
	background-position: 100% 0px; 
	overflow: auto;
	}
	
	div#mx_divLayerDialog {
		width: 300px;
		background-color: rgb(230,230,230);
		font-family: Verdana, Arial, Helvetica;
		font-size: 12px;
		border: 1px solid rgb(66,66,66);
		border-top: 1px solid rgb(116,116,116);
		border-left: 1px solid rgb(116,116,116);
		}

	/* dialog header default appearance */ 
	div#mx_divLayerDialogHeader {

		background-color: rgb(0,83,225);
		background-image: url(../common/images/iconSmallStatusAlert.gif);
		background-repeat: no-repeat;
		background-position: 8px 4px;
		color: rgb(255,255,255);
		height: 23px;
		font-family: Arial;
		font-weight: bold;
		font-size: 13px;
		text-shadow: rgb(10,24,131) 2px 2px;
		text-align: left;
		padding: 4px 4px 2px 28px;
		border: none;
		border-top: solid 1px #6a9bff;
		border-right: solid 1px rgb(230,230,230);
		border-bottom: 1px solid rgb(230,230,230);
		border-left: solid 1px #6a9bff;

		}


	/* dialog footer default appearance */ 
	div#mx_divLayerDialog {
		min-height: 20px;
		border-top: solid 1px white;
		border-right: solid 1px black;
		border-bottom: solid 1px black;
		border-left: solid 1px white;
		margin: 0;
		font: 11px verdana;
		padding: 0px 0px 10px 0px;
		margin-left: auto; 
		margin-right: auto; 
		}
		
		div#mx_divLayerDialogFooter {
		min-height: 20px;
		font: 11px verdana;
		padding: 0px 0px 5px 0px;
		margin-left: auto; 
		margin-right: auto;
		}
		
	/* button appearance */
	.button {
		font: 11px verdana;
		padding: 0px 12px 0px 12px;
		
		}


	div#mx_divLayerDialogBody {
		min-height: 50px;
		padding: 0px 10px 4px 10px;
		font: 11px verdana;
		text-align: left;
		}

		td.dialog {
		text-align: center;
		vertical-align: middle;
		}

	</style>
  <body class="background">
	<table cellpadding="0" cellspacing="0" border="0" width="100%" height="100%">
		<tr>
			<td class="dialog">
				<div id="mx_divLayerDialog">
					<div id="mx_divLayerDialogHeader"><%=sError%></div>
						<div id="mx_divLayerDialogBody">
							<p><%=sErrorMessage%></p>
							<p><%=sAdminMessage%></p>
							</p>
						</div>
						<div id="mx_divLayerDialogFooter">
							<table border="0" cellpadding="0" cellspacing="0" width="100%">
								<tr>
									<td align="center"><input type="button" value="<%=sBack%>" class="button" onclick="javascript:history.go(-1);" /></td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</td>
		</tr>
	</table>
  </BODY>
</HTML>
