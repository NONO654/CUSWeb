<%--  emxProgramCentralSearchBusinessGoalProcess.jsp

  Copyright (c) 1998-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxProgramCentralSearchBusinessGoalProcess.jsp.rca 1.20 Wed Oct 22 15:49:34 2008 przemek Experimental przemek $
--%>

<%@include file = "emxProgramGlobals2.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.common.util.ComponentsUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>


<%
	 String sMode = emxGetParameter(request,"mode");
  com.matrixone.apps.program.BusinessGoal businessGoal =
    (com.matrixone.apps.program.BusinessGoal) DomainObject.newInstance(context, DomainConstants.TYPE_BUSINESS_GOAL, DomainConstants.PROGRAM);
	 com.matrixone.apps.program.ProjectSpace project =
     (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE,DomainConstants.PROGRAM);
	 com.matrixone.apps.common.Person person =
         (com.matrixone.apps.common.Person) DomainObject.newInstance(context,
                 DomainObject.TYPE_PERSON,DomainObject.PROGRAM);
	 String sObjectId = emxGetParameter(request, "objectId");
	 String sContext = emxGetParameter(request,"context");
	 String sTableRowId[] = emxGetParameterValues( request, "emxTableRowId" );
	 String sRelName = emxGetParameter(request,"relName");
	 Object domainObjectToType = DomainObject.EMPTY_STRING;
	 Object domainObjectFromType = DomainObject.EMPTY_STRING;
	 Object objToConnectObject = DomainObject.EMPTY_STRING;
	 String strToConnectObject = DomainObject.EMPTY_STRING;
	 StringList busSelects = new StringList ();
	 busSelects.add(DomainObject.SELECT_ID);
     busSelects.add(DomainObject.SELECT_NAME);
     busSelects.add(DomainObject.SELECT_CURRENT);
     busSelects.add(DomainObject.SELECT_RELATIONSHIP_ID);
     
     StringList relSelects = new StringList(3);
     relSelects.add(DomainRelationship.SELECT_ID);
     relSelects.add(DomainRelationship.SELECT_RELATIONSHIP_ID);
     
   	 String bunit=null;
	 int listSize=0;
	
  String hasTarget = emxGetParameter(request, "hasTarget");
  String objectId    = emxGetParameter(request,"objectId");
  try {
    String formKey = emxGetParameter(request, "formKey");

    // set the query limit for performance improvement
    String queryLimit = emxGetParameter(request,"queryLimit");
    if (queryLimit == null || queryLimit.equals("null") || queryLimit.equals("")){
      queryLimit = "0";
    }

    // Getting the parameters from request
    formBean.processForm(session,request,"formKey");
    String BusinessGoalNameSearchedFor = (String) formBean.getElementValue("BusinessGoalName");
    String description = (String) formBean.getElementValue("Description");
    String owner = (String) formBean.getElementValue("Owner");
    String businessUnitName = (String) formBean.getElementValue("BusinessUnitName");
    String businessUnitId = (String) formBean.getElementValue("BusinessUnitId");
    String state = (String) formBean.getElementValue("State");
    String vaultType = (String) formBean.getElementValue("vaultType");
    //used to throw warning on results page
    String passedQueryLimit = "false";
    String fromSummaryPage =  (String) formBean.getElementValue("fromSummaryPage");

    String busWhere = null;

    String vaultPattern = "";
    if(!PersonUtil.SEARCH_SELECTED_VAULTS.equals( vaultType))
    {
      vaultPattern = PersonUtil.getSearchVaults(context, false ,vaultType);
    }
    else
    {
      vaultPattern = (String) formBean.getElementValue("selectedVaults");
    }

    if (BusinessGoalNameSearchedFor != null && !BusinessGoalNameSearchedFor.equals(null) && !BusinessGoalNameSearchedFor.equals("null") &&
        !BusinessGoalNameSearchedFor.equals("*") && !BusinessGoalNameSearchedFor.equals("")){
      busWhere = "\"" + businessGoal.SELECT_NAME + "\" ~~ const\"" + BusinessGoalNameSearchedFor + "\"";
    }

    if (!"".equals(businessUnitName) && !"*".equals(businessUnitName))
    {
      if (busWhere != null){
        busWhere += " && \"" + businessGoal.SELECT_ORGANIZATION_NAME + "\" ~~ \"" + businessUnitName + "\"";
      }
      else {
        busWhere = "\"" + businessGoal.SELECT_ORGANIZATION_NAME + "\" ~~ \"" + businessUnitName + "\"";
      }
    }

    if (!"".equals(businessUnitId) && !"*".equals(businessUnitId))
    {
      if (busWhere != null){
        busWhere += " && \"" + businessGoal.SELECT_ORGANIZATION_ID + "\" ~~ \"" + businessUnitId + "\"";
      }
      else {
        busWhere = "\"" + businessGoal.SELECT_ORGANIZATION_ID + "\" ~~ \"" + businessUnitId + "\"";
      }
    }

    if (!"".equals(description) && !"*".equals(description))
    {
      if (busWhere != null){
        busWhere += " && \"" + businessGoal.SELECT_DESCRIPTION + "\" ~~ const\"" + description + "\"";
      }
      else {
        busWhere = "\"" + businessGoal.SELECT_DESCRIPTION + "\" ~~ const\"" + description + "\"";
      }
    }

    if (!"".equals(state) && !"*".equals(state))
    {
      if (busWhere != null){
        busWhere += " && \"" + businessGoal.SELECT_CURRENT + "\" ~~ \"" + state + "\"";
      }
      else {
        busWhere = "\"" + businessGoal.SELECT_CURRENT + "\" ~~ \"" + state + "\"";
      }
    }

    if(fromSummaryPage != null && "true".equals(fromSummaryPage))
    {
      // only allow leaf goals to be selected
      if (busWhere != null)
      {
          busWhere += " && \"" + businessGoal.SELECT_HAS_SUBGOAL + "\" ~~ \"false\"";
      }
      else
      {
          busWhere = "\"" + businessGoal.SELECT_HAS_SUBGOAL + "\" ~~ \"false\"";
      }

      if ("".equals(owner) || "*".equals(owner))
      {
        owner = null;
      }
    }
    String searchMode    = "businessGoalSearch";

  //  StringList busSelects = new StringList (5);
    busSelects.add(businessGoal.SELECT_ID);
    busSelects.add(businessGoal.SELECT_NAME);
    busSelects.add(businessGoal.SELECT_CURRENT);
    busSelects.add(businessGoal.SELECT_DESCRIPTION);
    busSelects.add(businessGoal.SELECT_OWNER);
    busSelects.add(businessGoal.SELECT_ORGANIZATION_ID);
    busSelects.add(businessGoal.SELECT_ORGANIZATION_NAME);
    busSelects.add(businessGoal.SELECT_POLICY);

    //remove session variable if it exists
    if(session.getAttribute("queryResultList") != null)
    {
       session.removeAttribute("queryResultList");
    }

    //build a queryResultList with only the business units that match the search criteria
    MapList queryResultList = new MapList();

    queryResultList = businessGoal.findObjects(
                      context,                            // context
                      businessGoal.TYPE_BUSINESS_GOAL,    // typePattern
                      null,                               // namePattern
                      null,                               // revPattern
                      owner,                              // ownerPattern
                      null,                       		  // vaultPattern
                      busWhere,                           // where clause
                      null,                               // queryName
                      true,                               // expandType
                      busSelects,                         // objectSelects
                      Short.parseShort(queryLimit));      // objectLimit


    int qLimit = (new Integer(queryLimit)).intValue();
    if(queryResultList.size() > qLimit && qLimit > 0){
      queryResultList.subList(qLimit, queryResultList.size()).clear();
      queryResultList.trimToSize();
      passedQueryLimit = "true";
    } else if ((queryResultList.size() == qLimit && qLimit > 0)) {
      passedQueryLimit = "true";
    }

    //Put queryResultList on session bean
    session.setAttribute("queryResultList", queryResultList);

    // Redirect results to the target page.
    String url = "emxProgramCentralSearchResultsFS.jsp?searchMode=" + XSSUtil.encodeForURL(context,searchMode) + "&hasTarget=" + XSSUtil.encodeForURL(context,hasTarget)+"&passedQueryLimit=" + passedQueryLimit+"&objectId="+ XSSUtil.encodeForURL(context,objectId);


  }
  catch (Exception e)
  {
    	
  }
%>
<% if(sMode.equalsIgnoreCase("DisconnectBusinessGoal"))
		{	  
	      for(int i=0;i<sTableRowId.length;i++)
			{
	    	    Map rowIdInfo = ProgramCentralUtil.parseTableRowId(context, sTableRowId[i]);
				String businessGoalId = (String)rowIdInfo.get("objectId");
				String projectId = (String)rowIdInfo.get("parentOId");
			
			
	     			try{ 
	     				String strState = DomainObject.EMPTY_STRING;
	     				String relId = DomainObject.EMPTY_STRING;
					    DomainObject domBG =DomainObject.newInstance(context,businessGoalId); 							
				        MapList projectList = domBG.getRelatedObjects(context,
				        		businessGoal.RELATIONSHIP_BUSINESS_GOAL_PROJECT_SPACE,
				        		DomainObject.QUERY_WILDCARD, 
				        		busSelects, 
				        		relSelects, 
				        		false, 
				        		true, 
				        		(short)1, 
				        		DomainObject.EMPTY_STRING, 
				        		DomainObject.EMPTY_STRING, 
				        		null,
				        		null, 
				        		null);
	       				
	       				listSize = projectList.size();
	          	        
	               	    for (int j = 0; j < listSize; j++){
	               	    	Map objectMap = (Map) projectList.get(j);
	               	    	String projectSpaceId = (String)objectMap.get(DomainObject.SELECT_ID);
	               	    	if(ProgramCentralUtil.isNotNullString(projectId) && projectId.equalsIgnoreCase(projectSpaceId)){
	               	    		relId = (String)objectMap.get(DomainObject.SELECT_RELATIONSHIP_ID);	
	                        	strState = (String)objectMap.get(DomainObject.SELECT_CURRENT);	
	                        	break;
	               	    	}
	         	         }
	               	    
	            	 	 DomainRelationship dRelRemove = new DomainRelationship();
	           		 
	           		 	 
	                 	 //Check if object in Complete State then should not allow for remove
	                  	 if(ProgramCentralUtil.isNotNullString(relId) && !DomainObject.STATE_BUSINESS_GOAL_COMPLETE.equals(strState)){
	                       		dRelRemove.disconnect(context, relId);	                    		
	                        }         
	                  							
						}catch (Exception ex)
			                {
			                 throw ex;
			                }
					 %>

					<script language="javascript" type="text/javaScript">
					parent.location.href=parent.location.href;
					parent.location.closeWindow();
					</script>
				<% }
			}
	else if(sMode.equalsIgnoreCase("DisconnectProject"))
		{			 
			String businessGoalRelId= ProgramCentralConstants.EMPTY_STRING;
			for(int i=0;i<sTableRowId.length;i++)
			 {
				Map rowIdInfo = ProgramCentralUtil.parseTableRowId(context, sTableRowId[i]);
				String projectId = (String)rowIdInfo.get("objectId");
				String businessGoalId = (String)rowIdInfo.get("parentOId");
				
				if(sContext==null)
				{	
					try{ 
					 DomainObject projectSpace = new DomainObject(projectId);							    
					 MapList businessGoalList = projectSpace.getRelatedObjects(context,
							 businessGoal.RELATIONSHIP_BUSINESS_GOAL_PROJECT_SPACE,
							 DomainObject.QUERY_WILDCARD,
							 busSelects, 
							 relSelects, 
							 true, 
							 true, 
							 (short)1, 
							 DomainObject.EMPTY_STRING,
							 DomainObject.EMPTY_STRING, 
							 null, 
							 null, 
							 null);
              		 
            	     listSize = businessGoalList.size();
            	    
              		
                    for (int j = 0; j < listSize; j++){
                    	Map objectMap = (Map) businessGoalList.get(j);
                       String bgId = (String)objectMap.get(DomainObject.SELECT_ID);
                       if(ProgramCentralUtil.isNotNullString(businessGoalId) && businessGoalId.equalsIgnoreCase(bgId)) {
                    	   businessGoalRelId = (String)objectMap.get(DomainObject.SELECT_RELATIONSHIP_ID);	//relid	 
                       		break;
                       }
            	     }
                    
                    if(ProgramCentralUtil.isNotNullString(businessGoalRelId)){
	                     DomainRelationship domRelRemove = new DomainRelationship();                      	   
	                     domRelRemove.disconnect(context, businessGoalRelId);     
                    }
                     				
				}catch (Exception ex){
		             throw ex;
		           }
		} %>
			<script language="javascript" type="text/javaScript">
			parent.location.href=parent.location.href;
			parent.location.closeWindow();
			</script>
		<% }				
	}%>
	<%
	if(sMode.equals("AddExistingBusinessGoal"))
	  {			
		String BusineGoalID = DomainObject.EMPTY_STRING;
		for(int i=0;i<sTableRowId.length;i++){
			StringTokenizer strTokenizer = new StringTokenizer(sTableRowId[i] ,"|");		
			for(int j=0;j<strTokenizer.countTokens();j++){
				objToConnectObject = strTokenizer.nextElement();
				BusineGoalID = objToConnectObject.toString();
				break;
				}
			
				String projectID=sObjectId;		
				try{ 
					 DomainRelationship.connect(context, 
							 DomainObject.newInstance(context,BusineGoalID),
							 businessGoal.RELATIONSHIP_BUSINESS_GOAL_PROJECT_SPACE, 
							 DomainObject.newInstance(context, projectID));
				   }catch (Exception ex){
	                 throw ex;
	                }					
				 %>
			<script language="javascript" type="text/javaScript">				
			 getTopWindow().window.getWindowOpener().location.href=getTopWindow().window.getWindowOpener().location.href;
			 getTopWindow().window.closeWindow();										
		    </script>
			<% }
		}%>
	<%
   	if(sMode.equals("AddExistingProject"))
		{		
		 String strSelectedFeatures[] = new String[sTableRowId.length];	
		
		 for(int i=0;i<sTableRowId.length;i++){
			StringTokenizer strTokenizer = new StringTokenizer(sTableRowId[i] ,"|");	
			
			for(int j=0;j<strTokenizer.countTokens();j++){
				objToConnectObject = strTokenizer.nextElement();
				strToConnectObject = objToConnectObject.toString();
				strSelectedFeatures[i]=strToConnectObject;
				break;
			  }
				
			if(sContext==null)
			  {				
				try{ 			
				    DomainRelationship.connect(context, DomainObject.newInstance(context, sObjectId),
					 project.RELATIONSHIP_BUSINESS_GOAL_PROJECT_SPACE, DomainObject.newInstance(context,strToConnectObject));
					}catch (Exception ex)
                    {
						try
						{
						String strLanguage = context.getSession().getLanguage();				
					
				                String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", "emxProgramCentral.BusinessGoal.AddProjectCompleteStateMessage", strLanguage);
						MqlUtil.mqlCommand(context, "notice " + sErrMsg);
						 
						}catch(Exception e)
						{
						e.printStackTrace();
						throw e;
						}
                     }				
				} %>
		<script language="javascript" type="text/javaScript">					
	    getTopWindow().window.getWindowOpener().location.href=getTopWindow().window.getWindowOpener().location.href;
	    getTopWindow().window.closeWindow();										
		</script>
	<% }
	}
	
	if(sMode.equals("displayBusinessUnits")){
			
	    String personId = person.getPerson(context).getId(context);
	    person.setId(personId);
	    String companyId = person.getCompanyId(context);
		String strURL = "../programcentral/emxProgramCentralBusinessGoalSelectorDialogFS.jsp?objectId="+ XSSUtil.encodeForURL(context,companyId);
    %>
	  <script language="javascript" type="text/javaScript">
	  var URL = "<%=strURL%>";  <%-- XSSOK--%>
   	  document.location.href = URL;
   	  </script>
   <%
    }
	
    if(sMode.equals("createProject")){
		String suiteKey =emxGetParameter(request,"suiteKey");
		String	businessGoalId=sObjectId;
	    String createProjectURL = "emxProgramCentralProjectCreateDialogFS.jsp?businessGoalId="+XSSUtil.encodeForURL(context,businessGoalId) + "&fromBG=true"+"&suiteKey="+XSSUtil.encodeForURL(context,suiteKey);
	%>
    <script language="javascript" type="text/javaScript">
	var URL = "<%=createProjectURL%>";   <%-- XSSOK--%>
   	document.location.href = URL;
    </script>
    <%			
	}	
    
	if(sMode.equals("businessUnitSelector")){
		String personId = person.getPerson(context).getId(context);
	    person.setId(personId);
	    String companyId = person.getCompanyId(context);
		String strURL ="../common/emxIndentedTable.jsp?program=emxProgramBusinessGoal:getCompany&table=PMCOrganizationSummary&selection=single&header=emxProgramCentral.Common.Search&submitAction=refreshCaller&hideHeader=true&cancelLabel=emxProgramCentral.Common.Close&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&emxSuiteDirectory=programcentral&relationship=relationship_Division&direction=from&expandProgram=emxProgramBusinessGoal:getBusinessUnitSpecifictoCompany&submitLabel=emxFramework.Common.Done&submitURL=../programcentral/emxProgramCentralSearchBusinessGoalProcess.jsp&mode=submit&rowGrouping=false&displayView=details&showClipboard=false&Export=false&showPageURLIcon=false&ShowFilterAction=false&typeFilter=false&customize=false&multiColumnSort=false&objectCompare=false&autoFilter=false&expandLevelFilter=false";
	%>			
	 <script language="javascript" type="text/javaScript">	    			
	 var URL = "<%=strURL%>";  <%-- XSSOK--%>
   	 document.location.href = URL;			  
	 </script>
	<%		
     }else	if(sMode.equals("businessUnitSelectorForEditDetails")){
		String personId = person.getPerson(context).getId(context);
	    person.setId(personId);
	    String companyId = person.getCompanyId(context);
		String strURL ="../common/emxIndentedTable.jsp?program=emxProgramBusinessGoal:getCompany&table=PMCOrganizationSummary&selection=single&header=emxProgramCentral.Common.Search&submitAction=refreshCaller&hideHeader=true&cancelLabel=emxProgramCentral.Common.Close&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource&emxSuiteDirectory=programcentral&relationship=relationship_Division&direction=from&expandProgram=emxProgramBusinessGoal:getBusinessUnitSpecifictoCompany&submitLabel=emxFramework.Common.Done&submitURL=../programcentral/emxProgramCentralSearchBusinessGoalProcess.jsp&mode=submitforEditDetails&rowGrouping=false&displayView=details&showClipboard=false&Export=false&showPageURLIcon=false&ShowFilterAction=false&typeFilter=false&customize=false&multiColumnSort=false&objectCompare=false&autoFilter=false&expandLevelFilter=false";
	%>			
	 <script language="javascript" type="text/javaScript">	    			
	 var URL = "<%=strURL%>";    <%-- XSSOK--%>
   	 document.location.href = URL;			  
	 </script>
	<%		
     }	
	
	if(sMode.equals("submit")){
	    String strTableRowId = emxGetParameter(request, "emxTableRowId");
	    Map mpObjectInfo = ProgramCentralUtil.parseTableRowId(context,strTableRowId);
		String strObjectId = (String)mpObjectInfo.get("objectId");
		DomainObject object = DomainObject.newInstance(context,strObjectId);
		String strObjectName = (String)object.getName(context);
	%>
		<script language="javascript" type="text/javaScript">						
		var name = "<%=XSSUtil.encodeForJavaScript(context,strObjectName)%>";
		var id = "<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>";
		var displayframe = findFrame(getTopWindow().getWindowOpener().parent, "slideInFrame");
		var displayForm = displayframe.document.forms[0];				
		displayForm.elements["BusinessUnitDisplay"].innerHTML =	name;
		displayForm.elements["BusinessUnitDisplay"].value =	name;
	    displayForm.elements["BusinessUnit"].value = name;
		displayForm.elements["BusinessUnitOID"].value =	id;							
		var businessUnitDisplayName	=	displayForm.elements["BusinessUnitDisplay"].value;
			
		var winObj = parent.window.getWindowOpener();
		eval("winObj.document.forms[0]." + "BusinessUnitDisplay" + ".value='" + businessUnitDisplayName + "'");
		getTopWindow().window.closeWindow();			
		</script>
	<% 
	    }else if(sMode.equals("submitforEditDetails")){
		    String strTableRowId = emxGetParameter(request, "emxTableRowId");
		    Map mpObjectInfo = ProgramCentralUtil.parseTableRowId(context,strTableRowId);
	            String strObjectId = (String)mpObjectInfo.get("objectId");
		    DomainObject object = DomainObject.newInstance(context,strObjectId);
		    String strObjectName = (String)object.getName(context);
		%>
			<script language="javascript" type="text/javaScript">			
			var name = "<%=XSSUtil.encodeForJavaScript(context,strObjectName)%>";	
			var id = "<%=XSSUtil.encodeForJavaScript(context,strObjectId)%>";
		    var winObj = parent.window.getWindowOpener();
			var displayForm =winObj.document.forms[0];					
		
			displayForm.elements["BusinessUnitEditModeDisplay"].value =	name;
		    displayForm.elements["BusinessUnitEditMode"].value = name;
			displayForm.elements["BusinessUnitEditModeOID"].value =	id;					
			var BusinessUnitEditModeDisplayvalue = 	displayForm.elements["BusinessUnitEditModeDisplay"].value;				
		eval("winObj.document.forms[0]." + "BusinessUnitEditModeDisplay" + ".value='" + BusinessUnitEditModeDisplayvalue + "'");
		getTopWindow().window.closeWindow();			
		</script>
	<% 
	    }
%>
<html>
</html>
<!-- Contents Ends Here  -->
