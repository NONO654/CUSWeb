<%--  emxpartDisconnectSubstitute.jsp  - To disconnect substitute from a part.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@ page import="com.matrixone.apps.engineering.RelToRelUtil" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  DomainObject rel = DomainObject.newInstance(context);
  String jsTreeID         = emxGetParameter(request,"jsTreeID");
  String objectId         = emxGetParameter(request,"objectId");
  String initSource       = emxGetParameter(request,"initSource");
  String suiteKey         = emxGetParameter(request,"suiteKey");
  String summaryPage      = emxGetParameter(request,"summaryPage");
  boolean hasException=false;
  String[] sCheckBoxArray = emxGetParameterValues(request, "emxTableRowId");
  String delId ="";
  String url    = "";
  if(sCheckBoxArray != null)
    {
       for(int i=0; i < sCheckBoxArray.length; i++)
          {
             StringTokenizer st = new StringTokenizer(sCheckBoxArray[i], "|");
			 //Getting selected EBOM Substitute relationship id
             String sRelId = st.nextToken();
			 try{
				 //Disconnecting EBOM Substitute relationship
				 
				 RelToRelUtil.disconnect(context,sRelId);
				 url = summaryPage + "?objectId=" + objectId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey;
				}
				catch(Exception Ex)
				{
					session.putValue("error.message", Ex.toString());
					hasException=true;

				}
		  }
    }

%>
<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

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
//XSSOK
    var objId = '<%=RelId%>';
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
    	//XSSOK
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

