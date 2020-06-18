<%-- (c) Dassault Systemes, 2013 --%>
<%--
  Execution Options save.
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import = "java.util.HashMap,java.util.Map"%>
<%@page import = "matrix.db.*, matrix.util.*"%>
<%@page import="matrix.db.Context" %>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@include file="../simulationcentral/smaWebUtil.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%
   Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
   String objectAction      = emxGetParameter(request, "objectAction");
   String oid               = "";
   String DMode = emxGetParameter(request, "portalMode");

   String header = SimulationUtil.getI18NString(context,
       "smaSimulationCentral.HomeExecutionOption");
   if("ExecutionOption".equals(objectAction) || "ExecutionOptionPortal".equals(objectAction) ){
       HashMap programMap = new HashMap();
       programMap.put("requestMap", requestMap);
       
       programMap.put("stream", SimulationConstants.EXT_NAME_EXEC_OPTION);
       String[] args = JPO.packArgs(programMap);
       
       try{
           JPO.invoke(context, 
               "jpo.simulation.ExecutionOption", null, 
               "SaveValuesInXml", args, Boolean.class);
       }
       catch(Exception e){
           %>           
           <script>
               alert('<%=e.getMessage().replaceAll("\n", "")%>');
           </script>
          <%           
       }
       
       String IsCustomValidParameter = (String)requestMap.get("IsCustomValidParameter");
       
		if(IsCustomValidParameter!=null && IsCustomValidParameter.equalsIgnoreCase("false"))
			{
		%>
           <script> 
               alert("InValid Expression Entered for Custom field");
           </script>
		<%
			}
		String IsMaxBatchSizeValidParameter = (String)requestMap.get("IsMaxBatchSizeValidParameter");
	       
		if(IsMaxBatchSizeValidParameter!=null && IsMaxBatchSizeValidParameter.equalsIgnoreCase("false"))
			{
		%>
           <script> 
               alert("InValid Expression Entered for Max Batch Size field");
           </script>
		<%
			}
	   String objectId = emxGetParameter(request, "parentOID");
       String ObjId = emxGetParameter(request, "objectId");
       
     //URLBuilder contentURL = null ;
       StringBuffer  contentURL = new StringBuffer();
       if("ExecutionOption".equals(objectAction))
       {
           contentURL.append("../common/emxForm.jsp")
                     .append("?form=")
                     .append("SMAActivityExecutionOption")
                     .append("&mode=view")
                     .append("&PrinterFriendly=false")
                     .append("&categoryTreeName=type_SimulationActivity")
                     .append("&toolbar=SMAExecutionOption_ListToolbar")
                     .append("&objectId="+objectId)
                     .append("&formHeader="+header);
       }
       else
       {
           contentURL.append("../common/emxForm.jsp")
           .append("?form=")
           .append("SMAActivityExecutionOption")
           .append("&mode=view")
           .append("&PrinterFriendly=false")
           .append("&categoryTreeName=type_SimulationActivity")
           .append("&toolbar=SMAExecutionOption_ListToolbarPortal")
           .append("&objectId="+objectId)
           .append("&formHeader="+header);
       }
       
       
           
       %>
       <script language="JavaScript">
       
       function sleep(delay) {
           var start = new Date().getTime();
           while (new Date().getTime() < start + delay);
       }
           var topFrame = getTopWindow();
           var frame1 = null;
           <%
           if("ExecutionOptionPortal".equals(objectAction))
           {
           %>
               if ( getTopWindow().getWindowOpener() )
               {
                   topFrame = getTopWindow().getWindowOpener().getTopWindow();
               }
               frame1 = findFrame(topFrame, "SMACompose_ActivityExecutionOptionPortal");
			   getTopWindow().closeSlideInPanel();
               if ( frame1 != null )
               {
                   frame1.location.replace("<%= contentURL%>");
               }
      getTopWindow().refreshTablePage();

           <%
             }
             else{
            %>
            if ( getTopWindow().getWindowOpener() )
            {
                topFrame = getTopWindow().getWindowOpener().getTopWindow();
            }
            frame1 = findFrame(topFrame, "detailsDisplay");
			getTopWindow().closeSlideInPanel();
            if ( frame1 != null )
            {
                frame1.location.replace("<%= contentURL%>");
            }
               

         <%
             }
         %>

           
       </script>
       <%
   }
   else if("ProcessExecutionOption".equals(objectAction) || "ProcessExecutionOptionPortal".equals(objectAction) ){
       //save in the process 
       HashMap programMap = new HashMap();
       programMap.put("requestMap", requestMap);
       
       programMap.put("stream", SimulationConstants.EXT_NAME_PROCESS_EXEC_OPTION);
       String[] args = JPO.packArgs(programMap);
       String objectId = emxGetParameter(request, "parentOID");
       Boolean result =(Boolean)JPO.invoke( context, 
           "jpo.simulation.ExecutionOption", null, 
           "SaveValuesInXmlOfProcess", args, Boolean.class);
       //URLBuilder contentURL = null ;
        StringBuffer  contentURL = new StringBuffer();
        if("ProcessExecutionOption".equals(objectAction)){
                 contentURL.append("../common/emxForm.jsp")
                 .append("?form=")
                 .append("SMAProcessExecutionOption")
                 .append("&mode=view")
                 .append("&PrinterFriendly=false")
                 .append("&categoryTreeName=type_Simulation")
                 .append("&toolbar=SMAExecutionOption_ProcessListToolbar")
                 .append("&isSelfTargeted=true")
                 .append("&objectId="+objectId)
                 .append("&formHeader="+header);
        }else{
                contentURL.append("../common/emxForm.jsp")
                .append("?form=")
                .append("SMAProcessExecutionOption")
                .append("&mode=view")
                .append("&PrinterFriendly=false")
                .append("&categoryTreeName=type_Simulation")
                .append("&toolbar=SMAExecutionOption_ProcessListToolbarPortal")
                .append("&isSelfTargeted=true")
                .append("&objectId="+objectId)
                .append("&formHeader="+header);
            
        }
       %>
       <script language="javascript">
           var topFrame = getTopWindow();
           function sleep(delay) {
               var start = new Date().getTime();
               while (new Date().getTime() < start + delay);
           }
           if ( getTopWindow().getWindowOpener() )
           {
               topFrame = getTopWindow().getWindowOpener().getTopWindow();
           }
           var frame1 = null ;
           <%
           if("ProcessExecutionOption".equals(objectAction))
           {
           %>
             frame1 = findFrame(topFrame, "detailsDisplay");
           <%
           }else
           {
           %>
             frame1 = findFrame(topFrame, "SMACompose_ProcessExecutionOptionPortal");
           <%
           }
           %>
           if ( frame1 != null )
           {
               frame1.location.replace("<%= contentURL.toString()%>");
           }
       </script>
       <%
   }
   
%>


