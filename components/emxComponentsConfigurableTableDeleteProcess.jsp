<%--  emxComponentsConfigurableTableDeleteProcess.jsp   -  This page deletes the selected objects.
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsConfigurableTableDeleteProcess.jsp.rca 1.8 Wed Oct 22 16:18:02 2008 przemek Experimental przemek $
--%>

 
<%@include file = "emxComponentsDesignTopInclude.inc"%>
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
  String url = "";
  String delId  ="";
  String sObjId = "";

  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  if(UINavigatorUtil.isMobile(context)){
	  checkBoxId = FrameworkUtil.getSplitTableRowIds(checkBoxId);
  }
  if(checkBoxId != null )
  {
    String objectIdList[] = new String[checkBoxId.length];
    try {  
      for(int i=0;i<checkBoxId.length;i++){
         StringTokenizer st = new StringTokenizer(checkBoxId[i], "|");
         while (st.hasMoreTokens()) {
             sObjId = st.nextToken();
         }            
         objectIdList[i]=sObjId;        
         delId=delId+checkBoxId[i]+";";
      }
      DomainAccess.deleteSecurityContextObjectifConnectedToOrg(context, objectIdList);
      DomainObject.deleteObjects(context,objectIdList);
    }catch(Exception Ex){
        session.putValue("error.message", (new FrameworkException(Ex)).toString());
    }
  }
%>

<%@include file = "emxComponentsDesignBottomInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">

var tree = parent.getTopWindow().objStructureTree;
  var isRootId = false;
  
  if (tree != null && tree.root != null) {
  var parentId = tree.root.id;
  var parentName = tree.root.name;

<%
  StringTokenizer sIdsToken = new StringTokenizer(delId,";",false);
  while (sIdsToken.hasMoreTokens()) {
    String RelId = sIdsToken.nextToken();
%>
    var objId = '<%=XSSUtil.encodeForJavaScript(context, RelId)%>';
   
    if(objId.indexOf("|")>=0)
    {
   	
   	var split_arr = objId.split("|");
   
   	for (var t=0;t<split_arr.length;t++)
   	{
		
		objId = split_arr[1];
		tree.deleteObject(objId);
	}
	    
    }else{
   	
    	tree.deleteObject(objId);
    }

     if(parentId == objId ){
        isRootId = true;
     }
<%
  }
%>
  }
    if(isRootId) {
      var url =  "../common/emxTree.jsp?AppendParameters=true&objectId=" + parentId + "&emxSuiteDirectory=<%=XSSUtil.encodeForURL(context, appDirectory)%>";
      var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
      if (contentFrame) {
        contentFrame.location.replace(url);
      }
      else {
        //parent.location.reload();
           
        getTopWindow().refreshTablePage();
        
      }
    } else {              
    getTopWindow().refreshTablePage();
    }
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>



