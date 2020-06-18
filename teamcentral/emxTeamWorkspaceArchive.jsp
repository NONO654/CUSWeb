<%-- To Archive the Workspace Object
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
--%>
<%@ include file="../emxUICommonAppInclude.inc" %>
<%@include file = "emxTeamCommonUtilAppInclude.inc" %>
<%@include file = "eServiceUtil.inc"%>
<%@ include file  = "emxTeamUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%!
  //
  // returns BusinessObjectList of all Active routes connected to a project member
  //
  static public BusinessObjectList getAllActiveProjectRoutes(matrix.db.Context context, HttpSession session, BusinessObject projectMember) throws MatrixException
  {
    //matrix.db.Context context = getPageContext();
    //Commented for the Bug No: 339254 0 8/13/2007 7:14 PM Begin
    /* // build Relationship and Type patterns
    
    String relPattern = Framework.getPropertyValue( session, "relationship_MemberRoute");
    String typePattern = Framework.getPropertyValue(session, "type_Route");
    //Commented for the Bug No: 339254 0 8/13/2007 7:14 PM End */
    
    String stateInProcess       = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_ROUTE, "state_InProcess");
    String stateDefine      = FrameworkUtil.lookupStateName(context, DomainObject.POLICY_ROUTE, "state_Define");
    
    //Commented for the Bug No: 339254 0 8/13/2007 7:14 PM Begin
    /* 
    SelectList selectStmts = new SelectList(1);
    selectStmts.addCurrentState();


    ExpansionWithSelect projectMemberSelect = projectMember.expandSelect(context, relPattern,
                                                                         typePattern, selectStmts,
                                                                         new StringList(), true, false, (short)1);

    // check the Project Member relations
    RelationshipWithSelectItr relItr = new RelationshipWithSelectItr(projectMemberSelect.getRelationships());

    BusinessObjectList projectRouteList = new BusinessObjectList();
    Hashtable attributesTable = null;
    String routeState = null;

    while (relItr.next()) {
      attributesTable =  relItr.obj().getTargetData();
      routeState = (String)attributesTable.get( "current" );

      if ( routeState.equals( stateDefine ) || routeState.equals(stateInProcess)) {
        projectRouteList.add(relItr.obj().getFrom());
      }
    }
    */
   // Commented for the Bug No: 339254 0 8/13/2007 7:14 PM End
   //Added for the Bug No: 339254 0 8/13/2007 7:14 PM Begin

    DomainObject dobj = new DomainObject(projectMember);
    BusinessObjectList projectRouteList = new BusinessObjectList();

    StringList objIdList = (StringList)dobj.getInfoList(context,"to[Project Members].from.from[Route Scope].to.id");
    
    StringList objSelect = new StringList(2);
    objSelect.addElement("id");
    objSelect.addElement("current");
    
    MapList stateMap = DomainObject.getInfo(context,(String [])objIdList.toArray(new String[]{}),objSelect);
    
    Iterator itr= stateMap.iterator();
    while(itr.hasNext()){
    Map eachMap = (Map)itr.next();
    String curstate = (String)eachMap.get("current");
    if(curstate==null){
    projectRouteList = projectRouteList;
    } else if ( curstate.equals( stateDefine ) || curstate.equals(stateInProcess)) {
        BusinessObject bobjId = new BusinessObject((String)eachMap.get("id"));
        projectRouteList.add(bobjId);
      }
    }
    
    //Added for the Bug No: 339254 0 8/13/2007 7:14 PM End
    return projectRouteList;
  }
%>


<%!
  //
  // returns BusinessObjectList of all Active Meetings connected to a project member
  //
  static public BusinessObjectList getAllActiveProjectMeetings(matrix.db.Context context, HttpSession session, BusinessObject projectMember) throws MatrixException
  {
    //matrix.db.Context context = getPageContext();

    // build Relationship and Type patterns
    String relPattern = Framework.getPropertyValue( session, "relationship_MeetingContext");
    String typePattern = Framework.getPropertyValue(session, "type_Meeting");

    SelectList selectStmts = new SelectList(1);
    selectStmts.addCurrentState();


    ExpansionWithSelect projectMemberSelect = projectMember.expandSelect(context, relPattern,
                                                                         typePattern, selectStmts,
	                                                                 new StringList(), false, true,  (short)1);

    // check the Project Member relations
    RelationshipWithSelectItr relItr = new RelationshipWithSelectItr(projectMemberSelect.getRelationships());

    BusinessObjectList projectMeetingsList = new BusinessObjectList();
    Hashtable attributesTable = null;
    String meetingState = null;

    while (relItr.next()) {
      attributesTable =  relItr.obj().getTargetData();
      meetingState = (String)attributesTable.get( "current" );
      if ( !meetingState.equals( "Complete" )) {
        projectMeetingsList.add(relItr.obj().getTo());
      }
    }
    return projectMeetingsList;
  }
%>


<%!
  //
  // returns objectIds of all Project Members connected to a project in a Vector
  //
  static public Vector getAllProjectMemberObjects(matrix.db.Context context, HttpSession session, String projectId) throws MatrixException
  {
    Vector memberList = new Vector();
    //matrix.db.Context context = getPageContext();

    BusinessObject activeProject = new BusinessObject( projectId );

    // build Relationship and Type patterns
    String relPattern = Framework.getPropertyValue( session, "relationship_ProjectMembers");
    String typePattern = Framework.getPropertyValue(session, "type_ProjectMember");

    // build select params
    SelectList selectStmts = new SelectList(1);
    selectStmts.addId();

    ExpansionWithSelect projectSelect = activeProject.expandSelect(context,relPattern,typePattern,
                                             selectStmts,new StringList(),false, true, (short)1);

    RelationshipWithSelectItr relItr = new RelationshipWithSelectItr(projectSelect.getRelationships());

    Hashtable projectMemberAttributesTable = null;
    String projectMemberId = null;

    while (relItr.next()) {
      projectMemberAttributesTable =  relItr.obj().getTargetData();
      projectMemberId = (String)projectMemberAttributesTable.get("id");
      memberList.add(projectMemberId);
    }
    return memberList;
  }
%>


<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script> 
<%
  String projectId = emxGetParameter(request, "objectId");

//When opened from Designer Central, the objectId parameter is not sent, instead projectId is passed.
	if (projectId == null) {
	    projectId = emxGetParameter(request, "projectId");	    
	}
   
  String sErrorMsg = "";
  BusinessObject busProject = new BusinessObject(projectId);
    
  busProject.open(context);
  
  boolean bcanArchive = true;
  
  Iterator granteeItr               = null;
  StringList granteeList = new StringList();
  StringList personList = new StringList();


  // get All the ProjectMembers for this project
  Enumeration projectMembersEnum = getAllProjectMemberObjects(context, session, projectId).elements();

while (projectMembersEnum.hasMoreElements()) {
     
    BusinessObject projectMember = new BusinessObject((String)projectMembersEnum.nextElement());
    BusinessObjectList activeRouteList = getAllActiveProjectRoutes(context, session, projectMember);

    if ( activeRouteList.size() > 0 ) {
      
      busProject.close(context);
      sErrorMsg=i18nNow.getI18nString("emxTeamCentral.ArchiveProject.RouteMsg","emxTeamCentralStringResource" ,sLanguage);
      bcanArchive = false;
    } else {
      BusinessObjectList activeMeetingList = getAllActiveProjectMeetings(context, session, projectMember);
      if ( activeMeetingList.size() > 0 ) {
        busProject.close(context);
        sErrorMsg=i18nNow.getI18nString("emxTeamCentral.ArchiveProject.MeetingMsg","emxTeamCentralStringResource" ,sLanguage);
        bcanArchive = false;
      }
    }
    if(bcanArchive == false) {
      break;
    }
  }

  if(bcanArchive == true) {
      
  // Promote the Project to "Archive" state
  // Requires 2 promote(context)s to move to "Archive" from "Active"
  while (!FrameworkUtil.getCurrentState(context, busProject).getName().equals("Archive"))
  {
    busProject.promote(context);
  }
  
  MapList sAccessList = DomainAccess.getAccessSummaryList(context, projectId);
  DomainObject dObj  = new DomainObject(projectId) ;
  String sOwner = dObj.getInfo(context, "owner");
  Iterator itr = sAccessList.iterator();
  while (itr.hasNext()){
	  Map tempMap = (Map)itr.next();
	  String ids = (String)tempMap.get("id");
	  StringList idList = com.matrixone.apps.domain.util.StringUtil.split(ids, ":");
	  if(!idList.isEmpty()){
		  String objId = (String)idList.get(0);
		  String sProject = (String)tempMap.get("name");
		  String organization = (String)tempMap.get("org");
		  if(UIUtil.isNotNullAndNotEmpty(organization)) {
		     sProject = (String)tempMap.get("project");
		  } 
		  String sComments = (String)tempMap.get("comment");
		  String sProjectRoleName = (String)tempMap.get("project");		  
		  if((!PersonUtil.getFullName(context, sOwner).equals(sProjectRoleName)) && (!sComments.equalsIgnoreCase("Primary"))) {
			  DomainAccess.deleteObjectOwnership(context, objId, organization,sProject,sComments,true);			  
		  }		  
	  }	  
  }

}

// Forward it to TeamFrames, but since we want to load this top frame instead of
// "mainframe", form submit is one solution
%>
<form name="newForm" target="_parent">
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
</form>

<%
  if (!bcanArchive) {
%>

<script language="Javascript">
  alert("<%=sErrorMsg%>");
  parent.window.location.href=parent.window.location.href;


</script>

<%
  } else {
%>
  <script language="javascript">
  getTopWindow().emxUICategoryTab.reloadTabs(getTopWindow().emxUICategoryTab.catObj);
	  parent.window.location.href=parent.window.location.href;
  if(getTopWindow().opener && getTopWindow().opener.getTopWindow().RefreshHeader){
		getTopWindow().opener.getTopWindow().RefreshHeader();      
	}else if(getTopWindow().RefreshHeader){
		getTopWindow().RefreshHeader();     
	}
  </script>
<%
}
%>
