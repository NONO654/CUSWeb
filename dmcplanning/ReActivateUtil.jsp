
<%--  ArchiveUtil.jsp   

    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved.

    This program contains proprietary and trade secret information of MatrixOne,
    Inc.  Copyright notice is precautionary only and does not evidence
    any actual or intended publication of such program

    static const char RCSID[] = "$Id: /ENOCFP/CNext/webroot/dmcplanning/ArchiveUtil.jsp 1.3.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";
        
--%>
<%--Importing package com.matrixone.apps.domain --%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>

<%--Importing package com.matrixone.apps.product --%>
<%@page import = "com.matrixone.apps.dmcplanning.ManufacturingPlan"%>
<%@page import = "com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%--Common Include File --%>
<%@include file = "DMCPlanningCommonInclude.inc" %>


<%@include file = "../common/emxNavigatorInclude.inc"%>



<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>

<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<html>
  


<%
String msg = "";
try
{


	String strLanguage = context.getSession().getLanguage();
    //Instantiating ProductLineutil and ProductLinecommon beans
    ManufacturingPlan mPlanBean = new ManufacturingPlan();

    //extract Table Row ids of the checkboxes selected.
    String strTableRowIds[] = emxGetParameterValues(request,"emxTableRowId");
 
		  
  StringList mpidslist = new StringList();
    if(strTableRowIds!=null)
      {
       for(int i=0;i<strTableRowIds.length;i++)
        {
           StringTokenizer stknzer= new StringTokenizer(strTableRowIds[i],"|");
           stknzer.nextToken();//relis
           mpidslist.add((String)stknzer.nextToken());
        }
      }
    //convertign String[] to String List
    
    
    
     boolean archived=mPlanBean.reActivate(context,mpidslist);
    
    
    if (archived)
    {
      ///need to refresh the d
    
%>
 <script language="javascript" type="text/javaScript">
    //<![CDATA[
       window.parent.location.href=window.parent.location.href;
    //]]>
    </script>
    
<%
    }
     
}catch(Exception ex)
{
     
    if(ex.toString() != null && (ex.toString().trim()).length()>0)
    {
      msg = ex.toString().trim();
    }
    emxNavErrorObject.addMessage(msg); 
}


%>     


<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>


  
</html>

  






 
 

   
