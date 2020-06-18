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
public static  List parseCapture(Context context,String xmlFile,String nodeName){
	List dataList = new ArrayList();
	try{
	//xmlFile = new String(xmlFile.getBytes());
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
			System.out.println("displayName--"+displayName);
			dataMap.put("captures",displayName);
			NodeList nodeList = element.getChildNodes();
			String marId = "";
			for(int s = 0;s<nodeList.getLength();s++) {
				Element elementNode = (Element) nodeList.item(s);
				String typeString = elementNode.getAttribute("Type");
				String nameString = elementNode.getAttribute("Name");
				String revisionString = elementNode.getAttribute("Revision");
				
				
			}
			
			dataMap.put("materialsId",marId);
			dataList.add(dataMap);
		}
	}catch(Exception e){
		e.printStackTrace();
	}
		return dataList;
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
			System.out.println("Value------------------"+Value);
			dataMap.put(displayName,Value);
			dataList.add(dataMap);
		}
		}catch(Exception e){
			e.printStackTrace();
		}
		return dataList;
	}
%>
<%
String ver = System.nanoTime()+"";
 context = Framework.getFrameContext(session);
List vaList = new ArrayList();
List parametersList = new ArrayList();
String objectId = request.getParameter("objectId");
if(objectId!=null&&objectId.length()>0){

}
System.out.println("objectId-------Captures--------"+objectId);

String mbdObj = MqlUtil.mqlCommand(context, "print bus " + objectId + " select relationship[VPMRepInstance|to.attribute[PLMEntity.V_Name]~='MBD_*']].to.id dump");

String attrInfo = "";
if(mbdObj!=null && mbdObj.length()>0){
	DomainObject dom = DomainObject.newInstance(context);
	dom.setId(mbdObj);
	ContextUtil.pushContext(context);
	attrInfo = dom.getInfo(context,"attribute[JNCJNCAttrExForRepRef.JNCAttributeInfoToShow]");
	ContextUtil.popContext(context);
	
	vaList = parseCapture(context,attrInfo,"Capture");

	parametersList = parseParameter(attrInfo,"Parameter");

}


 
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
  margin-top:40px;
  }
</style>
</head>
<body>


<table id="box-table-a" summary="Employee Pay Sheet" cellspacing="0" cellpadding="0">
    <thead>
    	<tr>
        	<th scope="col" style="line-height: 40px;height: 40px;">工序</th>
            
        </tr>
    </thead>
    <tbody>
		<%
			for(int i = 0;i<vaList.size();i++){
				Map map = (Map)vaList.get(i);
				String captureName =(String)map.get("captures");
				if(captureName!=null && captureName.length()>0){
					captureName = unicodeToString(captureName);
				}
		%>
    	<tr style="line-height: 40px;height: 40px;">
        	<td><a  id="<%=mbdObj%>" tt="<%=captureName%>" onClick="refreshBOMListPage(this)"><%=captureName%></a></td>
        </tr>
        <%
			}
			
		%>
		<%
		   if(vaList.size()<7){
			for(int i = 0;i<7-vaList.size();i++){
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
	function reLoadBOMList(a){
	
		window.parent.parent.document.getElementById("iframeContent").contentWindow.document.getElementById("iframeLeft").contentWindow.location.href = "../cssc/csscBOMList.jsp?objectId="+a+"&frompage=";
		window.parent.parent.document.getElementById("iframeContent").contentWindow.document.getElementById("iframeContent").contentWindow.location.href = "../cssc/csscParameterView.jsp?bomId="+a+"&frompage=";
	}
	
	function refreshBOMListPage(a){
		
		
	
		
		var mbdObj = a.id;
		var value = a.getAttribute('tt');
		
		window.parent.parent.document.getElementById("iframeContent").contentWindow.document.getElementById("iframeLeft").contentWindow.location.href = "../cssc/csscBOMList.jsp?objectId=&frompage=captures&mbdObj="+mbdObj+"&value="+value;
		
		//window.parent.parent.document.getElementById("iframeContent").contentWindow.document.getElementById("iframeContent").contentWindow.location.href = "../cssc/csscParameterView.jsp?objectId="+mbdObj+"&bomId="+parentId+"&frompage=captures";
		
		
	}
</script>
</body>
</html>