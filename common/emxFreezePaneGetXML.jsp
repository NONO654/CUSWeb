<%--  emxFreezePaneGetXML.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFreezePaneGetXML.jsp.rca 1.5 Wed Oct 22 15:48:44 2008 przemek Experimental przemek $
--%>
<%@ page import="com.matrixone.jdom.*,
             com.matrixone.jdom.output.*" %>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
// timeStamp to handle the business objectList
String timeStamp = emxGetParameter(request, "timeStamp");

try {
    ContextUtil.startTransaction(context, false);
    // Process the request object to obtain the table data and set it in Table
	// bean
    // Start: Initialize Bean
    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    // End: Initialize Bean
    HashMap tableData = indentedTableBean.getTableData(timeStamp);
	Element root = null;
    Object objXmlData = tableData.get("xmlData");
    if(objXmlData != null){
		root = (Element)objXmlData;
		tableData.remove("xmlData");
    }else{
		root = new Element("mxRoot");
    }
	
	Vector contentVector = new Vector();

    //set the root element
    contentVector.add(root.clone());
	Document doc = new Document(contentVector);
    out.clear();
    response.setContentType("text/xml; charset=UTF-8");
    XMLOutputter  outputter = MxXMLUtils.getOutputter();
    //outputter.output(doc, System.out);
    outputter.output(doc, out);

    ContextUtil.commitTransaction(context);
    // End: Get Data
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if (ex.toString() != null && (ex.toString().trim()).length() > 0){
        emxNavErrorObject.addMessage(ex.toString().trim());
        System.out.println(ex.toString().trim());
        %>
        <%@include file = "emxNavigatorBottomErrorInclude.inc"%>
		<%
    }
}
%>
