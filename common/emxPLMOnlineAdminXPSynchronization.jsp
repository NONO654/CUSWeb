<%--
//@fullReview  ZUR 10/07/02 HL XP Params V6R2012
//@quickReview ZUR 10/11/15 HL XP Params V6R2012 - UI minor enhancements
//@quickReview ZUR 10/12/01 - Minor modification for IE layout compatibility
//@quickReview ZUR 10/12/14 - Robustification to handle some extreme cases
//@fullReview  ZUR 11/01/31 V6R2012x, Integrating first SynchroUI
//@quickReview ZUR 11/05/18 IR-105736V6R2012x
//@quickReview ZUR 11/10/05	IR-126757V6R2012x/2013 "NLSizing" the attributes type
//@quickReview YXJ 13/10/14	split summary & synchro into 2 JSPs
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@ page import="com.matrixone.vplm.parameterizationUtilities.MatrixUtilities" %>
<%@ page import ="com.matrixone.vplm.TeamAttributeCustomize.TeamAttributeCustomize"%>
<%@ page import ="com.matrixone.vplm.TeamAttributeCustomize.AttributeProperties"%>
<%@ page import ="com.matrixone.vplm.FreezeServerParamsSMB.FreezeServerParamsSMB"%>
<%@ page import ="com.matrixone.vplm.TeamAttributeSynchronization.TeamAttributeSynchronization"%>
<%@ page import ="com.matrixone.vplm.TeamAttributeSynchronization.SynchronizationParameter"%>
<%@ page import ="com.matrixone.vplm.TeamAttributeSynchronization.AttributeDescription"%>
<%@ page import ="com.matrixone.vplm.parameterizationUtilities.NLSUtilities.ParameterizationNLSCatalog"%>
<%@ page import="java.util.*"%>
<html>
<head>
	<link rel=stylesheet type="text/css" href="styles/emxUIDOMLayout.css">
	<link rel=stylesheet type="text/css" href="styles/emxUIDefault.css">
	<link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css">
	<link rel=stylesheet type="text/css" href="styles/emxUIParamOnline.css">

	<script type="text/javascript" src="scripts/expand.js"></script>
	<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
	<script src="scripts/emxUIAdminConsoleUtil.js" type="text/javascript"></script>
	<%
	Locale currentLocale = request.getLocale();
	
	ParameterizationNLSCatalog myNLS = new ParameterizationNLSCatalog(context, currentLocale, "myMenu");
	
	// CONTEXT CHECK
	String NonAppropriateContext = myNLS.getMessage("NonAppropriateContext");
	String NonAppropriateSolution = myNLS.getMessage("NonAppropriateSolution");
	String admincontext = "VPLMAdmin";
	String displayhidediv = "block";
	String displayhidecontrol = "none";
	String currentcontext = context.getRole();
	
	String CurrentUISolution = MatrixUtilities.getCurrentSolution(context);
	
	boolean contextSolutionIsTeam = true;
	
	if (!MatrixUtilities.RACE_SOLUTION.equalsIgnoreCase(CurrentUISolution))
	{
		NonAppropriateContext = NonAppropriateSolution;
		contextSolutionIsTeam = false;
	}
	if (currentcontext.indexOf(admincontext) >= 0 && MatrixUtilities.RACE_SOLUTION.equalsIgnoreCase(CurrentUISolution))
	{
		displayhidediv = "none";
		displayhidecontrol = "block";
	}

	// FREEZE
	FreezeServerParamsSMB Frz = new FreezeServerParamsSMB();
	String fStatus = "";
	if (Frz.GetServerFreezeStatusDB(context,"APPXPParametrizationDataTree") == Frz.S_FROZEN)
		fStatus = "disabled";

	// ATTRIBUTES
	TeamAttributeCustomize TAC = new TeamAttributeCustomize(context);
	String[] collectionIDs = TAC.getAllCollectionIDs();
	
	%>
	<script>
		var typesArePresentForSync = false;
		
		var attrPrdnameArray = new Array();
		var attrPrdtypeArray = new Array();
		var attrPrdlengthArray = new Array();
		//var attrPrdROArray = new Array();
		var attrPrdMandArray = new Array();

		var AllPartAttrname = new Array();
		var AllPartAttrtype = new Array();
		var AllPartAttrlength = new Array();
		//var AllPartROArray = new Array();
		var AllPartMandArray = new Array();

		var SynchroPartAttr = new Array();
		var SynchroPrdAttr = new Array();
		var SynchroDeployStatus = new Array();

		var tempComboValue;

		var xmlreqs = new Array();

		var currentfreeze="<%=fStatus%>";

		
		var typesNLS = new Array();
		var lengthsNLS = new Array();
		
		<%
		String[] possibleTypes = {
			TeamAttributeCustomize.STR_BOOLEAN,
			TeamAttributeCustomize.STR_STRING,
			TeamAttributeCustomize.STR_REAL,
			TeamAttributeCustomize.STR_INTEGER,
			TeamAttributeCustomize.STR_DATE};
		String[] possibleLengths = {"16", "40", "80"};
		for (String ttype : possibleTypes)
		{
		%>
			typesNLS["<%=ttype%>"] = "<%=myNLS.getMessage("typeLabel" + ttype)%>";
		<%
		}
		for (String length : possibleLengths)
		{
		%>
			lengthsNLS["<%=length%>"] = "<%=myNLS.getMessage("lengthLabel" + length)%>";
		<%
		}
		%>
		
		function checkMandatoryConsistency(iProductName, iPartName)
		{
			for (var i=0 ; i<attrPrdnameArray.length ; i++)
				if (attrPrdnameArray[i] == iProductName)
					for (var j=0 ; j<AllPartAttrname.length ; j++)
						if (AllPartAttrname[j] == iPartName)
						{
							if (attrPrdMandArray[i] != AllPartMandArray[j])
								return "\n    -  " + iProductName + " / " + iPartName;
							return "";
						}
			return "";
		}
		
		function addAttributeSynchLine(indi,atype,alen,attname)
		{
			var filteredPartListAttr = filterPartList(atype,alen);
			var newRow = document.getElementById("SynchTable").insertRow(-1);
			newRow.style.backgroundColor= "white";
			newRow.style.height= 25 + 'px';
			newRow.id=indi;

			var newCell = newRow.insertCell(-1);
			newCell.align = "left";
//			newCell.className="MatrixFeelNxG";
			newCell.style.width="32%";
			newCell.innerHTML=attname;

			newCell = newRow.insertCell(-1);
			newCell.align = "left";
//			newCell.className="MatrixFeelNxG";
			newCell.style.width="11%";

			if (alen == "0")
				newCell.innerHTML = typesNLS[atype];
			else
				newCell.innerHTML = typesNLS[atype] + "(" + lengthsNLS[alen] + ")";
			
			var newCell3 = newRow.insertCell(-1);
			newCell3.align = "center";
//			newCell3.className="MatrixFeelNxG";
			newCell3.style.width="4%";
			newCell3.innerHTML="";

			var newCell4 = newRow.insertCell(-1);
			newCell4.align = "left";
//			newCell4.className="matrixFeel";
			newCell4.style.width="32%";

			var selectSynch = document.createElement("select");
			selectSynch.id='comboSynch'+indi;
			selectSynch.setAttribute("style", "width:200px");
			if (document.all)//IE
			{
				selectSynch.style.setAttribute("cssText","width:200px;");
			}

			selectSynch.onclick = function() { getCurrentComboValue(indi,atype) };
			selectSynch.onchange = function() { updateComboOptions(indi,atype) };

			selectSynch.options[0] = new Option("<%=myNLS.getMessage("ChooseLabel")%>"+'...', '0');

			for ( var i=0;i<filteredPartListAttr.length;i++)
			{
				selectSynch.options[i+1] = new Option(filteredPartListAttr[i],filteredPartListAttr[i]);
			}

			if (currentfreeze=="disabled")
				selectSynch.disabled=true;

			newCell4.appendChild(selectSynch);

			//Deploy Status
			var newCell5 = newRow.insertCell(-1);
			newCell5.align = "center";
//			newCell5.className="matrixFeel";
			newCell5.style.width="21%";
			newCell5.innerHTML='';
			newCell5.value=0;
		}

		/* shows Only Part Attributes of the same type
		alen not used for the moment
		*/
		function filterPartList(atype, alen)
		{
			var filteredPartAttrList = new Array();
			var j=0;
			for( var i=0;i<AllPartAttrname.length;i++)
			{
				if (atype.toUpperCase()==AllPartAttrtype[i].toUpperCase())
				{
					filteredPartAttrList[j]=AllPartAttrname[i];
					j++;
				}
			}
			return filteredPartAttrList;
		}

		function LinkRefAttributetoCorrespSynch(ProductAttrName,PartAttrName,SynchroDeployStatus)
		{
			var tablesize=document.getElementById('SynchTable').rows.length;
			for (var i=1;i<tablesize;i++)
			{
				var oCustPrdAtt = document.getElementById('SynchTable').rows[i].cells[0].childNodes[0].data;
				if (ProductAttrName==oCustPrdAtt)
				{
					var listlength=document.getElementById("comboSynch"+i).options.length;
					for (var j=0;j<listlength;j++)
					{
						if (PartAttrName==document.getElementById("comboSynch"+i)[j].value)
						{
							document.getElementById("comboSynch"+i).selectedIndex = j;
							var iType=attrPrdtypeArray[i-1];
							RemoveChosenOptionFromOtherComboBX(i,iType,PartAttrName);
							if (SynchroDeployStatus=="true")
							{
								document.getElementById('SynchTable').rows[i].cells[4].value=1;//Deployed
								document.getElementById('SynchTable').rows[i].cells[4].innerHTML="<img src=\"images/iconParameterizationParameterDeployed.gif\">";
								document.getElementById('SynchTable').rows[i].cells[4].title="<%=myNLS.getMessage("DeployedParameter")%>";
							}
							else
							{
								document.getElementById('SynchTable').rows[i].cells[4].value=2;//Stored but not yet deployed
								document.getElementById('SynchTable').rows[i].cells[4].innerHTML='<img src="images/iconParameterizationParameterSaved.gif">';
								document.getElementById('SynchTable').rows[i].cells[4].title="<%=myNLS.getMessage("SavedParameter")%>";
							}
							break;
						}
					}
					break;
				}
			}
		}

		function getCurrentComboValue(iID,iType)
		{
			//on Click
			var currSelectedInd=document.getElementById("comboSynch"+iID).options.selectedIndex;
			if (currSelectedInd==0)
				tempComboValue="NOCHOICE";
			else
				tempComboValue=document.getElementById("comboSynch"+iID).options[document.getElementById("comboSynch"+iID).options.selectedIndex].innerHTML;
		}

		function updateComboOptions(iID,iType)
		{
			//On "change"
			var NewSelectedInd = document.getElementById("comboSynch"+iID).options.selectedIndex;
			if (tempComboValue!="NOCHOICE")
			{
				AddOptionToOtherComboBX(iID,iType);
				document.getElementById('SynchTable').rows[iID].cells[4].innerHTML='<img src="images/iconParameterizationParameterModified.gif">';
				document.getElementById('SynchTable').rows[iID].cells[4].title="<%=myNLS.getMessage("NotYetSavedParameter")%>";
				document.getElementById('SynchTable').rows[iID].cells[4].value=4;
			}
			if (NewSelectedInd!=0)
			{
				document.getElementById('SynchTable').rows[iID].cells[4].innerHTML='<img src="images/iconParameterizationParameterModified.gif">';
				document.getElementById('SynchTable').rows[iID].cells[4].value=2;
				document.getElementById('SynchTable').rows[iID].cells[4].title="<%=myNLS.getMessage("NotYetSavedParameter")%>";
				tempComboValue=document.getElementById("comboSynch"+iID).options[document.getElementById("comboSynch"+iID).options.selectedIndex].innerHTML;
				RemoveChosenOptionFromOtherComboBX(iID,iType,tempComboValue);
			}
		}

		function AddOptionToOtherComboBX(iID,iType)
		{
			var tablesize=document.getElementById('SynchTable').rows.length;
			var listlength;
			for (var i=1;i<tablesize;i++)
			{
				if ( (iType==attrPrdtypeArray[i-1])&&(i!=iID))
				{
					listlength=document.getElementById("comboSynch"+i).options.length;
					var newopt = new Option(tempComboValue,tempComboValue);
					document.getElementById("comboSynch"+i).options[listlength]=newopt;
				}
			}
		}

		function RemoveChosenOptionFromOtherComboBX(iID,iType,valueToRemove)
		{
			var tablesize=document.getElementById('SynchTable').rows.length;
			var listlength;
			for (var i=1;i<tablesize;i++)
			{
				if ( (iType==attrPrdtypeArray[i-1])&&(i!=iID))
				{
					listlength=document.getElementById("comboSynch"+i).options.length;
					for (var j=0;j<listlength;j++)
					{
						if (valueToRemove==document.getElementById("comboSynch"+i)[j].value)
						{
							document.getElementById("comboSynch"+i).remove(j);
							break;
						}
					}
				}
			}
		}

		/*
		Resets In Session The Synchronizations
		*/
		function ResetInSession()
		{
			if (currentfreeze=="disabled")
				alert("<%=myNLS.getMessage("Freezemessage")%>");
			else
			{
				var tablesize=document.getElementById('SynchTable').rows.length;
				var filteredPartListAttr;
				var alen=0;
				for (var i=1;i<tablesize;i++)
				{
					var AttrPrdType=attrPrdtypeArray[i-1];
					filteredPartListAttr = filterPartList(AttrPrdType,alen);//alen not used for the moment
					document.getElementById("comboSynch"+i).options.length = 0;
					var opt0 = new Option("<%=myNLS.getMessage("ChooseLabel")%>"+'...', '0');
					document.getElementById("comboSynch"+i).options[0]=opt0;
					for ( var j=0;j<filteredPartListAttr.length;j++)
					{
						document.getElementById("comboSynch"+i).options[j+1] = new Option(filteredPartListAttr[j],filteredPartListAttr[j]);
					}
					document.getElementById("comboSynch"+i).selectedIndex = 0;
					document.getElementById('SynchTable').rows[i].cells[4].innerHTML='';
					document.getElementById('SynchTable').rows[i].cells[4].title="";
				}
			}
		}

		/*
		* Deploys the current Set Synchronizations
		*/
		function DeployParams(iInput)
		{
			if (!typesArePresentForSync)
			{
				alert("<%=myNLS.getMessage("Deploysuccess")%>");
				return;
			}
			var tablesize=document.getElementById('SynchTable').rows.length;
			var retcheck="ok";
			var srvSend="";
			if (currentfreeze=="disabled")
				alert("<%=myNLS.getMessage("Freezemessage")%>");
			else
			{
				var srvSend="iSourceJSP=DataSynch";
				var cont="no";
				if ((iInput=="nofreeze")||(iInput=="save"))
				{
					srvSend=srvSend+"&frzStatus=false";
				}
				else if (iInput=="freezecmds")
				{
					if (confirm ("<%=myNLS.getMessage("Confirmfreeze")%>"))
					{
						cont="yes";
						srvSend=srvSend+"&frzStatus=true";
					}
				}
				if (  (cont=="yes") || (iInput!="freezecmds"))
				{
					var oCustPrdAtt;
					var oChoosenPartAtt;
					var nbSetSynch=0;
					if (iInput=="nofreeze")
						srvSend=srvSend+"&iDeployType=StoreAndDeploy";
					else if(iInput=="save")
						srvSend=srvSend+"&iDeployType=StoreOnly";
					var mandatoryConsistency = "";
					for (var i=1;i<tablesize;i++)
					{
						if (document.getElementById("comboSynch"+i).selectedIndex !=0)
						{
							oCustPrdAtt = document.getElementById('SynchTable').rows[i].cells[0].childNodes[0].data;
							oChoosenPartAtt=document.getElementById("comboSynch"+i).options[document.getElementById("comboSynch"+i).options.selectedIndex].innerHTML;
							srvSend=srvSend+"&iCustPrdAtt_"+nbSetSynch+"="+oCustPrdAtt;
							srvSend=srvSend+"&iChoosenPartAtt_"+nbSetSynch+"="+oChoosenPartAtt;
							mandatoryConsistency = mandatoryConsistency + checkMandatoryConsistency(oCustPrdAtt, oChoosenPartAtt);
							nbSetSynch=nbSetSynch+1;
						}
					}
					if (mandatoryConsistency != "")
					{
						alert("<%=myNLS.getMessage("SyncRequiresSameMandStatus")%>" + mandatoryConsistency);
						return;
					}
					srvSend=srvSend+"&iNbSetSynch_="+nbSetSynch;
					document.getElementById('LoadingDiv').style.display='block';
					document.getElementById('divPageFoot').style.display='none';
					xmlreq("emxPLMOnlineAdminXPAjaxParam.jsp",srvSend,DeployParamsRet,0);
				}
			}
		}

		function DeployParamsRet()
		{
			var xmlhttpfreeze = xmlreqs[0];
			var usermessage="";
			if(xmlhttpfreeze.readyState==4)
			{
				document.getElementById('LoadingDiv').style.display='none';
				document.getElementById('divPageFoot').style.display='block';
				var tablesize=document.getElementById('SynchTable').rows.length;
				var SynchResult =xmlhttpfreeze.responseXML.getElementsByTagName("SynchAttRet");
				var freeze_res =xmlhttpfreeze.responseXML.getElementsByTagName("Freezeret");
				var SynchType =xmlhttpfreeze.responseXML.getElementsByTagName("SynchType");
				if (freeze_res.item(0)!=null)
				{
					if (freeze_res.item(0).firstChild.data =="S_OK")
					{
						for (i=1; i<tablesize; i++)
							document.getElementById("comboSynch"+i).disabled=true;
						usermessage="<%=myNLS.getMessage("Freezesuccess")%>";
						currentfreeze="disabled";
					}
					else if (freeze_res.item(0).firstChild.data =="E_Internal")
						usermessage="<%=myNLS.getMessage("Freezefailure")%>";
					else
						usermessage=freeze_res.item(0).firstChild.data;
				}
				if (SynchResult.item(0)!=null)
				{
					if (SynchResult.item(0).firstChild.data =="S_OK")
					{
						var tablesize=document.getElementById('SynchTable').rows.length;
						if (SynchType.item(0).firstChild.data =="StoreAndDeploy")
						{
							usermessage=usermessage+"\n<%=myNLS.getMessage("Deploysuccess")%>";
							for (var i=1;i<tablesize;i++)
							{
								if ((document.getElementById('SynchTable').rows[i].cells[4].value == 1 )||
										(document.getElementById('SynchTable').rows[i].cells[4].value == 2 ))
								{
									document.getElementById('SynchTable').rows[i].cells[4].value=1;
									document.getElementById('SynchTable').rows[i].cells[4].innerHTML="<img src=\"images/iconParameterizationParameterDeployed.gif\">";
									document.getElementById('SynchTable').rows[i].cells[4].title="<%=myNLS.getMessage("DeployedParameter")%>";
								}
								else if (document.getElementById('SynchTable').rows[i].cells[4].value == 4 )
								{
									document.getElementById('SynchTable').rows[i].cells[4].value=0;
									document.getElementById('SynchTable').rows[i].cells[4].innerHTML="";
								}
							}
						}
						else
						{	//StoreOnly
							usermessage=usermessage+"\n<%=myNLS.getMessage("Savesuccessmsg")%>";
							for (var i=1;i<tablesize;i++)
							{
								if  (document.getElementById('SynchTable').rows[i].cells[4].value == 2 )
								{
									document.getElementById('SynchTable').rows[i].cells[4].value=1;
									document.getElementById('SynchTable').rows[i].cells[4].innerHTML="<img src=\"images/iconParameterizationParameterSaved.gif\">";
									document.getElementById('SynchTable').rows[i].cells[4].title="<%=myNLS.getMessage("SavedParameter")%>";
								}
								else if (document.getElementById('SynchTable').rows[i].cells[4].value == 4 )
								{
									document.getElementById('SynchTable').rows[i].cells[4].value=0;
									document.getElementById('SynchTable').rows[i].cells[4].innerHTML="";
								}
							}
						}
					}
					else
					{
						usermessage=usermessage+"\n<%=myNLS.getMessage("Deployfail")%>";
					}
				}
				alert(usermessage);
			}
		}
		
		function reIndex(i)
		{
			alert("reindex collection : " + i);
		}
		
		function addTableControllingDiv0(DivID,iTitle,toolbarWidth,iconFileName,iconToolTip)
		{
			document.write('<table border="0" width="'+toolbarWidth+'" >');
			document.write('<tr bgcolor="#6691AA" align="left">');
			document.write('<td class="pic" style="border:0"><img src="../common/images/'+iconFileName+'" title="'+iconToolTip+'"/></td>');
			document.write('<td><b><font color="white">'+iTitle+'</font></b></td>');
			document.write('<td class="pic" style="border:0" align="center"><img src="images/xpcollapse1_s.gif" onclick="SwitchMenuParams(\''+DivID+'\', this);"/></td>');
			document.write('</tr>')
			document.write('</table>');
		}

	</script>
</head>

<body>
	<div id="GlobalbgDiv"  style="width: 100%;  height:100%; background-color: #eeeeee;">
		<script type="text/javascript">
			addDivForNonAppropriateContext("<%=displayhidediv%>","<%=NonAppropriateContext%>","100%","100%");
		</script>
		<div id="GlobShiftedDiv" style="width: 100%; height:100%; position:relative; left: 70px; top : 40px">
			<script type="text/javascript">
				addTransparentLoadingInSession("none","LoadingDiv");
			</script>
			<%
			if (contextSolutionIsTeam)
			{
				TeamAttributeSynchronization TAS = new TeamAttributeSynchronization(context);
				AttributeDescription[] AttPartList = TAS.getPartAttributes(context);
				AttributeDescription[] AttProdList = TAS.getProductAttributes(context);
				SynchronizationParameter[] synchParamList = TAS.getSynchronizationParameters(context);
				String SynchronizeTitle = myNLS.getMessage("SynchronizeTitle");
				
				String partCollectionID = TeamAttributeSynchronization.getPartCollectionID();
				String productCollectionID = TeamAttributeSynchronization.getProductCollectionID();
				String[] allCollections = TAC.getAllCollectionIDs();
				boolean isPartCollPresent = false;
				boolean isProductCollPresent = false;
				for (String collID : allCollections)
					if (collID.equals(partCollectionID))
						isPartCollPresent = true;
					else if (collID.equals(productCollectionID))
						isProductCollPresent = true;
				%>
				<script type="text/javascript">
					typesArePresentForSync = <%=isPartCollPresent && isProductCollPresent%>;
					addTableControllingDiv0("DataSynchDiv","<%=SynchronizeTitle%>","80%","iconParameterizationSynchronization.gif","<%=SynchronizeTitle%>");
				</script>
				<div id="DataSynchDiv" style="width:80%; height:80%; min-height:40%; overflow-y:auto; overflow-x:auto; background-color:white">
					<table id="SynchTable" border="0" width="100%" cellspacing="2" cellpadding="0" style="none" bgcolor="white">
						<tr bgcolor="#B8CCD8">
							<td width="32%" ><%=myNLS.getMessage("PhysicalProductLabel")%></td>
							<td width="11%"><%=myNLS.getMessage("AttributeType")%>(<%=myNLS.getMessage("AttributeLength")%>)</td>
							<td width="4%"></td>
							<td width="32%"><%=myNLS.getMessage("CommonPartLabel")%></td>
							<td width="21%"><%=myNLS.getMessage("DeployStatus")%></td>
						</tr>
					</table>
					<script>
					<%
					//update array with state names
					for(int i=0;i<AttProdList.length;i++)
					{
						%>
							attrPrdnameArray[<%=i%>]   = "<%=AttProdList[i].getName()%>";
							attrPrdtypeArray[<%=i%>]   = "<%=AttProdList[i].getType()%>";
							attrPrdlengthArray[<%=i%>] = "<%=AttProdList[i].getLength()%>";
							//attrPrdROArray[<%=i%>]   = <%=AttProdList[i].isReadOnly()%>;
							attrPrdMandArray[<%=i%>] = <%=AttProdList[i].isMandatory()%>;
						<%
					}
					for(int j=0;j<AttPartList.length;j++)
					{
						%>
							AllPartAttrname[<%=j%>]   = "<%=AttPartList[j].getName()%>";
							AllPartAttrtype[<%=j%>]   = "<%=AttPartList[j].getType()%>";
							AllPartAttrlength[<%=j%>] = "<%=AttPartList[j].getLength()%>";
							//AllPartROArray[<%=j%>]   = <%=AttPartList[j].isReadOnly()%>;
							AllPartMandArray[<%=j%>] = <%=AttPartList[j].isMandatory()%>;
						<%
					}
					String SynchPrdAttrName="";
					String SynchPartAttrName="";
					String isCurrentDeployed="";
					int lenSynchroList = synchParamList.length;
					for(int k=0;k<lenSynchroList;k++)
					{
						SynchPrdAttrName = synchParamList[k].getProductAttributeName();
						SynchPartAttrName = synchParamList[k].getPartAttributeName();
						isCurrentDeployed= String.valueOf(synchParamList[k].isDeployed());
						%>
							SynchroPrdAttr[<%=k%>] = <%="'"+SynchPrdAttrName+"'"%>;
							SynchroPartAttr[<%=k%>] = <%="'"+SynchPartAttrName+"'"%>;
							SynchroDeployStatus[<%=k%>] = <%="'"+isCurrentDeployed+"'"%>;
						<%
					}
					%>
							if (typesArePresentForSync)
							{
								for (var i=0; i<<%=AttProdList.length%>; i++)
								{
									addAttributeSynchLine(i+1,attrPrdtypeArray[i],attrPrdlengthArray[i],attrPrdnameArray[i]);
								}
								for (var j=0; j<SynchroPrdAttr.length; j++)
								{
									LinkRefAttributetoCorrespSynch(SynchroPrdAttr[j],SynchroPartAttr[j],SynchroDeployStatus[j]);
								}
							}
					</script>
				</div>
				<%
			}
			%>
		</div>
	</div>
	<script>addFooter("javascript:DeployParams('nofreeze')","images/buttonParameterizationDeploy.gif","<%=myNLS.getMessage("Deploycmd")%>","<%=myNLS.getMessage("DeployTitle")%>",null,null,null,null,"javascript:ResetInSession()","images/buttonParameterizationReset.gif","<%=myNLS.getMessage("Resetcmd")%>","<%=myNLS.getMessage("ResetTitle")%>","<%=displayhidecontrol%>");</script>
</body>
</html>
