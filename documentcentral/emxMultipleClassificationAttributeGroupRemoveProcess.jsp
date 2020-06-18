<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: This page is used to delete business objects
   Parameters :

   static const char RCSID[] = "$Id: emxMultipleClassificationAttributeGroupRemoveProcess.jsp.rca 1.2.3.3 Tue Oct 28 23:00:37 2008 przemek Experimental przemek $";
   --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "emxMultipleClassificationUtils.inc" %>


<%
try{
    //String timeStamp        = emxGetParameter(request, "timeStamp");
    //HashMap requestMap      = tableBean.getRequestMap(timeStamp);
    String parentId         = emxGetParameter(request ,"objectName");
    final String stdMsg     = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(sLanguage),"emxMultipleClassification.Removed.Message5");
    String objIds[]         = emxGetParameterValues(request,"emxTableRowId");
    objIds = getTableRowIDsArray(objIds);
    AttributeGroup attrGrp  = new AttributeGroup();
    
    StringBuffer sbErrMsg   = new StringBuffer();
    StringBuffer selectedAttributes = new StringBuffer();
    StringList strAttrList  = new StringList();
    String strSelectedAttr;
    if(objIds!= null) {
        int k = objIds.length;
        for(int i=0;i<k;i++) {
            strAttrList.addElement(objIds[i]);
            selectedAttributes.append(objIds[i]);
            if(i != k-1) {
                selectedAttributes.append(",");
            }
        }
    }

    attrGrp.setName(parentId);
    int countClassifiedItems    = (int) attrGrp.getNumberOfEndItemsWhereUsed(context);

    if (countClassifiedItems >= 1) {
    	String targetURL="emxMultipleClassificationRemoveAttributesProcess.jsp";
        String message= MessageUtil.getMessage(context,
                null,
                "emxMultipleClassification.Removed.Message",
                new String[]{Integer.toString(countClassifiedItems)},
                null,
                context.getLocale(),
        "emxLibraryCentralStringResource");
        sbErrMsg.append(message);
        
        //Display below alert message only if the default vault is other than All.
        if(!PersonUtil.SEARCH_ALL_VAULTS.equals(PersonUtil.getSearchDefaultSelection(context))) {
            sbErrMsg.append("\n");
            sbErrMsg.append(EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale(sLanguage),"emxMultipleClassification.Removed.Message6"));
        }
%>
		<form name="formForward" method="post" target = "listHidden" action="<%=XSSUtil.encodeForHTML(context,targetURL)%>">
		<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
		<!-- XSSOK - no need to encode parentID as we are submitting the form to a intermediate page, not displayed to browser -->
		<input type="hidden" name="parentId" value="<%=parentId%>"/>
        <script language=javascript >
        	var passSelectedAttr;
            if(confirm("<xss:encodeForJavaScript><%=sbErrMsg.toString()%></xss:encodeForJavaScript>")) {
<%
                parentId    = FrameworkUtil.encodeNonAlphaNumeric(parentId,Framework.getCharacterEncoding(request));
				strSelectedAttr = selectedAttributes.toString();
%>
				var SelectedAttr= encodeURIComponent("<xss:encodeForJavaScript><%=strSelectedAttr%></xss:encodeForJavaScript>");
				passSelectedAttr=SelectedAttr;
                //XSSOK
            	document.formForward.action="<%=XSSUtil.encodeForHTML(context,targetURL)+"?selectedAttributes="%>"+passSelectedAttr;
            	document.formForward.submit();
				}
            </script>
        </form>
<%
    } else {

        try {
            attrGrp.removeAttributes(context,strAttrList);
        } catch(Exception e) {
        	sbErrMsg.append(stdMsg);
        }
%>
        <script language=javascript>
            var vErrMsg = '<xss:encodeForJavaScript><%=sbErrMsg.toString().trim()%></xss:encodeForJavaScript>';
            if (vErrMsg != "") {
                alert(vErrMsg);
            }
            getTopWindow().refreshTablePage();
        </script>

<%
    }
}catch(Exception err){
	err.printStackTrace();
}
%>


