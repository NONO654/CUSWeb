<%--
  emxProgramCentralLocationProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  
  static const char RCSID[] = $Id: emxProgramCentralLocationProcess.jsp.rca 1.5 Wed Oct 22 15:49:14 2008 przemek Experimental przemek $

--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProgramGlobals2.inc"%>

<%@page import="com.matrixone.apps.common.WorkCalendar"%>

<html>
<body>
<form name="locform">
<%

// populate all parameters in hidden

  StringList infoList = new StringList();  
  String strTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
  String timeStamp = emxGetParameter(request,"timeStamp");
  String objectId = emxGetParameter(request,"objectId");
  String relId = emxGetParameter(request,"relId");
  String parentOID = emxGetParameter(request,"parentOID");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String portalMode = emxGetParameter(request,"portalMode");
  String strUIType = emxGetParameter(request,"uiType");

%>
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>" />    
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />    
<input type="hidden" name="relId" value="<xss:encodeForHTMLAttribute><%=relId%></xss:encodeForHTMLAttribute>" />    
<input type="hidden" name="parentOID" value="<xss:encodeForHTMLAttribute><%=parentOID%></xss:encodeForHTMLAttribute>" />    
<input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />    
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />    
<input type="hidden" name="uiType" value="<xss:encodeForHTMLAttribute><%=strUIType%></xss:encodeForHTMLAttribute>" />

<%  

if((strTableRowIds!=null)||(strTableRowIds.length!=0))
{

  String[] objectIds = new String[strTableRowIds.length];

  for (int i=0; i<strTableRowIds.length; i++)
  {
    String id = strTableRowIds[i];
    if(id.indexOf('|') != -1)
    {
      id = id.substring(id.indexOf('|')+1, id.length());
    }
    objectIds[i] = id;
%>
  <input type="hidden" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=id%></xss:encodeForHTMLAttribute>" />

<%
  }

  String sLocationNames = null;
  String selectWorkCalendar = "from[" + WorkCalendar.RELATIONSHIP_CALENDAR + "].to.id";
  
  StringList selects = new StringList(selectWorkCalendar);
  selects.addElement(DomainConstants.SELECT_NAME);
  selects.addElement(DomainConstants.SELECT_ID);


  MapList mapList = DomainObject.getInfo(context, objectIds, selects);
  
  Iterator itr  = mapList.iterator();
    
  while(itr.hasNext())
  {
    Map map = (Map) itr.next();
    String sLocactionCal = (String) map.get(selectWorkCalendar);
    if(sLocactionCal != null && !"".equals(sLocactionCal))
    {
      if(sLocationNames == null)
      {
        sLocationNames = (String) map.get(DomainConstants.SELECT_NAME);
      }
      else
      {
        sLocationNames += ", " + (String) map.get(DomainConstants.SELECT_NAME);
      }
    }

  }
  

  
  if(sLocationNames != null && sLocationNames.length() > 0)
  {
 %>
   <script language="Javascript">   
       var msg = confirm("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Calendar.ReplaceConfirm</emxUtil:i18nScript>\n\n<%=XSSUtil.encodeForJavaScript(context,sLocationNames)%>");
       
       if(msg){
         document.locform.action = "../components/emxCommonConnectObjects.jsp";
         document.locform.submit();
       }else{
         getTopWindow().parent.document.location.href = getTopWindow().parent.document.location.href;
       }  
   </script>
 <%
      }
  else { %>
  <script language="Javascript">
         document.locform.action = "../components/emxCommonConnectObjects.jsp";
         document.locform.submit();
         getTopWindow().getWindowOpener().location.href = "../common/emxTable.jsp?jsTreeID=null&parentOID=<%=XSSUtil.encodeForURL(context,parentOID)%>&toolbar=PMCWorkCalendarLocationToolbar&portal=PMCCalendarView&table=PMCWorkCalendarLocations&objectId=<%=XSSUtil.encodeForURL(context,parentOID)%>&program=emxLocation:getLocation&header=emxProgramCentral.Common.CalendarLocations&selection=multiple&portalMode=true&emxSuiteDirectory=programcentral&HelpMarker=emxhelpcalendarlocationlist&StringResourceFileId=emxProgramCentralStringResource&portalCmdName=PMCListCalendarLocations";
    </script>
   <% } 
}
 
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</form>
</body>
</html>
 
