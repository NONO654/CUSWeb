<%-- @quickreview SBM1 17:09:25 : IR-550969-3DEXPERIENCER2018x Fix to prevent XSS attacks --%>
<%@include file = "../common/emxNavigatorInclude.inc"%>




<html>

	<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

	<head>
		<title></title>

		<%@include file = "../common/emxUIConstantsInclude.inc"%>

		<script type="text/javascript" language="JavaScript">
			addStyleSheet("emxUIDefault","../common/styles/");
			addStyleSheet("emxUIToolbar","../common/styles/");
		</script>

		<script language="javascript">

			function doDone(targetLocation){
				var close = "false";
				var frameDisplayCreateECA = findFrame(top,"frameDisplayCreateECA");
				var editForm = "";
				if(frameDisplayCreateECA==null){
					close = "true";
				}else{
					editForm = frameDisplayCreateECA.document.getElementsByName("editForm");
					if(editForm==null){
						close = "true";
					}
				}

				var isFormValid = frameDisplayCreateECA.validateForm();
				if(isFormValid){
					if(close=="true"){
						if(targetLocation=="popup"){
							top.close();
						}else if(targetLocation=="slidein"){
							top.closeSlideInDialog();
						}
					}else if(close=="false"){
						turnOnProgress();
						editForm.target="_top";
						frameDisplayCreateECA.document.editForm.submit();
					}
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
	String strLanguage = request.getHeader("Accept-Language");
	String objectId = emxGetParameter(request,"objectId");
	String titleKey = emxGetParameter(request,"titleKey");
	if(titleKey==null || titleKey.length()==0){
		titleKey = "emxVPMCentral.Change.Form.Header.CreateECA";
	}
	String header = UINavigatorUtil.getI18nString(titleKey, "emxVPMCentralStringResource", strLanguage);
	String failed = request.getParameter("failed");
	if(failed ==null || "null".equals(failed)){
		failed ="0";
	}

	String targetLocation = emxGetParameter(request, "targetLocation");

	String browser = request.getHeader("USER-AGENT");
    boolean isIE = browser.indexOf("MSIE") > 0;

    StringBuffer parametersBuffer = new StringBuffer();
    Map parameters = request.getParameterMap();
	java.util.Set keys = parameters.keySet();
	Iterator keysItr = keys.iterator();
	while(keysItr.hasNext()){
		String key = (String) keysItr.next();
		String value[] = (String[])parameters.get(key);

		if(parametersBuffer!=null && !parametersBuffer.toString().isEmpty()){
			parametersBuffer.append("&");
		}
		parametersBuffer.append(key + "=" + XSSUtil.encodeForURL(context,value[0]));
	}
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
			<iframe id="frameDisplayCreateECA" name="frameDisplayCreateECA" src="../common/emxVPMCreateVPMActionBody.jsp?<%=parametersBuffer.toString()%>"></iframe>
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

	<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</html>


