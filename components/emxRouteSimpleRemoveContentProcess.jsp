<%--  emxRouteWizardRemoveContentProcess.jsp - Removes Content from the route .
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteSimpleRemoveContentProcess.jsp.rca 1.1.2.5 Wed Oct 22 16:18:04 2008 przemek Experimental przemek $

--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
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

String relatedObjectId  =  (String) formBean.getElementValue("objectId");
String routeId          =  (String) formBean.getElementValue("routeId");
String parentId         =  (String) formBean.getElementValue("parentId");
String scopeId          =  (String) formBean.getElementValue("scopeId");
String portalMode        =  (String) formBean.getElementValue("portalMode");
String selscope          =  (String) formBean.getElementValue("selscope");
String supplierOrgId     =  (String) formBean.getElementValue("supplierOrgId");
String suiteKey      =  (String) formBean.getElementValue("suiteKey");
String documentID    =  (String) formBean.getElementValue("documentID");
String sContentId    =  (String) formBean.getElementValue("contentId");
String routeStart = emxGetParameter(request,"routeInitiateManner");
String allowDelegation = emxGetParameter(request,"allowDelegation");
String workspaceFolderId = emxGetParameter(request,"workspaceFolderId");
String workspaceFolder = emxGetParameter(request,"workspaceFolder");
String sRouteInstructions      = emxGetParameter(request,"routeInstructions");
String sRouteAction     = emxGetParameter(request,"routeAction");
String sRouteDueDate      = emxGetParameter(request,"routeDueDate");
String routeMemberFilter=emxGetParameter(request,"routeMemberFilter");
String routeMemberString=emxGetParameter(request,"routeMemberString");
String routeDueDateMSValue=emxGetParameter(request,"routeDueDateMSValue");
if(UIUtil.isNotNullAndNotEmpty(sRouteInstructions)){
	sRouteInstructions= FrameworkUtil.findAndReplace(sRouteInstructions, "E:N:T:E:R", "\n");
	}

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
/*
        If there are any contentId's, Remove them from "hashRouteWizFirst" data structure.
        Most of the code deals with removal of "Uploaded External Files", which we can remove at later point of time
*/
try
{
    if (sContentIds != null  && !sContentIds.equals("null"))
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
                if (upLoadedFilesMapList != null && upLoadedFilesMapList.size() > 0 && !upLoadedFilesMapList.equals("null"))
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
              formBean.setElementValue("ContentID",sFinalContents);

              hashRouteWizFirst.put("routeInitiateManner",routeStart);
              hashRouteWizFirst.put("allowDelegation",allowDelegation);

              hashRouteWizFirst.put("routeAction",sRouteAction);

              hashRouteWizFirst.put("routeDueDate",sRouteDueDate);

              hashRouteWizFirst.put("routeInstructions",sRouteInstructions);

              hashRouteWizFirst.put("routeMemberFilter",routeMemberFilter);

              hashRouteWizFirst.put("routeMemberString",routeMemberString); 

            
            formBean.setElementValue("hashRouteWizFirst",hashRouteWizFirst);

            formBean.setFormValues(session);


        }
} catch (Exception ex ) {
         System.out.println("Exception................................"+ex);
        session.putValue("error.message",ex);
}

%>

<script language="javascript">
var routeInstructions1= <%= sRouteInstructions%>;
routeInstructions1=jsTrim(thisForm.routeInstructions1.value+"");
routeInstructions1=encodeURIComponent(routeInstructions1);
routeInstructions1= routeInstructions1.replace(/%0A/g,"E:N:T:E:R");
</script>

<form name="newForm" target="_parent">
  <input type="hidden" name="objectId"   value="<xss:encodeForHTMLAttribute><%=relatedObjectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="routeId"    value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="parentId"   value="<xss:encodeForHTMLAttribute><%=parentId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="statesWithIds"   value="<xss:encodeForHTMLAttribute><%=statesWithIds%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="routeDueDateMSValue"   value="<xss:encodeForHTMLAttribute><%=routeDueDateMSValue%></xss:encodeForHTMLAttribute>"/>
</form>

<script language="javascript">
var url='emxRouteCreateSimpleDialogFS.jsp?statesWithIds="<%=XSSUtil.encodeForURL(context, statesWithIds)%>"&keyValue="<%=XSSUtil.encodeForURL(context, keyValue)%>"&removeContent=true&routeInstructions="+routeInstructions1';
 document.newForm.action = url;
 document.newForm.submit();
</script>
</body>
</html>


