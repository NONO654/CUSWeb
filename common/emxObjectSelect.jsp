<%--  emxObjectSelect.jsp  -

   Intermediate JSP to update the fields by the object Id of the selected Object

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxObjectSelect.jsp.rca 1.2.5.4 Wed Oct 22 15:48:37 2008 przemek Experimental przemek $";
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
try
{
  String timeStamp = emxGetParameter(request, "timeStamp");
  HashMap requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
  String strFrameName = (String)requestMap.get("frameName");
  String strFormName = (String)requestMap.get("formName");
  String strFieldNameDisplay = (String)requestMap.get("fieldNameDisplay");
  String strFieldNameActual = (String)requestMap.get("fieldNameActual");
  
  String strContainedInFieldType=(String)requestMap.get("containedInFieldType");
  String strContainedInFieldRev=(String)requestMap.get("containedInFieldRev");

  String strObjname = "";
  String strTableRowId = emxGetParameter(request,"emxTableRowId");
  String strShowRevision = (String)requestMap.get("ShowRevision");
  String languageStr = request.getHeader("Accept-Language");

  String sType ="";
  String sName ="";
  String sRev ="";
  if ((strTableRowId == null)||(strTableRowId.equals("null"))||(strTableRowId.equals("")))
  {
        
        String strRetMsg = i18nNow.getI18nString("emxFramework.Common.PleaseSelectitem", "emxFrameworkStringResource", languageStr);
        throw new FrameworkException(strRetMsg);
  }
  else {
            strTableRowId = strTableRowId.trim();
			DomainObject domObj= new DomainObject(strTableRowId);
			Map objMap = new HashMap();
			StringList selectList = new StringList();
			selectList.addElement(DomainConstants.SELECT_TYPE);
			selectList.addElement(DomainConstants.SELECT_REVISION);
			objMap = domObj.getInfo(context,selectList);
	  
		    sType = (String) objMap.get(DomainConstants.SELECT_TYPE);
		    sRev  = (String) objMap.get(DomainConstants.SELECT_REVISION);

            if(((strShowRevision != null) && (!strShowRevision.equalsIgnoreCase("")) && !("null".equalsIgnoreCase(strShowRevision))) && (strShowRevision.equalsIgnoreCase("true")))
            {
                //This is to get obj name & rev.
                strObjname = FrameworkUtil.getObjectNameWithRevision(context, strTableRowId);

            }
            else {
                //This has to be read from the bean method.
                strObjname = FrameworkUtil.getObjectName(context, strTableRowId); 
            }
    }
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
    function setAndRefresh()
    {
      var txtTypeDisplay;
      var txtTypeActual;
	  var txtContainedInType;
	  var txtContainedInRev;

      var targetFrame = findFrame(getTopWindow().getWindowOpener(), "<xss:encodeForJavaScript><%=strFrameName%></xss:encodeForJavaScript>");
      if(targetFrame !=null){
        txtTypeDisplay=targetFrame.document.<%=XSSUtil.encodeForHTML(context, strFormName)%>.<%=XSSUtil.encodeForHTML(context, strFieldNameDisplay)%>;
    
        txtTypeActual=targetFrame.document.<%=XSSUtil.encodeForHTML(context, strFormName)%>.<%=XSSUtil.encodeForHTML(context,strFieldNameActual) %>;
        
      }else{
      /*
        Control comes here if the search type is Global Search ------
        In case of Global Search the old logic fails as getTopWindow().getWindowOpener().document.location = emxSearch.jsp
        and getTopWindow().getWindowOpener().document.editDataForm.OwnerDisplay is null since emxSearch.jsp does not have <form> editDataForm.
        So we have to find for the "searchContent" in emxSearch.jsp which in turn contains the webform jsp emxFormEditDisplay.jsp
        which contains the <form> editDataForm :        
        */
        var searchContentFrame = findFrame(getTopWindow().getWindowOpener(), "searchContent");
        
        if(searchContentFrame !=null){
            txtTypeDisplay=searchContentFrame.document.<%=XSSUtil.encodeForHTML(context, strFormName)%>.<%=XSSUtil.encodeForHTML(context, strFieldNameDisplay) %>;
            txtTypeActual=searchContentFrame.document.<%=XSSUtil.encodeForHTML(context, strFormName)%>.<%=XSSUtil.encodeForHTML(context, strFieldNameActual)%>;
			txtContainedInType = searchContentFrame.document.<%=XSSUtil.encodeForHTML(context, strFormName)%>.<%=XSSUtil.encodeForHTML(context, strContainedInFieldType)%>;
            txtContainedInRev = searchContentFrame.document.<%=XSSUtil.encodeForHTML(context, strFormName)%>.<%=XSSUtil.encodeForHTML(context, strContainedInFieldRev)%>;

        } else {
        txtTypeDisplay = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForHTML(context, strFormName)%>.<%=XSSUtil.encodeForHTML(context, strFieldNameDisplay) %>;
        txtTypeActual = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForHTML(context, strFormName)%>.<%=XSSUtil.encodeForHTML(context, strFieldNameActual) %>;
		txtContainedInType = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForHTML(context, strFormName)%>.<%=XSSUtil.encodeForHTML(context, strContainedInFieldType) %>;
        txtContainedInRev = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForHTML(context, strFormName)%>.<%=XSSUtil.encodeForHTML(context, strContainedInFieldRev) %>;

       }
      }
      //XSSOK
      txtTypeDisplay.value = "<%=strObjname%>";
      txtTypeActual.value = "<xss:encodeForJavaScript><%=strTableRowId%></xss:encodeForJavaScript>";
      if(txtContainedInType!=null && txtContainedInType!="undefined" && txtContainedInRev!=null && txtContainedInRev!="undefined")
		{
			txtContainedInType.value = "<%=XSSUtil.encodeForJavaScript(context, sType)%>";
			txtContainedInRev.value ="<%=XSSUtil.encodeForJavaScript(context, sRev)%>";
		}

      getTopWindow().closeWindow();
    }

</script>

<html>
<body onload=setAndRefresh()>
</body>
</html>
<%
} // End of try
catch(Exception ex) {
   session.putValue("error.message", ex.getMessage());
 } // End of catch
%>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
