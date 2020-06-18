<%--  emxRouteWizardRemoveContentProcess.jsp - Removes Content from the route .
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteWizardRemoveContentProcess.jsp.rca 1.14 Wed Oct 22 16:18:55 2008 przemek Experimental przemek $

--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@page import = "com.matrixone.apps.common.Route" %>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<html>
<body>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%


String keyValue=emxGetParameter(request,"keyValue");

if(keyValue == null)
{
  keyValue = formBean.newFormKey(session);
}
formBean.processForm(session,request,"keyValue");

String statesWithIds = (String) emxGetParameter(request, "statesWithIds");
if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(statesWithIds)) {
	statesWithIds = "";
}

Route routeObject       = (Route) DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
DomainObject BaseObject = DomainObject.newInstance(context);

String sContentIds[]    = emxGetParameterValues(request, "chkItem1");
String sFromPage        = emxGetParameter(request, "fromPage");
String sRoles           = request.getParameter("selRoles");
String sGroup           =request.getParameter("selGroup");
StringList roleList = FrameworkUtil.split(sRoles,";");
StringList groupList = FrameworkUtil.split(sGroup,";");

String templateId       =  (String) formBean.getElementValue("templateId");
String templateName     =  (String) formBean.getElementValue("template");
String relatedObjectId  =  (String) formBean.getElementValue("objectId");
String routeId          =  (String) formBean.getElementValue("routeId");
String parentId         =  (String) formBean.getElementValue("parentId");
String scopeId          =  (String) formBean.getElementValue("scopeId");
String routeAutoName    =  (String) formBean.getElementValue("routeAutoName");
String routeName        =  (String) formBean.getElementValue("routeName");
String routeDescription =  (String) formBean.getElementValue("txtdescription");
String checkPreserveOwner =  (String) formBean.getElementValue("checkPreserveOwner");

String selectedAction    =  (String) formBean.getElementValue("selectedAction");
String portalMode        =  (String) formBean.getElementValue("portalMode");
String routeBasePurpose  =  (String) formBean.getElementValue("routeBasePurpose");

String selscope          =  (String) formBean.getElementValue("selscope");
String routeCompletionAction    =  (String) formBean.getElementValue("routeCompletionAction");

String supplierOrgId     =  (String) formBean.getElementValue("supplierOrgId");
String suiteKey      =  (String) formBean.getElementValue("suiteKey");

String documentID    =  (String) formBean.getElementValue("documentID");
String sContentId    =  (String) formBean.getElementValue("contentId");
String chkRouteMembers  =  (String) formBean.getElementValue("chkRouteMembers");
String routeStart = emxGetParameter(request,"routeStart");
String visblToParent = emxGetParameter(request,"visblToParent");
String workspaceFolderId = emxGetParameter(request,"workspaceFolderId");
String workspaceFolder = emxGetParameter(request,"workspaceFolder");
routeAutoName = emxGetParameter(request,"routeAutoName");



String treeLabel        = "";
String foldId           = "";
String tempTreeLabel    = "";
MapList folderMapList  =  new MapList();

if(sFromPage == null) {
        sFromPage = "";
}

String removeMember = (String) formBean.getElementValue("removeMember");

if(removeMember == null){
        removeMember = "blank";
}

try
{
   if (sContentIds != null && (routeId != null && !routeId.equals("null")  && !routeId.equals("")))
        {  
                routeObject.setId(routeId);
                routeObject.RemoveContent(context, sContentIds);
        } 
    else if (sContentIds != null && sFromPage.equals("routeWizard"))
        {
                Hashtable routeDetails  =  (Hashtable) formBean.getElementValue("hashRouteWizFirst");
                MapList upLoadedFilesMapList      = (MapList)routeDetails.get("uploadedDocIDs");
                MapList newUpLoadedMapList = new MapList();
                String sFinalContents = "";
                StringList sRemoveIdList = new StringList();
                for (int i = 0; i< sContentIds.length ; i++)
                {
                        sRemoveIdList.addElement(sContentIds[i]);
                }
                if (upLoadedFilesMapList != null && upLoadedFilesMapList.size() > 0)
                {
                        Iterator upLoadedFilesMapListItr = upLoadedFilesMapList.iterator();
                        while(upLoadedFilesMapListItr.hasNext())
                        {
                                Map upLoadedMap = (Map)upLoadedFilesMapListItr.next();
                                if (upLoadedMap != null)
                                {
                                        String docId = (String)upLoadedMap.get("docID");
                                        if (!sRemoveIdList.contains(docId))
                                        {
                                                newUpLoadedMapList.add(upLoadedMap);
                                        }else{
                                                BaseObject.setId(docId);
                                                BaseObject.deleteObject(context);
                                                // updating tree frame
                                                foldId = (String)upLoadedMap.get("folderId");
                                                folderMapList = WorkspaceVault.getAllParentWorkspaceVaults(context,foldId);
                                                if(folderMapList != null && folderMapList.size() > 0 )
                                                {
                                                        Iterator folderMapListItr = folderMapList.iterator();
                                                        while(folderMapListItr.hasNext())
                                                        {
                                                                Map folderMap = (Map)folderMapListItr.next();
                                                                String folId = (String)folderMap.get(DomainObject.SELECT_ID);
                                                                treeLabel = UITreeUtil.getUpdatedTreeLabel(application,session,request,context,folId,(String)null,appDirectory,sLanguage);
                                                                if(treeLabel != null && !"".equals(treeLabel))
                                                                {
                                                                        tempTreeLabel +=folId+"<**>"+treeLabel+"<**>";
                                                                }
                                                        }
                                                }
                                                treeLabel = UITreeUtil.getUpdatedTreeLabel(application,session,request,context,foldId,(String)null,appDirectory,sLanguage);
                                                if(treeLabel != null && !"".equals(treeLabel))
                                                {
                                                        tempTreeLabel +=foldId+"<**>"+treeLabel+"<**>";
                                                }
                                        }
                                }
                        }
                }
                formBean.setElementValue("uploadedDocIDs", newUpLoadedMapList);
                Hashtable hashRouteWizFirst  =  (Hashtable) formBean.getElementValue("hashRouteWizFirst");
                String sDocID               = (String)hashRouteWizFirst.get("documentID");
                StringTokenizer strTokDocsIds = new StringTokenizer(sDocID, "~");
                while (strTokDocsIds.hasMoreTokens())
                {
                        String strId = (String)strTokDocsIds.nextToken();
                        if(!sRemoveIdList.contains(strId))
                        {
                                sFinalContents = sFinalContents + strId+ "~";
                        }
                }
                hashRouteWizFirst.put("documentID",sFinalContents);
                formBean.setElementValue("hashRouteWizFirst",hashRouteWizFirst);
                formBean.setElementValue("ContentID",sFinalContents);
                formBean.setElementValue("routeDescription",routeDescription);
                formBean.setElementValue("checkPreserveOwner",checkPreserveOwner);
                
                Route.setRouteWizardHashtable(hashRouteWizFirst, routeName, routeAutoName, templateId,
               		 templateName, routeBasePurpose, routeCompletionAction, selscope, workspaceFolderId,
               		 workspaceFolder, parentId, routeStart, visblToParent);
                hashRouteWizFirst.put("checkPreserveOwner",checkPreserveOwner);
                formBean.setElementValue("removeContent","true");
                formBean.setFormValues(session);

        }else if (sFromPage.equals("changeScope"))
        {

                //THIS CONDITION IS USED TO REMOVE THE CONTENT WHEN SCOPE IS CHANGED IN STEP1

                Hashtable hashRouteWizFirst = (Hashtable)formBean.getElementValue("hashRouteWizFirst");

// Commented for IR-030694V6R2011 Dated 22nd Feb 2010 Begins.
//                hashRouteWizFirst.put("documentID","");
// Commented for IR-030694V6R2011 Dated 22nd Feb 2010 Ends.

                Route.setRouteWizardHashtable(hashRouteWizFirst, routeName, routeAutoName, templateId,
               		 templateName, routeBasePurpose, routeCompletionAction, selscope, workspaceFolderId,
               		 workspaceFolder, parentId, routeStart, visblToParent);
                hashRouteWizFirst.put("routeDescription",routeDescription);
                hashRouteWizFirst.put("checkPreserveOwner",checkPreserveOwner);

               
// Commented for IR-030694V6R2011 Dated 22nd Feb 2010 Begins.
//                formBean.setElementValue("ContentID","");
// Commented for IR-030694V6R2011 Dated 22nd Feb 2010 Ends.

				formBean.setElementValue("removeContent","true");

                formBean.setFormValues(session);


        }else if(removeMember.equals("removeMember"))
        {
                //THIS CONDITION IS USED TO REMOVE MEMBERS IN STEP2
            String[] selPersons   = emxGetParameterValues(request, "chkItem");
            MapList routeMemberMapList =(MapList)formBean.getElementValue("routeMemberMapList");
            MapList routeRoleMapList =(MapList)formBean.getElementValue("routeRoleMapList");
            MapList routeGroupMapList =(MapList)formBean.getElementValue("routeGroupMapList");
            
            // Begin : Bug 341297 : Code modification
            MapList taskMapList =(MapList)formBean.getElementValue("taskMapList");
            if (taskMapList == null) {
                taskMapList = new MapList();
            }
            // End : Bug 341297 : Code modification
            
            boolean hasRole=false;
            boolean hasGroup=false;
            int selPersonCount = 0;
            java.util.List selectedPersonList = Arrays.asList(selPersons);
            Iterator routeMemberMapListItr = routeMemberMapList.iterator();
                    while(routeMemberMapListItr.hasNext()){
                           HashMap memberMap = (HashMap)routeMemberMapListItr.next();
                           String memid = (String)memberMap.get("id");
                           String memName = (String)memberMap.get("name");
                           hasRole=false;
                           hasGroup=false;
                           if(memid.equals("Role"))
                           {
                                   hasRole=roleList.contains(memName);
                                   if(hasRole){
                                           routeMemberMapListItr.remove();
                                           routeRoleMapList.remove(memberMap);
                                           selPersonCount++;
                                   }
                           }else if(memid.equals("Group"))
                           {
                                   hasGroup=groupList.contains(memName);
                                   if(hasGroup){
                                           routeMemberMapListItr.remove();
                                           routeGroupMapList.remove(memberMap);
                                           selPersonCount++;
                                   }
                           }else if(selectedPersonList.contains(memid))
                           {
                                  routeMemberMapListItr.remove();
                                  selPersonCount++;
                           }
                           if(selPersonCount == selPersons.length){
                               break;
                           }                        
                    }

                    // Begin : Bug 341297 : Code modification
                    // Remove the corresponding tasks for the person/group/group
                    Map mapTaskInfo = null;
                    String strPersonId = null;
                    String strName = null;
                    
                    Iterator taskMapListItr = taskMapList.iterator();
                    while(taskMapListItr.hasNext()) {
                        mapTaskInfo = (Map)taskMapListItr.next();
                        
                        strPersonId = (String)mapTaskInfo.get("PersonId");
                        strName = (String)mapTaskInfo.get("name");
                        if (strName == null) {
                            strName = (String)mapTaskInfo.get("PersonName");
                        }
                        
                        if("Role".equals(strPersonId)) {
   	                     if(roleList.contains(strName)) {
   	                         taskMapListItr.remove();
   	                     }
                        }
                        else if("Group".equals(strPersonId)) {
   						if(groupList.contains(strName)) {
   						    taskMapListItr.remove();
   						}
                        }
                        else if(selectedPersonList.contains(strPersonId)) {
                            taskMapListItr.remove();
                        }
                 	}
                formBean.setElementValue("routeMemberMapList",routeMemberMapList);
                formBean.setElementValue("taskMapList",taskMapList);
                formBean.setElementValue("routeRoleMapList", routeRoleMapList);
                formBean.setElementValue("routeGroupMapList", routeGroupMapList);
                formBean.setElementValue("removeMember", "");
                formBean.setFormValues(session);

//Bug 296093 - Added ExtraCondtion for removing person as well as tasks related to that person.

        }
} catch (Exception ex ) {
        session.putValue("error.message",ex.toString());
}

%>

<form name="newForm" target="_parent">
  <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="template" value="<xss:encodeForHTMLAttribute><%=templateName %></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="objectId"   value="<xss:encodeForHTMLAttribute><%=relatedObjectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="routeId"    value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="Routewizard"    value="Routewizard"/>
  <input type="hidden" name="statesWithIds" value="<xss:encodeForHTMLAttribute><%=statesWithIds%></xss:encodeForHTMLAttribute>"/>
</form>

<script language="javascript">

<%
// Bug 296093 - Added extra condition for removing person and tasks
 //if(removeMember.equals("removeMember")|| ){
 if("removeMember".equals(removeMember)|| "removePersonAndTask".equals(removeMember)){
%>
     document.newForm.action = 'emxRouteWizardAccessMembersFS.jsp?Routewizard="RouteWizard"&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>';
<%
 }else{
%>
var url='emxRouteWizardCreateDialogFS.jsp?Routewizard="RouteWizard"&statesWithIds="<%=XSSUtil.encodeForURL(context, statesWithIds)%>"&keyValue="<%=XSSUtil.encodeForURL(context, keyValue)%>"&removeContent="true"';

 document.newForm.action = url;
<%
 }
%>

  document.newForm.submit();
</script>
</body>
</html>


