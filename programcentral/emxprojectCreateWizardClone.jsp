<%--
  emxprojectCreateWizardClone.jsp

  Displays the projects to clone from

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
  Reviewed for Level III Compliance by JDH 5/2/2002

  static const char RCSID[] = "$Id: emxprojectCreateWizardClone.jsp.rca 1.44.2.1 Fri Dec 19 02:35:00 2008 ds-panem Experimental $";
--%>
<%@ page import =  "com.matrixone.apps.program.ProgramCentralUtil" %>

<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%
  com.matrixone.apps.program.ProjectSpace project =
    (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context,
    DomainConstants.TYPE_PROJECT_SPACE, "PROGRAM");
  com.matrixone.apps.common.Person person =
    (com.matrixone.apps.common.Person) DomainObject.newInstance(context,
    DomainConstants.TYPE_PERSON);

  String sLanguage = request.getHeader("Accept-Language");

  String suiteKey=(String)emxGetParameter(request,"suiteKey");

  String templateId = (String) emxGetParameter(request, "TemplateId");
  String wizType = (String) emxGetParameter(request, "wizType");
  String busId = (String) emxGetParameter(request, "busId");
  String projectName = (String) emxGetParameter(request, "ProjectName");
  String wbsForm = (String) emxGetParameter(request, "wbsForm");
  String fromWBS = (String) emxGetParameter(request, "fromWBS");
  String businessGoalId     = (String) emxGetParameter(request, "businessGoalId");
  String fromAction     = emxGetParameter(request,"fromAction");
  String fromProgram = (String) emxGetParameter(request, "fromProgram");
  String fromBG = (String) emxGetParameter(request, "fromBG");
  String portalMode     = (String) emxGetParameter(request,"portalMode");
  String wizardType = (String) emxGetParameter(request, "wizardType");
  String cloneOnlyWBS = emxGetParameter(request, "cloneOnlyWBS");

  boolean isECHInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionEnterpriseChange",false,null,null);
  String isChangeProject     = (String) emxGetParameter(request,"isChangeProject");
  isChangeProject = isChangeProject != null ? isChangeProject : "";
  boolean changeProj = "true".equals(isChangeProject);

  ///ADDED for bug 356387
  boolean copyExistingSearchShowSubTypes =true;
  String strShowSubTypes = emxGetParameter(request,"copyExistingSearchShowSubTypes");
  
  if (ProgramCentralUtil.isNotNullString(strShowSubTypes))
  {
      copyExistingSearchShowSubTypes = "true".equalsIgnoreCase(strShowSubTypes);
  }

  String strCopyExistingProjectType = emxGetParameter(request,"copyExistingProjectType");
  if (strCopyExistingProjectType == null || "".equalsIgnoreCase(strCopyExistingProjectType.trim()))
  {
      strCopyExistingProjectType = "type_ProjectManagement";
  }
  String strCopyExistingProjectRealType = PropertyUtil.getSchemaProperty(context, strCopyExistingProjectType);
 ///END

  /*External Cross project Dependency*/
  String hasEditAccess = emxGetParameter(request,"hasEditAccess");
  String externalDependency  = (String) emxGetParameter(request,"externalDependency");

  // Added for Related Projects. Object id of the Parent Project
  String objectId = (String) emxGetParameter(request, "objectId");

  String fromRelatedProjects = emxGetParameter(request,"fromRelatedProjects");

// Master Project Schedule
  String fromSubProjects = emxGetParameter(request,"fromSubProjects");
  String requiredTaskId = emxGetParameter(request,"requiredTaskId");
  String addType = emxGetParameter(request,"addType");
// End - Master Project Schedule

  String pageName = "WizardClone";
  String wizardPageName = emxGetParameter(request,"pageName");
  String strWizType = "";
  String strPageName = "";
  String relRelatedProject = PropertyUtil.getSchemaProperty(context, DomainObject.SYMBOLIC_relationship_RelatedProjects);
  
  // Introduced this variable for questions survey in related projects cloning...
  String clonePage = emxGetParameter(request,"clonePage");

  if (fromWBS==null || "".equals(fromWBS) )
  {
    fromWBS = "false";
  }

  if(wizType == null || "null".equals(wizType))
  {
      wizType = "";
  }

  // Set the person id
  person = person.getPerson(context);

  // Retrieve the person's project list
  StringList relSelects = new StringList(0);
  StringList busSelects = new StringList(7);
  busSelects.add(project.SELECT_DESCRIPTION);
  busSelects.add(project.SELECT_ID);
  busSelects.add(project.SELECT_NAME);
  busSelects.add(project.SELECT_TYPE);
  busSelects.add(project.SELECT_CURRENT);
  busSelects.add(project.SELECT_POLICY);
  busSelects.add("from["+relRelatedProject+"].to.id");
  //Added:28-July-09:nr2:R208:PRG Bug :371950
  busSelects.add("to["+relRelatedProject+"].from.id");
  //End:R208:PRG Bug :371950

  StringBuffer busWhere = new StringBuffer(30);

  //Modified Condition:27-Feb-09:QZV:R207:ECH:Bug:369851
  if(isECHInstalled && !"AddExistingSubProject".equals(wizType) && !"true".equals(fromWBS)) {
      //Modified Where condition with type.kindof:12-Mar-09:QZV:R207:ECH:Bug:369850
	  if(changeProj) {
	      busWhere.append("type.kindof["+ project.TYPE_CHANGE_PROJECT +"] == TRUE");
	  } else {
	      busWhere.append("type.kindof["+ project.TYPE_PROJECT_SPACE +"] == TRUE");
	  }
      //End:R207:ECH:Bug:369850
  }
  if(busWhere.length()== 0){
	  busWhere.append("type != "+ProgramCentralConstants.TYPE_EXPERIMENT);
  }else{
	  busWhere.append(" && type != "+ProgramCentralConstants.TYPE_EXPERIMENT);
  }
  //End:R207:ECH:Bug:369851

  String relWhere = null;
  String stUserId = context.getUser();
  java.util.List tempAlreadyRelated = new ArrayList();
  java.util.List alreadyRelated = new ArrayList();
  java.util.List alreadySubProject = new ArrayList();
  java.util.List alreadyParentProject = new ArrayList();

   MapList projectListwithparent = project.getProjects(context, person, strCopyExistingProjectRealType, busSelects, relSelects, busWhere.toString(), relWhere, copyExistingSearchShowSubTypes);

   //Added for ECH to support Change Disciplines
   String messageNoProjectFound = "";
   if(isECHInstalled){
	   	messageNoProjectFound = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
				  "emxEnterpriseChange.Common.NoProjectFound", sLanguage);
        String parentOID = "";
        if(wizType.equalsIgnoreCase("AddExistingSubProject")){
            //Case for Insert Existing Project Above or Add Existing Project Below
            if(requiredTaskId!=null && !requiredTaskId.isEmpty()){
                if("Child".equals(addType)){
                    parentOID = requiredTaskId.substring(0,requiredTaskId.indexOf("|"));
                }else{
                    parentOID = requiredTaskId.substring(requiredTaskId.indexOf("|")+1);
                }
            }
		}else if(wizType.equalsIgnoreCase("Clone") || wizType.equalsIgnoreCase("Copy")){
            //Case for Copy WBS To Selected Task or Add/Copy WBS
            parentOID = busId;
        }
        //Filter the projectListwithparent in order to allow only project with proper change disciplines
        if(parentOID!=null && !parentOID.isEmpty()){
            HashMap paramMap = new HashMap();
            paramMap.put("objectId", parentOID);
            paramMap.put("projectListwithparent", projectListwithparent);
            paramMap.put("wizType", wizType);
            String[] methodargs = JPO.packArgs(paramMap);
            projectListwithparent = (MapList)JPO.invoke(context, "emxEnterpriseChangeBase", new String[0], "filterProjectListWithParentForChangeDisciplines", methodargs, MapList.class);
        }
   }
   //End Added for ECH to support Change Disciplines

   //added for Related Projects- feature issue fixing UTP
       MapList projectList = new MapList();
      int iSize = projectListwithparent.size();

    //Added:28-July-09:nr2:R208:PRG Bug :371950
    java.util.List relatedProjList = new ArrayList();
    //End:R208:PRG Bug :371950

      for(int iCount=0;iCount<iSize;iCount++){
        Map mpTemp = (Map)projectListwithparent.get(iCount);
        String strParentId = (String)mpTemp.get("id");
        strParentId = strParentId.trim();

       //Added:28-July-09:nr2:R208:PRG Bug :371950
        StringList relProjFromToList = new StringList();
        String strrelProjFromTo = "";
        StringList relProjToFromList = new StringList();
        String strrelProjToFrom = "";
        if(strParentId.equalsIgnoreCase(objectId)){
	        Object relProjFromToObj = mpTemp.get("from["+relRelatedProject+"].to.id");
	        if(relProjFromToObj != null){
		        if(relProjFromToObj instanceof StringList)
		        	relProjFromToList = (StringList)relProjFromToObj;
		        else
		        	strrelProjFromTo = (String) relProjFromToObj;

	            if(relProjFromToList != null && relProjFromToList.size() > 0){
		        	for(int i=0;i<relProjFromToList.size();i++){
		        		String id = (String) relProjFromToList.get(i);
		        		if(!relatedProjList.contains(id))
		        			  relatedProjList.add(id);
		        	}
		        }
		        else if(strrelProjFromTo != null && !"".equals(strrelProjFromTo) && (!relatedProjList.contains(strrelProjFromTo)))
		        	relatedProjList.add(strrelProjFromTo);
	        }

	        Object relProjToFromObj = mpTemp.get("to["+relRelatedProject+"].from.id");
	        if(relProjToFromObj != null){
		        if(relProjToFromObj instanceof StringList)
		        	relProjToFromList = (StringList)relProjToFromObj;
		        else
		        	strrelProjToFrom = (String) relProjToFromObj;

		        if(relProjToFromList != null && relProjToFromList.size() > 0){
		            for(int i=0;i<relProjToFromList.size();i++){
		            	String id = (String) relProjToFromList.get(i);
		            	if(!relatedProjList.contains(id))
		            	    relatedProjList.add(id);
		            }
		        }
		        else if(strrelProjToFrom != null && !"".equals(strrelProjToFrom) && (!relatedProjList.contains(strrelProjToFrom)))
		        	relatedProjList.add(strrelProjToFrom);
	        }
        }
    //End:R208:PRG Bug:371950
          if(!strParentId.equalsIgnoreCase(objectId))
        		  projectList.add(mpTemp);
      }
  //ended for Related Projects- feature issue fixing UTP

    //Added:28-July-09:nr2:R208:PRG Bug :371950
    //Remove related projects from projectList
    MapList tempMapList = new MapList();
    for(int iCnt=0;iCnt<projectList.size();iCnt++){
        Map mpTemp = (Map) projectList.get(iCnt);
        String Id = (String) mpTemp.get("id");
        if(relatedProjList.contains(Id.trim()))
        	tempMapList.add(mpTemp);
    }
    projectList.removeAll(tempMapList);
    //End:R208:PRG Bug :371950

  if(wizType.equalsIgnoreCase("AddExistingRelatedProject")){
     // If the user selects multiple projects and clicks "Insert Existing", need to
     // get all the Projects related to the selected projects, so as not to add them again.
     alreadyRelated = project.getCommonProjects(context,objectId,busSelects,projectList);
  }

// Master Project Schedule
  if(wizType.equalsIgnoreCase("AddExistingSubProject")){
     alreadySubProject = getSubTasks(context, objectId);
     alreadyParentProject = getParentTasks(context, objectId);
  }

  if(wizardPageName != null && !"null".equals(wizardPageName) && !"".equals(wizardPageName) && "fromAddExistingSubProject".equals(wizardPageName))
  {
      strWizType="AddExistingSubtaskProject";
      strPageName = wizardPageName;
  }
// End - Master Project Schedule

  else if(wizardPageName != null && !"null".equals(wizardPageName) && !"".equals(wizardPageName) && "fromAddExistingRelProject".equals(wizardPageName))
  {
      strWizType="AddExistingRelProject";
      strPageName = wizardPageName;
  }
  else
  {
      strWizType = wizType;
      strPageName = pageName;
  }

  String strCommonFS = "emxProgramCentralCommonFS.jsp?suiteKey="+suiteKey+"&topLinks=false&bottomLinks=false&fromAction="+fromAction+"&portalMode="+portalMode;
%>


<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><html>
<html>

<%-- Issue: "System Busy Visual" by Tony An 09/23/02 Begin --%>
<script language="javascript">
  turnOffProgress();
  var jsAlreadyRelated = "<%=alreadyRelated%>";
  var jsAlreadySubProject = "<%=alreadySubProject%>";
  var jsAlreadyParentProject = "<%=alreadyParentProject%>";
</script>
<%-- Issue: "System Busy Visual" by Tony An 09/23/02 End   --%>

  <body class="white">

  <%-- Use the i18n tag using string resource bundle passed from request --%>
<%
	///ADDED for 356389
    String params="wizType="+strWizType+"&wbsForm="+wbsForm+"&busId="+busId+"&fromWBS="+fromWBS+"&ProjectName="+projectName+"&";

	String strStringResourceBundle = emxGetParameter(request, "StringResourceFileId");
	if (strStringResourceBundle == null) {
	    String strTempSuiteKey = suiteKey;
	    if (!suiteKey.startsWith("eServiceSuite"))
	    {
	        strTempSuiteKey = "eServiceSuite" + suiteKey;
	    }
	    strStringResourceBundle = EnoviaResourceBundle.getProperty(context, strTempSuiteKey + ".StringResourceFileId");
	}
	///END
%>
<framework:localize id="i18nId2" bundle="<%=strStringResourceBundle%>" locale='<%= request.getHeader("Accept-Language") %>'/>


    <form name="ProjectsCreateWizardClone" action="emxprojectCreateWizardDispatcher.jsp" method="post" onsubmit="validateForm ();return false">
	      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
      <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="pageName" value="<xss:encodeForHTMLAttribute><%=strPageName%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="p_button" value="" />
      <input type="hidden" name="cloneOnlyWBS" value="<xss:encodeForHTMLAttribute><%=cloneOnlyWBS%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="wizType" value="<xss:encodeForHTMLAttribute><%=strWizType%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="busId" value="<xss:encodeForHTMLAttribute><%=busId%></xss:encodeForHTMLAttribute>" />
      <!-- added for Related Projects -->
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%= objectId != null ? objectId : "" %></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="fromRelatedProjects" value="<xss:encodeForHTMLAttribute><%= fromRelatedProjects != null ? fromRelatedProjects : "" %></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="clonePage" value="<xss:encodeForHTMLAttribute><%=clonePage%></xss:encodeForHTMLAttribute>" />
      <!-- addition ends -->
      <input type="hidden" name="ProjectName" value="<xss:encodeForHTMLAttribute><%=projectName%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="wbsForm" value="<xss:encodeForHTMLAttribute><%=wbsForm%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="businessGoalId" value="<xss:encodeForHTMLAttribute><%=businessGoalId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="fromAction" value="<xss:encodeForHTMLAttribute><%=fromAction%></xss:encodeForHTMLAttribute>" />
      <input type = "hidden" name = "WizardProjectId" value = "" />
      <input type="hidden" name="fromProgram" value="<xss:encodeForHTMLAttribute><%=fromProgram%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="fromBG" value="<xss:encodeForHTMLAttribute><%=fromBG%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="fromWBS" value="<xss:encodeForHTMLAttribute><%=fromWBS%></xss:encodeForHTMLAttribute>" />
      <!-- added for Master Project Schedule -->
      <input type="hidden" name="fromSubProjects" value="<xss:encodeForHTMLAttribute><%=fromSubProjects%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="requiredTaskId" value="<xss:encodeForHTMLAttribute><%=requiredTaskId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="addType" value="<xss:encodeForHTMLAttribute><%=addType%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="isChangeProject" value="<xss:encodeForHTMLAttribute><%=isChangeProject%></xss:encodeForHTMLAttribute>" />
      <!-- End - Master Project Schedule -->


      <framework:sortInit
        defaultSortKey="<%=project.SELECT_NAME%>"
        defaultSortType="string"
        mapList="<%= projectList %>"
        params="<%= params %>"
        resourceBundle="<%=strStringResourceBundle%>"
        ascendText="emxProgramCentral.Common.SortAscending"
        descendText="emxProgramCentral.Common.SortDescending"/>
        
<%

       //Added if else block for bug IR-023805
        if(wizardType!= null && wizardType.equals("AddExistingSubProject" ))
        {
        	wizardType="AddExistingSubProject";
        }else{
        	wizardType="Clone";
        }
      //end for bug IR-023805
      //params do not work in sortInit; this is a work-around for now.
      String uri = (String) pageContext.getAttribute("emxAppLib.uri");
      uri += params;
      pageContext.setAttribute("emxAppLib.uri", uri);
%>

<framework:ifExpr expr='<%=wizType.equalsIgnoreCase("Copy") || fromWBS.equalsIgnoreCase("true") || wizType.equalsIgnoreCase("Clone") || wizType.equalsIgnoreCase("AddExistingRelatedProject") || wizType.equalsIgnoreCase("AddExistingSubProject")%>'>

 &nbsp;
</framework:ifExpr>

       <table border="0" width="100%" class="list">
         <tr>
           <td>
             <table border="0" width="100%">
               <tr>
                 <th width="5%" align="center">
                   <framework:ifExpr expr='<%=wizType.equalsIgnoreCase("AddExistingRelatedProject") || wizType.equalsIgnoreCase("AddExistingSubProject")%>'>
                     <input type="checkbox" name="selectAll" onClick="checkAll(this,'TemplateId');" />
                   </framework:ifExpr>

                   <framework:ifExpr expr='<%=(!(wizType.equalsIgnoreCase("AddExistingRelatedProject")) && !(wizType.equalsIgnoreCase("AddExistingSubProject")))%>'>
                     <framework:i18n localize="i18nId2">emxProgramCentral.Common.Select</framework:i18n>
                   </framework:ifExpr>
                 </th>
                 <th>
                   <framework:ifExpr expr='<%=wizType.equalsIgnoreCase("AddExistingRelatedProject") || wizType.equalsIgnoreCase("AddExistingSubProject")%>'>
                   <framework:i18nScript localize="i18nId">emxProgramCentral.Common.Name</framework:i18nScript>
                     
                   </framework:ifExpr>
                   <framework:ifExpr expr='<%=(!(wizType.equalsIgnoreCase("AddExistingRelatedProject")) && !(wizType.equalsIgnoreCase("AddExistingSubProject")))%>'>
                   <framework:i18nScript localize="i18nId">emxProgramCentral.Common.Title</framework:i18nScript>
                   </framework:ifExpr>
                 </th>
                 <th>
                 <framework:i18nScript localize="i18nId">emxProgramCentral.Common.Type</framework:i18nScript>
                 </th>
                 <th>
                   <framework:ifExpr expr='<%=wizType.equalsIgnoreCase("AddExistingRelatedProject")|| wizType.equalsIgnoreCase("AddExistingSubProject")%>'>
                    <framework:i18nScript localize="i18nId">emxProgramCentral.Common.State</framework:i18nScript>
                   </framework:ifExpr>
                   <framework:ifExpr expr='<%=(!(wizType.equalsIgnoreCase("AddExistingRelatedProject")) && !(wizType.equalsIgnoreCase("AddExistingSubProject")))%>'>
                     <framework:i18nScript localize="i18nId">emxProgramCentral.Common.Status</framework:i18nScript>
                   </framework:ifExpr>
                 </th>
                 <th>
                  <framework:i18nScript localize="i18nId">emxProgramCentral.Common.Description</framework:i18nScript>
                 </th>
               </tr>

               <framework:ifExpr expr="<%= projectList.size() == 0 %>">
                 <tr>
                   <td class="requiredNotice" colspan="5" align="center">
                     <framework:i18n localize="i18nId2">emxProgramCentral.Common.NoProjectFound</framework:i18n>
                     <%if(isECHInstalled){%>
                     	<%=messageNoProjectFound%>
                     <%}%>
                   </td>
                 </tr>
               </framework:ifExpr>

              <framework:ifExpr expr="<%= projectList.size() != 0 %>">
                 <framework:mapListItr mapList="<%= projectList %>" mapName="projectMap">
 <%
    String id = (String) projectMap.get(person.SELECT_ID);
    String newURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId="+id + "&mode=replace";

  //if(id.equals(objectId))
  //continue;

 %>
                   <tr class='<framework:swap id="1"/>'>
                     <td width="5%" align="center">
                       <framework:ifExpr expr='<%=wizType.equalsIgnoreCase("AddExistingSubProject")%>'>
                         <input type="checkbox" name="TemplateId" value="<%=id%>" <% if(id.equals(templateId)){ out.print("checked=\"checked\"");}%> />
                       </framework:ifExpr>
                       <framework:ifExpr expr='<%=wizType.equalsIgnoreCase("AddExistingRelatedProject")%>'>
                         <input type="checkbox" name="TemplateId" <%=project.STATE_PROJECT_ARCHIVE.equals( ( String )projectMap.get(person.SELECT_CURRENT) ) ? "Disabled":""%> value="<%=id%>" <% if(id.equals(templateId)){ out.print("checked=\"checked\"");}%> />
                       </framework:ifExpr>
                       <framework:ifExpr expr='<%=(!(wizType.equalsIgnoreCase("AddExistingRelatedProject"))&& !(wizType.equalsIgnoreCase("AddExistingSubProject")))%>'>
                         <input type="radio" name="TemplateId" value="<%=id%>" <%=project.STATE_PROJECT_ARCHIVE.equals( ( String )projectMap.get(person.SELECT_CURRENT) ) ? "Disabled":""%> <% if(id.equals(templateId)){ out.print("checked=\"checked\"");}%> />
                       </framework:ifExpr>
                     </td>
                     <td nowrap="nowrap">
                       <a href="javascript:showModalDialog('<%=newURL%>', 830, 650)">
                       <framework:ifExpr expr='<%= (projectMap.get(project.SELECT_TYPE)).equals(project.TYPE_PROJECT_SPACE) || (projectMap.get(project.SELECT_TYPE)).equals(project.TYPE_CHANGE_PROJECT) %>'>
                          <img src="../common/images/iconSmallProject.png" border="0" alt="<%= projectMap.get(person.SELECT_NAME) %>" />
                       </framework:ifExpr>
                       <framework:ifExpr expr='<%= (projectMap.get(project.SELECT_TYPE)).equals("Project Concept") %>'>
                          <img src="../common/images/iconSmallProjectConcept.gif" border="0" alt="<%= projectMap.get(person.SELECT_NAME) %>" />
                       </framework:ifExpr>
                         <%= projectMap.get(person.SELECT_NAME) %>
                       </a>&nbsp;
                     </td>
                     <td nowrap="nowrap"><%=i18nNow.getTypeI18NString((String)projectMap.get(person.SELECT_TYPE),sLanguage)%>&nbsp;</td>
                     <td nowrap="nowrap">
                       <%=i18nNow.getStateI18NString((String)projectMap.get("policy"),(String)projectMap.get(person.SELECT_CURRENT),sLanguage)%>
                       &nbsp;
                     </td>
                     <td nowrap="nowrap"><xss:encodeForHTMLAttribute><%= projectMap.get(person.SELECT_DESCRIPTION) %></xss:encodeForHTMLAttribute>&nbsp;</td>
                   </tr>
                 </framework:mapListItr>
               </framework:ifExpr>
             </table>
           </td>
         </tr>
       </table>
       <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" style="-moz-user-focus: none" hidden="true"/>

      <%-- Addition for bug 356387 --%>
		  <input type="hidden" name="copyExistingProjectType" value="<xss:encodeForHTMLAttribute><%=strCopyExistingProjectType%></xss:encodeForHTMLAttribute>"/>
		  <input type="hidden" name="copyExistingSearchShowSubTypes" value="<xss:encodeForHTMLAttribute><%=copyExistingSearchShowSubTypes%></xss:encodeForHTMLAttribute>"/>
	  <%--End Addition for bug 356387 --%>



     </form>
   </body>

   <script language="javascript" type="text/javaScript">//<![CDATA[
   <!-- hide JavaScript from non-JavaScript browsers

     f = document.ProjectsCreateWizardClone;

     function backUp() {
       f.p_button.value = "Back";
       f.submit();
     }

     function cancel() {
       f.p_button.value = "Cancel";
       f.submit();
     }


     function submitSearchedProject(){
<%
	   if(externalDependency !=null && "true".equals(externalDependency)) {
%>
          f.action = "emxProgramCentralDependencyAddDialogFS.jsp?objectId=<%=objectId%>&fromWBS=<%=fromWBS%>&externalDependency=<%=externalDependency%>&hasEditAccess=<%=hasEditAccess%>&mode=internal&topTaskId=null&TemplateId="+f.WizardProjectId.value;
          f.target = "_parent";
	      f.submit();
		  return;
<%
       } else {
%>
		f.p_button.value = "Next";
        //added for bug no. 359801------------------------------
        f.action = "<%=strCommonFS%>"+"&functionality=CreateCloneProjectSpaceStep3";
        f.target = "_parent";
        //added ends ---------------------------
        f.submit();
<%
       }
%>
     }

   function movePrevious(){
<%
 		if ("true".equals(fromWBS)) {
%>
			f.action = "emxProgramCentralProjectCreateDialogFS.jsp?objectId=<%=objectId%>&fromWBS=true&suiteKey=<%=suiteKey%>";
<%
 		}
 		else {
%>
			f.action = "<%=strCommonFS%>"+"&functionality=CreateProjectSpaceStep1";
<%
 		}
 %>
      //Modified for bug 356387
      f.action = f.action + "&copyExistingProjectType=<%=strCopyExistingProjectType%>&copyExistingSearchShowSubTypes=<%=copyExistingSearchShowSubTypes%>";
      f.target = "_parent";
      f.submit();
    }
  function closeWindow()
  {
    parent.window.close();
  }
     /*External Cross project Dependency*/
	 var selectedId = "";
     function validateForm () {
       f = document.ProjectsCreateWizardClone;
       if (validateSelection(f,"TemplateId")) {
		 /*External Cross project Dependency*/
		 if(true == <%=externalDependency%>) {
		  	  startProgressBar(<%="true".equalsIgnoreCase(fromWBS)%>);
			  //showDetailsPopup(url);
              f.action = "emxProgramCentralDependencyAddDialogFS.jsp?objectId=<%=objectId%>&fromWBS=<%=fromWBS%>&externalDependency=<%=externalDependency%>&hasEditAccess=<%=hasEditAccess%>&mode=internal&topTaskId=null&TemplateId="+selectedId;
              f.target = "_parent";
              f.submit();
              return;
          }

// Master Project Schedule
<%
         if("AddExistingSubProject".equals(wizType)){
%>
		 if(checkSubProject(f,"TemplateId") && checkParentProject(f,"TemplateId")){
             startProgressBar(true);
             if (jsDblClick()){
<%
               if(!"AddExistingRelatedProject".equals(wizType) && !"AddExistingSubProject".equals(wizType) &&!"true".equals(fromWBS)){
%>

                 f.action = "<%=strCommonFS%>"+"&functionality=CreateCloneProjectSpaceStep3";
                 f.target = "_parent";
<%             }
%>
               f.submit();
             }
         }
		 else {
			return;
		 }
<%   }
%>
// End - Master Project Schedule

		  if(checkRelated(f,"TemplateId")){
             startProgressBar(true);
             if (jsDblClick()){
<%
               if(!"AddExistingRelatedProject".equals(wizType) && !"AddExistingSubProject".equals(wizType) &&!"true".equals(fromWBS)){
%>
                 f.action = "<%=strCommonFS%>"+"&functionality=CreateCloneProjectSpaceStep3";
                 f.target = "_parent";
<%             }
%>
               f.submit();
             }
         }
       }

 //Added:22-Jan-2011:vf2:R211 PRG:IR-059565
 <%
         if("Copy".equals(wizType)){
 %>
            f.action = "<%=strCommonFS%>"+"&functionality=CreateCloneProjectSpaceStep3";
            f.target = "_parent";
            f.submit();
 <%      }
 %>
//End:22-Jan-2011:vf2:R211 PRG:IR-059565         
     }

// Master Project Schedule
     function checkSubProject(form, chkprefix){
        max = form.elements.length;
        var addedProjCnt = 0;
        for (var counter=0; counter<max; counter++) {
          fieldname = form.elements[counter].name;
          if (fieldname.substring(0,chkprefix.length) == chkprefix) {
            if (form.elements[counter].checked == true) {
              var objId = form.elements[counter].value;

              if(jsAlreadySubProject.indexOf(objId) != -1){
                 addedProjCnt++;
              }

            }
          }
        }
// End - Master Project Schedule

        if(addedProjCnt>0){
           alert("<framework:i18nScript localize="i18nId2">emxProgramCentral.Project.ProjectsAlreadySubtask</framework:i18nScript>");
        }
        else{
           return true;
        }
     }

     function checkParentProject(form, chkprefix){
        max = form.elements.length;
        var addedProjCnt = 0;
        for (var counter=0; counter<max; counter++) {
          fieldname = form.elements[counter].name;
          if (fieldname.substring(0,chkprefix.length) == chkprefix) {
            if (form.elements[counter].checked == true) {
              var objId = form.elements[counter].value;

              if(jsAlreadyParentProject.indexOf(objId) != -1){
                 addedProjCnt++;
              }

            }
          }
        }

        if(addedProjCnt>0){
           alert("<framework:i18nScript localize="i18nId2">emxProgramCentral.Project.ProjectsAlreadySubtask</framework:i18nScript>");
        }
        else{
           return true;
        }
     }
     function checkRelated(form, chkprefix){
        max = form.elements.length;
        var addedProjCnt = 0;
        for (var counter=0; counter<max; counter++) {
          fieldname = form.elements[counter].name;
          if (fieldname.substring(0,chkprefix.length) == chkprefix) {
            if (form.elements[counter].checked == true) {
              var objId = form.elements[counter].value;

              if(jsAlreadyRelated.indexOf(objId) != -1){
                 addedProjCnt++;
              }

            }
          }
        }

        if(addedProjCnt>0){
           alert("<framework:i18nScript localize="i18nId2">emxProgramCentral.Project.ProjectsAlreadyRelated</framework:i18nScript>");
        }
        else{
           return true;
        }
     }

     function validateAddExistingForm() {
         var varChecked = "false";
         var objForm = document.ProjectsCreateWizardClone;
         for( var i = 0; i < objForm.elements.length; i++ ){
              if (objForm.elements[i].type == "checkbox" && objForm.elements[i].checked && objForm.elements[i].name == "projectId" ) {
                  varChecked = "true";
              }
         }

        if (varChecked == "false") {
          alert("<emxUtil:i18nScript localize="i18nId2">emxProgramCentral.Project.SelectProject</emxUtil:i18nScript>");
          return;
        } else {
              objForm.action="emxprojectCreateWizardAction.jsp"
              objForm.submit();
          }
     }

     function doCheck() {
       var objForm = document.ProjectsCreateWizardClone;
       var chkList = objForm.chkList;
       for (var i=0; i < objForm.elements.length; i++)
       if (objForm.elements[i].name.indexOf('projectId') > -1){
         objForm.elements[i].checked = chkList.checked;
       }
     }

    function updateCheck() {
       var objForm = document.ProjectsCreateWizardClone;
       var chkList = objForm.chkList;
       chkList.checked = false;
    }

     function performProjectSearch() {
       var wizTypeVar = "<%=wizType%>";
       if(wizTypeVar == "AddExistingSubProject" ){
          var valObjectId = "<%=objectId%>";
          var valRequiredTaskId = "<%=requiredTaskId%>";
          var valAddType = "<%=addType%>";
          showModalDialog("emxProgramCentralSearchFS.jsp?mode=projectSearch&selectMultiple=false&wizType=AddExistingSubtaskProject&objectId="+valObjectId+"&requiredTaskId="+valRequiredTaskId+"&addType="+valAddType+"&pClose=true", 700, 700, true);
       }
	   else if(wizTypeVar == "AddExistingRelatedProject" ){
          var valObjectId = "<%=objectId%>";
          showModalDialog("emxProgramCentralSearchFS.jsp?mode=projectSearch&selectMultiple=false&wizType=AddExistingRelProject&objectId="+valObjectId+"&pClose=true", 700, 700, true);
       }
        else{
          var url = "emxProgramCentralSearchFS.jsp?mode=projectSearch&selectMultiple=false";
          if(<%=isECHInstalled%>) {
            //Modified:27-Feb-09:QZV:R207:ECH:Bug:369851
          	url += "&isChangeProject=<%=changeProj%>&fromWBS=<%=fromWBS%>";
          	//End:R207:ECH:Bug:369851
          }
          showModalDialog(url, 700, 700, true);
        }
     }

     function validateSelection (form, chkprefix) {
       var passed = 0;
       max = form.elements.length;
       for (var i=0; i<max; i++) {
         fieldname = form.elements[i].name;
         if (fieldname.substring(0,chkprefix.length) == chkprefix) {
           if (form.elements[i].checked == true) {
             selectedId = form.elements[i].value;
             passed = 1;
           }
         }
       }
       if (passed == 1) {
         f.p_button.value = "Next";
         return true;
       } else {
         alert("<emxUtil:i18nScript localize="i18nId2">emxProgramCentral.Project.SelectProject</emxUtil:i18nScript>");
         return false;
       }
     }

     function checkAll (allbox, chkprefix) {
           form = allbox.form;
           max = form.elements.length;
           for (var i=0; i<max; i++) {
             fieldname = form.elements[i].name;
             if (fieldname.substring(0,chkprefix.length) == chkprefix) {
                 form.elements[i].checked = allbox.checked;
             }
           }
     }

   //Stop hiding here -->//]]>
   </script>

 </html>

<%!
// Master Project Schedule
public ArrayList getSubTasks(Context context, String objectId) {
	MapList mapSkills=null;
	ArrayList subtaskIdList = new ArrayList();
	try {
		String subtaskRelationship = PropertyUtil.getSchemaProperty(context, DomainObject.SYMBOLIC_relationship_Subtask);

		StringList busSelects = new StringList(1);
		busSelects.add(DomainObject.SELECT_ID);
		StringList relSelects = new StringList(1);

		mapSkills = new DomainObject(objectId).getRelatedObjects(context, subtaskRelationship,
			"*", busSelects, relSelects, false, true, (short)0, "", "");

		subtaskIdList = new ArrayList(mapSkills.size());

		for(int i=0;i<mapSkills.size();i++) {
			Map map = (Map)mapSkills.get(i);
			subtaskIdList.add(map.get("id"));
		}
	}
	catch(Exception e) {
		System.out.println(e.getMessage());
	}
	return subtaskIdList;
}

public ArrayList getParentTasks(Context context, String objectId) {
	MapList mapSkills=null;
	ArrayList subtaskIdList = new ArrayList();
	try {
		String subtaskRelationship = PropertyUtil.getSchemaProperty(context, DomainObject.SYMBOLIC_relationship_Subtask);

		StringList busSelects = new StringList(1);
		busSelects.add(DomainObject.SELECT_ID);
		StringList relSelects = new StringList(1);

		mapSkills = new DomainObject(objectId).getRelatedObjects(context, subtaskRelationship,
			"*", busSelects, relSelects, true, false,(short)0, "", "");

		subtaskIdList = new ArrayList(mapSkills.size());

		for(int i=0;i<mapSkills.size();i++) {
			Map map = (Map)mapSkills.get(i);
			subtaskIdList.add(map.get("id"));
		}
	}
	catch(Exception e) {
		System.out.println(e.getMessage());
	}
	return subtaskIdList;
}
// End - Master Project Schedule

%>
