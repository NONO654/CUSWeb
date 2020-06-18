<%-- @quickreview SBM1 17:09:25 : IR-550969-3DEXPERIENCER2018x Fix to prevent XSS attacks --%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<html>

	<head>
		<title></title>

		<script language="javascript">
			addStyleSheet("emxUIDefault","../common/styles/");
			addStyleSheet("emxUIForm","../common/styles/");
		</script>
		
		<script language="javascript">
			function CheckDivboxes(){ 	 
				if(document.forms.frmSync.chkPC.checked == true){
					document.forms.frmSync.chkDiv.checked=true;
					document.forms.frmSync.chkDiv.disabled=true;      	      	     	      	
				}
				if(document.forms.frmSync.chkPC.checked == false){
					document.forms.frmSync.chkDiv.checked=false;
					document.forms.frmSync.chkDiv.disabled=false;      	      	     	      	
				}
			} 

			function UpdateCheckboxes(){ 	 
				if(document.forms.frmSync.chkLIN.checked == true){
					document.forms.frmSync.chkProdRev.checked=true;
					document.forms.frmSync.chkProdRev.disabled=true;      	      	     	      	
				}
				if(document.forms.frmSync.chkLIN.checked == false){
					document.forms.frmSync.chkProdRev.checked=false;
					document.forms.frmSync.chkProdRev.disabled=false;      	      	     	      	
				}
			}
		</script>
	</head>

	<%
  	String sObjID			= emxGetParameter(request, "id");
  	String curType			= emxGetParameter(request, "type_var");
	String targetLocation = emxGetParameter(request, "targetLocation");
  	
  	String sVariantModelText  	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.VariantModelText", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sVariantModelsText  	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.VariantModelsText", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));

    String LINpub	        = com.matrixone.jsystem.util.Sys.getEnv("LIN_UNDER_PLATFORM");
    
    String sEvoModelText  	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EvolutionModelText", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEvoModelsText  	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EvolutionModelsText", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sOption  		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.AdditionalOption", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEnableEvo 		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EnableEvolution", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEnableVariant	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EnableVariant", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEnableProdRev 	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EnableProdRev", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEnableBuild 	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EnableBuilds", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEnableLIN 		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.LINUnderPlatform", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEnableDiversity	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.InputDiversity", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEnableProdConf	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.InputProdConf ", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sBuildRules	 	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.BuildCompositionRules", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEnableManufPlan	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EnableManufPlan", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
	%>

	<body>
		<form name="frmSync" method="post" action="../common/emxSynchronizeWithVPLM_Evolution.jsp?objectId=<%=XSSUtil.encodeForURL(context,sObjID)%>&targetLocation=<%=XSSUtil.encodeForURL(context,targetLocation)%>">
			<table>

  <tr>
    <td class="inputField">
						<p><input type="checkbox" name="chkType" value="Type" checked disabled><%=curType%></p>

						<%if((LINpub != null) && (LINpub.startsWith("ON"))){%>
							<p><input type="checkbox" name="chkLIN" value="LINEnabled" onClick="UpdateCheckboxes()"><%=sEnableLIN%></p>
						<%}%>
					</td>
				</tr>
				
				<tr>
					<td class="heading1">
						<%if(curType.equals("Model")){%>
    	<%=sVariantModelText%>
						<%}else{%>
    	<%=sVariantModelsText%>
						<%}%>
					</td>
				</tr>

				<tr>
					<td class="inputField">
						<p><input type="CheckBox" name="chkDiv" value="diversity"><%=sEnableDiversity%></p>
						<p><input type="CheckBox" name="chkPC" value="ProdConf" onClick="CheckDivboxes()"><%=sEnableProdConf%></p>
					</td>
				</tr>

				<tr>
					<td class="heading1">
						<%if(curType.equals("Model")){%>
    	<%=sEvoModelText%>
						<%}else{%>
    	<%=sEvoModelsText%>
						<%}%>
					</td>
				</tr>
    
				<tr>
					<td class="inputField">
						<p><input type="checkbox" name="chkProdRev" value="ProdRevEnabled"><%=sEnableProdRev%></p>
						<p><input type="checkbox" name="chkBuild" value="BuildEnabled"><%=sEnableBuild%></p>
						<p style="font-style:italic;"><%=sBuildRules%></p>
					</td>
				</tr>
    
				<tr>
					<td class="inputField">
						<p><input type="checkbox" name="chkManufPlan" value="ManufPlanEnabled"><%=sEnableManufPlan%></p>
					</td>
				</tr>

				<tr>
					<td class="heading1">
						<%=sOption%>
					</td>
				</tr>

				<tr>
					<td class="inputField">
						<p><input type="checkbox" name="chkVariant" value="VariantEnabled"><%=sEnableVariant%></p>
					    <p><input type="checkbox" name="chkEvo" value="EvoEnabled"><%=sEnableEvo%></p>
    </td> 
  </tr>

	    	</table>
    	</form>
	</body>
</html>
