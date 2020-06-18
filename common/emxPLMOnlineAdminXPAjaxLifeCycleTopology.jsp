<% response.setContentType("text/xml");
   response.setContentType("charset=UTF-8");
   response.setHeader("Content-Type", "text/xml");
   response.setHeader("Cache-Control", "no-cache");
   response.getWriter().write("<?xml version='1.0' encoding='iso-8859-1'?>");
%>
<%--
//@fullReview  ZUR 11/09/05 HL Lifecycle Custo
//@quickReview ZUR 12/06/15 HL Light Enhancements for error handling
--%>

<%-- com.matrixone.vplm.PromotionRulesHandle.PromotionRulesHandle 
     com.matrixone.vplm.TeamAttributeCustomize.TeamAttributeCustomize --%>
<%@ page import ="com.matrixone.vplm.LifecycleTopology.LifecycleCustoHandler"%>
<%@ page import ="com.matrixone.vplm.LifecycleTopology.StateCustoExchange"%>
<%@ page import ="com.matrixone.vplm.LifecycleTopology.TransitionCustoExchange"%>

<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
		
<%
String finalNameString="<root>";
String iPolicy=emxGetParameter(request,"oPolicy");

String requestCommand = emxGetParameter(request,"requestCommand");
int nbofStates =Integer.parseInt(emxGetParameter(request,"iNbofStates"));

LifecycleCustoHandler lifeCycleHandlerSend = new LifecycleCustoHandler(context);
StateCustoExchange[] listExcStates = null;

if ("DeployAll".equalsIgnoreCase(requestCommand))
{
	
	String deployRes	= "S_OK";
	String deployResLog = ""; 
	
	if (nbofStates>0)
	{
		
		listExcStates = new StateCustoExchange[nbofStates];
		
		for (int i=0; i<nbofStates; i++)
			listExcStates[i] = new StateCustoExchange();

		for (int i=0; i<nbofStates; i++)
		{	
			String stateSysName ="";
			String stateUserName ="";
			boolean isEnabled=true;
			boolean isCritical=false;
		
			stateSysName=emxGetParameter(request,"oStateSysName_"+String.valueOf(i));
			stateUserName=emxGetParameter(request,"oStateUserName_"+String.valueOf(i));
			isEnabled=Boolean.parseBoolean(emxGetParameter(request,"oisStateEnabled_"+String.valueOf(i)));
			isCritical=Boolean.parseBoolean(emxGetParameter(request,"oisStateCritical_"+String.valueOf(i)));
						
			listExcStates[i].setPolicy(iPolicy);
			listExcStates[i].setStateSysName(stateSysName);
			listExcStates[i].setStateUserName(stateUserName);
			listExcStates[i].setEnabled(isEnabled);
			listExcStates[i].setCritical(isCritical);		
		}
	
		int iRet = lifeCycleHandlerSend.setStates(context, listExcStates);
			
		if (iRet!=0)
		{
			deployRes	 = "E_Fail";
			deployResLog = "Problem with the Modify States Step !";
		}			
	
		int nbofTransitions =Integer.parseInt(emxGetParameter(request,"oNbofTransitions"));	
	
		if (nbofTransitions>0)
		{
		
			TransitionCustoExchange[] listExcTransitions = new TransitionCustoExchange[nbofTransitions];
		
			for (int i=0; i<nbofTransitions; i++)
				listExcTransitions[i] = new TransitionCustoExchange();
		
			String transitionName="";
			String transitionSourceState="";
			String transitionTargetState="";
			boolean isTransitionCritical=false;
				
			for (int i=0; i<nbofTransitions; i++)
			{			
			
				transitionSourceState=emxGetParameter(request,"oTransitionSourceState_"+String.valueOf(i));
				transitionTargetState=emxGetParameter(request,"oTransitionTargetState_"+String.valueOf(i));
				transitionName=emxGetParameter(request,"oTransitionName_"+String.valueOf(i));
				isTransitionCritical=Boolean.parseBoolean(emxGetParameter(request,"oTransitionCritical_"+String.valueOf(i)));
			
				listExcTransitions[i].setTransitionName(transitionName); 
				listExcTransitions[i].setPolicy(iPolicy);
				listExcTransitions[i].setSourceStateName(transitionSourceState); 
				listExcTransitions[i].setTargetStateName(transitionTargetState);
				listExcTransitions[i].setCritical(isTransitionCritical);
		
			}
		
			iRet = lifeCycleHandlerSend.setTransitions(context, listExcTransitions);
							
			if (iRet!=0)
			{
				deployRes	 = "E_Fail";
				deployResLog += "\n"+"Problem with the Modify Transitions Step !";
			}			
		
		}

	}	

	int nbrule =Integer.parseInt(emxGetParameter(request,"iRulesSize"));

	//if (nbrule>0)
	//{	
	String checkRule="";
	StringList iList=null;
	String iprefix="iRules_";
	String retmessageRules="";	

	iList= new StringList();
	
	for (int i=2; i<=(nbrule+1); i++)
	{
		iprefix=iprefix+String.valueOf(i);
		
		checkRule=emxGetParameter(request,iprefix);
		iList.addElement(checkRule);
			
		iprefix="iRules_";		
	}
	
	int irulesret=0;
	
	/*PromotionRulesHandle iRulesPromo = new PromotionRulesHandle();	
	irulesret = iRulesPromo.LoadCheckParamsFromUI(iList,context);*/
	
	irulesret = lifeCycleHandlerSend.setLifecycleChecks(iList,context,iPolicy);
	
	if (irulesret != lifeCycleHandlerSend.S_OK)
	{
		deployRes	 = "E_Fail";
		deployResLog += "\n" + "Problem with the Deploy Lifecycle Checks Step!";
	}

	
	finalNameString=finalNameString+"<DeployResult>"+deployRes+"</DeployResult>";
	finalNameString=finalNameString+"<DeployResultLog>"+deployResLog+"</DeployResultLog>";
	
	//finalNameString=finalNameString+"<nbRuleSet>"+retmessageRules+"</nbRuleSet>";
	
	//}

}
else if ("CheckForBOinStates".equalsIgnoreCase(requestCommand))
{
	
	String stateContainsBO="false";
	String stateNamesBO="";
		
	if (nbofStates>0)
	{	

		String[] listofStates = new String[nbofStates];
		
		for (int i=0; i<nbofStates; i++)
			listofStates[i] = new String();		
		
		for (int i=0; i<nbofStates; i++)
		{	
			String stateSysName ="";		
			stateSysName=emxGetParameter(request,"oStateSysName_"+String.valueOf(i));			
			listofStates[i] = stateSysName;
		}

		//call			
		String[] listofPOStates = lifeCycleHandlerSend.checkDBforBOinStates(context,iPolicy,listofStates);
				
		if (listofPOStates != null)
		{			
			if (listofPOStates.length > 0)
			{									
				for (int i=0; i<listofPOStates.length; i++)
				{						
					if (!("".equalsIgnoreCase(listofPOStates[i])))
					{					
						if ("".equalsIgnoreCase(stateNamesBO))
							stateNamesBO = listofPOStates[i];
						else
							stateNamesBO += ","+listofPOStates[i];
						
						stateContainsBO = "true";
					}
				}				
			}
		}
		
		
	}
	
	
	finalNameString=finalNameString+"<BOinStates>"+stateContainsBO+"</BOinStates>";//
	finalNameString=finalNameString+"<StatesContaingBO>"+stateNamesBO+"</StatesContaingBO>";
		
	
}

finalNameString = finalNameString+"</root>";

response.getWriter().write(finalNameString);


%>
