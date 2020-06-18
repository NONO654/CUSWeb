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
			function CheckAll(){ 	 
				if(document.forms.frmSync.chkType.checked == true){
					document.forms.frmSync.chkProdRev.checked=true;
				 	document.forms.frmSync.chkProdRev.disabled=true;      	      	
				 	document.forms.frmSync.chkBuild.checked=true;
				 	document.forms.frmSync.chkBuild.disabled=true;
				 	document.forms.frmSync.chkDiv.checked=true;
				 	document.forms.frmSync.chkDiv.disabled=true; 
				 	document.forms.frmSync.chkPC.checked=true;
				 	document.forms.frmSync.chkPC.disabled=true;
				 	document.forms.frmSync.chkManufPlan.checked=true;
				 	document.forms.frmSync.chkManufPlan.disabled=true;       	      	
				 	document.forms.frmSync.chkLIN.checked=true;
				 	document.forms.frmSync.chkLIN.disabled=true;      	      	
			     }
				 if((document.forms.frmSync.chkType.checked == false) && (document.forms.frmSync.chkProdRev.disabled == true)){
				 	document.forms.frmSync.chkProdRev.checked=false;
				 	document.forms.frmSync.chkProdRev.disabled=false;      	      	
				 	document.forms.frmSync.chkBuild.checked=false;
				 	document.forms.frmSync.chkBuild.disabled=false;
				 	document.forms.frmSync.chkDiv.checked=false;
				 	document.forms.frmSync.chkDiv.disabled=false;
				 	document.forms.frmSync.chkPC.checked=false;
				 	document.forms.frmSync.chkPC.disabled=false;
				 	document.forms.frmSync.chkManufPlan.checked=false;
				 	document.forms.frmSync.chkManufPlan.disabled=false;        	      	
				 	document.forms.frmSync.chkLIN.checked=false;
				 	document.forms.frmSync.chkLIN.disabled=false;      	      	
				}
			}
		</script>

	</head>

	<%
  	String sObjID				= emxGetParameter(request, "id");
    String curType				= emxGetParameter(request, "type_var");
    String targetLocation = emxGetParameter(request, "targetLocation");
    
    String LINpub				= com.matrixone.jsystem.util.Sys.getEnv("LIN_UNDER_PLATFORM");
    
    String warningModelvariant	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EvoModelWarningVariant", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String warningModelsvariant	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EvoModelsWarningVariant", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String warningModel			= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EvoModelWarning", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String warningModels		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EvoModelsWarning", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEnableProdRev 		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EnableProdRev", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEnableBuild 		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EnableBuilds", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sEnableManufPlan		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.EnableManufPlan", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	
  	String sUnpublishCfg  		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.Diversity", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String sUnpublishProdConf 	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.InputProdConf", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	  	
  	String sUnpublishLIN 		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.LINUnderPlatform", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	%>
  	
	<body>
		<form name="frmSync" method="post" action="../common/emxSynchronizeWithVPLM_Evolution_unpublish.jsp?objectId=<%=sObjID%>&targetLocation=<%=targetLocation%>" >
			<table>

				<tr>
					<td class="inputField">
						<p><input type="checkbox" name="chkType" value="Type" onClick="CheckAll()"><%=curType%></p>
						
						<%if((LINpub != null) && (LINpub.startsWith("ON"))){%>
							<p><input type="checkbox" name="chkLIN" value="LINEnabled"><%=sUnpublishLIN%></p>
						<%}%>
					</td>
				</tr>

  <tr>

				<tr>
					<td class="heading1">
						<%if(curType.equals("Model")){%>
    	<%=warningModelvariant%>
						<%}else{%>
    	<%=warningModelsvariant%>
						<%}%>  
					</td>
				</tr>
		    
				<tr>
					<td class="inputField">
						<p><input type="CheckBox" name="chkDiv" value="diversity"><%=sUnpublishCfg%></p>
						<p><input type="CheckBox" name="chkPC" value="ProdConf"><%=sUnpublishProdConf%></p>
					</td>
				</tr>
    
				<tr>
					<td class="heading1">
						<%if(curType.equals("Model")){%>
    	<%=warningModel%>
						<%}else{%>
    	<%=warningModels%>
						<%}%>
					</td>
				</tr>
    
				<tr>
					<td class="inputField">
						<p><input type="checkbox" name="chkBuild" value="BuildEnabled"><%=sEnableBuild%></p>
						<p><input type="checkbox" name="chkProdRev" value="ProdRevEnabled"><%=sEnableProdRev%></p>
						<p><input type="checkbox" name="chkManufPlan" value="ManufPlanEnabled"><%=sEnableManufPlan%></p>
    </td>
  </tr>
			</table>
		</form>

	</body>

</html>
