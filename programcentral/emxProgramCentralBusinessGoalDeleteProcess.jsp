<%--  emxProgramCentralBusinessGoalDeleteProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralBusinessGoalDeleteProcess.jsp.rca 1.13 Wed Oct 22 15:49:20 2008 przemek Experimental przemek $";
--%>

<%@include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%
   //Added:8-Mar-2010:s4e:R209 PRG:IR-036385 
   //This jsp has been modified because now delete link for Business goals will be available only on "PMCMyDeskBusinessGoalToolBarActions" toolbar 
  com.matrixone.apps.program.BusinessGoal businessGoal =
    (com.matrixone.apps.program.BusinessGoal) DomainObject.newInstance(context, DomainConstants.TYPE_BUSINESS_GOAL, DomainConstants.PROGRAM);
  String[] strBusinessGoalRowId = emxGetParameterValues(request,"emxTableRowId");
  strBusinessGoalRowId = ProgramCentralUtil.parseTableRowId(context,strBusinessGoalRowId);
  String strBusinessGoalId = "";
  String strBusinessGoalCurrentState ="";
  String strLanguage = context.getSession().getLanguage();
  String strErrMsg ="";
  boolean flag = false;
  for(int nCount=0;nCount<strBusinessGoalRowId.length;nCount++)
  {
      strBusinessGoalId = strBusinessGoalRowId[nCount];
      businessGoal.setId(strBusinessGoalId);
      strBusinessGoalCurrentState=businessGoal.getCurrentState(context).getName();
      if (!(DomainConstants.STATE_BUSINESS_GOAL_CREATE.equals(strBusinessGoalCurrentState)))
      {
          flag = true;
          strErrMsg = EnoviaResourceBundle.getProperty(context, "ProgramCentral", 
    			  "emxProgramCentral.BusinessGoal.CannotDeleteInActiveOrCompleteState", strLanguage);
          continue; 
          
      }     
      businessGoal.deleteObject(context, true);      
  }
  if(flag)
  {
      %>
      <script language="javascript" type="text/javaScript">
    //PRG:RG6:R211:IR-070902V6R2012: Line deleted
      alert("<%=XSSUtil.encodeForJavaScript(context,strErrMsg)%>")
      window.closeWindow();      
      </script>
  <% 

   }
 %>
 <script language="javascript" type="text/javascript">
    window.parent.location = window.parent.location;
    window.closeWindow();
  </script>

