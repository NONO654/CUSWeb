<!-- 
@quickreview X32 19:06:20 : Old Reporter removal Modification
@quickreview E25 19:01:17 [Modifications for New message Specifications under variable].
@quickreview E25 18:12:11 [Modifications for New message Specifications under variable].
@quickreview E25 17:08:16 [Modifications for integration of new reporter class].
 -->
<%-- @quickreview SBM1 17:09:25 : IR-550969-3DEXPERIENCER2018x Fix to prevent XSS attacks --%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@page	import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationReporter"%>
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
	    </script>
    </head>
    
    <%
    String targetLocation = emxGetParameter(request, "targetLocation");
    %>

    <body onload="turnOffProgress();">
    <%
	String prodSize  			= "0";
	String logicalFeatSize  	= "0";
	String partSize  			= "0";
	String prodConfSize 		= "0";
	String syncVersion 			= "product";
    String prodPublished 		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.ProdPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    String logicalFeatPublished = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.LogicalFeatPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    String partPublished 		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.PartPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
	List MsgVector 			= null;
	int    VPMsize 				= 0;
		
		try{
        // Get the object ID
        String partID		= emxGetParameter(request, "objectId");
        
        // Create the JPO arguments
        Hashtable argTable = new Hashtable();
        argTable.put("ROOTID", partID);
        argTable.put("SYNCVERSION", syncVersion);
        argTable.put(VPLMIntegrationReporter.DETAILED_REPORT,"true");
		String[] args = JPO.packArgs(argTable);
        
        // Invoke the JPO
        Map matrixObjIDvplmObjIDMap = (Map)JPO.invoke(context, "VPLMIntegSyncWithVPLM", null, "execute", args, Map.class);
		Map<String,Map<String, List<String>>> resultsMap=null;
		Map<String, List<String>> syncMessages=null;
		List<String> errorMessage=null;	
		String msgString="";
		
		//List msgVector=null;
			if(matrixObjIDvplmObjIDMap!=null && matrixObjIDvplmObjIDMap.size()>0){
					//resultsMap=syncReport.collabReporter.getDetailedMessageReport(context);
					syncMessages= (Map<String, List<String>>)matrixObjIDvplmObjIDMap.get(partID);
					errorMessage = syncMessages.get(VPLMIntegrationReporter.ERROR_MESSAGES);
					MsgVector= syncMessages.get(VPLMIntegrationReporter.DETAILED_REPORT);
					ArrayList<String> collabStatus =(ArrayList) syncMessages.get(VPLMIntegrationReporter.Collab_Status);
					if(errorMessage.isEmpty() || errorMessage == null )
					{
						 msgString=collabStatus.get(1);
					//	msgString = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.PublishSucceeded", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language")) + "<br>";
					}
					else{
						String throwerrorMessage="";	
						for(String error:errorMessage)
		    			{
							throwerrorMessage=throwerrorMessage.concat(error);
		    			}
						Exception e = new Exception(throwerrorMessage);
		                throw(e);
					}
					
				
				if(prodSize == null){prodSize = "0";}
				if(logicalFeatSize == null){logicalFeatSize = "0";}
				if(partSize == null){partSize = "0";}
    
    %>
		  	
				<table>
			    <tr>
						<td class="heading1">
							<p style="text-align:center; color:green; font-size:10pt;"><%=msgString%></p>
						</td>
			        </tr>
			        <tr>
						<td class="inputField"><%
								List<String> shortmsgList= syncMessages.get(VPLMIntegrationReporter.SHORT_REPORT);
								if(shortmsgList.size() > 0)
								{
								for(int i=0;i<shortmsgList.size();i++){
			
									%><p><%=shortmsgList.get(i)%></p><%
									} 
								}
							%>
			    </td>
			    </tr>
			</table>
			  	
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
		  	<%
        }
		}
		catch(Exception exception){
		String msgSyncFailed = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.PublicationFailed", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language")) ;
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
	</body>
        
</html>
