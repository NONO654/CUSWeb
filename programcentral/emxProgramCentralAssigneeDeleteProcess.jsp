<%--  emxProgramCentralAssigneeDeleteProcess.jsp

  Removes the assignees of the given task.
  
  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralAssigneeDeleteProcess.jsp.rca 1.20 Wed Oct 22 15:49:19 2008 przemek Experimental przemek $";

  Reviewed for Level III compliance by AMM 5/2/2002
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
  com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
  com.matrixone.apps.program.Risk risk = (com.matrixone.apps.program.Risk) DomainObject.newInstance(context, DomainConstants.TYPE_RISK, DomainConstants.PROGRAM);
 
  // Get task id from the request.
  String objectId   = emxGetParameter( request, "objectId");
  
  //Added:19-Feb-09:nzf:R207:PRG:Bug:368776
  String ATTRIBUTE_ORIGINATOR=(String)PropertyUtil.getSchemaProperty(context,"attribute_Originator");
    
    StringList relSel = new StringList();
    StringList busSel = new StringList(2);
    busSel.add(task.SELECT_ID );
    busSel.add("attribute["+ATTRIBUTE_ORIGINATOR+"]");
    
    DomainObject dmoObject = new DomainObject(objectId);
    dmoObject.open(context);
    MapList mlObj = dmoObject.getRelatedObjects(context,
            PropertyUtil.getSchemaProperty( context, "relationship_hasEfforts" ),
            PropertyUtil.getSchemaProperty( context, "type_Effort" ),
            busSel,
            relSel,
            false,
            true,
            (short) 1,
            null,
            null);
    Map map;
    Iterator itr;
    StringList slOrignatorsHavingEfforts = new StringList();
    
    if (mlObj != null && mlObj.size() > 0)
    {
        for (itr = mlObj.iterator(); itr.hasNext(); )
        {
            map = (Map) itr.next();
            String strOriginator = (String) map.get("attribute["+ATTRIBUTE_ORIGINATOR+"]");
            slOrignatorsHavingEfforts.add(strOriginator);
        }
    }
  //End:R207:PRG:Bug:368776
  
  String objectType = emxGetParameter( request, "type");
  String riskType = risk.TYPE_RISK;

  // Get ids to remove from the request.
  String[] people = emxGetParameterValues( request, "selectedIds");
  
  //Added:19-Feb-09:nzf:R207:PRG:Bug:368776
  DomainObject dmoPeopleNames = new DomainObject();
  StringList slSelectPpltoDelete = new StringList();
  boolean isUserRemovingHimself = false;
  String contextUser = context.getUser();
  for(int i=0;i<people.length;i++)
  {
      dmoPeopleNames = DomainObject.newInstance(context,people[i].substring(0,people[i].indexOf(",")));
      String assigneeName = dmoPeopleNames.getName(context);
      slSelectPpltoDelete.add(assigneeName);
      if(contextUser.equalsIgnoreCase(assigneeName)){
    	  isUserRemovingHimself = true;
      }
  }
  
  boolean allowDelete = true;
  String strList = "";
  StringList slPeoplehavingEfforts = new StringList();
  if(!(slOrignatorsHavingEfforts.size()==0)){
      
      for(int i=0;i<slSelectPpltoDelete.size();i++){
          String strOrign = slSelectPpltoDelete.get(i).toString();
          
          if(slOrignatorsHavingEfforts.contains(strOrign)){
              slPeoplehavingEfforts.add(strOrign);
              strList = strList+strOrign+"\\n";
          }
      }
      if(slPeoplehavingEfforts.size()>0){
          allowDelete=false;
      }else{
          allowDelete=true;
      }
  }
  //End:R207:PRG:Bug:368776
  String personId = (String) emxGetParameter(request, "personId");

  int numPeople = 0;
  if ( people != null ) {
    // get the number of people
    numPeople = people.length;
    if(objectType.equals(riskType) || objectType.equals(task.TYPE_TASK)) {

      try {
        // start a write transaction and lock business object
        risk.setId(objectId);
        risk.startTransaction(context, true);
        task.setId(objectId);

        for (int i=0; numPeople>i; i++) {
          // Loop through and remove each selected member.
          String per_id = people[i].substring(people[i].indexOf(",")+1,people[i].length());
          String tempId = people[i].substring(0,people[i].indexOf(","));
          
          //Modified forIR-060072V6R2011x
          //if(allowDelete){
              task.removeAssignee(context, per_id);
              //effort.removeEffortConnected(context,objectId,tempId);              
          //}else{
              //i18nNow i18n = new i18nNow();
              //String strLanguage = context.getSession().getLanguage();
              //String strErrorMsg = i18n.GetString("emxProgramCentralStringResource",strLanguage,"emxProgramCentral.TaskAssigneEffortDeletionPrevention");
              //MqlUtil.mqlCommand(context, "Notice " + strErrorMsg+"\\n\\n"+strList);
              //break;
          //}
          //End
        }//ends for

        // commit the data
        ContextUtil.commitTransaction(context);
      } catch (Exception e) {
        ContextUtil.abortTransaction(context);
        throw e;
      }//ends catch

    } else {

      try {
        // start a write transaction and lock business object
        task.setId(objectId);
        task.startTransaction(context, true);

        for (int i=0; numPeople>i; i++) {
          // Loop through and remove each selected member.
          task.removeAssignee(context, people[i].substring(people[i].indexOf(",")+1,people[i].length()));
        }//ends for

  // commit the data
        ContextUtil.commitTransaction(context);
      } catch (Exception e) {
        ContextUtil.abortTransaction(context);
        throw e;
      }//ends catch

    }//ends else
  }//ends if
%>

<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers

    var tree = getTopWindow().objDetailsTree;
    var structTree = getTopWindow().objStructureTree;

    if(tree == null) {
      parent.document.location.reload();
    } else if(structTree != null){ // [MODIFIED::PRG:rg6:Dec 23,2010:IR-060464V6R2012 :R211::Causing refresh issue for remove assignee command in the assignee category of task]
<%
      //Loop through all ids passed in for delete and remove them from the navigation tree
     if ( people != null ) {
       for (int i=0; numPeople>i; i++) {
         // Loop through and remove each selected member.
         String tempId = people[i].substring(0,people[i].indexOf(","));
%>
         tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,tempId)%>", false);
         structTree.deleteObject("<%=XSSUtil.encodeForJavaScript(context,tempId)%>",false);
<%
       } //ends for
     }//ends if
%>
      
    }//ends else
<%
if(isUserRemovingHimself && objectType.equals(task.TYPE_TASK)) {
%>
	javascript:getTopWindow().bclist.goBack();
<%
}  else {
%>
	parent.document.location.href = parent.document.location.href;
<%
}
%>
   // parent.document.location.reload();
   //Modified for Bug#340465 on 08/27/2007 - Start
//parent.document.location.href = parent.document.location.href;
   //Modified for Bug#340465 on 08/27/2007 - End
    // Stop hiding here -->//]]>
  </script>
</html>
