<% response.setContentType("text/xml; charset=UTF-8"); %><?xml version="1.0" encoding="UTF-8"?>
<%-- emxFreezePaneValidate.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFreezePaneValidate.jsp.rca 1.4.1.4.2.1 Fri Nov  7 09:39:05 2008 ds-kvenkanna Experimental $
--%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil,java.util.regex.*,com.matrixone.jdom.Element,com.matrixone.jdom.Text,com.matrixone.jdom.Document,com.matrixone.jdom.input.SAXBuilder"%>
<%@include file = "emxNavigatorInclude.inc"%>

<%
String sActualValue = "";
String sDisplayValue = "";
String sDisplayLinkValue = "";
String sAlertValue = "";

try {

    SAXBuilder builder = new SAXBuilder();
    builder.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
    builder.setFeature("http://xml.org/sax/features/external-general-entities", false);
    builder.setFeature("http://xml.org/sax/features/external-parameter-entities", false);

    Document mxLinkdoc = builder.build(request.getInputStream());
    Element mxRoot=mxLinkdoc.getRootElement();
    Iterator itr = (mxRoot.getContent()).iterator();
    if(mxRoot.getContent().size()==0){    	
    	out.clear();
    	%>
    	<mxRoot>
    	<!-- //XSSOK -->
    	<message><actual><![CDATA[<%=sActualValue%>]]></actual><display><![CDATA[<%=sDisplayValue%>]]></display><displaylink><![CDATA[<%=sDisplayLinkValue%>]]></displaylink><alert><![CDATA[<%=sAlertValue%>]]></alert></message>
    	</mxRoot>
    	<%    	
    	return;
    }
    Text text = (Text)itr.next();

    String paramName = emxGetParameter(request, "paramName");
    paramName = UIUtil.isNullOrEmpty(paramName)  ? "emxFreezePaneValidate.jsp" : paramName;
    boolean skipInputFilter = "true".equalsIgnoreCase(emxGetParameter(request, "skipInputFilter"));    
    String fieldValue = text.getTextTrim();
    if(!skipInputFilter) {
    	XSSUtil xssUtil = XSSUtil.getInstance(context, null); 
    	fieldValue = xssUtil.strip_tags(context, xssUtil.canonicalize(context, fieldValue, paramName ,true), paramName , "false");
    }
	
    String sEditType = emxGetParameter(request, "editType");
    String rteValue = emxGetParameter(request, "rteValue");
    String sDynamicURLEnabled = EnoviaResourceBundle.getProperty(context, "emxFramework.DynamicURLEnabled");
    if("true".equals(rteValue)){
    	sDisplayValue = UIRTEUtil.htmlEncode(context, fieldValue);
    	out.clear();
    }else if(!"false".equals(sDynamicURLEnabled)) {
        String languageStr = request.getHeader("Accept-Language");
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("mxLink\\s*:", java.util.regex.Pattern.MULTILINE | java.util.regex.Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(fieldValue);
        if(matcher.find()) {
            HashMap paramMap = new HashMap();
            paramMap.put("FieldName", fieldValue);
            paramMap.put("uiType","structureBrowser");
            paramMap.put("language", request.getHeader("Accept-Language"));
            String sXMLoutput = (String)JPO.invoke(context, "emxUtilBase", null, "validateMxLinkData", JPO.packArgs(paramMap), String.class);
            SAXBuilder saxb = new SAXBuilder();
            saxb.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
            saxb.setFeature("http://xml.org/sax/features/external-general-entities", false);
            saxb.setFeature("http://xml.org/sax/features/external-parameter-entities", false);

            Document doc = saxb.build(new StringReader(sXMLoutput));

            Element tmpRoot=doc.getRootElement();
            Element e1ement = tmpRoot.getChild("mxField");
            sActualValue = e1ement.getText().trim();
            e1ement = tmpRoot.getChild("errorMsg");
            sAlertValue = e1ement.getText().trim();
            String sTopMsg = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.DynamicURL.ErrorMsg1", new Locale(languageStr));
            String sBottomMsg = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.DynamicURL.ErrorMsg4", new Locale(languageStr));
            if(!"".equals(sAlertValue)) {
                sAlertValue = sTopMsg + sAlertValue;
                if("mass".equals(sEditType)) {
                    sAlertValue += sBottomMsg;
                }
            }
            sDisplayValue = UINavigatorUtil.formatSymbolicToType(context, sActualValue, languageStr);
        }else {
            sActualValue = fieldValue;
            sDisplayValue = fieldValue;
        }
        
        sDisplayLinkValue = UINavigatorUtil.formatEmbeddedURL(context, sActualValue, true, languageStr);
        sDisplayLinkValue = FrameworkUtil.findAndReplace(sDisplayLinkValue, "&amp;", "&");
        sDisplayLinkValue = FrameworkUtil.findAndReplace(sDisplayLinkValue, "&quot;", "\"");

        if(!"".equals(sAlertValue)) {
            sAlertValue = FrameworkUtil.findAndReplace(sAlertValue,"\\n","\n");
            sAlertValue = FrameworkUtil.findAndReplace(sAlertValue,"\\r","\r");
            sAlertValue = FrameworkUtil.findAndReplace(sAlertValue,"\\t","\t");
        }
        out.clear();
    }else {
        sActualValue = fieldValue;
        sDisplayValue = fieldValue;
        sDisplayLinkValue = fieldValue;
    }
}catch(Exception e) {
    e.printStackTrace();
}
%>
<mxRoot>
<!-- //XSSOK -->
<message><actual><![CDATA[<%=sActualValue%>]]></actual><display><![CDATA[<%=sDisplayValue%>]]></display><displaylink><![CDATA[<%=sDisplayLinkValue%>]]></displaylink><alert><![CDATA[<%=sAlertValue%>]]></alert></message>
</mxRoot>
