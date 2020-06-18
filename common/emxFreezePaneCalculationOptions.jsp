<%--  emxFreezePaneCalculationOptions.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFreezePaneCalculationOptions.jsp.rca 1.1 Fri Dec  5 08:51:44 2008 ds-ukumar Experimental $
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%
String timeStamp = emxGetParameter(request, "timeStamp");
  try{
      String strLanguage = request.getHeader("Accept-Language");
  	  String helpDone = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.Done", request.getLocale());
  	  String helpCancel = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.FormComponent.Cancel", request.getLocale());
  	String sHelpMarker = "emxtablecalculationoptions";
	//Modified for Bug - 344115
	String toolbarURL = "PrinterFriendly=false&export=false&HelpMarker="+sHelpMarker;
%>
<html>
      <head>
       	<script type="text/javascript" language="JavaScript" src="scripts/jquery-latest.js"></script>
      	<script type="text/javascript" language="JavaScript" src="scripts/emxUITableUtil.js"></script>
      	<script type="text/javascript" language="JavaScript" src="scripts/emxUICalculationUtil.js"></script>
      	<script type="text/javascript" language="javascript" src="scripts/emxUIConstants.js"></script>
      	<script type="text/javascript" language="JavaScript" src="scripts/emxUICore.js"></script>
      	<script type="text/javascript" language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
      	<script type="text/javascript" language="JavaScript" src="scripts/emxUIToolbar.js"></script>
      	<script type="text/javascript" language="JavaScript" src="scripts/emxNavigatorHelp.js"></script>
      	<title>
      		<emxUtil:i18n localize="i18nId">emxFramework.TableCalculation.OptionsHeader</emxUtil:i18n>
      	</title>
      	<script type="text/javascript">
            addStyleSheet("emxUIDefault");
      		addStyleSheet("emxUIDialog");
      		addStyleSheet("emxUIToolbar");
      		addStyleSheet("emxUIDOMLayout");
      	</script>
      </head>

    <body id="fpCalculationDialog" onload="turnOffProgress();">
	<!--  Header -->
    <div id="pageHeadDiv">
		<form>
		   <table>
			<tr>
		    <td class="page-title">
		      <h2><emxUtil:i18n localize="i18nId">emxFramework.StructureBrowser.OptionsHeader</emxUtil:i18n></h2>
		    </td>
<%
	String processingText = UINavigatorUtil.getProcessingText(context, strLanguage);
%>
        <td class="functions">
        <table>
			<tr>
                <!-- //XSSOK -->
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
        </tr></table>
        </td>
			</tr>
		</table>
					<!-- //XSSOK -->
					<script language="JavaScript" src="emxToolbarJavaScript.jsp?<%= toolbarURL %>" type="text/javascript"></script>
					<div  class="toolbar-container" id="divToolbarContainer">
						<div id="divToolbar" class="toolbar-frame"></div>
					</div>
</form>
	</div>
	<!--  Body -->
	<div id="divPageBody">
		<iframe	name="formfpCalculations"
						src="emxFreezePaneCalculationOptionsDisplay.jsp?timeStamp=<%=XSSUtil.encodeForURL(context, timeStamp)%>"
						height="100%"
						width="100%"
						border="0"
						frameborder="no"
						marginwidth="0"
						marginheight="0">
		</iframe>
	</div>
	<!--  Footer -->
	<div id="divPageFoot">
<table border="0" cellspacing="0" cellpadding="0" width="100%">
			<tr>
    <td class="pagination"></td>
	<td class="buttons">
    <table>
			<tr>
			<td><a class="footericon" href="#" onClick="formfpCalculations.submitOptions()"><img src="images/buttonDialogDone.gif" alt="<%=helpDone%>" /></a></td>
			<td><a href="#" onClick="formfpCalculations.submitOptions()"><button class="btn-primary" type="button"><%=helpDone%></button></a></td>
			<td><a class="footericon" href="javascript:getTopWindow().closeWindow()"><img src="images/buttonDialogCancel.gif" alt="<%=helpCancel%>" /></a></td>
			<td><a onClick="javascript:getTopWindow().closeWindow()"><button class="btn-default" type="button"><%=helpCancel%></button></a></td>
		</tr>
	</table>
							</td>
			</tr>
		</table>
	</div>
  </body>

<%	//out.clear();
	}catch(Exception ex){
	    if (ex.toString() != null && (ex.toString().trim()).length() > 0){
	        emxNavErrorObject.addMessage(ex.toString().trim());
	    %><%@include file = "emxNavigatorBottomErrorInclude.inc"%><%
	    }
	}
%>
</html>
