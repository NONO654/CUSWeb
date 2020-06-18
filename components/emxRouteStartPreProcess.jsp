<%-- emxRouteStartPreProcess.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: emxRouteStartPreProcess.jsp
--%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file  = "../emxUICommonAppInclude.inc"%>
<html>

<head>
<script language="javascript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
</head>
<body>
</body>
<script language="Javascript" >
  var blnStartRoute = true;

 <%
	  String routeId      = emxGetParameter(request, "objectId"); 
	  Route boRoute = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
	  boRoute.setId(routeId);
      SelectList selectStmts = new SelectList();
      String sAttrRestrictMembers = PropertyUtil.getSchemaProperty(context, "attribute_RestrictMembers" );
      String SELECT_RESTRICT_MEMBERS = DomainObject.getAttributeSelect(sAttrRestrictMembers);
      selectStmts.addElement(SELECT_RESTRICT_MEMBERS);
      selectStmts.addElement(boRoute.SELECT_OWNER);
      Map resultMap = boRoute.getInfo(context, selectStmts);
      String restrictMembers = (String) resultMap.get(SELECT_RESTRICT_MEMBERS);
      String sOwner         = (String) resultMap.get(boRoute.SELECT_OWNER);
            
      Pattern relPattern  = null;
      Pattern typePattern = null;

      relPattern  = new Pattern(PropertyUtil.getSchemaProperty(context, "relationship_InitiatingRouteTemplate"));
      typePattern = new Pattern(PropertyUtil.getSchemaProperty(context, "type_RouteTemplate"));
      BusinessObject boGeneric  = null;
      RelationshipWithSelectItr relItr  = null;

      String proxyGoupType = PropertyUtil.getSchemaProperty(context,"type_GroupProxy");
      
      typePattern       = new Pattern(DomainObject.TYPE_PERSON);
      typePattern.addPattern(DomainObject.TYPE_ROUTE_TASK_USER);
      typePattern.addPattern(proxyGoupType);
      relPattern        = new Pattern(DomainObject.RELATIONSHIP_ROUTE_NODE);

      boRoute.open(context);

      // to check whether route is connected with Route Node Relationship
      boGeneric                       = com.matrixone.apps.common.util.ComponentsUtil.getConnectedObject(context,boRoute,relPattern.getPattern(),typePattern.getPattern(),false,true);
      BusinessObject boPerson         = null;
      BusinessObject boConnectedRoute = null;
      boolean bFlag                   = false;
	  boolean noneFlag                = false;      
      boolean bDateEmpty              = false;
      String sAsigneeId               = null;  

      // added on 21 Jan'04 to display last name ,first name of owner

      sOwner              = com.matrixone.apps.common.Person.getDisplayName(context, sOwner);


      ExpansionWithSelect routeTaskSelect = boRoute.expandSelect(context,relPattern.getPattern(),typePattern.getPattern(),
      selectStmts, new StringList(),false, true, (short)1);

      relItr = new RelationshipWithSelectItr(routeTaskSelect.getRelationships());
      // to check whether the Route Node relationship is updated with the attributes
      ArrayList arrayPersons = new ArrayList();

      while(relItr.next()) {

        boPerson   = relItr.obj().getTo();
        boPerson.open(context);
        sAsigneeId = boPerson.getObjectId();
        boPerson.close(context);

        if (!(arrayPersons.contains(sAsigneeId))){
          arrayPersons.add(sAsigneeId);
        }
      }
      relItr.reset();

	  ExpansionWithSelect routeSelect = null;
	  Hashtable routeNodeAttributesTable          = new Hashtable();
      for (int num=0; num < arrayPersons.size();num++) {
        boPerson = new BusinessObject((String)arrayPersons.get(num));
        boPerson.open(context);

        if ( bFlag == true){
          break;
        }
        //tuy
    SelectList selectRouteRelStmts = new SelectList();
    selectRouteRelStmts.addAttribute(DomainObject.ATTRIBUTE_ROUTE_SEQUENCE);
    selectRouteRelStmts.addAttribute(DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE);
    selectRouteRelStmts.addAttribute(DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE);
    selectRouteRelStmts.addAttribute(DomainObject.ATTRIBUTE_TITLE);
    selectRouteRelStmts.addAttribute(DomainObject.ATTRIBUTE_DUEDATE_OFFSET);
    //Added for IR-047619V6R2011x:Start
    selectRouteRelStmts.add("from."+DomainObject.SELECT_ID);//rupesh
    //Added for IR-047619V6R2011x:End
    Pattern relRoutePattern     = new Pattern(DomainObject.RELATIONSHIP_ROUTE_NODE);
    Pattern typeRoutePattern    = new Pattern(DomainObject.TYPE_ROUTE);
    SelectList selectRouteStmts = new SelectList();
    String sTaskName = "";
    String sSchCompletionDt = "";
    String sOrder = "";
    String sDueDateOffset = "";
    String sAssigneeSetDate = "";
    routeSelect = boPerson.expandSelect(context,relRoutePattern.getPattern(),typeRoutePattern.getPattern(),
                                           selectRouteStmts,selectRouteRelStmts,true, false, (short)1);      
    RelationshipWithSelectItr relRouteItr = new RelationshipWithSelectItr(routeSelect.getRelationships());
    while (relRouteItr != null && relRouteItr.next()) {
        routeNodeAttributesTable             =  relRouteItr.obj().getRelationshipData();
        //Added for IR-047619V6R2011x:Start
        String sSelectRouteId = "";
        sSelectRouteId = (String)routeNodeAttributesTable.get("from."+DomainObject.SELECT_ID);
        if(!sSelectRouteId.equals(routeId))
            continue;
        //Added for IR-047619V6R2011x:End
		if ( bFlag == true){
            break;
          }
        sTaskName                = (String)routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_TITLE + "]" );

        sSchCompletionDt = (String)routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_SCHEDULED_COMPLETION_DATE + "]" );
        sOrder           = (String)routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_ROUTE_SEQUENCE + "]" );
        sDueDateOffset   = (String)routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_DUEDATE_OFFSET + "]" );
        sAssigneeSetDate = (String)routeNodeAttributesTable.get("attribute[" + DomainObject.ATTRIBUTE_ASSIGNEE_SET_DUEDATE + "]" );
        }
        if ((sSchCompletionDt.equals("")) && (sDueDateOffset.equals("")) && (sAssigneeSetDate.equals("No"))) {
        bDateEmpty = true;
        }

        if ("".equals(sOrder) || sOrder == null) {
        bFlag = true;
        }
  }
      boRoute.close(context);
  		  
  		  if ( boGeneric == null ) {
%>
	  getTopWindow().isStartRouteClicked=false;
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteDetails.StartMessage</emxUtil:i18nScript>");
<%	 
      // alert message if the Route Node Relationsip is not updated with attributes
    
      }else if ( boGeneric != null && bFlag == true ) {
%>
		getTopWindow().isStartRouteClicked=false;
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteDetails.TaskAttrMessage</emxUtil:i18nScript>");
<%
        // alert message if the Route doesn't have Route Node
      } else if ( boGeneric == null) {
%>
		getTopWindow().isStartRouteClicked=false;
        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Routes.PersonMessage</emxUtil:i18nScript>");
<%
      }  else {
        // alert message to intimate owner that few due-dates not filled yet.
      if (bDateEmpty) {
%>
		 getTopWindow().isStartRouteClicked=false;
         alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RouteDetails.AssigneeDueDateAlert</emxUtil:i18nScript>");
<%
       }
%>
submitWithCSRF("emxRouteStart.jsp?routeId=<%=XSSUtil.encodeForURL(context, routeId)%>&restrictMembers=<%=restrictMembers%>&fromPage=routeProperties", getTopWindow().findFrame(getTopWindow(),"formViewHidden"));
         
<%
      }
%>
</script>
</html> 	
