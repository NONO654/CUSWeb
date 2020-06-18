<%-- smaTemplateOptionEdit.jsp
         This JSP is strictly for use of oneClick Template Edit page for Dashboard.
        For any queries contact Experience Studio team.
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<html>

<head>
  <%@include file = "../common/emxFormConstantsInclude.inc"%>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <%@include file = "../common/emxFormUtil.inc"%>
  <%@include file = "../emxJSValidation.inc" %>
  <script type="text/javascript" src="../common/scripts/emxUITableUtil.js"></script>

  <jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

  <%@page import="java.util.Iterator"%>
  <%@page import="com.dassault_systemes.smaslm.matrix.common.json.JSONObject"%>
  <%@page import="java.util.Map,java.util.HashMap,com.matrixone.apps.domain.util.MapList"%>
  <%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
  <%@page import="java.util.Map,java.util.Set,java.util.Map,java.util.HashSet,com.dassault_systemes.smaslm.matrix.common.json.JSONObject"%>


  <%
String securityContext = emxGetParameter(request, "SecurityContext");
String TEMPLATE_EDIT_TIMESTAMP = emxGetParameter(request, "TEMPLATE_EDIT_TIMESTAMP");
request.setAttribute("table", "SMATemplate_Options"); 
request.setAttribute("program", "jpo.simulation.Template:getOptions");
context.resetRole(securityContext); 
String objectId = emxGetParameter(request, "objectId");
String simId = emxGetParameter(request, "simId");
String simTitle = emxGetParameter(request, "simTitle");
String contentType = emxGetParameter(request, "contentType");
//icon is for underlying process or activity whichever is opened in xs studio, creating path dynamically
String icon; 
if(contentType.equalsIgnoreCase("Simulation")){
	icon="../webapps/SMAProcXSWidgets/assets/images/process.png";
}
else{
	//this is an activity
	icon="../common/images/smaIconActivity.gif";
}
DomainObject templateObject = new DomainObject();
templateObject.setId(objectId);
templateObject.open(context);
Boolean hasModifyAccess = templateObject.checkAccess(context, (short)AccessConstants.cModify);
if(hasModifyAccess){
    hasModifyAccess = !AccessUtil.isLocked(context, templateObject, true);
}
Map requestMapforCal = new HashMap();
JSONObject retValObj = new JSONObject();
Boolean invokeEditDirectly = true;

  StringBuffer mxLinkHTML = new StringBuffer(100);
  StringBuffer sfb = new StringBuffer();
    int paramind = 1;
    Enumeration enumParamNames = emxGetParameterNames(request);
    while(enumParamNames.hasMoreElements()) {
        String paramName = (String) enumParamNames.nextElement();
        String paramValue = emxGetParameter(request, paramName);

       if(paramValue != null && !"null".equals(paramValue) && !"".equals(paramValue) ) {
                if(paramind > 1)
                        sfb.append("&");
                sfb.append(paramName);
                sfb.append("=");
                sfb.append(paramValue);
                paramind++;
        }
    }
    
  HashMap tableData = new HashMap();
  HashMap requestMap = new HashMap();
    String timeStamp = tableBean.getTimeStamp();
    try {
      ContextUtil.startTransaction(context, true);
      sfb.append("&timeStamp=");
      sfb.append(timeStamp);
      sfb.append("&invokeEditDirectly=false");
      sfb.append("&isPopup=false");

      // Process the request object to obtain the table data and set it in Table bean
      tableBean.setTableData(context, pageContext,request, timeStamp, PersonUtil.getAssignments(context));
      
    } catch (Exception ex) {
      ContextUtil.abortTransaction(context);
      if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        emxNavErrorObject.addMessage(ex.toString().trim()); 
      String errorMsg = ex.toString().trim();
      %>
  <script type="text/JavaScript">
           alert("<%=errorMsg%>");
        </script>
  <% 
    } finally {
      ContextUtil.commitTransaction(context);
    }
  

  tableData = tableData.size() == 0 ? tableBean.getTableData(timeStamp) : tableData;  
  HashMap tableControlMap = tableBean.getControlMap(tableData);
  requestMap = requestMap.size() == 0 ? tableBean.getRequestMap(tableData) : requestMap;
  
 
  String tableRowIdList[] = emxGetParameterValues(request, "emxTableRowId");
  MapList relBusObjList = tableBean.getFilteredObjectList(tableData);
  tableBean.setEditObjectList(context, timeStamp, relBusObjList, null);  
  String strtitle = emxGetParameter(request, "templateTitle") + " Experience"; 
%>
  <title><%=strtitle%></title>

  <script type="text/JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
  <script type="text/JavaScript" src="../common/scripts/emxNavigatorHelp.js"></script>
  <script type="text/JavaScript" src="../common/scripts/emxUIPopups.js"></script>
  <script type="text/JavaScript" src="../common/scripts/emxUICalendar.js"></script>
  <script type="text/JavaScript" src="../common/scripts/emxUIFormUtil.js"></script>
  <script type="text/JavaScript" src="../common/scripts/emxUITableEditUtil.js"></script>
  <script type="text/JavaScript" src="../common/scripts/emxUITableEditHeaderUtil.js"></script>

  <script type="text/JavaScript">
     addStyleSheet("emxUIDefault");
     addStyleSheet("emxUIDialog");
     addStyleSheet("emxUIToolbar");
     addStyleSheet("emxUICalendar");
     addStyleSheet("emxUIMenu");
  </script>
  <%@include file = "../emxStyleDefaultInclude.inc"%>
  <%@include file = "../emxStyleDialogInclude.inc"%>

  <script type="text/JavaScript">
   var cancelProcessParamExists = "false";
   
   function onSubmit(){
       
         var forwardURL = '../common/emxNavigator.jsp?objectId=<%=objectId%>';
         var newURL = '../common/emxFrameworkContextManager.jsp?forwardUrl='+forwardURL+'&SecurityContext=' + '<%=XSSUtil.encodeForURL(context, securityContext)%>';
         console.log("frame for submit "+newURL);
         
         var submitFrame = findFrame(parent, "submitFrame");
         submitFrame.document.location.href =  newURL;
        
   }
   
   function onSubmitFrameLoad(){
       
       var submitFrame = findFrame(parent, "submitFrame");
       if(submitFrame.document.location.href === 'about:blank') {
         return;
       }
       document.forms[0].cancelProcess.value = "false";

        var bodyFrame = findFrame(parent, "formEditDisplay");
    
        var temparray = fieldObjs.keySet();
        var isValid = true;
        for(var n=0; n < temparray.length; n++)
        {
           var tempobj = fieldObjs.get(temparray[n]);
           //if(fieldObjs[n] == null || fieldObjs[n] == "undefined" || fieldObjs[n] == "null" || fieldObjs[n] == "")
           if(tempobj == null || tempobj == "undefined" || tempobj == "null" || tempobj == "")
           {
               break;
           }
           else
           {
              if(!validateTableFields(tempobj))
              {
                  isValid = false;
              };
           }
          }
        
        if(!isValid){
            alert("Incorrect form details");
            return;
        }
       
            var target = "formEditHidden";
            var theForm = bodyFrame.document.forms["editDataForm"];
            theForm.elements["isPopup"][0].value = "false"
            theForm.target = target;

            var timeStamp=theForm.timeStamp.value;
            var objCount = 0;
            if(theForm.objCount){
                objCount = theForm.objCount.value;
            }
            if (validatemxLinks(theForm, "edit", "table", timeStamp, objCount)) {
                  document.forms["massUpdateForm"].clearEditObjList.value = "false";        
            theForm.action = "../simulationcentral/smaTemplateTableEditProcess.jsp?";          
            var ss = getUpdatedString();
            if(theForm.updatedfieldmap){
                theForm.updatedfieldmap.value = ss;
            }
            addSecureToken(theForm);
            theForm.submit();
            removeSecureToken(theForm);
            }
        
        
        document.forms[0].cancelProcess.value = "true";
   }
   
   function onClose(){
       
       var closeTimeStamp = {
               TEMPLATE_EDIT_TIMESTAMP : "<%=TEMPLATE_EDIT_TIMESTAMP%>",
               OPERATION : "close"
           };
           var contentFrame = getTopWindow().top;
           closeTimeStamp = JSON.stringify(closeTimeStamp);
           contentFrame.postMessage(closeTimeStamp, "*");
           
       //console.log("Fire a post message to widget, to clear this iframe");   
   }
   
   function windowClose()
   {       
     var cancelProcess=document.forms[0].cancelProcess.value;
     if(document.forms[0].clearEditObjList)
     {
       var clearEOList = document.forms[0].clearEditObjList.value;
       if(clearEOList == 'true') {

         var objHiddenFrame = findFrame(parent, "tempFrameHidden");
         if(!objHiddenFrame) {
           objHiddenFrame = getTopWindow().openerFindFrame(getTopWindow(), "formViewHidden");
         }
         objHiddenFrame.document.location.href = '../common/emxTableEditCancelProcess.jsp?timeStamp=<%=XSSUtil.encodeForURL(context, timeStamp)%>&cancelProcess=' + cancelProcess;
       }
     }
     else
     {
         var objHiddenFrame = findFrame(parent, "formEditHidden");
         objHiddenFrame.document.location.href = '../common/emxTableEditCancelProcess.jsp?timeStamp=<%=XSSUtil.encodeForURL(context, timeStamp)%>&cancelProcess=' + cancelProcess;
     }
   }
   
   function loadpage()
   {
       
     var toppage = getTopWindow().document.location.href;
     //alert("toppage" + toppage);
     if(toppage.indexOf("smaTemplateOptionsEdit.jsp") < 0)
     { 
       var editFrame = findFrame(parent,"formEditDisplay");
       editFrame.document.forms[0].isPopup.value = 'false';
       var cnlImg = document.getElementById('cancelImage');
       var cnlTxt = document.getElementById('cancelText');
       cnlTxt.innerHTML = "";
       cnlImg.innerHTML = "";
     }

     if(!isIE)
           {
               emxUICore.addEventHandler(window, "beforeunload", windowClose);
       }
       else
       {
           emxUICore.addEventHandler(window, "unload", windowClose);
       }

   }

   function cleanupEditSession(timeStamp, invokeEditDirectly)
   {
       if (invokeEditDirectly == "true" && cancelProcessParamExists=="false") {
           emxUICore.getData('../common/emxTableCleanupSession.jsp?timeStamp=' + timeStamp);
       }
   }
   //method to show properties of template, postMessage call is handled is xs-one-click template by onRecieveMsg method.
   function showEditPropertiesPopup(){
    var obj={
      TEMPLATE_EDIT_TIMESTAMP : "<%=TEMPLATE_EDIT_TIMESTAMP%>",
      CONETXT:"<%=securityContext%>",
      OBJECTID:"<%=objectId%>",
      OPERATION:"showProperties"
    }
    var contentFrame = getTopWindow().top;
    obj = JSON.stringify(obj);
    contentFrame.postMessage(obj, "*");    
   

   }
//method to show Life Cycle Widget , postMessage call is handled is xs-one-click template by onRecieveMsg method.
   function showLifeCyclePopup(){
    var obj={
      TEMPLATE_EDIT_TIMESTAMP : "<%=TEMPLATE_EDIT_TIMESTAMP%>",
      TITLE:"<%=strtitle%>",
      OBJECTID:"<%=objectId%>",
      OPERATION:"showWidget",
      WIDGET:"lifeCycle"
    }
    var contentFrame = getTopWindow().top;
    obj = JSON.stringify(obj);
    contentFrame.postMessage(obj, "*");   
   }

   //method to show Attribute Groups window where user can do task related to Attribute and Attribute Groups
   //  , postMessage call is handled is xs-one-click template by onRecieveMsg method.
   function showAttributeGroups(){
    var obj={
      TEMPLATE_EDIT_TIMESTAMP : "<%=TEMPLATE_EDIT_TIMESTAMP%>",
      TITLE:"<%=strtitle%>",
      OBJECTID:"<%=objectId%>",
      OPERATION:"showAttributeGroups"
    }
    var contentFrame = getTopWindow().top;
    obj1 = JSON.stringify(obj);
    contentFrame.postMessage(obj1, "*");  
   }


   function openPCWApp(){
         
          var obj={
            TEMPLATE_EDIT_TIMESTAMP : "<%=TEMPLATE_EDIT_TIMESTAMP%>",
            OPERATION:"showWidget",
            WIDGET:"PCW",
            OBJECTID : "<%=simId%>",
            OBJECTTYPE :"Simulation"
            }
          var contentFrame = getTopWindow().top;
          obj = JSON.stringify(obj);
          contentFrame.postMessage(obj, "*");   
      }
   
   emxUICore.addEventHandler(window, "load", loadpage);
    
 </script>

</head>
<style>
  .workbenchToolbar {
    box-sizing: border-box;
    height: 55px;
    padding: 5px;
    position: relative;
    left: 0;
    right: 0;
    top: 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    box-shadow: 0 2px 5px 0 rgba(0, 0, 0, 0.26);
    background-color: #F1F1F1;
    color: #368EC4;
  }

  .main-title {
    padding-left: 10px;
    font-size: 1.3em;
    font-family: Arial;
    color: #368EC4;

  }

  .save-button,
  .close-button {
    display: inline-block;
    vertical-align: middle;
    color: #368ec4;
    border-color: #368ec4;
    background-color: #f5f6f7;
    background-image: -moz-linear-gradient(top, #f5f6f7, #e2e4e3);
    background-image: -webkit-gradient(linear, 0 0, 0 100%, from(#f5f6f7), to(#e2e4e3));
    background-image: -webkit-linear-gradient(top, #f5f6f7, #e2e4e3);
    background-image: linear-gradient(to bottom, #f5f6f7, #e2e4e3);
    padding: 6px 12px;
    margin-bottom: 0;
    font-size: 14px;
    font-weight: normal;
    line-height: 1.428571429;
    text-align: center;
    white-space: nowrap;
    cursor: pointer;
    -webkit-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
    border-radius: 4px;
    font-family: "3ds-Light";
  }

  .close-button {
    color: #77797c;
    border-color: #b4b6ba;
    background-color: #f5f6f7;
  }
  .action{
    margin-right: 10px;
    cursor: pointer;
    

  }
  .flag{
    display: none;
  }
  .action:hover{
    border-bottom: 1px solid grey;
  }
  .processTitle{
    width: fit-content;
    margin-left: 10px;
    font-size: 15px;
    line-height: 20px;
    margin-top: 4px;
    cursor: pointer;

  }
  .process-icon{
    height: 20px;
    width: 20px;
    margin-right: 8px;
    box-sizing: border-box;
    display: inline-block;
    vertical-align: top;
    background-color: #f9f9f9;
    border: 1px solid #d1d4d4;
    border-radius: 4px;
  }
</style>

<body style="height: 100%;"
  onbeforeunload="cleanupEditSession('<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>', 'true')">

  <form name="massUpdateForm" method="post" onsubmit="return false" style="display: none;">
    <input type="hidden" name="clearEditObjList" value="true" />
    <input type="hidden" name="cancelProcess" value="true" />
    <input type="hidden" name="fieldType" value="textbox" />
    <input type="hidden" name="strdepth" value="" />
  </form>

  <div id="workbenchtoolbar" class="workbenchToolbar">
    <span class="main-title">
      <%=strtitle%>
      <span class="processTitle flag" id="simItem"  onclick="openPCWApp() ;">
        <img class="process-icon" src="<%=icon%>" alt="<%=simTitle%>" /><%=simTitle%>
      </span>
    </span>
    <div class="actions" style="display: flex;">
      <div class="action flag"  onclick="showAttributeGroups()">
        <img src="../webapps/SMAProcWebApp/assets/icons/32/I_SMAAttributeGroups.png" title="Attribute Group" alt="Attribute Group" />
      </div>
      <div class="action flag"  onclick="showLifeCyclePopup()">
        <img src="../webapps/SMAProcWebApp/assets/icons/32/I_Lifecycle.png" title="Lifecycle" alt="Lifecycle" />
      </div>
      <div class="action flag"  onclick="showEditPropertiesPopup()">
        <img src="../webapps/SMAProcWebApp/assets/icons/32/I_Properties.png" title="Properties" alt="Properties" />
      </div>
      <div class="editButtons">
        <%
           if(hasModifyAccess){
               %>
        <a class="footericon" href="javascript:;" onclick="onSubmit();return false">
          <button id="savebutton" class="save-button">Save changes</button>
        </a>
        <%
           }
        %>

        <a class="footericon" href="javascript:;" onclick="onClose();return false">
          <button id="closebutton" class="close-button">Close</button>
        </a>
      </div>
    </div>

  </div>
  <%
String emxTableEditBodyURL = UINavigatorUtil.encodeURL("../common/emxTableBody.jsp?"+sfb.toString());
if(hasModifyAccess){
   emxTableEditBodyURL = UINavigatorUtil.encodeURL("../common/emxTableEditBody.jsp?"+sfb.toString());
} 
 
%>
  <div id="templateOptionsFrame" style="height: calc(100% - 54px);">
    <div id="divPageBody" class="edit" style="height: 100%;">
      <iframe name="formEditDisplay" src="<%=emxTableEditBodyURL%>" width="100%" height="100%" frameborder="0"
        border="0"></iframe>
      <iframe class="hidden-frame" name="formEditHidden" HEIGHT="0" WIDTH="0"></iframe>
      <iframe class="hidden-frame" name="tempFrameHidden" HEIGHT="0" WIDTH="0"></iframe>
      <iframe class="hidden-frame" name="submitFrame" HEIGHT="0" WIDTH="0" onload="onSubmitFrameLoad()"></iframe>
    </div>
  </div>
</body>
<script type="text/javascript">

  var nodes = document.querySelectorAll(".flag");
  if(localStorage.getItem('XS_BETA') === 'true' && localStorage.getItem('XS_BETA') !== null){
   
    nodes.forEach(element => {
      element.setAttribute("style", "display: block;");
    });
    
  }
   

   
</script>
</html>
