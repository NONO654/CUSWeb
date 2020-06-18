<%--  emxCPCEPDisconnectProcess.jsp
  (c) Dassault Systemes, 1993-2016.  All rights reserved.
--%>



<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxCPCInclude.inc"%>
<%@page import="matrix.db.BusinessObject"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>


<%

String objectId = emxGetParameter(request,"objectId");
String suiteKey = emxGetParameter(request,"suiteKey");
//DebugUtil.setDebug(true);

com.matrixone.apps.componentcentral.CPCPart part = new com.matrixone.apps.componentcentral.CPCPart(objectId);

  String jsTreeID = emxGetParameter(request,"jsTreeID");

  String initSource = emxGetParameter(request,"initSource");
  String summaryPage = emxGetParameter(request,"summaryPage");
  String url = "";
  String delId  ="";

  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  if(checkBoxId != null )
  {
      try{
          String relIdList[] = new String[checkBoxId.length];
          for(int i=0;i<checkBoxId.length;i++){

             StringTokenizer st = new StringTokenizer(checkBoxId[i], "|");
             String sRelId = st.nextToken();
             BusinessObject FromObject = null;
             relIdList[i] = sRelId;
            }
	        part.disconnectEPfromSEP(context,relIdList);

          url = summaryPage + "?objectId=" + objectId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey;

      }catch(Exception Ex){
          session.putValue("error.message", Ex.toString());
      }
  }
%>


<script language="Javascript">
  var tree = getTopWindow().objDetailsTree;
  var isRootId = false;

if (tree)
{
if (tree.root != null)
    {
      var parentId = tree.root.id;
      var parentName = tree.root.name;

<%
  StringTokenizer sIdsToken = new StringTokenizer(delId,";",false);
  while (sIdsToken.hasMoreTokens())
      {
        String RelId = sIdsToken.nextToken();
%>
    var objId = '<xss:encodeForJavaScript><%=RelId%></xss:encodeForJavaScript>';
    tree.getSelectedNode().removeChild(objId);

     if(parentId == objId )
         {
            isRootId = true;
          }
<%
  }
%>
    }
}
    if(isRootId)
    {
      var url =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + parentId + "&emxSuiteDirectory=<%=appDirectory%>";
      var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
      if (contentFrame)
          {
            contentFrame.location.replace(url);
           }
      else
          {
                    if(getTopWindow().refreshTablePage)
                    {
                        getTopWindow().refreshTablePage();
                     }
                    else
                    {
                        getTopWindow().location.href = getTopWindow().location.href;
                     }
            }
     }
      else
          {
            parent.location.href = parent.location.href;
          }

</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

