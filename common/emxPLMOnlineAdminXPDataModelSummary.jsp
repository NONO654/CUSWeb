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
<%@ page import ="com.matrixone.vplm.FreezeServerParamsSMB.FreezeServerParamsSMB"%>
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
	ParameterizationNLSCatalog[] collectionNLSCatalogs = new ParameterizationNLSCatalog[collectionIDs.length];
	for (int i=0 ; i<collectionIDs.length ; i++)
	{
		String collectionNLSFile = TAC.getNLSFileName(collectionIDs[i]);
		collectionNLSCatalogs[i] = new ParameterizationNLSCatalog(context, currentLocale, collectionNLSFile);
	}
	
	boolean show_indexed = false;//TAC.getEnableIndexed();
	%>
	<script>
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
			<%
			String AddedAttributesSummary  = myNLS.getMessage("AddedAttributesSummary");
			String ObjectTypeLabel		 = myNLS.getMessage("ObjectTypeLabel");
			String CurrentlyUsedAttributes = myNLS.getMessage("CurrentlyUsedAttributes");
			String tooltipReIndex = "RE-INDEX";
			int DataSummaryDivHeight = 10 + 35 * collectionIDs.length;
			%>
			<script type="text/javascript">
				addTransparentLoadingInSession("none","LoadingDiv");
				addTableControllingDiv0("DataSummary","<%=AddedAttributesSummary%>","80%","iconParameterizationAttributesSummary.gif","<%=AddedAttributesSummary%>");
			</script>
			<div id="DataSummary" style="width: 80%; background-color:#eeeeee; height:<%=DataSummaryDivHeight%>px; overflow-y:auto; overflow-x:hidden;">
				<table id="AttrTable" width="100%" height="100%" bgcolor="white" cellspacing="2" cellpadding="0">
					<tr bgcolor="#B8CCD8" height="12px">
						<td align="left" width="5%"></td>
						<% if (show_indexed) { %>
						<td align="left" width="5%"></td>
						<td width="30%"><%=ObjectTypeLabel%></td>
						<% } else { %>
						<td width="35%"><%=ObjectTypeLabel%></td>
						<% } %>
						<td colspan="2" width="60%"><%=CurrentlyUsedAttributes%></td>
					</tr>
					<%
					for (int i=0 ; i<collectionIDs.length ; i++)
					{
						String imageCollectionStatus = "iconParameterizationAttributeEditable.gif";
						String tooltipCollection = myNLS.getMessage("UIAttrEditable");
						if (Frz.GetServerFreezeStatusDB(context,"ParameterizationAttributeDef_" + collectionIDs[i]) == Frz.S_FROZEN)
						{
							imageCollectionStatus = "iconParameterizationAttributeFrozen.gif";
							tooltipCollection = myNLS.getMessage("UIAttrFrozen");
						}
						int activeAttributes = TAC.getQuantityOfDeployedAttributes(collectionIDs[i]);
						
						String[] structuredDescriptionOfActive = TAC.getDescriptionOfDeployedAttributes(collectionIDs[i]);
						String descriptionOfActive = "";
						for (int j=0 ; j<structuredDescriptionOfActive.length ; j++)
							if (j % 3 == 0)
							{
								if (!"".equals(descriptionOfActive))
									descriptionOfActive += ", ";
								descriptionOfActive += structuredDescriptionOfActive[j] + " ";
							}
							else if (j % 3 == 1)
								descriptionOfActive += myNLS.getMessage("typeLabel" + structuredDescriptionOfActive[j]);
							else if (j % 3 == 2 && !"0".equals(structuredDescriptionOfActive[j]) && !"".equals(structuredDescriptionOfActive[j]))
								descriptionOfActive += "(" + myNLS.getMessage("lengthLabel" + structuredDescriptionOfActive[j]) + ")";
						
						String collectionNLSKeys = TAC.getNLSKey(collectionIDs[i]);
						String collectionNLSName = collectionNLSCatalogs[i].getMessage(collectionNLSKeys);
						%>
						<tr bgcolor="white">
							<td align="left" width="5%"><img src="images/<%=imageCollectionStatus%>" title="<%=tooltipCollection%>"></td>
							<% if (show_indexed) { %>
							<td align="left" width="5%"><img src="images/iconParameterizationIndexedAttribute.gif" title="<%=tooltipReIndex%>" style="cursor:pointer" onclick="javascript:reIndex('<%=collectionIDs[i]%>')"></td>
							<td width="30%"><%=collectionNLSName%></td>
							<% } else { %>
							<td width="35%"><%=collectionNLSName%></td>
							<% } %>
							<td width="10%"><%=activeAttributes%></td>
							<td width="50%"><%=descriptionOfActive%></td>
						</tr>
						<%
					}
					%>
				</table>
			</div>
		</div>
	</div>
</body>
</html>
