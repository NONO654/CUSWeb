<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
   Process the selected person on a change owner request.
   - perform the set owner on the target object.
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../components/emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="matrix.util.StringList"%>

<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import="java.util.Iterator"%>



<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>




<html>
<body>

 <!-- Used to load "findFrame" --> 
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>


<%!
  private static final String COMPONENT_FRAMEWORK_BUNDLE = "emxComponentsStringResource";
  private static final String ALERT_MSG = "emxComponents.Search.Error.24";

%>
<%

try
{
  String[] strTableRowIds = emxGetParameterValues(request,"emxTableRowId");

  if ((strTableRowIds == null) || (strTableRowIds.length==0))
  {
     i18nNow i18nInstance = new i18nNow();
     String strLang = request.getHeader("Accept-Language");
     String strRetMsg = i18nInstance
         .GetString(COMPONENT_FRAMEWORK_BUNDLE, strLang, ALERT_MSG);
     session.setAttribute("error.message", strRetMsg);
  }

  Search search = new Search();
  String ownerName = search.getObjectName(context, strTableRowIds);

  //WXB-IR170400-get the ObjectIds and remove from session
  String objectId = (String)session.getAttribute("CHANGEOWNERIDS");
  session.removeAttribute("CHANGEOWNERIDS");
 
  // Call the JPO method to do the change owner.
  boolean success = false;
  ContextUtil.startTransaction(context, true);
  try
  {
    String[] arguments = {objectId, ownerName};
    JPO.invoke(context, 
        "jpo.simulation.SimulationUtil", null,
        "setOwner", arguments);

    ContextUtil.commitTransaction(context);
    success = true;
  }
  catch (matrix.util.MatrixException me)
  {
     ContextUtil.abortTransaction(context);
     emxNavErrorObject.addMessage(ErrorUtil.getMessage(me));
  }

  String timeStamp1 = emxGetParameter(request, "timeStamp");
  Map requestMap1 = tableBean.getRequestMap(timeStamp1);

  String updateAction = (String)requestMap1.get("updateAction");
  if (success 
      && updateAction != null && updateAction.equalsIgnoreCase("refreshCaller"))
  {
      String timeStamp2 = (String)requestMap1.get("callerTimeStamp");
      // callerTimeStamp is not in the request map if comming from
      // the home page
      if (timeStamp2 != null)
      {
          StringBuffer urlParams = new StringBuffer();
          Map requestMap2 = tableBean.getRequestMap(timeStamp2);
          java.util.Set keys = requestMap2.keySet();
          Iterator itr = keys.iterator();
          while(itr.hasNext())
          {
            String paramName = (String)itr.next();
            String paramValue = null;
            try
            {
              paramValue = (String)requestMap2.get(paramName);
            }
            //Ignore the exception
            catch(Exception ClassCastException) {}
    
            urlParams.append("&").append(paramName).append("=")
                .append(paramValue);
          }
          if (urlParams.length() > 0)
              urlParams.setCharAt(0, '?');


%>
          <script language="javascript"> 
          
          if (getTopWindow().getWindowOpener())
          {
              
              var urlParams = "<%=urlParams.toString()%>";
              if (getTopWindow().getWindowOpener().parent)
              { 
                  if (getTopWindow().getWindowOpener().parent.location.search)
                      urlParams = "";
                  getTopWindow().getWindowOpener().parent.location.href = 
                    getTopWindow().getWindowOpener().parent.location.href + urlParams;
              }
              else
              {
                  if (getTopWindow().getWindowOpener().location.search)
                      urlParams = "";
                  getTopWindow().getWindowOpener().location.href = 
                    getTopWindow().getWindowOpener().location.href + urlParams;
              }

              getTopWindow().closeWindow();    
          }
          </script>
<%




      }//close if
      else
      {
          String [] sRowIds = objectId.split("\\*");
          String rowsToRemove = "";
          for (int iii = 0; iii < sRowIds.length; iii++)
          {
              String selObjectId = sRowIds[iii];
              // get the actual object id since sRowId
              // might be "|" separated list containing 
              // relation and parent id's as well
              String[] ids = sRowIds[iii].split("\\|");
              if (ids.length > 1)
                  selObjectId = ids[1];
              DomainObject DO = new DomainObject();
              DO.setId(selObjectId);
  
              if ( AccessUtil.hasAccess(context, DO, "read") == false )
              {
                  
                  if (rowsToRemove.length() > 0)
                      rowsToRemove += "*";
                  rowsToRemove += selObjectId;
              }
          }

%>
        <script language="javascript">
<%

        String [] rowsToRemoveAr=rowsToRemove.split("\\*");
        for(int iii=0;iii<rowsToRemoveAr.length;iii++)
        {
            String rObjectId=rowsToRemoveAr[iii];       
%>

            deleteNode("<%=rObjectId%>");

<%
        }
%>
        getTopWindow().closeWindow();
        </script>
<%
      }
  }
  else  if (!success)
  {   
      // did not succeed so reset submit button
%>
      <script language="JavaScript">
                var tblFooterFrm = getTopWindow().findFrame(parent, "listFoot");
                tblFooterFrm.setTableSubmitAction(true);
      </script>
<%
  }
} // End of try
catch (Exception ex)
{
    emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
} // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</body>
</html>
