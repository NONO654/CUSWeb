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

 <script language="JavaScript">
			function CheckAll(){ 
				if(document.forms.frmSync.chkProduct.checked == true){
      	document.forms.frmSync.chkDiv.checked=true;
      	document.forms.frmSync.chkDiv.disabled=true;
      	
      	document.forms.frmSync.chkBOM.checked=true;
      	document.forms.frmSync.chkBOM.disabled=true;
      	
     	document.forms.frmSync.chkPC.checked=true;
     	document.forms.frmSync.chkPC.disabled=true;
    }
				if(document.forms.frmSync.chkProduct.checked == false){
       	document.forms.frmSync.chkDiv.checked=false;
   		document.forms.frmSync.chkDiv.disabled=false;
   		
        document.forms.frmSync.chkBOM.checked=false;
   		document.forms.frmSync.chkBOM.disabled=false;
   		
       	document.forms.frmSync.chkPC.checked=false;
     	document.forms.frmSync.chkPC.disabled=false;
   	}	
  }
 </script>
	</head>

	<%
  	String sProdID = emxGetParameter(request, "id");
	String targetLocation = emxGetParameter(request, "targetLocation");
  	String mode = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.Mode", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String Product = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.InputProduct", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String diversity = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.Diversity", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String LIN = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.InputLIN", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	String prodConf = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.InputProdConf", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
	String prodConfLog = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.ProdConfLogical", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
  	%>

	<body>
		<form name="frmSync" method="post" action="../common/emxSyncronizeWithVPLM_X3_unpublish.jsp?objectId=<%=XSSUtil.encodeForURL(context,sProdID)%>&targetLocation=<%=XSSUtil.encodeForURL(context,targetLocation)%>">
			<table>

				<tr>
					<td class="inputField">
						<input type="CheckBox" name="chkProduct" value="Product" onClick="CheckAll()"><%=Product%>
						<br>
						<input type="CheckBox" name="chkPC" value="PC"><%=prodConf%>
						<br>
						<input type="CheckBox" name="chkCLF" value="ProdConfLog" onClick="CheckDiv()"><%=prodConfLog%>
					</td> 
				</tr>
			</table>
		</form>
	</body>
</html>
