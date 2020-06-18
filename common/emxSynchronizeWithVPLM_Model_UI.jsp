<%-- @quickreview SBM1 17:09:25 : IR-550969-3DEXPERIENCER2018x Fix to prevent XSS attacks --%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<html>

	<head>
		<title></title>

		<script type="text/javascript" language="JavaScript">
			addStyleSheet("emxUIDefault","../common/styles/");
			addStyleSheet("emxUIToolbar","../common/styles/");
		</script>
		
		<script language="javascript">
			function doDone(targetLocation){
				var close = "false";
				var syncDisplayFrame = findFrame(top,"syncDisplayFrame");
				var frmSync = "";
				if(syncDisplayFrame==null){
					close = "true";
				}else{
					frmSync = syncDisplayFrame.document.getElementsByName("frmSync");
					if(frmSync==null){
						close = "true";
					}
				}
				
				if(close=="true"){
					if(targetLocation=="popup"){
						top.close();
					}else if(targetLocation=="slidein"){
						top.closeSlideInDialog();
					}
				}else if(close=="false"){		
					turnOnProgress();
				    //top.syncDisplayFrame.document.frmSync.target="_top";
					frmSync.target="_top";
				    //top.syncDisplayFrame.document.frmSync.submit();
					syncDisplayFrame.document.frmSync.submit();
					document.getElementById("doneButtonId").style.visibility="hidden";
					document.getElementById("doneLabelId").style.visibility="hidden";
					document.getElementById("cancelLabelId").firstChild.data = "<emxUtil:i18n localize='i18nId'>emxFramework.Common.Close</emxUtil:i18n>";

					//frmSync.submit();
				}
			}
			
			function doCancel(targetLocation){
				if(targetLocation=="popup"){
					top.close();
				}else if(targetLocation=="slidein"){
					top.closeSlideInDialog();
				}
			}
		</script>
	
	</head>

	<%
    String sObjID 	= emxGetParameter(request, "objectId");
    String curType 	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.Model", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String title  	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.InputTitle", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String header  	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.InputHeader", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    String LINpub	= com.matrixone.jsystem.util.Sys.getEnv("LIN_UNDER_PLATFORM");
    String targetLocation = emxGetParameter(request, "targetLocation");

	String browser = request.getHeader("USER-AGENT");
    boolean isIE = browser.indexOf("MSIE") > 0;
    %>
    
    <body class="slide-in-panel" onload="turnOffProgress();">
	
		<div id="pageHeadDiv">
			<form name="formHeaderForm">
				<table>
					<tr>
						<td class="page-title">
							<h2><%=header%></h2>
						</td>
						<td class="functions">
							<table>
								<tr>
									<td class="progress-indicator"><div id="imgProgressDiv"></div></td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
				<div class="toolbar-container" id="divToolbarContainer">
					<div id="divToolbar" class="toolbar-frame"></div>
				</div>
			</form>     		
		</div>
	
		<div id="divPageBody" <%if(isIE){%> style="top:85px;" <%}%>>
			<iframe name="syncDisplayFrame" src="../common/emxSynchronizeWithVPLM_Evolution_UICenter.jsp?id=<%=XSSUtil.encodeForURL(context,sObjID)%>&type_var=<%=XSSUtil.encodeForURL(context,curType)%>&targetLocation=<%=XSSUtil.encodeForURL(context,targetLocation)%>"></iframe>
		</div>
		
		<div id="divPageFoot">
			<table>
				<tr>
					<td class="functions"></td>
					<td class="buttons">
						<table>
							<tr>
								<td><a name="doneButton" id="doneButtonId" href="javascript:doDone('<%=XSSUtil.encodeForJavaScript(context, targetLocation)%>')"><img src="images/buttonDialogDone.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Button.Submit</emxUtil:i18n>"></a></td>
								<td><a name="doneLabel" id="doneLabelId" href="javascript:doDone('<%=XSSUtil.encodeForJavaScript(context, targetLocation)%>')" class="button"><emxUtil:i18n localize="i18nId">emxFramework.Button.Submit</emxUtil:i18n></a></td>
								<td><a name="cancelButton" id="cancelButtonId" href="javascript:doCancel('<%=XSSUtil.encodeForJavaScript(context, targetLocation)%>')"><img src="images/buttonDialogCancel.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n>"></a></td>
								<td><a name="cancelLabel" id="cancelLabelId" href="javascript:doCancel('<%=XSSUtil.encodeForJavaScript(context, targetLocation)%>')" class="button"><emxUtil:i18n localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n></a></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>     		
		</div>

	</body>
<html>

