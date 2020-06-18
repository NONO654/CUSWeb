<%--  emxIssueCategoryClassificationProcess.jsp

  Sets the selected Category/Classification from the tree and passes to the Dialog page

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ page import = "com.matrixone.apps.domain.util.i18nNow"%>
<%@include file = "emxComponentsUtil.inc"%>

<%
 try{
  //Get paramters from url
  String strFrameName = emxGetParameter(request, "frameName");
  String strFormName = emxGetParameter(request, "formName");
  String strFieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
  String strFieldNameActual = emxGetParameter(request, "fieldNameActual");
  String strLanguage = request.getHeader("Accept-Language");
  String strFieldNameId = emxGetParameter(request, "fieldNameId");
String strIssueCreateMode = emxGetParameter(request, "issueCreateMode");

  String fromPage = emxGetParameter(request, "fromPage");
  if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(fromPage))
  {
      fromPage="";
  }
  String objectId="";
  String parentId="";
  String strCategoryClassification= request.getParameter("radiobutton");
  String strCategoryClassificationId = "";

  if(fromPage.equalsIgnoreCase("issueSBChooser"))
  {
      String childIds[] = (String[]) request.getParameterValues("emxTableRowId");


      if(childIds==null)
      {
         %> <script language="javascript">
         		 alert("<%=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Message.PleaseMakeASelection")%>");
         	</script>
         		<%
          return;
      }

      objectId = childIds[0];
      StringTokenizer st = new StringTokenizer(objectId,"|");
      while(st.hasMoreTokens())
      {
          objectId = st.nextToken();
          parentId = st.nextToken();
          break;
      }

      com.matrixone.apps.domain.DomainObject domCategoryChild = new com.matrixone.apps.domain.DomainObject(objectId);
      com.matrixone.apps.domain.DomainObject domCategoryParent = new com.matrixone.apps.domain.DomainObject(parentId);
		if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(strCategoryClassification))
		{
		    strCategoryClassification = domCategoryParent.getName(context)+"/"+domCategoryChild.getName(context);
			strCategoryClassificationId= parentId+"|"+objectId;
		}
  }

  //Getting the value from the tree
  String strI18nCategoryClassification = "";

 if(!(strCategoryClassification == null || "null".equalsIgnoreCase(strCategoryClassification)||strCategoryClassification.equals("")))
{
  int slashIndex=strCategoryClassification.indexOf("/");
  String strCategory=strCategoryClassification.substring(0,slashIndex);
  String strClassification=strCategoryClassification.substring(slashIndex+1,strCategoryClassification.length());
  StringBuffer sbCategoryStr = new StringBuffer("emxComponents.Common.").append(strCategory.replace(' ', '_'));

  String strI18nCategory = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), sbCategoryStr.toString());

  StringBuffer sbClassificationStr = new
  StringBuffer("emxComponents.Common.").append(strClassification.replace(' ', '_'));
  String strI18nClassification = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), sbClassificationStr.toString());
  if(strI18nCategory.contains("emxComponents.Common.")){
	  strI18nCategory = strCategory;
  }
  if(strI18nClassification.contains("emxComponents.Common.")){
	  strI18nClassification = strClassification;
  }
  strI18nCategoryClassification=strI18nCategory+"/"+strI18nClassification;
}
//Start of Add By Infosys, for Bug # 284950 on 16 Jan 2006
else
{
	response.sendRedirect("emxIssueCategoryClassificationSelectorDialog.jsp?contentPageIsDialog=true&usepg=false&warn=true&fromProcess=true");
}
//End of Add By Infosys, for Bug # 284950 on 16 Jan 2006

%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">

      var txtTypeDisplay;
      var txtTypeActual;
	  var txtTypeId;
	  <% if("createFromSlideIn".equals(strIssueCreateMode)){%>
	  	  var targetWindow = getTopWindow().getWindowOpener();
	  	  var tmpFieldNameActual = "<%=XSSUtil.encodeForJavaScript(context, strFieldNameActual)%>";
	      var tmpFieldNameDisplay = "<%=XSSUtil.encodeForJavaScript(context, strFieldNameDisplay)%>";
	      var tmpFieldNameOID = tmpFieldNameActual + "OID";
	      
	      txtTypeActual = targetWindow.document.getElementById(tmpFieldNameActual) ? targetWindow.document.getElementById(tmpFieldNameActual) : targetWindow.parent.document.getElementById(tmpFieldNameActual);
	      txtTypeDisplay = targetWindow.document.getElementById(tmpFieldNameDisplay) ? targetWindow.document.getElementById(tmpFieldNameDisplay) : targetWindow.parent.document.getElementById(tmpFieldNameDisplay);
	      txtTypeId = targetWindow.document.getElementById(tmpFieldNameOID) ? targetWindow.document.getElementById(tmpFieldNameOID) : targetWindow.parent.document.getElementById(tmpFieldNameOID);

	      if (txtTypeActual==null && txtTypeDisplay==null) {
	    	  txtTypeActual=targetWindow.document.forms[0][tmpFieldNameActual];
	    	  txtTypeDisplay=targetWindow.document.forms[0][tmpFieldNameDisplay];
	    	  txtTypeId=targetWindow.document.forms[0][tmpFieldNameOID];
	      }
	  
	  <%}else{%>
      var targetFrame = findFrame(getTopWindow().getWindowOpener(), "<%=XSSUtil.encodeForJavaScript(context, strFrameName)%>");
      if(targetFrame !=null){
        txtTypeDisplay=targetFrame.document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameDisplay)%>;
  txtTypeActual=targetFrame.document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameActual)%>;
		txtTypeId=targetFrame.document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameId)%>;
      }else{
        txtTypeDisplay = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameDisplay)%>;
  txtTypeActual=getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameActual)%>;
		txtTypeId=getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameId)%>;      
      }
	  <%}%>
      

	  txtTypeDisplay.value = "<%=XSSUtil.encodeForJavaScript(context, strI18nCategoryClassification)%>";
      txtTypeActual.value = "<%=XSSUtil.encodeForJavaScript(context, strCategoryClassification)%>";
	  txtTypeId.value = "<%=XSSUtil.encodeForJavaScript(context, strCategoryClassificationId)%>";
	  getTopWindow().closeWindow();

</script>

<%
} // End of try
catch(Exception ex) {
 ex.printStackTrace(System.out);
 session.putValue("error.message", ex.getMessage());
 } // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
