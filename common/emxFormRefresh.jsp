<%--emxFormRefresh.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormRefresh.jsp.rca 1.1 Wed Nov 19 02:55:22 2008 ds-ss Experimental $
--%>
<%@page import="javax.json.JsonValue.ValueType"%>
<%@ page import = "matrix.db.*,matrix.util.*,com.matrixone.servlet.Framework,java.util.*,java.io.*,
com.matrixone.apps.domain.util.*" %>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@page import="javax.json.JsonArray"%>
<%@page import="javax.json.JsonArrayBuilder"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="java.io.StringReader"%>
<%@page import="javax.json.JsonReader"%>
<jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
	try
	{
	    Context context 	   = Framework.getContext(session);
	    ContextUtil.startTransaction(context, false);
	    
	    response.setHeader("Content-Type", "text/plain; charset=UTF-8");
		response.setContentType("text/plain; charset=UTF-8");
		response.setHeader("Cache-Control", "no-cache");
		response.setHeader("Pragma", "no-cache");
	    
	    String language    	   = request.getHeader("Accept-Language");
	    BufferedReader jReader = new BufferedReader(new InputStreamReader(request.getInputStream(),"UTF-8"));
	    String jsonPost		   = jReader.readLine();
	    JsonReader jsonReader = Json.createReader(new StringReader(jsonPost));
		JsonObject postJson = jsonReader.readObject();
		jsonReader.close();
	   	
		String timeStamp 	   = postJson.getString("TimeStamp");
		String formType    	   = postJson.getString("FormType");
		
		JsonObject eventJson   = postJson.getJsonObject("Event");
		String eventType   	   = eventJson.getString("Type");
		String eventTarget 	   = eventJson.getString("Target");
		
		JsonObject refreshJson = postJson.getJsonObject("Refresh");
		String refreshProgram  = refreshJson.getString("Program");
		String refreshFunction = refreshJson.getString("Function");
		String refreshField	   = refreshJson.getString("Field");
		
		JsonArray fieldValues  = postJson.getJsonArray("FieldValues");
		HashMap fieldValsMap   = new HashMap();
		for(int i = 0; i < fieldValues.size(); i++ ) {
			JsonObject field   = (JsonObject)fieldValues.get(i);
			try{
				fieldValsMap.put(field.getString("Name"),"null".equals(field.getString("Value")) ? null : field.getString("Value") );
			}catch(Exception e){ 
				fieldValsMap.put(field.getString("Name"), "null".equals(field.getJsonObject("Value")) ? null : (field.getJsonObject("Value").isEmpty() ? "" : field.getJsonObject("Value")));
			} 
		}
		
	    HashMap formData = null;
	    boolean tableComponent = false;
	    if("createForm".equalsIgnoreCase(formType)) {
	        formData     = createBean.getFormData(timeStamp);
	    }else if("emxTable".equalsIgnoreCase(formType)) {
	        formData     = tableBean.getTableData(timeStamp);
	        tableComponent = true;
	    }else {
	        formData     = formEditBean.getFormData(timeStamp);
	    }
	    MapList fields = null;
	    if(tableComponent) {
	        fields = tableBean.getColumns(formData);
	    }else {
	        fields = (MapList)formData.get("fields");
	    } 
	    
	    
	    HashMap fieldMap = null;
	    for(int i = 0; i < fields.size(); i++ ) {
	        fieldMap 	 = (HashMap) fields.get(i);
	        if(fieldMap != null && refreshField.equals(fieldMap.get("name"))) break;
	    }
	    
	    HashMap requestMap = (HashMap)formData.get("requestMap");
	    //For Bug 375732
	    if (requestMap == null) requestMap = (HashMap)formData.get("RequestMap");
	    requestMap.put("languageStr",language);
	    requestMap.put("RefereshProgram",refreshProgram);
	    requestMap.put("RefereshFunction",refreshFunction);
	    requestMap.put("RefreshingField",refreshField);
	    
	    HashMap eventMap = new HashMap(2);
	    eventMap.put("Type",eventType);
	    eventMap.put("Target",eventTarget);
        
		HashMap inputMap = new HashMap(4);
		inputMap.put( tableComponent ? "columnValues" : "fieldValues",fieldValsMap);
	    inputMap.put( tableComponent ? "columnMap"    : "fieldMap",fieldMap);
	    inputMap.put("requestMap",requestMap);
	    inputMap.put("Event",eventMap);
	    
	    String[] args   = JPO.packArgs(inputMap);
	    Map resultMap   = null;
		
		try {
		   FrameworkUtil.validateMethodBeforeInvoke(context, refreshProgram, refreshFunction, "Program");
		   resultMap 	= (Map) JPO.invoke(context, refreshProgram, null, refreshFunction,args, Map.class);
		}catch (Exception exJPO) {
		   throw (new FrameworkException(exJPO.toString()));
		}
		
		JsonObjectBuilder responseJson = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder());
		
		if(resultMap != null)
		{
			JsonArrayBuilder rangesActual = Json.createArrayBuilder();
			JsonArrayBuilder rangesDisplay = Json.createArrayBuilder();
		    StringList rangeActualValues  = (StringList)resultMap.get("RangeValues");
		    StringList rangeDisplayValues = (StringList)resultMap.get("RangeDisplayValues");
			String seltActValue       	  = (String)resultMap.get("SelectedValues");
			String seltDispValue     	  = (String)resultMap.get("SelectedDisplayValues");
		    
			if(rangeActualValues != null) {
		        for(int i = 0 ; i < rangeActualValues.size() ; i++) {
		            rangesActual.add((String)rangeActualValues.get(i));
		        }
		    }
		    
		    if(rangeDisplayValues != null) {
		        for(int i = 0 ; i < rangeDisplayValues.size() ; i++) {
		            rangesDisplay.add((String)rangeDisplayValues.get(i));
		        }
		    }
		    
		    responseJson.add("RangeValues", rangesActual);
		    responseJson.add("RangeDisplayValue", rangesDisplay);
		    responseJson.add("SelectedValues", seltActValue);
		    responseJson.add("SelectedDisplayValues", seltDispValue);
		    responseJson.add("Status", "success");
		}else
		{
		    responseJson.add("Status", "fails");
		}
		
	    out.clear();
	    out.print(responseJson.build().toString());
	    ContextUtil.commitTransaction(context);
	    
	} catch (Exception ex)
	{
		JsonObjectBuilder errorJson = Json.createObjectBuilder();
	    errorJson.add("Status","error");
	    errorJson.add("Message",ex.getMessage());
	    ex.printStackTrace();
	    out.clear();
	    out.print(errorJson.build().toString());
	}
%>
