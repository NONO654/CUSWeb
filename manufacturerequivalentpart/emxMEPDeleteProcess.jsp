<%--  emxMEPDeleteProcess.jsp   -  This page deletes MEP objects.
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   static const char RCSID[] = $Id: /ENOManufacturerEquivalentPart/CNext/webroot/manufactuerequivalentpart/emxMEPDeleteProcess.jsp 1.1.2.1.1.1 Wed Oct 29 22:14:50 2008 GMT przemek Experimental$
--%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String summaryPage = emxGetParameter(request,"summaryPage");
  String url = "";
  String delId  ="";
  String errorMessage = "";
  
  String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
  if(checkBoxId != null )
  {
      String objectIdList[] = new String[checkBoxId.length];
      try {
          for(int i=0;i<checkBoxId.length;i++){
             StringTokenizer st = new StringTokenizer(checkBoxId[i], "|");
             String sObjId = st.nextToken();
             DomainObject dom = new DomainObject();
             dom.setId(sObjId);
             dom.open(context);
             String access = dom.getInfo(context,"current.access[delete]");
             if("true".equalsIgnoreCase(access)){
                 objectIdList[i]=sObjId;
                 delId=delId+checkBoxId[i]+";";
             }
             else{
            	 String sType = UINavigatorUtil.getAdminI18NString("Type", dom.getTypeName(), context.getLocale().toString());
                 errorMessage += " "+sType+" "+dom.getName()+" "+dom.getRevision()+",";
                 errorMessage = EnoviaResourceBundle.getProperty(context, "emxManufacturerEquivalentPartStringResource", context.getLocale(),"emxManufacturerEquivalentPart.NoDeleteAccess")+errorMessage.substring(0,errorMessage.length()-1);
                 dom.close(context);
               	 throw new Exception(errorMessage);
             }
             dom.close(context);
          }
         
          com.matrixone.apps.manufacturerequivalentpart.Part.deleteMEPs(context,objectIdList);
      }catch(Exception Ex){
          session.putValue("error.message", Ex.getMessage());
      }
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
  var tree = getTopWindow().objDetailsTree;
  var isRootId = false;

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
        getTopWindow().refreshTablePage();
        
    }
</script>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>



