<%-- emxProgramCentralResourceLoadingSummary.jsp

  Displays a window for creating a Calendar event.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralResourceLoadingSummary.jsp.rca 1.19 Tue Oct 28 22:59:42 2008 przemek Experimental przemek $";

--%>

<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@ page import="java.util.Calendar" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
    boolean toExcel = false;
    String outputAsSpreadsheet = emxGetParameter(request, "outputAsSpreadsheet");
    if ("true".equals(outputAsSpreadsheet)){
    toExcel = true;
    }

    String prop = EnoviaResourceBundle.getProperty(context, "eServiceProgramCentral.ResourceLoading.Default");
    String filter_passed_param = emxGetParameter(request, "mx.page.filter");

    if(filter_passed_param==null && prop!=null)
    {
        filter_passed_param=prop;
    }

    boolean isPrinterFriendly = false;
    String printerFriendly = emxGetParameter(request, "PrinterFriendly");

    if (printerFriendly != null && "true".equals(printerFriendly)) {
       isPrinterFriendly = true;
    }
    
    ResourceLoading resourceLoading = new ResourceLoading (context);
%>

<%--jsp:useBean id="resourceLoading" scope="request" class="com.matrixone.apps.program.ResourceLoading"/--%>


<%@page import="com.matrixone.apps.program.ResourceLoading"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><script language="javascript" src="../common/scripts/emxUIConstants.js" />
<script language="javascript" src="../common/scripts/emxUICore.js" />
<script language="javascript" src="../common/scripts/emxUICoreMenu.js" />

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

  window.open(url,'','height=580,width=750,status=no,toolbar=no,menubar=no,location=no,resizable=yes,scrollbars=yes');

}
function newReport()
{
  var newPage="../programcentral/emxProgramCentralResourceDialogFS.jsp";
  var filterSelected = '<%=XSSUtil.encodeForJavaScript(context,filter_passed_param)%>';

  newPage += "?type=regular&optionSelected="+filterSelected;
  //Added:30-Sep-2010:vf2:R2012
  var frameobj = findFrame(getTopWindow(), 'pagecontent');
  var tableId = frameobj.document.forms[0].tablerowids.value;
  //var tableId = getTopWindow().frames[0].document.forms[0].tablerowids.value;
  //End:30-Sep-2010:vf2:R2012
  if (tableId!=null && tableId.length > 0 ){
    newPage += "&emxTableRowId=" + tableId;
  }
  var date_start = '<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"start"))%>';
  if (date_start!=null && date_start.length > 0 ){
    newPage += "&start=" + date_start;
  }

  var date_end = '<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"end"))%>';
  if (date_end!=null && date_end.length > 0 ){
    newPage += "&end=" + date_end;
  }

  var date_start_msvalue = '<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"start_msvalue"))%>';
  if (date_start_msvalue!=null ){
    newPage += "&start_msvalue=" + date_start_msvalue;
  }

  var date_end_msvalue = '<%=XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"end_msvalue"))%>';
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
//Modified for Bug#312083 on 10/15/2007 - Begin
//String emxTableRowId   = emxGetParameter(request, "emxTableRowId");
String emxTableRowId = (String) session.getAttribute("emxTableRowId");
//Modified for Bug#312083 on 10/15/2007 - End
String sStartDtHidden = emxGetParameter(request,"start_msvalue");
sStartDtHidden = XSSUtil.encodeForJavaScript(context, sStartDtHidden);
String sEndDtHidden = emxGetParameter(request,"end_msvalue");
sEndDtHidden = XSSUtil.encodeForJavaScript(context, sEndDtHidden);
String sDate = emxGetParameter(request,"start");
String eDate = emxGetParameter(request,"end");

String objectId   = emxGetParameter(request, "objectId");
objectId = XSSUtil.encodeForJavaScript(context, objectId);

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

    //double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
    //if(d_start != null && d_end !=null){
      //d_start = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,d_start, clientTZOffset,request.getLocale());
      //d_end = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,d_end, clientTZOffset,request.getLocale());
    //}

  }

}
if(d_start!=null && d_start.length() > 0 && d_end != null && d_end.length() > 0)
{

  dt_Start = new Date(d_start);
  dt_End = new Date(d_end);
}

String language = request.getHeader("Accept-Language");
com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, "PROGRAM");
String selected="";
Date dsAdjusted = dt_Start;
Date deAdjusted = dt_End;
ArrayList al = new ArrayList();

String initial = emxGetParameter(request, "initial");
if(initial !=null && initial.equalsIgnoreCase("Monthly"))
{
  dsAdjusted = resourceLoading.adjustStartDate(dt_Start);
  deAdjusted = resourceLoading.adjustEndDate(dt_End);
}
else if (initial !=null && initial.equalsIgnoreCase("Quarterly"))
{
  dsAdjusted = resourceLoading.adjustQuarterlyStartDate(dt_Start);
  deAdjusted = resourceLoading.adjustQuarterlyEndDate(dt_End);
}
else if (initial !=null && initial.equalsIgnoreCase("Weekly"))
{
  dsAdjusted = resourceLoading.adjustWeeklyStartDate(dt_Start);
  deAdjusted = resourceLoading.adjustWeeklyEndDate(dt_End);
}

if(filter_passed_param !=null && filter_passed_param.equalsIgnoreCase("Monthly"))
{
	//Added:26-Nov-10:vf2:R211:IR-081516
	dsAdjusted = resourceLoading.adjustStartDate(dt_Start);
	deAdjusted = resourceLoading.adjustEndDate(dt_End);
	//End:26-Nov-10:vf2:R211:IR-081516
	al = resourceLoading.getMonthRanges(dsAdjusted,deAdjusted);
  selected="m";
}
else if (filter_passed_param !=null && filter_passed_param.equalsIgnoreCase("Quarterly"))
{
	//Added:26-Nov-10:vf2:R211:IR-081516
	dsAdjusted = resourceLoading.adjustQuarterlyStartDate(dt_Start);
	deAdjusted = resourceLoading.adjustQuarterlyEndDate(dt_End);
	//End:26-Nov-10:vf2:R211:IR-081516
	al = resourceLoading.getQuarterlyData(dsAdjusted,deAdjusted);
  selected="q";
}
else if (filter_passed_param !=null && filter_passed_param.equalsIgnoreCase("Weekly"))
{
  dsAdjusted = resourceLoading.adjustWeeklyStartDate(dsAdjusted);
  deAdjusted = resourceLoading.adjustWeeklyEndDate(deAdjusted);
  al = resourceLoading.getWeeklyData(dsAdjusted,deAdjusted);
  selected="w";
}else{

  //if none selected, then select the default set in the properties file.
    if(prop!=null && prop.equalsIgnoreCase("monthly"))
    {
      dsAdjusted = resourceLoading.adjustStartDate(dt_Start);
      deAdjusted = resourceLoading.adjustEndDate(dt_End);
      al = resourceLoading.getMonthRanges(dsAdjusted,deAdjusted);
      selected="m";

    }else if (prop!=null && prop.equalsIgnoreCase("weekly"))
    {
      dsAdjusted = resourceLoading.adjustWeeklyStartDate(dt_Start);
      deAdjusted = resourceLoading.adjustWeeklyEndDate(dt_End);
      al = resourceLoading.getWeeklyData(dsAdjusted,deAdjusted);
      selected="w";
    }
    else if (prop!=null && prop.equalsIgnoreCase("quarterly"))
    {
      dsAdjusted = resourceLoading.adjustQuarterlyStartDate(dt_Start);
      deAdjusted = resourceLoading.adjustQuarterlyEndDate(dt_End);
      al = resourceLoading.getQuarterlyData(dsAdjusted,deAdjusted);
      selected="q";
    }
}
hidden_start =  resourceLoading.mxFormatDate(dsAdjusted);
hidden_end =  resourceLoading.mxFormatDate(deAdjusted);

Date startDate = new Date(hidden_start);
java.text.SimpleDateFormat sdf3 = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
String start_date = sdf3.format(startDate);

Date endDate = new Date(hidden_end);
String end_date = sdf3.format(endDate);

String hiddenParams = "";

double iTimeZoneDbl= (new Double(timeZone)).doubleValue();

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
exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
		  "emxProgramCentral.Common.ResourceLoading.Name", language) + strDelimiter);
%>

<framework:ifExpr expr="<%=toExcel == false%>">
<table border="0" width="100%" align="center" class="list">
<tr>
  <td colspan="2" bgcolor="#eeeeee"><b>
  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.ReportPeriod</emxUtil:i18n>
  </b></td>
</tr><tr>
  <td colspan="1">
  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.From</emxUtil:i18n> &nbsp;
  <framework:lzDate localize='i18nId' tz='<%= timeZone %>' format='<%= dateFormat %>' displaydate='true'>
<%-- XSSOK --%>  <%=start_date%>
  </framework:lzDate>
  </td>
  <td colspan="1">
  <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.To </emxUtil:i18n>&nbsp;
  <framework:lzDate localize='i18nId' tz='<%= timeZone %>' format='<%= dateFormat %>' displaydate='true'>
<%-- XSSOK --%>  <%=end_date%>
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
    <table border="0" width="100%" class="list">
        <tr>
          <th>
          <emxUtil:i18n localize="i18nId">emxProgramCentral.Common.ResourceLoading.Name</emxUtil:i18n>
          </th>
</framework:ifExpr>
<%          if(selected.equals("m"))
            {
              for (int i=0; i<al.size(); i++) {
                Date stdate = (Date)al.get(i);
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(),Locale.US);
                String aDate = sdf.format(stdate);
				String week_date = "";
				if(!toExcel)
                {
					week_date = resourceLoading.formatMonthly(eMatrixDateFormat.getFormattedDisplayDate(aDate,iTimeZoneDbl),request.getLocale());
					exportStringBuffer.append(week_date + strDelimiter);
				}
%>
                <framework:ifExpr expr="<%=toExcel == false%>">
           <%-- XSSOK --%>         <th><%=week_date%></th>
                </framework:ifExpr><%}

            }
            else if (selected.equals("w"))
            {
              for (int i=0; i<al.size(); i++){
                Date stdate = (Date)al.get(i);
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
                String aDate = sdf.format(stdate);
                String week_date = eMatrixDateFormat.getFormattedDisplayDate(aDate,iTimeZoneDbl);
				if(!toExcel)
                {
                    week_date = week_date.replace(',',' ');
                    exportStringBuffer.append(week_date + strDelimiter);
                }
%>
              <framework:ifExpr expr="<%=toExcel == false%>">
                    <th><framework:lzDate localize='i18nId' tz='<%= timeZone %>' format='<%= dateFormat %>' displaydate='true'>
               <%-- XSSOK --%>         <%=aDate%>
                        </framework:lzDate>
                    </th></framework:ifExpr><%}


            }
            else if(selected.equals("q"))
            {


              for (int i=0; i<al.size(); i++) {
                Date qdate = (Date)al.get(i);
                Date qdate_next;

                if(i==al.size()-1)
                {
                  qdate_next =  deAdjusted;

                } else

                {
                  qdate_next = (Date)al.get(i + 1);
                }

                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
                String qDate = sdf.format(qdate);

                String quarter_date = resourceLoading.formatMonthly(eMatrixDateFormat.getFormattedDisplayDate(qDate,iTimeZoneDbl),request.getLocale());
                Date formatQuarter =(Date) resourceLoading.getQuarterEndDate(qdate_next);
                String qDate_next = sdf.format(formatQuarter);
				String quarter_Next = "";
				if(!toExcel)
                {
					quarter_Next = resourceLoading.formatMonthly(eMatrixDateFormat.getFormattedDisplayDate(qDate_next,iTimeZoneDbl),request.getLocale());
					exportStringBuffer.append(quarter_date + " - " + quarter_Next + strDelimiter);
				}
                
%>
                <framework:ifExpr expr="<%=toExcel == false%>">
                    <th><%=quarter_date%> - <%=quarter_Next%></th>
                </framework:ifExpr>
       <%}


            }
			MapList topMap = new MapList();
			if(!toExcel)
            {
			exportStringBuffer.append("\n");
            com.matrixone.apps.common.Person person = null;
            String sRel = "";
            String sBus = "";

          //Modified:nr2:PRG:R212:20 May 2011:IR-030958V6R2012x
            StringTokenizer tokenizer = new StringTokenizer(emxTableRowId,"~",false);
            int tokens = tokenizer.countTokens();
            String full_userName="";
            for(int k=0;k<tokens;k++)
            {
              full_userName = "";
              String itemId = tokenizer.nextToken();
              if(k==tokens-1)
                hiddenParams += itemId;
              else
                hiddenParams += itemId + "~"; //Modified:nr2:PRG:R212:20 May 2011:IR-030958V6R2012x

              StringTokenizer stok=null;
              if(itemId!=null && itemId.indexOf("_") > 0) //Selected from Project->Member
              {
                stok = new StringTokenizer(itemId,"_",false);
                while(stok.hasMoreTokens())
                {
                  sRel = stok.nextToken();
                  sBus = stok.nextToken();
                }
              }
              else if(itemId!=null && itemId.indexOf("|") > 0) //Selected from Company->Person
               {
                stok = new StringTokenizer(itemId,"|",false);
                int numTokens = stok.countTokens();
                if(numTokens==4){
                    if(stok.hasMoreTokens())
              		   sRel = stok.nextToken();
                       sBus = stok.nextToken();
               }
                /*
                while(stok.hasMoreTokens())
                {
                   sRel = stok.nextToken();
                   sBus = stok.nextToken();
                }
                */
               }
              else{ //Should not reach this condition. 
                sBus = itemId;
              }
              DomainObject objPerson = new DomainObject(sBus);
              try{
                objPerson.open(context);
               }catch(Exception ex){
                throw ex;
              }
               finally{
            	   objPerson.close(context);            	   
               }
              String userName =objPerson.getName();
              String personId =objPerson.getId();
              person = person.getPerson(context,userName);
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
              busWhere += " && relationship[Project Access Key].from.relationship[Project Access List].to.current!='Hold'";
              busWhere += " && relationship[Project Access Key].from.relationship[Project Access List].to.current!='Cancel'";
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
             
              String taskId = DomainObject.EMPTY_STRING;
              String sStartdate = DomainObject.EMPTY_STRING;
              String sEndDate = DomainObject.EMPTY_STRING;
              String task_duration = DomainObject.EMPTY_STRING;

              String type_Person=(String)PropertyUtil.getSchemaProperty(context,"type_Person");
              String rel_assigned=(String)PropertyUtil.getSchemaProperty(context,"relationship_AssignedTasks");
              HashMap dataMap = new HashMap();
              HashMap itemData=null;
              Vector vec = new Vector();
              MapList assignmentList = person.getAssignments(context, busSelects, busWhere, false, true);
              for(int g=0;g<assignmentList.size();g++)
              {

                 itemData = new HashMap();
                 taskId =(String)((Map)assignmentList.get(g)).get("id");

                 sStartdate =(String)((Map)assignmentList.get(g)).get(task.SELECT_TASK_ESTIMATED_START_DATE);
                 sEndDate =(String)((Map)assignmentList.get(g)).get(task.SELECT_TASK_ESTIMATED_FINISH_DATE);


                 task_duration =(String)((Map)assignmentList.get(g)).get(task.SELECT_TASK_ESTIMATED_DURATION);
                 Vector taskVec = resourceLoading.getAllocation(context,taskId,rel_assigned,type_Person,true,false,(short)1, true);

                 task.setId(taskId);

                 StringList busTaskSelects = new StringList(1);
                 busTaskSelects.add(task.SELECT_ID);

                 //Get Project data
                 StringList busProjSelects = new StringList();
                 busProjSelects.addElement(DomainObject.SELECT_ID);

                 String attribute_ProjectVisibility=(String)PropertyUtil.getSchemaProperty(context,"attribute_ProjectVisibility");
                 busProjSelects.addElement("attribute[" + attribute_ProjectVisibility + "]");



                 Map projMap = (Map) task.getProject(context,busProjSelects);

                 String projID = (String)projMap.get(task.SELECT_ID);

                 String projVisibility = (String)projMap.get("attribute[" + attribute_ProjectVisibility + "]");


                 //if visibility is set to members and the person is not a member of the project
                 //then do not include this task in the report.

                 //Modified:10-Mar-2010:s2e:R209 PRG:IR-034847V6R2011    
                boolean checkmembership = false;
                MapList testMap = task.getTasks(context, task, 1, busTaskSelects, new StringList(), false, true);
                MapList ml = (MapList)resourceLoading.getAssigneeInfo(context,taskId, true);

                     String pid = null;
                     Iterator mListItr      = ml.iterator();
                      while(mListItr.hasNext()){
                    	  pid     = (String) ( ( (Map)mListItr.next() ).get(DomainConstants.SELECT_ID) );
                          if(personId.equals(pid) && pid != null && pid.length() != 0){
                              checkmembership = true;
                              break;
                           }
                            else{
                              checkmembership = resourceLoading.isPersonProjectMember(context,projID,personId);
                            }
                          }
                    //End:10-Mar-2010:s2e:R209 PRG:IR-034847V6R2011 

                 if(projVisibility != null && projVisibility.trim().length()>0 &&
                   projVisibility.equalsIgnoreCase("Members") && !checkmembership)

                   {
                    continue;
                   }

                 //check to make sure that the task does not have any children before adding it to
                 //the list of tasks
                 
                 if(testMap!=null && testMap.size()>0)
                 {
                    continue;
                 }


                 
                 String totalAssingees = "" + ml.size();

                 String userCalendarId = resourceLoading.getUserCalendar(context,sBus);
                 String alloc_value = resourceLoading.getAllocValue(taskVec,sBus);
                 ArrayList hmInfo = new ArrayList();
                 if (userCalendarId != null && !"".equals(userCalendarId) && !"null".equals(userCalendarId))
                 {
                    Date sttDate = new Date(sStartdate);
                    Date eddDate = new Date(sEndDate);
                    hmInfo = resourceLoading.getDaysInRange(context, userCalendarId, sttDate,eddDate,1);
                 }
                 else{
                    hmInfo = resourceLoading.getDateRangeData(sStartdate,sEndDate,true);
                 }

                 itemData.put("taskid",taskId);
                 itemData.put("taskDays",hmInfo);
                 itemData.put("duration",task_duration);
                 itemData.put("assignees",totalAssingees);
                 itemData.put("allocation",alloc_value);
                 vec.add(itemData);
              }



              dataMap.put("personid",sBus);
              dataMap.put("fullname",full_userName);
              dataMap.put("data",vec);
              topMap.add(dataMap);
            }
			}
%>

        </tr>
<%
        String rowValue="";
        int m=0;int n=0;
        for(int j=0;j<topMap.size();j++)
        {
          HashMap topDataMap = (HashMap)topMap.get(j);
          String pid = (String)topDataMap.get("personid");
          String full_n = (String)topDataMap.get("fullname");
		  if(!toExcel)
          {
            exportStringBuffer.append("\"");
            exportStringBuffer.append(full_n);
            exportStringBuffer.append("\"");
            exportStringBuffer.append(strDelimiter);
          }
          if(prop==null)
          {
           prop="Monthly";
          }

          if(isPrinterFriendly)
          {
            full_n="<table><tr><td><img src=\"../common/images/iconSmallPerson.gif\" border=\"0\" /></td><td>"+full_n+"</td></tr></table>";
          }
          else{
            full_n="<table><tr><td><img src=\"../common/images/iconSmallPerson.gif\" border=\"0\" /></td><td><a href=\"javascript:callTree('../programcentral/emxProgramCentralResourceLoadingPersonFS.jsp?emxTableRowId="+pid+"&emxSuiteDirectory=programcentral&mx.page.filter="+filter_passed_param+"&objectId="+objectId+"&start="+hidden_start+"&end="+hidden_end+"&start_msvalue="+sStartDtHidden+"&end_msvalue="+sEndDtHidden+"&sDate="+sDate+"&eDate="+eDate+"')\">"+full_n+"</a></td></tr></table>";
          }

          rowValue = "#eeeeee";
          if (m == 0) {
          rowValue="#ffffff";
          }
%>
            <framework:ifExpr expr="<%=toExcel == false%>">
           <%-- XSSOK--%>
                <tr bgcolor="<%=rowValue%>">
            </framework:ifExpr>
<%          if(selected=="m"){%>
            <framework:ifExpr expr="<%=toExcel == false%>">
           <%-- XSSOK --%>     <td><%=full_n%></td>
            </framework:ifExpr>
<%

              for(int ta = 0; ta<al.size(); ta++)
              {
                Date idate = (Date)al.get(ta);
                int iMonth = idate.getMonth();
                long getnum = resourceLoading.getNumworkingDays(context,idate,pid);
                ArrayList arr = resourceLoading.getworkingDates(context,idate,pid,1);
                Date weekItemNext = null;
                if(ta==al.size()-1)
                {
                  weekItemNext =  dt_End;

                } else

                {
                  weekItemNext =  (Date)al.get(ta+1);
                }
				String strMonthlyLoading = "";
				if(!toExcel)
				{
					//Modified:7-May-2010:wqy:V6R2010:PRG:HF-046696V6R2010
					/*
					The buffer loads all the value including the HTML tags reurned by the function.
					In order to differentiate between them the 3 rd parameter is hardcoded.
					Funaction call with 3rd parameter 'false' returns the value with the font tags and the other one
					returns just the value.
					*/
					strMonthlyLoading = (String) resourceLoading.get_m_loading(topDataMap,getnum,arr,false);
					exportStringBuffer.append(resourceLoading.get_m_loading(topDataMap,getnum,arr,true) + strDelimiter);
					//Modification End:7-May-2010:wqy:V6R2010:PRG:HF-046696V6R2010
				}
                
%>
                <framework:ifExpr expr="<%=toExcel == false%>">
                    <td><%=strMonthlyLoading%></td><%-- XSSOK --%>
                </framework:ifExpr>
<%

              }%>
            </tr>
<%           }else if(selected=="q"){

%>

                <framework:ifExpr expr="<%=toExcel == false%>">
            <%-- XSSOK --%>         <td><%=full_n%></td>
                </framework:ifExpr>
<%

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

                  ArrayList daysofweek = resourceLoading.getAvailableDates(context, weekItem, weekItemNext, pid, 1);
				  String strQuarterlyLoading = "";
				  if(!toExcel)
					{
					//Modified:7-May-2010:wqy:V6R2010:PRG:HF-046696V6R2010
					  /*
	                    The buffer loads all the value including the HTML tags reurned by the function.
	                    In order to differentiate between them the 3 rd parameter is hardcoded.
	                    Funaction call with 3rd parameter 'false' returns the value with the font tags and the other one
	                    returns just the value.
	                    */
					  strQuarterlyLoading = (String) resourceLoading.getQuarterlyResourceLoading(context, topDataMap,daysofweek,false);
					  exportStringBuffer.append(resourceLoading.getQuarterlyResourceLoading(context, topDataMap,daysofweek,true) + strDelimiter);
					//Modification End:7-May-2010:wqy:V6R2010:PRG:HF-046696V6R2010
					}
%>
                <framework:ifExpr expr="<%=toExcel == false%>">
                    <td><%=strQuarterlyLoading%></td><%-- XSSOK --%>
                </framework:ifExpr>
        <%      }%>
        </tr>

        <%    }else if(selected=="w"){%>
                <framework:ifExpr expr="<%=toExcel == false%>">
         <%-- XSSOK --%>        <td><%=full_n%></td>
                </framework:ifExpr>
                <%for(int w=0;w<al.size();w++){
                    Date weekItem = (Date)al.get(w);
                    int getnumdays =7;
                    int MILLIS_IN_DAY = 1000 * 60 * 60 * 24;
                    Date week_date_end =new Date( weekItem.getTime() + (6*MILLIS_IN_DAY));
                    ArrayList daysofweek = resourceLoading.getAvailableDates(context, weekItem, week_date_end, pid, 1);
					String strWeeklyLoading = "";
					if(!toExcel)
					{
						//Modified:7-May-2010:wqy:V6R2010:PRG:HF-046696V6R2010
						/*
	                    The buffer loads all the value including the HTML tags reurned by the function.
	                    In order to differentiate between them the 3 rd parameter is hardcoded.
	                    Funaction call with 3rd parameter 'false' returns the value with the font tags and the other one
	                    returns just the value.
	                    */
						strWeeklyLoading = (String) resourceLoading.getWeeklyResourceLoading(context, topDataMap,daysofweek,false);						
						exportStringBuffer.append((String) resourceLoading.getWeeklyResourceLoading(context, topDataMap,daysofweek,true) + strDelimiter);
						//Modification End:7-May-2010:wqy:V6R2010:PRG:HF-046696V6R2010
					}
            %>
                    <framework:ifExpr expr="<%=toExcel == false%>">
                        <td><%=strWeeklyLoading%></td><%-- XSSOK --%>
                    </framework:ifExpr>
        <%        }%>
        </tr>
        <%      }%>

<%
              n++;
              m=n%2;
              exportStringBuffer.append("\n");
        }        
    }else{

       //TODO ...Replace "NO DATA FOUND" with string resource key
       out.println(ProgramCentralUtil.i18nStringNow("emxProgramCentral.Common.ResourceLoading.DateRangeInsufficient", language));
       hiddenParams =emxTableRowId;
    }


%>
<%
if(!toExcel)
{
	if(!(al != null && al.size() > 0 )) {	exportStringBuffer.append(EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			  "emxProgramCentral.Common.ResourceLoading.DateRangeInsufficient", language) + '\n');
    }
	if(session.getAttribute("exportData")!=null)
	{
		session.removeAttribute("exportData");
	}
	session.setAttribute("exportData",exportStringBuffer.toString());
}
  if(toExcel)
  {
	String exportData = (String) session.getAttribute("exportData");
    String fileNameStr = "ResourceLoadingSummary" + (new Date()).getTime() + ".csv";
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
        prgBw.write(exportData);
        prgBw.flush();
        prgBw.close();
        url = Framework.getTemporaryFilePath(response, session, tempFileName, true);
    }
    catch(Exception nex)
    {
        System.out.println("Exception in exporting to Excel in Resource Loading Summary");
    }
    url = url.substring(0,url.lastIndexOf("/")+1) + XSSUtil.encodeForURL(context, tempFileName) +  "?saveasfile=" + saveAs;
%>
<table border="0" width="710" cellpadding="0" cellspacing="0" class="formBG" class="list">
    <tr>
      <td>
        <table border="0" width="710" cellpadding="0" cellspacing="0" class="formBG" class="list">
            <table border="0" width="700">
                <tr>
                  <td nowrap class="label" width="33%">
                    <emxUtil:i18n localize="i18nId">emxProgramCentral.Export.DownloadFile</emxUtil:i18n>
                  </td>
                  <td width="10"> <a href="<%= url%>"><xss:encodeForHTML><%= fileName %></xss:encodeForHTML></a></td>
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
  <%-- XSSOK --%>  <input type="hidden" name="start" value="<%=hidden_start%>"/>
  <%-- XSSOK --%>  <input type="hidden" name="end" value="<%=hidden_end%>"/>
  <%-- XSSOK --%> <input type="hidden" name="start_msvalue" value="<%=sStartDtHidden%>"/>
  <%-- XSSOK --%>  <input type="hidden" name="end_msvalue" value="<%=sEndDtHidden%>"/>
  <%-- XSSOK --%>  <input type="hidden" name="sDate" value="<%=sDate%>"/>
  <%-- XSSOK --%>  <input type="hidden" name="eDate" value="<%=eDate%>"/>
  </form>
