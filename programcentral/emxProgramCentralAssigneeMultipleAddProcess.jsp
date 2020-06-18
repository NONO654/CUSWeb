<%--  emxProgramCentralAssigneeMultipleAddProcess.jsp

  Applies the results of the member search to the task.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralAssigneeMultipleAddProcess.jsp.rca 1.10 Tue Oct 28 22:59:43 2008 przemek Experimental przemek $";
--%>
<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>

<%
  com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, "PROGRAM");
  com.matrixone.apps.program.Risk risk = (com.matrixone.apps.program.Risk) DomainObject.newInstance(context, DomainConstants.TYPE_RISK, "PROGRAM");

  //Get paramters from url
  String tempSelectedIds = emxGetParameter(request, "selectedIds");

  //Get results returned from search
  StringList searchResultList = (StringList)session.getAttribute("searchResultList");
  //remove session variable
  session.removeAttribute("searchResultList");

  String theId = "";
  StringTokenizer stToken   = new StringTokenizer(tempSelectedIds,",");

  while (stToken.hasMoreTokens()) {
    try {
      theId        = stToken.nextToken();
      boolean isARisk = false;

      task.setId(theId);

      //Test to see if theId is a risk
      risk.setId(theId);

      if (risk.getInfo(context, risk.SELECT_TYPE).equals(risk.TYPE_RISK)) {
        isARisk = true;
      }

      // get person IDs from the calling page.
      if (searchResultList != null){
        Iterator resultListItr = searchResultList.iterator();

        //If objexct type is a risk then add people to risk
        if(isARisk)
        {
          //Create an array containing all assignees
          int i = 0;
          String[] assignees = new String[searchResultList.size()];

          //Loop through results sent in from search
          while (resultListItr.hasNext())
          {
            assignees[i] = (String) resultListItr.next();
            i++;
          }

          risk.addAssignees(context, assignees);
        }
        //Else, object type is a task
        else
        {
          try {
            // start a write transaction and lock business object
            task.startTransaction(context, true);

            while (resultListItr.hasNext())
            {
              String selectedPerson = (String) resultListItr.next();
              selectedPerson = selectedPerson.substring(0, selectedPerson.indexOf(','));
              task.addAssignee(context, selectedPerson, null);
            }

            // commit the data
            ContextUtil.commitTransaction(context);

          } catch (Exception e) {
            ContextUtil.abortTransaction(context);
            throw e;
          }
        }
      }
    } catch (Exception ex ){
    }
  }

%>
<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
    //Modified for bug 358843
    //parent.window.getWindowOpener().parent.document.location.reload();
    parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;
    parent.window.closeWindow();
    // Stop hiding here -->//]]>
  </script>
</html>
