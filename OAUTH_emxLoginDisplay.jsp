<%--  OAUTH_emxLoginDisplay.jsp   - Main login page for MatrixOne applications

   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: OAUTH_emxLoginDisplay.jsp.rca 1.1.1.5 Wed Oct 22 16:09:12 2008 przemek Experimental przemek $";
--%>
<%@include file = "common/emxNavigatorInclude.inc"%>

<html>
<head>
<title><emxUtil:i18n localize="i18nId">emxFramework.Login.Title</emxUtil:i18n></title>
<style>

	body.background {
	background-image: url(utilSplashBodyBGD.gif); 
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
		background-image: url(common/images/iconSmallStatusAlert.gif);
		background-repeat: no-repeat;
		background-position: 8px 4px;
		color: rgb(255,255,255);
		height: 18px;
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
</head>
<body class="background">
	<table cellpadding="0" cellspacing="0" border="0" width="100%" height="100%">
  <tr>
			<td class="dialog">
				<div id="mx_divLayerDialog">
					<div id="mx_divLayerDialogHeader"><emxUtil:i18n localize="i18nId">emxFramework.ToggleToolbar.Alert</emxUtil:i18n></div>
					<div id="mx_divLayerDialogBody">
						<p><emxUtil:i18n localize="i18nId">emxFramework.ToggleToolbar.LoginMessage</emxUtil:i18n></p>	
					</div>
				</div>
        </td>
  </tr>
</table>
</body>
</html>
