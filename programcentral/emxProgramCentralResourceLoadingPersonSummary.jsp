<%-- emxProgramCentralResourceLoadingPersonSummary.jsp

  Displays a window for creating a Calendar event.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralResourceLoadingPersonSummary.jsp.rca 1.15 Tue Oct 28 18:55:11 2008 przemek Experimental przemek $";

--%>

<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@ page import="java.util.Calendar" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.common.Task"%>

<%
    boolean toExcel = false;
    String outputAsSpreadsheet = emxGetParameter(request, "outputAsSpreadsheet");
    if ("true".equals(outputAsSpreadsheet)){
    toExcel = true;
    }
    String filter_passed_param = emxGetParameter(request, "mx.page.filter");
    filter_passed_param = XSSUtil.encodeURLForServer(context, filter_passed_param);
    boolean isPrinterFriendly = false;
    String printerFriendly = emxGetParameter(request, "PrinterFriendly");

    if (printerFriendly != null && "true".equals(printerFriendly)) {
       isPrinterFriendly = true;
    }
    
    ResourceLoading personBean = new ResourceLoading (context);
%>


<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><jsp:useBean id="calendar_bean" scope="page" class="com.matrixone.apps.common.WorkCalendar"/>

<%--jsp:useBean id="personBean" scope="request" class="com.matrixone.apps.program.ResourceLoading"/--%>

<script language="javascript" src="../common/scripts/emxUIConstants.js" />
<script language="javascript" src="../common/scripts/emxUICore.js" />
<script language="javascript" src="../common/scripts/emxUICoreMenu.js" />
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>

<script language="javascript">
addStyleSheet('emxUICalendar');
</script>
<script type="text/javascript">
addStyleSheet("emxUIDefault");
</script>
<script>
addStyleSheet("emxUIList");
</script>
<script>
addStyleSheet("emxUIMenu");
</script>
<script language="javascript">

function callTree(url)
{
	showModalDialog(url,750,580);
}

function newReport()
{

  var newPage="../programcentral/emxProgramCentralResourceDialogFS.jsp";
  var filterSelected = '<%=filter_passed_param%>';
  newPage += "?type=summary&optionSelected="+filterSelected;
  //Added:30-Sep-2010:vf2:R2012
  var frameobj = findFrame(getTopWindow(), 'pagecontent');
  var tableId = frameobj.document.forms[0].tablerowids.value;
  //var tableId = getTopWindow().frames[1].document.forms[0].tablerowids.value;
  //End:30-Sep-2010:vf2:R2012
  if (tableId!=null && tableId.length > 0 ){
    newPage += "&emxTableRowId=" + tableId;
  }
  <%-- XSSOK --%> var date_start = '<%=emxGetParameter(request,"sDate")%>';
  if (date_start!=null && date_start.length > 0 ){
    newPage += "&start=" + date_start;
  }

  <%-- XSSOK --%> var date_end = '<%=emxGetParameter(request,"eDate")%>';
  if (date_end!=null && date_end.length > 0 ){
    newPage += "&end=" + date_end;
  }

  <%-- XSSOK --%> var date_start_msvalue = '<%=XSSUtil.encodeURLForServer(context, emxGetParameter(request,"start_msvalue"))%>';
  
    if (date_start_msvalue!=null ){
      newPage += "&start_msvalue=" + date_start_msvalue;
    }

    <%-- XSSOK --%> var date_end_msvalue = '<%=XSSUtil.encodeURLForServer(context, emxGetParameter(request,"end_msvalue"))%>';
    
    if (date_end_msvalue!=null ){
      newPage += "&end_msvalue=" + date_end_msvalue;
  }


  parent.document.location.href = newPage;
  return;
  //window.open(url,'','height=580,width=750,status=no,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes');
}

</script>
<%

//TODO...move all of the common functions to an include file.
//Review the String resource keys to make all are coming from a properties file...some are hardcoded for now....
//REMOVE COMMENTED CODE

com.matrixone.apps.common.Person person = null;
String emxTableRowId   = emxGetParameter(request, "emxTableRowId");
String objectId   = emxGetParameter(request, "objectId");
String prop = EnoviaResourceBundle.getProperty(context, "eServiceProgramCentral.ResourceLoading.Default");


String d_fault = "yearly";
String d_start = "";
String d_end = "";
String hidden_start = "";
String hidden_end = "";
Date bDate = new Date();
Date lDate = DateUtil.computeFinishDate(bDate,1,0);
Date dt_Start = new Date();
Date dt_End = new Date();


String date_range = emxGetParameter(request, "date_range");
if(date_range!=null && date_range.trim().length()>0)
{
  StringTokenizer sdate_range = new StringTokenizer(date_range,"|",false);
  while(sdate_range.hasMoreTokens())
  {
    d_start= sdate_range.nextToken();
    d_end = sdate_range.nextToken();
    hidden_start=d_start;
    hidden_end = d_end;

    /*double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
    if(d_start != null && d_end !=null){

      // d_start = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,d_start, clientTZOffset,request.getLocale());
      // d_end = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,d_end, clientTZOffset,request.getLocale());

    }*/

  }

}

if(d_start!=null && d_start.length() > 0 && d_end != null && d_end.length() > 0)
{

  dt_Start = new Date(d_start);
  dt_End = new Date(d_end);

}

String language = request.getHeader("Accept-Language");
String yellow_threshold = EnoviaResourceBundle.getProperty(context, "eServiceProgramCentral.ResourceLoading.YellowThreshold");
String red_threshold = EnoviaResourceBundle.getProperty(context, "eServiceProgramCentral.ResourceLoading.RedThreshold");

Date dsAdjusted = dt_Start;
Date deAdjusted = dt_End;
String selected="";
ArrayList al = new ArrayList();
if(filter_passed_param !=null && filter_passed_param.equalsIgnoreCase("Monthly"))
{
  dsAdjusted = personBean.adjustStartDate(dt_Start);
  deAdjusted = personBean.adjustEndDate(dt_End);
  al = personBean.getMonthRanges(dsAdjusted,deAdjusted);
  selected="m";
}
else if (filter_passed_param !=null && filter_passed_param.equalsIgnoreCase("Quarterly"))
{
  dsAdjusted = personBean.adjustQuarterlyStartDate(dt_Start);
  deAdjusted = personBean.adjustQuarterlyEndDate(dt_End);

  al = personBean.getQuarterlyData(dsAdjusted,deAdjusted);
  selected="q";
}
else if (filter_passed_param !=null && filter_passed_param.equalsIgnoreCase("Weekly"))
{
  dsAdjusted = personBean.adjustWeeklyStartDate(dt_Start);
  deAdjusted = personBean.adjustWeeklyEndDate(dt_End);
  al = personBean.getWeeklyData(dsAdjusted,deAdjusted);
  selected="w";
}else{

  //if none selected, then select the default set in the properties file.
  if(prop!=null && prop.equalsIgnoreCase("monthly"))
  {
    dsAdjusted = personBean.adjustStartDate(dt_Start);
    deAdjusted = personBean.adjustEndDate(dt_End);
    al = personBean.getMonthRanges(dsAdjusted,deAdjusted);
    selected="m";

  }else if (prop!=null && prop.equalsIgnoreCase("weekly"))
  {
    dsAdjusted = personBean.adjustWeeklyStartDate(dt_Start);
    deAdjusted = personBean.adjustWeeklyEndDate(dt_End);
    al = personBean.getWeeklyData(dsAdjusted,deAdjusted);
    selected="w";
  }
  else if (prop!=null && prop.equalsIgnoreCase("quarterly"))
  {
    dsAdjusted = personBean.adjustQuarterlyStartDate(dt_Start);
    deAdjusted = personBean.adjustQuarterlyEndDate(dt_End);
    al = personBean.getQuarterlyData(dsAdjusted,deAdjusted);
    selected="q";
  }
}

hidden_start =  personBean.mxFormatDate(dsAdjusted);
hidden_end =  personBean.mxFormatDate(deAdjusted);

Date startDate = new Date(hidden_start);
java.text.SimpleDateFormat sdf3 = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
String start_date = sdf3.format(startDate);
Date endDate = new Date(hidden_end);
String end_date = sdf3.format(endDate);

String hiddenParams = "";
double iTimeZoneDbl= (new Double((String)session.getValue("timeZone"))).doubleValue();

StringBuffer exportStringBuffer = new StringBuffer();
String strDelimiter = ",";
exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
		  "emxProgramCentral.Common.ResourceLoading.ReportPeriod", language) + strDelimiter);
exportStringBuffer.append("\n");
exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
		  "emxProgramCentral.Common.ResourceLoading.From", language) + strDelimiter);
exportStringBuffer.append(start_date + strDelimiter);
exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
		  "emxProgramCentral.Common.ResourceLoading.To", language) + strDelimiter);
exportStringBuffer.append(end_date + strDelimiter);
exportStringBuffer.append("\n");
exportStringBuffer.append("Person" + strDelimiter);
exportStringBuffer.append("Project" + strDelimiter);
exportStringBuffer.append("WBS Task" + strDelimiter);

%>
<%--xssok --%>  <framework:ifExpr expr="<%=toExcel == false%>">
<table border="0" width="100%" align="center">
  <tr>
    <td colspan="2" bgcolor="#eeeeee"><b><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.ReportPeriod</emxUtil:i18n></b></td>
  </tr><tr>
    <td colspan="1">
      <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.From</emxUtil:i18n> &nbsp;
      <framework:lzDate localize='i18nId' tz='<%= timeZone %>' format='<%= dateFormat %>' displaydate='true'>
      <%=start_date%>
      </framework:lzDate>
    </td>
    <td colspan="1">
      <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.To </emxUtil:i18n>&nbsp;
      <framework:lzDate localize='i18nId' tz='<%= timeZone %>' format='<%= dateFormat %>' displaydate='true'>
      <%=end_date%>
      </framework:lzDate>
    </td>
 </tr>

</table><hr noshade>
</framework:ifExpr>
<%
    if(al != null && al.size() > 0 )
    {

%>
<framework:ifExpr expr="<%=toExcel == false%>">
      <table border="0" width="100%">
        <tr>
          <th><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.Person</emxUtil:i18n></th>
          <th><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.Project</emxUtil:i18n></th>
          <th><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.WBSTask</emxUtil:i18n></th>
</framework:ifExpr>
          <%if(selected=="m")
            {
              for (int i=0; i<al.size(); i++) {
                Date stdate = (Date)al.get(i);
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
                String aDate = sdf.format(stdate);
                String week_date = personBean.formatMonthly(eMatrixDateFormat.getFormattedDisplayDate(aDate,iTimeZoneDbl),request.getLocale());
                if(toExcel)
                {
                    exportStringBuffer.append(week_date + strDelimiter);
                }
%>
                <framework:ifExpr expr="<%=toExcel == false%>">
                    <th><%=week_date%></th>
                </framework:ifExpr><%}
            }
            else if (selected=="w")
            {

              for (int i=0; i<al.size(); i++) {
                Date stdate = (Date)al.get(i);
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
                String aDate = sdf.format(stdate);
                String week_date = eMatrixDateFormat.getFormattedDisplayDate(aDate,iTimeZoneDbl);
                if(toExcel)
                {
                    week_date = week_date.replace(',',' ');
                    exportStringBuffer.append(week_date + strDelimiter);
                }
%>
                <framework:ifExpr expr="<%=toExcel == false%>">
                    <th><framework:lzDate localize='i18nId' tz='<%= timeZone %>' format='<%= dateFormat %>' displaydate='true'>
                        <%=aDate%>
                        </framework:lzDate>
                    </th></framework:ifExpr><%}


            }
            else if(selected=="q")
            {

              for (int i=0; i<al.size(); i++) {
                Date qdate = (Date)al.get(i);
                Date qdate_next;

                if(i==al.size()-1)
                {
                  qdate_next =  deAdjusted; //(Date)al.get(al.size()-1);
                }else
                {
                  qdate_next = (Date)al.get(i + 1);
                }

                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
                String qDate = sdf.format(qdate);

                String quarter_date = personBean.formatMonthly(eMatrixDateFormat.getFormattedDisplayDate(qDate,iTimeZoneDbl),request.getLocale());
                Date formatQuarter =(Date) personBean.getQuarterEndDate(qdate_next);
                String qDate_next = sdf.format(formatQuarter);
                String quarter_Next = personBean.formatMonthly(eMatrixDateFormat.getFormattedDisplayDate(qDate_next,iTimeZoneDbl),request.getLocale());
                if(toExcel)
                {
                    exportStringBuffer.append(quarter_date + " - " + quarter_Next + strDelimiter);
                }
%>
                <framework:ifExpr expr="<%=toExcel == false%>">
                    <th><%=quarter_date%> - <%=quarter_Next%></th>
                </framework:ifExpr>
       <%}


            }
            if(toExcel)
            {
                exportStringBuffer.append("\n");
            }

            String sRel = "";
            String sBus = "";


            StringTokenizer tokenizer = new StringTokenizer(emxTableRowId,",",false);
            int tokens = tokenizer.countTokens();
            MapList topMap = new MapList();
            String full_userName="";
            //MapList myProj = new MapList();
            com.matrixone.apps.program.ProjectSpace projectSpace = (com.matrixone.apps.program.ProjectSpace) DomainObject.newInstance(context, DomainConstants.TYPE_PROJECT_SPACE, DomainConstants.PROGRAM);
            com.matrixone.apps.program.Task task =(com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
            String taskId = "";
            
            for(int k=0;k<tokens;k++)
            {
              full_userName = "";
              String itemId = tokenizer.nextToken();

              if(k==tokens-1)
                hiddenParams += itemId;
              else
                hiddenParams += itemId + ",";

              StringTokenizer stok=null;
              if(itemId!=null && itemId.indexOf("|") > 0)
              {
                stok = new StringTokenizer(itemId,"|",false);
                while(stok.hasMoreTokens())
                {
                  sRel = stok.nextToken();
                  sBus = stok.nextToken();
                }
              }else{

                sBus = itemId;

              }

              DomainObject objPerson = new DomainObject(sBus);
              try{
                objPerson.open(context);
              }catch(Exception ex){
                throw ex;
              }
              String userName =objPerson.getName();
              String personId =objPerson.getId();
              person = person.getPerson(context,userName);


              StringList busProjSelects = new StringList(2);
              busProjSelects.add(task.SELECT_ID);
              busProjSelects.add(task.SELECT_NAME);

              //myProj = (MapList) projectSpace.getProjects(context,person,busProjSelects,null,null,null);


              String fName = person.getAttributeValue(context,"First Name");
              String lName = person.getAttributeValue(context,"Last Name");


              full_userName = lName + ", " + fName;
              StringList busSelects = new StringList(7);
              busSelects.add(task.SELECT_ID);
              busSelects.add(task.SELECT_NAME);
              busSelects.add(task.SELECT_CURRENT);
              busSelects.add(task.SELECT_PERCENT_COMPLETE);
              busSelects.add(task.SELECT_TASK_ESTIMATED_START_DATE);
              busSelects.add(task.SELECT_TASK_ESTIMATED_FINISH_DATE);
              busSelects.add(task.SELECT_TASK_ACTUAL_FINISH_DATE);
              busSelects.add(task.SELECT_TASK_ESTIMATED_DURATION);

              String busWhere = " current!='Complete'";
            //Added:nr2:PRG:R210:27-Aug 2010:IR-057835V6R2011x
                busWhere += " && relationship[" + DomainConstants.RELATIONSHIP_PROJECT_ACCESS_KEY + "].from.relationship[" + DomainConstants.RELATIONSHIP_PROJECT_ACCESS_LIST + "].to.current!='" + ProgramCentralConstants.STATE_PROJECT_SPACE_HOLD_CANCEL_HOLD + "'";
                busWhere += " && relationship[" + DomainConstants.RELATIONSHIP_PROJECT_ACCESS_KEY + "].from.relationship[" + DomainConstants.RELATIONSHIP_PROJECT_ACCESS_LIST + "].to.current!='" + ProgramCentralConstants.STATE_PROJECT_SPACE_HOLD_CANCEL_CANCEL + "'";
            //End:nr2:PRG:R210:27-Aug 2010:IR-057835V6R2011x
            
              //Hide experiment project and task from resource loading report:start
                StringList subTypeList = ProgramCentralUtil.getSubTypesList(context,ProgramCentralConstants.TYPE_EXPERIMENT);
                if(subTypeList !=null && subTypeList.size()>0){
              	  for(int i=0;i< subTypeList.size();i++){
              		  String strType =(String)subTypeList.get(i);
              		  busWhere += " && "+ProgramCentralConstants.SELECT_PROJECT_TYPE +"!='" + strType + "'";
              	  }
                }
                //Hide experiment project and task from resource loading report:End
             // String taskId = "";
              String sStartdate = DomainObject.EMPTY_STRING;
              String sEndDate = DomainObject.EMPTY_STRING;
              String task_duration = DomainObject.EMPTY_STRING;

              String type_Person=(String)PropertyUtil.getSchemaProperty(context,"type_Person");
              String rel_assigned=(String)PropertyUtil.getSchemaProperty(context,"relationship_AssignedTasks");
              HashMap dataMap = new HashMap();
              HashMap itemData=null;
              Vector vec = null;
              MapList assignmentList = person.getAssignments(context, busSelects, busWhere, false, false);
              String rowValue="";
              String stask_name="";
              int m=0;int n=0;
              vec = new Vector();

              for(int g=0;g<assignmentList.size();g++)
              {
                itemData = new HashMap();
                stask_name="";
                taskId =(String)((Map)assignmentList.get(g)).get("id");
                stask_name = (String)((Map)assignmentList.get(g)).get("name");
                task.setId(taskId);

                String attribute_ProjectVisibility=(String)PropertyUtil.getSchemaProperty(context,"attribute_ProjectVisibility");

                StringList busTaskSelects = new StringList(1);
                busTaskSelects.add(task.SELECT_ID);
                busTaskSelects.addElement("attribute[" + attribute_ProjectVisibility + "]");

                // Do not get the data as super user, user should not see which he does not have access to
                Map listProj = (Map)task.getProject(context,busTaskSelects, false);


                ////Get Project data
                //StringList busProjectSelects = new StringList();
                //busProjectSelects.addElement(DomainObject.SELECT_ID);

                //Map projMap = (Map) task.getProject(context,busProjectSelects);
                
                //Modified:10-Mar-2010:s2e:R209 PRG:IR-034847V6R2011 
                
                boolean checkmembership = false;
                MapList testMap = task.getTasks(context,task, 1, busTaskSelects, new StringList(), false, false);
                MapList ml = (MapList)personBean.getAssigneeInfo(context,taskId, false);
                
                if(listProj != null )
                {
                  String projID = (String)listProj.get(task.SELECT_ID);
                  String projVisibility = (String)listProj.get("attribute[" + attribute_ProjectVisibility + "]");

                //if visibility is set to members and the person is not a member of the project
                //then do not include this task in the report.
                String pid = null;
                Iterator mListItr      = ml.iterator();
                while(mListItr.hasNext()){
                    pid     = (String) ( ( (Map)mListItr.next() ).get(DomainConstants.SELECT_ID) );
                    if(personId.equals(pid) && pid != null && pid.length() != 0){
                        checkmembership = true;
                        break;
                     }
                      else{
                        checkmembership = personBean.isPersonProjectMember(context,projID,personId);
                      }
                    }
                 
              //End:10-Mar-2010:s2e:R209 PRG:IR-034847V6R2011 

                  if(projVisibility != null && projVisibility.trim().length()>0 &&
                    projVisibility.equalsIgnoreCase("Members") && !checkmembership){
                      continue;
                  }
                }
                else
                {
                  continue;
                }


                //check to make sure that the task does not have any children before adding it to
                //the list of tasks
                // Do not get the data as super user, user should not see which he does not have access to
                //MapList testMap = task.getTasks(context,task, 1, busTaskSelects, new StringList(), false, false);
                if(testMap!=null && testMap.size()>0)
                {
                continue;
                }


                String projId = "";
                if(listProj != null )
                {
                  projId = (String)listProj.get(task.SELECT_ID);

                  sStartdate =(String)((Map)assignmentList.get(g)).get(task.SELECT_TASK_ESTIMATED_START_DATE);
                  sEndDate =(String)((Map)assignmentList.get(g)).get(task.SELECT_TASK_ESTIMATED_FINISH_DATE);
                  task_duration =(String)((Map)assignmentList.get(g)).get(task.SELECT_TASK_ESTIMATED_DURATION);
                  // Do not get the data as super user, user should not see which he does not have access to
                  Vector taskVec = personBean.getAllocation(context,taskId,rel_assigned,type_Person,true,false,(short)1, false);

                  // Do not get the data as super user, user should not see which he does not have access to
                 // MapList ml = (MapList)personBean.getAssigneeInfo(context,taskId, false);
                  String totalAssingees = "" + ml.size();


                  String alloc_value = personBean.getAllocValue(taskVec,sBus);
                  String userCalendarId = ResourceLoading.getUserCalendar(context,sBus);
                  ArrayList hmInfo = new ArrayList();
                  if (userCalendarId != null && !"".equals(userCalendarId) && !"null".equals(userCalendarId))
                  {
                    Date sttDate = new Date(sStartdate);
                    Date eddDate = new Date(sEndDate);
                    hmInfo = ResourceLoading.getDaysInRange(context, userCalendarId, sttDate,eddDate,1);
                  }
                  else{
                    hmInfo = ResourceLoading.getDateRangeData(sStartdate,sEndDate,true);
                  }
                  itemData.put("taskid",taskId);
                  itemData.put("taskname",stask_name);
                  itemData.put("projectid",projId);
                  itemData.put("taskDays",hmInfo);
                  itemData.put("duration",task_duration);
                  itemData.put("assignees",totalAssingees);
                  itemData.put("allocation",alloc_value);
                  vec.add(itemData);

                  n++;
                  m=n%2;
                }
              }

              dataMap.put("personid",sBus);
              dataMap.put("fullname",full_userName);
              dataMap.put("data",vec);
              topMap.add(dataMap);
            }


%>

        </tr>
<%
        String rowValue="";
        int m=0;int n=0;
        String proj_id="";
        String pid = "";
        String proj_name="";
        String task_person_name="";
        Vector existing = new Vector();
        boolean stopProcessing=true;
        if(topMap.size()>0)
        {

          for(int j=0;j<topMap.size();j++)
          {
            HashMap top = (HashMap)topMap.get(j);
            Vector vector = (Vector)top.get("data");
            if(vector!=null && vector.size()>0)
            {
              stopProcessing=false;

              for(int i = 0; i<vector.size(); i++)
              {

                HashMap hitem = (HashMap)vector.get(i);
                String task_project = (String)hitem.get("projectid");
                String task_project_name = (String)hitem.get("taskname");
                String task_project_id = (String)hitem.get("taskid");
                pid = (String)top.get("personid");
                DomainObject dom = new DomainObject(task_project);

              //Modified:10-Mar-2010:s2e:R209 PRG:IR-034847V6R2011 
                boolean checkmembership = false;
                MapList ml = (MapList)personBean.getAssigneeInfo(context,taskId, false);
                
                String perid = null;
                Iterator mListItr      = ml.iterator();
                while(mListItr.hasNext()){
                	perid     = (String) ( ( (Map)mListItr.next() ).get(DomainConstants.SELECT_ID) );
                    if(pid.equals(perid) && perid != null && perid.length() != 0){
                        checkmembership = true;
                        break;
                     }
                      else{
                    	  checkmembership = personBean.isPersonProjectMember(context,task_project,pid);
                      }
                    }
                
                
                boolean checkmem = personBean.isPersonProjectMember(context,task_project,pid);
              
                if(toExcel)
                {
                    if(i==0){
                        exportStringBuffer.append((String)top.get("fullname") + strDelimiter);
                    }
                    else{
                        exportStringBuffer.append(" " + strDelimiter);
                    }
                    if(checkmembership){
                        proj_name = dom.getName(context);
                        exportStringBuffer.append(proj_name + strDelimiter);
                    }
                    else{
                        exportStringBuffer.append(" " + strDelimiter);
                    }
                    exportStringBuffer.append(task_project_name + strDelimiter);
                }
                if(checkmembership) {
                  proj_name = dom.getName(context);
                  if(isPrinterFriendly)
                  {
                	  proj_name="<table><tr><td><img src=\"../common/images/iconSmallProject.gif\" border=\"0\">"+XSSUtil.encodeForHTML(context, proj_name)+"</td></tr></table>";
                  }
                  else
                  {
                	  if(checkmem)
                	  {
                		  proj_name="<table><tr><td><img src=\"../common/images/iconSmallProject.gif\" border=\"0\"><a href=\"javascript:callTree('../common/emxTree.jsp?objectId="+XSSUtil.encodeForHTML(context, task_project)+"&emxSuiteDirectory=programcentral')\">"+proj_name+"</a></td></tr></table>";
                	  }
                      else
                	     proj_name="<table><tr><td><img src=\"../common/images/iconSmallProject.gif\" border=\"0\">"+XSSUtil.encodeForHTML(context, proj_name)+"</td></tr></table>";
                	  
                  }
                }
              //End:10-Mar-2010:s2e:R209 PRG:IR-034847V6R2011 
                else{
                  proj_name="<table><tr><td><img src=\"../common/images/iconSmallProject.gif\" border=\"0\" /></td></tr></table>";
                }

                if(isPrinterFriendly)
                {
                	task_project_name="<table><tr><td><img src=\"../common/images/iconSmallTask.gif\" border=\"0\">"+XSSUtil.encodeForHTML(context, task_project_name)+"</td></tr></table>";
                }
                else
                {
                  task_project_name="<table><tr><td><img src=\"../common/images/iconSmallTask.gif\" border=\"0\"><a href=\"javascript:callTree('../common/emxTree.jsp?objectId="+task_project_id+"&emxSuiteDirectory=programcentral')\">"+XSSUtil.encodeForHTML(context, task_project_name)+"</a></td></tr></table>";
                }

                if(i==0)
                {
                  if(isPrinterFriendly)
                  {
                    task_person_name="<table><tr><td><img src=\"../common/images/iconSmallPerson.gif\" border=\"0\">"+XSSUtil.encodeForHTML(context, (String)top.get("fullname"))+"</td></tr></table>";
                  }
                  else
                  {
                    task_person_name="<table><tr><td><img src=\"../common/images/iconSmallPerson.gif\" border=\"0\"><a href=\"javascript:callTree('../common/emxTree.jsp?objectId="+pid+"&emxSuiteDirectory=programcentral')\">"+XSSUtil.encodeForHTML(context, (String)top.get("fullname"))+"</a></td></tr></table>";
                  }
                }
                else
                {
                  task_person_name="";
                }
                rowValue = "#eeeeee";
                if (m == 0) {
                  rowValue="#ffffff";
                }

%>


                <%if(selected.equals("m")){%>
                <framework:ifExpr expr="<%=toExcel == false%>">
   <%-- XSSOK--%> <tr bgcolor="<%=rowValue%>">
   <%-- XSSOK--%>                 <td><%=task_person_name%></td>
   <%-- XSSOK--%>                 <td><%=proj_name%></td>
   <%-- XSSOK--%>                 <td><%=task_project_name%></td>
                </framework:ifExpr>

<%
                    //int month1=month;
                    for(int ta = 0; ta<al.size(); ta++)
                    {

                      Date idate = (Date)al.get(ta);
                      int iMonth = idate.getMonth();
                      //long getnum = getNumworkingDays(idate);
                      long getnum = personBean.getNumworkingDays(context,idate,pid);
                      Date monthItemNext = null;
                      if(ta==al.size()-1)
                      {
                        monthItemNext =  (Date)al.get(al.size()-1);
                      } else
                      {
                        monthItemNext =  (Date)al.get(ta+1);
                      }


                      ArrayList arr = personBean.getworkingDates(context,idate, pid,1);


                      double finalvalue = Task.parseToDouble(personBean.get_t_loading(hitem,getnum,arr));
                      String stReturn = "";

                      if(finalvalue<0.01){
                        stReturn="0.00";
                      }else{
                        stReturn = personBean.resultFormatted(finalvalue);
                      }
                      if(toExcel)
                      {
                        exportStringBuffer.append(stReturn + strDelimiter);
                      }
                      
                	  if(finalvalue >= (Double)Task.parseToDouble(yellow_threshold) && finalvalue < (Double)Task.parseToDouble(red_threshold))
                      {
                        stReturn="<font color=\"orange\">"+XSSUtil.encodeForHTML(context, stReturn)+"</font>";
                      }else if(finalvalue >= (Double)Task.parseToDouble(red_threshold)){
                        stReturn="<font color=\"red\">"+XSSUtil.encodeForHTML(context, stReturn)+"</font>";
                      }

%>
                      <framework:ifExpr expr="<%=toExcel == false%>">
                        <td><%=stReturn%></td>
                      </framework:ifExpr>
<%                  }
                    if(toExcel)
                    {
                        exportStringBuffer.append("\n");
                    }
%>
                  </tr><%

                }else if(selected.equals("q")){
%>
                  <framework:ifExpr expr="<%=toExcel == false%>">
      <%-- XSSOK--%>   <tr bgcolor="<%=rowValue%>">
      <%-- XSSOK--%>                    <td><%=task_person_name%></td>
      <%-- XSSOK--%>                    <td><%=proj_name%></td>
      <%-- XSSOK--%>                    <td><%=task_project_name%></td>
                  </framework:ifExpr>
<%
                  for(int w=0;w<=al.size()-1;w++){
                    Date weekItem = (Date)al.get(w);
                    Date weekItemNext = null;

                    if(w==al.size()-1)
                    {
                      weekItemNext =  deAdjusted;
                    }else
                    {
                    weekItemNext =  (Date)al.get(w+1);
                    }


                    ArrayList daysofweek = personBean.getAvailableDates(context, weekItem, weekItemNext, pid, 1);

                    double str_qloading = Task.parseToDouble(personBean.getQuarterlyLoading(hitem,daysofweek));
                    String strRet = "";

                    if(str_qloading >= (Double)Task.parseToDouble(yellow_threshold) && str_qloading < (Double)Task.parseToDouble(red_threshold))
                    {
                      strRet="<font color=\"orange\">"+XSSUtil.encodeForHTML(context, personBean.resultFormatted(str_qloading))+"</font>";

                    }else if(str_qloading >= (Double)Task.parseToDouble(red_threshold)){

                      strRet="<font color=\"red\">"+XSSUtil.encodeForHTML(context, personBean.resultFormatted(str_qloading))+"</font>";
                    }else{
                      if(str_qloading<0.01){
                        strRet="0.00";
                      }else{
                        strRet = personBean.resultFormatted(str_qloading);
                      }
                    }
                    if(toExcel)
                    {
                        exportStringBuffer.append(personBean.getQuarterlyLoading(hitem,daysofweek) + strDelimiter);
                    }


%>
                    <framework:ifExpr expr="<%=toExcel == false%>">
                      <td><%=strRet%></td>
                    </framework:ifExpr>

<%                }
                  if(toExcel)
                  {
                    exportStringBuffer.append("\n");
                  }
%>
                </tr>


<%            }else if(selected.equals("w")){%>
                <framework:ifExpr expr="<%=toExcel == false%>">
           <%-- XSSOK --%>        <td><%=task_person_name%></td>
           <%-- XSSOK --%>         <td><%=proj_name%></td>
           <%-- XSSOK --%>         <td><%=task_project_name%></td>
                </framework:ifExpr>
<%              for(int w=0;w<al.size();w++){
                  Date weekItem = (Date)al.get(w);
                  int getnumdays =7;
                  int MILLIS_IN_DAY = 1000 * 60 * 60 * 24;
                  Date week_date_end =new Date( weekItem.getTime() + (6*MILLIS_IN_DAY));


                  ArrayList daysofweek = personBean.getAvailableDates(context, weekItem, week_date_end, pid, 1);

                  double str_wloading = Task.parseToDouble(personBean.getWeeklyLoading(hitem,daysofweek));
                  String strRet = "";

                	  if(str_wloading >= (Double)Task.parseToDouble(yellow_threshold) && str_wloading < (Double)Task.parseToDouble(red_threshold))
                  {
                    strRet="<font color=\"orange\">"+XSSUtil.encodeForHTML(context, personBean.resultFormatted(str_wloading))+"</font>";

                  }else if(str_wloading >= (Double)Task.parseToDouble(red_threshold)){

                    strRet="<font color=\"red\">"+XSSUtil.encodeForHTML(context, personBean.resultFormatted(str_wloading))+"</font>";
                  }else{


                    if(str_wloading<0.01){
                      strRet="0.00";
                    }else{
                      strRet = personBean.resultFormatted(str_wloading);
                    }

                    strRet = personBean.resultFormatted(str_wloading);
                  }
                  if(toExcel)
                  {
                    exportStringBuffer.append(personBean.getWeeklyLoading(hitem,daysofweek) + strDelimiter);
                  }
%>
                  <framework:ifExpr expr="<%=toExcel == false%>">
                    <td><%=strRet%></td>
                  </framework:ifExpr>
<%               }
                 if(toExcel)
                 {
                   exportStringBuffer.append("\n");
                 }
%>
               </tr>
<%            }%>
<%
              n++;
              m=n%2;

            }


          }

        }

      }else{

        stopProcessing=true;
      }

      if(stopProcessing){
        //TODO ...Replace "NO DATA FOUND" with string resource key
        if(toExcel)
        {
            exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
      			  "emxProgramCentral.Common.Nodata", language) + '\n');
        }
%>
    <framework:ifExpr expr="<%=toExcel == false%>">
        <tr>
          <td>
            <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.Nodata</emxUtil:i18n>
          </td>

        </tr>
    </framework:ifExpr>

<%
      }else{

        if(toExcel){
            exportStringBuffer.append("Total" + strDelimiter);
            exportStringBuffer.append(" " + strDelimiter);
            exportStringBuffer.append(" " + strDelimiter);
        }
%>
        <framework:ifExpr expr="<%=toExcel == false%>">
            <tr>
              <th><emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.Total</emxUtil:i18n></th>
              <th>&nbsp;</th>
              <th>&nbsp;</th>
        </framework:ifExpr>
<%
      }

      if(topMap.size()>0 && !(stopProcessing))
      {

        double monthly_res=0;
        double weekly_res=0;
        double total_qloading = 0;
        if(selected.equals("m")){

          for(int te = 0; te<al.size(); te++){

            Date idate_all = (Date)al.get(te);

            int iMonth_all = idate_all.getMonth();
            long getnumdays = personBean.getNumworkingDays(context,idate_all,pid);

            ArrayList arr_all = personBean.getworkingDates(context,idate_all, pid,1);
            monthly_res = (Double)Task.parseToDouble(personBean.getTotalLoading(topMap,getnumdays,arr_all));
            
            String strRet = "";

            if(monthly_res >= (Double)Task.parseToDouble(yellow_threshold)&& monthly_res <(Double)Task.parseToDouble(red_threshold))
            {
              strRet="<font color=\"orange\">"+XSSUtil.encodeForHTML(context, personBean.resultFormatted(monthly_res))+"</font>";
            }else if(monthly_res >= (Double)Task.parseToDouble(red_threshold)){
              strRet="<font color=\"red\">"+XSSUtil.encodeForHTML(context, personBean.resultFormatted(monthly_res))+"</font>";
            }else{


              if(monthly_res<0.01){
                strRet="0.00";
              }else{
                strRet = personBean.resultFormatted(monthly_res);
              }
            }
            if(toExcel)
            {
                exportStringBuffer.append(personBean.resultFormatted(monthly_res) + strDelimiter);
            }

%>
            <framework:ifExpr expr="<%=toExcel == false%>">
                <th><%=strRet%></th>
            </framework:ifExpr>
<%

          }

        }else if(selected.equals("w")){


          for(int w=0;w<al.size();w++){
            Date weekItem = (Date)al.get(w);

            int getnumdays =7;
            int MILLIS_IN_DAY = 1000 * 60 * 60 * 24;
            Date week_date_end =new Date( weekItem.getTime() + (6*MILLIS_IN_DAY));

            ArrayList daysofweek = personBean.getAvailableDates(context, weekItem, week_date_end, pid, 1);
            weekly_res = (Double)Task.parseToDouble(personBean.getTotalWeeklyLoading(topMap,daysofweek));

            String strRet = "";

            if(weekly_res >=(Double)Task.parseToDouble(yellow_threshold) && weekly_res < (Double)Task.parseToDouble(red_threshold))
            {
              strRet="<font color=\"orange\">"+XSSUtil.encodeForHTML(context, personBean.resultFormatted(weekly_res))+"</font>";

            }else if(weekly_res >= (Double)Task.parseToDouble(red_threshold)){

              strRet="<font color=\"red\">"+XSSUtil.encodeForHTML(context, personBean.resultFormatted(weekly_res))+"</font>";
            }else{

              if(weekly_res<0.01){
                strRet="0.00";
              }else{
                strRet = personBean.resultFormatted(weekly_res);
              }
            }
            if(toExcel)
            {
                exportStringBuffer.append(personBean.resultFormatted(weekly_res) + strDelimiter);
            }

%>          <framework:ifExpr expr="<%=toExcel == false%>">
                <th><%=strRet%></th>
            </framework:ifExpr>
<%
        }




      }else if (selected.equals("q")){

        for(int w=0;w<=al.size()-1;w++){

          Date weekItem = (Date)al.get(w);
          Date weekItemNext = null;

          if(w==al.size()-1)
          {
            weekItemNext =  deAdjusted;

          } else
          {
            weekItemNext =  (Date)al.get(w+1);
          }


          ArrayList daysofweek = personBean.getAvailableDates(context, weekItem, weekItemNext, pid, 1);

	total_qloading = (Double)Task.parseToDouble(personBean.getTotalQuarterlyLoading(topMap,daysofweek));
          String strRet = "";

          if(total_qloading >= (Double)Task.parseToDouble(yellow_threshold) && total_qloading < (Double)Task.parseToDouble(red_threshold))
          {
            strRet="<font color=\"orange\">"+XSSUtil.encodeForHTML(context, personBean.resultFormatted(total_qloading))+"</font>";

	}else if(total_qloading >= (Double)Task.parseToDouble(red_threshold)){
            strRet="<font color=\"red\">"+XSSUtil.encodeForHTML(context, personBean.resultFormatted(total_qloading))+"</font>";
          }else{

            if(total_qloading<0.01){
              strRet="0.00";
            }else{
              strRet = personBean.resultFormatted(total_qloading);
            }
          }
          if(toExcel)
          {
            exportStringBuffer.append(personBean.resultFormatted(total_qloading) + strDelimiter);
          }


 %>          <framework:ifExpr expr="<%=toExcel == false%>">
                <th><%=strRet%></th>
            </framework:ifExpr>
<%
    }
      }

    }


   }else{


     //TODO ...Replace with string resource key
     out.println(ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.ResourceLoading.DateRangeInsufficient", language));
     hiddenParams =emxTableRowId;
    }


%>
<%
  if(toExcel)
  {
    String fileNameStr = "ResourceLoadingPersonSummary" + (new Date()).getTime() + ".csv";
    String fileEncodeType = UINavigatorUtil.getFileEncoding(context, request);
    String fileName = new String(fileNameStr.getBytes(),fileEncodeType);
    fileName = fileName.replace(' ','_');
    String saveAs = ServletUtil.encodeURL(fileName);
    String tempFileName = saveAs.replace('%','0');  // temp - hashed file name

    String url = "";
    try
    {
        OutputStreamWriter osw = new OutputStreamWriter( (java.io.OutputStream)Framework.createTemporaryFile(session, tempFileName),  fileEncodeType);
        BufferedWriter prgBw = new BufferedWriter( osw );
        prgBw.write(exportStringBuffer.toString());
        prgBw.flush();
        prgBw.close();
        url = Framework.getTemporaryFilePath(response, session, tempFileName, true);
    }
    catch(Exception nex)
    {
        System.out.println("Exception in exporting to Excel in Resource Loading Summary");
    }
    url = url.substring(0,url.lastIndexOf("/")+1) + XSSUtil.encodeForURL(context, tempFileName ) +  "?saveasfile=" + saveAs;
%>
<table border="0" width="710" cellpadding="0" cellspacing="0" class="formBG">
    <tr>
      <td>
        <table border="0" width="710" cellpadding="0" cellspacing="0" class="formBG">
            <table border="0" width="700">
                <tr>
                  <td nowrap class="label" width="33%">
                    <emxUtil:i18n localize="i18nId">emxProgramCentral.Export.DownloadFile</emxUtil:i18n>
                  </td>
                  <td width="10"> <a href="<%= url%>"><xss:encodeForHTML><%= fileName %></xss:encodeForHTML></a></td>  <%-- XSSOK --%>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
<%
  }
%>


</table>

<form name="form1" method="post">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<input type="hidden" name="tablerowids" value="<xss:encodeForHTMLAttribute><%=hiddenParams%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="start" value="<xss:encodeForHTMLAttribute><%=hidden_start%></xss:encodeForHTMLAttribute>"/>
<input type="hidden" name="end" value="<xss:encodeForHTMLAttribute><%=hidden_end%></xss:encodeForHTMLAttribute>"/>
</form>
