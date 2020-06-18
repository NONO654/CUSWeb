<%--
  emxRouteEditAccessProcess.jsp --
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  static const char RCSID[] = "$Id: emxRouteEditAccessProcess.jsp.rca 1.7 Wed july 11 16:18:32 2008 przemek Experimental przemek $";
--%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="emxRouteInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js"
type="text/javascript">
</script>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
	String typeRoute      = DomainObject.TYPE_ROUTE;
	String sProjectAccess = DomainObject.ATTRIBUTE_PROJECT_ACCESS;
	String relRouteScope  = DomainObject.RELATIONSHIP_ROUTE_SCOPE;
	String relProjectMembership = DomainObject.RELATIONSHIP_PROJECT_MEMBERSHIP;

	HashMap map = new HashMap();
	String sAccess = "";
	String sLead = "";
	String sRoute = "";
	String sPersonName = "";
	String memberId = "";
	String isLead = "";
	String strOldAccess = "";
	String count    = emxGetParameter(request, "count");
	String objectId = emxGetParameter(request, "objectId");
	String sType    = emxGetParameter(request, "type");
	boolean isRevised = false;

	String sObjId = emxGetParameter(request, "busIdArrayHidden");
	if (sObjId == null) {
		sObjId = "";
	}
	String sContent = emxGetParameter(request, "contentArrayHidden");
	if (sContent == null) {
		sContent = "";
	}

	RouteTemplate routeTemplateId = (RouteTemplate) (DomainObject.newInstance(context, DomainConstants.TYPE_ROUTE_TEMPLATE));
	DomainObject BaseObject = DomainObject.newInstance(context, objectId);
	Route route = (Route) DomainObject.newInstance(context, DomainConstants.TYPE_ROUTE);

	// build the type and rel patterns for each type
	Pattern typePattern = null;
	Pattern relPattern = null;
	boolean checkSubscribe = false;
	boolean checkNoneAccess = false;

	//  If the edit all page opens and the route template is in Active state, 
	//  revise the route template

	routeTemplateId.setId(objectId);
	String templateState = routeTemplateId.getInfo(context, DomainObject.SELECT_CURRENT);
	if (templateState.equals(DomainObject.STATE_ROUTE_TEMPLATE_ACTIVE)) {
		isRevised = true;
		String revisionId = routeTemplateId.revise(context);
		BaseObject.setId(revisionId);
		objectId = revisionId;
	} else
		BaseObject.setId(objectId);

	try {
		Hashtable revokeMap        = new Hashtable();
		AccessUtil leadAccessUtil  = new AccessUtil();
		AccessUtil accessUtil      = new AccessUtil();
		StringTokenizer objIdToken = null;
		objIdToken = new StringTokenizer(sObjId, ",");
		StringTokenizer contentToken = new StringTokenizer(sContent, ",");
		StringTokenizer accessToken = null;
		String strPersonAccess = "";

		while (contentToken.hasMoreTokens()) {
			strPersonAccess = contentToken.nextToken();
			if (!sObjId.equals("") && sObjId != null) {
				memberId = objIdToken.nextToken();
				if (memberId.indexOf("memberId") != -1) {
					memberId = null;
				} else {
					memberId = memberId.trim();
				}
			}
			accessToken = new StringTokenizer(strPersonAccess, "~");
			while (accessToken.hasMoreTokens()) {

				sLead = accessToken.nextToken();
				sLead = sLead.trim();
				sRoute = accessToken.nextToken();
				sRoute = sRoute.trim();
				sAccess = accessToken.nextToken();
				sAccess = sAccess.trim();
				sPersonName = accessToken.nextToken();
				sPersonName = sPersonName.trim();
				isLead = accessToken.nextToken();
				isLead = isLead.trim();
				strOldAccess = accessToken.nextToken();
				strOldAccess = strOldAccess.trim();

				if (context.getUser().equalsIgnoreCase(sPersonName)&& sAccess.equalsIgnoreCase("None")) {
					checkNoneAccess = true;
				}
				StringList grantorList = new StringList();

				// checking for access is not null then only do anything about grant or revoke
				if (sAccess != null && !"".equals(sAccess)
						&& !"null".equals(sAccess)) {

					// Checking for this person not a lead and revoke lead access if he was a lead
					if (sLead == null || sLead.equals("null")) {

						// to avoid building accesslist if no change
						if (!strOldAccess.equals(sAccess)
								|| "true".equals(isLead)) {

							if ("true".equals(isLead)) {
								grantorList.add(AccessUtil.WORKSPACE_LEAD_GRANTOR);
								revokeMap.put(sPersonName, grantorList);
							}

							if ("Read".equals(sAccess)) {
								accessUtil.setRead(sPersonName);
							} else if ("Read Write".equals(sAccess)) {
								accessUtil.setReadWrite(sPersonName);
							} else if ("Add".equals(sAccess)) {
								accessUtil.setAdd(sPersonName);
							} else if ("Remove".equals(sAccess)) {
								accessUtil.setRemove(sPersonName);
							} else if ("Add Remove".equals(sAccess)) {
								accessUtil.setAddRemove(sPersonName);
							} else {

								if ("true".equals(isLead)) {
									String grantorCommand = "print bus "
											+ objectId
											+ " select grant[,"
											+ sPersonName
											+ "].grantor dump |;";
									String objectGrntor = MqlUtil.mqlCommand(context,grantorCommand);
									if (objectGrntor.indexOf(AccessUtil.ROUTE_ACCESS_GRANTOR) != -1) {
										grantorList.add(AccessUtil.ROUTE_ACCESS_GRANTOR);
									}
								} else {
									grantorList.add(AccessUtil.ROUTE_ACCESS_GRANTOR);
									revokeMap.put(sPersonName, grantorList);
									//accessUtil.setNoGlobalRead(sPersonName);
									// sets blank access mask to the accesslist
								}
							}
						}
					} else {
						// Check this person is already a project lead or not
						// If he is lead don't do any thing other wise grant him lead access
						if (!"true".equals(isLead)) {
							leadAccessUtil.setWorkspaceLead(sPersonName);
						}
					}
					if (memberId != null && !memberId.equals("")) {
						BaseObject.setId(memberId);
					}
				}
			} //End for second while loop
		}//End for first while loop

		try {
			AccessList memberAccessList = accessUtil.getAccessList();
			AccessList leadAccessList = leadAccessUtil.getAccessList();
			Workspace.editAccess(context, objectId, memberAccessList, leadAccessList, revokeMap);
		} catch (Exception exp) {
			// check if there are any access violations

			String exString = exp.getMessage();
			if (exString.indexOf("ACCESS DENIED") > -1) {
				throw (exp);
			} else {
				session.putValue("error.message", exp.getMessage());
			}
		}
%>

<%
	} catch (Exception ex) {
		session.putValue("error.message", ex);
%>

<%
	}
%>

<html>
<body>


	<script>


  <%String strpopUpURL = UINavigatorUtil.getCommonDirectory(context)+ "/emxTree.jsp?objectId="+ XSSUtil.encodeForURL(context, objectId) + "&emxSuiteDirectory=" + XSSUtil.encodeForURL(context, appDirectory);
   if (checkNoneAccess == true) {%>
   var newTree = getTopWindow().getWindowOpener().getTopWindow().tempTree;
   var nodeVar = newTree.root;
    for (var i=0; i < nodeVar.childNodes.length; i++) {
      if (nodeVar.childNodes[i].text == '<%=XSSUtil.encodeForJavaScript(context, getI18NString("emxComponentsStringResource", "emxFramework.Command.Folder", request.getHeader("Accept-Language")))%>')
      {
        var nodeCollapse = nodeVar.childNodes[i];
        nodeCollapse.collapse();
        break;
      }
    }
    getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
    window.closeWindow();
  <%} else {
				if (isRevised) {%>
  	getTopWindow().getWindowOpener().parent.location.href  = '<%=strpopUpURL%>';
  	getTopWindow().closeWindow();   
   
  <%} else {%>
       getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
       window.closeWindow();     
      
      <%}
	}%>
		
	</script>
</body>
</html>
