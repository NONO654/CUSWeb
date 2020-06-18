<%-- emxProgramCentralTaskAssigneeActionsHidden.jsp -  General search starting point
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
  static const char RCSID[] = $Id: emxProgramCentralTaskAssigneeActionsHidden.jsp.rca 1.2.1.3.3.2.2.2 Fri Dec 19 08:39:12 2008 ds-ksuryawanshi Experimental $
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProgramCentralCommonUtilAppInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="../common/scripts/emxUISearch.js"></script>
<%@page import="com.matrixone.apps.domain.DomainConstants"%><script language="JavaScript" src="../common/scripts/emxUISearch.js"></script>
<%

StringBuffer contentURL =new StringBuffer();
String command=emxGetParameter(request,"command");
    command = XSSUtil.encodeURLForServer(context,command);
String objectId   = emxGetParameter(request,"objectId");
	objectId = XSSUtil.encodeURLForServer(context, objectId);
 String[] emxTableRowId = emxGetParameterValues(request, "emxTableRowId");
 String portalCommandName = emxGetParameter(request, "portalCmdName");

      int numPeople = 0;
  if ( emxTableRowId != null ) {
    // get the number of people
    numPeople = emxTableRowId.length;
  }
if(command.equals("AddRiskAssignee") || command.equals("AddOpportunityAssignee")){
	
	boolean toContinue = true;
    String strSelectedRiskId = DomainObject.EMPTY_STRING;
    String []riskIdArray = null;
        String riskId = DomainObject.EMPTY_STRING;
    
    
    if(emxTableRowId != null){
    	riskIdArray = new String[emxTableRowId.length];
    	String [] rowIdArray = ProgramCentralUtil.parseTableRowId(context,emxTableRowId);
    	int size = rowIdArray.length;
    	 for(int i=0;i<size;i++){
    		 riskId = rowIdArray[i];
                riskIdArray[i] = riskId;
                if(i==0){
                    strSelectedRiskId = riskId;
                }else{
                    strSelectedRiskId +=","+riskId;
                }
            }
            
            if (strSelectedRiskId.endsWith(",")) {
                strSelectedRiskId = strSelectedRiskId.substring(0,strSelectedRiskId.length()-1);
            }
        }
    else
    {
    	 riskId = objectId;
    	 strSelectedRiskId = riskId;
    	 riskIdArray = new String[1];
         riskIdArray[0] = riskId;
    }
    
        StringList selectables = new StringList(1);
        selectables.add(DomainConstants.SELECT_TYPE);
        MapList objInfoList = DomainObject.getInfo(context, riskIdArray, selectables);
        Iterator itr = objInfoList.iterator();
		
        while (itr.hasNext())
		{
			Map objInfoMap = (Map) itr.next();
        	String objType= (String)objInfoMap.get(DomainConstants.SELECT_TYPE);
       		 if(DomainConstants.TYPE_PROJECT_SPACE.equalsIgnoreCase(objType))
       		 {
       			if(command.equals("AddRiskAssignee")){
        %>
       			  <script type="text/javascript" language="JavaScript">
        			 var errorUrl = "../programcentral/emxProgramCentralUtil.jsp?mode=errorMessage&errorKey=emxProgramCentral.Risk.CannotAssignAssigneeToProject";
        			 var errorMessage = emxUICore.getData(errorUrl);
        			 alert(errorMessage);
        		  </script>
        <%
       				
       			}else{
     			
       	        %>
       	       			  <script type="text/javascript" language="JavaScript">
       	        			 var errorUrl = "../programcentral/emxProgramCentralUtil.jsp?mode=errorMessage&errorKey=emxProgramCentral.Opportunity.CannotAssignAssigneeToProject";
       	        			 var errorMessage = emxUICore.getData(errorUrl);
       	        			 alert(errorMessage);
       	        		  </script>
       	        <%
      			}
        		toContinue = false;
       			 break;
    }
		}
		if(toContinue)
		{
        session.setAttribute("selectedRiskIds", riskIdArray);
     %>
        <script language="javascript">
        var searchUrl="../common/emxFullSearch.jsp?table=PMCCommonPersonSearchTable&field=TYPES=type_Person:CURRENT=policy_Person.state_Active&includeOIDprogram=emxCommonPersonSearch:includeRiskAssignees&searchMode=GeneralPeopleTypeMode&form=PMCCommonPersonSearchForm&selection=multiple&mode=addRiskAssignee&suiteKey=ProgramCentral&HelpMarker=emxhelpriskassign&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&selectedRiskIds=<%=XSSUtil.encodeForURL(context, strSelectedRiskId)%>&submitURL=../programcentral/emxProgramCentralCommonPersonSearchUtil.jsp?objectId=<%=XSSUtil.encodeForURL(context, objectId)%>";
        searchUrl += "&portalCmdName=<%=portalCommandName%>";
        showModalDialog(searchUrl, 930,650, true);
        </script>
     <%
    }

}
if(command.equals("Add")){
    // TODO : Search column configuration.
    DomainObject dom = DomainObject.newInstance(context,objectId);
    boolean isKindOfRisk = dom.isKindOf(context, DomainConstants.TYPE_RISK);

    if(isKindOfRisk == true){
        %>
        <script>
        
           var strSearchURL ="../common/emxFullSearch.jsp?table=PMCCommonPersonSearchTable&field=TYPES=type_Person:CURRENT=policy_Person.state_Active&includeOIDprogram=emxCommonPersonSearch:includeRiskAssignees&searchMode=GeneralPeopleTypeMode&form=PMCCommonPersonSearchForm&selection=multiple&objectId=<%=objectId%>&submitURL=../programcentral/emxProgramCentralAssigneeAddProcess.jsp?objectId=<%=objectId%>";
           showModalDialog(strSearchURL);
           </script>
        <%}
    else {
     String strProjectSpace = "";
          //strProjectSpace = dom.getInfo(context,"to["+DomainConstants.RELATIONSHIP_SUBTASK+"].from.name");
          // to fetch the project name from task (subtask also) at any level.
          if(null != objectId && !"".equalsIgnoreCase(objectId.trim())){
			  StringList slBusSelects = new StringList(1);
			  slBusSelects.add(DomainConstants.SELECT_NAME);
			  com.matrixone.apps.program.Task taskObj = new com.matrixone.apps.program.Task();
			  taskObj.setId(objectId);
			  Map projectInfo = taskObj.getProject(context, slBusSelects);
			  if(projectInfo!=null){
	        	  strProjectSpace  = (String) projectInfo.get(DomainConstants.SELECT_NAME);
		          strProjectSpace = XSSUtil.encodeForURL(context, strProjectSpace);  
	          }
          }

          String strFromPage   = emxGetParameter(request,"fromPage");
          if(null == strFromPage || "".equalsIgnoreCase(strFromPage)){
              strFromPage = "assignSelectedFromActionHidden";
          }
          strFromPage = XSSUtil.encodeForURL(context, strFromPage);
       
     %>
  <script>
  var projectID = '<%=strProjectSpace%>'; 	//XSSOK
  var fromPage = '<%=strFromPage%>';		//XSSOK
  var searchURL = "../common/emxFullSearch.jsp?table=PMCCommonPersonSearchTable&field=TYPES=type_Person:POLICY=policy_Person:CURRENT=policy_Person.state_Active&form=PMCCommonPersonSearchForm&excludeOIDprogram=emxProgramCentralUtil:getexcludeOIDforPersonSearch&searchMode=GeneralPeopleTypeMode&selection=multiple&objectId=<%=objectId%>&default=PRG_PEOPLE_PROJECT_MANAGEMENT="+projectID+"&submitURL=../programcentral/emxProgramCentralAssigneeAddProcess.jsp?objectId=<%=objectId%>&fromPage="+fromPage; //XSSOK
    
    showModalDialog(searchURL); //XSSOK
    <%
    }%>
    </script>
<%

    /*
    contentURL.append("emxProgramCentralSearchFS.jsp?mode=projectMemberSearch");
    HashMap searchMap = new HashMap();
    searchMap.put("targetSearchPage", "emxProgramCentralAssigneeAddProcess.jsp?objectId="+objectId);
    searchMap.put("objectId", objectId);
    session.setAttribute("personSearchMap", searchMap);
    */
}
else if(command.equals("Delete"))
{


    DomainObject dom=new DomainObject(objectId);
    String objectType = (String) dom.getInfo(context, dom.SELECT_TYPE);
    String strPersonId="";
    String strRelId="";
    String selectedIds="";

    contentURL.append("emxProgramCentralAssigneeDeleteProcess.jsp?type="+objectType);

for(int intPCount=0;intPCount<numPeople;intPCount++)
    {
    if(emxTableRowId[intPCount].indexOf("|") != -1) {
            StringTokenizer strtokenizer = new StringTokenizer(emxTableRowId[intPCount], "|"); //RelID|PersonID
            strRelId = strtokenizer.nextToken().trim(); //RelId
            strRelId = XSSUtil.encodeURLForServer(context, strRelId);
            strPersonId = strtokenizer.nextToken().trim();  //personID
            strPersonId = XSSUtil.encodeURLForServer(context, strPersonId);
            selectedIds=strPersonId+","+strRelId;
            contentURL.append("&selectedIds="+selectedIds);
          }
    }

}
else if(command.equals("Modify"))
{

if(numPeople>1)
    {
%>


<script>
  alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Profile.SelectOnlyOnePerson</emxUtil:i18nScript>");
getTopWindow().window.closeWindow();

</script>

<%
    }else {

    String strPersonId="";
    String strRelId="";
    String selectedIds="";
    if(emxTableRowId[0].indexOf("|") != -1) {
            StringTokenizer strtokenizer = new StringTokenizer(emxTableRowId[0], "|");
            strRelId = strtokenizer.nextToken().trim();
            strRelId = XSSUtil.encodeURLForServer(context, strRelId);
            strPersonId = strtokenizer.nextToken().trim();
            strPersonId = XSSUtil.encodeURLForServer(context, strPersonId);
            selectedIds=strPersonId+","+strRelId;
          }
    contentURL.append("emxProgramCentralAssigneeEditRoleDialogFS.jsp?personId=" + selectedIds);
}
}
//Added:14-May-2010:s4e:R210 PRG:WBSEnhancement
//Added to make the selected person as the Owner of Task

else if(command.equals("MakeTaskOwner"))
{
    if(numPeople>1)
    {
    %><script>
      alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Profile.SelectOnlyOnePerson</emxUtil:i18nScript>");
     </script>
    <%
    }
    else
    {
        boolean flag = false;
        try{
        String strPersonId="";
        String strRelId="";
        String strTaskId="";

        if(emxTableRowId[0].indexOf("|") != -1)
        {
            StringTokenizer strtokenizer = new StringTokenizer(emxTableRowId[0], "|");
            strRelId = strtokenizer.nextToken().trim();
            strPersonId = strtokenizer.nextToken().trim();
            strTaskId=strtokenizer.nextToken().trim();
            DomainObject taskDobj = DomainObject.newInstance(context, strTaskId);
            String strOldTaskOwner = taskDobj.getInfo(context, DomainConstants.SELECT_OWNER);
            String hasChangeOwner = (String) taskDobj.getInfo(context,"current.access[changeowner]");
            com.matrixone.apps.common.Person newOwnerPerson =
                (com.matrixone.apps.common.Person) DomainObject.newInstance(context,
                        DomainConstants.TYPE_PERSON);
            newOwnerPerson.setId(strPersonId);
            String strNewTaskOwner = newOwnerPerson.getName(context);
            com.matrixone.apps.common.AssignedTasksRelationship assignee = new com.matrixone.apps.common.AssignedTasksRelationship(strRelId);
            if(strOldTaskOwner.equals(strNewTaskOwner))
            {
                %><script>
                alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Profile.AlreadyOwner</emxUtil:i18nScript>");
               </script>
                <%
            }
            else if(hasChangeOwner.equalsIgnoreCase("FALSE"))
            {
                %><script>
                alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Profile.NotOwner</emxUtil:i18nScript>");
               </script>
                <%
            }
            else
            {
                ContextUtil.pushContext(context, PropertyUtil.getSchemaProperty(context, "person_UserAgent"),DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
                flag = true;
                taskDobj.setOwner(context, strNewTaskOwner);
            }

        }
        }
        catch (Exception e)
        {
            e.printStackTrace();
            throw e;

        }
        finally
        {
            if(flag)
            {
                   ContextUtil.popContext(context);
            }
        }

     }
}

//End:14-May-2010:s4e:R210 PRG:WBSEnhancement

Enumeration enumParamNames=emxGetParameterNames(request);
    while(enumParamNames.hasMoreElements())
    {
        String param=(String)enumParamNames.nextElement();
        String paramValue=emxGetParameter(request,param);
        contentURL.append("&"+param+"="+paramValue);
    }
%>
<%-- Modified:V6R2010:PRG Autonomy search --%>
<%

if(!(command.equals("AddRiskAssignee")) && !(command.equals("Add"))&& !(command.equals("MakeTaskOwner"))){
%>

    <script>
      <%-- XSSOK--%>
   document.location.href="<%=contentURL%>";
    </script>

<%
    }
%>
<%-- End:V6R2010:PRG Autonomy search --%>

