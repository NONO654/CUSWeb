<%@ page import="com.matrixone.apps.framework.ui.emxPagination" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List"%>
<%@ page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.lang.String" %>
<%@ page import="com.matrixone.apps.domain.util.MapList"%>

<%
	System.out.println("Begin emxPLMCheckDialog.jsp");
	String command = emxGetParameter(request,"command");
	System.out.println("Command:"+command);
	if(!command.equals("delete") && !command.equals("select")) {
		response.setContentType("text/xml");
		response.setContentType("charset=UTF-8");
		response.setHeader("Content-Type", "text/xml");
		response.setHeader("Cache-Control", "no-cache");
		response.getWriter().write("<?xml version='1.0' encoding='UTF-8'?>");
   }
 
%>

<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>

<%
	
	if (!context.isTransactionActive())
		ContextUtil.startTransaction(context, true);

	
	
	if(command.equals("edit")){
		String body = emxGetParameter(request,"body");
		String var = emxGetParameter(request,"thisvar");
		String objectId = emxGetParameter(request,"objectId");
		String doSave = emxGetParameter(request,"doSave");

		System.out.println("Body:"+body+",var:"+var+",id:"+objectId);
		
		HashMap programMap = new HashMap();
		HashMap paramMap = new HashMap();
		programMap.put("paramMap", paramMap);
		paramMap.put("attrBody",body);
		paramMap.put("attrVar",var);
		paramMap.put("objectId",objectId);
		paramMap.put("doSave",doSave);

		MapList retour = (MapList)JPO.invoke(context, "emxPLMCheckBase", null, "check", JPO.packArgs(programMap), MapList.class);
		System.out.println("Result :"+retour);
		String xmlReturn = "<root>";
		for(Object o : retour){
			Map m = (HashMap)o;
			xmlReturn += "<parseError l='"+m.get("line")+"' i='"+m.get("info")+"'><![CDATA[";
			xmlReturn += m.get("msg");
			xmlReturn += "]]></parseError>";
		}
		xmlReturn += "</root>";
		
		response.getWriter().write(xmlReturn);
	} else if(command.equals("delete")) {
		String selectedId[] = emxGetParameterValues(request,"emxTableRowId");
		selectedId = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(selectedId);
		
		if(selectedId != null )
		{
			StringTokenizer st = null;
			String sRelId = "";
			String sObjId = "";
			for(int i=0;i<selectedId.length;i++)
			{
				if(selectedId[i].indexOf("|") != -1)
				{
					st = new StringTokenizer(selectedId[i], "|");
					sRelId = st.nextToken();
					sObjId = st.nextToken();
				}
				else
				{
					sObjId = selectedId[i];
				}
				String[] args = new String[] { sObjId };
				Boolean canDelete = (Boolean)JPO.invoke(context, "emxPLMCheckBase", null, "delete", args, Boolean.class);
				System.out.println("canDelete "+canDelete);
				if(!canDelete.booleanValue())
				{
					%>
					<script language="Javascript">
							alert("ERROR:<%=sObjId%>");
					</script>				 
					<%
				}
			}
		}%>
			<script language="javascript" src="../common/scripts/emxUICore.js"></script>
			<script language="Javascript">
				getTopWindow().refreshTablePage();
			</script>
	<%} else if(command.equals("create")) {
		String name = emxGetParameter(request,"name");
		String parentId = emxGetParameter(request,"parentId");
		String typeModel = emxGetParameter(request,"typeModel");
		System.out.println("Name:"+name+",typeModel:"+typeModel+",parentId:"+parentId);
		
		HashMap programMap = new HashMap();
		HashMap paramMap = new HashMap();
		programMap.put("paramMap", paramMap);
		paramMap.put("attrName",name);
		paramMap.put("attrTypeModel",typeModel);
		paramMap.put("attrParentId",parentId);
		MapList retour = (MapList)JPO.invoke(context, "emxPLMCheckBase", null, "createEntity", JPO.packArgs(programMap), MapList.class);
		System.out.println("Result :"+retour);
		String xmlReturn = "<root>";
		for(Object o : retour){
			Map m = (HashMap)o;
			String objectId = (String)m.get("objectId");
			if(objectId.length() != 0) {
				xmlReturn += "<createObject id='"+m.get("objectId")+"'><![CDATA[";
				xmlReturn += m.get("objectName");
				xmlReturn += "]]></createObject>";
			} else {
				xmlReturn += "<parseError l='"+m.get("line")+"' i='"+m.get("info")+"'><![CDATA[";
				xmlReturn += m.get("msg");
				xmlReturn += "]]></parseError>";
			}
		}
		xmlReturn += "</root>";
		System.out.println("xmlReturn :"+xmlReturn);
		response.getWriter().write(xmlReturn);
	} else if(command.equals("select")) {
		String selectedId[] = emxGetParameterValues(request,"emxTableRowId");
		selectedId = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(selectedId);
		
		if(selectedId != null)
		{
			StringTokenizer st = null;
			String sRelId = "";
			String sObjId = "";
			//for(int i=0;i<selectedId.length;i++)
			//{
				if(selectedId[0].indexOf("|") != -1)
				{
					st = new StringTokenizer(selectedId[0], "|");
					sRelId = st.nextToken();
					sObjId = st.nextToken();
				}
				else
				{
					sObjId = selectedId[0];
				}
				System.out.println("sObjId:"+sObjId+" sRelId:"+sRelId);
				String parentName = "";
				if(sObjId != null) {
					DomainObject object = DomainObject.newInstance(context, sObjId);
					parentName = object.getInfo(context, DomainConstants.SELECT_NAME);
					%>
					<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
					<script language="javascript" src="../common/scripts/emxUICore.js"></script>
					<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
					<script language="javascript" src="../common/scripts/jquery-latest.js"></script>
					<script language="javascript" src="scripts/emxUICoreMenu.js"></script>
					<script language="javascript" src="scripts/emxUIToolbar.js"></script>
					<script language="Javascript">
						var txtType,txtTypeDisp;
						objForm = emxUICore.getNamedForm(getTopWindow().opener,0);
						txtType = objForm.elements["Father"];
						txtTypeDisp = objForm.elements["FatherDisplay"];
						txtType.value = "<%=sObjId%>";
						txtTypeDisp.value = "<%=parentName%>";
						getTopWindow().close();
					</script>				 
				<%
				}
			//}
		}
	}

%>


