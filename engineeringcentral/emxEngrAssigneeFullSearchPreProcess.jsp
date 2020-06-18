 <%--  emxEngrAssigneeFullSearchPreProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%
  String objectId = emxGetParameter(request,"objectId");
  String language  = request.getHeader("Accept-Language");
  //Multitenant
  //String strRootNodeErrorMsg = i18nNow.getI18nString("emxEngineeringCentral.BOM.CopyToRootNodeError","emxEngineeringCentralStringResource", language);
  String strRootNodeErrorMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BOM.CopyToRootNodeError"); 
  //Multitenant
  //String strInvalidSelectionMsg = i18nNow.getI18nString("emxEngineeringCentral.CommonView.Alert.Invalidselection","emxEngineeringCentralStringResource", language);
  String strInvalidSelectionMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.CommonView.Alert.Invalidselection");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
  String selPartRelId = "";
  String selPartObjectId = "";
  String selPartParentOId = "";
  String contextPersonId = com.matrixone.apps.domain.util.PersonUtil.getPersonObjectID(context);
  String excludeOIDList = "";
  // Initializing StringLists for ObjectIds and RelIds for further processing.
  StringList slArrObjIds = new StringList();
  StringList slArrRelIds = new StringList();
  DomainObject dom = new DomainObject();

  if (tableRowIdList!= null) {
    for (int i=0; i< tableRowIdList.length; i++) {
       //process - relId|objectId|parentId - using the tableRowId
       String tableRowId = tableRowIdList[i];
       String firstIndex = tableRowIdList[i].substring(0,tableRowIdList[i].indexOf("|"));
       StringTokenizer strTok = new StringTokenizer(tableRowId,"|");
       selPartRelId = strTok.nextToken();
       String sRelName = "";
       if(!firstIndex.equals(""))
       {
           Relationship rel=new Relationship(selPartRelId);
           rel.open(context);
           sRelName=rel.getTypeName();
           rel.close(context);
       }

       if(!"".equals(firstIndex)) {
          selPartObjectId = strTok.nextToken();
          if (strTok.hasMoreTokens())
          {
              selPartParentOId = strTok.nextToken();
		  }
		  else
		  {
			  selPartParentOId = objectId;
		  }
       } else {
          selPartObjectId = objectId;
          selPartParentOId = objectId;
       }
       //get selected parts assignee to exclude from the list
       String strAssigneeId = "";
	   try
	   {
	   	   ContextUtil.pushContext(context);
	   	   strAssigneeId = MqlUtil.mqlCommand(context,"print connection $1 select $2 dump",selPartRelId,"tomid.fromrel["+DomainConstants.RELATIONSHIP_ASSIGNED_EC+"].from.id");
	   }
	   catch (Exception e)
	   {
	   }
	   finally
	   {
	   	   ContextUtil.popContext(context);
	   }

       if (strAssigneeId != null && !"".equals(strAssigneeId))
       {
           if (!"".equals(excludeOIDList))
           {
               excludeOIDList = "," + strAssigneeId;
           }
           else
           {
               excludeOIDList = strAssigneeId;
           }
       }
	   //Appending Object Ids and RelIds to the StringLists
	   slArrObjIds.add(selPartObjectId);
	   slArrRelIds.add(selPartRelId);
    }
  }

  String prevmode         = emxGetParameter(request, "prevmode");
  if(prevmode == null || "null".equals(prevmode)){
    prevmode ="";
  }

  //If more than one assignee then only show those assignees connected to the context change object
  //else show all users with correct role.
  StringList objectSelects = new StringList(DomainConstants.SELECT_ID);

  Change changeObj = new Change();
  changeObj.setId(objectId);
  String strObjName = changeObj.getInfo(context, DomainConstants.SELECT_NAME);
  MapList assigneeListList = changeObj.getRelatedObjects(context,
											  DomainConstants.RELATIONSHIP_ASSIGNED_EC,
											  DomainConstants.QUERY_WILDCARD,
											  objectSelects,
											  null,
											  true,
											  false,
											  (short) 1,
											  DomainConstants.EMPTY_STRING,
											  DomainConstants.EMPTY_STRING);

  String changeAssignment = "";
  if (assigneeListList.size() > 1)
  {
      changeAssignment = ":CHANGE_ASSIGNMENT="+strObjName;
  }
  String contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_Person:USERROLE=role_DesignEngineer"+changeAssignment+":CURRENT=policy_Person.state_Active&table=ENCAssigneeTable&HelpMarker=emxhelpfullsearch&objectId="+objectId;
  contentURL += "&srcDestRelName=relationship_AssignedEC&isTo=false&selection=single&arrObjIds1="+slArrObjIds+"&arrRelIds1="+slArrRelIds+"&txtExcludeOIDs="+excludeOIDList+"&submitURL=../engineeringcentral/emxEngrAssigneeDelegateConnect.jsp";
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script>
//XSSOK
//document.location.href="<%=XSSUtil.encodeForJavaScript(context,contentURL)%>";
var contentframe = getTopWindow().findFrame(getTopWindow(),  "detailsDisplay");
contentframe.showModalDialog("<%=XSSUtil.encodeForJavaScript(context,contentURL)%>", 550,500,true);
</script>
