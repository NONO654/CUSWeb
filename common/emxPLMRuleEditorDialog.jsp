<%@ page import="com.matrixone.apps.framework.ui.emxPagination" %>
<%@ page import="java.util.*"%>
<%@ page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.lang.String" %>
<%@ page import="java.io.*" %>
<%@ page import="com.matrixone.apps.domain.util.MapList"%>

<%
	System.out.println("Begin emxPLMRuleEditorDialog.jsp");
// 	int leng=request.getContentLength();
// 	Map<String,String[]>mreq = request.getParameterMap();
	StringBuffer sb = new StringBuffer();
    BufferedReader reader = null;
    String content = "";
    String text = "";
    String aux = "";
	java.util.List<String> lPayload = new ArrayList<String>();
	Map<String,String> mPayload = new HashMap<String,String>();

    try {
//         InputStream inputStream = getInputStream();//request.getInputStream();
//         inputStream.available();
// 	    if (inputStream != null) {
        reader = request.getReader() ;// new BufferedReader(new InputStreamReader(inputStream)); 
        //IR-595018 S63 We add a flag to retrieve our informations though the request
        while ((aux = reader.readLine()) != null) {
        	if(!aux.isEmpty()&&aux.contains("--MyBRBoundary--"))
                lPayload.add(aux);
        }
        
        for(int i=0;i<lPayload.size();i++) {
        	String line = lPayload.get(i);
        	String key = line.split("=")[1];
        	key = key.substring(17,key.length()-1);
        	i+=1;
        	String value = lPayload.get(i);
        	value = value.substring(16);
        	value = java.net.URLDecoder.decode(value, "UTF-8");
        	mPayload.put(key.replace("\"", ""), value);
        }
        	
// 	    } else {
//                sb.append("");
//         }

    } catch (IOException ex) {
        throw ex;
    } finally {
        if (reader != null) {
            try {
                reader.close();
            } catch (IOException ex) {
                throw ex;
            }
        }
    }
// 	String testT = req.getReader().lines().collect(Collectors.joining(System.lineSeparator()));
// 	String query = emxGetQueryString(request);
// 	Enumeration enumReq = emxGetParameterNames(request);
	String command = mPayload.get("command");// emxGetParameter(request,"command");
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
		String UUIDSup = "5fe29379-cfe0-41eb-a503-a03b84ba831f";
		String UUIDMin = "cf9d40c6-ca8a-4864-ae4e-eb840230be50";
		String UUIDDiv = "9f168c73-05ed-4b78-8c6e-17d8b0e66c82";
		String body = mPayload.get("body");// emxGetParameter(request,"body");
		body=body.replaceAll(UUIDSup, ">");
		body=body.replaceAll(UUIDMin, "<");
		body=body.replaceAll(UUIDDiv, "/");
		String var = mPayload.get("thisvar");// emxGetParameter(request,"thisvar");
		String objectId = mPayload.get("objectId");// emxGetParameter(request,"objectId");
		String doSave = mPayload.get("doSave");// emxGetParameter(request,"doSave");
		String typeEdit = mPayload.get("typeEdit");// emxGetParameter(request,"typeEdit");
		String name = mPayload.get("name");// emxGetParameter(request,"name");
		String priority = mPayload.get("hasprecedence");// emxGetParameter(request,"hasprecedence");
		
		System.out.println("Body:"+body+",var:"+var+",id:"+objectId);
		
		HashMap programMap = new HashMap();
		HashMap paramMap = new HashMap();
		programMap.put("paramMap", paramMap);
		paramMap.put("attrBody",body);
		paramMap.put("attrVar",var);
		paramMap.put("objectId",objectId);
		paramMap.put("doSave",doSave);
		paramMap.put("typeEdit",typeEdit);
		paramMap.put("name",name);
		paramMap.put("hasPrec",priority);

		MapList retour = (MapList)JPO.invoke(context, "emxPLMRuleEditor", null, "check", JPO.packArgs(programMap), MapList.class);
// 		System.out.println("Result :"+retour);
		if(typeEdit.equals("PLMBusinessRule")&&doSave.equals("1")&&retour.isEmpty())//Ne fait un deploy que si c'est une BusinessRule, que la commande est de sauver et que le parse ne renvoie pas d'erreur
		{
			JPO.invoke(context,"emxBusinessRulesEditorProgram",null,"updateBusinessRule",JPO.packArgs(programMap));
		}
		String xmlReturn = "<root>";
		for(Object o : retour){
			Map m = (HashMap)o;
			xmlReturn += "<parseError l='"+m.get("line")+"' i='"+m.get("info")+"'><![CDATA[";
			xmlReturn += m.get("msg");
			xmlReturn += "]]></parseError>\n";
		}
		xmlReturn += "</root>";
		
		response.getWriter().write(xmlReturn);
	} else if(command.equals("delete")) {
		String selectedId[] = emxGetParameterValues(request,"emxTableRowId");
		
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
				Boolean canDelete = (Boolean)JPO.invoke(context, "emxPLMRuleEditor", null, "deleteEntity", args, Boolean.class);
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
			<script language="Javascript">
				top.refreshTablePage();
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
		MapList retour = (MapList)JPO.invoke(context, "emxPLMRuleEditor", null, "createEntity", JPO.packArgs(programMap), MapList.class);
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
						objForm = emxUICore.getNamedForm(top.opener,0);
						txtType = objForm.elements["Father"];
						txtTypeDisp = objForm.elements["FatherDisplay"];
						txtType.value = "<%=sObjId%>";
						txtTypeDisp.value = "<%=parentName%>";
						top.close();
					</script>				 
				<%
				}
			//}
		}
	} else if(command.equals("selectCheck")) {
		String selectedId[] = emxGetParameterValues(request,"emxTableRowId");
		
		if(selectedId != null )
		{
			StringTokenizer st = null;
			String sRelId = "";
			String sObjId = "";
			String sObjIdList = "";
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
				sObjIdList += sObjId +";";
				
			}
			String[] args = new String[] { sObjIdList };
			MapList retour = (MapList)JPO.invoke(context, "emxPLMRuleEditor", null, "selectEntity", args, MapList.class);
			System.out.println("retour "+retour);
		}
	}
	System.out.println("End emxPLMRuleEditorDialog.jsp");
%>


