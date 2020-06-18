<%--  emxTeamDiscussionDeleteProcess.jsp  --  Deletes a Discussion

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamDiscussionDeleteProcess.jsp.rca 1.20 Wed Oct 22 16:06:40 2008 przemek Experimental przemek $
 --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>

<%@include file = "emxTeamUtil.inc"%>
<%@include file = "eServiceUtil.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String[] strMessageRelIds = emxGetParameterValues(request, "emxTableRowId");
  String[] strDiscussionIds = null;
  String objectId  = emxGetParameter(request, "objectId");
  String jsTreeID  = emxGetParameter(request, "jsTreeID");
  String suiteKey  = emxGetParameter(request, "suiteKey");
  //Get the workspaceId to create the tree URL
  String workspaceId = emxGetParameter(request,"workspaceId");
  workspaceId=objectId;
  String treeUrl = "";
  WorkspaceVault folder     = (WorkspaceVault) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE_VAULT,DomainConstants.TEAM);
  Workspace workspace       = (Workspace) DomainObject.newInstance(context,DomainConstants.TYPE_WORKSPACE,DomainConstants.TEAM);
  Document document         = (Document) DomainObject.newInstance(context,DomainConstants.TYPE_DOCUMENT,DomainConstants.TEAM);
  Message message           = (Message) DomainObject.newInstance(context,DomainConstants.TYPE_MESSAGE,DomainConstants.TEAM);
  DomainObject BaseObject   = DomainObject.newInstance(context,objectId);

  String sDocument = BaseObject.TYPE_DOCUMENT;
  String sFolder   =   BaseObject.TYPE_PROJECT_VAULT;

  MapList messageMapList=  new MapList();
  Pattern typePattern = new Pattern(message.TYPE_DOCUMENT);
  Pattern relPattern = new Pattern(message.RELATIONSHIP_MESSAGE_ATTACHMENTS);

  String doc_Vault_Rel = "to["+document.RELATIONSHIP_VAULTED_OBJECTS+"].from.id";
  String relMessageAttachments = document.RELATIONSHIP_MESSAGE_ATTACHMENTS;

  StringList selStmts = new StringList();
  selStmts.add(BaseObject.SELECT_ID);
  String deleteType  = emxGetParameter(request, "deleteType");
  // if the type to delete is a Reply, delete just that reply and reload the page
  if(deleteType != null && deleteType.equals("reply"))
  {
    MapList templateMapList = BaseObject.getRelatedObjects(context,
                                                            relPattern.getPattern(),
                                                            typePattern.getPattern(),
                                                            selStmts,
                                                            new StringList(),
                                                            false,
                                                            true,
                                                            (short)0,
                                                            "",
                                                            "");
    if(templateMapList!=null){
    ListIterator listItr = templateMapList.listIterator();
      while(listItr.hasNext())
      {
        Map map = (Map)listItr.next();
        map.remove("level");
        String documentID = (String)map.get(BaseObject.SELECT_ID);

        if (documentID != null){
          document.setId(documentID);
          StringList sList = new StringList(1);
          sList.addElement(doc_Vault_Rel);
          Map wsMap = document.getInfo(context,sList);
          StringList wsList = (StringList)wsMap.get(doc_Vault_Rel);
          if (wsList!=null){
            BaseObject.disconnect(context,new RelationshipType(relMessageAttachments),true,(BusinessObject)document);
          }
          else{
            String[] sArray = new String[1];
            sArray[0] = documentID;
            document.deleteDocuments(context, sArray);
          }
        }
      }
    }
  //Get the Parent Discussion Object ID to create the tree URL,before deleting the reply object
    String messobj = BaseObject.getInfo(context, "to[" + DomainConstants.RELATIONSHIP_REPLY + "].from.id");
    String replyobj = BaseObject.getInfo(context, "to[" + DomainConstants.RELATIONSHIP_REPLY + "].id");
    DomainObject messObj = new DomainObject(messobj);
    treeUrl = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + messObj.getId() +"&emxSuiteDirectory="+appDirectory+"&mode=insert&AppendParameters=true&folderId=null&workspaceId=" + workspaceId;//message.getId()
    message.deleteReply(context, BaseObject);
%>
    <script language="Javascript">
    //Open the tree URL instead of reloading the page,which was holding the deleted object ID
       //var tree = getTopWindow().tempTree;
       var tree = getTopWindow().objStructureTree;
       //delete object as the child node gets created twise,so remove the existing one and the tree URL will create a child node
       tree.deleteObject("<%=messObj.getId()%>");
     
      //parent.location.reload();
      parent.location.href = parent.location.href;


    </script>
<%
    return;
  }

  String strType = (String) BaseObject.getInfo(context,BaseObject.SELECT_TYPE);
  if(strType.equals(BaseObject.TYPE_WORKSPACE))
  {
    //changing base object to workspace
    workspace.setId(objectId);
  }
  else if(strType.equals(sFolder))
  {
    //changing base object to folder
    folder.setId(objectId);
  }
  else if(strType.equals(sDocument) || strType.equals(BaseObject.TYPE_PACKAGE) || strType.equals(BaseObject.TYPE_RTS_QUOTATION) || strType.equals(BaseObject.TYPE_REQUEST_TO_SUPPLIER))
  {
    //changing base object to document
    document.setId(objectId);
  }

  if(strMessageRelIds != null) {
    Vector uniqueMess = new Vector();
    strDiscussionIds = new String[strMessageRelIds.length];
    for(int i =0;i < strMessageRelIds.length; i++){
      strDiscussionIds[i] = strMessageRelIds[i];
      BaseObject.setId(strMessageRelIds[i]);

      HashMap rootMap = new HashMap();
      rootMap.put(BaseObject.SELECT_ID,strMessageRelIds[i]);
      messageMapList = BaseObject.getRelatedObjects(context,
                                                            BaseObject.RELATIONSHIP_REPLY,
                                                            BaseObject.TYPE_MESSAGE,
                                                            selStmts,
                                                            new StringList(),
                                                            true,
                                                            true,
                                                            (short)0,
                                                            "",
                                                            "");

      if(messageMapList!=null){
        if (messageMapList.size() == 0){
          messageMapList.add(0,rootMap);
        }
      ListIterator messListItr = messageMapList.listIterator();
      while(messListItr.hasNext())
      {
        DomainObject mess = new DomainObject();
        Map messMap = (Map)messListItr.next();
        messMap.remove("level");
        String messageID = (String)messMap.get(BaseObject.SELECT_ID);
         if (messageID != null){
          mess.setId(messageID);
          MapList templateMapList = mess.getRelatedObjects(context,
                                                            relPattern.getPattern(),
                                                            typePattern.getPattern(),
                                                            selStmts,
                                                            new StringList(),
                                                            false,
                                                            true,
                                                            (short)0,
                                                            "",
                                                            "");

          if(templateMapList!=null){
            ListIterator listItr = templateMapList.listIterator();
            while(listItr.hasNext())
            {
              Map map = (Map)listItr.next();
              map.remove("level");
              String documentID = (String)map.get(BaseObject.SELECT_ID);

              if (documentID != null){
                document.setId(documentID);
                StringList sList = new StringList(1);
                sList.addElement(doc_Vault_Rel);
                Map wsMap = document.getInfo(context,sList);
                StringList wsList = (StringList)wsMap.get(doc_Vault_Rel);
                if (wsList!=null){
                  BaseObject.disconnect(context,new RelationshipType(relMessageAttachments),true,(BusinessObject)document);
                }
                else{
                  String[] sArray = new String[1];
                  sArray[0] = documentID;
                  document.deleteDocuments(context, sArray);
                }
              }
            }
          }
        }

        if(!uniqueMess.contains(messageID)){
           uniqueMess.addElement(messageID);
        }

      }
    }
  }
  DomainObject mess = DomainObject.newInstance(context);
  boolean isContextPushed = false;
  try{
    ContextUtil.pushContext(context);
    isContextPushed = true;
    for (int i=0;i<uniqueMess.size();i++){
      mess.setId((String)uniqueMess.elementAt(i));
      mess.deleteObject(context);
    }
  }catch(Exception e){
     session.setAttribute("error.message",e.getMessage());
  }
  finally{
    if(isContextPushed){
      ContextUtil.popContext(context);
    }
  }
}

%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript">
  //var tree = getTopWindow().tempTree;
var detailsDisplayFrame;
var contTree = getTopWindow().objStructureTree;
//Added for bug 340568
if(getTopWindow().getWindowOpener()) {
    detailsDisplayFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"detailsDisplay");
  } else {
    detailsDisplayFrame = findFrame(getTopWindow(),"detailsDisplay");
  }
//End for bug 340568

 if(contTree == null) {
        parent.location.reload();
       } else {
<%

  if(strMessageRelIds != null ){
    for(int i =0;i < strMessageRelIds.length; i++)
  {
       String strDis=strDiscussionIds[i].trim();
%>
   contTree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, strDis)%>");
 <%
   }
  }
%>
  contTree.refresh();

//Added for bug 340568
 if(detailsDisplayFrame)
	detailsDisplayFrame.document.location.href = detailsDisplayFrame.document.location.href;
 //End for bug 340568

}


</script>
