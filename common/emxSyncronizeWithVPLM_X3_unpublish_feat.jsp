<%-- @quickreview SBM1 17:09:25 : IR-550969-3DEXPERIENCER2018x Fix to prevent XSS attacks --%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>

<html>

	<head>
		<title></title>
    
		<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
		<script language="javascript" src="../common/scripts/emxUICore.js"></script>
		<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
		<script language="javaScript" src="../common/scripts/emxUITableUtil.js"></script>
		
		<script language="javascript">
		    addStyleSheet("emxUIDefault","../common/styles/");
		    addStyleSheet("emxUIToolbar","../common/styles/");
		    addStyleSheet("emxUIList","../common/styles/");
		    addStyleSheet("emxUIProperties","../common/styles/");
    addStyleSheet("emxUITemp","../");
		    addStyleSheet("emxUIForm","../common/styles/");
	    </script>
	    
	    <script language="javascript">
			function showVPMDetails(){
				var VPMDetails = document.getElementById('VPMDetails');
				var VPMDetailsLink = document.getElementById("VPMDetailsLink");
				if(VPMDetails.style.display=="none"){
					VPMDetails.style.display="block";
					VPMDetailsLink.firstChild.data="Hide corresponding modifications in VPM";
				}else if(VPMDetails.style.display=="block"){
					VPMDetails.style.display="none";
					VPMDetailsLink.firstChild.data="See corresponding modifications in VPM";
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
    String targetLocation = emxGetParameter(request, "targetLocation");
    String header = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.UnpublishInputHeader", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    
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
    <%
	String prodSize  			= "0";
	String cfgFeatSize  		= "0";
	String LINFeatSize  		= "0";
	String partSize  			= "0";
	String incRuleSize 			= "0";
	String prodConfSize 		= "0";
	String syncVersion  		= "";
		    String prodUnpublished = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.ProdUnpublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
		    String cfgFeatUnpublished = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.CfgFeatUnpublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
		    String LINFeatUnpublished = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.LINFeatUnpublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
		    String partUnpublished = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.PartUnpublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
		    String incRuleUnpublished = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.IncRuleUnpublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
		    String prodConfUnpublished = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.ProdConfUnpublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
	List MsgVector 			= null;
	int    VPMsize 				= 0;
			
			try{
        // Get the object ID
        String partID		= emxGetParameter(request, "objectId");
        
        //Create the arguments
        Hashtable argTable = new Hashtable();
        argTable.put("ROOTID", partID);
				String[] args = JPO.packArgs(argTable);        
        
        // Invoke the JPO
        Map matrixObjIDvplmObjIDMap = (Map)JPO.invoke(context, "VPLMIntegSyncWithVPLM", null, "execute", args, Map.class);
				if(matrixObjIDvplmObjIDMap!=null & matrixObjIDvplmObjIDMap.size()>0){
	        String operationStatus = (String)matrixObjIDvplmObjIDMap.get(VPLMIntegrationConstants.MAPKEY_OPERATION_STATUS);
					if(operationStatus.equals("false")){
	            String errMessage = (String)matrixObjIDvplmObjIDMap.get(VPLMIntegrationConstants.MAPKEY_ERROR_MESSAGE);
	            Exception e = new Exception(errMessage);
	            throw(e);
	        }
	        //Reached here means operation status is true, so remove this element from the table
	        matrixObjIDvplmObjIDMap.remove(VPLMIntegrationConstants.MAPKEY_OPERATION_STATUS);
			
			String msgString = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.UnpublishSucceeded", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language")) + "<br>";
			
			// Write number of objects published
			prodSize  		= (String)matrixObjIDvplmObjIDMap.get("prodSize");
			cfgFeatSize  	= (String)matrixObjIDvplmObjIDMap.get("cfgFeatSize");
			LINFeatSize  	= (String)matrixObjIDvplmObjIDMap.get("LINFeatSize");
			partSize  		= (String)matrixObjIDvplmObjIDMap.get("partSize");
			incRuleSize		= (String)matrixObjIDvplmObjIDMap.get("incRuleSize");
			prodConfSize	= (String)matrixObjIDvplmObjIDMap.get("prodConfSize");
					if(prodSize == null){prodSize = "0";}
					if(cfgFeatSize == null){cfgFeatSize = "0";}
					if(LINFeatSize == null){LINFeatSize = "0";}
					if(partSize == null){partSize = "0";}
					if(incRuleSize == null){incRuleSize = "0";}
					if(prodConfSize == null){prodConfSize = "0";}
					
    %>
					<table>
			    <tr>
							<td class="heading1">
								<p style="text-align:center; color:green; font-size:10pt;"><%=msgString%></p>
							</td>
			        </tr>
			        <tr>
							<td class="inputField">
								<p><%=prodSize%> <%=prodUnpublished%></p>
								<p><%=cfgFeatSize%> <%=cfgFeatUnpublished%></p>
								<p><%=LINFeatSize%> <%=LINFeatUnpublished%></p>
								<p><%=partSize%> <%=partUnpublished%></p>
								<p><%=incRuleSize%> <%=incRuleUnpublished%></p>
								<p><%=prodConfSize%> <%=prodConfUnpublished%></p>
			    </td>
			    </tr>
			</table>
    <%
    if (matrixObjIDvplmObjIDMap.containsKey(VPLMIntegrationConstants.MAPKEY_REPORT_MESSAGE)){
					MsgVector = (List)matrixObjIDvplmObjIDMap.get(VPLMIntegrationConstants.MAPKEY_REPORT_MESSAGE);
			}			
					if(MsgVector != null){
						VPMsize = MsgVector.size() * 22;
					}else{
						VPMsize = 0;
					}
					
    %>		  	
			    	<table>
			<tr>
							<td class="heading1" style="text-align:center;">
								<a id="VPMDetailsLink"  href="javascript:showVPMDetails()">See corresponding modifications in VPM</a>
							</td>
			</tr>
						<tr>
							<td class="inputField" id="VPMDetails" style="display:none">
								<%if(MsgVector != null){
									for(int i=0;i< MsgVector.size();i++){
	                String msg = (String)MsgVector.get(i);
	 %>
										<p><%=msg%></p>
									<%}
								}%>
							</td>
						</tr>
				</table>
				<%}
			}catch(Exception exception){
		String msgSyncFailed = UINavigatorUtil.getI18nString("emxVPLMSynchro.Failed.VPLMSyncFailed", "emxVPLMSynchroStringResource", request.getHeader("Accept-Language")) ;
        String msgString = exception.getMessage().replaceAll("'","");
        
		List list = new ArrayList();
		StringTokenizer tok = new StringTokenizer(msgString, "|");
		int counter=0;
				while(tok.hasMoreElements()){
            String line = (String) tok.nextElement();
            list.add(line.substring(line.lastIndexOf('|')+1));
        }
	%>
				<table>
					<tr>
						<td class="heading1">
							<p style="text-align:center; color:red; font-size:10pt;"><%=msgSyncFailed%></p>
						</td>
					</tr>	
					<tr>
						<td class="inputField">
							<table>
			<tr>
				<th><%=UINavigatorUtil.getI18nString("emxVPLMSynchro.Failed.Name", "emxVPLMSynchroStringResource", request.getHeader("Accept-Language"))%></th>
				<th><%=UINavigatorUtil.getI18nString("emxVPLMSynchro.Failed.Message", "emxVPLMSynchroStringResource", request.getHeader("Accept-Language"))%></th>
			</tr>
								<%
								if(list.size() == 3){%>
			<tr class="even">
				<td><a href="JavaScript:onLink('emxTree.jsp?objectId=<%=(String)list.get(0)%>')"><%=(String)list.get(1)%></a></td>
				<td class="field"><%=(String)list.get(2)%></td>
			</tr>
								<%}else{%>
			<tr class="even">
				<td class="field">&nbsp;</td>
				<td class="field"><%=msgString%></td>
			</tr>
								<%}%>
							</table>
						</td>
					</tr>
				</table>
			<%}%>
		</div>
		
		<div id="divPageFoot">
			<table>
				<tr>
					<td class="functions"></td>
					<td class="buttons">
						<table>
							<tr>
								<td><a name="cancelButton" id="cancelButtonId" href="javascript:doCancel('<%=XSSUtil.encodeForJavaScript(context, targetLocation)%>')"><img src="images/buttonDialogCancel.gif" border="0" alt="<emxUtil:i18n localize="i18nId">emxFramework.Common.Close</emxUtil:i18n>"></a></td>
								<td><a name="cancelLabel" id="cancelLabelId" href="javascript:doCancel('<%=XSSUtil.encodeForJavaScript(context, targetLocation)%>')" class="button"><emxUtil:i18n localize="i18nId">emxFramework.Common.Close</emxUtil:i18n></a></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>     		
		</div>
    
	</body>
        
</html>
