<%@ page import = "matrix.db.*,matrix.util.*,com.matrixone.apps.domain.util.*,com.matrixone.servlet.*,java.util.*,java.io.BufferedReader,java.io.StringReader" %>
<%@page import="java.io.InputStreamReader"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="javax.json.JsonArray"%>
<%@page import="javax.json.JsonReader"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonString"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%><jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
	Context context = Framework.getContext(session);

	ContextUtil.startTransaction(context, false);
	response.setHeader("Content-Type", "text/plain; charset=UTF-8");
    response.setContentType("text/plain; charset=UTF-8");
    response.setHeader("Cache-Control", "no-cache"); //HTTP 1.1
    response.setHeader("Pragma", "no-cache"); //HTTP 1.0

    Map typeAheadMap    = UINavigatorUtil.getRequestParameterMap(request);
    
	String timeStamp    = UIUtil.getValue(typeAheadMap, "timeStamp");
	String uiType       = UIUtil.getValue(typeAheadMap, "uiType");
	String field        = UIUtil.getValue(typeAheadMap, "field");
	String program      = UIUtil.getValue(typeAheadMap, "program");
	String function     = UIUtil.getValue(typeAheadMap, "function");
	String form         = UIUtil.getValue(typeAheadMap, "form");
	String table        = UIUtil.getValue(typeAheadMap, "table");	
	String mode         = UIUtil.getValue(typeAheadMap, "mode");
	String language     = request.getHeader("Accept-Language");
	//String columnMapXML = request.getParameter("columnMap");
	String level = request.getParameter("level");
	String isFromChooser = request.getParameter("isFromChooser");
	HashMap formData = null;
	boolean tableComponent = false;
	if ("createForm".equalsIgnoreCase(uiType) || 
			("form".equalsIgnoreCase(uiType) && "create".equalsIgnoreCase(mode))) 
	{
		formData = createBean.getFormData(timeStamp);
	} else if ("emxTable".equalsIgnoreCase(uiType)) {
		formData = tableBean.getTableData(timeStamp);
		tableComponent = true;
	} else if ("structureBrowser".equalsIgnoreCase(uiType)) {
		formData = indentedTableBean.getTableData(timeStamp);
		tableComponent = true;
		form = table;
	} else {
		formData = formEditBean.getFormData(timeStamp);
	}

	MapList fields = new MapList();
	if (tableComponent) {
		fields = tableBean.getColumns(formData);
	} else if(formData != null){
		fields = (MapList) formData.get("fields");
	}else{
		return;
	}

	HashMap fieldMap = new HashMap();
	for (int i = 0; i < fields.size(); i++) {
		fieldMap = (HashMap) fields.get(i);
		boolean hasAccess = formEditBean.hasAccessToFiled(fieldMap);
		if (fieldMap != null && field.equals(fieldMap.get("name")) && hasAccess)
			break;
	}

	HashMap requestMap = (HashMap) formData.get("requestMap");
	if (requestMap == null)
		requestMap = (HashMap) formData.get("RequestMap");

	//if( ! UIUtil.isNullOrEmpty(columnMapXML))
		//requestMap.put("columnMap", columnMapXML);
	if(! UIUtil.isNullOrEmpty(level))
		requestMap.put("level", level);

	String xml = "";
	String charTyped = "";

	if (context != null) {
        HashMap map = new HashMap();
		BufferedReader jReader = new BufferedReader(new InputStreamReader(request.getInputStream(), "utf-8"));
		String jsonPost = jReader.readLine();
		JsonReader jsonReader = Json.createReader(new StringReader(jsonPost));
		JsonObject postJson = jsonReader.readObject();
		jsonReader.close();
		charTyped = postJson.containsKey("type_ahead_filter") ? postJson.getString("type_ahead_filter") : "";
		JsonArray fieldValues = postJson.getJsonArray("fieldValues");
		
		HashMap fieldValuesMap = new HashMap();
		
		for(int i = 0; i < fieldValues.size(); i++)
		{
			JsonObject jsObject = fieldValues.getJsonObject(i); 
			if("structureBrowser".equals(uiType)&& Boolean.parseBoolean(isFromChooser)){				
				Object tempJsonVal = jsObject.get("value");
				if(tempJsonVal instanceof JsonObject){
					fieldValuesMap.put(jsObject.getString("name"), jsObject.getJsonObject("value"));
				}else{
					fieldValuesMap.put(jsObject.getString("name"), jsObject.getString("value"));
				}
			}else{				
				Object tempJsonVal = jsObject.get("Value");
				if(tempJsonVal instanceof JsonObject){
					fieldValuesMap.put(jsObject.getString("Name"), jsObject.getJsonObject("Value"));
				}else{
					fieldValuesMap.put(jsObject.getString("Name"), jsObject.getString("Value"));
				}		
				
			}
		}
		// Code to update the JPO App Server Param List
	    UINavigatorUtil.updateJpoAppServerParamList(pageContext,requestMap);

		map.put("form", form);
		map.put("requestMap", requestMap);
		map.put("field", field);
		map.put("typeAheadMap", typeAheadMap);
		map.put("fieldMap", fieldMap);
		map.put("language", language);
		map.put("charTyped", charTyped);
		map.put("fieldValuesMap", fieldValuesMap);		


		try {
			FrameworkUtil.validateMethodBeforeInvoke(context, program, function, "Program");
			xml = (String) JPO.invoke(context, program, JPO
					.packArgs(map), function, JPO.packArgs(charTyped),
					String.class);
			ContextUtil.commitTransaction(context);
		} catch (Exception e) {
			ContextUtil.abortTransaction(context);
			throw (new JspException(e));
		}
	}
	out.clear();
	out.print(xml.trim());
%>
