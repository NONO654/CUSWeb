
<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ page import="java.util.*,com.jspsmart.upload.*,java.io.*,java.text.*,java.io.StringReader,javax.xml.parsers.DocumentBuilder,javax.xml.parsers.DocumentBuilderFactory,org.w3c.dom.Document,org.w3c.dom.Element,org.w3c.dom.Node,org.w3c.dom.NodeList,org.xml.sax.InputSource,java.util.List,matrix.db.Context"%> 
<%@ page import="matrix.util.UUID,matrix.db.RelationshipType,com.matrixone.servlet.Framework,matrix.db.Context,com.matrixone.apps.domain.DomainObject,com.matrixone.apps.domain.util.PersonUtil,matrix.util.MatrixException,com.matrixone.apps.domain.util.ContextUtil,com.matrixone.apps.domain.util.FrameworkException,com.matrixone.apps.domain.util.MqlUtil,com.matrixone.apps.domain.util.ContextUtil,com.matrixone.apps.domain.DomainRelationship"%>
<%@ page import="jxl.*,java.util.regex.Matcher,java.util.regex.Pattern,java.net.*,java.util.LinkedList"%>
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
	
	public static List getHeader(String xmlFile, String nodeName) {
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
			System.out.println("nodes-------------" + nodes.getLength());
			if(nodes!=null && nodes.getLength()>0) {
				Element element = (Element) nodes.item(0);
				NodeList headNodes = element.getChildNodes();
				
				for (int i = 0; i < headNodes.getLength(); i++) {
					Map dataMap = new HashMap();
					Element element1 = (Element) headNodes.item(i);
					String displayName = element1.getAttribute("DisplayName");
					System.out.println("displayName--------------" + displayName);
					String Value = element.getAttribute("Value");

					dataMap.put(displayName, Value);
					dataList.add(dataMap);
				}
			}
		} catch (Exception e) {
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
	
	
	public static  List parseCapture(String xmlFile,String nodeName,String captureName){
		List attributeList = new ArrayList();
		try{
		//xmlFile = new String(xmlFile.getBytes());
			
			StringReader sr = new StringReader(xmlFile);
			InputSource is = new InputSource(sr);
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

			DocumentBuilder db = dbf.newDocumentBuilder();

			Document domTree = db.parse(new ByteArrayInputStream(xmlFile.getBytes()));

			Element root = domTree.getDocumentElement();


			NodeList nodes = root.getElementsByTagName(nodeName);
			System.out.println("nodes-------"+nodes.getLength());

			for (int i = 0; i < nodes.getLength(); i++) {
				Map dataMap = new HashMap();
				Element element = (Element) nodes.item(i);
				String displayName = element.getAttribute("DisplayName");
				if(UIUtil.isNotNullAndNotEmpty(displayName)) {
					displayName =unicodeToString(displayName);
				}
				if(captureName.equals(displayName)) {
					NodeList captListsList = element.getChildNodes();
					for(int s = 0;s<captListsList.getLength();s++) {
						Element element2 = (Element)captListsList.item(s);
						String name = element2.getAttribute("Name");
						NodeList nodeList = element2.getChildNodes();
						for(int o =0;o<nodeList.getLength();o++) {
							Element element3 = (Element)nodeList.item(o);
							NodeList nodeList2 = element3.getChildNodes();
							HashMap dataMaps = new HashMap();
							for(int n = 0;n<nodeList2.getLength();n++) {
								
								Element element4 =(Element) nodeList2.item(n);
								String DisplayName= element4.getAttribute("DisplayName");
								String value = element4.getAttribute("Value");
								System.out.println("DisplayName-----------"+n+"-------"+DisplayName);
								System.out.println("value-----------"+n+"-------"+value);
								dataMaps.put(DisplayName, value);
								
							}
							attributeList.add(dataMaps);
							
						}
					}
				}
			}
		}catch(Exception e){
			e.printStackTrace();
		}
			return attributeList;
		}
%>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Top 10 Express Table Designs - Smashing Magazine Source</title>
<style type="text/css">
<!--
@import url("style.css?v=2.5");
-->
body{
	margin: 0;
}
</style>
</head>
<body>
<%
	int count = 0;
	String attrInfo = "";
	int bomListCount = 0;
	int parametersCount = 0;
	List parametersList = new ArrayList();
	List valueList = new ArrayList(); 
	try{
	DomainObject dom = DomainObject.newInstance(context);
	String objectId = request.getParameter("objectId");
	String frompage = request.getParameter("frompage");
	String mbdObjId = request.getParameter("mbdObj");
	String captureValue = request.getParameter("value");
	if(captureValue!=null && captureValue.length()>0){
		captureValue = URLDecoder.decode(captureValue, "UTF-8"); 
	}
	
	if(frompage==null||frompage.length()==0){
		
	}
	String ver = System.nanoTime()+"";
	List headList = new ArrayList();
	dom.setId(objectId);
	ContextUtil.pushContext(context);
	if(objectId!=null && objectId.length()>0){
	String mbdObj = MqlUtil.mqlCommand(context, "print bus " + objectId + " select relationship[VPMRepInstance|to.attribute[PLMEntity.V_Name]~='MBD_*']].to.id dump");
	
	if(UIUtil.isNotNullAndNotEmpty(mbdObj)){
		dom.setId(mbdObj);
		attrInfo = dom.getInfo(context,"attribute[JNCJNCAttrExForRepRef.JNCAttributeInfoToShow]");
	}
	}else{
		dom.setId(mbdObjId);
		attrInfo = dom.getInfo(context,"attribute[JNCJNCAttrExForRepRef.JNCAttributeInfoToShow]");
	}
	ContextUtil.popContext(context);
	if(attrInfo!=null && attrInfo.length()>0){
		parametersList = parseParameter(attrInfo,"Parameter");
		List xmlList = getHeader(attrInfo,"Attributes");
		for(int i = 0;i<xmlList.size();i++){
		Map<String,String> headMap = (Map)xmlList.get(i);
			for (String key : headMap.keySet()) {
				headList.add(key);
			}
		}
	}
	int sCount = headList.size();	
%>
<table id="box-table-a" summary="Employee Pay Sheet">
    <thead>
    	<tr>
			<%
				for(int i = 0;i<headList.size();i++){
					String headName = (String)headList.get(i);
					headName = unicodeToString(headName);
			%>
        	<th scope="col" style="line-height: 30px;height: 30px;"><%=headName%></th>
			<%
				}
			%>
            
        </tr>
    </thead>
    <tbody>
		<%
				List dataList = new ArrayList();
				if(attrInfo!=null && attrInfo.length()>0){
					if(captureValue!=null && captureValue.length()>0){
						dataList = parseCapture(attrInfo,"Capture",captureValue);
					
					}else{
						dataList = parseParameterAttribute(attrInfo,"Attributes");
					}
				}
				
				for(int i = 0;i<dataList.size();i++){
					LinkedList linkList = new LinkedList();
					for(int s = 0;s<headList.size();s++){
						String headName = (String)headList.get(s);
						
						Map dataMap = (Map)dataList.get(i);
						Iterator keys = dataMap.keySet().iterator();
						while(keys.hasNext()) {
							String key = (String) keys.next();
							if(headName.equals(key)){
								String value=(String)dataMap.get(key);
								if(value!=null && value.length()>0){
									value = unicodeToString(value);
								}
								linkList.add(value);
							}
						}
						
					}
					valueList.add(linkList);
				}
				System.out.println("valueList--------xxxxxxxxxxxxxxxxxxxxxxxxxxxx-------"+valueList);
				for(int i = 0;i<valueList.size();i++){
		%>
		<tr style="line-height: 30px;height: 30px;">
		<%	
					LinkedList list = (LinkedList)valueList.get(i);
					for(int s = 0;s<list.size();s++){
						String value_ = (String)list.get(s);
		%>
			
			<td><%=value_%></td>
			
		<%		
					}
		%>
		<tr/>
		<%	
				}					
				int parametersListSize = parametersList.size();
				int dataListSize = dataList.size();
				if(parametersListSize>=dataListSize){
					for(int i = 0;i<(parametersListSize-dataListSize);i++){
					%>
						<tr style="line-height: 30px;height: 30px;">
						<%
							for(int s = 0;s<headList.size();s++){
								%>
								<td></td>
								<%
							}
						%>	
						</tr>
					<%
						
					}
				}
	}catch(Exception e){
		e.printStackTrace();
	}
		
		%>
    </tbody>
</table>


</table>
<script>
	function refresh(str){
		
		window.location.href = "../cssc/csscBOMList.jsp?objectId="+str;
	}
</script>
</body>
</html>