<%--  emxProgramCentralAutomaticAssignmentProcess.jsp

  Views the assignees of the given task

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
--%>

<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%
  com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
  String objectId        = (String) emxGetParameter(request, "objectId");
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String timeStamp  = emxGetParameter(request, "timeStamp");

  HashMap hmChange = new HashMap();
  MapList mlChanges = new MapList();
  String sOwnerSelected = "";
  String sOwnerOriginal = "";
  String sAssigneeSelected = "";
  String sAssigneeOriginal = "";
  String sAssigneePercentAllocation = "";
  String sAssigneeOriginalPercentAllocation = "";
  String name;
  String sAssigneeRelID = "";
  
  try {
    ContextUtil.startTransaction( context, true );

    // Get all parameters and parse into owner & assignee changes
    for(Enumeration names = emxGetParameterNames(request);names.hasMoreElements();) {

        name = (String) names.nextElement();
        hmChange = new HashMap();

        if ( name.indexOf( "owner~") == 0 ) {
            //  Gather owner changes
            // Get value and compare it to ownerorig~ parameter
            sOwnerSelected = emxGetParameter( request, name );
            sOwnerOriginal = emxGetParameter( request, "ownerorig~" + name.substring( 6 ) );
            sAssigneePercentAllocation = emxGetParameter( request, "PA~" + name.substring( 9 ) );

            if ( sOwnerSelected != null && !sOwnerSelected.equals( sOwnerOriginal ) ) {
                hmChange.put( "CHANGE_TYPE", "NEW_OWNER" );
                hmChange.put( "TASK_ID", name.substring( 6 ) );
                hmChange.put( "PERSON_NAME", sOwnerSelected ) ;
                hmChange.put( "PERSON_PERCENTALLOCATION", sAssigneePercentAllocation ) ;
            }

        } else if ( name.indexOf( "taskorig~" ) == 0 ) {
            // Gather task assignees that have slotted for being removed
            sAssigneeOriginal = emxGetParameter( request, name );
            sAssigneeSelected = emxGetParameter( request, "task~" + name.substring( 9 ) );
            sAssigneePercentAllocation = emxGetParameter( request, "PA~" + name.substring( 9 ) );
            sAssigneeRelID = emxGetParameter( request, "PAorigId~" + name.substring( 9 ) );
            sAssigneeOriginalPercentAllocation = emxGetParameter( request, "PAorigValue~" + name.substring( 9 ) );
             
            if ( ( sAssigneeOriginal != null && sAssigneeOriginal.equals( "yes" ) ) && ( sAssigneeSelected == null || sAssigneeSelected.equals( "" ) ) ) {
                hmChange.put( "CHANGE_TYPE", "ASSIGNEE_REMOVED" );
                hmChange.put( "TASK_ID", name.substring( 9, name.lastIndexOf( "~" ) ) );
                hmChange.put( "PERSON_ID", name.substring( name.lastIndexOf( "~" )+1 ) ) ;
                hmChange.put( "PERSON_PERCENTALLOCATION", sAssigneePercentAllocation ) ;
            } else if ( ( sAssigneeOriginal != null && sAssigneeOriginal.equals( "no" ) ) && ( sAssigneeSelected != null && !sAssigneeSelected.equals( "" ) ) ) {
                hmChange.put( "CHANGE_TYPE", "ASSIGNEE_ADDED" );
                hmChange.put( "TASK_ID", name.substring( 9, name.lastIndexOf( "~" ) ) );
                hmChange.put( "PERSON_ID", sAssigneeSelected ) ;
                hmChange.put( "PERSON_PERCENTALLOCATION", sAssigneePercentAllocation ) ;
            } else if ((sAssigneeOriginalPercentAllocation != null) && (!sAssigneeOriginalPercentAllocation.equals(sAssigneePercentAllocation))){
                hmChange.put( "CHANGE_TYPE", "ASSIGNEE_PERCENT_CHANGED" );
                hmChange.put( "TASK_ID", name.substring( 9, name.lastIndexOf( "~" ) ) );
                hmChange.put( "PERSON_ID", sAssigneeSelected ) ;
                hmChange.put( "PERSON_PERCENTALLOCATION", sAssigneePercentAllocation ) ;
                hmChange.put( "PERSON_RELTASKID", sAssigneeRelID ) ;
            }

        }

        if ( hmChange != null && !hmChange.isEmpty() ) mlChanges.add( hmChange );
    }

    HashMap hashmap = new HashMap(); 
    hashmap.put("Changes", mlChanges);

    String as[] = JPO.packArgs(hashmap);
    String initArgs[] = new String[] { objectId };
	JPO.invoke(context, "emxTaskBase", initArgs, "applyMassAssignment", as);

    ContextUtil.commitTransaction( context );

  } catch (Exception e) {
    ContextUtil.abortTransaction( context );
    throw e;
  }
%>

<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
  <!-- hide JavaScript from non-JavaScript browsers
  var topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "PMCWBS");  
  if(topFrame==null){
  var topFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow().getTopWindow().getWindowOpener().getTopWindow(), "PMCWBS");  
  }
  topFrame.emxEditableTable.refreshStructureWithOutSort();
    parent.window.closeWindow();
  //Stop hiding here -->//]]>
  </script>
</html>
