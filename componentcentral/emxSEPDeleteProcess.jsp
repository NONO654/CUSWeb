<%--  emxSEPDeleteProcess.jsp   -  This page deletes MEP objects.
  (c) Dassault Systemes, 1993-2016.  All rights reserved.
--%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String summaryPage = emxGetParameter(request,"summaryPage");
  String url = "";
  String delId  ="";

  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  if(checkBoxId != null )
  {
      String objectIdList[] = new String[checkBoxId.length];
      try {
          for(int i=0;i<checkBoxId.length;i++){
             StringTokenizer st = new StringTokenizer(checkBoxId[i], "|");
             String sObjId = st.nextToken();
             objectIdList[i]=sObjId;
             delId=delId+checkBoxId[i]+";";
          }
          com.matrixone.apps.componentcentral.CPCPart cpcpart=new com.matrixone.apps.componentcentral.CPCPart();
          cpcpart.deleteSEPs(context,objectIdList);
      }catch(Exception Ex){
          session.putValue("error.message", Ex.toString());
      }
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="Javascript">
  var tree = getTopWindow().objDetailsTree;
  var isRootId = false;

  if(tree != null){
  if (tree.root != null) {
  var parentId = tree.root.id;
  var parentName = tree.root.name;

<%
  StringTokenizer sIdsToken = new StringTokenizer(delId,";",false);
  while (sIdsToken.hasMoreTokens()) {
    String RelId = sIdsToken.nextToken();
%>
    var objId = '<xss:encodeForJavaScript><%=RelId%></xss:encodeForJavaScript>';
    tree.getSelectedNode().removeChild(objId);

     if(parentId == objId ){
        isRootId = true;
     }
<%
  }
%>
  }
}
	 if(isRootId) {
      var url =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + parentId;
      var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
      if (contentFrame) {
        contentFrame.location.replace(url);
      }
      else {
        getTopWindow().refreshTablePage();
      }
    } else {
		if(window.name =="hiddenFrame" || window.name =="listHidden")
			getTopWindow().refreshTablePage();
		else{
        	getTopWindow().closeWindow();
        }

    }
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>



