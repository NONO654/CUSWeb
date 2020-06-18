<%--  emxRouteQuickCreateProcess.jsp  --  Editing Route object

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

static const char RCSID[] = $Id: emxRouteQuickCreateProcess.jsp.rca 1.22 Tue Oct 28 19:01:03 2008 przemek Experimental przemek $
 --%>

<%@ include file = "../emxUICommonAppInclude.inc" %>
<%@ include file = "emxRouteInclude.inc" %>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
  Hashtable routeDetails  =  new Hashtable();
  com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person)DomainObject.newInstance(context,DomainConstants.TYPE_PERSON);
  Route route = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  BusinessObject personObject = (BusinessObject)person.getPerson(context);
  for (Enumeration e = request.getParameterNames() ; e.hasMoreElements() ;) {
     String paramName = (String)e.nextElement();
     routeDetails.put(paramName , request.getParameter(paramName));
  }
  String objectId        = emxGetParameter(request,"objectId");
  String  restrictMembers       = emxGetParameter(request,"selscope");
  String  strTypeName       = emxGetParameter(request,"TypeName");
  String projectId = emxGetParameter(request,"workspaceFolderId");
  String  selscopeId ="";
  String scopeName= "";
  String folderType = "";  //352371
  if(restrictMembers.equals("ScopeName")){
        selscopeId = emxGetParameter(request,"workspaceFolderId");
        scopeName   = emxGetParameter(request,"workspaceFolder");
   }
   else if(restrictMembers.equals("Organization"))
   {
       selscopeId = restrictMembers;
   }
//Added for bug 352371 starts
  if(projectId != null && !"".equals(projectId) && !"null".equals(projectId))
  {
  DomainObject boProject = new DomainObject(projectId);
  folderType = boProject.getInfo(context,"type");
  }
//Added for bug 352371 ends
   if((strTypeName!=null || !"".equals(strTypeName) || !"null".equals(strTypeName)) && DomainObject.TYPE_DOCUMENT.equals(strTypeName)&& !com.matrixone.apps.domain.util.mxType.isOfParentType(context,folderType,com.matrixone.apps.domain.DomainObject.TYPE_WORKSPACE_VAULT))//Modified:16-Mar-09:wqy:R207:PRG Bug 370839
   {  // Modified for bug 352371){
	   selscopeId = objectId;
   }
  String routeId                = emxGetParameter(request, "routeId");
  String routeAutoName          = emxGetParameter(request, "routeAutoName");
  String routeCompletionAction  = emxGetParameter(request, "routeCompletionAction");
  String routeName              = emxGetParameter(request, "routeName");
  String routeDescription       = emxGetParameter(request, "txtdescription");
  String portalMode             = emxGetParameter(request,"portalMode");
  String routeBasePurpose       = emxGetParameter(request,"routeBasePurpose");
  String supplierOrgId          = emxGetParameter(request,"supplierOrgId");
  String suiteKey               = emxGetParameter(request,"suiteKey");
  String sTemplateId            = emxGetParameter(request, "templateId");
  String sTemplateName          = emxGetParameter(request, "template");
  String visblToParent          = emxGetParameter(request,"visblToParent");
  String strAutoStopOnRejection = emxGetParameter(request,"routeAutoStop");
  if(visblToParent == null || visblToParent.equals("null")){
          visblToParent = "";
   }
  
  boolean rtSelected = (sTemplateId != null && !"null".equals(sTemplateId) && !sTemplateId.equals(""));
  if(rtSelected)
	  new com.matrixone.apps.common.RouteTemplate(sTemplateId).checksToUseRouteTemplateInRoute(context);
  
  HashMap map1           = new HashMap();
  String sAttrRestrictMembers       = PropertyUtil.getSchemaProperty(context, "attribute_RestrictMembers" );
  String sAttrRouteBasePurpose      = PropertyUtil.getSchemaProperty(context, "attribute_RouteBasePurpose" );
  String sAttrRouteCompletionAction = PropertyUtil.getSchemaProperty(context, "attribute_RouteCompletionAction" );
  String attrOriginator             = PropertyUtil.getSchemaProperty(context, "attribute_Originator");
  final String ATTRIBUTE_AUTO_STOP_ON_REJECTION   = PropertyUtil.getSchemaProperty(context, "attribute_AutoStopOnRejection" );
  String routeAutoNameId            = null;
  boolean bExecute                  = false;
  String strProjectVault  = "";
  String revisionSequence = "";
  String strObjectVault = "";
  String strObjectName = "";
  String strObjectType = "";
  String sProjectId                = "";
  DomainObject sProjectObject = null;
  String sPrjType = null;
  if((objectId != null && !"".equals(objectId) && !"null".equals(objectId)) )//&& (restrictMembers.equals("All") || restrictMembers.equals("Organization")))
  //restrictMembers' condition is removed for IR-045678V6R2011
  {
    DomainObject boObject = new DomainObject(objectId);
    String sType  = boObject.getType(context);
	//Added for the Bug No: 338721 2 11/16/2007 4:30 PM Start 
    String objState=boObject.getInfo(context,DomainConstants.SELECT_CURRENT);
    routeDetails.put(objectId,objState);
    //Added for the Bug No: 338721 2 11/16/2007 4:30 PM End 
    boolean isProjId = false;
    try
    {
      if ((routeAutoName != null) && ("checked".equals(routeAutoName)) && !"null".equals(routeAutoName))
      {
        map1 = Route.createRouteWithScope(context , objectId , routeName , routeDescription , true,routeDetails );
      }
      else
      {
        map1 = Route.createRouteWithScope(context , objectId , routeName , routeDescription , false, routeDetails);
      }
      routeId = (String)map1.get("routeId");
      if(sProjectId != null && !sProjectId.equals(""))
      {
        sProjectId = (String)map1.get("workspaceId");
        sProjectObject = DomainObject.newInstance(context, sProjectId);
        sPrjType = sProjectObject.getInfo(context, DomainObject.SELECT_TYPE);
      }
    }catch(Exception ranc){
       throw new FrameworkException(ranc.getMessage());
    }
  }//eof if(objectId != null && !"".equals(objectId) && !"null".equals(objectId))
  else
  {
    //if no objectid exists
    if(restrictMembers.equals("All") || restrictMembers.equals("Organization"))
    {

       if(routeName == null || "null".equals(routeName) || "".equals(routeName))
       {

         routeAutoNameId = Route.routeName(context,"type_Route",revisionSequence,"policy_Route");
     route = (Route)DomainObject.newInstance(context,routeAutoNameId);
         routeId = route.getObjectId();
       }
       else
       {
     BusinessObject tempObj = new BusinessObject(DomainObject.TYPE_ROUTE,routeName,revisionSequence,strProjectVault);
     if (!tempObj.exists(context))
     {
       tempObj.create(context,DomainObject.POLICY_ROUTE);
       route = (Route)DomainObject.newInstance(context,tempObj);
       routeId = route.getObjectId();
     }
     else
     {
       // boRoute = (Route)DomainObject.newInstance(context,tempObj);
      com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();
      String text = loc.GetString("emxComponentsStringResource", request.getHeader("Accept-Language"), "emxComponents.CreateFolder.AlreadyExists");
      session.putValue("error.message"," " + text);
      bExecute = true;
     }

       }
     if (!bExecute)
    {
         route.connect(context,new RelationshipType(DomainObject.RELATIONSHIP_PROJECT_ROUTE),true, personObject);
    }
    }
    else
    {

  BusinessObject boscope = new BusinessObject(selscopeId);
  boscope.open(context);
  String sTypeName  = boscope.getTypeName();
  try
  {
        if ((routeAutoName != null) && ("checked".equals(routeAutoName)) && !"null".equals(routeAutoName))
        {
           map1 = Route.createRouteWithScope(context , selscopeId , routeName , routeDescription , true , routeDetails);
        }
        else
        {
            BusinessObject tempObj = new BusinessObject(DomainObject.TYPE_ROUTE,routeName,revisionSequence,strProjectVault);
            if (!tempObj.exists(context))
            {
                 map1 = Route.createRouteWithScope(context , selscopeId , routeName , routeDescription , false, routeDetails);
            }
             else
            {
                com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();
                String text = loc.GetString("emxComponentsStringResource", request.getHeader("Accept-Language"), "emxComponents.CreateFolder.AlreadyExists");
                session.putValue("error.message"," " + text);
                bExecute = true;
            }
        }
    if (!bExecute)
    {
      routeId = (String)map1.get("routeId");
    }
        }catch(Exception ranc){
          throw new FrameworkException(ranc.getMessage());
        }
     }// eof else
  }// eof else if no object Id Exists

if (!bExecute)
 {
  AttributeList routeAttrList = new AttributeList();
  routeAttrList.addElement(new Attribute(new AttributeType(attrOriginator),context.getUser()));
  routeAttrList.addElement(new Attribute(new AttributeType(sAttrRouteCompletionAction),routeCompletionAction));
  routeAttrList.addElement(new Attribute(new AttributeType(sAttrRouteBasePurpose),routeBasePurpose));
  routeAttrList.addElement(new Attribute(new AttributeType(ATTRIBUTE_AUTO_STOP_ON_REJECTION), strAutoStopOnRejection));// getting Auto Stop Attribute
  if( (selscopeId != null) && (!selscopeId.equals("")) )
    routeAttrList.addElement(new Attribute(new AttributeType(sAttrRestrictMembers),selscopeId));
  if (visblToParent != null && !"null".equals(visblToParent) && !"".equals(visblToParent) && "Yes".equalsIgnoreCase(visblToParent))
    routeAttrList.addElement(new Attribute(new AttributeType(DomainObject.ATTRIBUTE_SUBROUTE_VISIBILITY),"Yes"));
  route.setId(routeId);
  route.setAttributes(context,routeAttrList);
  route.setDescription(routeDescription);
  route.update(context);
// Bug No : 304201 Begin
  if (visblToParent != null && !"null".equals(visblToParent) && !"".equals(visblToParent) && "Yes".equalsIgnoreCase(visblToParent))
 {
    DomainObject taskObj=new DomainObject(objectId);
    String originator=taskObj.getInfo(context,DomainConstants.SELECT_ORIGINATOR);
	try{
    	ContextUtil.pushContext(context);
		StringList accessNames = DomainAccess.getLogicalNames(context, routeId);	
    	DomainAccess.createObjectOwnership(context, routeId, null, originator +"_PRJ", (String)accessNames.get(0),  DomainAccess.COMMENT_MULTIPLE_OWNERSHIP, false);
	} catch(Exception ex) {
    		throw new FrameworkException(ex);
    } finally {
    		ContextUtil.popContext(context);
    }
 }
// Bug No : 304201 End
  // To Add route template members to route via Route Node..
  BusinessObject routeTemplateObj             = null;
  BusinessObject personObj                    = null;

  SelectList selectPersonStmts                = null;
  SelectList selectPersonRelStmts             = null;
  ExpansionWithSelect personSelect            = null;
  RelationshipWithSelectItr relPersonItr      = null;
  Relationship relationShipRouteNode          = null;


  String routeActionValueStr                  = null;
  String routeSequenceValueStr                = null;
  String routeInstructionsValueStr            = null;
  String sRouteTitle                          = null;
  String routeTaskNameValueStr                = null;
  String routeTaskUser                        = null;
  String text                                 = null;
  String routeAssigneeDueDateOptStr           = null;
  String dueDateOffset                        = null;
  String dueDateOffsetFrom                    = null;
  // Added by Infosys for Bug # 303103 Date 05/11/2005
  String parallelNodeProcessionRule           = null;
  // Added for the bug 301391
  String reviewTask = "";
  String allowDelegation ="";

  Attribute routeTitle                        = null;
  Attribute routeActionAttribute              = null;
  Attribute routeOrderAttribute               = null;
  Attribute routeInstructionsAttribute        = null;
  Attribute templateTaskAttribute             = null;
  AttributeList attrList                      = null;
  Attribute routeAssigneeDueDateOptAttribute  = null;
  Attribute routeDueDateOffsetAttribute       = null;
  Attribute routeDateOffsetFromAttribute      = null;
  Attribute routeTaskUserAttribute            = null;
  // Added by Infosys for Bug # 303103 Date 05/11/2005
  Attribute parallelNodeProcessionRuleAttrib  = null;
  // Added for the bug 301391
  Attribute reviewTaskAttribute               = null;
  Attribute allowDelegationAttribute          = null;


  String strProjectId  = "";
  String templateTaskStr                      = PropertyUtil.getSchemaProperty(context, "attribute_TemplateTask");
  Hashtable routeNodeAttributesTable          = new Hashtable();

  if(rtSelected) {

    selectPersonStmts = new SelectList();
    AccessUtil accessUtil = new AccessUtil(); //Added for 376886

    // build select params for Relationship
    selectPersonRelStmts = new SelectList();
    selectPersonRelStmts.addAttribute(DomainObject.ATTRIBUTE_ROUTE_SEQUENCE);
    selectPersonRelStmts.addAttribute(DomainObject.ATTRIBUTE_ROUTE_ACTION);
    selectPersonRelStmts.addAttribute(DomainObject.ATTRIBUTE_ROUTE_INSTRUCTIONS);
    selectPersonRelStmts.addAttribute(DomainObject.ATTRIBUTE_TITLE);
    selectPersonRelStmts.addAttribute(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE);
    selectPersonRelStmts.addAttribute(DomainObject.ATTRIBUTE_DUEDATE_OFFSET);
    selectPersonRelStmts.addAttribute(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM);
    selectPersonRelStmts.addAttribute(DomainObject.ATTRIBUTE_ROUTE_TASK_USER);
    // Added by Infosys for Bug # 303103 Date 05/11/2005
    String strParallelNodeProscessionRule = PropertyUtil.getSchemaProperty(context, "attribute_ParallelNodeProcessionRule");
    // Added for the bug 301391
    String  sAttReviewTask               =  PropertyUtil.getSchemaProperty(context,"attribute_ReviewTask");

    selectPersonRelStmts.addAttribute(strParallelNodeProscessionRule);
    // Added for the bug 301391
    selectPersonRelStmts.addAttribute(sAttReviewTask); // Bug No :308941
    selectPersonRelStmts.addAttribute(DomainObject.ATTRIBUTE_ALLOW_DELEGATION);// Bug No :308941



    routeTemplateObj = new BusinessObject(sTemplateId);
    routeTemplateObj.open(context);
    try{
     //21 nov route.connectTemplate(context,sTemplateId);
    route.connectTemplate(context,sTemplateId);
    } catch(Exception e){
     session.putValue("error.message",e.getMessage());
    }
    Pattern typePattern = new Pattern(DomainObject.TYPE_PERSON);
    typePattern.addPattern(DomainObject.TYPE_ROUTE_TASK_USER);
    personSelect = routeTemplateObj.expandSelect(context,DomainObject.RELATIONSHIP_ROUTE_NODE,typePattern.getPattern(),
                                     selectPersonStmts,selectPersonRelStmts,false, true, (short)1);

    routeTemplateObj.close(context);
    relPersonItr = new RelationshipWithSelectItr(personSelect.getRelationships());
    // loop thru the rels and get the route object
    while ((relPersonItr != null ) && relPersonItr.next()) {
      if ( relPersonItr.obj().getTypeName().equals(DomainObject.RELATIONSHIP_ROUTE_NODE)) {
        personObj = relPersonItr.obj().getTo();
        if (personObj != null)   {
          personObj.open(context);

          if((DomainObject.TYPE_ROUTE_TASK_USER).equals(personObj.getTypeName()) || ((DomainObject.TYPE_PERSON).equals(personObj.getTypeName()))  ) {

            try{
              relationShipRouteNode = route.connect(context, new RelationshipType(DomainObject.RELATIONSHIP_ROUTE_NODE),true,personObj);
            } catch(Exception ex){
              session.putValue("error.message",ex.getMessage());
            }

            routeNodeAttributesTable    =  relPersonItr.obj().getRelationshipData();
            routeSequenceValueStr       = (String) routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_ROUTE_SEQUENCE + "]" );
            sRouteTitle                 = (String) routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_TITLE + "]" );
            routeActionValueStr         = (String) routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_ROUTE_ACTION + "]" );
            routeInstructionsValueStr   = (String) routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_ROUTE_INSTRUCTIONS + "]" );
            routeTaskNameValueStr       = (String) routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_TITLE + "]" );
            routeAssigneeDueDateOptStr  = (String) routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE + "]" );
            dueDateOffset               = (String) routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_DUEDATE_OFFSET + "]" );
            dueDateOffsetFrom           = (String) routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_DATE_OFFSET_FROM + "]" );
            routeTaskUser               = (String) routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_ROUTE_TASK_USER + "]" );
            // Added by Infosys for Bug # 303103 Date 05/11/2005
            parallelNodeProcessionRule  = (String) routeNodeAttributesTable.get("attribute[" + strParallelNodeProscessionRule + "]" );
		    // Added for the bug 301391
            reviewTask = (String)routeNodeAttributesTable.get("attribute["+sAttReviewTask+"]");
		    allowDelegation = (String)routeNodeAttributesTable.get("attribute[" +DomainObject.ATTRIBUTE_ALLOW_DELEGATION+ "]" );

            attrList = new AttributeList();
            relationShipRouteNode.open(context);

            // Added by Infosys for Bug # 303103 Date 05/11/2005
            // set parallelNodeProcessionRule
            parallelNodeProcessionRuleAttrib  = new Attribute(new AttributeType(strParallelNodeProscessionRule),parallelNodeProcessionRule);
            attrList.addElement(parallelNodeProcessionRuleAttrib);

            // set title
            routeTitle  = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_TITLE),sRouteTitle);
            attrList.addElement(routeTitle);

            // set route action
            if ( routeActionValueStr != null ) {
              routeActionAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ROUTE_ACTION),routeActionValueStr);
              attrList.addElement(routeActionAttribute);
            }

            // set route order
            routeOrderAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ROUTE_SEQUENCE),routeSequenceValueStr);
            attrList.addElement(routeOrderAttribute);

            // set route instructions
            if ( routeInstructionsValueStr != null ) {
              routeInstructionsAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ROUTE_INSTRUCTIONS),routeInstructionsValueStr);
              attrList.addElement(routeInstructionsAttribute);
            }

            templateTaskAttribute = new Attribute(new AttributeType(templateTaskStr),"Yes");
            attrList.addElement(templateTaskAttribute);

            // set route assignee due date option
            if ( routeAssigneeDueDateOptStr != null ) {
              routeAssigneeDueDateOptAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE),routeAssigneeDueDateOptStr);
              attrList.addElement(routeAssigneeDueDateOptAttribute);
            }

            // set route due date offset
            if ( dueDateOffset != null ) {
              routeDueDateOffsetAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_DUEDATE_OFFSET),dueDateOffset);
              attrList.addElement(routeDueDateOffsetAttribute);
            }


            // set route due date offset from
            if( dueDateOffsetFrom != null ) {
              routeDateOffsetFromAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_DATE_OFFSET_FROM),dueDateOffsetFrom);
              attrList.addElement(routeDateOffsetFromAttribute);
            }

            // set route task user attribute
            if( routeTaskUser != null ) {
              routeTaskUserAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ROUTE_TASK_USER),routeTaskUser);
              attrList.addElement(routeTaskUserAttribute);
            }
            // Added for the bug 301391
            // set Review Task attribute
            if( reviewTask != null){
               reviewTaskAttribute = new Attribute(new AttributeType(sAttReviewTask),reviewTask);
               attrList.addElement(reviewTaskAttribute);
             }
	     	// set Allow Delegation attribute
             if( allowDelegation != null){
                allowDelegationAttribute = new Attribute(new AttributeType(DomainObject.ATTRIBUTE_ALLOW_DELEGATION),allowDelegation);
                attrList.addElement(allowDelegationAttribute);
            }

            relationShipRouteNode.setAttributes(context,attrList);
            relationShipRouteNode.close(context);
            
          	// Added for bug 376886
          	if(((DomainObject.TYPE_PERSON).equals(personObj.getTypeName())) || ((DomainObject.TYPE_ROUTE_TASK_USER).equals(personObj.getTypeName())))
          	{          	
	         	String personName = personObj.getName();
	         	System.out.println("Person Name :"+personName);
	         	if(DomainObject.TYPE_ROUTE_TASK_USER.equals(personObj.getTypeName()))
	         	    personName = PropertyUtil.getSchemaProperty(context,routeTaskUser);
	         	try{
	         	Access access = routeTemplateObj.getAccessForGranteeGrantor(context,personName, AccessUtil.ROUTE_ACCESS_GRANTOR);
	         	
	         	if (AccessUtil.hasAddRemoveAccess(access))
	         		accessUtil.setAccess(personName,AccessUtil.ROUTE_ACCESS_GRANTOR,accessUtil.getAddRemoveAccess());
	         	else if(AccessUtil.hasRemoveAccess(access))
	         	  	accessUtil.setAccess(personName,AccessUtil.ROUTE_ACCESS_GRANTOR,accessUtil.getRemoveAccess());
	         	else if(AccessUtil.hasAddAccess(access))
	         	  	accessUtil.setAccess(personName,AccessUtil.ROUTE_ACCESS_GRANTOR,accessUtil.getAddAccess());
	         	else if(AccessUtil.hasReadWriteAccess(access))
	         	  	accessUtil.setAccess(personName,AccessUtil.ROUTE_ACCESS_GRANTOR,accessUtil.getReadWriteAccess());
	         	else
	         	  	accessUtil.setAccess(personName,AccessUtil.ROUTE_ACCESS_GRANTOR,accessUtil.getReadAccess());
	         	}
	         	catch(MatrixException e)
	         	{
	         	    
	         	}
          	}
          	// Ended
            
          }
          personObj.close(context);
        }

      }
  }//End while
      
    if(accessUtil.getAccessList().size() > 0){
        //emxGrantAccess GrantAccess = new emxGrantAccess(DomainObject.newInstance(context,routeId));
        //GrantAccess.grantAccess(context, accessUtil);
        String[] args = new String[]{route.getObjectId()};
        JPO.invoke(context, "emxWorkspaceConstants", args, "grantAccess", JPO.packArgs(accessUtil.getAccessList()));
}

    //
    // Copy the value of Auto Stop On Rejection attribute from Route Template to Route object
    //
    final String SELECT_ATTRIBUTE_AUTO_STOP_ON_REJECTION = "attribute[" + ATTRIBUTE_AUTO_STOP_ON_REJECTION + "]";
    // Get value from template object
    DomainObject dmoRouteTemplate = new DomainObject(routeTemplateObj);
    strAutoStopOnRejection = dmoRouteTemplate.getInfo(context, SELECT_ATTRIBUTE_AUTO_STOP_ON_REJECTION);
    if (strAutoStopOnRejection != null && !"".equals(strAutoStopOnRejection) && !"null".equalsIgnoreCase(strAutoStopOnRejection)) {
        // Set value on route object
        route.setAttributeValue(context, ATTRIBUTE_AUTO_STOP_ON_REJECTION, strAutoStopOnRejection);
    }

    routeTemplateObj.close(context);
  }
  String treePage = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId="+ XSSUtil.encodeForURL(context, routeId);

 // to add route in tree of workspace/folder/projectspace check if page is acessed from either of them
 if(objectId!=null && !objectId.equals("null") && !objectId.equals("") )
 {
  String treeUrl = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + routeId +"&emxSuiteDirectory="+appDirectory+"&mode=insert&AppendParameters=true";
  %>
 <script>

   if ('true' == '<%=XSSUtil.encodeForJavaScript(context, portalMode)%>') {
	   if(getTopWindow().getWindowOpener() != null)
	    {  
	        getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
	    }
   } else{
	   var conTree = getTopWindow().getWindowOpener().getTopWindow().objDetailsTree;
	   var strTree = getTopWindow().getWindowOpener().getTopWindow().objStructureTree;
	   var selectedNode = null;
	   if(conTree != null && conTree != strTree){
		   selectedNode = conTree.getSelectedNode();
	   }
	   if(selectedNode && getTopWindow().getWindowOpener().getTopWindow().addStructureTreeNode)
	   {
	    try{
	    var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
	    frameContent.addStructureNode("<%=XSSUtil.encodeForJavaScript(context, routeId)%>", "",selectedNode.nodeID , "<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>");
	    }catch(e)
	          {
	      getTopWindow().getWindowOpener().getTopWindow().addStructureTreeNode("<%=XSSUtil.encodeForJavaScript(context, routeId)%>","newNode",selectedNode.nodeID, "<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>");
	    }
	    getTopWindow().closeWindow();
	   }
	   else if(getTopWindow().getWindowOpener().getTopWindow().refreshTablePage)
	   {  
           getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
		   
	   }
	   else{
	      var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
	      // Added for Refresh functionality
	      if(frameContent)
	    	 //XSSOK
	      {alert("<%=treePage%>");
	         //XSSOK  
	          frameContent.document.location.href =  "<%=treePage%>" ;
	          frameContent.focus();
	          window.closeWindow();
	       }
	      else
	      {
	          getTopWindow().getWindowOpener().getTopWindow().location.href = getTopWindow().getWindowOpener().getTopWindow().location.href;
	      }
	   }
   }

 
</script>

 <%
 }
 else
 {
 %>
 <script>
 var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
 //XSSOK
 frameContent.document.location.href =  "<%=treePage%>" ;
 frameContent.focus();
 </script>
<%
 }
}
%>
<html>
<body>
<form name="newForm" target="_parent">
</form>
<script language="javascript">
<%
if(bExecute)
 {
%>
  document.newForm.action = "emxRouteQuickCreateDialogFS.jsp";
  document.newForm.submit();
<%
 }else
 {
%>
window.closeWindow();
<%
 }
%>
</script>

</body>
</html>

