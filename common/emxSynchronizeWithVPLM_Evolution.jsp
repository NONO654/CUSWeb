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
    	</script>
	</head>

	<%
	String header = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.InputHeader", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
	String targetLocation = emxGetParameter(request, "targetLocation");
	%>
	
	<body onload="turnOffProgress();">

    <%
	String modelSize  			= "0";
	String prodLineSize  		= "0";
	
	String CfgFeatSize      	= "0";
	String ProdConfSize      	= "0";
	
	String LINFeatSize  		= "0";
	
	String ManufPlanSize		= "0";
		
	String partSize  			= "0";
	String incRuleSize 			= "0";
	String incManufRuleSize		= "0";
	
	String buildSynchro  		= "false";
	String syncVersion 			= "evolution";
    String modelPublished 		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.ModelPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    String prodLinePublished 	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.ProdLinePublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    
    String partPublished 		= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.PartPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    String incRulePublished 	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.IncRulePublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    
    String CfgFeatPublished 	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.CfgFeatPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    String ProdConfPublished 	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.ProdConfPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    
    String ManufPlanPublished    = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.ManufPlanPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    String incManufRulePublished = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.IncManufRulePublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    
    String LINpub	= com.matrixone.jsystem.util.Sys.getEnv("LIN_UNDER_PLATFORM");
    String LINFeatPublished 	= UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.LINFeatPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
    
	List MsgVector 			= null;
	int    VPMsize 				= 0;
			
			try{
        // Get the object ID
        String objectID	= emxGetParameter(request, "objectId");
		
		// Get the kind of synchro wanted
		String EvoStatus  			= request.getParameter("chkEvo");
		String VariantStatus    	= request.getParameter("chkVariant");
		
		String ProdRevStatus  		= request.getParameter("chkProdRev");
		String BuildStatus  		= request.getParameter("chkBuild");
		
		String DiversityStatus		= request.getParameter("chkDiv");
		String ProdConfStatus		= request.getParameter("chkPC");
		String LINStatus  			= request.getParameter("chkLIN");
		
		String ManufPlanStatus		= request.getParameter("chkManufPlan");

				if(EvoStatus != null){syncVersion += "_Evo";}
				if(VariantStatus != null){syncVersion += "_Variant";}
		
		//Evolution axis
				if(ProdRevStatus != null){syncVersion += "_ProdRev";}
				if(BuildStatus != null){syncVersion += "_Build";}
				if(ManufPlanStatus != null){syncVersion += "_ManufPlan";}
		
		//Variant axis
				if(DiversityStatus != null){syncVersion += "_Diversity";}
				if(ProdConfStatus != null){syncVersion += "_Diversity_ProdConf";} // as Diversity is checked but disabled
				if(LINStatus != null){syncVersion += "_ProdRev_LIN";} // as ProdRev is checked but disabled
		
		// Create the JPO arguments
        Hashtable argTable = new Hashtable();
        argTable.put("ROOTID", objectID);
        argTable.put("SYNCVERSION", syncVersion);
				String[] args = JPO.packArgs(argTable);
        
        // Invoke the JPO
        Map matrixObjIDvplmObjIDMap = (Map)JPO.invoke(context, "VPLMIntegSyncWithVPLM", null, "execute", args, Map.class);
				if(matrixObjIDvplmObjIDMap!=null && matrixObjIDvplmObjIDMap.size()>0){
            String operationStatus = (String)matrixObjIDvplmObjIDMap.get(VPLMIntegrationConstants.MAPKEY_OPERATION_STATUS);
					if(operationStatus.equals("false")){
                String errMessage = (String)matrixObjIDvplmObjIDMap.get(VPLMIntegrationConstants.MAPKEY_ERROR_MESSAGE);
                
                //en attente correction RI
                //String errPLMID = (String)matrixObjIDvplmObjIDMap.get("ERROR_PLMID");
                //String errConcat += " on PLMID : ";
                //errConcat +=  errPLMID;
                //Exception e = new Exception(errConcat);
                
                Exception e = new Exception(errMessage);
                throw(e);
            }
            //Reached here means operation status is true, so remove this element from the table
            matrixObjIDvplmObjIDMap.remove(VPLMIntegrationConstants.MAPKEY_OPERATION_STATUS);

			String msgString = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.PublishSucceeded", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language")) + "<br>";
            
			// Write number of objects published
			modelSize  		 = (String)matrixObjIDvplmObjIDMap.get("modelSize");
			prodLineSize  	 = (String)matrixObjIDvplmObjIDMap.get("prodLineSize");
			CfgFeatSize	     = (String)matrixObjIDvplmObjIDMap.get("CfgFeatSize");
			ProdConfSize  	 = (String)matrixObjIDvplmObjIDMap.get("ProdConfSize");
			LINFeatSize  	 = (String)matrixObjIDvplmObjIDMap.get("LINFeatSize");
			partSize  		 = (String)matrixObjIDvplmObjIDMap.get("partSize");
			ManufPlanSize    = (String)matrixObjIDvplmObjIDMap.get("manufPlanSize");
			incRuleSize		 = (String)matrixObjIDvplmObjIDMap.get("incRuleSize");
			incManufRuleSize = (String)matrixObjIDvplmObjIDMap.get("incManufRuleSize");
			
				if(modelSize == null){modelSize = "0";}
				if(prodLineSize == null){prodLineSize = "0";}
				if(CfgFeatSize  == null){CfgFeatSize = "0";}
				if(ProdConfSize == null){ProdConfSize = "0";}
				if(LINFeatSize == null){LINFeatSize = "0";}
				if(partSize == null){partSize = "0";}
				if(ManufPlanSize == null){ManufPlanSize = "0";}
				if(incRuleSize == null){incRuleSize = "0";}
				if(incManufRuleSize == null){incManufRuleSize = "0";}

			buildSynchro  	= (String)matrixObjIDvplmObjIDMap.get("buildSynchro");
				if(buildSynchro.equalsIgnoreCase("true")){
				buildSynchro = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.BuildPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));
				}else{
				buildSynchro = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.NoBuildPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));			
			}
			
			// Get message if there is one
			String tmpMessage = (String)matrixObjIDvplmObjIDMap.get("message");
				if(tmpMessage != null){msgString = tmpMessage;}
    %>
				<table>
			    <tr>
						<td class="heading1">
							<p style="text-align:center; color:green; font-size:10pt;"><%=msgString%></p>
						</td>
			        </tr>
			        <tr>
						<td class="inputField">
							<p><%=prodLineSize%> <%=prodLinePublished%></p>
							<p><%=modelSize%> <%=modelPublished%></p>
							<p><%=buildSynchro%></p>
							<p><%=ManufPlanSize%> <%=ManufPlanPublished%></p>
							<p><%=CfgFeatSize%> <%=CfgFeatPublished%></p>
							<p><%=ProdConfSize%> <%=ProdConfPublished%></p>
							<%if((LINpub != null) && (LINpub.startsWith("ON"))){%>
								<p><%=LINFeatSize%> <%=LINFeatPublished%></p>
								<p><%=partSize%> <%=partPublished%></p>
							<%}%>
							<p><%=incRuleSize%> <%=incRulePublished%></p>
							<p><%=incManufRuleSize%> <%=incManufRulePublished%></p>
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
	 <%
			}
        }catch(Exception exception){
		String msgSyncFailed = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.PublicationFailed", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language")) ;
        String msgString = exception.getMessage().replaceAll("'","");
		buildSynchro = UINavigatorUtil.getI18nString("emxVPLMSynchroCfg.Info.NoBuildPublished", "emxVPLMSynchroCfgStringResource", request.getHeader("Accept-Language"));			    
        
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
									<td><a href="javascript:onLink('emxTree.jsp?objectId=<%=(String)list.get(0)%>')"><%=(String)list.get(1)%></a></td>
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
