<%-- emxMultipleClassificationRemoveClassProcess.jsp

   Copyright (c) 1998-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program


   static const char RCSID[] = "$Id: emxMultipleClassificationRemoveClassProcess.jsp.rca 1.2.3.2 Wed Oct 22 16:02:42 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file="emxLibraryCentralUtils.inc"%>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<%
  String sRelSubclass =   LibraryCentralConstants.RELATIONSHIP_SUBCLASS;
  String strMode     = emxGetParameter(request, "Mode");
  String strObjectId  = null;
  boolean isModeRemove = "remove".equalsIgnoreCase(emxGetParameter(request, "Mode"));
  if (isModeRemove) {
     String emxTableRowIds[] = (String[]) emxGetParameterValues(request, "emxTableRowId");
     emxTableRowIds          = getTableRowIDsArray(emxTableRowIds);
     if(emxTableRowIds != null && emxTableRowIds.length > 0) {
        strObjectId = emxTableRowIds[0];
     }
  }
  String stroldParentObjectId            = emxGetParameter(request, "objectId");
  
  String optionForAG = emxGetParameter(request, "optionForAG");
  boolean carryOverInheritedAttributeGroups = false;
  HashMap map = new HashMap();
  if(optionForAG != null && optionForAG.equalsIgnoreCase("Carry"))
  {
    carryOverInheritedAttributeGroups = true;
  }
//
// Find if object has inherited attributes
//
  StringBuffer strErrMsg = new StringBuffer("");
  if(strObjectId != null)
  {
    com.matrixone.apps.classification.Classification objClassification = (com.matrixone.apps.classification.Classification)DomainObject.newInstance (context, strObjectId, "Classification");   
    try{
        map = (HashMap)objClassification.reparent(context, null, stroldParentObjectId, null,carryOverInheritedAttributeGroups);
    }catch(FrameworkException e){
        StringList selectables = new StringList();
        selectables.add(DomainConstants.SELECT_TYPE);
        selectables.add(DomainConstants.SELECT_NAME);
        Map objInfo = objClassification.getInfo(context,selectables);
        strErrMsg.append("\n").append(objInfo.get(DomainConstants.SELECT_TYPE));
        strErrMsg.append(" ").append(objInfo.get(DomainConstants.SELECT_NAME));
    }
  }
  
  if(strErrMsg.length() > 0){
      String strCannotRemoveMessage = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(sLanguage),"emxLibraryCentral.Message.CannotRemoveMessage");
      strCannotRemoveMessage = strCannotRemoveMessage + strErrMsg;
%>
<script language="javascript" type="text/javaScript">
    alert("<xss:encodeForJavaScript><%=strCannotRemoveMessage%></xss:encodeForJavaScript>");
</script>
<%} %>
<script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
<script language="javascript" src="emxLibraryCentralUtilities.js"></script>
<script language="javascript" type="text/javaScript">
    try
    {
        getTopWindow().deleteObjectFromTrees('<xss:encodeForJavaScript><%=strObjectId%></xss:encodeForJavaScript>',true);
        updateCountAndRefreshTreeLBC('<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>',getTopWindow());
        getTopWindow().refreshTablePage();
    } catch(exec){
    }
</script>
