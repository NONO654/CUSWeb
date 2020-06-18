<%--  emxComponentsConfigurableTableDisconnectProcess.jsp -  This page disconnects the selected objects.
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxDeCollobrateProcess.jsp.rca 1.4 Wed Oct 22 16:18:42 2008 przemek Experimental przemek $
--%>

 
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

  DomainObject rel = DomainObject.newInstance(context);
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String summaryPage = emxGetParameter(request,"summaryPage");
  String portalMode = emxGetParameter(request, "portalMode");
  
  boolean isPortalPage = false;

  if(portalMode != null && "true".equalsIgnoreCase(portalMode)) {
    isPortalPage = true;
  }

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
             while (st.hasMoreTokens()) {
                 sObjId = st.nextToken();
             }      
             delId=delId+sObjId+";";

          }
          //code for disconnecting 
		  ContextUtil.pushContext(context);
          DomainRelationship.disconnect(context,objectIdList);
		  ContextUtil.popContext(context);
      }catch(Exception Ex){
		  ContextUtil.popContext(context);
          session.putValue("error.message", Ex.toString());
      }
  }
%>


<script language="Javascript">
  var tree = getTopWindow().objStructureTree;
  var isRootId = false;

if (tree)
{
  if (tree.root != null) {  
  var parentId = tree.root.id;
  var parentName = tree.root.name;

<%
  StringTokenizer sIdsToken = new StringTokenizer(delId,";",false);
  while (sIdsToken.hasMoreTokens()) {
    String RelId = sIdsToken.nextToken();
%> 

    var objId = '<%=XSSUtil.encodeForJavaScript(context, RelId)%>';
    tree.deleteObject(objId);
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
      var url =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + parentId + "&emxSuiteDirectory=<%=XSSUtil.encodeForURL(context, appDirectory)%>";
      var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");  
      if (contentFrame) 
            {
             contentFrame.location.replace(url);
            }  
 // Added for Refresh functionality
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
    // Added for Refresh functionality
    else 
        {   
    	    //XSSOK
            if("<%=isPortalPage%>" == "true")
            {
                parent.document.location.href=parent.document.location.href;
            } else if(getTopWindow().refreshTablePage)
            {  
               getTopWindow().refreshTablePage();
            }  
            else
            {  
                 getTopWindow().location.href = getTopWindow().location.href;
            }
        } 
</script>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>



