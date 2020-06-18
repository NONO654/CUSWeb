<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ page import="java.util.*,com.jspsmart.upload.*,java.io.*,java.text.*,java.io.StringReader,javax.xml.parsers.DocumentBuilder,javax.xml.parsers.DocumentBuilderFactory,org.w3c.dom.Document,org.w3c.dom.Element,org.w3c.dom.Node,org.w3c.dom.NodeList,org.xml.sax.InputSource,java.util.List,matrix.db.Context"%> 
<%@ page import="matrix.util.UUID,matrix.db.RelationshipType,com.matrixone.servlet.Framework,matrix.db.Context,com.matrixone.apps.domain.DomainObject,com.matrixone.apps.domain.util.PersonUtil,matrix.util.MatrixException,com.matrixone.apps.domain.util.ContextUtil,com.matrixone.apps.domain.util.FrameworkException,com.matrixone.apps.domain.util.MqlUtil,com.matrixone.apps.domain.util.ContextUtil,com.matrixone.apps.domain.DomainRelationship"%>
<%@ page import="jxl.*,java.util.regex.Matcher,java.util.regex.Pattern"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%!
 public static String unicodeToString(String str) {
        Pattern pattern = Pattern.compile("(\\\\u(\\p{XDigit}{4}))");   
        Matcher matcher = pattern.matcher(str);
        char ch;
        while (matcher.find()) {
            ch = (char) Integer.parseInt(matcher.group(2), 16);
            str = str.replace(matcher.group(1), ch + "");   
        }
        return str;
    }
	
public static  List parseParameter(String xmlFile,String nodeName) {
		List dataList = new ArrayList();
		try{
		//xmlFile = new String(xmlFile.getBytes(), "UTF-8");
		StringReader sr = new StringReader(xmlFile);
		InputSource is = new InputSource(sr);
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

		DocumentBuilder db = dbf.newDocumentBuilder();

		Document domTree = db.parse(new ByteArrayInputStream(xmlFile.getBytes()));

		Element root = domTree.getDocumentElement();


		NodeList nodes = root.getElementsByTagName(nodeName);

		for (int i = 0; i < nodes.getLength(); i++) {
			Map dataMap = new HashMap();
			Element element = (Element) nodes.item(i);
			String displayName = element.getAttribute("DisplayName");
			String Value = element.getAttribute("Value");
			
			dataMap.put(displayName,Value);
			dataList.add(dataMap);
		}
		}catch(Exception e){
			e.printStackTrace();
		}
	
		return dataList;
	}
	
	
	public static  List parseBOMXML(String xmlFile,String nodeName) {
		List dataList = new ArrayList();
		try{
		//xmlFile = new String(xmlFile.getBytes(), "UTF-8");
		StringReader sr = new StringReader(xmlFile);
		InputSource is = new InputSource(sr);
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

		DocumentBuilder db = dbf.newDocumentBuilder();

		Document domTree = db.parse(new ByteArrayInputStream(xmlFile.getBytes()));

		Element root = domTree.getDocumentElement();


		NodeList nodes = root.getElementsByTagName(nodeName);

		for (int i = 0; i < nodes.getLength(); i++) {
			Map dataMap = new HashMap();
			Element element = (Element) nodes.item(i);
			String displayName = element.getAttribute("DisplayName");
			String Value = element.getAttribute("Value");
			
			dataMap.put(displayName,Value);
			dataList.add(dataMap);
		}
		}catch(Exception e){
			e.printStackTrace();
		}
		
		return dataList;
	}
	
	public static List parseParameterAttribute(String xmlFile, String nodeName) {
		List dataList = new ArrayList();
		try {
			// xmlFile = new String(xmlFile.getBytes(), "UTF-8");
			StringReader sr = new StringReader(xmlFile);
			InputSource is = new InputSource(sr);
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

			DocumentBuilder db = dbf.newDocumentBuilder();

			Document domTree = db.parse(new ByteArrayInputStream(xmlFile.getBytes()));

			Element root = domTree.getDocumentElement();
			NodeList nodes = root.getElementsByTagName(nodeName);

			for (int i = 0; i < nodes.getLength(); i++) {

				Element nodesAttributes = (Element) nodes.item(i);
				NodeList nodeList = nodesAttributes.getChildNodes();
				HashMap attributeList = new HashMap<String,String>();;
				for (int s = 0; s < nodeList.getLength(); s++) {

					Map dataMap = new HashMap();
					Element element = (Element) nodeList.item(s);
				    String displayName = element.getAttribute("DisplayName");
					String Value = element.getAttribute("Value");
					attributeList.put(displayName,Value);
					
				}
				dataList.add(attributeList);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return dataList;
	}
%>
<%
String ver = System.nanoTime()+"";
%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Top 10 Express Table Designs - Smashing Magazine Source</title>
<style type="text/css">
<!--
@import url("style1.css?v=<%=ver%>");
-->
table
  {
  margin-top:10px;
  }
</style>
</head>
<body>
<%

String objectId = request.getParameter("objectId");
String bomId = request.getParameter("bomId");
String attrInfo  ="";
List attributeList = new ArrayList();
String frompage = request.getParameter("frompage");
int iCount = 0;
if("captures".equals(frompage)){
	if(bomId!=null&&bomId.length()>0){
		
		objectId = bomId;
	}
}else{
	
	if(bomId!=null && bomId.length()>0){
		
		objectId = bomId;
	}
}


DomainObject dom = DomainObject.newInstance(context);


List parametersList = new ArrayList();



System.out.println("objectId------------xxxxxxxxxxxx-------"+objectId);
if(objectId!=null && objectId.length()>0){
	
	
	ContextUtil.pushContext(context);
	String mbdObj = MqlUtil.mqlCommand(context, "print bus " + objectId + " select relationship[VPMRepInstance|to.attribute[PLMEntity.V_Name]~='MBD_*']].to.id dump");
	dom.setId(mbdObj);
	attrInfo = dom.getInfo(context,"attribute[JNCJNCAttrExForRepRef.JNCAttributeInfoToShow]");
	System.out.println("attrInFo----------------xxxxxxxxxxxxxxxx-------------"+attrInfo);
	ContextUtil.popContext(context);
	
	if(attrInfo!=null && attrInfo.length()>0){
		parametersList = parseParameter(attrInfo,"Parameter");
	}

}
if(attrInfo!=null && attrInfo.length()>0){
	attributeList = parseParameterAttribute(attrInfo,"Attributes");
}
iCount = attributeList.size();

%>

<table id="box-table-a" summary="Employee Pay Sheet" style="line-height: 30px;height: 30px;">
    <thead>
    	<tr>
        	<th scope="col">参数</th>
            
        </tr>
    </thead>
    <tbody>
    	<%
			for(int i = 0;i<parametersList.size();i++){
				Map dataMap = (Map)parametersList.get(i);
				Iterator keys = dataMap.keySet().iterator();
				while(keys.hasNext()) {
				String key = (String) keys.next();
				String value=(String)dataMap.get(key);
				if(key!=null && key.length()>0){
					key = unicodeToString(key);
				}
				if(value!=null && value.length()>0){
					value = unicodeToString(value);
				}
		%>
        <tr style="line-height: 30px;height: 30px;">
        	<td><%=key%>:<%=value%></td>
            
			
        </tr>
		<%
			}
			}
			
			if(parametersList.size()<=iCount){
				for(int i = 0;i<iCount-parametersList.size();i++){
		%>
     
			<tr style="line-height: 30px;height: 30px;"><td></td></tr>
		<%
				}
			}
		%>
	
    </tbody>
</table>


</table>

<script>
	function refreshBOMListPage(a){
	
		  var parentId = a.id;
		//alert(window.parent.parent.location.href);
		//document.getElementById('iframeContent').contentWindow.refresh(); 
		window.parent.parent.document.getElementById('iframeContent').contentWindow.refresh(parentId); 
	}
</script>
</body>
</html>