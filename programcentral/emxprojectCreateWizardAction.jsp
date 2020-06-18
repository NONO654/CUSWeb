<%--
  emxprojectCreateWizardAction.jsp

  Performs the action to create a project

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxprojectCreateWizardAction.jsp.rca 1.82 Tue Oct 28 18:55:12 2008 przemek Experimental przemek $";
--%>

<%--
Change History:
Date       Change By  Release   Bug/Functionality         Details
-----------------------------------------------------------------------------------------------------------------------------
29-Apr-09   wqy        V6R2010   373702                   Modified logic for inserting existing project in related project.

14-May-09   kyp        V6R2010   375280                   projectDate value is computed from miliseconds before setting into project.
--%>

<%@include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import =  "com.matrixone.apps.program.ProjectSpace" %>
<script src="../programcentral/emxProgramCentralUIFormValidation.js" type="text/javascript"></script>

<%!

    public static final String LANG_ENGLISH = "en";
%>

<%

	//Added for ECH
	boolean isECHInstalled = com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appVersionEnterpriseChange",false,null,null);
	//End Added for ECH

    boolean isEPMInstalled = ProjectSpace.isEPMInstalled(context);
  com.matrixone.apps.program.BusinessGoal businessGoal =
    (com.matrixone.apps.program.BusinessGoal) DomainObject.newInstance(context,
    DomainConstants.TYPE_BUSINESS_GOAL, DomainConstants.PROGRAM);
  com.matrixone.apps.program.Task task =
    (com.matrixone.apps.program.Task) DomainObject.newInstance(context,
    DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
  com.matrixone.apps.program.ProjectSpace project =
    (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context,
    DomainConstants.TYPE_PROJECT_SPACE, DomainConstants.PROGRAM);
  com.matrixone.apps.program.ProjectTemplate template =
    (com.matrixone.apps.program.ProjectTemplate) DomainObject.newInstance(context,
    DomainConstants.TYPE_PROJECT_TEMPLATE, DomainConstants.PROGRAM);
    //com.matrixone.apps.common.ProjectManagement projectmanagement = new ProjectManagement();
%>

<%

    // Particular requirement of TaskDateRollup.java logic. The internal calculations are taking time factors into consideration
    int DEFAULT_START_HOUR_OF_DAY = 8;
    double DEFAULT_HOURS_PER_DAY = 8;
    int DEFAULT_FINISH_HOUR_OF_DAY = 17;

    //
    // Initialize constants from Dimension object for task durations
    //
        matrix.db.UnitList _units;
        AttributeType objAttrType = new AttributeType(DomainConstants.ATTRIBUTE_TASK_ESTIMATED_DURATION);

         try
         {
             Dimension dimension = objAttrType.getDimension(context);
             if (dimension != null)
             {
                 _units = dimension.getUnits(context);
                 if (_units.size() != 0)
                 {
                     UnitItr uitr = new UnitItr(_units);
                     while(uitr.next())
                     {
                         Unit unit = (Unit) uitr.obj();

                         if (unit.getName().equals("h"))
                         {
                             String multiplier = unit.getMultiplier();
                             DEFAULT_HOURS_PER_DAY = (1.0 / Double.parseDouble(multiplier));
                             DEFAULT_FINISH_HOUR_OF_DAY = DEFAULT_START_HOUR_OF_DAY + (int) DEFAULT_HOURS_PER_DAY + 1;
                         }
                     }//while
                 }//if
             }//if
         }
         catch (Exception e)
         { /*Do nothing and assume defualt values for the constants*/        }


        String subtypes = MqlUtil.mqlCommand(context,
                                             "print type $1 select $2 dump $3",
                                              task.TYPE_TASK_MANAGEMENT,"derivative","|"); //PRG:RG6:R213:Mql Injection:Static Mql:20-Oct-2011
        StringList _taskTypes = FrameworkUtil.split(subtypes, "|");
      _taskTypes.add(0, task.TYPE_TASK_MANAGEMENT);

  boolean error = false;
  StringList alreadyExistingProjectNames=new StringList();
  String pClose = emxGetParameter(request, "pClose");
  try{
  String wizType = emxGetParameter(request, "wizType");
	String cloneOnlyWBS = emxGetParameter(request, "cloneOnlyWBS");
  String busId = emxGetParameter(request, "busId");
  String relatedProjectId = "";
  String fromRelatedProjects = emxGetParameter(request, "fromRelatedProjects");
  String parentProjectId = emxGetParameter(request, "parentProjectId");
   Map<String,String> projectScheduleMap = ProgramCentralUtil.getProjectSchedule(context, parentProjectId);
	String projectSchedule = projectScheduleMap.get(parentProjectId);
  String currentFrame = XSSUtil.encodeURLForServer(context, emxGetParameter(request, "portalCmdName"));
  // When coming from 'Insert New' / 'Insert Existing', there can be more than one
  // parent projects.
  String[] parentProjects = new String[1];

  if(parentProjectId !=null && parentProjectId.indexOf("|") != -1 ){ // Insert New / Insert Existing
      StringTokenizer st = new StringTokenizer(parentProjectId,"|");
      int i=0;
      //Modified:29-Apr-09:wqy:R207:PRG Bug :373702
      if(st.hasMoreTokens())
      {
          parentProjects[i] = st.nextToken();
          i++;
      }
  }
  else{
      parentProjects[0] = parentProjectId; // Create New
  }

  String fromPage = emxGetParameter(request,"fromPage");
  String relatedProjectRelationship = PropertyUtil.getSchemaProperty(context, DomainObject.SYMBOLIC_relationship_RelatedProjects);


// Master Project Schedule
  String fromSubProjects = emxGetParameter(request, "fromSubProjects");
  String requiredTaskId = emxGetParameter(request, "requiredTaskId");
  String addType = emxGetParameter(request, "addType");
  String subtaskRelationship = PropertyUtil.getSchemaProperty(context, DomainObject.SYMBOLIC_relationship_Subtask);

  boolean addAsSubProject = false;
 if("true".equalsIgnoreCase(fromSubProjects)){
      addAsSubProject = true;
  }
 StringBuffer sBuff = null;
// End - Master Project Schedule

  boolean addAsRelatedProject = false;
  if("true".equalsIgnoreCase(fromRelatedProjects)){
      addAsRelatedProject = true;
  }

  String projectType = emxGetParameter(request, "ProjectType");
  String projectName = emxGetParameter(request, "ProjectName");
//Added:23-Jun-09:yox:R208:PRG:Project & Task Autonaming
  if(projectName== null){
      projectName =  com.matrixone.apps.domain.util.FrameworkUtil.autoName(context,
                              "type_ProjectSpace",
                              null,
                              "policy_ProjectSpace",
                              null,
                              null,
                              true,
                              true);

  }
//End:R208:PRG :Project & Task Autonaming
  String programId = emxGetParameter(request, "ProgramId");
  String projectVisibility = emxGetParameter(request, "ProjectVisibility");
  String baseCurrency = emxGetParameter(request, "Currency");
  String projectDescription = emxGetParameter(request, "ProjectDescription");
  String projectDate = emxGetParameter(request, "projectDate");//for reverse calendaring
  String resourceRequest = emxGetParameter(request, "resourceRequest");//for reverse calendaring
  String projectDate_msValue = emxGetParameter(request, "projectDate_msValue");
  //String projectStartDate = emxGetParameter(request, "projectStartDate");
  String defaultVault = emxGetParameter(request, "defaultVault");
  String defaultStore = emxGetParameter(request, "defaultStore");
  String fromProgram = emxGetParameter(request, "fromProgram");
  String fromBG = emxGetParameter(request, "fromBG");
  String fromClone = emxGetParameter(request, "fromClone");
//Added:23-Jun-09:yox:R208:PRG:Project & Task Autonaming
  String tasksAutoName = emxGetParameter(request, "tasksAutoName");
  boolean isTaskAutoname = false;
  if("checked".equalsIgnoreCase(tasksAutoName)){
      isTaskAutoname = true;
  }
//End:R208:PRG :Project & Task Autonaming
  //Initialized globally for the EPM-PMC merge
  String icProjURL      = emxGetParameter(request,DomainConstants.ATTRIBUTE_IC_PROJECT_URL);
  String DSServer       = emxGetParameter(request,"server");
  String DSPath         = emxGetParameter(request,"path");
  String DSFormat       = emxGetParameter(request,"format");
  String DSSelector     = emxGetParameter(request,"selector");
  String projectScheduleFrom     = emxGetParameter(request,"ScheduleFrom");//For Reverse calendaring
  String DSFileFolder   = "File";
    //End of global Initializations
  if ("null".equals(fromClone) || "".equals(fromClone) || fromClone == null )
  {
    fromClone = "false";
  }

  String projectDuration = emxGetParameter(request, "ProjectDuration");
  String selectedPolicy = emxGetParameter(request, "selectedPolicy");

  // Changed to String[] for the use case of add existing related projects
  String[] templateIds = emxGetParameterValues(request,"TemplateId");

  //Added to parse the Ids of project to add above the selected task and related project...  
  String insertExistingProjectAboveMode     = emxGetParameter(request,"insertExistingProjectAboveMode");
  String insertExistingProjectBelowMode     = emxGetParameter(request,"insertExistingProjectBelowMode");
  String addRelatedProjectMode    = emxGetParameter(request,"addRelatedProjectMode");
 if(ProgramCentralConstants.INSERT_EXISTING_PROJECT_ABOVE.equalsIgnoreCase(insertExistingProjectAboveMode)|| ProgramCentralConstants.INSERT_EXISTING_PROJECT_BELOW.equalsIgnoreCase(insertExistingProjectBelowMode) || ProgramCentralConstants.ADD_RELATED_PROJECT_MODE.equalsIgnoreCase(addRelatedProjectMode))
    {	 	  
	  templateIds = emxGetParameterValues(request,"emxTableRowId");
	  templateIds = ProgramCentralUtil.parseTableRowId(context,templateIds);
		 	 
	 }     
  String templateId = "";
  if(templateIds!= null && templateIds.length ==1){
      templateId = templateIds[0];
  }
  String[] selectedProjectIds = null;
  if(wizType.equalsIgnoreCase("AddExisting"))
  {
    selectedProjectIds = emxGetParameterValues(request, "projectId");
    if (selectedProjectIds==null)
    {
      selectedProjectIds = emxGetParameterValues(request, "TemplateId");
   }
  }
  String[] relationshipIds = emxGetParameterValues(request,"selectedIds");
  String BusinessUnitId = emxGetParameter(request, "BusinessUnitId");
  String businessGoalId = emxGetParameter(request, "businessGoalId");
  String fromAction     = emxGetParameter(request,"fromAction");
  String portalMode     = emxGetParameter(request,"portalMode");
  String connectRelatedProjects = emxGetParameter(request, "connectRelatedProjects");
  //Commented the if condition for fixing the Bug 340804
  //if(!isEPMInstalled)
//  {
      if(!"null".equals(fromPage) && fromPage!=null && "SearchResults".equals(fromPage))
      {
          templateIds = emxGetParameterValues(request,"selectedObject");
    %>
          <script language="javascript">
              var href = parent.window.getWindowOpener().parent.getWindowOpener().document.location.href;
              parent.window.getWindowOpener().parent.getWindowOpener().document.location.href=href;
          </script>
    <%
      }
 // }
          //added newly
  if(isEPMInstalled)
  {


      if ((DSFormat == null) || ("".equals(DSFormat)) || ("null".equals(DSFormat)))
        DSFormat = "generic";


      if (DSServer!=null && !DSServer.equals("None"))
      {

        String storeData = MqlUtil.mqlCommand(context, "print store $1 select $2 $3 $4 $5 dump $6;", DSServer,"protocol","host","port","path", "|");

        StringTokenizer storeTok = new StringTokenizer(storeData, "|");
        String protocol = "";
        if (storeTok.hasMoreTokens())
          protocol = storeTok.nextToken(); // protocol
        if (protocol.indexOf("https") == 0)
          protocol = "syncs";
        else if (protocol.indexOf("http") == 0)
          protocol = "sync";

        StringBuffer DSUrl = new StringBuffer(128);
        DSUrl.append(protocol);
        DSUrl.append("://");
        if (storeTok.hasMoreTokens())
           DSUrl.append(storeTok.nextToken());  // host
        else
           DSUrl.append("localhost");  // host
        DSUrl.append(":");
        if (storeTok.hasMoreTokens())
          DSUrl.append(storeTok.nextToken());  // port
        else
          DSUrl.append("2647");  // port

        String tmpPath = "";
        if (storeTok.hasMoreTokens())
        {
            tmpPath = storeTok.nextToken();

            if (tmpPath.equals("/"))
              tmpPath = "";

            if (tmpPath.indexOf("/") == 0)
              tmpPath = tmpPath.substring(1);

            if ((tmpPath.lastIndexOf("/") == (tmpPath.length() - 1)) &&
                (tmpPath.lastIndexOf("/") != 0) &&
                (!tmpPath.equals("")))
              tmpPath = tmpPath.substring(0, tmpPath.length() - 1);

            DSUrl.append("/");
            DSUrl.append(tmpPath);  // path
        }

        if (DSPath.indexOf("/") != 0)
          DSUrl.append("/");
        DSUrl.append(DSPath);

        DSPath = VCDocument.processSyncUrlData(context, DSPath);
        icProjURL = VCDocument.processSyncUrlData(context, DSUrl.toString());
      }
      else
      {

          if (DSPath==null || DSPath.equals(""))
            DSPath = "/";

          DSPath = VCDocument.processSyncUrlData(context, DSPath);
          icProjURL = DSPath;
          DSServer = "";

      }
  } //end newly

  Map answerList = (Map)session.getAttribute("answerList");
  session.removeAttribute("answerList");
  if(answerList == null){
    //set up map for question for template
    answerList = new HashMap();
    Enumeration enumParam = emxGetParameterNames(request);
    while (enumParam.hasMoreElements()) {
      String name = (String) enumParam.nextElement();
      if(name.startsWith("question_")) {
        String value = emxGetParameter(request, name);
        name = name.substring(9);
        answerList.put(name, value);
      }
    }
  }
  MapList attrMapList = (MapList) session.getAttribute("attributeMapCreate");
  session.removeAttribute("attributeMapCreate");
  Locale locale = request.getLocale();
  context.setLocale(locale);
  double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
  if(projectDate != null){
      projectDate = projectDate.trim();

      long lngMS = Long.parseLong(projectDate_msValue);
      Date date = new Date(lngMS);

      DateFormat dateFmt = DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), Locale.US);
      projectDate = dateFmt.format(date);

    if ("Project Start Date".equals(projectScheduleFrom)) {
         projectDate = eMatrixDateFormat.getFormattedInputDateTime(context,
                projectDate,
                ((DEFAULT_START_HOUR_OF_DAY > 12)?(DEFAULT_START_HOUR_OF_DAY-12):DEFAULT_START_HOUR_OF_DAY) + ":00:00 " + ((DEFAULT_START_HOUR_OF_DAY >= 12)? "PM":"AM"),
                eMatrixDateFormat.getEMatrixDisplayDateFormat(),
                clientTZOffset,
                Locale.US);
    }
    else if ("Project Finish Date".equals(projectScheduleFrom)) {
        projectDate = eMatrixDateFormat.getFormattedInputDateTime(context,
                projectDate,
                ((DEFAULT_FINISH_HOUR_OF_DAY > 12)?(DEFAULT_FINISH_HOUR_OF_DAY-12):DEFAULT_FINISH_HOUR_OF_DAY) + ":00:00 " + ((DEFAULT_FINISH_HOUR_OF_DAY >= 12)? "PM":"AM"),
                eMatrixDateFormat.getEMatrixDisplayDateFormat(),
                clientTZOffset,
                Locale.US);
    }
  }


  boolean bFromProgram = false;
  if (fromProgram != null && ! "".equals(fromProgram)  && ! "null".equals(fromProgram)) {
    bFromProgram = true;
  }


  boolean importIntoExistingProj = true;
  if (busId == null || "null".equals(busId) || "".equals(busId)){
    importIntoExistingProj = false;
  }

  // Schema Values
  String projType = project.getDefaultPolicy(context);
  String projTemplateType = template.getDefaultPolicy(context);

  // get form values;
  if (projectType == null || "null".equals(projectType) || "".equals(projectType)) {
    if (busId == null || "null".equals(busId) || "".equals(busId)) {
      projectType = project.getDefaultPolicy(context);
    } else {
      projectType = "";
    }
  }

  if (selectedPolicy == null || "".equals(selectedPolicy) || "null".equals(selectedPolicy)){
    selectedPolicy = project.getDefaultPolicy(context);
  }

  String newbusId = "" ;
  HashMap hiddenAttributeMap=new HashMap();

  context.start(true);

  try {
    if (wizType.equals("Template")) {
      if (busId == null || "".equals(busId) || "null".equals(busId)) {
         // create a project based on a template
         template.setId(templateId);
         // Added:14-Jan-10:nzf:R209:PRG:Bug:IR-032717
//         ContextUtil.pushContext(context);
//         template.setAttributeValue(context,DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_DATE,projectDate);
//         ContextUtil.popContext(context);
         // End:R209:PRG:Bug:IR-032717
         // added newly
 if(isEPMInstalled)
  {
          if(icProjURL !=null && !"null".equals(icProjURL))
          {
             project = (com.matrixone.apps.program.ProjectSpace)template.clone(context, projectType,
                                                                               projectName, selectedPolicy, defaultVault,
                                                                               answerList, icProjURL,isTaskAutoname);
             // Modified for Bug#340632 on 8/30/2007 - Begin
             if(addAsRelatedProject){
            relatedProjectId = project.getId();
            DomainRelationship.connect(context,new DomainObject(relatedProjectId),relatedProjectRelationship,false,parentProjects,false);
         }
         // Modified for Bug#340632 on 8/30/2007 - End
             String projId = project.getInfo(context,project.SELECT_ID);
            String kw1="", kw2="";            
             if (DSFileFolder.equals("File"))
             {
                kw1="vcfile";
                kw2="selector";
            }
            else
            {
                kw1="vcfolder";
                kw2="config";
            }
            if (DSSelector == null || "".equals(DSSelector) || "null".equals(DSSelector))
            {
                DSSelector = "";
            }

            MqlUtil.mqlCommand(context, "connect bus $1 $2 $3 $4 $5 store $6 format $7 complete;",projId,kw1,DSPath,kw2,DSSelector,DSServer,DSFormat);

            project.setDeliverableDSFA(context, DSServer, DSSelector, DSPath);
          }
          else
          {
        //end newly
         project = (com.matrixone.apps.program.ProjectSpace)template.clone(context, projectType,
                                                               projectName, selectedPolicy, defaultVault, answerList,isTaskAutoname);

         if(addAsRelatedProject){
            relatedProjectId = project.getId();
            DomainRelationship.connect(context,new DomainObject(relatedProjectId),relatedProjectRelationship,false,parentProjects,false);
         }
          }  //newly added
      }
        else
          {
        	Map projectAttr = new HashMap();
            if (ProgramCentralUtil.isNotNullString(projectVisibility)) {
                projectAttr.put(ProgramCentralConstants.ATTRIBUTE_PROJECT_VISIBILITY, projectVisibility);
			}
            project = (com.matrixone.apps.program.ProjectSpace)template.clone(context, projectType, projectName, selectedPolicy, defaultVault, answerList, "", isTaskAutoname, projectAttr);
            //project = (com.matrixone.apps.program.ProjectSpace)template.clone(context, projectType, projectName, selectedPolicy, defaultVault, answerList, isTaskAutoname);
         if(addAsRelatedProject){
            relatedProjectId = project.getId();
            DomainRelationship.connect(context,new DomainObject(relatedProjectId),relatedProjectRelationship,false,parentProjects,false);
         }
          }
      } else {
        project.setId(busId);

        String type = project.getInfo(context, project.SELECT_TYPE);
        if (_taskTypes.indexOf(type) == -1)
        {
          String startDateStr = project.getInfo(context, project.SELECT_TASK_ESTIMATED_START_DATE);
          long startMil = Date.parse(startDateStr);
          Date startDate = new Date(startMil);
          project.addTasks(context, templateId, answerList);
          //task.setId(busId);
          //task.updateStartDate(context, startDate);
        } else {
          task.setId(busId);
          String startDateStr = task.getInfo(context, task.SELECT_TASK_ESTIMATED_START_DATE);
          long startMil = Date.parse(startDateStr);
          Date startDate = new Date(startMil);
          task.addTasks(context, templateId, answerList);
          //task.updateStartDate(context, startDate);
        }
      }
    } else if (wizType.equals("Blank")) {
      // create a blank project
      project.create(context, projectType, projectName, selectedPolicy, context.getVault().getName());
      if(addAsRelatedProject){
          relatedProjectId = project.getId();
          DomainRelationship.connect(context,new DomainObject(relatedProjectId),relatedProjectRelationship,false,parentProjects,false);
      }
//added newly
     if(isEPMInstalled)
  {
      if(icProjURL !=null && !"null".equals(icProjURL))
      {
            Map attrMap = new HashMap();
            attrMap.put(DomainConstants.ATTRIBUTE_IC_PROJECT_URL, icProjURL);
            project.setAttributeValues(context, attrMap);
            String projId = project.getInfo(context,project.SELECT_ID);
            String kw1="", kw2="";            
             if (DSFileFolder.equals("File"))
             {
                kw1="vcfile";
                kw2="selector";
            }
            else
            {
                kw1="vcfolder";
                kw2="config";
            }
            if (DSSelector == null || "".equals(DSSelector) || "null".equals(DSSelector))
            {
                DSSelector = "";
            }

            MqlUtil.mqlCommand(context, "connect bus $1 $2 $3 $4 $5 store $6 format $7 complete;",projId,kw1,DSPath,kw2,DSSelector,DSServer,DSFormat);

            project.setDeliverableDSFA(context, DSServer, DSSelector, DSPath);
        }
  }
//end newly

    } else if (wizType.equals("Clone")) {
      if (busId == null || "".equals(busId) || "null".equals(busId)) {
        // clone a project
        project.setId(templateId);

        //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
        String sCommandStatement = "print type $1 select $2 $3 dump $4";
        String hiddenAttributes =  MqlUtil.mqlCommand(context, sCommandStatement,projectType, "attribute","attribute.hidden","|"); 
        //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End

        StringTokenizer st = new StringTokenizer(hiddenAttributes,"|");
        int count = st.countTokens()/2;
        ArrayList attrNameList = new ArrayList(count);
        ArrayList attrHiddenList = new ArrayList(count);

        int tempcnt = 1;
        String attName="";
        String attHidden="";
        while(st.hasMoreTokens())
        {
          if(tempcnt <= count) {
            attName=st.nextToken().trim();
            attrNameList.add(attName);
          }
          else {
            attHidden=st.nextToken().trim();
            attrHiddenList.add(attHidden);
          }
          tempcnt++;
        }

        for(int ii=0;ii<attrHiddenList.size();ii++)
        {
          if(attrHiddenList.get(ii).equals("TRUE"))
          {
            // Modified:22-Jul-09:nzf:R208:PRG:Bug:377292
              if("Task Approval".equals(attrNameList.get(ii))){
                  if("".equals(project.getAttributeValue(context,(String)attrNameList.get(ii)))){
                      hiddenAttributeMap.put(attrNameList.get(ii), "FALSE");
                  }
              }else{
                    hiddenAttributeMap.put(attrNameList.get(ii), project.getAttributeValue(context,(String)attrNameList.get(ii)));
              }
            // End:R208:PRG:Bug:377292
          }
        }

        int size = 0;
        int index = 0;
        String[] selectedProjectsRelPrjIds = new String[1];
//added newly
 if(isEPMInstalled)
  {
        if(icProjURL !=null && !"null".equals(icProjURL))
        {
            project = (com.matrixone.apps.program.ProjectSpace)project.clone(context, projectType,
                                                              projectName, selectedPolicy, defaultVault, null,icProjURL);
            String projId = project.getInfo(context,project.SELECT_ID);
            
            String kw1="", kw2="";            
             if (DSFileFolder.equals("File"))
             {
                kw1="vcfile";
                kw2="selector";
            }
            else
            {
                kw1="vcfolder";
                kw2="config";
            }
            if (DSSelector == null || "".equals(DSSelector) || "null".equals(DSSelector))
            {
                DSSelector = "";
            }

            MqlUtil.mqlCommand(context, "connect bus $1 $2 $3 $4 $5 store $6 format $7 complete;",projId,kw1,DSPath,kw2,DSSelector,DSServer,DSFormat);
            project.setDeliverableDSFA(context, DSServer, DSSelector, DSPath);
        }
        else
        {
//end newly
        if("true".equals(connectRelatedProjects)){
            /* for connecting all related projects also ! */

            String strSelectedProjectsRelPrjIds = emxGetParameter(request, "selectedProjectsRelPrjIds");
            StringList relatedProjectList = null;

            if(strSelectedProjectsRelPrjIds != null){
                relatedProjectList = FrameworkUtil.split(strSelectedProjectsRelPrjIds,"|");
            }

            size = relatedProjectList.size();
            selectedProjectsRelPrjIds = new String[size];

            Iterator itrRelPrjItr = relatedProjectList.iterator();
            int i=0;
            while(itrRelPrjItr.hasNext()){
                selectedProjectsRelPrjIds[i] = (String) itrRelPrjItr.next();
                i++;
            }
        }
        project = (com.matrixone.apps.program.ProjectSpace)project.clone(context, projectType,projectName, selectedPolicy, defaultVault, null);
        }         //new elz end

     }
     else{
      if("true".equals(connectRelatedProjects)){
            /* for connecting all related projects also ! */

            String strSelectedProjectsRelPrjIds = emxGetParameter(request, "selectedProjectsRelPrjIds");
            StringList relatedProjectList = null;

            if(strSelectedProjectsRelPrjIds != null){
                relatedProjectList = FrameworkUtil.split(strSelectedProjectsRelPrjIds,"|");
            }

            size = relatedProjectList.size();
            selectedProjectsRelPrjIds = new String[size];

            Iterator itrRelPrjItr = relatedProjectList.iterator();
            int i=0;
            while(itrRelPrjItr.hasNext()){
                selectedProjectsRelPrjIds[i] = (String) itrRelPrjItr.next();
                i++;
            }
        }
  		Map projectAttr = new HashMap();
    	if (ProgramCentralUtil.isNotNullString(projectVisibility)) {
        	projectAttr.put(ProgramCentralConstants.ATTRIBUTE_PROJECT_VISIBILITY, projectVisibility);
		}
    	project = (com.matrixone.apps.program.ProjectSpace)project.clone(context, projectType, projectName, selectedPolicy, defaultVault, null, "", false, projectAttr);
        //project = (com.matrixone.apps.program.ProjectSpace)project.clone(context, projectType,projectName, selectedPolicy, defaultVault, null);
          }
        project.setAttributeValues(context, hiddenAttributeMap);
        // project is created....

        relatedProjectId = project.getId();
        // based on the flag connect all the source project's related projects as well to this newly created project
        if("true".equals(connectRelatedProjects) && size > 0){
            DomainRelationship.connect(context,new DomainObject(relatedProjectId),relatedProjectRelationship,true,selectedProjectsRelPrjIds,false);
        }
        if(addAsRelatedProject){
            // Connect the newly created project as a related project to the parent (current) project
            DomainRelationship.connect(context,new DomainObject(relatedProjectId),relatedProjectRelationship,false,parentProjects,false);
        }
      } else {
        project.setId(busId);
        String type = project.getInfo(context, project.SELECT_TYPE);
        if (_taskTypes.indexOf(type) == -1)
        {
        	project.setId(templateId);
        	com.matrixone.apps.program.Task srcTask = new com.matrixone.apps.program.Task(project);
      		com.matrixone.apps.program.Task targetTask = new com.matrixone.apps.program.Task(busId);
      		srcTask.cloneWBS(context, targetTask, null,null, null, false,false, null); //project.addTasks(context, templateId, null);
      		project.setId(busId);
} else {
          task.setId(busId);
          task.addTasks(context, templateId, null);
        }

        task.setId(busId);
        task.importStartDate(context, new Date(Date.parse(task.getInfo(context, task.SELECT_TASK_ESTIMATED_START_DATE))));
      }
    } else if(wizType.equals("Copy")){
      // this is where you copy all the relationship IDs to the new structure.
      project.setId(busId);
      for(int i = 0; i<relationshipIds.length; i++){
        String tempTaskId = relationshipIds[i].substring(relationshipIds[i].indexOf('|')+1);
        relationshipIds[i] = tempTaskId;
      }
      project.addTask(context, relationshipIds, null);
      task.setId(busId);
    }

// Master Project Schedule
    else if(wizType.equals("AddExistingSubtaskProject")){
        boolean bAdded = false;
        Task subProjectTask = new Task();
       for(int i=0;i<parentProjects.length;i++)
       {
              StringList busSelects = new StringList(1);
              busSelects.add(DomainObject.SELECT_ID);
              busSelects.add(DomainObject.SELECT_NAME);
              StringList relSelects = new StringList(1);
              //to store the object ids which are already connected
               Map alreadySubtaskProjects = new HashMap();

              MapList mapSkills = new DomainObject(parentProjects[i]).getRelatedObjects(context, subtaskRelationship, ProgramCentralConstants.TYPE_PROJECT_MANAGEMENT, busSelects, relSelects, false, true, (short)0, "", "");

              if ( mapSkills!=null && mapSkills.size() > 0 )
              {
                    alreadySubtaskProjects = new HashMap(mapSkills.size());
                    for ( int j = 0; j<mapSkills.size();j++ )
                    {
                        alreadySubtaskProjects.put((String)(((Map)mapSkills.get(j)).get("id")),(String)(((Map)mapSkills.get(j)).get("name")));
                    }
              }
			  if(!alreadySubtaskProjects.containsKey(parentProjectId))
              {
            	  DomainObject parentObjectId = DomainObject.newInstance(context,parentProjectId);
            	  String parentProjectName=parentObjectId.getName(context);
            	  alreadySubtaskProjects.put(parentProjectId,parentProjectName);
              }
                    String childId = requiredTaskId.substring(0,requiredTaskId.indexOf("|"));
                    String siblingId = requiredTaskId.substring(requiredTaskId.indexOf("|")+1);
                    String atTaskId = "";
                    if ("Child".equals(addType)) {
                        atTaskId = requiredTaskId.substring(0,requiredTaskId.indexOf("|"));
                    }
                    else {
                        atTaskId = requiredTaskId.substring(requiredTaskId.indexOf("|")+1);
                    }
                    Vector vecChildIds = new Vector(templateIds.length);

                    for (int j=0;j<templateIds.length;j++) {
                        if(!alreadySubtaskProjects.containsKey(templateIds[j])) {
                            vecChildIds.add((String)templateIds[j]);
                        }
                        else
                        {
                            alreadyExistingProjectNames.add((String)alreadySubtaskProjects.get(templateIds[j]));
                        
                        }
                    }
                    String []childIds = new String[vecChildIds.size()];
                    for(int c=0;c<childIds.length;c++) {
                        childIds [c] = (String) vecChildIds.get(c);
                    }
                    //com.matrixone.apps.common.Task task1 = new com.matrixone.apps.common.Task();

                    if ("Child".equals(addType)) {
                        atTaskId = requiredTaskId.substring(0,requiredTaskId.indexOf("|"));
                        subProjectTask.setId(atTaskId); //Di7 below
                    }
                    else {
                        atTaskId = requiredTaskId.substring(requiredTaskId.indexOf("|")+1);
                        subProjectTask.setId(atTaskId); //di7 above
                        //Modified for Bug # 341152 on 9/13/2007 - Begin
                        atTaskId = requiredTaskId.substring(0,requiredTaskId.indexOf("|"));
                        //Modified for Bug # 341152 on 9/13/2007 - End
                    }
                    
                    //Added code for whatIf Add existing project below or above functionality
                    String strProjectType = DomainObject.EMPTY_STRING;
                    DomainObject taskObject = DomainObject.newInstance(context,atTaskId);
                    if(!taskObject.getType(context).equalsIgnoreCase(ProgramCentralConstants.TYPE_EXPERIMENT)){
                    	strProjectType = taskObject.getInfo(context,ProgramCentralConstants.SELECT_PROJECT_TYPE);
                    }
                    if((strProjectType != null && ProgramCentralConstants.TYPE_EXPERIMENT.equalsIgnoreCase(strProjectType)) || 
                    		taskObject.getType(context).equalsIgnoreCase(ProgramCentralConstants.TYPE_EXPERIMENT)){
                    	String strAddProject = subProjectTask.getObjectId(context);
                    	com.matrixone.apps.program.Experiment experiment =  new com.matrixone.apps.program.Experiment(strAddProject);
                    	experiment.addExistingProjectBelowOrAbove(context, childIds, atTaskId);
                    }else{
                        
                        java.util.List<String> subProjectIds = java.util.Arrays.asList(childIds);
                        
                        if("Child".equals(addType)) {
                        	subProjectTask.addExistingProject(context, subProjectIds, null, true); 
                        }
                        else{
                        	subProjectTask.addExistingProject(context, subProjectIds, atTaskId, true);
                        }
                      
                    }//End
                    
                    // Start Structure Browser Add/Remove Feature Implementation
                    if ("Child".equals(addType) && childIds.length!=0) {
                        String newTaskAction = "add";
                        sBuff = new StringBuffer();
                        String childRelDir = "";
                        String childRelId = "";
                        MapList utsList =null;
                        relSelects.add(DomainConstants.SELECT_RELATIONSHIP_ID);
                        relSelects.add(DomainRelationship.SELECT_DIRECTION);
                        sBuff.append("<mxRoot>");
                        sBuff.append("<action><![CDATA["+newTaskAction+"]]></action>");
                        sBuff.append("<data status=\"committed\">");

                        for(int m=0;m<childIds.length;m++){
                            utsList = subProjectTask.getRelatedObjects(context,
                                                        subtaskRelationship,
                                                        DomainConstants.TYPE_PROJECT_MANAGEMENT,
                                                        busSelects,
                                                        relSelects, // relationshipSelects
                                                        false,      // getTo
                                                        true,       // getFrom
                                                        (short) 1,  // recurseToLevel
                                                        "id=="+childIds[m],// objectWhere
                                                        null);      // relationshipWhere
                            Map map = (Map) utsList.get(0);
                            childRelDir = (String)map.get(DomainRelationship.SELECT_DIRECTION);
                            childRelId = (String)map.get(DomainConstants.SELECT_RELATIONSHIP_ID);
                            sBuff.append("<item oid=\""+childIds[m]+"\" relId=\""+childRelId+"\" pid=\""+atTaskId+"\"  direction=\""+childRelDir+"\" />");
                        }
                        sBuff.append("</data>");
                        sBuff.append("</mxRoot>");
                    }
                    // End Structure Browser Add/Remove Feature Implementation
       }
    }
// End - Master Project Schedule

    else if(wizType.equals("AddExistingRelProject")){
       for(int i=0;i<parentProjects.length;i++)
       {
          // Logid added by Pavan on 28-Feb-2006 to ensure already related projects are not connected and eliminate the Transaction exception seen on the browser

              StringList busSelects = new StringList(1);
              busSelects.add(DomainObject.SELECT_ID);
              StringList relSelects = new StringList(1);

              //to store the object ids which are already connected
              Vector alreadyRelatedProjects = new Vector();

              MapList mapSkills = new DomainObject(parentProjects[i]).getRelatedObjects(context, relatedProjectRelationship, "*", busSelects, relSelects, false, true, (short)1, "", "");

              if ( mapSkills!=null && mapSkills.size() > 0 )
              {
                    alreadyRelatedProjects = new Vector(mapSkills.size());
                    for ( int j = 0; j<mapSkills.size();j++ )
                    {
                        alreadyRelatedProjects.add((String)(((Map)mapSkills.get(j)).get("id")));
                    }
              }

              for (int j=0;j<templateIds.length;j++) {
                    if(!alreadyRelatedProjects.contains(templateIds[j])) {
                        try{
                        DomainRelationship.connect(context, parentProjects[i], relatedProjectRelationship, templateIds[j], false);
                        }catch(Exception e){
                            String strLanguage=context.getSession().getLanguage();
                            String sErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
                      			  "emxProgramCentral.RelatedProject.DoNotSelectCompleteAndArchiveProject", strLanguage);
                            MqlUtil.mqlCommand(context, "Error $1",sErrMsg); //PRG:RG6:R213:Mql Injection:Static Mql:20-Oct-2011
                        }
                    }
              }
              // End of the code: Added by Pavan on 28-Feb-2006 to ensure already related projects are not connected and eliminate the Transaction exception seen on the browser
       }
    }

    //Change Discipline if Change Project
	if(isECHInstalled){
		if(wizType.equalsIgnoreCase("Blank") || wizType.equalsIgnoreCase("Clone") || wizType.equalsIgnoreCase("Template")){
			if(project.isKindOf(context, PropertyUtil.getSchemaProperty(context,"type_ChangeProject"))){
		    	String projectId = project.getInfo(context, DomainConstants.SELECT_ID);

		    	if(projectId!=null && !projectId.equalsIgnoreCase("")){
		    		//Check if an the change discipline interface has been already connected

		    		//add interface attribute for Change Discipline
		    		String strInterfaceName = PropertyUtil.getSchemaProperty(context,"interface_ChangeDiscipline");

		    		//Check if an the change discipline interface has been already connected
		    		//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
		            String sCommandStatement = "print bus $1 select $2 dump";
		            String sCommandResult =  MqlUtil.mqlCommand(context, sCommandStatement,projectId, "interface["+ strInterfaceName + "]"); 
		            //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End

		    		//If no interface --> add one
		    		  if("false".equalsIgnoreCase(sCommandResult)){
		    			//PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:start
	                    String strAddInterface = "modify bus $1 add interface $2";
	                    MqlUtil.mqlCommand(context, strAddInterface,projectId, strInterfaceName); 
	                    //PRG:RG6:R213:Mql Injection:parameterized Mql:20-Oct-2011:End
		    		}

		            BusinessInterface busInterface = new BusinessInterface(strInterfaceName, context.getVault());
		            AttributeTypeList listInterfaceAttributes = busInterface.getAttributeTypes(context);

		            java.util.Iterator listInterfaceAttributesItr = listInterfaceAttributes.iterator();
		            while(listInterfaceAttributesItr.hasNext()){
		          	  String attrName = ((AttributeType) listInterfaceAttributesItr.next()).getName();
		          	  String attrNameSmall = attrName.replaceAll(" ", "");
		          	  String attrNameSmallHidden = attrNameSmall + "Hidden";
		          	  String attrNameValue = emxGetParameter(request,attrNameSmallHidden);
		          	  if(attrNameValue!=null && !attrNameValue.isEmpty()){
		          		  project.setAttributeValue(context, attrName, attrNameValue);
		          	  }
		            }
		    	}
		    }
		}
	}//End of Change Discipline if Change Project

    //Business Unit Add

    if(BusinessUnitId !=null && !"".equals(BusinessUnitId) && !"null".equals(BusinessUnitId)){
      project.setBusinessUnit(context, BusinessUnitId);
    }

    //business Goal add
    //Modified:NZF:10-May-2011:IR-060256V6R2012x
    if(null != businessGoalId && !"".equals(businessGoalId) && !businessGoalId.contains(",")){
      businessGoal.setId(businessGoalId);
      String[] projectIds = new String[1];
      projectIds[0] = project.getInfo(context, project.SELECT_ID);
      businessGoal.addProjects(context, projectIds);
    }else{
    	StringList slBusinessGoalIds = FrameworkUtil.splitString(businessGoalId,",");
    	for(int i=0;i<slBusinessGoalIds.size();i++){
    	    businessGoal.setId(slBusinessGoalIds.get(i).toString());
    	    String[] projectIds = new String[1];
    	    projectIds[0] = project.getInfo(context, project.SELECT_ID);
    	    businessGoal.addProjects(context, projectIds);
    	}
    }
    //End:NZF:10-May-2011:IR-060256V6R2012x
    HashMap map = new HashMap();
    //String strLanguage = context.getLocale().getLanguage();
    //Added:MS9:7-July-2011: IR-117652V6R2012x / IR-089422V6R2012x / IR-098166V6R2012x
    //Added:MS9:3-Aug-2011: IR-123699V6R2012x
    if(ProgramCentralUtil.isNotNullString(parentProjectId)){
        project.setId(parentProjectId);
        String strEffortSubmission = EnoviaResourceBundle.getProperty(context, "emxProgramCentral.WeeklyTimesheet.EffortSubmissionByType");
        if(project.isKindOf(context,DomainConstants.TYPE_PROJECT_SPACE)){
            map.put(ProgramCentralConstants.ATTRIBUTE_EFFORT_SUBMISSION, strEffortSubmission);
        }
    }//End:MS9:3-Aug-2011: IR-123699V6R2012x
    //End:MS9:7-July-2011: IR-117652V6R2012x / IR-089422V6R2012x / IR-098166V6R2012x
    if (projectDate != null && ! "".equals(projectDate)) {
        //Added:18-Feb-10:vm3:R209:PRG:Bug 030676
        map.put(project.ATTRIBUTE_TASK_ESTIMATED_START_DATE, projectDate);
        map.put(project.ATTRIBUTE_TASK_ESTIMATED_FINISH_DATE, projectDate);
        //End-Added:18-Feb-10:vm3:R209:PRG:Bug 030676
    }

    if (projectDuration != null && ! projectDuration.equals("")) {
      map.put(project.ATTRIBUTE_TASK_ESTIMATED_DURATION, projectDuration);
    }
    if (projectVisibility != null && !"".equals(projectVisibility) && !"null".equals(projectVisibility)) {
      map.put(project.ATTRIBUTE_PROJECT_VISIBILITY, projectVisibility);
    }
    if(ProgramCentralUtil.isNotNullString(baseCurrency)){
    	map.put(project.ATTRIBUTE_CURRENCY, baseCurrency);
    }
    //Start Reverse calendaring
    if (projectScheduleFrom != null && !"".equals(projectScheduleFrom) && !"null".equals(projectScheduleFrom)) {
        map.put(PropertyUtil.getSchemaProperty(context,"attribute_ScheduleFrom"), projectScheduleFrom);
      }
    //End Reverse calendaring
    if(defaultStore != null && !"".equals(defaultStore)) {
     map.put(DomainConstants.ATTRIBUTE_FILE_STORE_SYMBOLIC_NAME, defaultStore);
    }
    if(!wizType.equals("AddExistingRelProject") && !wizType.equals("AddExistingSubtaskProject")){
    	
    	if(addAsRelatedProject)
    	{
    		project.setId(relatedProjectId);
    	}

        project.setAttributeValues(context, map);
        // get the bus id of the newly created project
        newbusId = project.getId();
        project.clear();
        project.setId(newbusId);
        if( busId == null || busId.equals("null") || busId.equals("")) {
         if (projectDescription != null && ! projectDescription.equals("") && !"null".equals(projectDescription)) {
        	 projectDescription = projectDescription.replace("&lt;","<");
		 projectDescription = projectDescription.replace("&gt;",">");
                 project.setDescription(context, projectDescription);
         }
         if (programId != null && ! programId.equals("")  && ! programId.equals("null")) {
           project.setProgram(context, programId);
         }
        }
        if(attrMapList != null) {
          HashMap processMap = new HashMap();
          Iterator attrMapListItr = attrMapList.iterator();
          String attrName = "";
          String attrType = "";
          String attrValue ="";
          while(attrMapListItr.hasNext())
          {
            Map item = (Map) attrMapListItr.next();
            attrName = (String) item.get("NAME");
            attrType = (String) item.get("TYPE");
            attrValue = emxGetParameter(request, attrName);
            if (attrValue != null) {
              //websphere's calendar issue with spaces
              if(attrType.equals("timestamp"))  {
                attrName = attrName.replace('~',' ');
                if(attrValue != null && !"null".equals(attrValue) && !"".equals(attrValue)){
                  attrValue = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,attrValue, clientTZOffset,request.getLocale());
                }
              }
              processMap.put(attrName, attrValue);
            }
          }
//added newly
if(isEPMInstalled)
  {
          if(icProjURL !=null && !"null".equals(icProjURL))
          {
              processMap.put(DomainConstants.ATTRIBUTE_IC_PROJECT_URL, icProjURL);
          }
  }
//end
        //Added:05-03-10:nr2:PRG:IR-030432V6R2011 &  IR-032717V6R2011
        //Desc:While creating project from existing project the constraint date of source project
        //was getting copied in the target project. This was causing the issue.
        String projectConstraintDateStr =  project.getInfo(context,"attribute[" + DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_DATE + "]");
        Enumeration e = emxGetParameterNames(request);
        String defaultTaskConstraintType = emxGetParameter(request,"Default Constraint Type");
        if(null != projectConstraintDateStr && !"".equals(projectConstraintDateStr)){
            processMap.put(DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_DATE,"");
        }

        MapList ml = null;
        String ATTRIBUTE_TASK_CONSTRAINT_DAT = "attribute[" + DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_DATE +"]";
        String ATTRIBUTE_TASK_CONSTRAINT_TYP = "attribute[" + DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE +"]";
        String TASK_ASAP = DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE_RANGE_ASAP;
        String TASK_ALAP = DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE_RANGE_ALAP;
        StringList slSelectList = new StringList(2);
        slSelectList.add(DomainConstants.SELECT_ID);
        slSelectList.add(ATTRIBUTE_TASK_CONSTRAINT_DAT);
        slSelectList.add(ATTRIBUTE_TASK_CONSTRAINT_TYP);
        ml  = project.getTasks(context,0,slSelectList,new StringList(),false);
        if(null != ml){
            ListIterator iter = ml.listIterator();
            while(iter.hasNext()){
                Map m = (Hashtable)iter.next();
                String taskId = (String)m.get(DomainConstants.SELECT_ID);
                if(null != taskId && !"".equals(taskId)){
                       task.setId(taskId);
                }
                String strConstDate = task.getAttributeValue(context,ATTRIBUTE_TASK_CONSTRAINT_DAT);
                String strConstType = task.getAttributeValue(context,ATTRIBUTE_TASK_CONSTRAINT_TYP);
                task.setAttributeValue(context,DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_DATE,projectDate);
                if(null != defaultTaskConstraintType){
                       if(TASK_ALAP.equals(defaultTaskConstraintType)){
                               task.setAttributeValue(context,DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE,TASK_ALAP);
                       }
                       else{
                               task.setAttributeValue(context,DomainConstants.ATTRIBUTE_TASK_CONSTRAINT_TYPE,TASK_ASAP);
                       }
                }//End if
           }//End while
        }//End if
        //End Code Addition Here.
        //End:05-02-10:nr2:PRG:IR-030432V6R2011
         project.setAttributeValues(context, processMap);
        }
     // To update the dates with the latest
        if (!error && projectDate != null && ! "".equals(projectDate)) {
          if(!wizType.equals("AddExistingRelProject") && !wizType.equals("AddExistingSubtaskProject")){

              task.clear();
              task.setId(project.getId());
              long startMil = Date.parse(projectDate);
              Date startDate = new Date(startMil);
              task.importStartDate(context, startDate);
          }
        }
     //Modified:09-Mar-2011:nzf/MS9:R211 PRG:IR-074222
     //The below code needs an additional check before getting executed and that is if the new project has any phases connected to it or not.
     //If the user creates the project from Template and prevents phases from being carried forward then this code should not be executed as FTE are connected to phases.
     MapList mlPhasesToNewProject = ResourcePlanTemplate.getPhasesForResourceRequestView(context, DomainObject.newInstance(context,project.getObjectId()), new StringList());
     if(mlPhasesToNewProject.size()!=0){
         if(null!=resourceRequest && !"".equalsIgnoreCase(resourceRequest) && !"Null".equalsIgnoreCase(resourceRequest))
         {
        	   ResourcePlanTemplate resourcePlanTemplate = new ResourcePlanTemplate();
        	   resourcePlanTemplate.createResourcePlan(context,project.getObjectId(),resourceRequest);
         }
     }
     //End:Modified:09-Mar-2011:nzf/MS9:R211 PRG:IR-074222
         
    } // end
    context.commit();
  //Modified:16-Nov-2010:s4e:R210 PRG:IR-073843V6R2012
  //While "Copy WBS to selected Task" wizType is "Clone" , but project is Task id , so Financials.cloneStructure() should not be executed
  //for Tasks.
    if(wizType.equals("Template") || wizType.equals("Clone")){
    if((project.isKindOf(context,DomainConstants.TYPE_PROJECT_SPACE)||project.isKindOf(context,DomainConstants.TYPE_PROJECT_TEMPLATE))
    		&& ("false".equals(cloneOnlyWBS))){
    //Added by ixe for cloning budget when copy project or create project from template is done
    DomainObject dmoSourceProject = new DomainObject(templateId);
    Financials.cloneStructure(context,
    		   dmoSourceProject,
                   project);
    }
    }
    //End:Modified:16-Nov-2010:s4e:R210 PRG:IR-073843V6R2012
  } catch (Exception e) {
    error = true;
    context.abort();
    session.setAttribute("error.message", e.getMessage());
  }

  StringBuffer treeUrl = new StringBuffer(UINavigatorUtil.getCommonDirectory(context)+
                  "/emxTree.jsp?AppendParameters=true"+
                  "&treeNodeKey=node.ProjectSpace&suiteKey=eServiceSuiteProgramCentral&objectId="+
                  //newbusId + "&DefaultCategory=PMCProjectSpaceProperties" +
                  newbusId + "&DefaultCategory=PMCGateDashboardCommandPowerView" + //Added:nr2:PRG:R210:For project Gate highlight
                  "&emxSuiteDirectory="+appDirectory +
                  "&treeTypeKey=type.Project");
%>
<%@include file = "../emxMQLNotice.inc"%>

<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="java.util.ListIterator"%>
<%@page import="com.matrixone.apps.program.Task"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.program.ResourcePlanTemplate"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@page import="java.util.Enumeration"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><html>
  <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    var contentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
<%
if(!alreadyExistingProjectNames.isEmpty()) {
        %>
        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.AddingAlreadyAddedProject</framework:i18nScript>\n<%=alreadyExistingProjectNames%>");
        <%
    
    }  
    if(error) {
        String sErrorMessage = (String)session.getAttribute("error.message");
        if(sErrorMessage != null && !"".equals(sErrorMessage) )
        {
          session.removeAttribute("error.message");
          sErrorMessage = sErrorMessage.trim();
%>
          alert("<%=sErrorMessage.replaceAll("\n","\\\\n")%>");
<%
        }
%>
        getTopWindow().window.close();
<%
    }
	if("Manual".equalsIgnoreCase(projectSchedule))
{
	%> 
	
	 var topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "<%=currentFrame%>");
	 if(topFrame == null){
		 topFrame = findFrame(getTopWindow().window.getWindowOpener().parent, "PMCWhatIfExperimentStructure");
		 if(topFrame==null){
			 topFrame = findFrame(getTopWindow().window.getWindowOpener().parent, "PMCWBS");
			 if(topFrame==null){
				 topFrame = findFrame(getTopWindow().window.getWindowOpener().parent, "detailsDisplay");
			 if(topFrame==null){
					topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "PMCWhatIfExperimentStructure");
					 if(topFrame==null){
							topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "PMCWBS");
				 if(topFrame==null){
				 topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
				}
			 }
		 }
			 }
			 }
	 }
	
	 topFrame.emxEditableTable.addToSelected('<%=sBuff.toString()%>');
  	top.jQuery('button.refresh', '.field.button').toggleClass('refresh').toggleClass('refresh-with-cache');
		toggleRollupIcon(topFrame,"iconActionUpdateDates","iconActionUpdateDatesActive");
		<%if(!ProgramCentralUtil.is3DSearchEnabled(context)){
			 %> 
			 getTopWindow().window.close();
			<%
			 }
		
}
    else
    {
      if(!importIntoExistingProj){       
        if(null!=sBuff){        	
%>        	
	        if(!contentFrame && getTopWindow().getWindowOpener().parent.getWindowOpener().parent){
				getTopWindow().getWindowOpener().parent.getWindowOpener().parent.emxEditableTable.addToSelected('<%=sBuff.toString()%>');
				getTopWindow().getWindowOpener().parent.getWindowOpener().parent.emxEditableTable.refreshStructure();
			}
<% 
        }
    }
    //if from action menu
    if(null != fromAction && !"".equals(fromAction) && "true".equals(fromAction))
    {
%>
         contentFrame.document.location.href = "<%= treeUrl %>";
<%    //else done clicked
    } else if (importIntoExistingProj){
%>
		var refreshURL = parent.window.opener.parent.document.location.href;
		refreshURL = refreshURL.replace("persist=true","");
		parent.window.opener.parent.document.location.href=refreshURL; 
         getTopWindow().window.close();
<%
    } else {
           if(bFromProgram || "true".equals(fromBG)){
              //need to point to the Properties Detail page
              newbusId += "&DefaultCategory=PMCProjectSpaceProperties";
%>
parent.window.getWindowOpener().document.location.href = parent.window.getWindowOpener().document.location.href;
getTopWindow().window.close();
<%
           }
           else if (!addAsRelatedProject && portalMode != null && (portalMode.equals("true"))){
%>
 <%
 //Added to refresh WBS struture after adding project above the task...
 if( ProgramCentralConstants.INSERT_EXISTING_PROJECT_ABOVE.equalsIgnoreCase(insertExistingProjectAboveMode)||ProgramCentralConstants.INSERT_EXISTING_PROJECT_BELOW.equalsIgnoreCase(insertExistingProjectBelowMode)){
 %>
 var topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "<%=currentFrame%>");
 if(topFrame == null){
	 topFrame = findFrame(getTopWindow().window.getWindowOpener().parent, "PMCWhatIfExperimentStructure");
	 if(topFrame==null){
		 topFrame = findFrame(getTopWindow().window.getWindowOpener().parent, "detailsDisplay");
		 if(topFrame==null){
				topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "PMCWhatIfExperimentStructure");
			 if(topFrame==null){
			 topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
			}
		 }
	 }
 }	
 
 var refreshURL =  topFrame.location.href;
 refreshURL = refreshURL.replace("persist=true","");
 topFrame.location.href=refreshURL; 
  <%
 if(!ProgramCentralUtil.is3DSearchEnabled(context)){
 %> 
// window.parent.getTopWindow().getWindowOpener().parent.location = window.parent.getTopWindow().getWindowOpener().parent.location.href;
 getTopWindow().window.close();
 
<%
 }
 }
%> 
            parent.window.getWindowOpener().document.location.href = parent.window.getWindowOpener().document.location.href;
<%
           } else if (addAsRelatedProject){
              	if(!ProgramCentralUtil.is3DSearchEnabled(context)){
              	%>
              	  var topFrame = findFrame(getTopWindow().opener.getTopWindow(), "PMCRelatedProjects");
              	  topFrame.location.href=topFrame.location.href;
             	  getTopWindow().window.close();
              	<%}else{%>
              	  var topFrame = findFrame(getTopWindow(), "PMCRelatedProjects");
              	  topFrame.location.href=topFrame.location.href; 
            	<%}
             }

// Master Project Schedule
else if (addAsSubProject) {
    if ("Child".equals(addType) && sBuff != null) {
%>
        // Start WBS AddProcess with SB Add/Remove Feture Implementation

        // Modified for bug 358843
        // Now after this fix, for the opened dialog the getWindowOpener() is no longer indented table directly,
        // now getWindowOpener() is hiddenprocess page inside listHidden frame, so to navigate to indented page we shall check getWindowOpener().parent

        parent.window.getWindowOpener().parent.emxEditableTable.addToSelected('<%=sBuff.toString()%>');
        parent.window.getWindowOpener().parent.emxEditableTable.refreshStructure();
        // End WBS AddProcess with SB Add/Remove Feture Implementation
<%
    } else {
%>
        // Refresh the Related Projects summary page only..
        // Modified for bug 358843
        // Now after this fix, for the opened dialog the getWindowOpener() is no longer indented table directly,
        // now getWindowOpener() is hiddenprocess page inside listHidden frame, so to navigate to indented page we shall check getWindowOpener().parent
        parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;

<%
    }
// End - Master Project Schedule

             } else if(!"AddExistingRelProject".equals(wizType) && !"AddExistingSubtaskProject".equals(wizType)){
%>
                 //parent.window.getWindowOpener().parent.document.location.href = "<!%= treeUrl %>";
                   var parentContentDetailsFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
                  parentContentDetailsFrame.document.location.href = "<%= treeUrl %>";

<%
           }
%>
<%
           }
         }
  } catch (Exception e) {
      error = true;
      context.abort();
      session.setAttribute("error.message", e.getMessage());
  }
if("true".equals(pClose)) {
%>
    parent.window.getWindowOpener().getTopWindow().close();
<%
  }
%>
<%
	if(!ProgramCentralUtil.is3DSearchEnabled(context)){
	%>
    parent.window.close();
	<%}%>
    // Stop hiding here -->//]]>
  </script>
</html>
