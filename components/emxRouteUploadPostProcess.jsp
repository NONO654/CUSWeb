<%--  emxRouteUploadPostProcess.jsp  --  Connecting Contents to Route from 
                                         Upload External

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
        Map objectMap  = (Map) request.getAttribute("objectMap");
        Map requestMap = (Map) request.getAttribute("requestMap");

        String keyValue = (String)requestMap.get("keyValue");
        if (keyValue == null)
        {
          keyValue = formBean.newFormKey(session);
        }

        Hashtable hashRte = new Hashtable();
        java.util.Set keys = requestMap.keySet();
        Iterator keysItr = keys.iterator();
	    boolean isScopeSelectedFlag = false;
        while (keysItr.hasNext())
        {
           String key = (String)keysItr.next();
           Object value = (Object)requestMap.get(key);
           if (value == null){
             value = "";
			}
           hashRte.put(key,value);
	       if(!isScopeSelectedFlag && key.equals("selscope") && value.equals("ScopeName")){
        	   isScopeSelectedFlag = true;
           }
        }
	    if(isScopeSelectedFlag){
			String workspaceFolderId = (String)hashRte.get("workspaceFolderId");
			String workspaceFolder = (String)hashRte.get("workspaceFolder");
			hashRte.put("selscopeId", workspaceFolderId==null?"":workspaceFolderId);
	    	hashRte.put("selscopeName", workspaceFolder==null?"":workspaceFolder);
        }

        formBean.setElementValue("hashRouteWizFirst", hashRte);
        formBean.setFormValues(session);

        String docId = "";
 	StringList objectIds = (StringList)objectMap.get("objectId");
        Iterator objItr = objectIds.iterator();
        if (objItr.hasNext())
          docId = (String)objItr.next();

        String ContentID = (String)session.getValue("RouteContent");
        if ((ContentID == null) || ("null".equals(ContentID)))
          ContentID = "";

        int contentLen = ContentID.length();
        int len = contentLen + docId.length() + 2;

        StringBuffer documentID = new StringBuffer(len);
        if (contentLen > 0)
        {
          documentID.append(ContentID);
          documentID.append("~");
        }
        documentID.append(docId);
%>
<script language="javascript">

var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");

getTopWindow().getWindowOpener().getTopWindow().document.location.href="emxRouteWizardCreateDialogFS.jsp?ContentID=<%=XSSUtil.encodeForURL(context, documentID.toString())%>&keyValue=<%=XSSUtil.encodeForURL(context, keyValue)%>&addContent=true";
getTopWindow().closeWindow();

</script>
