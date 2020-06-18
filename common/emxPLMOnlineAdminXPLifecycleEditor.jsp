<html>
<head>

<!--
//@fullReview  ZUR 10/04/22 HL XP Params	
//@quickReview ZUR 10/05/28 HL XP Params
//@quickReview ZUR 10/06/01 HL XP Params
//@fullReview ZUR 10/07/02 HL XP Params V6R2012
//@quickReview ZUR 10/09/22 Updates the Lifecycle proposed CheckList regarding the Object Type
//@quickReview ZUR 10/10/22 Modifications to take into account the Next Generation UI V6R2012
//@quickReview ZUR 10/11/30 Integrating "addTransparentLoadingInSession" while deploying parameters
//@quickReview ZUR 11/01/27 - Integrating "All Parameters" in DB HL V6R2012x 
//@quickReview ZUR 11/06/08 - IR-113823V6R2012x - Hide FL objects in the Consider Child types menu
//@fullReview ZUR 11/12/23 HL Lifecycle Customization
//@quickReview ZUR 12/12/06 - IR-204387V6R2014
//@quickReview ZUR 13/02/01 - IR-215622V6R2014
//@fullReview ZUR 13/04/18 - V6R2014x New Typing HL Migration
//@quickReview ZUR 13/11/12 - IR-265128V6R2014x and IR-267997V6R2014x
-->
        
		<link rel=stylesheet type="text/css" href="styles/emxUIDOMLayout.css">
		<link rel=stylesheet type="text/css" href="styles/emxUIDefault.css">
		<link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css"> 
		<link rel=stylesheet type="text/css" href="styles/emxUIParamOnline.css"> 
		
		<link rel="stylesheet" href="styles/emxPLMOnlineXPParamLCDiv.css"></link>
		<link rel="stylesheet" href="styles/emxPLMOnlineXPParamLCEditor.css"></link>
        
		<%@ page import="com.dassault_systemes.vplmposadminservices.HtmlCatalogHandler" %> 
		<%@ page import="java.util.*"%>  
		<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.PreferencesUtil" %>
		<%@ page import ="com.matrixone.vplm.FreezeServerParamsSMB.FreezeServerParamsSMB"%>
		<%@ page import ="com.matrixone.vplm.TeamAttributeCustomize.TeamAttributeCustomize"%>
		<%@ page import ="com.matrixone.vplm.TeamAttributeCustomize.AttributeProperties"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.LifecycleCustoHandler"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.StateCustoExchange"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.TransitionCustoExchange"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.PolicyCustoDescription"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.RuleDescription"%>
		<%@ page import ="com.matrixone.vplm.LifecycleTopology.TypeCustoDescription"%>
		<%@ page import ="com.matrixone.vplm.parameterizationUtilities.NLSUtilities.ParameterizationNLSCatalog"%>
						
			
		<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
		<script src="scripts/expand.js" type="text/javascript"></script> 
		<script src="scripts/emxUIAdminConsoleUtil.js" type="text/javascript"></script>		
		<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
		
		<%@include file = "../common/emxNavigatorInclude.inc"%>
		<%@include file = "../emxTagLibInclude.inc"%>		
		
		<script type="text/javascript" src="scripts/jquery.min-xparam.js"></script>
		<script type="text/javascript" src="scripts/jquery-ui.min-xparam.js"></script>
		<script type="text/javascript" src="scripts/jquery.jsPlumb-xparam.js"></script>
		
				
		<%	 
		 Locale currentLocale = request.getLocale();
		 //Context ctx = Framework.getFrameContext(session);
				
		 ParameterizationNLSCatalog myNLS = new ParameterizationNLSCatalog(context, currentLocale, "myMenu");
		
		 String Deploysuccess 	= myNLS.getMessage("Deploysuccess");
		 String Deployfail 		= myNLS.getMessage("Deployfail");
		 String Dataaccess 		= myNLS.getMessage("Dataaccess");
		 String Deploycmd 		= myNLS.getMessage("Deploycmd");
		 String Resetcmd 		= myNLS.getMessage("Resetcmd");
		 String ResetTitle 		= myNLS.getMessage("ResetTitle");	 
		 String NonAppropriateContext	=myNLS.getMessage("NonAppropriateContext");
		 String NonAppropriateSolution	=myNLS.getMessage("NonAppropriateSolution");
		 
		 String Addlabel 				= myNLS.getMessage("Add");		 
		 String DeployTitle				= myNLS.getMessage("DeployTitle");	 
		 String Restartmessage 			= myNLS.getMessage("Restartmessage");
		 String copyCATNlsmsg			= myNLS.getMessage("copyCATNlsmsg"); 
				 
			 
		 String newStateNamemsg 		= myNLS.getMessage("newStateNamemsg");
		 String newSignatureNamemsg 	= myNLS.getMessage("newSignatureNamemsg");
		 String msgDeleteConfirm 		= myNLS.getMessage("msgDeleteConfirm");
		 String msgRestoreConfirm 		= myNLS.getMessage("msgRestoreConfirm");
		 String msgCurrtransitionName  	= myNLS.getMessage("msgCurrtransitionName");
		 String selectItemLabel 		= myNLS.getMessage("selectItemLabel");
		 String removeStateLabel 		= myNLS.getMessage("removeStateLabel");
		 String addStateLabel 			= myNLS.getMessage("addStateLabel");
		 String addStateButton 			= myNLS.getMessage("addStateButton");
		 String tooltip1 				= myNLS.getMessage("LCtooltip");
		 String tooltip2 				= myNLS.getMessage("LCtooltipmore");		 		
		 String transitionNotAllowed 	= myNLS.getMessage("transitionNotAllowed");
		 String doubleTransition 		= myNLS.getMessage("doubleTransition");
		 String forbiddenTransition 	= myNLS.getMessage("forbiddenTransition");
		 String cyclicTransition 		= myNLS.getMessage("cyclicTransition");
		 String criticalConnection		= myNLS.getMessage("criticalConnection");
		 String stateNameAlreadyUsed	= myNLS.getMessage("stateNameAlreadyUsed");
		 String topologyBoxTitle 		= myNLS.getMessage("topologyBoxTitle");
		 String controlBoxTitle 		= myNLS.getMessage("controlBoxTitle");	 
		 String selectaTransisionmsg 	= myNLS.getMessage("selectaTransisionmsg");		 
		 String singletonStatemsg		= myNLS.getMessage("singletonStatemsg");
		 String criticalStatemsg 		= myNLS.getMessage("criticalStatemsg");		 
		 String addCheckLabel			= myNLS.getMessage("addCheckLabel");		 
		 String selectaStatemsg 		= myNLS.getMessage("selectaStatemsg");
		 String SpecialCharactersMessage= myNLS.getMessage("SpecialCharactersMessage");	
		 String confirmDeleteTrans		= myNLS.getMessage("confirmDeleteTrans");
		 String blankCharactersMessage	= myNLS.getMessage("blankCharactersMessage");
		    
		 //LC Checks		 
		// String ApplicativeTypeLabel 	= myNLS.getMessage("ApplicativeTypeLabel");
		 String FromStatusLabel 		= myNLS.getMessage("FromStatusLabel");
		 String ToStatusLabel 			= myNLS.getMessage("ToStatusLabel");
		 String AdditionalInfoTitle 	= myNLS.getMessage("AdditionalInfoTitle");
		 String DataTypeLabel 			= myNLS.getMessage("DataTypeLabel");
		 String Rulelabel 				= myNLS.getMessage("RuleLabel");
		 String CurrentSetCheckslabel 	= myNLS.getMessage("CurrentSetChecks");
		 String RulesTableToolTip 		= DataTypeLabel +" - "+FromStatusLabel+" - "+ToStatusLabel+" - "+Rulelabel+" - "+AdditionalInfoTitle;
		 
		 String FrozenLine				= myNLS.getMessage("FrozenLine");
		 
		 String exisitngBOmsg1 			= myNLS.getMessage("exisitngBOmsgPart1");//"Existing Business Objects in the DB are currently in the state(s) ";
		 String exisitngBOmsg2 			= myNLS.getMessage("exisitngBOmsgPart2");//"If you still want to proceed, click on OK, (but those Objects will be inaccessible), "; 
		 String exisitngBOmsg3			= myNLS.getMessage("exisitngBOmsgPart3");//"Otherwise click on cancel to stop the deploy process and do the necessary";
		 
		 String deployLaunchFailure 	= "Deploy Launch has failed ! it's most probably a connection timeout, please logout and reconnect.";
		 		 
		 String ConsiderDisciplineLabel = myNLS.getMessage("ConsiderDisciplineKeyword");		 
		 String forAttributesLabel 		= myNLS.getMessage("forAttributesLabel");
		 String NotYetDeployedParameter = myNLS.getMessage("NotYetDeployedParameter");
		 
		 String CommonPartLabel 			= myNLS.getMessage("CommonPartLabel");
		 	 
		 String AllStringNLS 			= myNLS.getMessage("AllStringNLS");
			 
		 String RemoveLine				= myNLS.getMessage("RemoveLine");
		 String DeployedParameter 		= myNLS.getMessage("DeployedParameter");	
		 String SelectAttributemessage	= myNLS.getMessage("SelectAttributemessage");
		 String Rulealreadysetmessage 	= myNLS.getMessage("Rulealreadysetmessage");

		 String DeployedTitle 			= RemoveLine+" ("+DeployedParameter+")";
		 String NotYetDeployedTitle 	= RemoveLine+" ("+NotYetDeployedParameter+")";
		 
		 String ConsiderChildTypesLabel 	= myNLS.getMessage("ConsiderChildTypesLabel")+":";
		 //String ConsiderDisciplinesLabel	= myNLS.getMessage("ConsiderDisciplinesLabel")+":";		 
		 
		 String lifecyleChecksNotSupported =  myNLS.getMessage("lifecyleChecksNotSupported");
		 
		 String currentcontext = context.getRole();
		
		 String admincontext="VPLMAdmin";
		 String displayhidediv ="block";		 
		 
		 String displayhidecontrol="none";			
		 String CurrentUISolution="";
		 
		 PreferencesUtil utilpref = new PreferencesUtil();
		 CurrentUISolution = utilpref.getUserPreferredUISolution(context);		
			
		 if (CurrentUISolution.equalsIgnoreCase("TEAM")==false)
			 NonAppropriateContext = NonAppropriateSolution;
		 
		 if ( ( currentcontext.indexOf(admincontext) >=0) && ( CurrentUISolution.equalsIgnoreCase("TEAM")) )
		 {
			displayhidediv ="none";
			displayhidecontrol="block";
		 }	
		 
		 String currentFamily = emxGetParameter(request,"policyName");
		 String currentAction = emxGetParameter(request,"LCAction");	 		 		 
		 
		 LifecycleCustoHandler myLifeCycleHandler = new LifecycleCustoHandler(context);
		 
		 String currentPolicy ="";	
		 currentPolicy = myLifeCycleHandler.getPolicyofFamily(currentFamily);
			 				
		 String fStatus = "";
			
		//Get States and Default States			
		myLifeCycleHandler.setContext(context);	
		
		StateCustoExchange[] custoStates = null;
		TransitionCustoExchange[] currentTransitions = null;
		
		try{
			custoStates =	myLifeCycleHandler.getStates(context,currentPolicy, currentLocale);
		}
		catch (Exception ex){
			//Do nothin
		  }
		finally {
			currentTransitions = myLifeCycleHandler.getTransitions(context,currentPolicy);
		}
		
		StateCustoExchange[] custoDefaultStates =	myLifeCycleHandler.getDefaultStates(currentPolicy,currentLocale);
			
		
		//Getting default Transitions
		TransitionCustoExchange[] defaultTransitions = myLifeCycleHandler.getDefaultTransitions(currentPolicy);
				
		if ("LCReset".equalsIgnoreCase(currentAction))
		{		
			currentTransitions = new TransitionCustoExchange[defaultTransitions.length];
					
			for (int i=0; i<defaultTransitions.length; i++)
				currentTransitions[i] = defaultTransitions[i];	
			
			//IR-265128V6R2014x
			custoStates = new StateCustoExchange[custoDefaultStates.length];
			
			for (int i=0; i<custoDefaultStates.length; i++)
				custoStates[i] = custoDefaultStates[i];	
		}	
					
		String handledPolicy = custoStates[0].getPolicy();		
		//Getting policy Description
		PolicyCustoDescription policyDesc = myLifeCycleHandler.getPolicyDescription(handledPolicy);
			
		String handledTypesforPolicy = policyDesc.getHandledObjTypeChecks();
		
		ParameterizationNLSCatalog iNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, policyDesc.getPolicyNLSFileName());
		String iPolicyUI = iNLSCatalog.getMessage(policyDesc.getPolicyNLSKey());
		
		String addRowStatus="style=\"cursor:pointer\" onclick=\"javascript:AddRow()\"";
		 
		 %>
		
		<script type="text/javascript">
		
		  
		// To hold temporarily the overlay label while mouse hovers over the connection overlay 
		var overlayLabel = "";
		
		var transitionNames 		= new Array();		
		var graphStatesArray 		= new Array();
		var graphStatesDefaultArray = new Array();
		var transitionInitArray 	= new Array();
		var transitionForbiddenArray= new Array();
		var transitionDefaultArray  = new Array();
		var listofRulesArray 		= new Array();
		var typeDescriptorArray 	= new Array();	
		
		var currPolicyDescriptor;
		var timer;
		var timerconn;		
	
		var commonEndpoint;
		
		var currHandledPolicy="<%=currentPolicy%>";
		var currAction ="<%=currentAction%>";
		
		var sourceSelectedState = "INIT";
		var targetSelectedState = "INIT";				

		var nbConnections = 0;	
		var stubCompatibilityArray = [[1,40],[2,32],[3,23],[4,15]];   
			
		//alert(currHandledPolicy);	
				
		var SupportedTypes = new Array();						
		var AlreadyUsedChecks = new Array();
		
		var xmlreqs = new Array();			

		//Struct Factory
		function structBuilder(names) 
		{
			var names = names.split(',');
			var count = names.length;
			
			function constructor() 
			{
				for (var i = 0; i < count; i++)
					this[names[i]] = arguments[i];
			}
			return constructor;
		}
		
		// State Node Struct Definition
		var stateNode = structBuilder("id,userStateName,divID,isEnabled,isCritical,initiallyEnabled,iOrder,ee,eo,en,es,oCount");
		var transitionStruct = structBuilder("sourceState,targetState,Name,isCritical,isDeployed");
		
		var policyDescriptor = structBuilder("policyID,areTransitionsEditable,areStatesRenamable,appType");		
		var typeDescriptor = structBuilder("typeID,typeNLS,listofRulesID,typeENOID,supportAttributes,listofAttributes,typeCategory");//listofDisciplines
		var ruleDescriptor = structBuilder("ruleID,ruleNLS,ruleNLSTooltip");
					
		
		function handleNamingStyleIssue(inputname)
		{			
			if (inputname.length >11)
				return inputname.substr(0,8)+"...";		
			else
				return inputname;
		}
				
		function addStateBox(_stateSysID,_stateUserID,_isEnabled,_isCritical,_iOrder,icounter)
		{
			var currDivID = "window"+icounter;		
			var currTableID = "table_"+currDivID;
			
			document.write('<div class="window" id="'+currDivID+'">');			
			document.write('<table id="'+currTableID+'" width="100%" height="100%" cellspacing="0" cellpadding="0" title="'+_stateUserID+'">');
			document.write('</table>');				
			document.write('</div>');	
						
			//1.3.3 > : 
			//jsPlumb.draggable(currDivID);	
			
			var newRow = document.getElementById(currTableID).insertRow(-1);
        //	newRow.style.backgroundColor= "white"; 
        	newRow.style.width="100%";
        	newRow.style.height="90%";
        	newRow.onclick = function() { handleStateOnClick(currDivID) };        	

        	var processedName = handleNamingStyleIssue(_stateUserID);        	
        	
        	newCell = newRow.insertCell(0);
        	newCell.style.width="100%";
        	newCell.colSpan="2";
        	newCell.align = "center";        	
           	newCell.innerHTML=processedName;
        	newCell.value=_stateUserID;       	
        	
        	newRow = document.getElementById(currTableID).insertRow(-1);        	
        	newRow.style.height="5%";//"0.3ems";
        	
        	newCell = newRow.insertCell(-1);
        	newCell.style.width="95%";
        	newCell.onclick = function() { handleStateOnClick(currDivID) };
    
        	newCell = newRow.insertCell(-1);
        	newCell.style.width="5%";        	
        	newCell.align="right";
        	newCell.style.verticalAlign="sub";
        	newCell.style.padding="0";
        	           
        	
            if ( (_isCritical == false)&&(currPolicyDescriptor.areTransitionsEditable))            
        		newCell.innerHTML='<img title="'+"<%=removeStateLabel%>"+'" style="cursor:pointer" onclick="handleStateOnDblClick(\''+currDivID+'\')" src="images/buttonMiniDeleteParam.gif"/>';
			else
				newCell.onclick = function() { handleStateOnClick(currDivID) };	
				
				// utilDetailsTreeRemove.gif
			
			if (_isEnabled==false)
				document.getElementById(currDivID).style.visibility='hidden';
			
			graphStatesArray[icounter]=new stateNode(_stateSysID,_stateUserID,currDivID,_isEnabled,_isCritical,_isEnabled,_iOrder);
			
			//alert("Adding "+_stateSysID+":"+_stateUserID+":"+currDivID+":"+_iOrder);
			
		}
				
		function initializeDefaultStates(_stateSysID,_stateUserID,_isEnabled,_isCritical,_iOrder,icounter)
		{			
			var i_InStatesStruct = getStateInStructFromStateName(_stateSysID);
			var currDivID =  "window"+i_InStatesStruct;
								
			graphStatesDefaultArray [icounter]=new stateNode(_stateSysID,_stateUserID,currDivID,_isEnabled,_isCritical,_iOrder);			
		}
						
		function getStateInStruct(stateDivID)
		{		
			var currGraphLen = graphStatesArray.length;
			
			for ( var i =0; i< currGraphLen ; i++)	
				if ( graphStatesArray[i].divID == stateDivID)
					return i;			
		}
				
		function getStateInStructFromStateName(stateSysName)
		{		
			var currGraphLen = graphStatesArray.length;
			
			for ( var i =0; i< currGraphLen ; i++)	
				if ( graphStatesArray[i].id == stateSysName)
					return i;	
			
			return -1;
		}
						
		function addInitialTransitions(_sourceState,_targetState,_transitionName,_isCritical,_isDeployed,icounter)
		{
			transitionInitArray[icounter]=new transitionStruct(_sourceState,_targetState,_transitionName,_isCritical,_isDeployed);			
		}
		
		function addForbiddenTransitions(_sourceState,_targetState,_transitionName,icounter)
		{
			transitionForbiddenArray[icounter]=new transitionStruct(_sourceState,_targetState,_transitionName);
		}
		
		function addDefaultTransitions(_sourceState,_targetState,_transitionName,icounter)
		{
			transitionDefaultArray[icounter]=new transitionStruct(_sourceState,_targetState,_transitionName);
		}
		
		//Policy Descriptor
		currPolicyDescriptor = new policyDescriptor("<%=policyDesc.getPolicyID()%>",<%=policyDesc.areTransitionsEditable()%>,<%=policyDesc.areStatesRenamable()%>,"<%=policyDesc.getAppType()%>");
		
		function addRuletoList(_ruleID, _ruleNLS, _ruleNLSTooltip, icounter)
		{						
			listofRulesArray [icounter] = new ruleDescriptor(_ruleID,_ruleNLS,_ruleNLSTooltip);
		}		
		
		function addTypetoList(_typeID, _NLStypeID, _listofRulesID, _ENOType, _supportsAttr, _listofAttr, _typeCategory, icounter)
		{					
			if (icounter == 0)			
					typeDescriptorArray[0] = new typeDescriptor(_typeID,_NLStypeID, _listofRulesID, _ENOType,
							_supportsAttr, _listofAttr, _typeCategory);
			else 
			{
				//Sorting based on (type)NLS
				var iSwitch = icounter;				
				for ( var i = 0; i < icounter; i++) 
				{
					var j = icounter;
					if (_NLStypeID < typeDescriptorArray[i].typeNLS)
					{						
						iSwitch = i;
						while (j > i) {
							typeDescriptorArray[j] = typeDescriptorArray[j - 1];
							j--;
						}
						break;
					}					
				}
				typeDescriptorArray[iSwitch] = new typeDescriptor(_typeID,_NLStypeID, 
						_listofRulesID, _ENOType,
						_supportsAttr, _listofAttr, 
						_typeCategory);
			}

		}
					
	
		</script>
		
</head>

	
<body>

<script type="text/javascript">
addTransparentLoadingInSession("none","LoadingDiv");
</script>

	<div id="policyTitleDiv">
	<table id="policytitleContainer" width="100%" height="100%">
	<tr class="paramLCHeader"><td class="paramLCCell"><%=iPolicyUI%></td></tr>	
	</table>	  	
	</div>

    <div id="controlBoxDiv" style="overflow-y:auto; overflow-x:auto">
	    
	    	<table id="ControlBoxTable">
	    	
	    	<tr> 
	    	<td colspan=4 width="60%"><b><i><font color="#0C3A66"><%=topologyBoxTitle%></font></i></b></td>
			<td align="right" width="50%" title="<%=tooltip1+"\n"+tooltip2%>"><img src="images/iconParameterizationHelp.gif"/></td>	
			</tr>	    
	    	    
	    	<tr> 
	    	  <td class="LCOperCell"><%=addStateLabel%></td>
	    	  <td class="LCOperCell">
	    	  	<select id="ListStatetoRestore" style="width:220px;"> 
	    	  		<option value="FirstItem"><%=selectItemLabel%></option>	
				</select>	
			  </td>
			  <td width="35%" colspan=2></td> 
			  <td width="50%" align="right">
				<img id="buttonaddState" src="images/buttonDialogAddGray.gif" style="cursor:pointer" onclick=javascript:RestoreState() title ="<%=addStateButton%>">
			  </td>
			</tr>
			    	
	    	<tr> 
	    	<td colspan="5"><b><i><font color="#0C3A66"><%=controlBoxTitle%></font></i></b></td>
			</tr>	    
			  
		    <tr> 
			  <td class="LCOperCell"><%=DataTypeLabel%>:</td>			
			  <td width="30%">
			  	<select onchange="javascript:updateSelectablesForType()"  id="ObjectTypeId" style="width:220px;">			  	
			  	</select>			
			  </td> 
			  <td width="10%" align="justify"><%=Rulelabel%>:</td>
			  <td width="30%" class="LCOperCell" >
			  <select id="ChosenCheck" style="width:400px;" onchange="javascript:UpdateRulesComplementary()" <%=fStatus%>>
			  </select>
			  </td>
			  <td width="50%" align="right"><img id="buttonadd" src="images/buttonDialogAddGray.gif" <%=addRowStatus %> title ="<%=Addlabel%>"></td>
			</tr>	 

			<tr>    	  			  
  		   		<td class="LCOperCell"></td>
  		   		<td width="30%"></td>  		   		
  		   		<td width="10%">
  		   			<label id="labelSelect" style="visibility:hidden" ><%=ConsiderChildTypesLabel%></label>
  		   		</td>
				<td width="30%" id="ListContainer">	
					<select style="visibility:hidden; width:100px;"  id="selectedValuesForChecks" title="" onchange="javascript:updateDiscipline('selectedValuesForChecks','selectedDisciplinesForChecks')">
					<option selected>EAU</option>
  		   			<option>TERRE</option>
  		   			<option>AIR</option>
  		   		</select>		
  		   		</td>	   		
  		   		<td></td>
  		   	</tr>		
	    	
	    	</table>
	    	
	    </div>	       

	<%	        	
    //Retrieving ... 
	
	String policyName = "";
	String stateSysName ="", stateUserName ="";
	String isEnabled="true", isCritical="false";
	int visuorder;
			
	for (int i=0; i<custoStates.length; i++)
	{    	
		policyName = custoStates[i].getPolicy();
		stateSysName = custoStates[i].getStateSysName();
		stateUserName = custoStates[i].getStateUserName();
		isEnabled = String.valueOf(custoStates[i].isEnabled());
		isCritical = String.valueOf(custoStates[i].isCritical());
		visuorder = custoStates[i].getVisuOrder();
		%>
		<script type="text/javascript">   
		addStateBox("<%=stateSysName%>","<%=stateUserName%>",<%=isEnabled%>,<%=isCritical%>,<%=visuorder%>,<%=i%>);
		</script>
		<%
	}
	
	for (int i=0; i<custoDefaultStates.length; i++)
	{   
		policyName = custoDefaultStates[i].getPolicy();
		stateSysName = custoDefaultStates[i].getStateSysName();
		stateUserName = custoDefaultStates[i].getStateUserName();
		isEnabled = String.valueOf(custoDefaultStates[i].isEnabled());
		isCritical = String.valueOf(custoDefaultStates[i].isCritical());
		visuorder = custoDefaultStates[i].getVisuOrder();
		%>
		<script type="text/javascript">   
		initializeDefaultStates("<%=stateSysName%>","<%=stateUserName%>",<%=isEnabled%>,<%=isCritical%>,<%=visuorder%>,<%=i%>);
		</script>
		<%
	
	}		
	
	String sourceState="";
	String targetState="";
	String transitionName="";
	String isDeployed="true";
	
	for (int i=0; i<currentTransitions.length; i++)
	{ 
		sourceState = currentTransitions[i].getSourceStateName();
		targetState = currentTransitions[i].getTargetStateName();
		transitionName = currentTransitions[i].getTransitionName(); 
		isCritical =  String.valueOf(currentTransitions[i].isCritical());	
		isDeployed =  String.valueOf(currentTransitions[i].isDeployed());
		%>
		<script type="text/javascript">		
		addInitialTransitions("<%=sourceState%>","<%=targetState%>","<%=transitionName%>",<%=isCritical%>,<%=isDeployed%>,<%=i%>);
		</script>		
		<%
		
	}
				
	//Getting forbidden Transitions
	TransitionCustoExchange[] forbiddenTransitions = myLifeCycleHandler.getForbiddenTransitions(currentPolicy);
	
	for (int i=0; i<forbiddenTransitions.length; i++)
	{ 
		sourceState = forbiddenTransitions[i].getSourceStateName();
		targetState = forbiddenTransitions[i].getTargetStateName();
		transitionName = forbiddenTransitions[i].getTransitionName();
		
		%>
		<script type="text/javascript">   
		addForbiddenTransitions("<%=sourceState%>","<%=targetState%>","<%=transitionName%>",<%=i%>);
		</script>		
		<%
		
	}
		
	//default Transitions	
	for (int i=0; i<defaultTransitions.length; i++)
	{ 
		sourceState = defaultTransitions[i].getSourceStateName();
		targetState = defaultTransitions[i].getTargetStateName();
		transitionName = defaultTransitions[i].getTransitionName();		
		%>
		<script type="text/javascript">   
		addDefaultTransitions("<%=sourceState%>","<%=targetState%>","<%=transitionName%>",<%=i%>);
		</script>		
		<%
		
	}	
	
	%>
		
	
	<script type="text/javascript"> 
										
	var GraphLen = graphStatesArray.length;
	var j=1;
	var k=1;			
				
	for ( var i=0; i< GraphLen ; i++)	
	{
		var curNode=graphStatesArray[i];
				
		if ( ( curNode.isEnabled == true)&&
			(curNode.isCritical == false))
		{														
			j++;			
		}
		else if (curNode.isEnabled == false)
		{
			var optk = new Option(curNode.userStateName,curNode.divID);
			document.getElementById("ListStatetoRestore").options[k]=optk;	
			document.getElementById("ListStatetoRestore").options[k].title=curNode.userStateName;
			k++;
		}
	}		
			
	function handleSourceAndTargetforLC(sourceDiv,targetDiv,connection)
	{	
		
		if (sourceSelectedState == "INIT")
		{
			highlightSelectedChoice(sourceDiv,targetDiv,connection);
		}
		else
		{			
			
			if (connection.islastclicked ==true)
			{
				//De-Selecting
				connection.setHover(false);
				connection.islastclicked=false;					
				resetSelectedTransition();
				resethighlightChecksInTable();
				connection.labelText="";
				
				var myoverlay = connection.getOverlay("label");
				myoverlay.setVisible(false);
				myoverlay.hide();			
				connection.repaint();
			}
			else
			{	
				resetSelectedTransition();					
				//Selecting
				highlightSelectedChoice(sourceDiv,targetDiv,connection);
				resetAllVisibleLabels(connection);
			}	

		}
		
		/*	document.getElementById(sourceSelectedState).style.backgroundColor ="#99CCFF";
			document.getElementById(sourceSelectedState).style.borderWidth="1px";*/
						
	}
				
	function highlightSelectedChoice(sourceDiv,targetDiv,connection)
	{
		connection.islastclicked=true;
		connection.setHover(true);
		
		sourceSelectedState=sourceDiv;
		targetSelectedState=targetDiv;

		document.getElementById(sourceDiv).style.borderColor="orange";//"#649582";
		document.getElementById(targetDiv).style.borderColor="orange";//#649582";

		var iSrc = getStateInStruct(sourceSelectedState);
		var iTrgt = getStateInStruct(targetSelectedState);		
				
		var sourceNLS=graphStatesArray[iSrc].userStateName;
		var targetNLS=graphStatesArray[iTrgt].userStateName;
		
		var sourceState=graphStatesArray[iSrc].id;
		var targetState=graphStatesArray[iTrgt].id;

		document.getElementById("buttonadd").title = "<%=addCheckLabel%> "+connection.label+" "+sourceNLS+" <%=ToStatusLabel%> "+targetNLS;
		
		highlightMatchingChecksInTable(sourceState,targetState);		
		//connection.repaint();
	}
		
	//DEMOADD	
	function highlightMatchingChecksInTable(iSourceState,iTargetState)
	{
		var rulestablesize = document.getElementById('rulestable').rows.length;
		
		for (var i=2; i<rulestablesize;i++)		
			document.getElementById('rulestable').rows[i].style.backgroundColor ="white";
			
		for (var i=2; i<rulestablesize;i++)
		{			
			var isrc  = document.getElementById('rulestable').rows[i].cells[1].value;
			var idest = document.getElementById('rulestable').rows[i].cells[2].value;
					
			if ( ( iSourceState == isrc)&&(iTargetState == idest))
				document.getElementById('rulestable').rows[i].style.backgroundColor ="#CBE5FF";
		}	
		
	}
	
	
	function resethighlightChecksInTable()
	{
		var rulestablesize = document.getElementById('rulestable').rows.length;		
		for (var i=2; i<rulestablesize;i++)		
			document.getElementById('rulestable').rows[i].style.backgroundColor ="white";
	}	
	
	function resetAllVisibleLabels()
	{		
		var listofConnections = jsPlumb.getAllConnections();	
		
		for ( var i in listofConnections) 
		{		
				for ( var j = 0; j < listofConnections[i].length; j++) 
				{
					var c = listofConnections[i][j];
					
					if (arguments.length > 0)
					{
						var connection = arguments[0];
					
						if ( !( (c.sourceId == connection.sourceId)
								&&(c.targetId == connection.targetId))) 
						{	
							c.labelText="";
														
							var myoverlay = c.getOverlay("label");
							myoverlay.setVisible(false);
							myoverlay.hide();
													
							c.repaint();
						}
					}
					else
					{
						c.labelText="";
						
						var myoverlay = c.getOverlay("label");
						myoverlay.setVisible(false);
						myoverlay.hide();
												
						c.repaint();
					}					
				}
		}
	}
	
	
	
	
	jsPlumb.bind("ready", function() {
						
		
			/*if (document.all)//IE	
			{
				jsPlumb.setRenderMode(jsPlumb.VML);//jsPlumb.CANVAS	
			}*/
		
			// chrome fix.
			document.onselectstart = function () { return false; };
			// default drag options
			jsPlumb.Defaults.DragOptions = { cursor: 'pointer', zIndex:2000 };
			// default to blue at one end and green at the other
			jsPlumb.Defaults.EndpointStyles = [{ fillStyle:'#225588' }, { fillStyle:'#558822' }];
			// blue endpoints 7 px; green endpoints 11.
			jsPlumb.Defaults.Endpoints = [ [ "Dot", {radius:7} ], [ "Dot", { radius:11 } ]];		
			// jsPlumb.Defaults.Endpoints = [ ["Image", {url:"images/buttonMinus.gif"}], ["Image", {url:"images/iconSectionCollapse.gif"}] ];
	 			
			// enable mouse events			
			//	jsPlumb.setMouseEventsEnabled(true);	>1.3.3			
			//	jsPlumb.Defaults.MouseEventsEnabled = true;			
			//	jsPlumb.setDraggable = false; // obsolete

			// this is the paint style and hover style for the connecting lines
			var connectorPaintStyle = {lineWidth:2,strokeStyle:"Black", joinstyle:"round",
					outlineColor:"#E4E4E4",
					outlineWidth:1.5
					};//9C9C91 deea18
			var connectorHoverStyle = {lineWidth:3,strokeStyle:"Orange"};//blue(9C9C91)
			
			var newObj = new Object();
			
			/*				
			var overlays = [
				[ "Arrow", { location:0.9 } ], //pourcentage définisssant la position de la fleche 
				[ "Label", { 
					location:0.1,
					
					label:function(c) { 
						return c.connection.labelText || ""; 
					},					
					
					cssClass:"aLabel"  
					//voir aLabel dans demo.css
				}] 
			];			
			*/
			
			/*
			var overlays = [
				[ "Arrow", {width:6, length:8, location:0.8 } ], //pourcentage définisssant la position de la fleche 
				[ "Label", { 
					location:0.4,	
					label:"",
	
					/*label:function(c) { 
						 return c.getLabel();// || ""; 
						//return overlayLabel;ZUR
					},
					cssClass:"aLabel",  //voir aLabel dans emxPLMOnlineXPParamLCEditor.css;
					events:{
						click:function(labelOverlay, originalEvent) {  
						  handleSignatureOnClick(labelOverlay)
						}					
						
						
					}
				}] 
			];*/
			
			/*
					
			events:{
					"click":function(label, evt) {
						alert("clicked on label for connection 1");
						}
					}*/
						
					
		   var overlays = [ 
					["Arrow", {	location:0.8, width:6 , length :8}] ,      
		            ["Label", {													   					
					cssClass:"aLabel",
					 label : function(connection) { 
						 return connection.label || "";  
        			 },
					location:0.4,
					id:"label",
					events:{
					"click":function(label, evt) {
						 handleSignatureOnClick(label);
						}
					}
				  } ]				
				];    
			

			// endpoint:"Dot",	
			// the definition of source endpoints
			var sourceEndpoint = {
				endpoint:["Dot", {radius:2}],
				paintStyle:{fillStyle:"#E6E6E6",radius:5}, //#225588
				endpointHoverStyle:{fillStyle:"LightSkyBlue"},
				isSource:true,
				maxConnections:-1,
				connector:"Flowchart",
				dragAllowedWhenFull:false,
				connectorOverlays: overlays,			
				connectorStyle:connectorPaintStyle,
				hoverPaintStyle:connectorHoverStyle,
				connectorHoverStyle:connectorHoverStyle
			};

			//	endpoint:"Dot",	
			// the definition of target endpoints
			var targetEndpoint = {
				endpoint:["Dot", {radius:5}],
				paintStyle:{fillStyle:"#E6E6E6",radius:5}, //#558822		
				endpointHoverStyle:{fillStyle:"LightSkyBlue"},
				isTarget:true,
				hoverPaintStyle:connectorHoverStyle,
				maxConnections:-1,
				//dropOptions:{hoverClass:"hover"},
				connectorOverlays: overlays
				//anchor:[ "TopCenter","RightMiddle","BottomCenter","LeftMiddle" ]
			};	
			
			var icommon = {
					cssClass:"myCssClass"
				};
			
			commonEndpoint = {
				endpoint:["Dot", {radius:7}],//5
				endpointHoverStyle:{fillStyle:"#8AB8E6"}, // color same as state box
				paintStyle:{fillStyle:"#CFCFCF", radius:5 }, // #E6E6E6
				isSource:currPolicyDescriptor.areTransitionsEditable,
				isTarget:currPolicyDescriptor.areTransitionsEditable,
				maxConnections:4,//ZUR prev -1	
				connector:[ "Flowchart", { stub:20 } ],
				//connector:[ "Bezier", { curviness:30 }, icommon ],
				//anchor:"Continuous",
				//connector:[ "StateMachine", { curviness:20 } ],				 
				connectorStyle:connectorPaintStyle,
				hoverPaintStyle:connectorHoverStyle,
				connectorHoverStyle:connectorHoverStyle,
				connectorOverlays: overlays,				
				dragAllowedWhenFull:true	 
			};
			
			var GraphLen = graphStatesArray.length;
	
			for ( var i=0; i< GraphLen ; i++)	
			{			
				var curNode=graphStatesArray[i];				
				var currDivID=graphStatesArray[i].divID;
				
				if (graphStatesArray[i].isEnabled==true)
				{	
								
					graphStatesArray[i].ee = jsPlumb.addEndpoint(currDivID, {anchor:"RightMiddle"}, commonEndpoint);				
					graphStatesArray[i].eo = jsPlumb.addEndpoint(currDivID, {anchor:"LeftMiddle"}, commonEndpoint);
					graphStatesArray[i].en = jsPlumb.addEndpoint(currDivID, {anchor:"TopCenter"}, commonEndpoint);
					graphStatesArray[i].es = jsPlumb.addEndpoint(currDivID, {anchor:"BottomCenter"}, commonEndpoint);
					graphStatesArray[i].oCount = 0;
												
					/*		
					graphStatesArray[i].es.bind("mousedown", function(endpoint,originalEvent) 
					{
						alert("mousedown");
					});*/					
					
				}
			}
		
			//init et connect
			// helper method to set mouse handlers and the labelText member on connections.
				
		
		//Redraw Critical Connection
		var redrawConnection = function(conn) 
		{				
			var i_S_recon = getStateInStruct(conn.sourceId);
			var i_T_recon = getStateInStruct(conn.targetId);
			
			//alert("conn.isCritical is "+conn.isCritical);		
			connect(graphStatesArray[i_S_recon], graphStatesArray[i_T_recon],conn.label,conn.isCritical);
		}	
			
			
		var init = function(conn,signature,criticity,inSessionConnection, sourceAnchor,targetAnchor) 
		{
					
			//conn.labelText = "to"+document.getElementById(conn.targetId).innerHTML;
					
			conn.label = signature;					
			conn.getOverlay("label").setLabel(signature);
			conn.getOverlay("label").hide();
			
			//handleStubForOverlapping();
						
			//conn.getOverlay("label").setVisible(false);			
			/*if (signature == "")
				conn.label = "to"+document.getElementById(conn.targetId).innerHTML;*/			
			//conn.labelText = "";
		
			conn.isCritical=criticity;
			conn.islastclicked=false;		
		
			conn.bind("click", function(conn, originalEvent) 
			{
			
				if (timerconn) clearTimeout(timerconn);
				timerconn = setTimeout(function() { 
					
					handleSourceAndTargetforLC(conn.sourceId,conn.targetId,conn);}, 20); 	//250
				
			});
		
		//alert("in init, the criticity is :"+conn.isCritical)
		
		if (currPolicyDescriptor.areTransitionsEditable)
		{
	
			conn.bind("dblclick", function(conn, originalEvent) 
			{
						
				clearTimeout(timerconn);
				
				if (criticity==false)
				{					
					var sourceTableid = "table_"+conn.sourceId;
					var targetTableid = "table_"+conn.targetId;	
					
					var sourceStConn = document.getElementById(sourceTableid).rows[0].cells[0].value;
					var targetStConn = document.getElementById(targetTableid).rows[0].cells[0].value;				
					if (confirm("<%=confirmDeleteTrans%> "+sourceStConn+" -> "+targetStConn+" ?"))
					{
						//delete transition						
						var i_Source = getStateInStruct(conn.sourceId);
						var i_Target = getStateInStruct(conn.targetId);
						//handling Issued related to transition deletion :
						// - deleting lifecycle checks linked to this transition					
						removeLCChecksAfterTransitionRemoval(graphStatesArray[i_Source].id,graphStatesArray[i_Target].id);
						jsPlumb.detach(conn);					
						resetSelectedTransition();					
						
						handlePostTransitionRemovalIssues(i_Source,i_Target);
						
						sourceSelectedState = "INIT";
						targetSelectedState = "INIT";
					}
			
				}
				else
				{
					//The removal of the transition is forbidden
					alert("<%=criticalConnection%>");
				}	
		
			});
		}
	
		conn.bind("mouseenter",  function() {handleSignatureOnMouseEnter(conn)} );
		conn.bind("mouseexit",  function() {handleSignatureOnMouseExit(conn)} );	
		
		var iSource = getStateInStruct(conn.sourceId);
		var iTarget = getStateInStruct(conn.targetId);
		
		var isTransitionAllowed = isNewTransitionAllowed(graphStatesArray[iSource].id, graphStatesArray[iTarget].id); 
						
		if (isTransitionAllowed!="ok")
		{
			var alertMsg = "<%=transitionNotAllowed%>"+"\n";
			
			if (isTransitionAllowed == "duplicatetransition")
				alertMsg=alertMsg+"<%=doubleTransition%>";
			else if (isTransitionAllowed == "forbiddentransition")
				alertMsg=alertMsg+"<%=forbiddenTransition%>";
			else if (isTransitionAllowed == "cyclictransition")
				alertMsg=alertMsg+"<%=cyclicTransition%>";
			
		//	conn.endpoints.length //graphStatesArray[iSource].id					
			alert(alertMsg);
			
			jsPlumb.detach(conn);
		//	conn.endpoints[1].detachFrom(conn.endpoints[0]);
		}
		else
		{
			//testing that there are no other outgoing transitions of signature "" from the source state "iSource"
						
			if (inSessionConnection==true)
			{						
				var statesconnectedtoSource = jsPlumb.getConnections({source:graphStatesArray[iSource].divID});
					
				for ( var k=0; k< statesconnectedtoSource.length ; k++)
				{														
					var labelConn =  statesconnectedtoSource[k].label;
					
					if (labelConn=="")
					{
						//generate a name, otherwise the implicit transition will be removed by M1
						var targetID = statesconnectedtoSource[k].targetId;						
						var i_target = getStateInStruct(targetID);	
						
						var auto_sign = "to"+graphStatesArray[i_target].userStateName;	
						
						statesconnectedtoSource[k].label=auto_sign;							
						statesconnectedtoSource[k].getOverlay("label").setLabel(auto_sign);//>1.3.3
					}

				}
							
			var testNeighborhood = areSourceAndTargetNeighbors(graphStatesArray[iSource], graphStatesArray[iTarget]);
			var locateTargettoSource = positionTargetToSource(graphStatesArray[iSource], graphStatesArray[iTarget]);
						
			var anchorsCompatibility = checkAnchorsCompatibility(sourceAnchor, targetAnchor, testNeighborhood,locateTargettoSource);
			
			var distFromTargetToSource = distanceFromTargetToSource(graphStatesArray[iSource], graphStatesArray[iTarget]); 
			
			var stubCheck = checkStubForOverlapping(distFromTargetToSource);
					
			if ( (!anchorsCompatibility) )
			{
				//detaching !!		
				var i_Source = getStateInStruct(conn.sourceId);
				var i_Target = getStateInStruct(conn.targetId);
				var i_Label = conn.label;
				jsPlumb.detach(conn,false);				
				//rerouting				
				connectOptimized(graphStatesArray[i_Source], graphStatesArray[i_Target],i_Label,false);			
		
			}				
			else if (!stubCheck)
			{
				//detaching !!		
				var i_Source = getStateInStruct(conn.sourceId);
				var i_Target = getStateInStruct(conn.targetId);
				var i_Label = conn.label;
				jsPlumb.detach(conn,false);	
				//rebuilding same with optimzed stub	
				connectWithOptimizedStub(graphStatesArray[i_Source], graphStatesArray[i_Target],sourceAnchor, targetAnchor,i_Label,false);	
			
			}		
			
			}
			
		}
		
		conn.repaint();
		
	};
						

	// function connect : connect two elements.  
	// calls the init function to register mouse handlers etc.
	var connect = function(sourceState,targetState,signature,criticalconn) 
	{		
		
		var sourceNode = optimizeOutgoingConnectionsLayout(sourceState,targetState);		
		var targetNode = optimizeIncomingConnectionLayout(sourceState,targetState);		
				
		var cDist = distanceFromTargetToSource(sourceState, targetState);			
		handleLiveStubForOverlapping(cDist);
	
		//var c = jsPlumb.connect({source:sourceNode,target:targetNode, overlays:overlays}); //removed after 1.3.3
		var c = jsPlumb.connect({source:sourceNode,target:targetNode});
		if (c) init(c,signature,criticalconn,false);
	};
	
	
	// function connectOptimized : connects two endpoints after in-session optimization
	var connectOptimized = function(sourceState,targetState,signature, criticalconn) 
	{				
		var sourceNode = optimizeOutgoingConnectionsLayout(sourceState,targetState);		
		var targetNode = optimizeIncomingConnectionLayout(sourceState,targetState);	
		
		var cDist = distanceFromTargetToSource(sourceState, targetState);			
		handleLiveStubForOverlapping(cDist);
				
		var c = jsPlumb.connect({source:sourceNode,target:targetNode});	
	};
	
	
	var connectWithOptimizedStub = function(sourceState,targetState, sourceAnchor, targetAnchor, signature,criticalconn) 
	{		
		var cDist = distanceFromTargetToSource(sourceState, targetState);			
		handleLiveStubForOverlapping(cDist);
		
		var isourceNode = getNodeFromAnchor(sourceAnchor,sourceState);
		var itargetNode = getNodeFromAnchor(targetAnchor,targetState);		
				
		var c = jsPlumb.connect({source:isourceNode,target:itargetNode});	
	};
		
				
			function optimizeOutgoingConnectionsLayout(iSourceNode,iTargetNode)
			{			
				var currentOutConnect = iSourceNode.oCount;
									
				if (areSourceAndTargetNeighbors(iSourceNode,iTargetNode)==true)
					return (iSourceNode.ee);
				
				iSourceNode.oCount = iSourceNode.oCount+1;
					
				if (currentOutConnect %2 == 0)//even
					return (iSourceNode.en);
				else //odd
					return (iSourceNode.es);
					
			}
			
			function optimizeIncomingConnectionLayout(iSourceNode,iTargetNode)
			{						
				if (areSourceAndTargetNeighbors(iSourceNode,iTargetNode)==true)
					return (iTargetNode.eo);
				
				var currOutCount = iSourceNode.oCount;
				
				//strategy : route connections coming from upper source nodes to upper upper target nodes
				//and connnect connections coming from lower source nodes to lower upper target nodes
				
				if (currOutCount%2 == 1)
					return (iTargetNode.en);
				else
					return (iTargetNode.es);						
				
			}
			
			function areSourceAndTargetNeighbors(iSourceNode,iTargetNode)
			{				
				var sourcediv = iSourceNode.divID;
				var targetdiv = iTargetNode.divID;
				
				var sdiff = targetdiv.substring(6,7) - sourcediv.substring(6,7);					
				
				if (sdiff==1)
					return true;
				/*				
				if (sdiff > 1)
				{
					
					var iS = sourcediv.substring(6,7);
					var iT = targetdiv.substring(6,7);
					alert("diff> alors :"+iS+" :" +iT );					
					iS = iS+1;
					alert(iS);
					
					for (var i=iS; i<iT; i++)
					{
						testdivID = "window"+i;
						alert("testint "+testdivID);
						if (document.getElementById(testdivID).style.visibility=='visible')
							return false;					
					}
					return true;
				}*/
				
				return false;
			}			
			
			function getNodeFromAnchor(iAnchor, iNode)
			{
				if (iAnchor == "TopCenter")
					return iNode.en;
				else if (iAnchor == "BottomCenter")
					return iNode.es;
				else if (iAnchor == "LeftMiddle")
					return iNode.eo;
				else//RightMiddle
					return iNode.ee;
				
			}
						
			function positionTargetToSource(iSourceNode,iTargetNode)
			{
				var sourcediv = iSourceNode.divID;
				var targetdiv = iTargetNode.divID;
						
				var sdiff = targetdiv.substring(6,7) - sourcediv.substring(6,7);
				
				if (sdiff>0)
					return "Right";//target is on the right of source
				else if (sdiff<0)
					return "Left";//target is on the left of the source
					
				return "NaN";			
			}			
			
			function distanceFromTargetToSource(iSourceNode,iTargetNode)
			{
				var sourcediv = iSourceNode.divID;
				var targetdiv = iTargetNode.divID;
				
				var sdiff = targetdiv.substring(6,7) - sourcediv.substring(6,7);
				
				return (Math.abs(sdiff));			
			}	
			
			
			function checkAnchorsCompatibility(sourceAnchor, targetAnchor, iNeighbours, targetPosToSource)
			{			
					
				if ( sourceAnchor == "TopCenter")
				{
				 	if (targetAnchor == "TopCenter") 
						return true;
				 	else
				 		return false;
				}
				
				if ( sourceAnchor == "BottomCenter")
				{
					if (targetAnchor == "BottomCenter")
						return true;			
					else
				 		return false;
				}
										
				if ( sourceAnchor == "LeftMiddle")
					return false;
				
				if ( sourceAnchor == "RightMiddle")
				{
					if ( ( iNeighbours == true) && (targetAnchor == "LeftMiddle"))
						return true;									
					else
						return false;
				}
				
				//We should never reach this point !
				return false;						
			}	
					
			
			function checkAnchorsCompatibility_beta(sourceAnchor, targetAnchor, iNeighbours, targetPosToSource)
			{			
					
				if ( sourceAnchor == "TopCenter")
				{
				 	if (targetAnchor == "TopCenter") 
						return true;
				 	else if ( (targetAnchor == "RightMiddle") && (targetPosToSource =="Right") && ( iNeighbours == false))
				 		return true;
				 	else if ( ( iNeighbours == false) && (targetAnchor == "LeftMiddle") && (targetPosToSource =="Left"))
				 		return true;
				 	else
				 		return false;
				}
				
				if ( sourceAnchor == "BottomCenter")
				{
					if (targetAnchor == "BottomCenter")
						return true;					
					if ( (targetAnchor == "RightMiddle") && (targetPosToSource =="Right") && ( iNeighbours == false) )
						return true;
				 	else if ( (targetAnchor == "LeftMiddle") && (targetPosToSource =="Left") && ( iNeighbours == false))
				 		return true;
					else
				 		return false;
				}
										
				if ( sourceAnchor == "LeftMiddle")
					return false;
				
				if ( sourceAnchor == "RightMiddle")
				{
					if ( ( iNeighbours == true) && (targetAnchor == "LeftMiddle"))
						return true;
					else if ( ( targetAnchor == "TopCenter") && (targetPosToSource =="Left") )
						return true;
					else if ( ( targetAnchor == "BottomCenter") && (targetPosToSource =="Left") )
						return true;								
					else
						return false;
				}
				
				//We should never reach this point !
				return false;			
				
			}			
							
			function checkStubForOverlapping(distTargetSource)
			{						
				
				for (var i=0; i<stubCompatibilityArray.length; i++)
				{									
					if (distTargetSource == stubCompatibilityArray[i][0])
					{							
						if (commonEndpoint.connector[1].stub == stubCompatibilityArray[i][1])	
							return true;
						else
							return false;							
					}
				}
					
				return true;
			}
		
			
			//Launching the connect Step !!!	
					
			var currTransLen = transitionInitArray.length;				
						
			for ( var i=0; i< currTransLen ; i++)
			{
				var sourceI = getStateInStructFromStateName(transitionInitArray[i].sourceState);
				var targetI = getStateInStructFromStateName(transitionInitArray[i].targetState);
				var iSignature = transitionInitArray[i].Name;
				var isConnectionCritical = transitionInitArray[i].isCritical;	
						
				
				//alert("drawing from "+transitionInitArray[i].sourceState+"to target"+transitionInitArray[i].targetState+"with name = "+transitionInitArray[i].Name+" isDeployed ?? "+transitionInitArray[i].isDeployed);
				
				connect(graphStatesArray[sourceI], graphStatesArray[targetI],iSignature,isConnectionCritical);		
			}
		
			
			jsPlumb.bind("jsPlumbConnectionDetached", function(connInfo) 
			{
				if (connInfo.connection.isCritical)
					redrawConnection(connInfo.connection);		
				
			});		
			
			// listen for new connections; initialise them the same way we initialise the connections at startup.
			jsPlumb.bind("jsPlumbConnection", function(connInfo) 
			{ 
				//alert("connecting !!!");
			
				var sAnchorType = connInfo.sourceEndpoint.anchor.type;
				var tAnchorType = connInfo.targetEndpoint.anchor.type;
				
				if (!connInfo.connection.isCritical)
				{
					//alert("new one !" +connInfo.connection.isCritical);
													
					var i_I = getStateInStruct(connInfo.connection.targetId);	
					var targetDefName ="";
					
					var policyType = currPolicyDescriptor.appType;
					
					if (policyType == "VPM")
						targetDefName = "to"+trimGeneratedName(graphStatesArray[i_I].userStateName);
					else
						targetDefName = "to"+graphStatesArray[i_I].userStateName;
					
					init(connInfo.connection,targetDefName,false,true,sAnchorType,tAnchorType);
				}
			});
			
			function handlePostTransitionRemovalIssues(i_src,i_targ) 
			{	
				var policyType = currPolicyDescriptor.appType;
				
				if (policyType == "CBP")
				{							
					var statesConntoSource = jsPlumb.getConnections({source:graphStatesArray[i_src].divID});
										
					if (statesConntoSource.length == 1)
					{										
						var itr_source = statesConntoSource[0].sourceId;					
						var itr_target = statesConntoSource[0].targetId;
										
						var i_src_struct = getStateInStruct(itr_source);
						var i_trg_struct = getStateInStruct(itr_target);					
												
						// IR-204387V6R2014						
						//var sdiff = graphStatesArray[i_trg_struct].divID.substring(6,7) - graphStatesArray[i_src_struct].divID.substring(6,7);
						
						var sdiff = graphStatesArray[i_trg_struct].iOrder - graphStatesArray[i_src_struct].iOrder;						
										
						if (sdiff==1)
						{
							//Implicit Transition, rename to ""
							statesConntoSource[0].label = "";					
							statesConntoSource[0].getOverlay("label").setLabel("");
							statesConntoSource[0].getOverlay("label").hide();							
						}
					
					}
				
				}//of if (policyType == "CBP")
						
			}		
			
			
			/*
			jsPlumb.bind("beforeDrop", function(connInfo) 
			{ 				
	
				var i_SCheck = getStateInStruct(connInfo.sourceId);
				var i_TCheck = getStateInStruct(connInfo.targetId);
				
				var cDist = distanceFromTargetToSource(graphStatesArray[i_SCheck], graphStatesArray[i_TCheck]);
					
				handleLiveStubForOverlapping(cDist);
				
				return true;
			});*/
			
			/*
			jsPlumb.bind("endpointClick", function(endpoint, originalEvent) 
			{ 
				alert("click on endpoint on element " + endpoint.elementId); 
			});
			*/
			
			newObj.connect  = connect ;
			
			return newObj;
			
			
		});
		
	
	/* function ResetTransitionStates()
	{
		//Detaching Everything		
		//jsPlumb.detachEverything(); //deprecated >1.3.3
		jsPlumb.detachEveryConnection();		
		var currTransLen = transitionDefaultArray.length;		
		//jsPlumbObject = new jsPlumb();
				
		for ( var i=0; i< currTransLen ; i++)
		{
			var sourceI = getStateInStructFromStateName(transitionDefaultArray[i].sourceState);
			var targetI = getStateInStructFromStateName(transitionDefaultArray[i].targetState);
			var iSignature = transitionDefaultArray[i].Name;				
		//	jsPlumbObject.connect(graphStatesArray[sourceI], graphStatesArray[targetI],iSignature);		
		}		
	}*/
		
	function RemoveStateInteractive(divId)		
	{		
		
		// var goDelete = confirm("<%=msgDeleteConfirm%>");	
		var tableid = "table_"+divId;			
		var stateName = document.getElementById(tableid).rows[0].cells[0].value;
		var goDelete = confirm("<%=msgDeleteConfirm%> "+stateName+" ?");			
		
		if (goDelete == true) 
		{						
			//jsPlumb.detachAll(divId);//1.3.3
			jsPlumb.detachAllConnections(divId);
			jsPlumb.removeAllEndpoints(divId);
			
			document.getElementById(divId).style.visibility='hidden';
							
			var i_S = getStateInStruct(divId);				
			graphStatesArray[i_S].isEnabled=false;
			
			//Adding to restore list
			var ListRestorelen=document.getElementById("ListStatetoRestore").options.length;			
			var newopt = new Option(graphStatesArray[i_S].userStateName,divId);			
			document.getElementById("ListStatetoRestore").options[ListRestorelen]=newopt;
									
			//Handling LifeCycleChecks Issues			
			removeLCChecksAfterStateRemoval(graphStatesArray[i_S].id);
			
			
		}
	}
			
		//DEMORMV
		/*
		function RemoveState(divId)		
		{							
			var goDelete=false;			
			var selectedI = document.getElementById("ListStatetoDelete").options.selectedIndex;			
			
			if (selectedI!=0)
			{
				// goDelete = confirm("<=msgDeleteConfirm%>");
				var tableid = "table_"+divID;			
				var stateName = document.getElementById(tableid).rows[0].cells[0].value;
				goDelete = confirm("<=msgDeleteConfirm%> "+stateName+" ?");
			}
				
			if (goDelete == true) 
			{
				//document.getElementById('window2').style.display='none';			
								
				var retDiv=document.getElementById("ListStatetoDelete").options[document.getElementById("ListStatetoDelete").options.selectedIndex].value;
		
				//jsPlumb.detachAll(retDiv);//1.3.3
				jsPlumb.detachAllConnections(retDiv);
				jsPlumb.removeAllEndpoints(retDiv);
				
				document.getElementById(retDiv).style.visibility='hidden';
								
				var i_S = getStateInStruct(retDiv);				
				graphStatesArray[i_S].isEnabled=false;				
							
				//Remove from 			
				var selected_elem = document.getElementById("ListStatetoDelete").selectedIndex;
				
				if (selected_elem!=0)
				{
					//Adding to restore list
					var ListRestorelen=document.getElementById("ListStatetoRestore").options.length;
					var newopt = new Option(document.getElementById("ListStatetoDelete").options[document.getElementById("ListStatetoDelete").options.selectedIndex].innerHTML,retDiv);
					document.getElementById("ListStatetoRestore").options[ListRestorelen]=newopt;
					
					//removing from the delete list
					document.getElementById("ListStatetoDelete").remove(selected_elem);					
					
				}
				
				//Removing LC Checks
				removeLCChecksAfterStateRemoval(graphStatesArray[i_S].id);
		
			//	document.getElementById(retDiv).style.display='none';				
			//	e2e.style.visibility='hidden';
			}
		}	
		*/
		
		//remove lifecycle checks after state deletion
		function removeLCChecksAfterStateRemoval(stateSys) 
		{			
			var nb_line=document.getElementById('rulestable').rows.length;
	    	var i=nb_line-1;
	    	
	    	while (i>=2)
	    	{	    
	    		var isrc  = document.getElementById('rulestable').rows[i].cells[1].value;
				var idest = document.getElementById('rulestable').rows[i].cells[2].value;
				
				if ( (isrc == stateSys) || 	(idest == stateSys))
					document.getElementById('rulestable').deleteRow(i);
					    		
				i--;
			}			
		}	
		
		
		
		
		//remove lifecycle checks after deleting transition
		function removeLCChecksAfterTransitionRemoval(sourceStateSys,targetStateSys) 
		{				
	    	
			var nb_line=document.getElementById('rulestable').rows.length;
	    	var i=nb_line-1;
	    	
	    	while (i>=2)
	    	{	    
	    		var isrc  = document.getElementById('rulestable').rows[i].cells[1].value;
				var idest = document.getElementById('rulestable').rows[i].cells[2].value;
				
				if ( (isrc == sourceStateSys) && (idest == targetStateSys))
					document.getElementById('rulestable').deleteRow(i);
					    		
				i--;
			}
			
		}
		
	
		
				
		/*
		function ChangeCellbgOnMouseEnter(id)
		{					
			var cellind=id.cellIndex;			
			document.getElementById('ControlBoxTable').rows[1].cells[cellind].style.backgroundColor="#CBE5FF";
			document.getElementById('ControlBoxTable').rows[1].cells[cellind].title="Click to Restore State";
		}
		
		function ChangeCellbgOnMouseExit(id)
		{
			var cellind=id.cellIndex;			
			document.getElementById('ControlBoxTable').rows[1].cells[cellind].style.backgroundColor="#CDD8EB";
			//document.getElementById("ControlBoxTable").rows[1].cells[cellind].style.visibility="hidden";
		
		}
		
		function RestoreStateOnClick(id)
		{
			var cellind=id.cellIndex;	
			
			if (confirm("you Sure that you want to restore this state ?"))
				document.getElementById("ControlBoxTable").rows[1].cells[cellind].style.visibility="hidden";		
		}*/
		
		function RestoreState()
		{		
			var selected_elem = document.getElementById("ListStatetoRestore").selectedIndex;
			
			if (selected_elem!=0)
			{
				//if (confirm("<=msgRestoreConfirm%>") )
				
				var retDiv=document.getElementById("ListStatetoRestore").options[document.getElementById("ListStatetoRestore").options.selectedIndex].value;
				document.getElementById(retDiv).style.visibility='visible';
					
				var i_in_struct = getStateInStruct(retDiv);						
				graphStatesArray[i_in_struct].isEnabled=true;
				
				//commonEndpoint.connector[1].stub+=5;
				//handleStubForOverlapping();
					
				graphStatesArray[i_in_struct].ee = jsPlumb.addEndpoint(retDiv, {anchor:"RightMiddle"}, commonEndpoint);
				graphStatesArray[i_in_struct].eo = jsPlumb.addEndpoint(retDiv, {anchor:"LeftMiddle"}, commonEndpoint);
				graphStatesArray[i_in_struct].en = jsPlumb.addEndpoint(retDiv, {anchor:"TopCenter"}, commonEndpoint);
				graphStatesArray[i_in_struct].es = jsPlumb.addEndpoint(retDiv, {anchor:"BottomCenter"}, commonEndpoint);					
								
				var newopt = new Option(document.getElementById("ListStatetoRestore").options[document.getElementById("ListStatetoRestore").options.selectedIndex].innerHTML,retDiv);
										
				//Removing the restored state from the "to restore" list				
				document.getElementById("ListStatetoRestore").remove(selected_elem);					
				
				/*document.getElementById('window2').style.display='block';					
				e2e.style.visibility='visible';	*/		
			}
			else
			{
				alert("<%=selectaStatemsg%>");
			}
		}
			
		function handleStateOnClick_timer(divID)
		{							
			if (timer) clearTimeout(timer);
			    timer = setTimeout(function() { 
			    	if (currPolicyDescriptor.areStatesRenamable)
						renameExistingState(divID);
			    	}, 250);  
		}
				
		function handleStateOnDblClick_timer(divID)
		{
			clearTimeout(timer);
			
			resetSelectedTransition();
			resetAllVisibleLabels();
			
			var i_in_S = getStateInStruct(divID);
			
			if ( ! graphStatesArray[i_in_S].isCritical)			
				RemoveStateInteractive(divID);
			else
				alert("<%=criticalStatemsg%>");
		}
		
		function handleStateOnClick(divID)
		{				
			if (currPolicyDescriptor.areStatesRenamable)
				renameExistingState(divID);

		}
		
		function handleStateOnDblClick(divID)
		{			
			resetSelectedTransition();
			resetAllVisibleLabels();
			
			var i_in_S = getStateInStruct(divID);
			
			if ( ! graphStatesArray[i_in_S].isCritical)			
				RemoveStateInteractive(divID);
			else
				alert("<%=criticalStatemsg%>");
		}
			
		
		function testNamingRules(enteredname)
		{			
			for (var i=0; i<graphStatesArray.length; i++)			
				if ( graphStatesArray[i].userStateName == enteredname)
					return "alreadyUsedName";
		 
			if (testNameForSpecialChar(enteredname)==true)		
				return "specialCharacterName";
						
			return "ok";			
		}
		
		function testNameForSpecialChar(iString)
		{
								
			var iChars ="!#$%^&*()+=-[]\\\';,/{}|\":<>?";

			for (var i = 0; i < iString.length; i++)						
				if (iChars.indexOf(iString.charAt(i)) != -1)	
			  		return true;
			
			return false;		
		}
		
		function testNameForBlankChar(iString)
		{	
			var iChars =" ";

			for (var i = 0; i < iString.length; i++)						
				if (iChars.indexOf(iString.charAt(i)) != -1)	
			  		return true;
			
			return false;		
		}
		
		function trimGeneratedName(iString)
		{
			return(iString.replace(/ /g,''));
		}
				
		function renameExistingState(divID)
		{			
			resetSelectedTransition();
			resetAllVisibleLabels();
			resethighlightChecksInTable();
						
			var tableid = "table_"+divID;	
			
			var previousName = document.getElementById(tableid).rows[0].cells[0].value;
			var enteredname=window.prompt("<%=newStateNamemsg%>",previousName);
					
			if (enteredname != null)
				if ( (enteredname!="") && (enteredname!=previousName))
				{
					var checkNameResult = testNamingRules(enteredname);
					if (checkNameResult == "ok")
						handleRenamingIssues(divID, enteredname);
					else
					{						
						if (checkNameResult == "alreadyUsedName")
							alert("<%=stateNameAlreadyUsed%>");
						else
							alert("<%=SpecialCharactersMessage%>");					
						
						//"specialCharacterName"			
						return;				
					}				
				}			
		}
		
		function handleRenamingIssues(divID, enteredname)
		{			
			//document.getElementById(divID).innerHTML=enteredname;
			
			var tableid = "table_"+divID;			
			document.getElementById(tableid).rows[0].cells[0].value=enteredname;			
			var processedName = handleNamingStyleIssue(enteredname);			
			document.getElementById(tableid).rows[0].cells[0].innerHTML=processedName;			
			
			var ii = getStateInStruct(divID);	
			
			graphStatesArray[ii].userStateName = enteredname;
							
			//handle LC renaming table			
			var nb_line=document.getElementById('rulestable').rows.length;
			
			for (var j=2; j<nb_line; j++) 
			{			
				var isrc  = document.getElementById('rulestable').rows[j].cells[1].value;
				var idest = document.getElementById('rulestable').rows[j].cells[2].value;
				
				if (isrc == graphStatesArray[ii].id)				
					document.getElementById('rulestable').rows[j].cells[1].childNodes[0].data = enteredname;
								
				if (idest == graphStatesArray[ii].id)				
					document.getElementById('rulestable').rows[j].cells[2].childNodes[0].data = enteredname;
							
			}

		}
			
		function handleSignatureOnClick(overlay)
		{

			if (currPolicyDescriptor.areTransitionsEditable)
			{
			
				//var currLabel = overlay.connection.label; 1.3.3
				var currLabel = overlay.component.label;			
	
				// var enteredname=prompt("<=msgCurrtransitionName%> : "+currLabel+".\n"+"<=newSignatureNamemsg%>",currLabel);			
				var enteredname=prompt("<%=newSignatureNamemsg%>",currLabel);			
				if (enteredname != null)
				{										
					if (testNameForSpecialChar(enteredname)==true)
					{	
						alert("<%=SpecialCharactersMessage%>");
						return;
					}
					
					var policyType = currPolicyDescriptor.appType;					
					
					if ( (policyType == "VPM") && (testNameForBlankChar(enteredname)==true))
					{
						alert("<%=blankCharactersMessage%>");			
						return;
					}
					
					if (enteredname!="")
					{
						/*overlay.connection.labelText = enteredname;
						overlay.connection.label = enteredname;*/
						overlay.component.labelText = enteredname;//1.3.5
						overlay.component.label = enteredname;//1.3.5
						
						overlay.setLabel(enteredname);
												
					//	var myoverlay = connection.getOverlay("label");					
					//	conn.getOverlay("label").setLabel(enteredname);//1.3.5						
	
					}
				}
							
				/*overlay.connection.repaint();
				setTimeout("delay("+overlay+")", 3000);
				overlay.connection.labelText ="";
				overlay.connection.repaint();*/				
			
			//	overlay.connection.repaint();//ZUR
			}
		//	resetSelectedTransition();
		//	overlay.connection.islastclicked = true;
		}
		
		
		function handleSignatureOnMouseEnter(connection)
		{
			//overlayLabel = "to"+document.getElementById(overlay.connection.targetId).innerHTML;
								
			var myoverlay = connection.getOverlay("label");
			myoverlay.setVisible(true);
			myoverlay.show();
	
			//connection.showOverlay();
			connection.labelText=connection.label;			
			connection.repaint();

		}
		
		function handleSignatureOnMouseExit(connection)
		{
			//overlay.connection.labelText="";
			
			if (connection.islastclicked == true)
			{
				connection.labelText=connection.label;
				connection.setHover(true);
				var myoverlay = connection.getOverlay("label");;//>1.3.5
				myoverlay.setVisible(true);
			}
			else
			{
				connection.setHover(false);
				connection.labelText="";
				
				var myoverlay = connection.getOverlay("label");//>1.3.5
				myoverlay.setVisible(false);
				myoverlay.hide();				
				connection.repaint();
			}
				
		}
		
		function isNewTransitionAllowed(sourceState, targetState)
		{
			
			for (var i=0; i<transitionForbiddenArray.length; i++)
			{
				if ( (transitionForbiddenArray[i].sourceState==sourceState)
						&&(transitionForbiddenArray[i].targetState==targetState))				
						return "forbiddentransition";
			}
							
			var i_source = getStateInStructFromStateName(sourceState);						
			var statesconnectedtoSource = jsPlumb.getConnections({source:graphStatesArray[i_source].divID});
			var nbconnectionstotarget = 0;		
			
			for ( var i=0; i< statesconnectedtoSource.length ; i++)
			{			
				tr_target = statesconnectedtoSource[i].targetId;
				i_target = getStateInStruct(tr_target);
				
				if ( graphStatesArray[i_target].id == targetState)			
					nbconnectionstotarget++;	
			}
			
			if 	(nbconnectionstotarget >1)	
				return "duplicatetransition";
						
			if (sourceState==targetState)
				return "cyclictransition";
							
			return "ok";
		}
		
		/*		
		Tests if the sent transition is a system-critical one.		
		*/
		
		function isTransmittedTransitionCritical(iSourceSysName,iTargetSysName)
		{
			
			var currTransLen = transitionInitArray.length;				
			
			for ( var i=0; i< currTransLen ; i++)
			{
				var sourceI = transitionInitArray[i].sourceState;
				var targetI = transitionInitArray[i].targetState;
				var isConnectionCritical = transitionInitArray[i].isCritical;
				
				if ( (iSourceSysName==sourceI)&&(iTargetSysName==targetI))			
					return isConnectionCritical;
			}	
			//if we are here, so it's not an old and critical transition, it is for sure a new one
			//so not critical -> returning false 			
			
			return false;
		}
		
		
		
		function handleLiveStubForOverlapping(iDistance)
		{
			nbConnections++;
			
			for (var i=0; i<stubCompatibilityArray.length; i++)						
				if (iDistance == stubCompatibilityArray[i][0])
				{
					commonEndpoint.connector[1].stub = stubCompatibilityArray[i][1];	
					return;
				}						
			
			//we should never reach this point
			commonEndpoint.connector[1].stub = 29;				
		}		
				
		function handleStubForOverlapping()
		{
			nbConnections++;
		
			if (nbConnections % 3 == 0)//each 3 connections
			{
				commonEndpoint.connector[1].stub+=7.5;		
				commonEndpoint.connector[0].stub+=7.5;	
			}
			
			if (commonEndpoint.connector[1].stub > 35)		
			{	
				commonEndpoint.connector[1].stub = 20;
				commonEndpoint.connector[0].stub = 20;
			}
			
		}
				
		function testRulesb4Deploy()
		{
			
			var statesconnectedtoSource;
			var statesconnectedtoTarget;
					
			for (var i=0; i<graphStatesArray.length; i++)
			{				
				if (graphStatesArray[i].isEnabled)
				{
					statesconnectedtoSource = jsPlumb.getConnections({source:graphStatesArray[i].divID});					
					statesconnectedtoTarget = jsPlumb.getConnections({target:graphStatesArray[i].divID});
					
					if  ( (statesconnectedtoSource.length ==0) &&
							(statesconnectedtoTarget.length==0))
								return "singletonstate";
										
				}						
			}		
			return "ok";
		}
		
		
		function checkPreviousRules_New(newID,retRule,retmultiple,retmultipleDiscipline)
		{
			if (retRule=="RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")
			{
				if (retmultiple=="ALL")
				{
					for (var i=0; i< SupportedTypes.length;i++)
					{
						if (isNewCheckWithInAlreadyUsed(newID+SupportedTypes[i]+"ALL") ==true)
							return "ko";
					}
					addNewRuletoExistant(newID,"ALL");
					
					return "ok";
				}
				else
				{
					if (isNewCheckWithInAlreadyUsed(newID+retmultiple+"ALL") ==true)
						return "ko";

					addNewRuletoExistant(newID+retmultiple+"ALL","");
					return "ok";
					
				}
			}
			else
			{
				if (isNewCheckWithInAlreadyUsed(newID+retmultiple+retmultipleDiscipline) ==true)
					return "ko";
			}
			addNewRuletoExistant(newID+retmultiple+retmultipleDiscipline,"");
			return "ok";
		}	
	        
		function isNewCheckWithInAlreadyUsed(newID)
		{
			for (var i=0; i<AlreadyUsedChecks.length;i++)
				if (newID==AlreadyUsedChecks[i])
					return true;
				
			return false;
		}
		
		function addNewRuletoExistant(newID,iAdditionalInfo)
		{
			var currLen = AlreadyUsedChecks.length; 
			
			if (iAdditionalInfo=="ALL")			
			{
				for (var i=0; i< SupportedTypes.length;i++)
				{	
					AlreadyUsedChecks[currLen+i] = newID+SupportedTypes[i]+"ALL";		
					
					if (i != (SupportedTypes.length-1))
						newRowidtoadd+=(currLen+i)+",";
					else
						newRowidtoadd+=(currLen+i);

				}
			}			
			else
			{	
				newRowidtoadd=currLen;				
				AlreadyUsedChecks[currLen]=newID;
			}
		}	
						
		function resetSelectedTransition()
		{
			
			if (sourceSelectedState != "INIT")
			{			
				document.getElementById(sourceSelectedState).style.borderColor= "#99CCFF";
				document.getElementById(targetSelectedState).style.borderColor= "#99CCFF";	
			}
			resetAllTransitions();						
		}
				
		function resetAllTransitions()
		{
			
			var listofConnections = jsPlumb.getAllConnections();	
			
			for ( var i in listofConnections) 
			{			
					for ( var j = 0; j < listofConnections[i].length; j++) 
					{
						var c = listofConnections[i][j];
						c.setHover(false);
						c.islastclicked=false;						
					}
			}	
		}
		
				
		function AddRow()
		{			
			
			if (sourceSelectedState == "INIT")
			{	
				alert("<%=selectaTransisionmsg%>");
			}
			else
			{			

			resetSelectedTransition();
			resetAllVisibleLabels();
			resethighlightChecksInTable();
							
			var size = document.getElementById('rulestable').rows.length;             
	   		
			var iSrc = getStateInStruct(sourceSelectedState);
			var iTrgt = getStateInStruct(targetSelectedState);		
							
			var sourceNLS=graphStatesArray[iSrc].userStateName;
	        var targetNLS=graphStatesArray[iTrgt].userStateName;
	        
	        var sourceStateSys = graphStatesArray[iSrc].id;
	        var targetStateSys = graphStatesArray[iTrgt].id;     
	         
	        var retourrule=document.getElementById("ChosenCheck").options[document.getElementById("ChosenCheck").options.selectedIndex].innerHTML;
	              	      
	         //discipline
	        /* //2014x
	        var objtypediscipline=document.getElementById("oDiscipline").value;
	         
	        if (document.getElementById("oDiscipline").disabled)
	         objtypediscipline="ALL";*/	  
	      //  var objtypediscipline = "";

		    var retmultipleArray = new Array();
		    var multiTypesValuesArray = new Array();
		    var retmultiple="",retmultipleValues="";
		    var retmultipleDiscipline="";
		    var multipleDisciplineArray=new Array();
		    var retRule=document.getElementById("ChosenCheck").options[document.getElementById("ChosenCheck").options.selectedIndex].value;

		    if ( (retRule=="RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")||
		    		((retRule=="RejectIfAttributeNotValuated")))
		    {
		    	for (var i = 0; i < document.getElementById("selectedValuesForChecks").options.length; i++)
		    		if (document.getElementById("selectedValuesForChecks").options[i].selected)
		    		{
		    			retmultipleArray.push(document.getElementById("selectedValuesForChecks").options[i].innerHTML);//value
		    			multiTypesValuesArray.push(document.getElementById("selectedValuesForChecks").options[i].value);
		    		}
		         		
				for (var i = 0; i<retmultipleArray.length;i++)
				{
					if (i != (retmultipleArray.length-1))
					{
						retmultiple+=retmultipleArray[i]+",";
						retmultipleValues+=multiTypesValuesArray[i]+",";
					}
					else
					{
						retmultiple+=retmultipleArray[i];
						retmultipleValues+=multiTypesValuesArray[i];
					}
				}
		    
		    	if ( (retRule=="RejectIfAttributeNotValuated") && (retmultiple==""))
				{
		    		alert("<%=SelectAttributemessage%>");					 
					return;
				}

		    	/*
				if (retRule=="RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")
				{				
					
					for (var i = 0; i < document.getElementById("selectedDisciplinesForChecks").options.length; i++)
						if (document.getElementById("selectedDisciplinesForChecks").options[i].selected)
							multipleDisciplineArray.push(document.getElementById("selectedDisciplinesForChecks").options[i].value);					 
					
					for (var i = 0; i<multipleDisciplineArray.length;i++)
					{
						if (i != (multipleDisciplineArray.length-1))
							retmultipleDiscipline+=multipleDisciplineArray[i]+",";
						else
							retmultipleDiscipline+=multipleDisciplineArray[i];
					}
					 
				}	
		    	*/
		    }	 
		    
	        var rettypeid=document.getElementById("ObjectTypeId").options[document.getElementById("ObjectTypeId").options.selectedIndex].value;
	        var rettype=document.getElementById("ObjectTypeId").options[document.getElementById("ObjectTypeId").options.selectedIndex].innerHTML;
	          
	        if ( (rettypeid=="Development Part") || (rettypeid=="EC Part") || (rettypeid=="Part"))
	        {
	        	rettypeid = "Part";
	        	rettype = "<%=CommonPartLabel%>";
	        }   
	        	  
	        var newid= rettypeid+sourceStateSys+targetStateSys+retRule;//objtypediscipline

	        newRowidtoadd="";
	        var checkresult =  checkPreviousRules_New(newid,retRule,retmultipleValues,retmultipleDiscipline);

	        if (checkresult=="ko")
			{
	        	alert("<%=Rulealreadysetmessage%>");
			}
			else
			{					
				var newRow = document.getElementById('rulestable').insertRow(-1);
			 	//newRow.style.backgroundColor= "white"; 
		     	newRow.id=newRowidtoadd;
		    
		     	var newCell = newRow.insertCell(0);
	         //	newCell.style.color = "#67738d";
	         	newCell.align = "left";
	         	newCell.className = "MatrixFeelNxG";
		        newCell.innerHTML = rettype;
		        newCell.value = rettypeid;

		        newCell = newRow.insertCell(1);
	         	newCell.align = "left";
	         	newCell.className = "MatrixFeelNxG";
	         	newCell.innerHTML = sourceNLS;
	         	newCell.value = sourceStateSys;

	         	newCell = newRow.insertCell(2);
	         	newCell.align = "left";
	         	newCell.className = "MatrixFeelNxG";
	         	newCell.innerHTML = targetNLS;
	         	newCell.value = targetStateSys;

	         	newCell = newRow.insertCell(3);
	         	newCell.align = "left";
	         	newCell.className = "MatrixFeelNxG";
	         	newCell.innerHTML = retourrule;
	         	newCell.value = retRule;

	         	/*newCell = newRow.insertCell(4);
	         	newCell.align = "left";
	         	newCell.className = "MatrixFeelNxG";
	         	newCell.innerHTML = objtypediscipline;*/

	          	newCell = newRow.insertCell(4);
	         	newCell.align = "left";
	         	newCell.className = "MatrixFeelNxG";
	         	newCell.innerHTML ="";	         	

	         	if (retmultiple!="")
	         	{
	         		if (retRule=="RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")	  
	         		{  
						var valuetoshow = "<%=ConsiderDisciplineLabel%>";
						valuetoshow=valuetoshow+" :"+retmultiple;
						var valuetostore = retmultipleValues;
						
						/*
						if (retmultipleDiscipline!="")
						{
							valuetoshow=valuetoshow+"/"+retmultipleDiscipline;
							valuetostore = valuetostore+"/"+retmultipleDiscipline;
						}
						else if ( (retmultipleDiscipline=="") && (retmultiple != "ALL"))
						{
							valuetoshow=valuetoshow+"/"+"ALL";
							valuetostore+="/"+"ALL";
						}*/
																
		         		newCell.innerHTML='<INPUT type=text size="30" Maxlength="150" readonly="readonly" value="'+valuetoshow+'">';
		         		newCell.value=valuetostore;
	         		}         		
	         		else if (retRule=="RejectIfAttributeNotValuated")
	         		{
	         			var valuetoshow = "<%=forAttributesLabel%>";
	         			valuetoshow=valuetoshow+" :"+retmultiple;
	         			newCell.innerHTML='<INPUT type=text size="30" Maxlength="150" readonly="readonly" value="'+valuetoshow+'">';
	         		}
	         	}	          		
       	
		     	newCell = newRow.insertCell(5);	 
	         	newCell.align = "right";
	         	newCell.className = "pic";	      
	        	newCell.innerHTML ='<img src="images/buttonDialogSubGray.gif" style="cursor:pointer" title="'+"<%=NotYetDeployedTitle%>"+'" id="image_'+size+'" onclick="deleteLCheckRow(this.parentNode.parentNode.rowIndex)">';
			 }
			
						
			//document.getElementById(sourceSelectedState).style.backgroundColor ="#99CCFF";
					
			}//of else if (sourceSelectedState == "INIT")
				
		}
		
		
		/*Old Stuff		
		 * ENOSTFunctionalReference			* 0-Functional Product
		 * ENOSTFunctionalRepReference		* 1-Functional Representation
		 * ENOSTLogical3DRepReference		* 2-Logical 3D Representation
		 * ENOSTLogicalReference			* 3-Logical Product
		 * ENOSTLogicalRepReference			* 4-Logical Representation
		 * Part								* 5-Part
		 * ENOSTProductReference			* 6-Physical Product
		 * ENOSTRepresentation				* 7-Physical Representation 
		 * ODTTEST							* 8-X_ODT_DataTypeTest
		 * MCADAssemblyForTeam				* 9-MCAD Assembly
		 * MCADComponentForTeam				* 10-MCAD Component
		 * MCADDrawingForTeam				* 11-MCAD Drawing
		 * MCADRepresentationForTeam		* 12-MCAD Representation	
		*/
		
			
		//	Deploys states, transitions and checks 
		
		function DeployParams(freezecmd)
		{
			//send : "id,userStateName,isEnabled,isCritical"	
						
			var rulesok = testRulesb4Deploy();
		
			if (rulesok != "ok")
			{
				if ( rulesok == "singletonstate")			
					alert("<%=singletonStatemsg%>");		
				
				return;			
			}
		
			// todo : Checker qu'il n y a pas de connections doubles : les filtrer			
					
			if (currPolicyDescriptor.areTransitionsEditable)
			{
				var listofRemovedStates = CheckforStateRemovalinSession();
			
				if (listofRemovedStates.length==0)				
					LaunchDeployProcess();				
				else
				{					
					var srvsend ="oPolicy="+currHandledPolicy;
					srvsend = srvsend + "&iNbofStates="+listofRemovedStates.length;					
					srvsend = srvsend + "&requestCommand=CheckForBOinStates";
					
					for ( var i=0; i< listofRemovedStates.length ; i++)	
						srvsend=srvsend+"&oStateSysName_"+i+"="+listofRemovedStates[i];					
										
					document.getElementById('LoadingDiv').style.display='block';
					document.getElementById('divPageFoot').style.display='none';
					
					xmlreq("emxPLMOnlineAdminXPAjaxLifeCycleTopology.jsp",srvsend,CheckBOStatesRet,0);
				}
			}
			else
			{
				LaunchDeployProcess();
			}
		
	  	}//of  function DeployParams()	  	
	    	
	  	function LaunchDeployProcess()
	  	{
	  		
	  		var currGraphLen = graphStatesArray.length;	
	  		
			var srvsend="iNbofStates="+currGraphLen;			
			srvsend = srvsend + "&requestCommand=DeployAll";
			srvsend = srvsend + "&oPolicy="+currHandledPolicy;
			
			var nbofTransitions=0;
	  		
			for ( var i=0; i< currGraphLen ; i++)
			{		
				srvsend=srvsend+"&oStateSysName_"+i+"="+graphStatesArray[i].id;
				srvsend=srvsend+"&oStateUserName_"+i+"="+graphStatesArray[i].userStateName;
				srvsend=srvsend+"&oisStateEnabled_"+i+"="+graphStatesArray[i].isEnabled;
				srvsend=srvsend+"&oisStateCritical_"+i+"="+graphStatesArray[i].isCritical;
										
				var statesconnectedto = jsPlumb.getConnections({source:graphStatesArray[i].divID});
				
				var tr_source,tr_target,i_in_struct,i_in_struct_t,tr_critical;
				
				if (currPolicyDescriptor.areTransitionsEditable)
				{
				
					for ( var j=0; j< statesconnectedto.length ; j++)
					{
						tr_source = statesconnectedto[j].sourceId;					
						i_in_struct = getStateInStruct(tr_source);					
						srvsend=srvsend+"&oTransitionSourceState_"+nbofTransitions+"="+graphStatesArray[i_in_struct].id;					
										
						tr_target = statesconnectedto[j].targetId;
						i_in_struct_t = getStateInStruct(tr_target);
						srvsend=srvsend+"&oTransitionTargetState_"+nbofTransitions+"="+graphStatesArray[i_in_struct_t].id;
					
						//Retrieve the criticity of the Transition					
						tr_critical = isTransmittedTransitionCritical(graphStatesArray[i_in_struct].id,graphStatesArray[i_in_struct_t].id);
										
						srvsend=srvsend+"&oTransitionCritical_"+nbofTransitions+"="+tr_critical;
										
						var tr_labelConnection =  statesconnectedto[j].label;
						srvsend=srvsend+"&oTransitionName_"+nbofTransitions+"="+tr_labelConnection;
					
						nbofTransitions=nbofTransitions+1;
					}
				}
				
				
			}
			
			srvsend=srvsend+"&oNbofTransitions="+nbofTransitions;					
			
			//LCChecks	
			
			var srvsend2="";
			
			var nb_line=document.getElementById('rulestable').rows.length;
			
			var isrc,idest,irule,itype,icheck,iadditionalinfo;//idiscipline
			var startfrom=1;
			var iAdditionalInfoGOV;

			for (var i=2; i<nb_line;i++) 
			{
				itype = document.getElementById('rulestable').rows[i].cells[0].value;
			
				//isrc = document.getElementById('rulestable').rows[i].cells[1].childNodes[0].data;
				isrc  = document.getElementById('rulestable').rows[i].cells[1].value;
				idest = document.getElementById('rulestable').rows[i].cells[2].value;
				irule = document.getElementById('rulestable').rows[i].cells[3].value;
			
				//idiscipline = document.getElementById('rulestable').rows[i].cells[4].childNodes[0].data;
		
				if ( (document.getElementById('rulestable').rows[i].cells[4].childNodes[0])==null)
					iadditionalinfo="";
				else
					iadditionalinfo = document.getElementById('rulestable').rows[i].cells[4].childNodes[0].value;

				//var tempinfo="";						
				//if (iadditionalinfo=="")
				//	tempinfo="NOINFO";
				
				if (irule=="RejectIfAttributeNotValuated")
				{
					var iID=iadditionalinfo.indexOf(":");
					iadditionalinfo=iadditionalinfo.substring(iID+1,iadditionalinfo.length);
				}
			
				if ((irule=="RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")
						&&(iadditionalinfo!="ALL"))
				{
						iadditionalinfo = document.getElementById('rulestable').rows[i].cells[4].value; 
				}

				//do the same for childtypes
				icheck=itype+":"+isrc+":"+idest+":"+irule+":"+iadditionalinfo;
				srvsend2=srvsend2+"&iRules_"+i+"="+icheck;
				startfrom = i;
			}
			
			//startfrom
			var indic=startfrom+1;
			for (var j=0; j<iChecksListBuffer.length;j++)
			{				
				srvsend2=srvsend2+"&iRules_"+indic+"="+iChecksListBuffer[j];
				indic++;
			}
					
			srvsend2=srvsend2+"&iRulesSize="+(nb_line-2+iChecksListBuffer.length);
			
		//	alert(srvsend);
		//	alert(srvsend2);
			srvsend=srvsend+srvsend2;
						
		//	alert(srvsend);		
		
			document.getElementById('LoadingDiv').style.display='block';
			document.getElementById('divPageFoot').style.display='none';	
						
			xmlreq("emxPLMOnlineAdminXPAjaxLifeCycleTopology.jsp",srvsend,DeployParamsRet,0);		  		
	  	}
	  	
	  	
	 	function CheckBOStatesRet()
	  	{  	 				

	 		var xmlhttpResponse = xmlreqs[0];			
			var usermessage="<%=deployLaunchFailure%>";					
			
			if(xmlhttpResponse.readyState==4)
			{				
				var CheckBOStates =xmlhttpResponse.responseXML.getElementsByTagName("BOinStates");
				
				if (CheckBOStates.item(0)!=null)
				{     
					//alert(CheckBOStates.item(0).firstChild.data);
					
					if (CheckBOStates.item(0).firstChild.data =="false")
					{	
						LaunchDeployProcess();
						return;						
					}
					else
					{				
						var statescontBO = xmlhttpResponse.responseXML.getElementsByTagName("StatesContaingBO");
						
						if (statescontBO.item(0)!=null)
						{        
							var stateNamesCrit = statescontBO.item(0).firstChild.data;
							
							var stateNamesCritList = new Array();
							stateNamesCritList = stateNamesCrit.split(',');
							
							var stateNamesListStr = "";
							
							for (var i=0; i < stateNamesCritList.length; i++)
							{
								var iInd = getStateInStructFromStateName(stateNamesCritList[i]);
																
								if (stateNamesListStr == "")
									stateNamesListStr = graphStatesArray[iInd].userStateName;
								else									
									stateNamesListStr += ", "+graphStatesArray[iInd].userStateName;
		
							}
																					
							var msgCriticalStep = "<%=exisitngBOmsg1%>"+stateNamesListStr+"\n"+"<%=exisitngBOmsg2%>"+"\n"+"<%=exisitngBOmsg3%>";						
							var confirmDeploy = confirm(msgCriticalStep);			
		
							if (confirmDeploy == true) 
							{
								LaunchDeployProcess();
								return;
							}
							else
							{						
								document.getElementById('LoadingDiv').style.display='none';
								document.getElementById('divPageFoot').style.display='block';	
								return;
							}
						}
						else
						{
							alert("<%=Deployfail%>");	
							return;
						}
					}
					
				}	
				alert(usermessage);	  		
	  		}
	  	}
	
	  	
		function DeployParamsRet()
		{
			var xmlhttpResponse = xmlreqs[0];      
			var freeze_res;
			var paramStatusDeploy="S_OK";//Deploy status of parameters
			var usermessage="<%=deployLaunchFailure%>";
			var resetk;
			
			if(xmlhttpResponse.readyState==4)
			{				
				document.getElementById('LoadingDiv').style.display='none';
				document.getElementById('divPageFoot').style.display='block';
				
				var Deploy_Res =xmlhttpResponse.responseXML.getElementsByTagName("DeployResult");
				var Deploy_Res_Log =xmlhttpResponse.responseXML.getElementsByTagName("DeployResultLog");
				
				var rulestablesize = document.getElementById('rulestable').rows.length;
					
				if (Deploy_Res.item(0)!=null)
				{         	          
					if (Deploy_Res.item(0).firstChild.data =="S_OK")
					{							
						for (var i=2; i<rulestablesize;i++) 						
							document.getElementById('rulestable').rows[i].cells[5].innerHTML='<img src="images/buttonDialogSub.gif" style=\"cursor:pointer\" title="'+"<%=DeployedTitle%>"+'" onclick=\"deleteLCheckRow(this.parentNode.parentNode.rowIndex)\">';
													
						usermessage="<%=Deploysuccess%>";
		        		usermessage=usermessage+"\n<%=Restartmessage%>";	
						usermessage=usermessage+"\n<%=copyCATNlsmsg%>";						
		        	
					}
					else
					{								
						usermessage="<%=Deployfail%>";						
						usermessage+="\n" + Deploy_Res_Log.item(0).firstChild.data;			
					}
				}
			
				alert(usermessage);
				
				//Reload the Page				
				if (Deploy_Res.item(0)!=null)
				{         	          
					if (Deploy_Res.item(0).firstChild.data =="S_OK")
					{	
						var str = window.location.href;
						str = str.replace("LCReset","LCLoad");//IR-215622V6R2014				
						window.location.href = str;						
					}
				}		
				
				
			}
		}
	  		  	
		function UpdateRulesComplementary()
		{
			var rettype=document.getElementById("ChosenCheck").options[document.getElementById("ChosenCheck").options.selectedIndex].value;			
			
			document.getElementById("ChosenCheck").title=document.getElementById("ChosenCheck").options[document.getElementById("ChosenCheck").options.selectedIndex].title;
					
			if(rettype=="RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")			
				ShowMultipleSelectForRules(rettype,"visible");	
			else
				ShowMultipleSelectForRules(rettype,"hidden");
		}				
		
		function CheckforStateRemovalinSession()
		{
			var currGraphLen = graphStatesArray.length;	
			
			var listofRemovedStates =  new Array();
			var j = 0;

			for ( var i=0; i< currGraphLen ; i++)
			{												
				if ( (graphStatesArray[i].isEnabled == false)&&
						(graphStatesArray[i].initiallyEnabled == true))
				{				
					listofRemovedStates[j++] = graphStatesArray[i].id;
				}
			}			
			return listofRemovedStates;
		}
	  	
		function ShowMultipleSelectForRules(iType,visibilityStatus)
		{
			
			document.getElementById("selectedValuesForChecks").style.visibility=visibilityStatus;			
			document.getElementById("labelSelect").style.visibility=visibilityStatus;
			//document.getElementById("selectedDisciplinesForChecks").style.visibility=visibilityStatus;	
		
			var rettype=document.getElementById("ObjectTypeId").options[document.getElementById("ObjectTypeId").options.selectedIndex].value;
			
			//document.getElementById("labelDiscipline").style.visibility=visibilityStatus;
			
			//14x
			
			if(iType=="RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")
			{			
				document.getElementById("selectedValuesForChecks").title="<%=ConsiderChildTypesLabel%>";
				document.getElementById("selectedValuesForChecks").options.length = 0;

				document.getElementById("labelSelect").firstChild.nodeValue="<%=ConsiderChildTypesLabel%>";
				//document.getElementById("labelDiscipline").style.visibility=visibilityStatus;
				
				updateSelectListForRule(iType);	
				
				var currTypeCat = ""
				
				var optiontab =  new Array();
				//alert(rettype);
				//MBH detected issue
				if ( rettype.indexOf("Part") == 0 )
				{
					optiontab[0] = new Option("<%=CommonPartLabel%>","Part"); 
					document.getElementById("selectedValuesForChecks").disabled=true;
				}
				else
				{
					for ( var i=0; i<typeDescriptorArray.length; i++)								
						if (typeDescriptorArray[i].typeID==rettype)
						{
							currTypeCat = typeDescriptorArray[i].typeCategory;
							break;
						}
					
					optiontab[0] = new Option("<%=AllStringNLS%>","ALL");
					var k=1;
					
					for ( var i=0; i<typeDescriptorArray.length; i++)								
						if (typeDescriptorArray[i].typeCategory==currTypeCat)
						{
							optiontab[k++] = new Option(typeDescriptorArray[i].typeNLS,
									typeDescriptorArray[i].typeID);
						}				
				}										
						
				for ( var i=0; i<optiontab.length; i++)
					document.getElementById("selectedValuesForChecks").options[i]=optiontab[i];
			
				//updateDiscipline('selectedValuesForChecks','selectedDisciplinesForChecks');
	
			}
			else if (iType=="RejectIfAttributeNotValuated")
			{
				//document.getElementById("labelDiscipline").style.visibility="hidden";	
								
				for ( var i=0; i<typeDescriptorArray.length; i++)								
					if (typeDescriptorArray[i].typeID==rettype)						
						if (typeDescriptorArray[i].supportAttributes == true)
						{
							
							document.getElementById("selectedValuesForChecks").style.visibility="visible";
							document.getElementById("selectedValuesForChecks").title="<%=forAttributesLabel%>";					

							document.getElementById("labelSelect").style.visibility="visible";
							document.getElementById("labelSelect").firstChild.nodeValue="<%=forAttributesLabel%>";
							
							updateSelectListForRule(iType);	

							var tempAttArray = new Array();
							tempAttArray = 	typeDescriptorArray[i].listofAttributes;					
							document.getElementById("selectedValuesForChecks").options.length =tempAttArray.length ;

							for (var i=0; i<tempAttArray.length;i++)
							{		
								var opti=new Option(tempAttArray[i],tempAttArray[i]);											
								document.getElementById("selectedValuesForChecks").options[i]=opti;
							}
							break;
						}							

			}// of 	else if (iType=="RejectIfAttributeNotValuated")

		}
						
		function updateSelectListForRule(iPromotionRule)
		{
			

			if (iPromotionRule == "RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")
			{			
				var ListObjectContainer = document.getElementById("ListContainer");
				var ListObjectElement = document.getElementById("selectedValuesForChecks");	
				
				ListObjectContainer.removeChild(ListObjectElement);

				var selectMultiple = document.createElement("select");
				//selectMultiple.multiple="false";
				
				//selectMultiple.multiple="true";//2014x test
				//selectMultiple.size=2;//2014x test
			
				//selectMultiple.type="select-multiple";					
				selectMultiple.id="selectedValuesForChecks";
				selectMultiple.setAttribute("style", "width:200px");	
				if (document.all)//IE
				{	
					selectMultiple.style.setAttribute("cssText","width:200px;");
				}				

			
				//selectMultiple.onchange = function() { updateDiscipline('selectedValuesForChecks','selectedDisciplinesForChecks'); };
				
				ListObjectContainer.appendChild(selectMultiple);
								
			}
			else if (iPromotionRule == "RejectIfAttributeNotValuated")
			{				
				var ListObjectContainer = document.getElementById("ListContainer");
				var ListObjectElement = document.getElementById("selectedValuesForChecks");	
				
				ListObjectContainer.removeChild(ListObjectElement);

				var selectMultiple = document.createElement("select");
				selectMultiple.multiple="true";
				selectMultiple.size=3;
				//selectMultiple.type="select-multiple";
					
				selectMultiple.id="selectedValuesForChecks";
				selectMultiple.setAttribute("style", "width:200px");	
				if (document.all)//IE
				{	
					selectMultiple.style.setAttribute("cssText","width:200px;");
				}
				ListObjectContainer.appendChild(selectMultiple);							

			}
			
		}

		/*
		function OnAttributeTypeChange()
		{
			var curTypeandLength=document.getElementById("ChosenType").value;

			if (curTypeandLength=="Boolean")
			{		
				var defaultObjectElement = document.getElementById("iAttributeDefValue");	
				var defaultObjectContainer = document.getElementById("DefValueClassContainer");
				defaultObjectContainer.removeChild(defaultObjectElement);

				var selectBool = document.createElement("select");
				selectBool.id="iAttributeDefValue";
				selectBool.setAttribute("style", "width:200px");	
				if (document.all)//IE
				{	
					selectBool.style.setAttribute("cssText","width:200px;");
				}	
				selectBool.options[0] = new Option("FalseLabel","False");
				selectBool.options[1] = new Option("TrueLabel","True");

				defaultObjectContainer.appendChild(selectBool);

				if (document.getElementById("CheckBxReadOnlyAttr").checked==false)
				{
					document.getElementById("iAttributeAuthValue").value="TrueLabel,FalseLabel";
				}		
				document.getElementById("iAttributeAuthValue").readOnly = true;
				document.getElementsByName("ValuesRadio")[0].checked=true;

			}

		}*/
			
		function updateSelectablesForType()
		{
			//var iObjectTypeSource = "ObjectTypeId";
			//var iDisciplineListtoControl = "oDiscipline";	
			//if (iObjectTypeSource == "ObjectTypeId") 	//2014x
				
			var rettype=document.getElementById("ObjectTypeId").options[document.getElementById("ObjectTypeId").options.selectedIndex].value;	
			UpdateLifeCycleCheckList(rettype);
			UpdateRulesComplementary(rettype);			
			
			document.getElementById("ObjectTypeId").title = document.getElementById("ObjectTypeId").options[document.getElementById("ObjectTypeId").options.selectedIndex].innerHTML;
		
		}
		
		
		function UpdateLifeCycleCheckList(irettype)
		{
			document.getElementById("ChosenCheck").options.length = 0;			
			
			for ( var i=0; i<typeDescriptorArray.length; i++)
			{			
				if (typeDescriptorArray[i].typeID==irettype)
				{
					var listofRulesofthisType = typeDescriptorArray[i].listofRulesID;					
					
					for (var j=0; j<listofRulesofthisType.length; j++)
					{
						var i_Irule = getIinRulesStruct(listofRulesofthisType[j]);						
						
						document.getElementById("ChosenCheck").options[j]= new Option(listofRulesArray[i_Irule].ruleNLS,listofRulesArray[i_Irule].ruleID);;						
						document.getElementById("ChosenCheck").options[j].title = listofRulesArray[i_Irule].ruleNLSTooltip;						
					}					
					break;
				}
			}		
		}
		
		
		function getIinRulesStruct(iruleID)
		{			
			for (var i=0; i < listofRulesArray.length; i++)
				if (listofRulesArray[i].ruleID == iruleID)
					return i;
			
		}			
		 
		function BuildInitialTable(rowID,newObjType,newObjTypeNLS,nSource,nSourceNLS,nDest,nDestNLS,nRule,nRuleNLS,nAdditionalInfoValue,nAdditionalInfo,remBehave)
	    {
			//nDiscipline
			var newRow = document.getElementById('rulestable').insertRow(-1);
	   	  
			newRow.id=rowID;       	
	        	
	        newCell = newRow.insertCell(0);	   
	        newCell.className="MatrixFeelNxG";	             	    	        	
	        newCell.value=newObjType;
	        newCell.innerHTML=newObjTypeNLS;	
	        		        	
	        newCell = newRow.insertCell(-1);
	        newCell.align = "left";
	        newCell.className="MatrixFeelNxG";	  
	        newCell.innerHTML=nSourceNLS;
	        newCell.value=nSource;

	       	newCell = newRow.insertCell(-1);
	        newCell.align = "left";
	        newCell.className="MatrixFeelNxG";
	  	    newCell.innerHTML=nDestNLS;
	  	    newCell.value=nDest;

	  	    newCell = newRow.insertCell(-1);	   
	        newCell.className="MatrixFeelNxG";	             	    	        	
	        newCell.value=nRule;
	        newCell.innerHTML=nRuleNLS;
	      
	        /*newCell = newRow.insertCell(-1);
	        newCell.align = "left";
	        newCell.className="MatrixFeelNxG";
	  	    newCell.innerHTML=nDiscipline;    */
	  	        
	  	   	newCell = newRow.insertCell(-1);
        	newCell.align = "left";
        	newCell.className="MatrixFeelNxG";	        	

	  	   	if (nAdditionalInfo!="")	
	  	   	{
	  	   	   	if (nRule == "RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")
	  	   	   		newCell.value=nAdditionalInfoValue;	  	   	   			

	  	   	   	newCell.innerHTML='<INPUT type=text size="30" Maxlength="150" readonly="readonly" value="'+nAdditionalInfo+'">';	  	   	   		
	  	   	 }
			 else
				newCell.innerHTML="";   	
	  	  
	  	   	newCell = newRow.insertCell(-1);
    		newCell.align = "right";
    		newCell.style.width="5%";	  	   	   	
	  	   	   	
	  	   	if (remBehave=="Frozen")
	  	   		newCell.innerHTML='<img src="images/iconSetAttribute.gif" title="'+"<%=FrozenLine%>"+'"> </td></tr>';
			else if (remBehave=="NotDeployed")
				newCell.innerHTML='<img src="images/buttonDialogSubOrangeDB.gif" style="cursor:pointer" title="'+"<%=NotYetDeployedTitle%>"+'" onclick="deleteLCheckRow(this.parentNode.parentNode.rowIndex)"> </td></tr>';
			else			
				newCell.innerHTML='<img src="images/buttonDialogSub.gif" style="cursor:pointer" title="'+"<%=DeployedTitle%>"+'" onclick="deleteLCheckRow(this.parentNode.parentNode.rowIndex)"></td></tr>';
	  	   			  	      	
	    }		
		
		function deleteLCheckRow(i)
		{
			//previously deleteRowWWW
			var relatedSetCheksIds = document.getElementById('rulestable').rows[i].id;

			var idstoremove = new Array();
			idstoremove =relatedSetCheksIds.split(',');

			for (var j=0; j<idstoremove.length;j++)
				AlreadyUsedChecks[idstoremove[j]]="NAN";	
						
			document.getElementById('rulestable').deleteRow(i);
		}
				
		/*2014x
		function updateDiscipline(iObjectTypeSource,iDisciplineListtoControl)
		{			
			var optionDisciplineTab =  new Array();
					
			var rettype=document.getElementById(iObjectTypeSource).options[document.getElementById(iObjectTypeSource).options.selectedIndex].value;//innerHTML; //-->id   .option
			document.getElementById(iDisciplineListtoControl).options.length = 0;
		
			if (rettype=="ALL" )
			{
				document.getElementById(iDisciplineListtoControl).disabled=true;	
				optionDisciplineTab[0] = new Option("ALL","ALL");				
			}
			else if ((rettype=="ENOSTRepresentation") && (iObjectTypeSource=="selectedValuesForChecks") )
			{
				//The only hardcoded case left
				document.getElementById(iDisciplineListtoControl).disabled=false;									
				optionDisciplineTab[0] = new Option("Design","Design");
				optionDisciplineTab[1] = new Option("Drafting","Drafting");
				optionDisciplineTab[2] = new Option("ALL","ALL");
			}
			else
			{				
				for (var i=0; i<typeDescriptorArray.length ; i++)
				{
				  	if ( rettype == typeDescriptorArray[i].typeID )
					{					  	
				  		var listofDiscplines = new Array(); 				  		
				  		
				  		if (typeDescriptorArray[i].listofDisciplines =="")
				  		{				  			
				  			document.getElementById(iDisciplineListtoControl).disabled=true;	
							optionDisciplineTab[0] = new Option("ALL","ALL");				  			
				  		}
				  		else
				  		{
				  			listofDiscplines = typeDescriptorArray[i].listofDisciplines.split(',');				  			
				  			document.getElementById(iDisciplineListtoControl).disabled=false;
				  		
				  			for (var j=0; j<listofDiscplines.length ; j++)				  		
				  				optionDisciplineTab[j] =new Option(listofDiscplines[j],listofDiscplines[j]);
				  			
				  			optionDisciplineTab[listofDiscplines.length] = new Option("ALL","ALL");
				  		}		 
				  		
				  		break;
					}				
				}				
			}				
			
			for ( var i=0; i<optionDisciplineTab.length; i++)
				document.getElementById(iDisciplineListtoControl).options[i]=optionDisciplineTab[i];
			
			if (iObjectTypeSource == "ObjectTypeId")
			{
				UpdateLifeCycleCheckList(rettype);
				UpdateRulesComplementary(rettype);
			}
		
		}*/
				
		
		function BuildTypesList()
		{			
			var optionTypesArray =  new Array();
		
			for (var i=0; i<typeDescriptorArray.length ; i++)
				optionTypesArray[i] = new Option(typeDescriptorArray[i].typeNLS,typeDescriptorArray[i].typeENOID);//.typeID
					
			for ( var i=0; i<optionTypesArray.length; i++)
			{
				document.getElementById("ObjectTypeId").options[i]=optionTypesArray[i];
				document.getElementById("ObjectTypeId").options[i].title = optionTypesArray[i].text;
			}
			
		}		
		
		function handleComplementaryAspects()
		{
			/*
			if (!currPolicyDescriptor.areStatesRenamable)
			{
				document.getElementById("ListStatetoRestore").disabled=true;
			}*/
			
			if (!currPolicyDescriptor.areTransitionsEditable)
			{
				document.getElementById("ListStatetoRestore").disabled=true;
			}
			
		}
		
		/*
		function ResetLifecyleChecks()
		{
			
			var nb_line=document.getElementById('rulestable').rows.length;
			var i=nb_line-1;

		    while (i>=2)
		    {
				document.getElementById('rulestable').deleteRow(i);
				i--;
			}
			
			//IR IR-118752V6R2012x
			AlreadyUsedChecks.splice(0,AlreadyUsedChecks.length);
			//alert("<=ResetWarningMessage%>");		
		}*/
		
		/*
		function ResetCustoStates()
		{
			var currDiv,newName,iInStruct;
			for (var i=0; i<graphStatesDefaultArray.length; i++)
			{
				currDiv = graphStatesDefaultArray[i].divID;
				newName = graphStatesDefaultArray[i].id;				
				handleRenamingIssues(currDiv, newName);				
				iInStruct = getStateInStruct(currDiv);		
				graphStatesArray[iInStruct] = graphStatesDefaultArray[i];			
			}
			
		}*/						
		
		function ResetInSession()
		{						
			//window.location.href=window.location.href;					
			var str = window.location.href;					
					
			str = str.replace("LCReset","LCReset");
			str = str.replace("LCLoad","LCReset");
			
			window.location.href = str;					
							
			/*
			//Reset Lifecyle Checks
			ResetLifecyleChecks();
			
			//Handle Reset States			
			ResetCustoStates();			
			
			//Handle Reset Transitions
			ResetTransitionStates();*/						
		}
		
		</script>
		
		
		<div id="AlreadySetRules" style="min-height:20%; overflow-y:auto">
		
		 <table id="rulestable" width="100%" height="20%" cellspacing="2" cellpadding="0" style="none" bgcolor="white"> 
    		<tr bgcolor="#659ac2" title="<%=RulesTableToolTip%>">
			 <td class="TitleInParam" colspan=6 height="20"><%=CurrentSetCheckslabel%> <%=iPolicyUI%></td>
			</tr>
	
			<tr width="100%" bgcolor="#CDD8EB">
 			 <td class="TitleSecParam" width="15%"><%=DataTypeLabel%></td>
 			 <td class="TitleSecParam" width="10%"><%=FromStatusLabel%></td>
 			 <td class="TitleSecParam" width="10%"><%=ToStatusLabel%></td>
 			 <td class="TitleSecParam" width="15%"><%=Rulelabel%></td>
 			 <td class="TitleSecParam" width="10%"><%=AdditionalInfoTitle%></td>
 			 <td class="TitleSecParam" width="5%">			 			 
 			 </td>
 			</tr>	
 		
 	<script>
	var iRulesCounter = 0;
	var iChecksListBuffer = new Array();
	var iChecksListCounter = 0;	
	</script>
	<%
	
	String[] Splitstring;
	Splitstring = new String[7];
	String currentString;
	String idString="";
	String str1 ="";
	String InfotoAdd="";
	
	RuleDescription[] listofAvailableRules = myLifeCycleHandler.getRulesList();
	
	for (int i=0; i<listofAvailableRules.length; i++)
	{
		
		String ruleID		= listofAvailableRules[i].getRuleID();
		String ruleNLS 		= myNLS.getMessage(listofAvailableRules[i].getRuleNLSKey());
		String ruleTooltip	= myNLS.getMessage(listofAvailableRules[i].getRuleNLSTooltipKey());	
		
		%>
		<script>
		addRuletoList("<%=ruleID%>", "<%=ruleNLS%>", "<%=ruleTooltip%>", <%=i%>);
		</script>
		<%
		
	}	
		
	String [] listofhandledTypes = handledTypesforPolicy.split(",");
	
	TeamAttributeCustomize RACEAttrHandler = new TeamAttributeCustomize(context);
	//String[] listofIDs = RACEAttrHandler.getAllCollectionIDs();//IR-267997V6R2014x
	
	if (!"".equals(handledTypesforPolicy))
	{
	
	for (int i=0; i<listofhandledTypes.length; i++)
	{
		
		//RuleDescription[] listorRulesforType = myLifeCycleHandler.getRulesListForType(listofhandledTypes[i]);
		String [] olistofRulesForType = myLifeCycleHandler.getUserDefinedRulesListForType(listofhandledTypes[i],currentPolicy);
		
		%>			
		<script>
		var listofRulesforType = new Array();
		var listofAttributesforType = new Array();
		</script>
		<%				
		for (int j=0; j<olistofRulesForType.length; j++)
		{
			
			//String ruleID =  listorRulesforType[j].getRuleID();			
			String ruleID =  olistofRulesForType[j];
			%>			
			<script>			
			listofRulesforType[<%=j%>] = "<%=ruleID%>";
			</script>
			<%		
		}
		
		TypeCustoDescription currHandledType = myLifeCycleHandler.getTypeDescription(listofhandledTypes[i],handledPolicy);
						
		ParameterizationNLSCatalog currNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, currHandledType.getNLSFileName());
		String NLSTypeID = currNLSCatalog.getMessage(currHandledType.getTypeNLSKey());	
	
		//String currApplicativeTypes = currHandledType.getApplicativeTypes();
		String currEnoType = currHandledType.getTypeENOID();
		String iTypeCategory = currHandledType.getTypeCategory();
	
		boolean typeSupportsAttributes = false;
		
		//for (int j=0; j<listofIDs.length; j++)
		//{
		//IR-267997V6R2014x	
		for (int j=0; j<olistofRulesForType.length; j++)
		{				
			//if (currEnoType.equalsIgnoreCase(listofIDs[j]))
			//{ IR-267997V6R2014x
			if ("RejectIfAttributeNotValuated".equals(olistofRulesForType[j]))
			{
				typeSupportsAttributes = true;
				AttributeProperties[] listAttrofType = RACEAttrHandler.getAddedAttributes(currEnoType);
				
				if (listAttrofType!=null)
				{
					int totalAttrLen=listAttrofType.length;
					int l=0;
					int attrStatus = 2;
					String attrtype ="";
					
					for(int k=0; k<totalAttrLen; k++)
					{
						attrStatus = listAttrofType[k].isDeployed() ? 1 : 2;	
						attrtype = listAttrofType[k].getAttributeType();
						
						if ( (attrStatus==1)&&( (attrtype.equalsIgnoreCase("Real") ) || (attrtype.equalsIgnoreCase("String"))   ) )
						{					
								String attrname = listAttrofType[k].getUserName();	
								%>
								<script>
								listofAttributesforType[<%=l%>] = <%="'"+attrname+"'"%>;
								</script>
								<%	
								l++;					
						}
					}//of for loop
				}		
			}
		}// of for loop if ("RejectIfAttributeNotValuated" ...
				
		//}//of for loop on listofIDs for AttributesSupport //IR-267997V6R2014x		

		%>			
		<script>	
		//listofAttributesforType[0] = "Supplier";//WARNING REMOVE*/
		//alert("<=listofhandledTypes[i]%>"+":"+"<=typeSupportsAttributes%>");
		
		
		addTypetoList("<%=listofhandledTypes[i]%>", "<%=NLSTypeID%>", listofRulesforType, 
				"<%=currEnoType%>",
				<%=typeSupportsAttributes%>,listofAttributesforType,
				"<%=iTypeCategory%>",
				<%=i%>);
		</script>
		<%		
	
	}//of for (int i=0; i<listofhandledTypes.length; i++)	
	
	}//of if (!"".equals(handledTypesforPolicy))
	
	%>
	<script>
	var currentActionLC = "<%=currentAction%>"; //LCLoad
	</script>
	<%	
		
	if (!"".equals(handledTypesforPolicy))
	{
		for (int i=0; i<listofhandledTypes.length; i++)
		{
			%>			
			<script>	
			SupportedTypes[<%=i%>]="<%=listofhandledTypes[i]%>";
			</script>
			<%
		}
	}
		
	StringList iGetList = myLifeCycleHandler.getLifecycleChecks(context,currentPolicy);
			
	if (iGetList!=null)
	{
	
		for (int i=0; i<iGetList.size(); i++)
		{
			currentString = (String) iGetList.elementAt(i);
			Splitstring = currentString.split(":", 6);//split into 6 parts, prev 7
			//String iAdditionalInfo="";
			String iAdditionalInfotoShow="";	
			String CurrentHandledCheck="";
			
			InfotoAdd="";
					
			//idString = currentString.replace(":", "");	
			
			idString=Splitstring[0]+Splitstring[1]+Splitstring[2]+Splitstring[3];
			
			CurrentHandledCheck=Splitstring[3];				
				
			for ( int k = 0; k < listofAvailableRules.length; k++)								
				if (Splitstring[3].equalsIgnoreCase(listofAvailableRules[k].getRuleID()))
					Splitstring[3]= myNLS.getMessage(listofAvailableRules[k].getRuleNLSKey());		
			
			if (!(Splitstring[4].equalsIgnoreCase("NOINFO")) )			
			{
				InfotoAdd=Splitstring[4];
				
				if (CurrentHandledCheck.equalsIgnoreCase("RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState"))
				{
					String additionnalInfoInput = Splitstring[4];
										
					if ( (!additionnalInfoInput.equalsIgnoreCase("ALL") ) 
					&&(!additionnalInfoInput.equalsIgnoreCase("")) )
					{						
						/*2014x
						String ChildType="";
						String InfotoKeep="";//2014x					
					
						int detectDelimitingchar = additionnalInfoInput.indexOf("/");
						
						if (detectDelimitingchar>0)		
							ChildType=additionnalInfoInput.substring(0,detectDelimitingchar);
							
						InfotoKeep=additionnalInfoInput.substring(detectDelimitingchar);*/						
						
						/*Functional Representation/ALL
						Functional Representation/Schema,Picture,Schema_Snapshot
						ALL	*/	
						/*						
						TypeCustoDescription govType = myLifeCycleHandler.getTypeDescription(ChildType);
						
						ChildType = myNLS.getMessage(govType.getTypeNLSKey());
						ParameterizationNLSCatalog currNLSCatalog = new ParameterizationNLSCatalog(ctx, currentLocale, govType.getNLSFileName());
						
						ChildType = currNLSCatalog.getMessage(govType.getTypeNLSKey());	
												
						additionnalInfoInput=ChildType;//+InfotoKeep;2014x
						*/						
						
						TypeCustoDescription govType = myLifeCycleHandler.getTypeDescription(additionnalInfoInput);
						
						additionnalInfoInput = myNLS.getMessage(govType.getTypeNLSKey());
						ParameterizationNLSCatalog currNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, govType.getNLSFileName());
						
						additionnalInfoInput = currNLSCatalog.getMessage(govType.getTypeNLSKey());	
		
					}
					
					if (additionnalInfoInput.equalsIgnoreCase("ALL"))
						additionnalInfoInput = AllStringNLS;															
						
					iAdditionalInfotoShow=ConsiderDisciplineLabel+" :"+additionnalInfoInput;
				}
				else if (CurrentHandledCheck.equalsIgnoreCase("RejectIfAttributeNotValuated"))					
					iAdditionalInfotoShow=forAttributesLabel+" :"+Splitstring[4];
				
				//else if (Splitstring[3].equalsIgnoreCase(RuleRejectIfAttributeNotValuated))	
			}
				
			if ("LCLoad".equalsIgnoreCase(currentAction))
			{
			
				%>
				<script>		

				var indexIDs="";
				
				if ("<%=InfotoAdd%>"=="ALL")
				{
					for (var j=0; j<SupportedTypes.length; j++)
					{
						AlreadyUsedChecks[iRulesCounter]="<%=idString%>"+SupportedTypes[j]+"ALL";
						//alert(AlreadyUsedChecks[iRulesCounter]);
			
						if (j != (SupportedTypes.length-1))
							indexIDs+=iRulesCounter+",";
						else
							indexIDs+=iRulesCounter;

						iRulesCounter=iRulesCounter+1;			
					}
				}
				else
				{				
					if ("<%=CurrentHandledCheck%>"=="RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")
					{		
						//var tempCheck="<=InfotoAdd>";2014x
						//var indexslash=tempCheck.indexOf("/");
						//var infotosave=tempCheck.substring(0,indexslash);
						var infotosave="<%=InfotoAdd%>";
				
						AlreadyUsedChecks[iRulesCounter]="<%=idString%>"+infotosave+"ALL";
						indexIDs=iRulesCounter;					
						iRulesCounter=iRulesCounter+1;
					}
					else
					{		
						AlreadyUsedChecks[iRulesCounter]="<%=idString+InfotoAdd%>";
						indexIDs=iRulesCounter;
						iRulesCounter=iRulesCounter+1;
					}
				}		
	
			</script>			
			<%
			
			}//if ("LCLoad" ...
			
			String typeNonNLS = Splitstring[0];		
						
			TypeCustoDescription currType = myLifeCycleHandler.getTypeDescription(typeNonNLS,currentPolicy);
			
			if (typeNonNLS.equalsIgnoreCase("Part"))
				Splitstring[0]=CommonPartLabel;
			else
			{
				//	Splitstring[0] = myNLS.getMessage(currType.getTypeNLSKey());
				ParameterizationNLSCatalog currNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, currType.getNLSFileName());
				Splitstring[0] = currNLSCatalog.getMessage(currType.getTypeNLSKey());		
			}
						
			fStatus = "";	
			String remBehave="";		
			String removeBehavior="<img src=\"images/buttonDialogSubGray.gif\" style=\"cursor:pointer\" title=\"remove\" onclick=\"deleteLCheckRow(this.parentNode.parentNode.rowIndex)\">";
				
			if (Splitstring[5].equalsIgnoreCase("false"))
			{
				removeBehavior="<img src=\"images/buttonDialogSubOrangeDB.gif\" style=\"cursor:pointer\" title=\""+NotYetDeployedTitle+", remove\" onclick=\"deleteLCheckRow(this.parentNode.parentNode.rowIndex)\">";
				remBehave="NotDeployed";
			}
			else
			{
				removeBehavior="<img src=\"images/buttonDialogSubGray.gif\" style=\"cursor:pointer\" title=\""+DeployedTitle+"\" onclick=\"deleteLCheckRow(this.parentNode.parentNode.rowIndex)\">";
				remBehave="Deployed";
			}
			
			String RuletoStock = typeNonNLS+":"+Splitstring[1]+":"+Splitstring[2]+":"+CurrentHandledCheck+":"+Splitstring[4];	
			//out.println(RuletoStock);
			
			//filtering by policy
			if (handledTypesforPolicy.indexOf(typeNonNLS) >=0 )
			{					
				%>
				<script>					
				var i_State_Source = getStateInStructFromStateName("<%=Splitstring[1]%>");
				var i_State_Target = getStateInStructFromStateName("<%=Splitstring[2]%>");
				
				if ( ( i_State_Source != -1)&& (i_State_Target != -1) )
				{
					//State that is not available in the policy : (e.g. case Dev Part / EC Part)					
					var iSourceNLS = graphStatesArray[i_State_Source].userStateName;
					var iTargetNLS = graphStatesArray[i_State_Target].userStateName;
					
					if (currentActionLC == "LCLoad")
						BuildInitialTable(indexIDs,"<%=typeNonNLS%>","<%=Splitstring[0]%>",
								"<%=Splitstring[1]%>",iSourceNLS,
								"<%=Splitstring[2]%>",iTargetNLS,
								"<%=CurrentHandledCheck%>","<%=Splitstring[3]%>",
								"<%=Splitstring[4]%>","<%=iAdditionalInfotoShow%>",
								"<%=remBehave%>");
				}
				else
				{
					//stocker				 
					iChecksListBuffer[iChecksListCounter] ="<%=RuletoStock%>";		
					iChecksListCounter++;
				}
				</script>			
				<%			
			}
			else
			{
				//stocker			
				 %>
				<script>
				iChecksListBuffer[iChecksListCounter] ="<%=RuletoStock%>";	
				iChecksListCounter++;
				 </script>			
				<%				
			}					
		}
	
	}
	
	//}//of currentAction == LCLoad
		
	%>   

 		<script> 	
		if (typeDescriptorArray.length>0)
		{
			BuildTypesList();
			UpdateLifeCycleCheckList(document.getElementById("ObjectTypeId").options[0].value);
		}
		else
		{
			document.getElementById("ObjectTypeId").disabled=true;
			document.getElementById("ChosenCheck").disabled=true;
			document.getElementById("buttonadd").onclick = function() { alert("<%=lifecyleChecksNotSupported%>");};
			document.getElementById("buttonadd").title = "<%=lifecyleChecksNotSupported%>";
		}
 		handleComplementaryAspects(); 		
 		</script>	
 			
 	</table>
 	
 	
 </div>
 <script>addFooter("javascript:DeployParams('nofreeze')","images/buttonDialogApply.gif","<%=Deploycmd%>","<%=DeployTitle%>",null,null,null,null,"javascript:ResetInSession()","images/buttonDialogCancel.gif","<%=Resetcmd%>","<%=ResetTitle%>","<%=displayhidecontrol%>");</script>
 </body>
 

</html>
