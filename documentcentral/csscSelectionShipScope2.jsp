<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.util.Map.Entry,
				 java.util.Iterator,
				 java.util.List,
				 java.util.HashMap,
				 matrix.util.UUID,
				 matrix.db.RelationshipType,
				 com.matrixone.servlet.Framework,
				 matrix.db.Context,
				 com.matrixone.apps.domain.DomainObject,
				 com.matrixone.apps.domain.util.PersonUtil,
				 matrix.util.MatrixException,
				 com.matrixone.apps.domain.util.ContextUtil,
				 com.matrixone.apps.domain.util.FrameworkException,
				 com.matrixone.apps.domain.util.MqlUtil,
				 com.matrixone.apps.domain.util.ContextUtil,
				 com.matrixone.apps.domain.DomainRelationship,
				 com.matrixone.apps.domain.util.i18nNow,
				 java.io.File,
				 com.matrixone.apps.framework.ui.UIUtil,
				 com.matrixone.apps.common.CommonDocument,org.dom4j.Document,org.dom4j.DocumentException,org.dom4j.Element,org.dom4j.io.OutputFormat,org.dom4j.io.SAXReader,org.dom4j.io.XMLWriter"%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%!
	public static List getNodes(String filePath,String elementName) {
		List dataList = new ArrayList();
		try {
			SAXReader reader = new SAXReader();
			Document document = reader.read(new File(filePath));
			Element root = document.getRootElement();
			Element element = root.element(elementName);
			List<Element> eles = element.elements();
			for (Element ele : eles) {
				String name = ele.attributeValue("Name");
				dataList.add(name);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dataList;
	}
%>
<%
		String objectId=request.getParameter("objectId");
		String parentId=request.getParameter("parentId");
	
		String urlPath = request.getSession().getServletContext().getRealPath("/") ;
		String ids[] = objectId.split(",");
		urlPath=urlPath+"upload/";
		System.out.println(urlPath);
		context = Framework.getFrameContext(session);
		
		
		
		
		
		List shipList = new ArrayList();
		List scopeList = new ArrayList();
	
		ContextUtil.pushContext(context);
		String folder = System.nanoTime() + "";
		BusinessObject bo = new BusinessObject("Document", "ProcessKnowledgeShipTypeAndScope", "0", "eService Production");
		System.out.println("bo------------------------------------------->>>");
		if (bo.exists(context)) {
			System.out.println("Exists----------------------------------->>>>");
			String fileName = MqlUtil.mqlCommand(context, "print bus " + bo.getObjectId(context) + " select format.file.name dump;");
			String path = urlPath + "/" + folder;
			File file = new File(path);
			if (!file.exists()) {
				file.mkdirs();
			}

			if (UIUtil.isNotNullAndNotEmpty(fileName)) {
				bo.checkoutFile(context, false, "generic", fileName, path);
				shipList = getNodes(path+"/"+fileName,"ShipTypeList");
				scopeList = getNodes(path+"/"+fileName,"ScopeList");
			}
		}
		ContextUtil.popContext(context);
	
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> 
<link rel="stylesheet" type="text/css"
	href="../common/styles/emxUIDefault.css">
<link rel="stylesheet" type="text/css"
	href="../common/styles/emxUIList.css">
<link rel="stylesheet" type="text/css" href="styles/dashboard.css">
<link href="../common/styles/emxUIToolbar.css" type="text/css"
	rel="stylesheet">
<link href="../common/styles/emxUIMenu.css" type="text/css"
	rel="stylesheet">
<link href="../common/styles/emxUIDialog.css" type="text/css"
	rel="stylesheet">
<link href="../common/styles/emxUICalendar.css" type="text/css"
	rel="stylesheet">
<script type="text/javascript" src="scripts/DatePicker.js"></script>

<script type="text/javascript">
	var footerurl = 'foot URL';
	addStyleSheet("emxUIToolbar");
	addStyleSheet("emxUIMenu");
	addStyleSheet("emxUIDOMLayout");
	
</script>

<style type="text/css">
body {
	margin: 0px;
	padding: 0px;
	overflow: auto;
	padding-top: 0px;
	padding-bottom: 22px;
	scroll=no;
	height=1024px
}

div {
	margin: 0px;
	padding: 0px;
}

#header {
	background-color: blue;
	color: white;
	position: absolute;
	top: 0px;
	left: 0px;
	height: 16px;
	width: 100%;
}

#content {
	width: 100%;
	height: 100%;
	overflow: auto
}

#footer {
	background-color: green;
	color: white;
	width: 100%;
	height: 16px;
	position: absolute;
	bottom: 0px;
	left: 0px;
}

        #bg{ display: none;  position: absolute;  top: 0%;  left: 0%;  width: 100%;  height: 100%;  background-color: black;  z-index:1001;  -moz-opacity: 0.7;  opacity:.70;  filter: alpha(opacity=70);}
        #show{display: none;  position: absolute;  top: 25%;  left: 22%;  width: 53%;  height: 49%;  padding: 8px;  border: 8px solid #E8E9F7;  background-color: white;  z-index:1002;  overflow: auto;}

</style>

<script src="../common/scripts/emxUIModal.js" language="JavaScript"></script>
<script src="../common/scripts/emxUICalendar.js" language="JavaScript"></script>
<script src="../common/scripts/emxUIPopups.js" language="JavaScript"></script>
<script src="../common/scripts/jquery-1.9.1.js" language="JavaScript"></script>

<script type="text/javascript">

	function closeWindow()
	{
		top.close();
	} 
	
	function clearField(formName,fieldName,idName)
    {
		var operand = "document." + formName + "." + fieldName+".value = \"\";";
		eval (operand);
		if(idName != null){
			var operand1 = "document." + formName + "." + idName+".value = \"\";";
			eval (operand1);
		}
		return;
    }
</script>

<script type="text/javascript" src="jquery-1.9.1.js"></script>
<script type="text/javascript">

   
	function submitValidate() 
	{
		
		var shipArray = [];
		var scopeArray = [];
		
		var obj = document.getElementsByName("ship");
		for(k in obj){
			if(obj[k].checked){
				shipArray.push(obj[k].value);
			}
		}
		if(shipArray==""||shipArray==null){
			alert("请选择适用船型！");
			return;
		}
		var objScop = document.getElementsByName("scope");
		for(s in objScop){
			if(objScop[s].checked){
				scopeArray.push(objScop[s].value);
			}
		}
		
		if(scopeArray==""||scopeArray==null){
			alert("请选择适用范围！");
			return;
		}
		var shipScope = shipArray.toString()+";"+scopeArray.toString();
		
		
		
		if(confirm("是否确认提交？")){
			document.tableTasksFrom.action="emxLibraryCentralObjectAddEndItems.jsp?selectionIds=<%=objectId%>&shipScope="+shipScope+"&objectId=<%=parentId%>";		
			document.tableTasksFrom.submit();
				
		}
	
	
	}

	
</script>




<script type="text/javascript" language="javascript">
	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
	addStyleSheet("emxUIForm");
	addStyleSheet("emxUIMenu");
</script>

</head>
<body class="white">

				
<br>


<br>
	<form name="tableTasksFrom" id="tableTasksFrom" method="post"	class="registerform" onsubmit="return submitValidate();  " action="emxLibraryCentralObjectAddEndItems.jsp" target="_parent" ENCTYPE="multipart/form-data">
		<table>
			<tr>
			
			<td><h3 style="color:red">适用船型:</h3></td>
			</tr>
			
		</table>
		<hr>		
		<table border="0px #ooo" cellpadding="0" cellspacing="0">
		
				
				
					<%
				
					for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
						String checked = "";
							if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							System.out.println("values--------"+values);
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									System.out.println("shipNames---------------"+shipNames);
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										System.out.println("nm------------------"+nm);
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						
						
						if(i%6==0&&i!=0){
				
					%>
						<tr>
					<%
						System.out.println("checked--------------"+checked);
						}
					%>
							<td><input type="checkbox" <%=checked%> name="ship" value="<%=shipName%>"><label  style="color:#808080"><%=shipName%></label></td>
					<%
						if((i*6/6==0)&&i!=0){
					%>
						
					</tr>	
						
					<%
						}
						
						
					}
					%>
					
				
				
		</table>	
		

		<br>
		<br>
		<br>
		<table>
			<tr>
			<td><h3 style="color:red">适用范围:</h3></td>
			</tr>
		</table>
		<hr>		
		<table border="0px #ooo" cellpadding="0" cellspacing="0">
		
				
					<%
				
					for(int i = 0;i<scopeList.size();i++){
						String scopName = (String)scopeList.get(i);
						String checked = "";
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
						
							 if(values!=null&&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(values.indexOf(";")+1,values.length());
									System.out.println("shipNames---------------"+shipNames);
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										System.out.println("nm------------------"+nm);
										if(scopName.equals(nm)){
											
											checked ="checked";
										}
								}
							 }
						}
						
						
						if(i%6==0&&i!=0){
				
					%>
						<tr>
					<%
						}
					%>
							<td><input type="checkbox" <%=checked%> name="scope" value="<%=scopName%>"><label  style="color:#808080"><%=scopName%></label></td>
					<%
						if((i*6/6==0)&&i!=0){
					%>
						
					</tr>	
						
					<%
						}
					}
					%>
				
				
		</table>	
		<input type="hidden" name="ids" id="ids" value="<%=objectId%>">
					
	</form>

</body>
</html>