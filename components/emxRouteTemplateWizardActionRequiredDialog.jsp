<%--  emxRouteTemplateWizardActionRequiredDialog.jsp   -   Display Summary Of People
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $: Exp $

--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%

//integer to count the no of tasks added for IR 77904
int taskSize = 0;

String keyValue=emxGetParameter(request,"keyValue");
String isRouteTemplateRevised=emxGetParameter(request,"isRouteTemplateRevised");
        Map paramMap = (Map) formBean.getElementValue("strParams");

  if (paramMap != null){
  Iterator keyItr = paramMap.keySet().iterator();



  while (keyItr.hasNext())
  {
    String name = (String) keyItr.next();
    String value = (String) paramMap.get(name);
    request.setAttribute(name, value);
  }

}


  String sAttParallelNodeProcessionRule = PropertyUtil.getSchemaProperty(context, "attribute_ParallelNodeProcessionRule");
  Route routeObj = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);

  String sRadioValue = "";

  String languageStr    = request.getHeader("Accept-Language");
  //String sourcePage     = emxGetParameter(request,"sourcePage");
  String sourcePage = (String)formBean.getElementValue("sourcePage");

  if ((sourcePage == null) || sourcePage.equals("null")){
    sourcePage = "";
  }



  String routeOrder = (String)formBean.getElementValue("routeOrder");
  String routeInstructions = (String)formBean.getElementValue("routeInstructions");
  String routeTime = (String)formBean.getElementValue("routeTime");
  String title = (String)formBean.getElementValue("title");
  String personName = (String)formBean.getElementValue("personName");
  String routeId = (String)formBean.getElementValue("routeId");
  String projectId = (String)formBean.getElementValue("objectId");
  String routeNodes = (String)formBean.getElementValue("routeNode");
  String templateId = (String)formBean.getElementValue("templateId");
  String templateName = (String)formBean.getElementValue("templateName");
  String assigneeType = (String)formBean.getElementValue("assigneeType");
  String portalMode = (String)formBean.getElementValue("portalMode");
  String routeAction = (String)formBean.getElementValue("routeAction");
  String newTaskIds = (String)formBean.getElementValue("newTaskIds");


    String relRouteNode      = PropertyUtil.getSchemaProperty(context, "relationship_RouteNode");

   // String folderId          = emxGetParameter(request,"folderId");
   // String workspaceId       = emxGetParameter(request,"workspaceId");

    String folderId = (String)formBean.getElementValue("folderId");
	String workspaceId = (String)formBean.getElementValue("workspaceId");


    String sRoute            = i18nNow.getI18nString("emxComponents.Common.Route", "emxComponentsStringResource", sLanguage);
    String strRouteActionAttr= PropertyUtil.getSchemaProperty(context, "attribute_RouteAction" );

    StringTokenizer sTokOrder      = null;
    StringTokenizer sTokName       = null;
    StringTokenizer sTokAction     = null;
    StringTokenizer sTokRouteNodes = null;

    String rowClass          = "even";



     // MapList taskDetails    = (MapList)session.getAttribute("taskMapList");
      MapList taskDetails    = (MapList)formBean.getElementValue("taskMapList");

	  if (sourcePage.equals("EditAllTasks")) {
	    sTokOrder       = new StringTokenizer(routeOrder,"~");
	    sTokName        = new StringTokenizer(title,"~");
	    sTokAction      = new StringTokenizer(routeAction,"~");
	    sTokRouteNodes  = new StringTokenizer(routeNodes,"~");
	  }

	  String sSameRow = "";
	  boolean bRadioDisplay = false;


  String assignURL   = "emxRouteTemplateWizardAssignTaskFS.jsp?selectedAction=";
  if ((routeAction == null) || routeAction.equals("null"))
    assignURL += "false";
  else
    assignURL += "true";

  assignURL += "&portalMode=" + XSSUtil.encodeForURL(context,portalMode) + "&keyValue=" + XSSUtil.encodeForURL(context,keyValue);

  StringTokenizer sTokAssigneeType = new StringTokenizer(assigneeType,"~");


%>



<script language="JavaScript">

function setUnloadMethod()
{
	var bodyElement = document.getElementById("taskdelete");  
    if (isIE && bodyElement){    
        bodyElement.onunload = function () { windowClose(); };
    }else{
        bodyElement.setAttribute("onbeforeunload",  "return windowClose()");
    }
}
function removeOnloadEvents()
{
	var bodyElement = document.getElementById("taskdelete");
	if (isIE && bodyElement){	
   		bodyElement.onunload = null;
	}else{
	  	bodyElement.setAttribute("onbeforeunload",  "");
	}
}
var submitAction = false;

  function closeWindow() {
     submitAction = true;
	 removeOnloadEvents();
  <%
      if (sourcePage.equals("EditAllTasks")) {
  %>
        var isRouteTemplateRevised = <%=isRouteTemplateRevised%>;
        if(isRouteTemplateRevised == true){
			submitWithCSRF("emxRouteTemplateCancelNewTaskProcess.jsp?newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>&routTemplateRevisionId=<%=XSSUtil.encodeForURL(context, projectId)%>", window);
		}else{
   submitWithCSRF("emxRouteTemplateCancelNewTaskProcess.jsp?newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>", window);
		}
  <%
      } else {
  %>
        submitWithCSRF("emxRouteWizardCancelProcess.jsp?keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>", window);
  <%
      }
  %>
  }


  function windowClose()
  {
    removeOnloadEvents();
	<%
      if (sourcePage.equals("EditAllTasks")) {
    %>
        if (submitAction != true )
        {
			var isRouteTemplateRevised = <%=isRouteTemplateRevised%>;
            if(isRouteTemplateRevised == true){
                emxUICore.getDataPost("emxRouteTemplateCancelNewTaskProcess.jsp", "newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>&routTemplateRevisionId=<%=XSSUtil.encodeForURL(context, projectId)%>");
			}else{
				emxUICore.getDataPost("emxRouteTemplateCancelNewTaskProcess.jsp", "newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>");
			}
            parent.window.close();
            return;
       }
	<%
      } else {
    %>
	       emxUICore.getDataPost("emxRouteWizardCancelProcess.jsp", "keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>");
	 <%
      }
     %>	  
	   
  }

  function submitForm() {
    startProgressBar(true);
	removeOnloadEvents();
    document.actionRequired.submit();
    return;
  }

</script>
<body id="taskdelete" name="taskdelete" onload="setUnloadMethod()">
<form method="post" name="actionRequired" onSubmit="javascript:submitForm(); return false" action="emxRouteTemplateWizardActionRequiredProcess.jsp" target="_parent" >
<input type="hidden" name="sourcePage" value="<xss:encodeForHTMLAttribute><%=sourcePage%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeId" value="<%=routeId%>" />
<input type="hidden" name="objectId" value="<%=projectId%>" />
<input type="hidden" name="routeInstructions" value="<xss:encodeForHTMLAttribute><%=routeInstructions%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeTime" value="<xss:encodeForHTMLAttribute><%=routeTime%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeOrder%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="personName" value="<xss:encodeForHTMLAttribute><%=personName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeAction" value="<xss:encodeForHTMLAttribute><%=routeAction%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="templateId" value="<%=templateId%>" />
<input type="hidden" name="templateName" value="<xss:encodeForHTMLAttribute><%=templateName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeNodes" value="<xss:encodeForHTMLAttribute><%=routeNodes%></xss:encodeForHTMLAttribute>" />

<input type="hidden" name="assigneeType" value="<xss:encodeForHTMLAttribute><%=assigneeType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="isRouteTemplateRevised" value="<xss:encodeForHTMLAttribute><%=isRouteTemplateRevised%></xss:encodeForHTMLAttribute>" />
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
 </script>

  <table class="list" id="UITable">
    <tr>
      <th><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Order</emxUtil:i18n>&nbsp;</th>
       <th><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n>&nbsp;</th>
       <th><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Action</emxUtil:i18n></th>
      <th><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.ActionRequired</emxUtil:i18n></th>
    </tr>



<%

  String strArray[]  = null;
  TreeMap sortMap  = new TreeMap();
  Vector sortVector = null;
  //HashTable ht = new HashTable();

  String routeScheduledCompletionDateStr      = PropertyUtil.getSchemaProperty(context, "attribute_ScheduledCompletionDate");
  String routeSequenceStr                     = PropertyUtil.getSchemaProperty(context, "attribute_RouteSequence");
  String routeAllowDelegation                 = PropertyUtil.getSchemaProperty(context, "attribute_AllowDelegation");
  String routeActionStr                       = PropertyUtil.getSchemaProperty(context, "attribute_RouteAction");
  String routeInstructionsStr                 = PropertyUtil.getSchemaProperty(context, "attribute_RouteInstructions");
  String taskNameStr                          = PropertyUtil.getSchemaProperty(context, "attribute_Title");


    if (sourcePage.equals("EditAllTasks")){

        taskSize = sTokOrder.countTokens();

        while(sTokOrder.hasMoreTokens()) {
                       strArray = new String[4];
                       strArray[0] =  sTokOrder.nextToken("~");
                       String sName = sTokName.nextToken("~");
                       strArray[1] =  sName.startsWith("role")?PropertyUtil.getSchemaProperty(context,sName)+"(Role)":sName;
                       strArray[2] =  sTokAction.nextToken("~");
                       strArray[3] =  sTokRouteNodes.nextToken("~");

                       if (sortMap.containsKey(strArray[0])) {
                         sortVector = (Vector)sortMap.get(strArray[0]);
                         sortVector.addElement(strArray);
                       }
                       else
                       {
                         sortVector = new Vector();
                         sortVector.addElement(strArray);
                         sortMap.put(strArray[0], sortVector);
                       }

            }
    }else if(taskDetails !=null && taskDetails.size() > 0){

       		taskSize = taskDetails.size();
            Iterator taskListItr = taskDetails.iterator();

            while(taskListItr.hasNext()) {
              Map taskMap = (Map)taskListItr.next();
               strArray = new String[4];
               strArray[0] =  (String)taskMap.get(routeSequenceStr);
               strArray[1] =  (String)taskMap.get(taskNameStr);
               strArray[2] =  (String)taskMap.get(routeActionStr);
               strArray[3] =  (String)taskMap.get(relRouteNode);


               if (sortMap.containsKey(strArray[0])) {
                 sortVector = (Vector)sortMap.get(strArray[0]);
                 sortVector.addElement(strArray);
               }
               else
               {
                 sortVector = new Vector();
                 sortVector.addElement(strArray);
                 sortMap.put(strArray[0], sortVector);
               }
            }

    }

    String sRadioButtonNames = "";
    String sRouteNodeNames = "";

    String sRouteNodeIds = "";
    String sRouteNodeSecs = "";

    String sHiddenParams = "";

//Added for the Bug No:328079 12/27/2006 Begin
  // HashMap radioSelectedMap = (HashMap)session.getAttribute("radioSelectedMap");
	             HashMap radioSelectedMap = null;
	             try{
	               radioSelectedMap = (HashMap) formBean.getElementValue("radioSelectedMap");
				   formBean.setElementValue("radioSelectedMap",null);
			      }catch(Exception ect){
					  System.out.println("EXCEPTION step4 Dialog radioSelectedMap :: "+ect.getMessage());
				  }
				  String strKey[]=new String[taskSize];
				  String strValue[]=new String[taskSize];
				  if(radioSelectedMap!=null)
				  {
				  Iterator itrObj = radioSelectedMap.keySet().iterator();
				  int index=0;
				
				while(itrObj.hasNext())
								{
									String name=(String)itrObj.next();
									index=Integer.parseInt(name.substring(name.length()-1));
									strKey[index]=name;
									strValue[index] = (String)radioSelectedMap.get(strKey[index]);
								}
							  }
//Added for the Bug No:328079 12/27/2006 End
						


  for(int orderCount=1;orderCount<=taskSize; orderCount++) {


    rowClass = rowClass.equals("even") ? "odd" : "even";
    Integer inter = new Integer(orderCount);
    String sOrder = inter.toString();
    if(sortMap.containsKey(sOrder)) {
      Vector vect = (Vector) sortMap.get(sOrder);
      int iSize = vect.size();
      for(int iDisplay=0;iDisplay < vect.size(); iDisplay++) {
        String sTest[] = (String[])vect.elementAt(iDisplay);

 %>


    <tr class='<framework:swap id ="1" />'>
      <td><%=sTest[0]%>&nbsp;</td>
      <td><%=XSSUtil.encodeForHTML(context,sTest[1])%>&nbsp;</td>
      <td><%=XSSUtil.encodeForHTML(context, i18nNow.getRangeI18NString(strRouteActionAttr, sTest[2],languageStr))%></td>
      <td>

      <%
	          if(iSize > 1 ) {
	            iSize=0;

	  %>
	           <table border="0">
	             <tr>
				 <!-- Modified for the Bug No:328079 12/27/2006 Begin -->
	             <%
				if(strKey[orderCount]!=null && strKey[orderCount].length()!=0 )
				  {
	  				%>
		  	  <td><input type="radio" value="Any" name="radioAction<%=sTest[0]%>" <% if(("radioAction"+sTest[0]).equals(strKey[orderCount]) && strValue[orderCount].equals("Any") ){%> checked <%}%> /></td>
	               <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Any</emxUtil:i18n></td>

	               <td><input type="radio"  value="All" name="radioAction<%=sTest[0]%>" <% if(("radioAction"+sTest[0]).equals(strKey[orderCount]) && strValue[orderCount].equals("All") ){%> checked <%}%> /></td>
	               <td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.All</emxUtil:i18n></td>

	             <%

	             	}
					else
					{//Modified for the Bug No:328079 12/27/2006 End
					    String strChecked = "All";
					    if(sourcePage.equals("EditAllTasks")){
		                    DomainRelationship routeNode =null;
		                    try{
		                        routeNode = DomainRelationship.newInstance(context,sTest[3]);
		                        }catch(Exception ect){
		                            System.out.println(ect.getMessage());
		                        }
		                   if(routeNode!=null){
		                     String parallelNodeValue= routeNode.getAttributeValue(context,sAttParallelNodeProcessionRule);
		                     if(parallelNodeValue.equalsIgnoreCase("Any")){
		                        strChecked = "Any";
		                     }
		                   }
						   for(int sameOrderTask = 1;sameOrderTask<vect.size();sameOrderTask++){
		                	   String updateSameOrderTask[] = (String[])vect.elementAt(sameOrderTask);
		                	   try{
			                        routeNode = DomainRelationship.newInstance(context,updateSameOrderTask[3]);
			                        }catch(Exception ect){
			                            System.out.println(ect.getMessage());
			                        }
			                   if(routeNode!=null){
			                     String parallelNodeValue= routeNode.getAttributeValue(context,sAttParallelNodeProcessionRule);
			                     if(!parallelNodeValue.equalsIgnoreCase(strChecked)){
			                    	 routeNode.setAttributeValue(context,sAttParallelNodeProcessionRule,strChecked);
			                     }
			                   }
		                   }
					    }
	  		   %>
	  			<td>
					<!-- //XSSOK -->
					<input type="radio" <%=strChecked.equals("Any")?"checked":""%> value="Any" name="radioAction<%=sTest[0]%>" /></td>
	  				<td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.Any</emxUtil:i18n></td>
	  				<!-- //XSSOK -->
	  				<td><input type="radio" <%=strChecked.equals("All")?"checked":""%>  value="All" name="radioAction<%=sTest[0]%>"/></td>
	  				<td><emxUtil:i18n localize="i18nId">emxComponents.ActionRequiredDialog.All</emxUtil:i18n></td>
	  		<%}%>



	  		</tr>
	           </table>
	  <%

	            // Store the radio button names.
	            if(sRadioButtonNames.equals("")) {
	              sRadioButtonNames = "radioAction"+sTest[0];
	              sRouteNodeSecs += "RouteNodeAction"+sTest[0];
	            } else {
	              sRadioButtonNames += "|" + "radioAction"+sTest[0];
	              sRouteNodeSecs += "|" + "RouteNodeAction"+sTest[0];
	            }

	          }
	          sHiddenParams += "<input type=\"hidden\" name='RouteNodeAction"+sTest[0]+"' value='"+sTest[3] +"' />";
	  %>
	         </td>
	      </tr>
	  <%
	        }
	      }
	    }
	  %>
	    </table>
	    <input type="hidden" name="radioNames" value="<xss:encodeForHTMLAttribute><%=sRadioButtonNames%></xss:encodeForHTMLAttribute>"/>
	    <input type="hidden" name="routeNodeSecs" value="<xss:encodeForHTMLAttribute><%=sRouteNodeSecs%></xss:encodeForHTMLAttribute>"/>
	    <!-- //XSSOK -->
	    <%=sHiddenParams%>
	  </form>
	  </body>
	  <%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<!-- Modified for the Bug No:328079 12/27/2006 Begin -->
<script>
 function goBack() {
	 removeOnloadEvents();
<%
    if (sourcePage.equals("EditAllTasks")) {
%>
     document.actionRequired.action="emxEditAllTasksDialogFS.jsp?sortName=true&newTaskIds=<%=XSSUtil.encodeForURL(context, newTaskIds)%>&objectId=<%=XSSUtil.encodeForURL(context, projectId)%>";
<%
    } else {
	 assignURL=assignURL+"&radioNames="+XSSUtil.encodeForURL(context,sRadioButtonNames)+"&routeNodeSecs="+XSSUtil.encodeForURL(context,sRouteNodeSecs);
%>
      //XSSOK
      document.actionRequired.action="<%=assignURL%>";
<%
    }
%>
    document.actionRequired.submit();
    return;
  }
  </script>
<!-- Modified for the Bug No:328079 12/27/2006 End -->
