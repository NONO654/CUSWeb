<html>
<head>

<!--
//@fullReview  ZUR 10/11/05 HL XP Params Enhancements V6R2012 - Split from emxPLMOnlineAdminXPParamDataAccess.jsp
//@quickReview ZUR 10/11/30 Integrating "addTransparentLoadingInSession" while deploying parameters
//@quickReview ZUR 11/01/10 IR-086945V6R2012 - Rollback to 1,2,3 
//@fullReview ZUR  11/04/05 - HL 2012x  All Params in DB
//@quickReview ZUR 12/02/03 - IR-151856V6R2013 - handling ENG restriction for Dev and Prod Part Naming (should not be the same)
//@fullReview ZUR  12/02/27 - HL 2013x - Moving to param infra 2.1
//@quickReview ZUR 12/11/16 - IR-199560V6R2014 && IR-199577V6R2014
//@quickReview ZUR 12/12/12 - IR-203385V6R2014
//@quickReview ZUR 12/12/21 - IR-207199V6R2014
//@quickReview ZUR 13/01/10 - IR-208517V6R2014
//@quickReview ZUR 13/11/05 - IR-260338V6R2014x
//@quickReview ZUR 14/05/22 - IR-300845-3DEXPERIENCER2015x - Change of Revision naming is not possible
//@quickReview ZUR 14/07/28 - IR-315943-3DEXPERIENCER2015x
//@quickReview ZUR 14/08/04 - IR-308845-3DEXPERIENCER2015x - +/Space/>
-->

		<link rel=stylesheet type="text/css" href="styles/emxUIDOMLayout.css">
		<link rel=stylesheet type="text/css" href="styles/emxUIDefault.css">
		<link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css">   
		<link rel=stylesheet type="text/css" href="styles/emxUIParamOnline.css"> 
        
		<%@ page import="com.dassault_systemes.vplmposadminservices.HtmlCatalogHandler" %> 
		<%@ page import="java.util.*"%>  
		<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.PreferencesUtil" %>	
		<%@ page import="com.matrixone.vplm.FreezeServerParamsSMB.FreezeServerParamsSMB"%>
		<%@ page import ="com.matrixone.vplm.applicationsIntegrationInfra.AppIntUIConnector"%>
		<%@ page import ="com.matrixone.vplm.parameterizationUtilities.NLSUtilities.ParameterizationNLSCatalog"%>
		<%@ page import ="com.dassault_systemes.ootbConfiguration.deployment.impl.ObjectAutonamingFormat"%>
		
			

		<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
		<script src="scripts/emxUIAdminConsoleUtil.js" type="text/javascript"></script>
		<script src="scripts/expand.js" type="text/javascript"></script> 
				
		<%@include file = "../common/emxNavigatorInclude.inc"%>
		<%@include file = "../emxTagLibInclude.inc"%>
		
		<script>
		  
		var sepSequence = new Array();
		
		var listofPolicies 	= new Array();
		var listofSequences = new Array();	
		var listofPreviewSequences = new Array();
		
		function structBuilder(fields) 
		{
			var fields = fields.split(',');
			var count = fields.length;
			
			function constructor() 
			{
				for (var i = 0; i < count; i++)
					this[fields[i]] = arguments[i];
			}
			return constructor;
		}
					
		var policyNaming 		= structBuilder("policyID,initalValue,defaultValue");
		var sequenceObj			= structBuilder("sequenceID,sequenceNLS,sequenceTootip");
		var sequenceSep			= structBuilder("sequenceID,sequenceNLS,sequenceTootip,sequenceIDChar");
		var namingElement		= structBuilder("namingID,initialValue,defaultValue,currentValue");	
		var custoNamingElement  = structBuilder("objTypeID,prefix,suffix,defprefix,defsuffix,appType,deploySts");
		var warningLabel		= structBuilder("warnID","warnRaised");
		
		/*
		var sepCompatibilityArray = [["Dash","-"],
		                             ["Under_Score","_"],
		                             ["Space"," "],
		                             ["Empty",""]];	*/
		
		var custoNamingsArray 	= new Array(); 
		var warnArrays 			= new Array();
		var forbiddenNamings	= new Array();	
		
		<%		 
		Locale currentLocale = request.getLocale();
		//Context ctx = Framework.getFrameContext(session);
		
		ParameterizationNLSCatalog myNLS = new ParameterizationNLSCatalog(context, currentLocale, "myMenu");
		
		String Freezemessage	= myNLS.getMessage("Freezemessage");
		String Confirmfreeze  	= myNLS.getMessage("Confirmfreeze");
		String Freezesuccess  	= myNLS.getMessage("Freezesuccess");
		String Freezefailure  	= myNLS.getMessage("Freezefailure");
		String Deploysuccess  	= myNLS.getMessage("Deploysuccess");
		String Deployfail 		= myNLS.getMessage("Deployfail");
		String Deploycmd 		= myNLS.getMessage("Deploycmd");
		String Resetcmd 		= myNLS.getMessage("Resetcmd");
		String ResetTitle 		= myNLS.getMessage("ResetTitle");	  	
 		String NotYetSaved 		= myNLS.getMessage("NotYetSavedParameter");
		String DeployTitle 		 = myNLS.getMessage("DeployTitle");
		String DeployedParameter = myNLS.getMessage("DeployedParameter");
		String NotYetDeployedParameter = myNLS.getMessage("NotYetDeployedParameter");		 
		String NonAppropriateContext	= myNLS.getMessage("NonAppropriateContext");
		String NonAppropriateSolution	= myNLS.getMessage("NonAppropriateSolution");	
			 
		String policyTypeTitle 		= myNLS.getMessage("policyTypeTitle");
		String CurrentpolicyTitle 	= myNLS.getMessage("currentPolicyTitle");		 
		String PartUnicityMessage  	= myNLS.getMessage("PartUnicityMessage");
		String SpecialCharactersMessage = myNLS.getMessage("SpecialCharactersMessage");
		String typesForbiddenMessage =  myNLS.getMessage("typesForbiddenMessage");
		String CheckForRaisedWarningsMsg =  myNLS.getMessage("CheckForRaisedWarningsMsg");
		
		String selectTypeTitle		= myNLS.getMessage("selectTypeTitle");
		String prefixTitle 			= myNLS.getMessage("prefixTitle");
		String suffixTitle 			= myNLS.getMessage("suffixTitle");
		String typeIdentifierFormat = myNLS.getMessage("typeIdentifierFormat");		
		String affixDefineTooltip = myNLS.getMessage("affixDefineTooltip");//IR-207199V6R2014
	 		 		  
		//Retrieves the "Freeze parameter" status of the current command
		FreezeServerParamsSMB Frz = new FreezeServerParamsSMB();	

		int iret=0;
		String fStatus = "";		
		iret = Frz.GetServerFreezeStatusDB(context,"APPXPParametrizationDataIdentification");

		if (iret == Frz.S_FROZEN)	
			fStatus = "disabled";
		
		String currentcontext = context.getRole();

		String admincontext="VPLMAdmin";
		String displayhidediv ="block";
		String displayhidecontrol="none";
		
		/*ZUR Testing the Current Solution :
		The Administration console will be accessible *only if* the Current Solution is TEAM */
		String CurrentUISolution="";
		PreferencesUtil utilpref = new PreferencesUtil();
		CurrentUISolution =   utilpref.getUserPreferredUISolution(context);		
		
		if (CurrentUISolution.equalsIgnoreCase("TEAM")==false)
			NonAppropriateContext = NonAppropriateSolution;
				
		if ( ( currentcontext.indexOf(admincontext) >=0) && ( CurrentUISolution.equalsIgnoreCase("TEAM")) ) 
		{
			displayhidediv ="none";
			displayhidecontrol="block";
		}				 
			      
        int iAffixIndex=0, iVNamingIndex = 0;
        String title_divVN	 	 = "";
        String tooltip_divVN 	 = "";            
        String title_divNaming 	 = "";
        String tooltip_divNaming = "";            
        
		AppIntUIConnector IDentUIConnector = new AppIntUIConnector(context);        	
        AppIntUIConnector.IExchangeDomain identificationDomain = IDentUIConnector.getDomain("ObjectIdentification");           	
        AppIntUIConnector.IExchangeFamily[] identificationFamilies = identificationDomain.getFamilies();       
    
        ParameterizationNLSCatalog baseNLS = new ParameterizationNLSCatalog(context, currentLocale, "emxVPLMAdministrationStringResource");        
        
		for (int i=0; i<identificationFamilies.length; i++)
		{			
			if ("VersionNaming".equals(identificationFamilies[i].getID()))
			{
				iVNamingIndex = i;			
				title_divVN = baseNLS.getMessage(identificationFamilies[i].getNLSKey());
				tooltip_divVN = baseNLS.getMessage(identificationFamilies[i].getTooltipNLSKey());	
								
				/* IR-208517V6R2014
				ParameterizationNLSCatalog VNNLSCatalog = new ParameterizationNLSCatalog(ctx, currentLocale, identificationFamilies[i].getNLSFileName());				
				title_divVN	  = VNNLSCatalog.getMessage(identificationFamilies[i].getNLSKey());
				tooltip_divVN = VNNLSCatalog.getMessage(identificationFamilies[i].getTooltipNLSKey());*/		   		
			}
			else if ("ObjectIdentifier".equals(identificationFamilies[i].getID()))
			{
				iAffixIndex = i;
				title_divNaming = baseNLS.getMessage(identificationFamilies[i].getNLSKey());
				tooltip_divNaming = baseNLS.getMessage(identificationFamilies[i].getTooltipNLSKey());
				
				/* IR-208517V6R2014
				ParameterizationNLSCatalog NamingCatalog = new ParameterizationNLSCatalog(ctx, currentLocale, identificationFamilies[i].getNLSFileName());
				title_divNaming	  = NamingCatalog.getMessage(identificationFamilies[i].getNLSKey());
				tooltip_divNaming = NamingCatalog.getMessage(identificationFamilies[i].getTooltipNLSKey());*/     						
			}				
		}
		
		//Naming Parameters		
		AppIntUIConnector.IExchangeParameter[] vCustoNamingParamsList = identificationFamilies[iAffixIndex].getParameters();
    	           	
		//IdentifierAffix
		int iAffix = 0; 
		
		for (int i=0; i<vCustoNamingParamsList.length; i++)
		{
			String rParamID = vCustoNamingParamsList[i].getID();		
			
			if ("IdentifierAffix".equalsIgnoreCase(rParamID))
				iAffix = i;			
		}
					
		//Affix Parameter 
		
		//Separator
				
		ParameterizationNLSCatalog pAffNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, vCustoNamingParamsList[iAffix].getNLSFileName());
    	              		
      	String affixID = vCustoNamingParamsList[iAffix].getID();
      	
      	String commonParamID = vCustoNamingParamsList[iAffix].getID();
      		
      	boolean isAffixDeployed  = vCustoNamingParamsList[iAffix].isDeployed();
      	
      	String affixUI = pAffNLSCatalog.getMessage(vCustoNamingParamsList[iAffix].getNLSKey());
        String affixTooltip = pAffNLSCatalog.getMessage(vCustoNamingParamsList[iAffix].getTooltipNLSKey());
      	          
        
    	AppIntUIConnector.IExchangeArgument[] namingAffixArgs = vCustoNamingParamsList[iAffix].getArguments();
    	
    	String currentAffixValue = namingAffixArgs[0].getValue();
    	String defaultAffixValue = namingAffixArgs[0].getDefault();
    	
    	String currSeparatorVal = namingAffixArgs[1].getValue();
    	String defSeparatorVal = namingAffixArgs[1].getDefault();
    	String separatorID = namingAffixArgs[1].getID();
    	
		String separatorNLS = "Separator";
		String separatorTooltip = "Naming Separator";
    	
    	for (int i=0; i<namingAffixArgs.length; i++)
    	{
    		if ("AffixArg".equals(namingAffixArgs[i].getID()))
    		{    		                   
    			currentAffixValue = namingAffixArgs[i].getValue();
        		defaultAffixValue = namingAffixArgs[i].getDefault();
        		affixID = namingAffixArgs[i].getID();
    		}
    		else if ("SeparatorArg".equals(namingAffixArgs[i].getID()))
    		{
    		 	currSeparatorVal = namingAffixArgs[i].getValue();
    		 	defSeparatorVal = namingAffixArgs[i].getDefault();
    	    	separatorID = namingAffixArgs[i].getID();   	    	
    	        	
    	    	separatorNLS = pAffNLSCatalog.getMessage(namingAffixArgs[i].getNLSKey());
    	    	separatorTooltip = pAffNLSCatalog.getMessage(namingAffixArgs[i].getTooltipNLSKey());
    	    	
                String[] argValList    = namingAffixArgs[i].getValuesList();                
                String[] argNLSKeyList = namingAffixArgs[i].getValuesNLSKeyList();
                
                String[] sepTooltipList = new String[argValList.length];
                String[] sepValuesListNLS  = new String[argValList.length];   
                
                for (int j=0; j<argNLSKeyList.length; j++)
                {
    				//argValuesNLSList[j] = IDentUIConnector.getProperty("ShortSequence_" + argValuesList[j]);
    				//argListNLSTooltip[j] = IDentUIConnector.getProperty("LongSequence_" + argValuesList[j]);
    				//if (argValuesNLSList[j] == null || argListNLSTooltip[j] == null)
    				sepValuesListNLS[j] = pAffNLSCatalog.getMessage(argNLSKeyList[j]); 
    				sepTooltipList[j] = pAffNLSCatalog.getMessage(argNLSKeyList[j]+".tooltip");
                }
               
                
                String cteVal = "-";
                
            	for (int j=0; j<argValList.length; j++)
                {              		           		
            		//AppIntUIConnector.IExchangeConstant matchCte =  namingAffixArgs[i].getConstant(argValList[j]);
            		AppIntUIConnector.IExchangeConstant matchCte =  vCustoNamingParamsList[iAffix].getConstant(argValList[j]);            		
            		cteVal = matchCte.getValue();               	
                	%>            	
                	//alert("adding"+"<=argValList[j]>"+"pour "+"<=cteVal>");  
                	//		 adding 	Colon 			 pour      :
                	//var charSessionVal = getSepCharacterVal("<=argValList[j]%>");  
                	//new sequenceObj("Dash","-","the Dash");                	
                	//sepSequence[sepSequence.length]=new sequenceObj("<=cteVal%>","<=sepValuesListNLS[j]%>","<=sepTooltipList[j]%>");
                	
                	sepSequence[sepSequence.length]=new sequenceSep("<%=argValList[j]%>","<%=sepValuesListNLS[j]%>","<%=sepTooltipList[j]%>","<%=cteVal%>");
                	<%            		
                }    			
                  	    	
    		}
    	}  	    	
    	    	    	    	
    	//UI Issues : IR-199560V6R2014
    	if ("TBD".equals(currentAffixValue))
    		currentAffixValue = "";
    	
    	if ("TBD".equals(defaultAffixValue))
    		defaultAffixValue = "";   	
    		    	
		%>
  		
		var xmlreqs = new Array();			
		var currentfreeze="<%=fStatus%>";			
				
		var affixContainer 	   = new namingElement("<%=affixID%>","<%=currentAffixValue%>","<%=defaultAffixValue%>","<%=currentAffixValue%>");
		var separatorContainer = new namingElement("<%=separatorID%>","<%=currSeparatorVal%>","<%=defSeparatorVal%>","<%=currSeparatorVal%>");
		
			     
		
		function appendSequencetoLists(_sequenceID,_sequenceNLS,_sequenceTootip)
		{		
			
			for (var i=0; i<listofSequences.length; i++)		
				if ( listofSequences[i].sequenceID == _sequenceID)
					return;
			
			listofSequences[listofSequences.length]=new sequenceObj(_sequenceID,_sequenceNLS,_sequenceTootip);
		}				
	
		var AffixForbiddenChars = "!#$%^&*()+=[]\\\';,/{}|\":<>?";//-
		
		warnArrays[0] = new warningLabel("sitenameinput",false);
		warnArrays[1] = new warningLabel("prefixInput",false);
		warnArrays[2] = new warningLabel("suffixInput",false);
	
		function testSpecialCharacters(iString)
		{
			//var iChars = "!#$%^&*()+=-[]\\\';,/{}|\":<>?";
			//+=-!#$%^&*()[]\\\\';,/{}|\\":>?
					
			var iChars =AffixForbiddenChars;

			for (var i = 0; i < iString.length; i++)						
				if (iChars.indexOf(iString.charAt(i)) != -1)	
			  		return true;
			
			return false;		
		}
		
		
		function testTypeNamings(iString)
		{
			
			var selectedType = document.getElementById("iTypeSelect").options[document.getElementById("iTypeSelect").options.selectedIndex].value;			
			var iI = getIndexInNamingArray(selectedType);				
			var currAppType = custoNamingsArray[iI].appType;
			
			if (currAppType == "VPM")
			{
				for (var i = 0; i < forbiddenNamings.length; i++)
					if (iString.indexOf(forbiddenNamings[i]) != -1)
						return true;
			}
			
			return false;
			
		}
		
				
		//	ZUR - IR-151856V6R2013				
		function testPartVersioningUnicity()
		{			
			var iPolicyID,iPolicyNaming;
			//var ProductionPartNaming,DevelopmentPartNaming;//IR-300845-3DEXPERIENCER2015x
			var ProductionPartNaming = "initvalx";
			var DevelopmentPartNaming = "initvaly";
			
			var tablesize=document.getElementById('VersionNamingTable').rows.length;
			

			for (var i=1; i<tablesize ; i++)
			{				
				iPolicyID = document.getElementById('VersionNamingTable').rows[i].cells[0].value;						
				iPolicyNaming = document.getElementById('comboNaming_'+i).options[document.getElementById('comboNaming_'+i).options.selectedIndex].value;
				
				if (iPolicyID=="VNaming_ProductionPart")
					ProductionPartNaming = iPolicyNaming;
				
				if (iPolicyID=="VNaming_DevelopmentPart")
					DevelopmentPartNaming = iPolicyNaming;
			}	
			
			if (ProductionPartNaming == DevelopmentPartNaming)
				return false;
			else
				return true;			
		}	

		// ZUR : Deploys the parameters : emxPLMOnlineAdminXPApplicationsAjax.jsp
		function DeployParams(iInput)
		{			
			if (currentfreeze == "disabled" )
				alert("<%=Freezemessage%>");
			else
			{
				var srvsend = "";
				var cont="no";

				if (iInput!="freezecmds")				
					srvsend=srvsend+"&frzStatus=false";					
				else if (iInput=="freezecmds")
				{
					if (confirm ("<%=Confirmfreeze%>"))
					{
						cont="yes";
						srvsend=srvsend+"&frzStatus=true";
					}
				}
				
				if (  (cont=="yes") || (iInput!="freezecmds"))
				{
					var oSiteName=document.getElementById('sitenameinput').value;
					var tablesize=document.getElementById('VersionNamingTable').rows.length; 
			
					
					if (CheckforRaisedWarnings() != "OK")
					{
						
						alert("<%=CheckForRaisedWarningsMsg%>");//SpecialCharactersMessage
						return;
					}
								
					/*
					if (testSpecialCharacters(oSiteName)==true)
					{
						alert("<=SpecialCharactersMessage%>");
						return;
					}*/					
					
					if (testPartVersioningUnicity() == false)
					{
						alert("<%=PartUnicityMessage%>");
						return;					
					}
					
					srvsend=srvsend+"&domainID=ObjectIdentification";

					if (oSiteName=="")
						oSiteName="TBD";	
							
					//IdentifierAffix
					
					srvsend=srvsend+"&iParamID_0="+"<%=commonParamID%>";
					srvsend=srvsend+"&nbOfArguments_0=2";
					srvsend=srvsend+"&iArgumentID_0_0=AffixArg";
					srvsend=srvsend+"&iArgumentValue_0_0="+oSiteName;
							
					var iSelSep = document.getElementById('selectSeparator').options[document.getElementById('selectSeparator').options.selectedIndex].value;
					
					//var paramModelVal = getSepLiteralVal(iSelSep);					
					srvsend=srvsend+"&iArgumentID_0_1=SeparatorArg";
					srvsend=srvsend+"&iArgumentValue_0_1="+iSelSep;														
					
					var iPolicyID,iPolicyNaming;			 

					for (var i=1; i<tablesize ; i++)
					{				
						iPolicyID = document.getElementById('VersionNamingTable').rows[i].cells[0].value;						
						iPolicyNaming = document.getElementById('comboNaming_'+i).options[document.getElementById('comboNaming_'+i).options.selectedIndex].value;						
						srvsend=srvsend+"&iParamID_"+i+"="+iPolicyID;
						srvsend=srvsend+"&nbOfArguments_"+i+"=1";
						srvsend=srvsend+"&iArgumentID_"+i+"_0=Argument";
						srvsend=srvsend+"&iArgumentValue_"+i+"_0="+iPolicyNaming;
					}
					
					var j=tablesize;
					
					for (var i=0; i<custoNamingsArray.length; i++)
					{
						srvsend=srvsend+"&iParamID_"+j+"="+custoNamingsArray[i].objTypeID;
						srvsend=srvsend+"&nbOfArguments_"+j+"=2";
						srvsend=srvsend+"&iArgumentID_"+j+"_0=PrefixArg";
						
						/*
						if (custoNamingsArray[i].appType == "CBP")
						{
							var iSentPrefix = custoNamingsArray[i].prefix;//+"::"+oSiteName;
							srvsend=srvsend+"&iArgumentValue_"+j+"_0="+iSentPrefix;
						}
						else//VPM					
							srvsend=srvsend+"&iArgumentValue_"+j+"_0="+custoNamingsArray[i].prefix;
						*/
						
						srvsend=srvsend+"&iArgumentValue_"+j+"_0="+custoNamingsArray[i].prefix;
						
						srvsend=srvsend+"&iArgumentID_"+j+"_1=SuffixArg";
						srvsend=srvsend+"&iArgumentValue_"+j+"_1="+custoNamingsArray[i].suffix;
						j++;					
					}						
					
					var nbofSentParams = tablesize+custoNamingsArray.length;
			 	
					srvsend=srvsend+"&numberbofSentParams="+nbofSentParams;//1+(tablesize-1)				

					if (iInput=="nofreeze")
 			   			srvsend=srvsend+"&iDeployType=StoreAndDeploy";
 					else if(iInput=="save")
 						srvsend=srvsend+"&iDeployType=StoreOnly";
						
					srvsend=srvsend+"&iSourceJSP=DataIdentification";					
					//alert(srvsend);				
					
					document.getElementById('LoadingDiv').style.display='block';
					document.getElementById('divPageFoot').style.display='none';								

	            	xmlreq("emxPLMOnlineAdminXPIdentificationAjax.jsp",srvsend,DeployParamsRet,0);
	            }
			}
		}
	
		function DeployParamsRet()
		{
			var xmlhttpfreeze = xmlreqs[0];      
		    var freeze_res;

            if(xmlhttpfreeze.readyState==4)
            {
            	var paramStatusDeploy="S_OK";//Deploy status of parameters
				var usermessage="";
				var tablesize=document.getElementById('VersionNamingTable').rows.length; 

				document.getElementById('LoadingDiv').style.display='none';	
				document.getElementById('divPageFoot').style.display='block';			
				
				var ParamsRet =xmlhttpfreeze.responseXML.getElementsByTagName("ParamsAppsSet");
	
				if (ParamsRet.item(0)!=null)
				{
					if (ParamsRet.item(0).firstChild.data =="S_OK")
					{
						document.getElementById("buttonAddSite").innerHTML='<img src=\"images/iconLicenseAvailable.gif\" title="'+"<%=DeployedParameter%>"+'" >';
						document.getElementById("nameDeployIndicator").innerHTML='<img src=\"images/iconLicenseAvailable.gif\" title="'+"<%=DeployedParameter%>"+'">';
					
						for (var i=1; i<tablesize ; i++)
						{	
	            			document.getElementById('VersionNamingTable').rows[i].cells[3].value=1;
							document.getElementById('VersionNamingTable').rows[i].cells[3].innerHTML="<img src=\"images/iconLicenseAvailable.gif\">";
							document.getElementById('VersionNamingTable').rows[i].cells[3].title="<%=DeployedParameter%>";	
						}
					}				
					else
						paramStatusDeploy="E_Fail";
				}
				else
					paramStatusDeploy="E_Fail";
				
				var freeze_res =xmlhttpfreeze.responseXML.getElementsByTagName("Freezeret");
				if (freeze_res.item(0)!=null)
				{     		            
					if (freeze_res.item(0).firstChild.data =="S_OK")
					{		
						currentfreeze = "disabled" ;			
						document.getElementById("sitenameinput").readOnly = true;					
			
						for (var i=1; i<tablesize ; i++)									
							document.getElementById("comboNaming_"+i).disabled=true;

						usermessage="<%=Freezesuccess%>";
					}
					else if (freeze_res.item(0).firstChild.data =="E_Internal")
						usermessage="<%=Freezefailure%>";
					else
						usermessage=freeze_res.item(0).firstChild.data;
				}
	
   				if (paramStatusDeploy=="S_OK")
            		usermessage=usermessage+"\n<%=Deploysuccess%>";
            	else
            		usermessage=usermessage+"\n<%=Deployfail%>";
            	            	
                alert(usermessage);  //Info/error message      		
            }	
		}

		//ZUR : This function resets the parameters in session
		function ResetInSession()
		{
			if (currentfreeze == "disabled" )
				alert("<%=Freezemessage%>");
			else
			{		
				var tablesize=document.getElementById('VersionNamingTable').rows.length; 
				
				for (var i=1; i<tablesize ; i++)
				{				
					var iPolicyID = document.getElementById('VersionNamingTable').rows[i].cells[0].value;
					var defaultVal; 
					
					for (var j=0; j<listofPolicies.length; j++)
						if (listofPolicies[j].policyID == iPolicyID)
							defaultVal = listofPolicies[j].defaultValue;		
			 		
					var listlength=document.getElementById("comboNaming_"+i).options.length;

					for (var j=0;j<listlength;j++)									
						if (defaultVal==document.getElementById("comboNaming_"+i)[j].value)
						{
							document.getElementById("comboNaming_"+i).selectedIndex = j;
							break;						
						}	
					
					UpdateLabelVersionInTable(i);
				}	
				
				//Affix
				affixContainer.currentValue = affixContainer.defaultValue;
				document.getElementById("sitenameinput").value=affixContainer.defaultValue;	
				
				CheckAffixValue();			
								
				var defaultSepId = getSepIDfromSepchar(separatorContainer.defaultValue);
				console.log("defaultSepId = "+defaultSepId);
				separatorContainer.currentValue = defaultSepId;
								
				var slistlen=document.getElementById("selectSeparator").options.length;

				for (var j=0;j<slistlen;j++)							
					if (defaultSepId==document.getElementById("selectSeparator")[j].value)
					{
						//if (separatorContainer.defaultValue
						document.getElementById("selectSeparator").selectedIndex = j;
						break;
					}
				
				
				//Prefixes and Suffixes
				for (i=0; i<custoNamingsArray.length; i++)
				{
					custoNamingsArray[i].prefix = custoNamingsArray[i].defprefix;
					custoNamingsArray[i].suffix = custoNamingsArray[i].defsuffix;
				}		
				
				//Updating View
				selectedTypeChanged();
						
				//Deploy Indicators
				document.getElementById("buttonAddSite").innerHTML='<img src=\"images/iconActionCreate.gif\" title="'+"<%=NotYetSaved%>"+'">';
				document.getElementById("nameDeployIndicator").innerHTML='<img src=\"images/iconActionCreate.gif\" title="'+"<%=NotYetSaved%>"+'">';
			}
		}
				
		function testonlineinputname()
		{
			var tSiteName=document.getElementById("sitenameinput").value;
						
			document.getElementById("buttonAddSite").innerHTML='<img src=\"images/iconActionCreate.gif\" title="'+"<%=NotYetSaved%>"+'">';
						
			if (testSpecialCharacters(tSiteName)==true)
			{	
				document.getElementById("sitenameinput").style.color="red";
				document.getElementById("labelwarning").style.color="red";
				document.getElementById("labelwarning").innerHTML="<%=SpecialCharactersMessage%>";
				
				document.getElementById("iTypeSelect").disabled=true;				
				warnArrays[0].warnRaised = true;
						
				
			}
			else
			{
				warnArrays[0].warnRaised = false;				
				document.getElementById(warnArrays[0].warnID).style.color="#070E14";
				
				var cSeparator = getSepValueForPreview();
				//document.getElementById('selectSeparator').options[document.getElementById('selectSeparator').options.selectedIndex].innerHTML;//.value;
								
				affixContainer.currentValue = tSiteName;			
				
				var selectedType = document.getElementById("iTypeSelect").options[document.getElementById("iTypeSelect").options.selectedIndex].value;			
				var iI = getIndexInNamingArray(selectedType);
				
				UpdateFinalFormatOverView(custoNamingsArray[iI].prefix,tSiteName,custoNamingsArray[iI].suffix, cSeparator, custoNamingsArray[iI].appType );
				
				if (CheckforRaisedWarnings() == "OK")
				{									
					document.getElementById("labelwarning").innerHTML="";
					//document.getElementById("sitenameinput").style.color="#070E14";					
					
					for (var i=0; i<warnArrays.length;i++)					
						document.getElementById(warnArrays[i].warnID).style.color="#070E14";
										
					document.getElementById("iTypeSelect").disabled=false;	
								
					//IR-207199V6R2014
					if (tSiteName == "")
					{
						document.getElementById("labelwarning").innerHTML="<%=affixDefineTooltip%>";
						document.getElementById("labelwarning").style.color="#157196";
					}
					else
						document.getElementById("labelwarning").innerHTML="";
					
					
				}			
				
			}
		}
			
		
		function onSeparatorChange()
		{
			testonlineinputname();
		}
							  
		function addObjectNamingLine(indi,iPolicyID,iPolicyCurrNaming,iDefaultNaming,iPolicyUI,iPolicyTooltip,isDeployed,iListofSequences)
		{
			listofPolicies[listofPolicies.length] = new policyNaming(iPolicyID,iPolicyCurrNaming,iDefaultNaming);
			
			var tempLabel; 
			var newRow = document.getElementById("VersionNamingTable").insertRow(-1);
			newRow.style.height="5";	

		 	var newCell = newRow.insertCell(-1);
		 	newCell.align = "left";
		 	newCell.className="MatrixFeelNxG";
		 	newCell.style.width="25%";
		 	newCell.title=iPolicyTooltip;
		 	newCell.innerHTML=iPolicyUI;
		 	newCell.value=iPolicyID;

		 	var newCell4 = newRow.insertCell(-1);
		 	newCell4.align = "left";
		 	newCell4.className="matrixFeel";
		 	newCell4.style.width="20%";			 	
		
		 	var selectSynch = document.createElement("select");
		 	selectSynch.id='comboNaming_'+indi;
			selectSynch.setAttribute("style", "width:200px");	
			if (document.all)//IE				
		 		selectSynch.style.setAttribute("cssText","width:200px;");			
			
		 	selectSynch.onchange = function() {UpdateLabelVersionInTable(indi);  };
		 	
			for ( var i=0;i<iListofSequences.length;i++)
			{				
				selectSynch.options[i] = new Option(iListofSequences[i].sequenceNLS,iListofSequences[i].sequenceID);
				selectSynch.options[i].title = iListofSequences[i].sequenceTootip;
				
				if (iListofSequences[i].sequenceID==iPolicyCurrNaming)
				{
					selectSynch.options[i].selected="selected";
					tempLabel = iListofSequences[i].sequenceTootip;
				}
			}			

			if (currentfreeze=="disabled")
		 		selectSynch.disabled=true;
		 						
		 	newCell4.appendChild(selectSynch);		 			 	

			var newCell5 = newRow.insertCell(-1);
		 	newCell5.align = "left";
		 	newCell5.className="MatrixFeelNxG";
		 	newCell5.style.width="35%";
		 	newCell5.innerHTML=tempLabel; 		 	 	

		 	var newCell6 = newRow.insertCell(-1);
		 	newCell6.align = "center";
		 	newCell6.className="MatrixFeelNxG";
		 	newCell6.style.width="20%";

		 	if (isDeployed==true)
		 	{
		 		newCell6.innerHTML='<img src=\"images/iconLicenseAvailable.gif\" title="'+"<%=DeployedParameter%>"+'">';  
		 		newCell6.value=1;
		 	} 		
		 	else
		 	{
		 		newCell6.innerHTML='<img src=\"images/iconSavedParameter.gif\" title="'+"<%=NotYetDeployedParameter%>"+'">';
		 		newCell6.value=2;
		 	}				
		}
			
		function UpdateLabelVersionInTable(indi)
		{	
			//var iPolicyID = document.getElementById('VersionNamingTable').rows[indi].cells[0].value;				
			var iNamingInd = document.getElementById('comboNaming_'+indi).options.selectedIndex;	
			document.getElementById('VersionNamingTable').rows[indi].cells[2].childNodes[0].data=document.getElementById('comboNaming_'+indi).options[iNamingInd].title;

			document.getElementById('VersionNamingTable').rows[indi].cells[3].innerHTML='<img src="images/iconActionCreate.gif">';			
			document.getElementById('VersionNamingTable').rows[indi].cells[3].title="<%=NotYetSaved%>";
			document.getElementById('VersionNamingTable').rows[indi].cells[3].value=0;
		}
		
		function addCustomNamingElement(iType,iTypeNLS,iPrefix,iSuffix,idefPrefix,idefSuffix,iObjType,iAppType,deploystatus,icount)
		{			
			//objTypeID,prefix,suffix,appType
			
			custoNamingsArray[icount]= new custoNamingElement(iType,iPrefix,iSuffix,idefPrefix,idefSuffix,iAppType,deploystatus);
			
			if (iAppType == "VPM")			
				forbiddenNamings[forbiddenNamings.length] = iObjType;
							
			var iNamingCombo = document.getElementById("iTypeSelect"); 
			
			iNamingCombo.options[icount] = new Option(iTypeNLS,iType);
			iNamingCombo.options[icount].title = iTypeNLS;	
			
			if (icount == 0)//initialization
			{				
				document.getElementById("prefixInput").value=iPrefix;
				document.getElementById("suffixInput").value=iSuffix;	
				
				UpdateFinalFormatOverView(iPrefix,affixContainer.initialValue,iSuffix,separatorContainer.initialValue, iAppType);
			}

			//ZUR IR-203385V6R2014
			if (deploystatus == "false")
				document.getElementById("nameDeployIndicator").innerHTML='<img src=\"images/iconSavedParameter.gif\" title="'+"<%=NotYetDeployedParameter%>"+'">';
									
		}
			
		/*
		function getSepCharacterVal(literalVal)
		{		
			for (var i=0; i<sepCompatibilityArray.length; i++)												
				if (literalVal == sepCompatibilityArray[i][0])					
					return sepCompatibilityArray[i][1];
									
			return literalVal;
		}
		
		function getSepLiteralVal(charVal)
		{		
			for (var i=0; i<sepCompatibilityArray.length; i++)												
				if (charVal == sepCompatibilityArray[i][1])					
					return sepCompatibilityArray[i][0];
									
			return charVal;
		}	*/					
		
		
		function handleSepatorIssues(separatorVal)
		{		
			//alert("handleSepatorIssues::"+separatorVal);						
			var selectSepObj = document.getElementById("selectSeparator");			
			//var charVal = getSepCharacterVal(separatorVal);
						
			selectSepObj.title="";
			selectSepObj.options.length = 0;	
			
			/*
			var sepList =  new Array();	
			sepList[0]=new sequenceObj("Dash","-","the Dash");
			sepList[1]=new sequenceObj("Under_Score","_","Under Score");
			sepList[2]=new sequenceObj("Space"," ","Simple Space");
			sepList[3]=new sequenceObj("Empty","","Naming Parts will be stacked");*/
			console.log("separatorVal = "+separatorVal);
							
			for ( var i=0; i<sepSequence.length; i++)
			{
				selectSepObj.options[i] = new Option(sepSequence[i].sequenceNLS,sepSequence[i].sequenceID);
				selectSepObj.options[i].title = sepSequence[i].sequenceTootip;
				
				//console.log("sepSequence[i].sequenceIDChar "+sepSequence[i].sequenceIDChar);				
				if (sepSequence[i].sequenceIDChar==separatorVal)//sepSequence[i].sequenceID
				{
					selectSepObj.options[i].selected="selected";	
				}
				//document.getElementById("selectSeparator").options[i].selected = true;
				
			}						
			
			selectSepObj.onchange = function() { onSeparatorChange();
			};
						
			//selectedTypeChanged()
		}
						
		function selectedTypeChanged()
		{								
			var selectedType = document.getElementById("iTypeSelect").options[document.getElementById("iTypeSelect").options.selectedIndex].value;			
			var iI = getIndexInNamingArray(selectedType);	
			
			document.getElementById("prefixInput").value=custoNamingsArray[iI].prefix;
			document.getElementById("suffixInput").value=custoNamingsArray[iI].suffix;	
			
			var currAffValue = document.getElementById('sitenameinput').value;
			//affixContainer.initialValue
			
			var curSepValue = getSepValueForPreview(); 
			//document.getElementById('selectSeparator').options[document.getElementById('selectSeparator').options.selectedIndex].innerHTML;//value;
			
			UpdateFinalFormatOverView(custoNamingsArray[iI].prefix,currAffValue,custoNamingsArray[iI].suffix, curSepValue, custoNamingsArray[iI].appType);
				
			document.getElementById("iTypeSelect").title = document.getElementById("iTypeSelect").options[document.getElementById("iTypeSelect").options.selectedIndex].innerHTML;	
			
		}
					
		function getIndexInNamingArray(iType)
		{
			for (i=0; i<custoNamingsArray.length; i++)				
				if (custoNamingsArray[i].objTypeID == iType)	
					return i;
			
			return 0;
		}
		
		function updateNamingElement(elt)
		{								
			document.getElementById("nameDeployIndicator").innerHTML='<img src=\"images/iconActionCreate.gif\" title="'+"<%=NotYetSaved%>"+'">';
			
			var eltName=document.getElementById(elt).value; 	
			
			if ( (testSpecialCharacters(eltName)==true)||
					(testTypeNamings(eltName)==true) )
			{			
				document.getElementById(elt).style.color="red";
				document.getElementById("labelwarning").style.color="red";
				
				if (testTypeNamings(eltName)==true)
					document.getElementById("labelwarning").innerHTML="<%=typesForbiddenMessage%>";
				else //if (testSpecialCharacters(eltName)==true)
					document.getElementById("labelwarning").innerHTML="<%=SpecialCharactersMessage%>";
						
				document.getElementById("iTypeSelect").disabled=true;
								
				for (var i=0; i<warnArrays.length;i++)				
					if (warnArrays[i].warnID == elt)
						warnArrays[i].warnRaised = true;	
							
			}
			else
			{								
				for (var i=0; i<warnArrays.length;i++)				
					if (warnArrays[i].warnID == elt)
					{
						warnArrays[i].warnRaised = false;
						document.getElementById(warnArrays[i].warnID).style.color="#070E14";
						
						var selectedType = document.getElementById("iTypeSelect").options[document.getElementById("iTypeSelect").options.selectedIndex].value;			
						var iI = getIndexInNamingArray(selectedType);	
												
						if (elt == "prefixInput")
							custoNamingsArray[iI].prefix = document.getElementById("prefixInput").value;
						else if (elt == "suffixInput")
							custoNamingsArray[iI].suffix = document.getElementById("suffixInput").value;
						
						//custoNamingsArray[iI].deploySts = "saved";						
						//var currAffVal = document.getElementById('sitenameinput').value;
						//document.getElementById("buttonAddSite").innerHTML='<img src=\"images/iconSavedParameter.gif\" title="<=NotYetDeployedParameter%>">';
						var curSepValue = getSepValueForPreview();
						//document.getElementById('selectSeparator').options[document.getElementById('selectSeparator').options.selectedIndex].innerHTML;//value;
										
						UpdateFinalFormatOverView(custoNamingsArray[iI].prefix,affixContainer.currentValue,custoNamingsArray[iI].suffix,curSepValue, custoNamingsArray[iI].appType);
						
						//UpdateFinalFormatOverView(custoNamingsArray[iI].prefix,currAffVal,custoNamingsArray[iI].suffix);

						
					}
							
			
				//for (var i=0; i<warnArrays.length;i++)					
				//document.getElementById(warnArrays[i].warnID).style.color="#070E14";
			
				
				if (CheckforRaisedWarnings() == "OK")
				{				
					document.getElementById("labelwarning").innerHTML="";
					//document.getElementById(elt).style.color="#070E14";					
									
					document.getElementById("iTypeSelect").disabled=false;
					
					//IR-207199V6R2014
					var tSiteName=document.getElementById("sitenameinput").value;
					
					if (tSiteName == "")
					{
						document.getElementById("labelwarning").style.color="#157196";
						document.getElementById("labelwarning").innerHTML="<%=affixDefineTooltip%>";
					}
					else
						document.getElementById("labelwarning").innerHTML="";
				}
				
			
				
				
				
			}
		}
		
		function confirmNamingElement()
		{			
			document.getElementById("nameDeployIndicator").innerHTML='<img src=\"images/iconSavedParameter.gif\" title="'+"<%=NotYetDeployedParameter%>"+'">';
						
			var selectedType = document.getElementById("iTypeSelect").options[document.getElementById("iTypeSelect").options.selectedIndex].value;			
			var iI = getIndexInNamingArray(selectedType);	
						
			custoNamingsArray[iI].prefix = document.getElementById("prefixInput").value;
			custoNamingsArray[iI].suffix = document.getElementById("suffixInput").value;
			custoNamingsArray[iI].deploySts = "saved";			
			
			var currAffVal = document.getElementById('sitenameinput').value;
			//document.getElementById("buttonAddSite").innerHTML='<img src=\"images/iconSavedParameter.gif\" title="<=NotYetDeployedParameter%>">';
			//affixContainer.initialValue
			
			var curSepValue = getSepValueForPreview();
			//document.getElementById('selectSeparator').options[document.getElementById('selectSeparator').options.selectedIndex].innerHTML;
								
			UpdateFinalFormatOverView(custoNamingsArray[iI].prefix,currAffVal,custoNamingsArray[iI].suffix,curSepValue, custoNamingsArray[iI].appType);
			
		
		}
		
		// 	IR-260338V6R2014x
		function UpdateFinalFormatOverView(iPrefix,iAffix,iSuffix,iSeparator,iAppType)
		{					
			var cSep = iSeparator;
			
			if (iAffix != "")
			{
				iAffix  = iAffix+cSep;				
				if (iPrefix != "")	
					iPrefix = iPrefix+cSep;				
			}
			else if ( (iAppType == "CBP") && (iPrefix != "") )	
				iPrefix = iPrefix+cSep;			
						
			if (iSuffix != "") iSuffix = cSep+iSuffix;
			
			document.getElementById("finalformat").value=iPrefix+iAffix+"<counter>"+iSuffix;
		}
		
		function getSepValueForPreview()
		{	
			var curSepValue = document.getElementById('selectSeparator').options[document.getElementById('selectSeparator').options.selectedIndex].value;
				//NOSEP				
			for ( var i=0; i<sepSequence.length; i++)				
				if (sepSequence[i].sequenceID==curSepValue)
					return sepSequence[i].sequenceIDChar;
				
			return '-';
			
		}
		
		function getSepIDfromSepchar(sepchar)
		{				
			for ( var i=0; i<sepSequence.length; i++)				
				if (sepSequence[i].sequenceIDChar==sepchar)
					return sepSequence[i].sequenceID;
				
			return '-';
			
		}
		
		
		
		
		function CheckforRaisedWarnings()
		{
			for (var i=0; i<warnArrays.length;i++)				
				if (warnArrays[i].warnRaised == true)
					return "WARN";
			
			return "OK";			
		}
		
		//IR-207199V6R2014
		function CheckAffixValue()
		{			
			var tSiteName=document.getElementById("sitenameinput").value;
			
			if (tSiteName == "")
			{
				document.getElementById("labelwarning").style.color="#157196";
				document.getElementById("labelwarning").innerHTML="<%=affixDefineTooltip%>";
			}
		}
		
		
	</script>
</head>	

<body>
            
<form action="" name="submitForm" method="POST">

<script type="text/javascript">
addTransparentLoadingInSession("none","LoadingDiv");
addDivForNonAppropriateContext("<%=displayhidediv%>","<%=NonAppropriateContext%>","100%","100%");
addTableControllingDiv("ParamDataIdDiv","<%=title_divNaming%>","100%","<%=identificationFamilies[iAffixIndex].getIcon()%>","<%=tooltip_divNaming%>");
</script> 

<div id="ParamDataIdDiv" style="width:98%; height:28%;  min-height:16%; background-color:#eeeeee;  overflow-x:hidden; overflow-y:auto;">

    <table width="100%" height="10%" cellspacing="2" cellpadding="2" >	
          <tr>
            <td width="25%" class="MatrixFeelNxG" title="<%=affixUI%>"><%=affixUI%>
            </td>
            <td width="20%" title="<%=separatorTooltip%>"><%=separatorNLS%></td>
            <td width="20%"></td>
            <td width="10%"></td>
            <td width="25%"></td>
            </tr>
            <tr height="5%" bgcolor="#eeeeee"  id="<%=commonParamID%>">
		    <td width="25%" class="MatrixFeelNxG">
		    <INPUT type="text" id="sitenameinput" value="<%=currentAffixValue%>" style="width:290px;" size="30" Maxlength="50" onkeyup="javascript:testonlineinputname()" oninput="javascript:testonlineinputname()"<%=fStatus%>>
		    </td>
		    <td width="20%" align="left">
		    	<select style="width:150px;"  id="selectSeparator" title="" onchange="javascript:testonlineinputname()">
					<option selected>EAU</option>
  		   			<option>TERRE</option>
  		   			<option>AIR</option>
  		   		</select>	
		    </td> 
		  	
		   	<td width="20%" id="buttonAddSite" align="left">
		   	<script>
		   	if ("<%=isAffixDeployed%>" == "false")
			   	document.write('<img src=\"images/iconSavedParameter.gif\" title="'+"<%=NotYetDeployedParameter%>"+'">');
		   	else
		   		document.write('<img src=\"images/iconLicenseAvailable.gif\" title="'+"<%=DeployedParameter%>"+'">');		   	
		   	</script>
			</td>		   	
		   	<td colspan="2" width="35%" class="titleCheckAccess" id="labelwarning">  </td>		  
		  </tr>
	</table>
	
	<br>
	
	<table id="AutoNamingTable" width="100%" height="20%" cellspacing="2" cellpadding="2" >	
	  <tr height="10">
 			<td class="MatrixFeelNxG" width="25%"><%=selectTypeTitle%></td>
 			<td class="MatrixFeelNxG" width="20%"><%=prefixTitle%></td>
 			<td class="MatrixFeelNxG" width="20%"><%=suffixTitle%></td>  	
 			<td class="MatrixFeelNxG" width="10%"></td> 
 			<td class="MatrixFeelNxG" width="25%"></td>
 		</tr>
 		
 		<tr height="10">
 		<td class="MatrixFeelNxG" width="25%">
 		<select style="width:290px;"  id="iTypeSelect" title="" onchange="javascript:selectedTypeChanged()">
  		</select>
  		</td>  	
  		  		  		
  		<td class="MatrixFeelNxG" width="20%" >
  		<INPUT type="text" id="prefixInput" value="" style="width:100%;  box-sizing:border-box;" size="30" Maxlength="60" onkeyup="javascript:updateNamingElement('prefixInput')" oninput="javascript:updateNamingElement('prefixInput')">
  		</td>
 	 		
 		<td class="MatrixFeelNxG" width="20%" >
  		<INPUT type="text" id="suffixInput" value="" style="width:100%;  box-sizing:border-box;" size="30" Maxlength="60" onkeyup="javascript:updateNamingElement('suffixInput')" oninput="javascript:updateNamingElement('suffixInput')">
  		</td>

  		<td class="MatrixFeelNxG" width="10%" align="left"></td> 
  		<!--<img src="images/buttonDialogDoneGray.gif" style="cursor:pointer" title="Click to confirm" onclick="javascript:confirmNamingElement()">-->  		
  		<td class="MatrixFeelNxG" width="25%"></td>
 		</tr>
 		
 		<tr height="10">
 		<td class="MatrixFeelNxG" width="25%"><%=typeIdentifierFormat%></td>
 		<td class="MatrixFeelNxG" colspan=2 width="40%" title="<%=affixTooltip%>"> 
 		<INPUT type="text" id="finalformat" value="" style="width:100%;  box-sizing:border-box;" size="64" readonly="readonly">
 		</td>
 		
 		<td id="nameDeployIndicator" class="MatrixFeelNxG" width="10%" align="center"> <img src="images/iconLicenseAvailable.gif" title="<%=DeployedParameter%>"></td>
 		<td class="MatrixFeelNxG" width="25%"></td>
 		</tr>
 		
	</table>
		
	<%
	
	//ObjectAutonamingFormat NamingTest = new ObjectAutonamingFormat();
	
	String iType = "VPMReference";
	
	//String [] listOfParams = ObjectAutonamingFormat.RetrieveNamingParameters(context, iType);
	
	
	int iCountName = 0;
	
	String NAMING_PREFIX_ARG	= "PrefixArg";
	String NAMING_SUFFIX_ARG	= "SuffixArg";
	String NAMING_APPTYPE_CONST = "appType";
	String NAMING_TYPE_CONST 	= "type";
	
	for (int i=0; i<vCustoNamingParamsList.length; i++)
	{
		String rParamID = vCustoNamingParamsList[i].getID();		
		
		if (!"IdentifierAffix".equalsIgnoreCase(rParamID))
		{
			//Naming Parameter 
			
			ParameterizationNLSCatalog pNamingCtlg = new ParameterizationNLSCatalog(context, currentLocale, vCustoNamingParamsList[i].getNLSFileName());
			              		
		  	String paramID = vCustoNamingParamsList[i].getID();
		  	String paramUI = pNamingCtlg.getMessage(vCustoNamingParamsList[i].getNLSKey());
		  	
		    String paramTooltip = pNamingCtlg.getMessage(vCustoNamingParamsList[i].getTooltipNLSKey());		  
		    boolean isParamDeployed  = vCustoNamingParamsList[i].isDeployed();          
		    
			AppIntUIConnector.IExchangeArgument[] paramNamingArgs = vCustoNamingParamsList[i].getArguments();
		
			//String[] defVals 	= new String[paramNamingArgs.length];	//defVals[j]	= paramNamingArgs[j].getDefault();	
			
			String curPrefixVal = "";
			String curSuffixVal = "";
			String defPrefixVal = "";
			String defSuffixVal = "";
			
			for (int j=0; j<paramNamingArgs.length; j++)
			{
				if (paramNamingArgs[j].getID().equalsIgnoreCase(NAMING_PREFIX_ARG))
				{
					curPrefixVal  = paramNamingArgs[j].getValue();
					defPrefixVal  = paramNamingArgs[j].getDefault();
				}
				else if (paramNamingArgs[j].getID().equalsIgnoreCase(NAMING_SUFFIX_ARG))
				{
					curSuffixVal = paramNamingArgs[j].getValue();
					defSuffixVal = paramNamingArgs[j].getDefault();
				}							
			}		
	
			
			//Retrieving Constants
			AppIntUIConnector.IExchangeConstant typeConst = vCustoNamingParamsList[i].getConstant(NAMING_TYPE_CONST);
			String currType  = typeConst.getValue();//standby
			
			AppIntUIConnector.IExchangeConstant appTypeConst = vCustoNamingParamsList[i].getConstant(NAMING_APPTYPE_CONST);
			String currappType  = appTypeConst.getValue();
						
			if ("CBP".equalsIgnoreCase(currappType))
			{
				String splitseparator = "::";
				
				String[] splitArgs = curPrefixVal.split(splitseparator);
				
				if (splitArgs.length == 2)
				{
					curPrefixVal = splitArgs[0];
					//affix --> splitArgs[1];
				}		
				
			}
			
					
			%>	
			<script>
		
		
			addCustomNamingElement("<%=paramID%>","<%=paramUI%>",
									"<%=curPrefixVal%>","<%=curSuffixVal%>",
									"<%=defPrefixVal%>","<%=defSuffixVal%>",
									"<%=currType%>",
									"<%=currappType%>",									
									"<%=isParamDeployed%>",																	
									<%=iCountName%>);
				
			
			</script>
			<%
			iCountName++;
				
			
		}
			
	}
					
	%>
	<script>
	handleSepatorIssues("<%=currSeparatorVal%>");
	CheckAffixValue();
	</script>	

	

</div>

<br>
<br>
      
<script type="text/javascript">
addTableControllingDiv("VersionNamingDiv","<%=title_divVN%>","100%","<%=identificationFamilies[iVNamingIndex].getIcon()%>","<%=tooltip_divVN%>");
</script>
	
<div Id="VersionNamingDiv" style="width: 98%; height:50%; min-height: 18%; background-color:#eeeeee;  overflow-x:hidden; overflow-y:auto;">
	
	<table id="VersionNamingTable" bgcolor="#eeeeee" width="100%" cellspacing="3" cellpadding="2" >       
            <tr height="10" bgcolor="#CDD8EB">
 			<td class="TitleSecParam" width="25%"><%=policyTypeTitle%></td>
 			<td class="TitleSecParam" width="20%"><%=CurrentpolicyTitle%></td>
 			<td class="TitleSecParam" width="35%"></td> 	
 			<td class="TitleSecParam" width="20%"></td> 
 			</tr>	
     </table>            
      
       <%   
       
        AppIntUIConnector.IExchangeParameter[] vNamingParametersList = identificationFamilies[iVNamingIndex].getParameters();
            	
        for (int i=0; i<vNamingParametersList.length; i++)
        {
        	ParameterizationNLSCatalog pVNNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, vNamingParametersList[i].getNLSFileName());
			
        	String policyID = vNamingParametersList[i].getID();
            String policyUI = pVNNLSCatalog.getMessage(vNamingParametersList[i].getNLSKey());
            //String policyTooltip = pVNNLSCatalog.getMessage(vNamingParametersList[i].getTooltipNLSKey());
            
            boolean isDeployed  = vNamingParametersList[i].isDeployed();              		
            		
            AppIntUIConnector.IExchangeArgument[] namingParamArgs = vNamingParametersList[i].getArguments();
            String currentNamingValue = namingParamArgs[0].getValue();
            String defaultNamingValue = namingParamArgs[0].getDefault();
            
            String policyTooltip = pVNNLSCatalog.getMessage(namingParamArgs[0].getTooltipNLSKey());
               		
            String[] argValuesList 	= namingParamArgs[0].getValuesList();
            String[] argKeysNLSList = namingParamArgs[0].getValuesNLSKeyList();
            		
            String[] argListNLSTooltip = new String[argKeysNLSList.length];
            String[] argValuesNLSList  = new String[argKeysNLSList.length];            		
        
            
            for (int j=0; j<argKeysNLSList.length; j++)
            {
            	argListNLSTooltip[j] = new String();
            	argValuesNLSList[j]  = new String();
            }
            	    
            for (int j=0; j<argKeysNLSList.length; j++)
            {
				argValuesNLSList[j] = IDentUIConnector.getProperty("ShortSequence_" + argValuesList[j]);
				argListNLSTooltip[j] = IDentUIConnector.getProperty("LongSequence_" + argValuesList[j]);
				if (argValuesNLSList[j] == null || argListNLSTooltip[j] == null)
				{
					argValuesNLSList[j]  = pVNNLSCatalog.getMessage(argKeysNLSList[j]); 
					argListNLSTooltip[j] = pVNNLSCatalog.getMessage(argKeysNLSList[j]+".tooltip");
				}
            }	            			            		
              				
           %>
            <script>   
            var tempSequence = new Array(); 
            </script>
        	<%  
        			
        	for (int j=0; j<argValuesList.length; j++)
            {            		
            	%>
            	<script>         	
            	tempSequence[tempSequence.length]=new sequenceObj("<%=argValuesList[j]%>","<%=argValuesNLSList[j]%>","<%=argListNLSTooltip[j]%>");            			
            	appendSequencetoLists("<%=argValuesList[j]%>","<%=argValuesNLSList[j]%>","<%=argListNLSTooltip[j]%>");
            	</script>
            	<%            		
            }           			
            %>
			<script>					
			addObjectNamingLine(<%=i+1%>,
							"<%=policyID%>",
							"<%=currentNamingValue%>","<%=defaultNamingValue%>",
							"<%=policyUI%>","<%=policyTooltip%>",
							<%=isDeployed%>,
							tempSequence);
			</script>				
			<%             	 
        }            		
        %>   
  </div>
 	
</form>
<script>addFooter("javascript:DeployParams('nofreeze')","images/buttonDialogApply.gif","<%=Deploycmd%>","<%=DeployTitle%>",null,null,null,null,"javascript:ResetInSession()","images/buttonDialogCancel.gif","<%=Resetcmd%>","<%=ResetTitle%>","<%=displayhidecontrol%>");</script>
</body>

</html>
