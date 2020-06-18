<%--  emxProgramCentralDependencyProcess.jsp

  Performs the action at add a dependency to a task and edit a dependency

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralDependencyProcess.jsp.rca 1.24 Tue Oct 28 22:59:43 2008 przemek Experimental przemek $";
--%>

<%@ include file = "./emxProgramGlobals2.inc"%>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "./emxPopupSelectUtil.inc"%>
<emxUtil:localize id="i18nId" bundle="emxProgramCentralStringResource" locale='<%= request.getHeader("Accept-Language") %>'/>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%
  String popup       = (String) emxGetParameter(request, "popup");
  String timeStamp = emxGetParameter(request, "timeStamp");
  String fromPage = (String) emxGetParameter(request, "fromPage");
  String Mode       = (String) emxGetParameter(request, "mode");
  String busId       = (String) emxGetParameter(request, "busId");
  String rootNodeObjectId = (String) session.getAttribute("rootObjectId");
  session.removeAttribute("rootNodeObjectId");
  rootNodeObjectId = XSSUtil.encodeURLForServer(context, rootNodeObjectId);
  String unitTime =DomainConstants.EMPTY_STRING;
  String sAttributeValue = DomainConstants.EMPTY_STRING;
  String prjId = DomainConstants.EMPTY_STRING;

  String tableName = (String) emxGetParameter(request, "table");
  String strUIType = emxGetParameter( request, "uiType" );
  if(strUIType == null || "null".equalsIgnoreCase(strUIType))
  {
      strUIType = DomainObject.EMPTY_STRING;
  }

  String justCleanupSession = (String) emxGetParameter(request, "justCleanupSession");
  if (justCleanupSession != null && justCleanupSession.equals("true"))
  {
     session.removeAttribute("taskAllList" + timeStamp);
  }
  else
  {
    session.removeAttribute("taskAllList" + timeStamp);

    DependencyRelationship dependency = (DependencyRelationship) DomainRelationship.newInstance(context,
                                         DomainConstants.RELATIONSHIP_DEPENDENCY);
    Task task = (Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);

    //Get the Task busId
    String[] tasks     = emxGetParameterValues(request,"selectedIds");
    busId       = (String) emxGetParameter(request, "busId");
    String[] emxTableRowIds = null;
    
        /*External Cross project Dependency*/
        //Added below code after converting depedency summary as emxTable.
        if(busId==null || "null".equalsIgnoreCase(busId) || "".equalsIgnoreCase(busId)) {
 if(!"PMCTaskDependency".equals(tableName)){
        	   busId = (String) emxGetParameter(request, "selectedTaskId");//Uma added :15648.12483.39828.47168 (SubTask-20Aug)
           }
       else{
                busId = (String) emxGetParameter(request, "objectId");
        }
 }
        if(tasks==null) {
             emxTableRowIds = emxGetParameterValues(request,"emxTableRowId");
            if(emxTableRowIds!=null) {
                tasks = new String[emxTableRowIds.length];
               StringList tasksList = new StringList();
                for(int i=0;i<emxTableRowIds.length;i++){
                 StringList slTemp = FrameworkUtil.split(emxTableRowIds[i].substring( (emxTableRowIds[i].indexOf("|"))+1 ),"|");
                       	tasksList.add(slTemp.get(0));
                }
               for(int j=0;j<emxTableRowIds.length;j++){
                   StringList slTemp1 = FrameworkUtil.split(emxTableRowIds[j].substring( (emxTableRowIds[j].indexOf("|"))+1 ),"|");
                   String parenttask = (String)slTemp1.get(1);
                          	if(tasksList.size()>1){
                          		if(tasksList.contains(parenttask)){
                          		   tasksList.remove(parenttask);
                          	   }
                          		for(int i=0; i<tasksList.size();i++){
                          			tasks[i] = (String)tasksList.get(i);	
                          		}
                          	}else{
                          		tasks[j] = (String)slTemp1.get(0);
                          	}
                  }
          
            }
        } //end of tasks==null
        if( emxTableRowIds == null && strUIType != "" && strUIType.equalsIgnoreCase("structureBrowser")){
            	%>
             	<script language="javascript" type="text/javaScript">
            	alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Common.SelectItem</emxUtil:i18nScript>");
            	</script>
            	<%
            	return;
        }
     
 
	busId = XSSUtil.encodeURLForServer(context, busId);
    task.setId(busId);
    prjId = task.getInfo(context, ProgramCentralConstants.SELECT_TASK_PROJECT_ID);
    // get the task's dependencies
    StringList busSelects = new StringList(1);
    StringList relSelects = new StringList(1);
    busSelects.add(task.SELECT_ID);
    relSelects.add(dependency.SELECT_DEPENDENCY_TYPE);
	relSelects.add(dependency.ATTRIBUTE_LAG_TIME);
    if (tasks != null ) {
      // get the number of tasks
      int numTasks          = tasks.length;
      String dependencyType = null;
      String lagTime        = null;
      HashMap modifyPredMap = new HashMap();
      HashMap addPredMap    = new HashMap();
      String strDurationKeyword = null;
      Double roundUPLagTime =0.0;

      // start a write transaction and lock business object
      task.startTransaction(context, true);
      try {
        for (int i=0; numTasks>i; i++) {
          if(isWin9x) {
            dependencyType = (String) emxGetParameter(request, "textfield" + tasks[i].replace('.','_') + "_value");
            lagTime        = (String) emxGetParameter(request, "lag_" + tasks[i]);
            //below changes is done for rounding up lagTime.
            roundUPLagTime = Double.valueOf(lagTime);
            roundUPLagTime = (double) Math.round(roundUPLagTime * 100)/100 ;
            lagTime         =roundUPLagTime.toString();
            
			unitTime        = (String) emxGetParameter(request, "unit_" + tasks[i]);
			strDurationKeyword = (String) emxGetParameter(request, "durationKeyword_" + tasks[i]);
          } else {
            dependencyType = (String) emxGetParameter(request, tasks[i]);
            lagTime        = (String) emxGetParameter(request, "lag_" + tasks[i]);
            //below changes is done for rounding up lagTime.
            
            if(!(lagTime.isEmpty())){
            roundUPLagTime = Double.valueOf(lagTime);
            roundUPLagTime = (double) Math.round(roundUPLagTime * 100)/100 ;
            lagTime         =roundUPLagTime.toString();
            }
            unitTime        = (String) emxGetParameter(request, "unit_" + tasks[i]);
            strDurationKeyword = (String) emxGetParameter(request, "durationKeyword_" + tasks[i]);
			if(unitTime.equals("h")){
			 unitTime = " h";
			}
			else if(unitTime.equals("d")){
			unitTime = " d";
			}
				//ADDED FOR EMPTY VALUE IN SLAG TIME
				if("".equals(lagTime)){
				    lagTime="0";
				}
				//ENDS
 //Added:10-Dec-09:wqy:R209:PRG:Keyword Duration
			if(null!=strDurationKeyword && !"NotSelected".equalsIgnoreCase(strDurationKeyword))
		    {
				strDurationKeyword = strDurationKeyword.substring(0,strDurationKeyword.indexOf("|"));
		    }
			else
			{
				strDurationKeyword = DomainObject.EMPTY_STRING;
			}
 //End:R209:PRG :Keyword Duration
			DomainObject doj  =new DomainObject(tasks[i]);
			sAttributeValue=lagTime+unitTime;

          }
          boolean isAChange  = false;
          MapList predecessorList = task.getPredecessors(context, busSelects, relSelects, null);
          Iterator predecessorItr = predecessorList.iterator();
          while (predecessorItr.hasNext()) {
            Map predecessorObj = (Map) predecessorItr.next();
            // if the task on the previous page matches a dependency that is already
            // related to this task then we know we need to update so add it to the
            // update map
            if(tasks[i].equals(predecessorObj.get(task.SELECT_ID))) {
              String connectionId = (String) predecessorObj.get(dependency.SELECT_ID);
              HashMap attributes = new HashMap();
              //attributes.put(dependency.ATTRIBUTE_LAG_TIME,lagTime);
			  attributes.put(dependency.ATTRIBUTE_LAG_TIME,sAttributeValue);
              attributes.put(dependency.ATTRIBUTE_DEPENDENCY_TYPE,dependencyType);
              attributes.put(dependency.ATTRIBUTE_ESTIMATED_DURATION_KEYWORD,strDurationKeyword);
              modifyPredMap.put(connectionId,attributes);
              isAChange = true;
              break;
            }
          }
          // add a new dependency
          if(!isAChange) {
            HashMap attributes = new HashMap();
            //attributes.put(dependency.ATTRIBUTE_LAG_TIME,lagTime);
			attributes.put(dependency.ATTRIBUTE_LAG_TIME,sAttributeValue);
            attributes.put(dependency.ATTRIBUTE_DEPENDENCY_TYPE,dependencyType);
            attributes.put(dependency.ATTRIBUTE_ESTIMATED_DURATION_KEYWORD,strDurationKeyword);
            addPredMap.put(tasks[i],attributes);
          }
        } // end of for loop
        task.modifyPredecessors(context, (Map) modifyPredMap);
        task.addPredecessors(context, (Map) addPredMap, true);

        // commit the data
        ContextUtil.commitTransaction(context);

      } catch (Exception e) {
        ContextUtil.abortTransaction(context);
        session.putValue("error.message", e.getMessage());
        //%>
        //<script language="javascript" type="text/javaScript">
        //alert("<%=e.getMessage()%>");
        //</script>
        //<%
      }
    }
    //refresh proper pages
    if(popup == null) {
      popup = "false";
    }
  }

  String blStructureBrowser = "false";
  if(fromPage!=null && "StructureBrowser".equalsIgnoreCase(fromPage)){
        blStructureBrowser = "true";
  }
%>

<%@page import="com.matrixone.apps.common.DependencyRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    if(<%=popup%> == true) {
      //parent.window.getWindowOpener().parent.document.focus();
          //Modified for Bug # 341067 on 9/11/2007 - Begin
      //parent.window.getWindowOpener().parent.document.location.reload();
    // [MODIFIED ::PRG:rg6:Dec 24, 2010:IR-087209V6R2012 :R211::Start]
        //    parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;
    // [MODIFIED ::PRG:rg6:Dec 24, 2010:IR-087209V6R2012 :R211::END]
       
   // [ADDED::PRG:rg6:Dec 24, 2010:IR-087209V6R2012 :R211::Start]
          parent.window.getWindowOpener().document.location.href = parent.window.getWindowOpener().document.location.href;  
   // [END::PRG:rg6:Dec 24, 2010:IR-087209V6R2012 :R211:]       
          
          //Modified for Bug # 341067 on 9/11/2007 - End
      parent.window.closeWindow();
        } else if(<%=blStructureBrowser%> == true) {
                //parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;
                parent.window.getWindowOpener().parent.emxEditableTable.refreshStructure();
                parent.window.closeWindow();
     }else if("<%=Mode%>" == "refreshWBS"){
        var topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "PMCWBS");  
        if(topFrame==null){
			topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "PMCProjectTemplateWBS"); 
			if(topFrame==null){
				topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "PMCWhatIfExperimentStructure");	
				if(topFrame == null){
					topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
				}
			}
        }                  
        topFrame.emxEditableTable.refreshStructureWithOutSort();
        var strTaskId = '<%=busId%>'; 
        var projectId = '<%=rootNodeObjectId%>';
        var strUrl = "../common/emxPortal.jsp?portal=PMCWBSTaskDependencyPortal&showPageHeader=false;&objectId=" + strTaskId + "&projectId=" + projectId;           
        getTopWindow().window.location.href = strUrl;
    } else {
                //Modified for Bug # 341067 on 9/11/2007 - Begin
      //parent.document.location.reload();
          parent.document.location.href = parent.document.location.href;
          //Modified for Bug # 341067 on 9/11/2007 - End
    }
    // Stop hiding here -->//]]>
  </script>
</html>
