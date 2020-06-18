<%--  emxComponentsDiscussionDeleteProcess.jsp  --  Deletes a Discussion

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsDiscussionDeleteProcess.jsp.rca 1.7 Wed Oct 22 16:18:19 2008 przemek Experimental przemek $
 --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<%
  String[] strMessageIds = emxGetParameterValues(request, "emxTableRowId");
  String[] strDiscussionIds = null;
  String[] strDelMsgIds= null;
  String messageIds = ComponentsUIUtil.arrayToString(strMessageIds, "~");
  String objectId  = emxGetParameter(request, "objectId");
  String objID     = emxGetParameter(request, "objID");
  String jsTreeID  = emxGetParameter(request, "jsTreeID");
  String suiteKey  = emxGetParameter(request, "suiteKey");
  String uiType  = emxGetParameter(request, "uiType");
  String deleteType  = emxGetParameter(request, "deleteType");
  String strType = null;
  Iterator itr = null;
  int j=0;
  Message message  = (Message) DomainObject.newInstance(context,DomainConstants.TYPE_MESSAGE);
  Route route = (Route) DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  DomainObject BaseObject   = DomainObject.newInstance(context,objectId);
  String messageID = null;
  MapList messageMapList=  new MapList();
  boolean success = true;
  StringList selStmts = new StringList();
  selStmts.add(BaseObject.SELECT_ID);

  // if the type to delete is a Reply, delete just that reply and reload the page
  if(deleteType != null && deleteType.equals("reply"))
  {
    message.deleteReply(context, BaseObject);
%>
	<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="Javascript">
      var discussionTreeDisplay = openerFindFrame(getTopWindow(), "discussionTreeDisplay");
     
    if(discussionTreeDisplay) {
    discussionTreeDisplay.parent.doFilter();
    }else{
         parent.parent.frames[0].frames[1].location = "../components/emxComponentsDiscussionTreeFrame.jsp?suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components&objectId=<%=XSSUtil.encodeForURL(context, objID)%>";
    }
    </script>
<%
    return;

}

  if(strMessageIds != null) {
    StringList uniqueMess = new StringList();
    strDiscussionIds = new String[strMessageIds.length];
    for(int i =0;i < strMessageIds.length; i++){
        // IR-029748V6R2011
        if( strMessageIds[i].indexOf("|") >-1 ) {
            strMessageIds[i] = strMessageIds[i].substring(strMessageIds[i].indexOf("|")+1);
        }
      // IR-029748V6R2011 - end changes
       strDiscussionIds[i] = strMessageIds[i];
      BaseObject.setId(strMessageIds[i]);
      HashMap rootMap = new HashMap();
      rootMap.put(BaseObject.SELECT_ID,strMessageIds[i]);


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

      if(messageMapList!= null){
        if (messageMapList.size() == 0){
          messageMapList.add(0,rootMap);
        }
      ListIterator messListItr = messageMapList.listIterator();
      while(messListItr.hasNext())
      {
          Map messMap = (Map)messListItr.next();
          messageID = (String)messMap.get(BaseObject.SELECT_ID);

            if(!uniqueMess.contains(messageID)){
               uniqueMess.addElement(messageID);
            }

        }
    }
 }

 itr = uniqueMess.iterator();

strDelMsgIds = new String[uniqueMess.size()];
  while(itr.hasNext()){
    //DomainObject mess = new DomainObject((String)itr.next());
    //mess.deleteObject(context);

    strDelMsgIds[j++] = (String)itr.next();
  }

  if(strDelMsgIds != null){
	try{
    DomainObject.deleteObjects(context,strDelMsgIds);
	}catch(Exception e){
		success = false;
		String errorMessage=EnoviaResourceBundle.getProperty(context,
                 "emxComponentsStringResource",
                 context.getLocale(),
                 "emxComponents.Common.DeleteErrorMessage");
%>
		<script language="javascript">
		alert("<%=errorMessage%>");	
		</script>
<%
	}
  }
}
%>

<script language="Javascript">
<%
if(success){
%>
var tree = getTopWindow().objStructureTree;
if(tree){
<%
  if(strMessageIds != null) {
    for(int i =0;i < strMessageIds.length; i++){
%>
      tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, strDiscussionIds[i].trim())%>");
<%
    }
  }
%>
}
var fromSB = "structureBrowser" == "<%=XSSUtil.encodeForJavaScript(context, uiType)%>";
if(fromSB){
      var selectedMembers = "<%=XSSUtil.encodeForJavaScript(context, messageIds)%>";
      parent.emxEditableTable.removeRowsSelected(selectedMembers.split("~"));
}
<%
}
%>
var listDisplay  = getTopWindow().findFrame(parent, "listDisplay");
if (listDisplay) {
listDisplay.parent.location.href = listDisplay.parent.location.href;
	} else{
  getTopWindow().refreshTablePage();
}

</script>

