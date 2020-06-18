<%--
  emxRouteEditAccessProcess.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxRouteEditAccessProcess.jsp.rca 1.7 Wed Oct 22 16:18:32 2008 przemek Experimental przemek $";

--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "emxRouteInclude.inc" %>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<%
	String typeRoute          = DomainObject.TYPE_ROUTE;
    String typeThread         = DomainObject.TYPE_THREAD;
    String typeMessage        = DomainObject.TYPE_MESSAGE;
    String typeDocument       = DomainObject.TYPE_DOCUMENT;
    String typeWorkspace      = DomainObject.TYPE_PROJECT;
    String typeWorkspaceVault = DomainObject.TYPE_PROJECT_VAULT;

    String sCreateRoute       = DomainObject.ATTRIBUTE_CREATE_ROUTE;
    String sProjectAccess     = DomainObject.ATTRIBUTE_PROJECT_ACCESS;
    String sCreateFolder      = DomainObject.ATTRIBUTE_CREATE_FOLDER;

    String relReply           =  DomainObject.RELATIONSHIP_REPLY;
    String relThread          =  DomainObject.RELATIONSHIP_THREAD;
    String relMessage         =  DomainObject.RELATIONSHIP_MESSAGE;
    String relSubVaults       =  DomainObject.RELATIONSHIP_SUB_VAULTS;
    String relRouteScope      =  DomainObject.RELATIONSHIP_ROUTE_SCOPE;
    String relVaultedObjects  =  DomainObject.RELATIONSHIP_VAULTED_DOCUMENTS;
    String relWorkspaceVaults =  DomainObject.RELATIONSHIP_WORKSPACE_VAULTS;
    String relSubscribedItem  =  DomainObject.RELATIONSHIP_SUBSCRIBED_ITEM;
    String relSubscribedPerson    =  DomainObject.RELATIONSHIP_SUBSCRIBED_PERSON;
    String relPushedSubscription  =  DomainObject.RELATIONSHIP_PUSHED_SUBSCRIPTION;
    String relProjectMembership   =  DomainObject.RELATIONSHIP_PROJECT_MEMBERSHIP;

    HashMap map = new HashMap();
    String sAccess      = "";
    String sLead        = "";
    String sRoute       = "";
    String sFolder      = "";
    String sPersonName  = "";
    String memberId     = "";
    String isLead       = "";
    String strOldAccess = "";
    String count        = emxGetParameter(request, "count");
    String objectId     = emxGetParameter(request,"objectId");

    String sType        = emxGetParameter(request,"type");
	

    String sObjId   = emxGetParameter(request,"busIdArrayHidden");
    if(sObjId == null){sObjId ="";}
    String sContent  = emxGetParameter(request,"contentArrayHidden");
    if(sContent == null){sContent ="";}


    WorkspaceVault folder     = (WorkspaceVault) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT);
    Workspace workspace       = (Workspace) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE);
    Document document         = (Document) DomainObject.newInstance(context,DomainConstants.TYPE_DOCUMENT);
    Message message           = (Message) DomainObject.newInstance(context,DomainConstants.TYPE_MESSAGE);
    DomainObject BaseObject   = DomainObject.newInstance(context,objectId);
    Route route               = (Route) DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);

    // build the type and rel patterns for each type
    Pattern typePattern = null;
    Pattern relPattern = null;
    boolean checkSubscribe = false;

    boolean checkNoneAccess = false;
    if(typeWorkspace.equals(sType))
    {
      typePattern = new Pattern(typeWorkspaceVault);
      typePattern.addPattern(typeRoute);
      typePattern.addPattern(typeDocument);
      typePattern.addPattern(typeThread);
      typePattern.addPattern(typeMessage);

      relPattern = new Pattern(relWorkspaceVaults);
      relPattern.addPattern(relVaultedObjects);
      relPattern.addPattern(relSubVaults);
      relPattern.addPattern(relRouteScope);
      relPattern.addPattern(relThread);
      relPattern.addPattern(relMessage);
      relPattern.addPattern(relReply);

      checkSubscribe = true;
    }
    else if(typeWorkspaceVault.equals(sType))
    {
      typePattern = new Pattern(typeWorkspaceVault);
      typePattern.addPattern(typeRoute);
      typePattern.addPattern(typeDocument);
      typePattern.addPattern(typeThread);
      typePattern.addPattern(typeMessage);

      relPattern = new Pattern(relVaultedObjects);
      relPattern.addPattern(relSubVaults);
      relPattern.addPattern(relRouteScope);
      relPattern.addPattern(relThread);
      relPattern.addPattern(relMessage);
      relPattern.addPattern(relReply);

      checkSubscribe = true;
    }
    else if(typeDocument.equals(sType))
    {
      typePattern = new Pattern(typeThread);
      typePattern.addPattern(typeMessage);
      relPattern = new Pattern(relThread);
      relPattern.addPattern(relMessage);
      relPattern.addPattern(relReply);
      checkSubscribe = true;
    }


    try {
      BaseObject.setId(objectId);
      Hashtable revokeMap = new Hashtable();
      AccessUtil leadAccessUtil = new AccessUtil();
      AccessUtil accessUtil = new AccessUtil();
      StringTokenizer  objIdToken = null;

	        objIdToken  = new StringTokenizer(sObjId,",");
		StringTokenizer  contentToken  = new StringTokenizer(sContent,",");
		StringTokenizer  accessToken   = null;
		String strPersonAccess   = "";
        	while(contentToken.hasMoreTokens())
		{
			strPersonAccess = contentToken.nextToken();
			if(!sObjId.equals("") && sObjId != null)
			{
			   memberId = objIdToken.nextToken();
			   if(memberId.indexOf("memberId") !=-1)
			   {
			     memberId = null;
			   }
			   else{
			     memberId = memberId.trim();
			   }
			}
			accessToken  = new  StringTokenizer(strPersonAccess,"~");
			while(accessToken.hasMoreTokens())
			{

				sLead	  		= 	accessToken.nextToken();
				sLead			=	sLead.trim();
				sRoute			=	accessToken.nextToken();
				sRoute			=	sRoute.trim();
				sFolder			=	accessToken.nextToken();
				sFolder			=	sFolder.trim();
				sAccess			=	accessToken.nextToken();
				sAccess			=	sAccess.trim();
				sPersonName		=	accessToken.nextToken();
				sPersonName		=	sPersonName.trim();
				isLead			=	accessToken.nextToken();
				isLead			=	isLead.trim();
				strOldAccess	=	accessToken.nextToken();
				strOldAccess	=	strOldAccess.trim();

				if(context.getUser().equalsIgnoreCase(sPersonName) && sAccess.equalsIgnoreCase("None"))
				{
					checkNoneAccess = true;

				}

		        StringList grantorList = new StringList();


				// checking for access is not null then only do anything about grant or revoke
				if(sAccess != null && !"".equals(sAccess) &&  !"null".equals(sAccess)){

				  // Checking for this person not a lead and revoke lead access if he was a lead
				  if(sLead == null || sLead.equals("null")){

					// to avoid building accesslist if no change
					if(!strOldAccess.equals(sAccess) ||  "true".equals(isLead)){


					   if("true".equals(isLead)) {
						  grantorList.add(AccessUtil.WORKSPACE_LEAD_GRANTOR);
						  revokeMap.put(sPersonName,grantorList);
					   }

					   if("Read".equals(sAccess)){
						 accessUtil.setRead(sPersonName);
					   }else if("Read Write".equals(sAccess)){
						 accessUtil.setReadWrite(sPersonName);
					   }else if("Add".equals(sAccess))
					   {
						 accessUtil.setAdd(sPersonName);
					   }else if("Remove".equals(sAccess)){
						 accessUtil.setRemove(sPersonName);
					   }else if("Add Remove".equals(sAccess)){
						 accessUtil.setAddRemove(sPersonName);
					   }else{

						 if("true".equals(isLead)) {

							String grantorCommand =  "print bus " + objectId + " select grant[,"+ sPersonName +"].grantor dump |;";
							String objectGrntor = MqlUtil.mqlCommand(context,grantorCommand);
							if ( objectGrntor.indexOf(AccessUtil.WORKSPACE_ACCESS_GRANTOR) != -1 ){
								  grantorList.add(AccessUtil.WORKSPACE_ACCESS_GRANTOR);
								}
						 } else {
						   //<Fix 372839>  
						   grantorList.add(AccessUtil.ROUTE_ACCESS_GRANTOR);
						   //</Fix 372839>
						   revokeMap.put(sPersonName,grantorList);
						   //accessUtil.setNoGlobalRead(sPersonName);// sets blank access mask to the accesslist
						 }

						 // remove all subscriptions that this person has to the given object, also remove from the sub-level objects.
						 // check is done only for Workspace, Folder and Document objects
						 if(checkSubscribe && memberId != null && !"".equals(memberId) &&  !"null".equals(memberId)){
						   // check for subscriptions only if "SubscribedItem" Rel exists for the project member
						   DomainObject projectMemberObject = DomainObject.newInstance(context,memberId);
						   StringList subscribedItemList = projectMemberObject.getInfoList(context, "to["+relSubscribedItem+"].from.id");
						   String personId = projectMemberObject.getInfo(context, "to["+relProjectMembership+"].from.id");
						   String personName = projectMemberObject.getInfo(context, "to["+relProjectMembership+"].from.name");

						   if(subscribedItemList.size() > 0){
							 // check for the current object, remove all subscriptions for the user
							  if(sType.equals(typeWorkspace)){
								workspace.setId(objectId);
								SubscriptionManager subscriptionMgr = workspace.getSubscriptionManager();
								subscriptionMgr.removeAllSubscriptions(context, objectId, personId, memberId);
							  }else if(sType.equals(typeWorkspaceVault)){
								folder.setId(objectId);
								SubscriptionManager subscriptionMgr = folder.getSubscriptionManager();
								subscriptionMgr.removeAllSubscriptions(context, objectId, personId, memberId);
							  }else if(sType.equals(typeDocument)){
								document.setId(objectId);
								SubscriptionManager subscriptionMgr = document.getSubscriptionManager();
								subscriptionMgr.removeAllSubscriptions(context, objectId, personId, memberId);
							  }else if(sType.equals(typeMessage)){
								message.setId(objectId);
								SubscriptionManager subscriptionMgr = message.getSubscriptionManager();
								subscriptionMgr.removeAllSubscriptions(context, objectId, personId, memberId);
							  }

							   StringList objectSelects = new StringList();
							   objectSelects.addElement(BaseObject.SELECT_ID);
							   objectSelects.addElement(BaseObject.SELECT_TYPE);

							   DomainObject domainObject = DomainObject.newInstance(context,objectId);
							   //loop thro. and get all the objects down and check for subscriptions
							   MapList objectMapList = domainObject.getRelatedObjects
													   (context,
														relPattern.getPattern(),  //relationshipPattern
														typePattern.getPattern(), //typePattern
														objectSelects,            //objectSelects
														new StringList(),         //relationshipSelects
														false,                     //getTo
														true,                     //getFrom
														(short)0,                 //recurseToLevel
														"",                       //objectWhere
														""                        //relationshipWhere
													   );

							  Iterator objectItr = objectMapList.iterator();
							  //iterate thro. the objects and remove the subscriptions for the user
							while(objectItr.hasNext()){
							  Map objectMap = (Map) objectItr.next();
							  String subscribedId = (String) objectMap.get(BaseObject.SELECT_ID);
							  String subscribedType = (String) objectMap.get(BaseObject.SELECT_TYPE);

							  DomainObject subscribedObject = DomainObject.newInstance(context,subscribedId);

							  if(subscribedType.equals(typeWorkspace)){
								workspace.setId(subscribedId);
								SubscriptionManager subscriptionMgr = workspace.getSubscriptionManager();
								subscriptionMgr.removeAllSubscriptions(context, subscribedId, personId, memberId);
							  }else if(subscribedType.equals(typeWorkspaceVault)){
								folder.setId(subscribedId);
								SubscriptionManager subscriptionMgr = folder.getSubscriptionManager();
								subscriptionMgr.removeAllSubscriptions(context, subscribedId, personId, memberId);
							  }else if(subscribedType.equals(typeDocument)){
								document.setId(subscribedId);
								SubscriptionManager subscriptionMgr = document.getSubscriptionManager();
								subscriptionMgr.removeAllSubscriptions(context, subscribedId, personId, memberId);
							  }else if(subscribedType.equals(typeMessage)){
								message.setId(subscribedId);
								SubscriptionManager subscriptionMgr = message.getSubscriptionManager();
								subscriptionMgr.removeAllSubscriptions(context, subscribedId, personId, memberId);
							  }else if(subscribedType.equals(typeRoute)){
								route.setId(subscribedId);
								SubscriptionManager subscriptionMgr = route.getSubscriptionManager();
								subscriptionMgr.removeAllSubscriptions(context, subscribedId, personId, memberId);
							  }
							}
						   }
						 }
					   }
					 }
				   }else{
					 // Check this person is already a project lead or not
					 // If he is lead don't do any thing other wise grant him lead access
					 if(!"true".equals(isLead)){
					   leadAccessUtil.setWorkspaceLead(sPersonName);
					 }
				   }
				   if(memberId != null && !memberId.equals("")) {
					 BaseObject.setId(memberId);
					 if(typeWorkspace.equals(sType)){
					   if("lead".equals(sLead)) {
						 map.put(sProjectAccess,"Project Lead");
					   }else{
						 map.put(sProjectAccess,"Project Member");
					   }
					   if("route".equals(sRoute)){
						 map.put(sCreateRoute,"Yes");
					   }else{
						 map.put(sCreateRoute,"No");
					   }
					   if("folder".equals(sFolder)){
						 map.put(sCreateFolder,"Yes");
					   }else{
						 map.put(sCreateFolder,"No");
					   }
					   BaseObject.setAttributeValues(context,map);
					 }
				   }
				 }
			 } //End for second while loop
   }//End for first while loop

    try {
      AccessList memberAccessList = accessUtil.getAccessList();
      AccessList leadAccessList = leadAccessUtil.getAccessList();
      Workspace.editAccess(context, objectId, memberAccessList, leadAccessList, revokeMap);
      //<Fix 372839>
      Route rtObj = (Route) DomainObject.newInstance(context, objectId, DomainConstants.TEAM);
      String[] contentIdArray = null;
      try{
          com.matrixone.apps.domain.util.ContextUtil.pushContext(context);
          contentIdArray = rtObj.getConnectedObjectIds(context);    
      } finally {
          com.matrixone.apps.domain.util.ContextUtil.popContext(context);
      }
      
      if(memberAccessList.size() > 0 && contentIdArray.length>0){
        try {
            JPO.invoke(context, "emxRoute", new String[]{objectId}, "inheritAccesstoContent", contentIdArray);
          }catch(Exception exp) {
            throw(exp);
          }
     }
     //</Fix 372839>
      }catch(Exception exp) {
        // check if there are any access violations
		
        String exString = exp.getMessage();
        if(exString.indexOf("ACCESS DENIED") > -1) {
          throw(exp);
        } else {
          session.putValue("error.message", exp.getMessage());
        }
      }
%>
      
<%
    } catch (Exception ex){
      session.putValue("error.message",ex);
%>
      
<%
    }
%>

<html>
<body>


<script>
	//XSSOK
    <framework:ifExpr expr="<%=checkNoneAccess%>">
   var newTree = getTopWindow().getWindowOpener().getTopWindow().tempTree;
	   if(newTree) {
   var nodeVar = newTree.root;
    for (var i=0; i < nodeVar.childNodes.length; i++) {
      if (nodeVar.childNodes[i].text == '<%=XSSUtil.encodeForJavaScript(context, i18nNow.getI18nString("emxFramework.Command.Folder","emxComponentsStringResource",request.getHeader("Accept-Language")))%>')
      {
        var nodeCollapse = nodeVar.childNodes[i];
        nodeCollapse.collapse();
        break;
      }
    }
	   }
    </framework:ifExpr>
    var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
    frameContent = frameContent != null ? frameContent : findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
    frameContent.document.location.href = frameContent.document.location.href;
    getTopWindow().closeWindow();
</script>
</body>
</html>
