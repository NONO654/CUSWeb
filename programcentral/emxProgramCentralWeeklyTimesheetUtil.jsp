<%--  emxProgramCentralWeeklyTimesheetUtil.jsp

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxProgramCentralWeeklyTimesheetUtility.jsp.rca 1.37 Tue Oct 28 22:59:43 2008 przemek Experimental przemek $

--%>

<%@ include file="emxProgramGlobals2.inc"%>
<%@ include file="../emxUICommonAppInclude.inc"%>

<%@page import="java.util.StringTokenizer"%>

<%@page import="com.matrixone.apps.program.fiscal.Interval"%>
<%@page import="com.matrixone.apps.program.fiscal.Helper"%>
<%@page import="com.matrixone.apps.program.fiscal.CalendarType"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><script language="javascript" src="../common/scripts/emxUICore.js"></script>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<script language="javascript" src="../common/scripts/emxUIFormValidation.js"></script>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="matrix.util.StringList"%>

<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.DomainConstants"%>
<%@ page import="com.matrixone.apps.program.WeeklyTimesheet"%>
<%@ page import="com.matrixone.apps.common.Person"%>
<%@ page import = "matrix.db.*"%>
<%@ page import="com.matrixone.apps.domain.util.PersonUtil"%>
<%@ page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@ page import="java.util.HashMap,java.util.Date"%>
<%@ page import = "com.matrixone.apps.program.Task" %>
<%@ page import = "com.matrixone.apps.program.ProgramCentralConstants" %>
<%@ page import="java.util.HashMap,java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="com.matrixone.apps.domain.util.MessageUtil"%>
<%
String mode = emxGetParameter(request,"mode");  
String language  = request.getHeader("Accept-Language");
if(mode.equalsIgnoreCase("createTimesheet")) {
    String weekEndingDate = emxGetParameter(request,"ActualWeekEndDate");
    String copyObjectId = emxGetParameter(request,"copyObjectId"); 
    String subMode = emxGetParameter(request,"subMode");    
    Date weekEndDate = new Date(weekEndingDate);
    WeeklyTimesheet weeklyTimesheet = new WeeklyTimesheet();
    HashMap map = new HashMap();
    String urlString = "../common/emxForm.jsp?mode=edit&form=PMCCreateWeeklyTimeSheetForm&postProcessURL=../programcentral/emxProgramCentralWeeklyTimesheetUtil.jsp?"+
                       "mode=createTimesheet&formHeader=emxProgramCentral.WeeklyTimesheet.CreateTimeSheet&findMxLink=false&suiteKey=ProgramCentral";
    try {
    	String strURL = DomainObject.EMPTY_STRING;
        String timesheetId = weeklyTimesheet.create(context,WeeklyTimesheet.POLICY_WEEKLY_TIMESHEET,null,context.getUser(),null,weekEndDate,map);
        if(timesheetId != null && copyObjectId != null) {
        	   WeeklyTimesheet newCreatedTimesheet = new WeeklyTimesheet(timesheetId);
        	   WeeklyTimesheet timeSheetToBeCopied = new WeeklyTimesheet(copyObjectId);
        	   newCreatedTimesheet.copyTimesheet(context,timeSheetToBeCopied);
        }
        if("copySelect".equalsIgnoreCase(subMode)){
        	strURL = "../common/emxIndentedTable.jsp?program=emxWeeklyTimeSheet:getTimesheetInProcess,emxWeeklyTimeSheet:getTimesheetSubmitted,emxWeeklyTimeSheet:getTimesheetApproved,emxWeeklyTimeSheet:getTimesheetRejected,emxWeeklyTimeSheet:getWeeklyTimeSheets&table=PMCWeeklyTimeSheet&header=emxProgramCentral.WeeklyTimesheet.MyWeeklyTimeSheet&toolbar=PMCWeeklyTimeSheetToolBar&programLabel=emxProgramCentral.WeeklyTimesheet.InProcess,emxProgramCentral.WeeklyTimesheet.submitted,emxProgramCentral.WeeklyTimesheet.Approved,emxProgramCentral.WeeklyTimesheet.Rejected,emxProgramCentral.Common.All&selection=multiple&suiteKey=ProgramCentral&editLink=true&multiColumnSort=false&customize=true&sortColumnName=Week&sortDirection=descending&showClipboard=false&objectCompare=false&autoFilter=false&showPageURLIcon=false&rowGrouping=false&displayView=details";
         %>
        <script language="javascript">
       		 var urlString = '<%=XSSUtil.encodeForJavaScript(context, strURL)%>';
         	 parent.window.parent.frames[0].location.href = urlString;
        </script>
        <%
        }
     }catch(Exception ex) {
    	   String errorMessage = ex.getMessage();
    	     %>
                <script language="javascript">
	            	alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");          	           
	            </script>
<% 
	  }
} 
else if("copySelect".equalsIgnoreCase(mode)){
	String tableRowId = emxGetParameter(request,"emxTableRowId");
	String[] objectIds = tableRowId.split("\\|");
	String objectId = objectIds[1];	
	objectId = XSSUtil.encodeURLForServer(context,objectId);
	String urlString = "../common/emxForm.jsp?mode=edit&form=PMCCreateWeeklyTimeSheetForm"
			           + "&postProcessURL=../programcentral/emxProgramCentralWeeklyTimesheetUtil.jsp?mode=createTimesheet&subMode=copySelect"
			           + "&formHeader=emxProgramCentral.WeeklyTimesheet.CreateTimeSheetFromCopy&findMxLink=false"
			           + "&suiteKey=ProgramCentral&HelpMarker=emxhelptimesheetcopy&copyObjectId="+objectId;        
    %>
<script language="javascript">
<%--XSSOK--%>
	   var url = "<%=urlString%>";
       getTopWindow().showSlideInDialog(url,true);
	</script>
<% 
}
//Modified:PA4:29-Aug-2011:IR-120317V6R2012x
else if("deleteTimesheet".equalsIgnoreCase(mode)) {
    String[] strTimesheetRowId = emxGetParameterValues(request,"emxTableRowId");
    String subMode = XSSUtil.encodeURLForServer(context,emxGetParameter(request,"subMode"));
    StringList slTimesheetIds =  new StringList();
    String[] strTimesheetIds =  new String[strTimesheetRowId.length];
    WeeklyTimesheet weeklyTimesheet = null;
    for(int i = strTimesheetRowId.length-1; i >= 0; i--)
    {
        try { 
        slTimesheetIds = FrameworkUtil.split(strTimesheetRowId[i], "|");           
            String timesheetId = null;
            String paramId = null;
            //When Timesheet(s) is marked for deletion from the list of timesheets. 
            if(slTimesheetIds.size() == 2) {
                timesheetId = (String)slTimesheetIds.get(1);
                weeklyTimesheet = new WeeklyTimesheet();
                weeklyTimesheet.deleteTimesheet(context,timesheetId);
            }
            //When Project(s) is marked for deletion inside a particular Timesheet.
            else if(slTimesheetIds.size() == 3){
                paramId = (String)slTimesheetIds.get(0);
                timesheetId = (String)slTimesheetIds.get(1);
                weeklyTimesheet = new WeeklyTimesheet(timesheetId);
                weeklyTimesheet.deleteTimesheet(context,paramId);
            }
            //When Effort(s) is marked for deletion inside a particular Timesheet.
            else if(slTimesheetIds.size() == 4){
                paramId = (String)slTimesheetIds.get(1 );
                weeklyTimesheet = new WeeklyTimesheet();
                weeklyTimesheet.deleteTimesheet(context,paramId);
           }        
       
        } catch(Exception ex) {
            ex.printStackTrace();
            String errorMessage = ex.getMessage();
            %>
               <script language="javascript">
               alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
               </script>
            <% 
        }
    }  
        %>
        <script language="javascript">
        //XSSOK
	       var mode= "<%=subMode%>";
        	if(mode != "details"){
        		var weeklyTimeSheetDetailsFrame = findFrame(getTopWindow(),"PMCMyWeeklyTimeSheet");
        		//weeklyTimeSheetDetailsFrame.location.href = weeklyTimeSheetDetailsFrame.location.href;
				weeklyTimeSheetDetailsFrame.parent.location.href = weeklyTimeSheetDetailsFrame.parent.location.href;
        	}else{
        		var weeklyTimeSheetDetailsFrame = findFrame(getTopWindow(),"PMCWeeklyTimeSheetBlank");
				// replacing "persist=true" in url with reference to IR-516959-3DEXPERIENCER2019x
    			weeklyTimeSheetDetailsFrame.location.href = weeklyTimeSheetDetailsFrame.location.href.replace("persist=true","");
        	}
        </script>
        <% 
//End:PA4:29-Aug-2011:IR-120317V6R2012x  
} else if("delete".equalsIgnoreCase(mode)) {
	  String subMode = XSSUtil.encodeURLForServer(context,emxGetParameter(request,"subMode"));
    String[] strTimesheetRowId = emxGetParameterValues(request,"emxTableRowId");
    StringList slTimesheetIds =  new StringList();
    String[] strTimesheetIds =  new String[strTimesheetRowId.length];
        slTimesheetIds = FrameworkUtil.split(strTimesheetRowId[0], "|");
        strTimesheetIds[0] = (String)slTimesheetIds.get(1);
        WeeklyTimesheet weeklyTimesheet = new WeeklyTimesheet(strTimesheetIds[0]);
        try {
            weeklyTimesheet.deleteTimesheet(context,strTimesheetIds[0]);
          } catch(Exception ex) {
            ex.printStackTrace();
            String errorMessage = ex.getMessage();
            %>
               <script language="javascript">
               alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
               </script>
            <% 
        }
            %>
            <script language="javascript">
            //XSSOK
    	       var mode= "<%=subMode%>";
            	if(mode != "details"){
            		var weeklyTimeSheetDetailsFrame = findFrame(getTopWindow(),"PMCMyWeeklyTimeSheet");
            		//weeklyTimeSheetDetailsFrame.location.href = weeklyTimeSheetDetailsFrame.location.href;
    				weeklyTimeSheetDetailsFrame.parent.location.href = weeklyTimeSheetDetailsFrame.parent.location.href;
            	}else{
            		var weeklyTimeSheetDetailsFrame = findFrame(getTopWindow(),"PMCWeeklyTimeSheetBlank");
        			weeklyTimeSheetDetailsFrame.location.href = weeklyTimeSheetDetailsFrame.location.href;
            	}
            </script>
            <% 
} else if("copyPrevious".equalsIgnoreCase(mode)){
    try{
	Person p = new Person(PersonUtil.getPersonObjectID(context));
    WeeklyTimesheet wt = new WeeklyTimesheet();
    wt.copyPrevious(context,p);
    %>
	<script language="javascript">
        parent.window.parent.frames[0].location.href = parent.window.parent.frames[0].location.href;
    </script>
<% 
    }catch(Exception ex) {
        String errorMessage = ex.getMessage();
        %>
			<script language="javascript">
          		 alert("<%=XSSUtil.encodeForJavaScript(context,errorMessage)%>");
           </script>
<% 
    }
}
else if("displayTimesheetTasks".equalsIgnoreCase(mode)){
	String timesheetId = emxGetParameter(request,"objectId");
	DomainObject objTimesheet = DomainObject.newInstance(context,timesheetId);
	StringList select = new StringList();
	String ownerSelect = "to["+ProgramCentralConstants.RELATIONSHIP_WEEKLY_TIMESHEET+"].from.id";
	select.add(ownerSelect);
	select.add(ProgramCentralConstants.SELECT_CURRENT);
	Map timesheetInfo = objTimesheet.getInfo(context, select);
	String strOwner = (String)timesheetInfo.get(ownerSelect);
	String state = (String)timesheetInfo.get(ProgramCentralConstants.SELECT_CURRENT);
	
	//String strOwner = objTimesheet.getInfo(context,"to["+ProgramCentralConstants.RELATIONSHIP_WEEKLY_TIMESHEET+"].from.id");
    String strURL    = "../common/emxIndentedTable.jsp?tableMenu=PMCWeeklyTimesheetViews&jsTreeID=root&table=PMCWeeklyTimeSheetView&header=emxProgramCentral.WeeklyTimesheet.MyWeeklyTimeSheet&SuiteDirectory=programcentral&expandProgram=emxWeeklyTimeSheet:displayTimesheetTasks&StringResourceFileId=emxProgramCentralStringResource&suiteKey=ProgramCentral&HelpMarker=emxhelptimesheetview&multiColumnSort=false&customize=true&massPromoteDemote=false&triggerValidation=false&objectCompare=false&postProcessJPO=emxWeeklyTimeSheet:postProcessRefresh&rowGrouping=false&displayView=details&showPageURLIcon=false&objectId=";
    strURL = strURL + XSSUtil.encodeForURL(context,timesheetId);
    strURL = strURL + "&parentOID=" +XSSUtil.encodeForURL(context,timesheetId);
	//if(ProgramCentralConstants.STATE_EFFORT_EXISTS.equals(state) ||
			//ProgramCentralConstants.STATE_EFFORT_REJECTED.equals(state)){
		strURL = strURL + "&editLink=true";
		strURL = strURL + "&toolbar=PMCWeeklyTimeSheetToolBarActions";
	//}

    %>
	 <script language="javascript">
      <%--XSSOK--%>
 var url = "<%=strURL%>";
       var weeklyTimeSheetDetailsFrame = findFrame(getTopWindow(),"PMCWeeklyTimeSheetBlank");
       if(weeklyTimeSheetDetailsFrame != null)
    	   weeklyTimeSheetDetailsFrame.location.href = url;
       else
    	   window.location.href = url;       
     </script>
<% 
}else if("Blank".equalsIgnoreCase(mode)){
	String strEmptyReportMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.WeeklyTimesheet.EmptyTimeSheetMessage", context.getSession().getLanguage());
	 %>
	<script type="text/javascript"> </script>
	<div class="list" align = "center"><%=strEmptyReportMsg%></div>
	<%
}else if("displayTimesheetTasksForApprover".equalsIgnoreCase(mode)){
    String timesheetId = emxGetParameter(request,"objectId");

	DomainObject domainObject = DomainObject.newInstance(context, timesheetId);
    String strTimeSheetName = domainObject.getInfo(context, domainObject.SELECT_NAME);
    timesheetId = XSSUtil.encodeURLForServer(context,timesheetId);
    DomainObject objTimesheet = DomainObject.newInstance(context,timesheetId);
    String strOwner = objTimesheet.getInfo(context,"to["+ProgramCentralConstants.RELATIONSHIP_WEEKLY_TIMESHEET+"].from.id");
    String strURL    = "../common/emxIndentedTable.jsp?tableMenu=PMCWeeklyTimesheetApproverViews&jsTreeID=root&editLink=true&toolbar=PMCWeeklyTimeSheetEffortApproveToolBar&header=emxProgramCentral.WeeklyTimesheet.WeeklyTimeSheetForApproval&subHeader="+strTimeSheetName+"&SuiteDirectory=programcentral&StringResourceFileId=emxProgramCentralStringResource&suiteKey=ProgramCentral&multiColumnSort=false&customize=true&massPromoteDemote=false&triggerValidation=false&objectCompare=false&expandProgramMenu=PMCWeeklyTimeSheetApproverFilter&objectId=";
    //strURL = strURL + timesheetId;
    strURL = strURL + strOwner;
    strURL = strURL + "&parentOID=" +timesheetId;
    strURL = strURL + "&timesheetID=" + timesheetId;
    %>
     <script language="javascript">
     <%--XSSOK--%>
  var url = "<%=strURL%>";
       var weeklyTimeSheetDetailsFrame = findFrame(getTopWindow(),"PMCWeeklyTimeSheetBlank");
       if(weeklyTimeSheetDetailsFrame != null)
      	 weeklyTimeSheetDetailsFrame.location.href = url;
       else
    	   window.location.href = url;
     </script>
<% 
}
else if("addTask".equalsIgnoreCase(mode)){
    %>
    <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
    <%
    String timesheetId = emxGetParameter(request,"objectId");
    String[] strTaskRowId = emxGetParameterValues(request,"emxTableRowId");
    StringList slTaskIds =  new StringList();
     strTaskRowId = ProgramCentralUtil.parseTableRowId(context, strTaskRowId);
    StringList strSelectList = new StringList();  	;
  	strSelectList.add(DomainObject.SELECT_TYPE);
  	strSelectList.add(DomainObject.SELECT_POLICY);
  	strSelectList.add(DomainObject.SELECT_NAME);
  	strSelectList.add(DomainObject.SELECT_ID);  	
  	MapList mapList = DomainObject.getInfo(context,strTaskRowId,strSelectList);  	
  	String effortId=ProgramCentralConstants.EMPTY_STRING;  	
   	boolean flag=false;
   	boolean isAlreadyadded = false;
   	StringList alreadyAddedTasks = new StringList();
 	 String strErrMsg =ProgramCentralConstants.EMPTY_STRING;
 	 String strLanguage = context.getSession().getLanguage();
    WeeklyTimesheet weeklyTimesheet = new WeeklyTimesheet(timesheetId); 
    Person person = new Person(PersonUtil.getPersonObjectID(context));
    
    ContextUtil.startTransaction(context, true);
  	   	Iterator iterator = mapList.iterator();
  	while(iterator.hasNext())
    {
     
  		Map map = (Map) iterator.next();
     	String type = (String)map.get(DomainObject.SELECT_TYPE);     
     	String  policy = (String)map.get(DomainObject.SELECT_POLICY);
     	effortId= (String)map.get(DomainObject.SELECT_ID);
     	String  name = (String)map.get(DomainObject.SELECT_NAME);
     	 
        if(policy.equals(ProgramCentralConstants.POLICY_PROJECT_REVIEW)){
        	flag=true;      	
        	
    	}
     	if(!policy.equals(ProgramCentralConstants.POLICY_PROJECT_REVIEW)){
    	//End:08-June-2010:vf2:R210 PRG:IR-054840
        try {
            weeklyTimesheet.addEffort(context,effortId);
        } catch(Exception ex) {
            ex.printStackTrace();
            if(ex.getMessage().contains("Already added")){
            	isAlreadyadded = true;
            	alreadyAddedTasks.add(name);
            }
        }
     		
     	}
     	}    
      		
 /* if(flag==true)
   {	  	 
	 strErrMsg = strErrMsg.equalsIgnoreCase("")? strErrMsg : "\n"+strErrMsg;
	 strErrMsg = strErrMsg + EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
				"emxProgramCentral.WeeklyTimesheet.AddEfforts", strLanguage); 		
    } */
   	 if(isAlreadyadded==true){
	  	ContextUtil.abortTransaction(context);
   	String addedTaskErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral","emxProgramCentral.WeeklyTimesheet.TaskAlreadyAddedAlert", strLanguage);
   	addedTaskErrMsg = addedTaskErrMsg+ ":" + alreadyAddedTasks.join(",");
   	strErrMsg = strErrMsg + addedTaskErrMsg;
   	 }else{
   		 ContextUtil.commitTransaction(context);
   	 }
   	 
   	 if(!strErrMsg.equalsIgnoreCase("")){
   		 
   	 %> 
        <script language="javascript">
        alert("<%=strErrMsg%>");
		getTopWindow().location.href=getTopWindow().location.href;
        </script>
     <%    
    }else{
	 
		%>
		<script language="javascript">
			//var weeklyTimeSheetDetailsFrame = findFrame(getTopWindow().window.getWindowOpener().parent,"PMCWeeklyTimeSheetBlank");
			//weeklyTimeSheetDetailsFrame.location.href = weeklyTimeSheetDetailsFrame.location.href;
			// replacing "persist=true" in url with reference to IR-516959-3DEXPERIENCER2019x
			getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href.replace("persist=true","");
			getTopWindow().close(); 
		</script>
		<% 
	}
}
else if("preSubmitTimesheet".equalsIgnoreCase(mode)){
    String timesheetId = emxGetParameter(request,"objectId");
    StringBuffer sberrormsg = new StringBuffer();
    String errormsg = "";
    String[] args = (String[]) JPO.packArgs(timesheetId);
    StringList returnVal  = (StringList) JPO.invoke(context,
                                     "emxWeeklyTimeSheet", 
                                     null,
                                     "getTaskWithZeroEffort", 
                                     args,
                                      StringList.class);
    if(returnVal.size()==1 && ((String)returnVal.get(0)).equalsIgnoreCase("AllTaskWithZeroEffort")){
    	%>
        <script language="javascript">
        var errormmsg = "<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
		"emxProgramCentral.WeeklyTimesheet.AllEffortWithZeroTotal", language)%>";
        alert(errormmsg);
        getTopWindow().window.closeWindow();
         </script>
         <% 
    }else{
    if(returnVal.size()>0){
    	for(int i=0;i<returnVal.size();i++){
    		String strTask = (String)returnVal.get(i);
    		sberrormsg.append(strTask);
    		if(i!=returnVal.size()-1){
    			sberrormsg.append(",");
    		}
    	}
    	errormsg = sberrormsg.toString();
    	%>
        <script language="javascript">
        var errormsg0 =  '<%=XSSUtil.encodeForJavaScript(context,errormsg)%>';
        var errormmsg = "<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
        		"emxProgramCentral.WeeklyTimesheet.EffortWithZeroTotal", language)%>";
        alert(errormmsg+"\n"+errormsg0);
        
         </script>
         <% 
    }
    %>
    <script language="javascript">
       
           var timesheetId = '<%=XSSUtil.encodeForJavaScript(context,timesheetId)%>';           
           var vURL="../programcentral/emxProgramCentralWeeklyTimesheetUtil.jsp?mode=submitTimesheet&objectId="+timesheetId;
           parent.window.parent.frames[1].location.href = vURL;    
       
    </script>
    <% 
    }
}
else if("submitTimesheet".equalsIgnoreCase(mode)){
	String timesheetId = emxGetParameter(request,"objectId");
	WeeklyTimesheet wt = new WeeklyTimesheet(timesheetId);
	//Added:27-Oct-2010:vf2:R211 PRG:IR-075628
	//if(wt.checkWeekEndingDate(context)){
		%>
	    <script language="javascript">
		//var errormmsg = "<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
			"emxProgramCentral.WeeklyTimesheet.FutureDateSubmissionAlert", language)%>";
		 </script>
		 <% 
	//}else{
	%>
    <script language="javascript">
       var confirmmsg = "<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
		"emxProgramCentral.WeeklyTimesheet.SubmitAlert", language)%>";
       if(confirm(confirmmsg)){
    	   var timesheetId = '<%=XSSUtil.encodeForJavaScript(context,timesheetId)%>';
    	   var vURL="../programcentral/emxProgramCentralWeeklyTimesheetUtil.jsp?mode=processTimesheetSubmission&timesheetId="+timesheetId;
    	   var weeklyTimeSheetDetailsFrame = findFrame(getTopWindow(),"PMCMyWeeklyTimeSheet");
        	weeklyTimeSheetDetailsFrame.location.href = vURL;   
       }
    </script>
<% 
//}
//End:27-Oct-2010:vf2:R211 PRG:IR-075628
}
else if("processRejection".equalsIgnoreCase(mode) || "processApproval".equalsIgnoreCase(mode)){
    String strTimesheetRowIds = emxGetParameter(request,"strTimesheetRowId");
    String strComments = emxGetParameter(request,"Comments");
    String approverType = emxGetParameter(request,"isApproverType");
    StringTokenizer st = new StringTokenizer(strTimesheetRowIds, ",");
    boolean isApproverType = false;
    boolean isEffortId = false;
    if("true".equals(approverType)){
    	isApproverType=true;
    }
    try {
	while(st.hasMoreElements()){       
        String objectId = st.nextToken();
        DomainObject dObj = DomainObject.newInstance(context,objectId);     
        String strType = dObj.getInfo(context,DomainConstants.SELECT_TYPE);
        if("Effort".equals(strType)){
            isEffortId = true;
        }		
    	WeeklyTimesheet wt = new WeeklyTimesheet(objectId); 	
    	wt.setApproverComments(strComments);
    	if("processRejection".equalsIgnoreCase(mode)){
    		wt.reject(context);
        }
    	if("processApproval".equalsIgnoreCase(mode)){
            wt.approve(context);
        }  	
    }
    %>
    <script language="javascript"> 
   <%--XSSOK--%>
 var isEffortId = <%= isEffortId%>;
   <%--XSSOK--%> 
var isApproverType = <%=isApproverType%>;
    if(isApproverType == false && isEffortId == true){    	       
    	getTopWindow().getWindowOpener().parent.getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.getWindowOpener().parent.location.href;
        getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href; 
        //Added:30-Sep-2010:vf2:R2012
        getTopWindow().close();
        //End:30-Sep-2010:vf2:R2012
    } else if(isApproverType == true){
    	var detailsDisplayFrame = findFrame(getTopWindow().getWindowOpener().parent.getTopWindow(), "PMCWeeklyTimeSheetApprove");
    	
    	var timeSheetListURL  = "../common/emxIndentedTable.jsp?toolbar=PMCWeeklyTimeSheetApproveToolBar&table=PMCWeeklyTimeSheetApprover&selection=multiple&program=emxWeeklyTimeSheet:getSubmittedTimesheetForApprover,emxWeeklyTimeSheet:getApprovedTimesheetForApprover&programLabel=emxProgramCentral.WeeklyTimesheet.submitted,emxProgramCentral.WeeklyTimesheet.Rejected&editLink=true&multiColumnSort=false&customize=true&sortColumnName=Week&sortDirection=descending&showClipboard=false&autoFilter=false&showPageURLIcon=false&freezePane=TimeSheet&objectCompare=false&StringResourceFileId=emxProgramCentralStringResource";
    	var blankURL = "../programcentral/emxProgramCentralWeeklyTimesheetUtil.jsp?mode=Blank";
    	detailsDisplayFrame.location.href=timeSheetListURL; 
    	getTopWindow().getWindowOpener().parent.location.href =blankURL;
        //Added:30-Sep-2010:vf2:R2012
        getTopWindow().close();
        //End:30-Sep-2010:vf2:R2012
    } else {        
          getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
        getTopWindow().close();
    }
    </script>
    <%  	
    } catch(Exception e){
        String errorMessage = e.getMessage();
        String strMessage = errorMessage.substring(errorMessage.lastIndexOf(":")+ 2,errorMessage.length());  
        %> 
           <script language="javascript">
           alert("<%=XSSUtil.encodeForJavaScript(context,strMessage.trim())%>");
           </script>
        <% 
    } 	   
}
else if("processTimesheetSubmission".equalsIgnoreCase(mode)){
	String timesheetId = emxGetParameter(request,"timesheetId");
	timesheetId = XSSUtil.encodeURLForServer(context,timesheetId);
	String strUrl = null;
	try{   
    WeeklyTimesheet wt = new WeeklyTimesheet(timesheetId);
    strUrl ="../common/emxIndentedTable.jsp?tableMenu=PMCWeeklyTimesheetViews&jsTreeID=root&editLink=true"+
    "&table=PMCWeeklyTimeSheetView&toolbar=PMCWeeklyTimesheetViewToolbar&header=emxProgramCentral.WeeklyTimesheet.MyWeeklyTimeSheet"+
    "&SuiteDirectory=programcentral&expandProgram=emxWeeklyTimeSheet:displayTimesheetTasks&StringResourceFileId=emxProgramCentralStringResource"+
    "&suiteKey=ProgramCentral&multiColumnSort=false&customize=true&massPromoteDemote=false&triggerValidation=false&objectCompare=false&objectId="+timesheetId;
    strUrl += "&parentOID="+timesheetId;      
    wt.submit(context);
    %>
    <script language="javascript">
  <%--XSSOK--%>
  var strUrl = "<%=strUrl%>";
    parent.window.parent.frames[0].location.href = parent.window.parent.frames[0].location.href;
    </script>
    <%  
	}catch(Exception ex) {
        String errorMessage = ex.getMessage(); 
        String strMessage = errorMessage.substring(errorMessage.lastIndexOf(":")+ 2,errorMessage.length());       
        %> 
           <script language="javascript">
         <%--XSSOK--%> 
 var strURL = "<%=strUrl%>";
           getTopWindow().window.location.href = strURL;  
           alert("<%=XSSUtil.encodeForJavaScript(context,strMessage.trim())%>");
           </script>         
        <% 
    }
}
else if("approve".equalsIgnoreCase(mode)) {
   String[] strTimesheetRowId = emxGetParameterValues(request,"emxTableRowId");
   String formHeader = "";
   String alertMessage = "";
   mode = "processApproval";
   formHeader = "emxProgramCentral.WeeklyTimesheet.ApproverComments";
   alertMessage = "emxProgramCentral.WeeklyTimesheet.ApproveEffortAlert";
   if (strTimesheetRowId == null
           || strTimesheetRowId.equals("")
           || strTimesheetRowId.equals("null"))
   {
	String timesheetId = emxGetParameter(request,"timesheetID");
	%>
    <script language="javascript">
        var formHeader = '<%=XSSUtil.encodeForJavaScript(context,formHeader)%>';
        confirmmsg = "<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral",alertMessage, language)%>";
        if(confirm(confirmmsg)){
        	var strTimesheetRowId = '<%=XSSUtil.encodeForJavaScript(context,timesheetId)%>';
        	var mode = '<%=XSSUtil.encodeForJavaScript(context,mode)%>';
        	var urlString = "../common/emxForm.jsp?mode=edit&form=PMCWeeklyTimeSheetApproverComment"
                + "&postProcessURL=../programcentral/emxProgramCentralWeeklyTimesheetUtil.jsp?mode="+mode
                + "&formHeader="+formHeader+"&findMxLink=false"
                + "&suiteKey=ProgramCentral&isApproverType=true&strTimesheetRowId="+strTimesheetRowId;
                
                 showModalDialog(urlString);
       }
       </script>
    <% 
   }
   else{
	   StringList slTimesheetIds =  new StringList();
	   String[] strTimesheetIds =  new String[strTimesheetRowId.length];
	   StringBuffer sbTimesheets = new StringBuffer();
	   for(int i = 0; i < strTimesheetRowId.length; i++)
       {
		    slTimesheetIds = FrameworkUtil.split(strTimesheetRowId[i], "|");
		    strTimesheetIds[i] = (String)slTimesheetIds.get(1);
		    sbTimesheets.append(strTimesheetIds[i]);
            if(i<strTimesheetRowId.length-1){
                   sbTimesheets.append(",");
            }
       }
       String strTimesheets = sbTimesheets.toString();
       if("processApproval".equalsIgnoreCase(mode)){
    	   %>
           <script language="javascript">
              strTimesheetRowId = '<%=XSSUtil.encodeForJavaScript(context,strTimesheets)%>';
              formHeader = '<%=XSSUtil.encodeForJavaScript(context,formHeader)%>';
              confirmmsg = "<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
              alertMessage, language)%>";
              if(confirm(confirmmsg)){
            	  mode = '<%=XSSUtil.encodeForJavaScript(context,mode)%>';
            	  urlString = "../common/emxForm.jsp?mode=edit&form=PMCWeeklyTimeSheetApproverComment"
                      + "&postProcessURL=../programcentral/emxProgramCentralWeeklyTimesheetUtil.jsp?mode="+mode
                      + "&formHeader="+formHeader+"&findMxLink=false"
                      + "&suiteKey=ProgramCentral&strTimesheetRowId="+strTimesheetRowId;
            	   
                    	  showModalDialog(urlString);            	  
              }
              
           </script>
           <% 
       }
    }
}
else if("reject".equalsIgnoreCase(mode)) {
   String[] strTimesheetRowId = emxGetParameterValues(request,"emxTableRowId");
   String formHeader = "";
   String alertMessage = "";
   mode = "processRejection";
   formHeader = "emxProgramCentral.WeeklyTimesheet.RejectionComments";
   alertMessage = "emxProgramCentral.WeeklyTimesheet.RejectEffortAlert";
   if (strTimesheetRowId == null
           || strTimesheetRowId.equals("")
           || strTimesheetRowId.equals("null"))
   {
    String timesheetId = emxGetParameter(request,"timesheetID");
    %>
    <script language="javascript">
        var formHeader = '<%=XSSUtil.encodeForJavaScript(context,formHeader)%>';
        confirmmsg = "<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
        alertMessage, language)%>";
        if(confirm(confirmmsg)){
            var strTimesheetRowId = '<%=XSSUtil.encodeForJavaScript(context,timesheetId)%>';
            var mode = '<%=XSSUtil.encodeForJavaScript(context,mode)%>';
            var urlString = "../common/emxForm.jsp?mode=edit&form=PMCWeeklyTimeSheetRejectionComment"
                + "&postProcessURL=../programcentral/emxProgramCentralWeeklyTimesheetUtil.jsp?mode="+mode
                + "&formHeader="+formHeader+"&findMxLink=false"
                + "&suiteKey=ProgramCentral&isApproverType=true&strTimesheetRowId="+strTimesheetRowId;
                
            showModalDialog(urlString);
       }
       </script>
    <% 
   }
   else{
       StringList slTimesheetIds =  new StringList();
       String[] strTimesheetIds =  new String[strTimesheetRowId.length];
       StringBuffer sbTimesheets = new StringBuffer();
       for(int i = 0; i < strTimesheetRowId.length; i++)
       {
            slTimesheetIds = FrameworkUtil.split(strTimesheetRowId[i], "|");
            strTimesheetIds[i] = (String)slTimesheetIds.get(1);
            sbTimesheets.append(strTimesheetIds[i]);
            if(i<strTimesheetRowId.length-1){
                   sbTimesheets.append(",");
            }
       }
       String strTimesheets = sbTimesheets.toString();
       if("processRejection".equalsIgnoreCase(mode)){
           %>
           <script language="javascript">
              strTimesheetRowId = '<%=XSSUtil.encodeForJavaScript(context,strTimesheets)%>';
              formHeader = '<%=XSSUtil.encodeForJavaScript(context,formHeader)%>';
              confirmmsg = "<%=EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
              alertMessage, language)%>";
              if(confirm(confirmmsg)){
                  mode = '<%=XSSUtil.encodeForJavaScript(context,mode)%>';
                  urlString = "../common/emxForm.jsp?mode=edit&form=PMCWeeklyTimeSheetRejectionComment"
                      + "&postProcessURL=../programcentral/emxProgramCentralWeeklyTimesheetUtil.jsp?mode="+mode
                      + "&formHeader="+formHeader+"&findMxLink=false"
                      + "&suiteKey=ProgramCentral&strTimesheetRowId="+strTimesheetRowId;
                 
               showModalDialog(urlString);  
              }
           </script>
           <% 
       }
    }
}
else if("LaborReportByPerson".equalsIgnoreCase(mode)){
	String[] strTimesheetRowId = emxGetParameterValues(request,"emxTableRowId");
	strTimesheetRowId = ProgramCentralUtil.parseTableRowId(context,strTimesheetRowId);
	StringBuffer sbTimesheets = new StringBuffer();
	String objectId = emxGetParameter(request,"objectId");
	String ContextUser = emxGetParameter(request,"ContextUser");
	if(strTimesheetRowId != null){
	for(int i = 0; i < strTimesheetRowId.length; i++)
    {
         String strTimesheetIds = (String)strTimesheetRowId[i];
         
         
         if(strTimesheetIds.contains(":")){
        	  	StringList valueList = StringUtil.split(strTimesheetIds, ":");
        	  	String personName = (String)valueList.get(2);
        	  	if(personName.contains("_PRJ")){
        	  		personName = personName.substring(0,personName.indexOf("_PRJ"));
        	  		strTimesheetIds = PersonUtil.getPersonObjectID(context, personName);
        	  	}else{
        	  		String errMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
        	  			  "emxProgramCentral.MemberTransfer.selectPerson", language);
        	  	%>
        	  	 <script language="JavaScript" type="text/javascript">
        	      alert("<%=errMsg%>");
        	      window.closeWindow();
        	      
        	     </script>
        	                               
        	  	<%
        	  	return;
        	  	}
        	  	
        	  }
         sbTimesheets.append(strTimesheetIds);
         if(i<strTimesheetRowId.length-1){
                sbTimesheets.append(",");
         }
    }
	   }
    String strTimesheets = sbTimesheets.toString();
	 %>
     <script language="javascript">
            var strTimesheetRowId = '<%=XSSUtil.encodeForJavaScript(context,strTimesheets)%>';
            var ContextUser = '<%=XSSUtil.encodeForJavaScript(context,ContextUser)%>';
            var objectId = '<%=XSSUtil.encodeForJavaScript(context,objectId)%>';
            urlString = "../common/emxForm.jsp?mode=edit&form=PMCLaborReportByPersonWebform"
                + "&postProcessURL=../programcentral/emxProgramCentralWeeklyTimesheetUtil.jsp?mode=DisplayLaborReportByPersonForPL"
                + "&formHeader=emxProgramCentral.WeeklyTimeSheetReports.PMCLaborReportByPerson&findMxLink=false"
                + "&suiteKey=ProgramCentral&HelpMarker=emxhelppersonlaborreportselection";
            urlString += "&strTimesheetRowId=" +strTimesheetRowId;
            urlString += "&objectId=" +objectId;
            urlString += "&ContextUser=" +ContextUser;
            showModalDialog(urlString,'600','400'); 
        
     </script>
     <% 
}

else if("DisplayLaborReportByPersonForPL".equalsIgnoreCase(mode)){   
    String strTimesheetRowId = emxGetParameter(request,"strTimesheetRowId");
    String YearType = emxGetParameter(request, "ReportYearBy");
    String selYear = emxGetParameter(request, "ReportingYear");
    String selTimeline = emxGetParameter(request, "DefaultTimeLineInterval");
    String objectId = emxGetParameter(request, "objectId");
    String ContextUser = emxGetParameter(request,"ContextUser");
    
    String projectState = emxGetParameter(request,"ProjectState");
    String projectOwner = emxGetParameter(request,"ProjectOwner");   
    String resourceBundle="emxProgramCentralStringResource";
    int indexOfFiscal = YearType.indexOf("Fiscal");
    boolean isFiscal = true;
    CalendarType calendarType = null;
    if(indexOfFiscal == -1)
    {
    	calendarType = CalendarType.ENGLISH;
    }
    else if(indexOfFiscal != -1)
    {
    	calendarType = CalendarType.FISCAL;
    }
    Interval interval = Helper.yearInterval(calendarType,Integer.parseInt(selYear)); 
    Date startDate = interval.getStartDate();
    Date endDate = interval.getEndDate();
    String[] messageValues = new String[3];
    int iDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
    java.text.DateFormat format = DateFormat.getDateInstance(iDateFormat, request.getLocale());
    String strStartDate = format.format(startDate);
    String strEndDate = format.format(endDate);        
    messageValues[0] = strStartDate;
    messageValues[1] = strEndDate;
    String subHeader = MessageUtil.getMessage(context,null,
            "emxProgramCentral.WeeklyTimeSheet.Reports.Label",
            messageValues,null,
            context.getLocale(),resourceBundle);
    if("".equals(projectState)){
    	projectState ="All";
    }   
    %>
    <script language="javascript">
           var ContextUser = '<%=XSSUtil.encodeForJavaScript(context,ContextUser)%>';
           var strTimesheetRowId = '<%=XSSUtil.encodeForJavaScript(context,strTimesheetRowId)%>';
           var objectId = '<%=XSSUtil.encodeForJavaScript(context,objectId)%>';
           var YearType = "<%=XSSUtil.encodeForJavaScript(context,YearType)%>";
           var subHeader = "<%=XSSUtil.encodeForJavaScript(context,subHeader)%>";
           var selYear = "<%=XSSUtil.encodeForJavaScript(context,selYear)%>";
           var selTimeline = "<%=XSSUtil.encodeForJavaScript(context,selTimeline)%>";
           var projectState = "<%=XSSUtil.encodeForJavaScript(context,projectState)%>";
           var projectOwner = "<%=XSSUtil.encodeForJavaScript(context,projectOwner)%>";
           var contentURL = "../common/emxIndentedTable.jsp?program=emxWeeklyTimeSheet:displayPersonForLaborReportByPerson"+
                               "&expandProgram=emxWeeklyTimeSheet:displayProjectsForLaborReportByPhase"+
                               "&table=PMCLaborReportByPerson"+
                               "&toolbar=PMCWeeklyTimeSheetReportViewFilterToolbar&freezePane=Name&selection=none"+
                               "&suiteKey=ProgramCentral&header=emxProgramCentral.WeeklyTimeSheet.PMCLaborReportInHrs"+
                               "&HelpMarker=emxhelpresourceplanlist";
           contentURL += "&strTimesheetRowId=" +strTimesheetRowId;
           contentURL += "&passFromJsp=true";
           contentURL += "&objectId=" +objectId;
           contentURL += "&subHeader=" +subHeader;
           contentURL += "&YearType=" + YearType + "&selYear=" + selYear + "&selTimeline=" + selTimeline+"&PMCWTSViewFilter="+selTimeline;
           contentURL += "&ContextUser=" +ContextUser+"&ProjectState="+projectState+"&PMCWTSProjectStateFilter="+projectState;
           contentURL += "&PMCWTSReportingYearFilter="+selYear+"&ProjectOwner="+projectOwner+"&Person=Person";
           contentURL += "&customize=true&objectCompare=false&showPageURLIcon=false&multiColumnSort=false";
           showModalDialog(contentURL,'600','400');
           //getTopWindow().window.location.href = contentURL;          
    </script>
    <% 
} else if("reportView".equalsIgnoreCase(mode)){    
    String suiteKey = emxGetParameter(request,"suiteKey");
    suiteKey = XSSUtil.encodeURLForServer(context,suiteKey);
    
    String YearType = emxGetParameter(request, "YearType");
    YearType = XSSUtil.encodeURLForServer(context,YearType);
    
    String selYear = emxGetParameter(request, "selYear");
    String Timeline = emxGetParameter(request, "Timeline"); 
    
    String PMCWTSViewFilter = emxGetParameter(request, "PMCWTSViewFilter"); 
    PMCWTSViewFilter = XSSUtil.encodeURLForServer(context,PMCWTSViewFilter); 
    	
    String objectId = emxGetParameter(request, "objectId");
    objectId = XSSUtil.encodeURLForServer(context,objectId);
    
    String emxParentIds = emxGetParameter(request, "emxParentIds");
    emxParentIds = XSSUtil.encodeURLForServer(context,emxParentIds );
    
    String person = emxGetParameter(request, "Person");
    
    String strTimesheetRowId = emxGetParameter(request, "strTimesheetRowId");
    strTimesheetRowId = XSSUtil.encodeURLForServer(context,strTimesheetRowId);
    
    String ContextUser = emxGetParameter(request, "ContextUser");
    ContextUser = XSSUtil.encodeURLForServer(context,ContextUser); 
    
    String PMCWTSReportingYearFilter = emxGetParameter(request, "PMCWTSReportingYearFilter");  
    PMCWTSReportingYearFilter = XSSUtil.encodeURLForServer(context,PMCWTSReportingYearFilter);
    
    String PMCWTSProjectStateFilter = emxGetParameter(request, "PMCWTSProjectStateFilter");
    PMCWTSProjectStateFilter = XSSUtil.encodeURLForServer(context,PMCWTSProjectStateFilter);
    
    String projectOwner = emxGetParameter(request, "ProjectOwner");
    projectOwner = XSSUtil.encodeURLForServer(context,projectOwner);
    
    String selectedProgram = emxGetParameter(request, "selectedProgram");
    selectedProgram = XSSUtil.encodeURLForServer(context,selectedProgram);

    String resourceBundle="emxProgramCentralStringResource";
    
    String strURL = null;
    int indexOfFiscal = YearType.indexOf("Fiscal");
    boolean isFiscal = true;
    CalendarType calendarType = null;
    if(indexOfFiscal == -1)
    {
        calendarType = CalendarType.ENGLISH;
    }
    else if(indexOfFiscal != -1)
    {
        calendarType = CalendarType.FISCAL;
    }
    Interval interval = Helper.yearInterval(calendarType,Integer.parseInt(selYear)); 
    Date startDate = interval.getStartDate();
    Date endDate = interval.getEndDate();
    //  SimpleDateFormat sdf;
    //  sdf = new SimpleDateFormat("dd MMM yyyy");
    //  String strStartDate = sdf.format(startDate);
    //  String strEndDate = sdf.format(endDate); 
    
    int iDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
    java.text.DateFormat format = DateFormat.getDateInstance(iDateFormat, request.getLocale());
    
    String strStartDate = format.format(startDate);
    String strEndDate = format.format(endDate);
    
    String[] messageValues = new String[3];
    messageValues[0] = strStartDate;
    messageValues[1] = strEndDate;
    String subHeader = MessageUtil.getMessage(context,null,
            "emxProgramCentral.WeeklyTimeSheet.Reports.Label",
            messageValues,null,
            context.getLocale(),resourceBundle);
    String encodedSubHeader = FrameworkUtil.encodeURL(subHeader);
    if("Person".equals(person)){
        strURL = "../common/emxIndentedTable.jsp?program=emxWeeklyTimeSheet:displayPersonForLaborReportByPerson"+
        "&expandProgram=emxWeeklyTimeSheet:displayProjectsForLaborReportByPhase"+
        "&table=PMCLaborReportByPerson"+
        "&toolbar=PMCWeeklyTimeSheetReportViewFilterToolbar&freezePane=Name&selection=none"+
        "&suiteKey=ProgramCentral&header=emxProgramCentral.WeeklyTimeSheet.PMCLaborReportInHrs"+
        "&HelpMarker=emxhelpresourceplanlist";
        strURL += "&strTimesheetRowId=" +XSSUtil.encodeURLForServer(context,strTimesheetRowId);
        strURL += "&passFromJsp=true";
        strURL += "&objectId=" +XSSUtil.encodeURLForServer(context,objectId);
        strURL += "&YearType=" + YearType + "&selYear=" + PMCWTSReportingYearFilter + "&selTimeline=" + PMCWTSViewFilter + "&PMCWTSViewFilter=" + PMCWTSViewFilter;       
        strURL += "&PMCWTSReportingYearFilter="+PMCWTSReportingYearFilter+"&PMCWTSProjectStateFilter="+ PMCWTSProjectStateFilter +"&ProjectState="+ PMCWTSProjectStateFilter;
        strURL += "&ContextUser=" +ContextUser+"&ProjectOwner="+projectOwner;
        strURL += "&customize=true&objectCompare=false&showPageURLIcon=false&multiColumnSort=false";
        strURL += "&Person=Person";
        strURL += "&subHeader=" +encodedSubHeader;
    } else {        
        strURL = "../common/emxIndentedTable.jsp?program=emxWeeklyTimeSheet:getMembershipChildLaborReport&expandProgramMenu=PMCWTSLaborReportMenu&table=PMCLaborReport&toolbar=PMCWeeklyTimeSheetReportViewFilterToolbarMenu&freezePane=Name&selection=multiple&suiteKey=ProgramCentral&header=emxProgramCentral.WeeklyTimeSheet.PMCLaborReportInHrsTable.Heading&HelpMarker=emxhelpresourceplanlist"; 
        strURL += "&passFromJsp=true"+"&suiteKey="+suiteKey;
        strURL += "&emxTableRowId=" +emxParentIds + "&selectedProgram="+selectedProgram;
        strURL += "&YearType=" + YearType + "&selYear=" + PMCWTSReportingYearFilter + "&selTimeline=" + PMCWTSViewFilter + "&PMCWTSViewFilter=" +PMCWTSViewFilter + "&PMCWTSReportingYearFilter="+PMCWTSReportingYearFilter;  
        strURL += "&customize=true&objectCompare=false&showPageURLIcon=false&multiColumnSort=false";
        strURL += "&subHeader=" +encodedSubHeader;
    }   
    %>
    <script language="javascript">  
    <%--XSSOK--%>
var strURL = '<%=strURL%>';
    getTopWindow().window.location.href = strURL;
    </script>
    <% 
}else if("gotoWeek".equalsIgnoreCase(mode)){
	   String selectedDate = (String) emxGetParameter(request, "PMCDatePickerCommand");
	   //String strURL = "../common/emxIndentedTable.jsp?table=PMCActualEffortsTable&editLink=true&toolbar=PMCActualEffortToolbar&program=emxTask:getAssignedWBSTask&freezePane=Name";
	   String strURL = "../common/emxIndentedTable.jsp?header=emxProgramCentral.Common.Assignments";
	   Enumeration eParam = request.getParameterNames();
	    StringBuffer url = new StringBuffer();

	   int cnt = 0;
	   while(eParam.hasMoreElements()){
	    	String param = (String)eParam.nextElement();
  			String value = (String)emxGetParameter(request, param);	
        	value = XSSUtil.encodeURLForServer(context, value);
        	url.append("&" + param + "=" + value);
		}
	   strURL = strURL + url.toString(); 
	   strURL = strURL + "&selectedDate=" + selectedDate;
		
		%>
		   	<script language="javascript">
	<%--XSSOK--%>			var strUrl = "<%=strURL%>";
				 parent.window.location.href = strUrl;
	   		</script> 
		 <%
 }else if("submitEffortsAgainstAssignments".equalsIgnoreCase(mode)){
	 String message = ProgramCentralConstants.EMPTY_STRING;
	 String strSelectedDate = (String) emxGetParameter(request, "PMCDatePickerCommand");
	 Date selectedDate = null;
	   String timezone = emxGetParameter(request, "timeZone");
	   if(ProgramCentralUtil.isNullString(strSelectedDate)){
		   selectedDate = Calendar.getInstance().getTime();
 	   }else{
		   String formattedInputDate = eMatrixDateFormat.getFormattedInputDate(context, strSelectedDate,
				   Double.parseDouble(timezone), context.getLocale());
		   selectedDate = eMatrixDateFormat.getJavaDate(formattedInputDate);
 	   }
	   WeeklyTimesheet wt = new WeeklyTimesheet();
	   String timesheetName = wt.getTimesheetNameByDate(context, selectedDate);
	   try{
		   WeeklyTimesheet timesheet = wt.getTimesheetByName(context, timesheetName);
		   if(null==timesheet){
				message = ProgramCentralUtil.getPMCI18nString(context, "emxProgramCentral.WeeklyTimesheet.AllEffortWithZeroTotal", 
						context.getLocale().getLanguage());
				%>
			   	<script language="javascript">
					var strMessage = "<%=XSSUtil.encodeForJavaScript(context,message)%>";
			   		alert(strMessage);						
			   	</script> 
			 	<%
		   }else{
			   String state = timesheet.getInfo(context, ProgramCentralConstants.SELECT_CURRENT);
			   //If timesheet is created and in Exists or Rejected state, submit
			   if(ProgramCentralConstants.STATE_EFFORT_EXISTS.equals(state)
						|| ProgramCentralConstants.STATE_EFFORT_REJECTED.equals(state)){
				   timesheet.submit(context);
				   message = ProgramCentralUtil.getPMCI18nString(context, 
						   "emxProgramCentral.WeeklyTimesheet.Notice.EffortSubmitted", 
						   context.getSession().getLanguage());
				%>
				   	<script language="javascript">
						var strMessage = "<%=XSSUtil.encodeForJavaScript(context,message)%>";
				   		alert(strMessage);
						window.parent.location.href = window.parent.location.href;
 				   	</script> 
				 <%
			   }else{
				   message = ProgramCentralUtil.getPMCI18nString(context, 
						   "emxProgramCentral.WeeklyTimesheet.Notice.CouldntPerformSubmission", 
						   context.getSession().getLanguage());
					%>
				   	<script language="javascript">
						var strMessage = "<%=XSSUtil.encodeForJavaScript(context,message)%>";
				   		alert(strMessage);						
				   	</script> 
				 	<%
			   }
		   }
	   }catch(Exception e){
		   throw e;
	   }
}else if("PMCWeeklyTimesheetAddTask".equalsIgnoreCase(mode)){
        String addTaskURL = "../common/emxIndentedTable.jsp?table=PMCTimeSheetSearchAddTask&selection=multiple&header=emxProgramCentral.Common.Search&program=emxWeeklyTimeSheet:getAssignedTasks&hideHeader=true&suiteKey=ProgramCentral&cancelLabel=emxProgramCentral.Common.Close&relationship=relationship_Subtask&direction=from&submitURL=../programcentral/emxProgramCentralWeeklyTimesheetUtil.jsp?mode=addTask&Export=false&showClipboard=false&showPageURLIcon=false&triggerValidation=false&massPromoteDemote=false&displayView=details&suiteKey=ProgramCentral&StringResourceFileId=emxProgramCentralStringResource";
		Enumeration requestParams = emxGetParameterNames(request);
	  	StringBuilder urlParameters = new StringBuilder();
     		
	  	if(requestParams != null){
		  while(requestParams.hasMoreElements()){
    		  String param = (String)requestParams.nextElement();  
    		  String value = emxGetParameter(request,param);
    		  urlParameters.append("&"+param);
    		  urlParameters.append("="+value);
		  }
		  addTaskURL = addTaskURL + urlParameters.toString();
	  	}
%>
	<script language="javascript" type="text/javaScript">
	 var strUrl = "<%=addTaskURL%>";
	 //document.location.href = strUrl;	
	 showModalDialog(strUrl, "812", "700", "true", "popup");	
	</script>
<%
	}
%>
