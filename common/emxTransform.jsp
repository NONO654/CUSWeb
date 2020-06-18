<%--  emxTransform.jsp   - The Collection Memeber delete object processing page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTransform.jsp.rca 1.4 Wed Oct 22 15:48:12 2008 przemek Experimental przemek $
--%>

<%@ page import="java.io.*,
                 java.util.*" %>

<%-- import JDOM and XML/XSLT classes --%>    
<%@ page import="com.matrixone.jdom.*,
                 com.matrixone.jdom.Document,
                 com.matrixone.jdom.input.*,
                 com.matrixone.jdom.output.*,
                 com.matrixone.jdom.transform.*,
                 javax.xml.transform.*,
                 javax.xml.transform.stream.*" %>
<%@include file="../emxRequestWrapperMethods.inc"%>                 
                 
<%
        String strXML = emxGetParameter(request, "xml");
        String strXSL = emxGetParameter(request, "xslt");
        
        StringReader objXMLReader = new StringReader(strXML);
        StringReader objXSLReader = new StringReader(strXSL);

        StreamSource objXMLSource = new StreamSource(objXMLReader);
        StreamSource objXSLSource = new StreamSource(objXSLReader);

        TransformerFactory objFactory = TransformerFactory.newInstance();
        Templates objTemplates = objFactory.newTemplates(objXSLSource);
	javax.xml.transform.Transformer objTransformer = objTemplates.newTransformer();
        objTransformer.transform(objXMLSource, new StreamResult(out));
 %>                 
