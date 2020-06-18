 <%--  emxPartFamilyMasterDialog.jsp  -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file ="emxEngrFramesetUtil.inc"%>


<%@page import="com.matrixone.apps.engineering.PartFamily"%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<body>
<form name="formProcess" method="post" id="formProcess">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
</form>
</body>
<%
		String objectId = (String)emxGetParameter(request, "objectId");
		String action = (String)emxGetParameter(request, "action");
		String key = (String)emxGetParameter(request, "key");
		String actionType = (String)emxGetParameter(request, "actionType");
		String ATTRIBUTE_REFERENCE_TYPE = PropertyUtil.getSchemaProperty(context, "attribute_ReferenceType");
		String language     = request.getHeader("Accept-Language");
		String[] tableRowId = emxGetParameterValues(request, "emxTableRowId");
		if (tableRowId == null)
		{
			tableRowId = (String []) session.getAttribute("emxTableRowId");
		}
		if(key == null)
		key = "";
		if(action == null){
					action = "";
				}
	if(action.equals("addexisting")) {
		if (tableRowId == null) {
		%>
			<script>
			parent.getTopWindow().refreshTablePage();
			</script>
		<%
		} else {
			String id=tableRowId[0];		
			String alert4 = i18nNow.getI18nString("emxEngineeringCentral.Common.CommandOnlyallowsAssignedPartstobeAssignedasaReference","emxEngineeringCentralStringResource", language); // IR:008742 
			boolean isUnAssignedReference = false;
			StringTokenizer token = new StringTokenizer(id,"|");
			String masterPartId= token.nextToken();
			DomainObject domObj = new DomainObject(masterPartId);
			String strvalue= domObj.getInfo(context,"attribute["+ATTRIBUTE_REFERENCE_TYPE+"]");
			if(actionType.equals("assignedReference"))  {
								 key ="byMaster";
								 if ((strvalue.equals("R")) || (strvalue.equals("U"))) {
										 isUnAssignedReference = true;
	
			           }
			   }
			if (isUnAssignedReference) {
						%>
						<script>
						//XSSOK
						alert("<%=alert4%>");
						</script>
						<%
			}	 else {
			String url = "../common/emxFullSearch.jsp?field=TYPES=type_Part&includeOIDprogram=emxPartFamily:getUnAssignedPartsforMasterInFullSearch&HelpMarker=emxhelpfullsearch&table=AEFGeneralSearchResults&freezePane=Name,Matches&selection=multiple&submitURL=../engineeringcentral/SearchUtil.jsp&suiteKey=EngineeringCentral&objectId="+objectId+"&MasterId="+masterPartId+"&addMasterReference=addMasterReference";
		%>
			<script>
		   //XSSOK
				showModalDialog('<%=url%>',800,575);
			</script>
		<%
		}
		}
	} else {
	boolean isMasters = false;
	boolean isUnAssigned = false;
	boolean isReference = false;
	boolean isUnAssignedReference = false;
	if(key == null)
		key = "";
	/*String alert1 = i18nNow.getI18nString("emxEngineeringCentral.Common.CommandOnlyallowsUnAssignedPartstobeAssignedasaMaster","emxEngineeringCentralStringResource", language);
	String alert2 = i18nNow.getI18nString("emxEngineeringCentral.Common.CommandOnlyallowsMasterPartsPartstobeUnAssigned","emxEngineeringCentralStringResource", language);
	String alert3 = i18nNow.getI18nString("emxEngineeringCentral.Common.CommandOnlyallowsReferencePartstobeRemoved","emxEngineeringCentralStringResource", language);
	String err1 = i18nNow.getI18nString("emxEngineeringCentral.Common.PleaseMakeSelection","emxEngineeringCentralStringResource", language);
	String msg1 = i18nNow.getI18nString("emxEngineeringCentral.Common.Doyouwishtoassignpartasamaster","emxEngineeringCentralStringResource", language);
	String msg2 = i18nNow.getI18nString("emxEngineeringCentral.Common.AreyouSureyouwanttoUnAssignthispartasaMaster","emxEngineeringCentralStringResource", language);
	String msg3 = i18nNow.getI18nString("emxEngineeringCentral.Common.AreyouSureyouwanttoRemovethis/thesePart/PartsasReference","emxEngineeringCentralStringResource", language);
*/
String alert1 = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.CommandOnlyallowsUnAssignedPartstobeAssignedasaMaster");
String alert2 = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.CommandOnlyallowsMasterPartsPartstobeUnAssigned");
String alert3 = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.CommandOnlyallowsReferencePartstobeRemoved");
String err1 = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.PleaseMakeSelection");
String msg1 = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.Doyouwishtoassignpartasamaster");
String msg2 = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.AreyouSureyouwanttoUnAssignthispartasaMaster");
String msg3 = EnoviaResourceBundle.getProperty(context ,"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.AreyouSureyouwanttoRemovethis/thesePart/PartsasReference");

	try {
			if(tableRowId==null) {
			%>

 <script language="Javascript">
 //XSSOK
		alert("<%=err1%>");
		parent.closeWindow();
 </script>

			<%  }
			String[] strPartlist= new String[tableRowId.length];
			for (int i=0;i<tableRowId.length;i++) {
				String strid=tableRowId[i];
				StringTokenizer strtkn = new StringTokenizer(strid,"|");
				String partID= strtkn.nextToken();
				strPartlist[i] = partID;
				DomainObject domObj = new DomainObject(partID);
				String strval= domObj.getInfo(context,"attribute["+ATTRIBUTE_REFERENCE_TYPE+"]");

				if (actionType.equals("unassignedMaster"))  {
				   key ="toUnassign";
				   if (strval.equals("U") || strval.equals("R")) {
							isUnAssigned = true;
							break;
				    }
				}  else if(actionType.equals("assignedMaster"))  {
								   key ="toMaster";
								   if ((strval.equals("M")) || (strval.equals("R"))) {
					             isMasters = true;
					             break;
				    }
			  }  else if(actionType.equals("unassignedReference"))  {
								   key ="fromMaster";
								   if ((strval.equals("U")) || (strval.equals("M"))) {
					             isReference = true;
					             break;
			     }
				}
		}
		session.setAttribute("selectedPartlist",strPartlist);
			tableRowId = (String[])session.getAttribute("selectedPartlist");
			session.removeAttribute("selectedPartlist");
		}
	    catch (Exception e){  }

		     if(isMasters) {
		     %>
		     <script>
		     //XSSOK
		      alert("<%=alert1%>");
		      parent.closeWindow();
		     </script>
		     <%
		     }

		     else if (isUnAssigned) {
						%>
						<script>
						//XSSOK
						alert("<%=alert2%>");
						parent.closeWindow();
						</script>
						<%
				}  else if (isReference) {
						%>
						<script>
						//XSSOK
						alert("<%=alert3%>");
						parent.closeWindow();
						</script>
						<%
				}
				else if (actionType.equals("assignedMaster") && tableRowId != null)
							{
						%>
					
					 <script>
					//XSSOK
								var res = window.confirm("<%=msg1%>");
								if (res) {
									<%
									session.setAttribute("tableRowIds",tableRowId);
									%>
										var form = document.formProcess;
									//XSSOK
									form.action = "emxPartFamilyMasterProcess.jsp?objectId=<%=objectId%>&action=process&key=<%=key%>&actionType=<%=actionType%>";
										form.submit();
								}  else {
										//getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
										var frameRefresh = getTopWindow().openerFindFrame(getTopWindow(),"detailsDisplay");
										frameRefresh.getTopWindow().refreshTablePage();									
										parent.closeWindow();
									 }
					</script>
						<%
					 }
			  else if (actionType.equals("unassignedMaster") && tableRowId != null)
									{
								%>
					
				   <script>
				 //XSSOK
							var res = window.confirm("<%=msg2%>");
							if (res) {
								<%
								session.setAttribute("tableRowIds",tableRowId);
								%>
									var form = document.formProcess;
									//XSSOK
								form.action = "emxPartFamilyMasterProcess.jsp?objectId=<%=objectId%>&action=process&key=<%=key%>&actionType=<%=actionType%>";
									form.submit();
							}  else {
									//getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
									var frameRefresh = getTopWindow().openerFindFrame(getTopWindow(),"detailsDisplay");
									frameRefresh.getTopWindow().refreshTablePage();			
									parent.closeWindow();
							 }
					</script>
			<%	}
			  else if (actionType.equals("unassignedReference") && tableRowId != null)
									{
								%>
								
<script>
						//XSSOK
						var res = window.confirm("<%=msg3%>");
						if (res) {
 								<%
							session.setAttribute("tableRowIds",tableRowId);
 								%>
							  var form = document.formProcess;
							  //XSSOK
							form.action = "emxPartFamilyMasterProcess.jsp?objectId=<%=objectId%>&action=process&key=<%=key%>&actionType=<%=actionType%>";
	form.submit();
						}  else {
						    //getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
						    var frameRefresh = getTopWindow().openerFindFrame(getTopWindow(),"detailsDisplay");
							frameRefresh.getTopWindow().refreshTablePage();			
						    parent.closeWindow();
   }
</script>
<% } %>

<% } %>


