<%--  emxIndentedTable.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@ page import="com.matrixone.jdom.*,com.matrixone.jdom.output.*,com.matrixone.json.*,com.matrixone.apps.framework.ui.UITableIndentedUtil"%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@page import="java.io.StringReader"%>
<%@page import="javax.json.JsonReader"%>
<%@page import="javax.json.JsonArray"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonObjectBuilder"%>
<%@page import="javax.json.JsonObject"%>
<%@ page import = "matrix.db.*, matrix.util.*,
				   com.matrixone.util.*,
				   com.matrixone.servlet.*,
				   com.matrixone.apps.framework.ui.*,
				   com.matrixone.apps.domain.util.*,
				   com.matrixone.apps.domain.*,
				   java.util.*,
				   java.io.*,
				   java.net.URLEncoder,
				   java.util.*,
				   com.matrixone.jsystem.util.*"%>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>
<%!
    public static String getStackTrace(Throwable t) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw, true);
        t.printStackTrace(pw);
        pw.flush();
        sw.flush();
        return sw.toString();
    }
%>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<%
	if (false) {
		System.out.print("--------------------------------\nGETDATA:\n    ");
		StringList pp = FrameworkUtil.split(emxGetQueryString(request), "&");
		pp.sort();
		System.out.println(FrameworkUtil.join(pp, "\n    "));
	}
//Added code to support the Global Search 
String cmddName = emxGetParameter(request, "cmddName");
if(cmddName!=null && "AEFTypesGlobalSearchCommand".equalsIgnoreCase(cmddName)){
	HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
	Vector userRoleList = PersonUtil.getAssignments(context);
	String stToolbar = emxGetParameter(request, "toolbar");
	String language = request.getHeader("Accept-Language");
	
	JsonObjectBuilder shortcutJson = BPSJsonObjectBuilder.createJsonObjectBuilder(Json.createObjectBuilder());
	HashMap params = new HashMap();
	JsonArray objectJsonArr  = null;
	JsonArray collectioArr = UIUtil.getObjectCategoryJson(context,"", cmddName, application, session, request, objectJsonArr);
	shortcutJson.add("collections",collectioArr);
	out.clear();
	response.setContentType("application/json; charset=UTF-8");
	out.write(shortcutJson.build().toString());
	return;
	}

if(cmddName!=null && "AEFCollabSpace".equalsIgnoreCase(cmddName)){
	HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);
	String language = request.getHeader("Accept-Language");
	JsonArray collectioArr = PersonUtil.getCollaborativeSpaceCommands_New(context);	
	out.clear();
	response.setContentType("application/json; charset=UTF-8");
	out.write(collectioArr.toString());
	return;
	}

String isStructureCompare = emxGetParameter(request, "IsStructureCompare");
if ( "TRUE".equalsIgnoreCase(isStructureCompare)){
	indentedTableBean = (com.matrixone.apps.framework.ui.UIStructureCompare)structureCompareBean;
}
// get time stamp
String timeStamp = emxGetParameter(request, "fpTimeStamp");
	if (timeStamp == null) { throw new Exception("null timeStamp: " + emxGetQueryString(request)); }
	if (timeStamp == null || timeStamp.length() == 0 || indentedTableBean.getTableData(timeStamp) == null) {
		out.clear();
        response.setContentType("text/xml; charset=UTF-8");
		String myError = "<mxRoot><error>No Content in the timeStamp</error></mxRoot>";
        out.write(myError);
		return;
    }

// get browser os type
String ua = request.getHeader("user-agent");
String isUnix = (ua.toLowerCase().indexOf("x11") > -1)?"true":"false";

// get time zone
String timeZone=(String)session.getAttribute("timeZone");

String sRowIds = (String)emxGetParameter(request, "rowIds");
String sLevelId = (String)emxGetParameter(request, "levelId");
String sObjectId = (String)emxGetParameter(request, "objectId");
String isRowEditable = (String)emxGetParameter(request, "RowEditable");
String pacRowEditableFlag = (String)emxGetParameter(request, "pacRowEditableFlag");
String sSortColumnName = (String)emxGetParameter(request, "sortColumnName");
String sSortDirection = (String)emxGetParameter(request, "sortDirection");
String sMassUpdateColumn = (String)emxGetParameter(request, "massUpdateColumn");
String sOutputFormat = (String)emxGetParameter(request, "outputFormat");
String sbImages = (String)emxGetParameter(request, "sbImages");
boolean isLoggingEnabled=false;
long serverTimeLocal=0L;
// Get table data
HashMap tableData = indentedTableBean.getTableData(timeStamp);
	if (tableData == null) { throw new Exception("null table data for timeStamp " + timeStamp + " " + emxGetQueryString(request));}
// Get request data
HashMap requestMap = indentedTableBean.getRequestMap(tableData);
	if (tableData == null) { throw new Exception("null request map for timeStamp " + timeStamp  + " " + emxGetQueryString(request));}
if(requestMap!=null && requestMap.containsKey("logPerformance")) {
		isLoggingEnabled=true;
}

// get transaction type
String transactionType = emxGetParameter(request, "TransactionType");
if(UIUtil.isNullOrEmpty(transactionType)){
	transactionType = (String) requestMap.get("TransactionType");
}
boolean updateTransaction = (transactionType != null && transactionType.equalsIgnoreCase("update"));

if (sOutputFormat != null) {
    requestMap.put("reportFormat",sOutputFormat);
    requestMap.put("exportFormat",sOutputFormat);
} else {
    requestMap.remove("reportFormat");
    requestMap.remove("exportFormat");
}

if (sbImages != null) {
    requestMap.put("sbImages",sbImages);
} else {
    requestMap.remove("sbImages");
}

String sFirstTime = (String)emxGetParameter(request, "firstTime");
requestMap.put("firstTime", sFirstTime);
if(isLoggingEnabled) {
	serverTimeLocal = System.currentTimeMillis();
}
//  pagination start
String sPageNumber = (String)emxGetParameter(request, "pageNumber");
requestMap.put("pageNumber", sPageNumber);
//  pagination end

	String sReset = (String)emxGetParameter(request, "reset");
	if ("true".equalsIgnoreCase(sReset)) {
		// table bean can be reused for new queries with different search criteria
		requestMap = UINavigatorUtil.updateRequestParameterMap(pageContext,requestMap);
		requestMap.remove("txtNoSearch");

		//Added for Autonomy FillPage feature
		requestMap.put("curFTSIndex", request.getParameter("curFTSIndex"));
		
		indentedTableBean.init(context, pageContext, requestMap, timeStamp, PersonUtil.getAssignments(context));
	}

String strExpandLevels = (String)emxGetParameter(request, "expandLevel");
String sToolbarData = (String)emxGetParameter(request, "toolbarData");
if (sToolbarData != null) {
    StringList toolbarList = FrameworkUtil.split(sToolbarData, "|");
    for (int itr = 0; itr < toolbarList.size(); itr++) {
        String urlParameter = (String)toolbarList.get(itr);
        if (urlParameter != null && !"".equals(urlParameter)) {
            StringList urlParameterList = FrameworkUtil.split(urlParameter, "=");
 			if (strExpandLevels != null && (urlParameter.startsWith("expandLevel") || urlParameter.startsWith("emxExpandFilter") ))
				urlParameterList.add(1, strExpandLevels);
            requestMap.put(urlParameterList.get(0), urlParameterList.get(1));
        }
    }
}

String sLevelIds = (String)emxGetParameter(request, "sLevelIds");
String cids = (String)emxGetParameter(request, "cids");
String sMode = (String)emxGetParameter(request, "action");
String strDataStatus = (String)emxGetParameter(request, "dataStatus");
//String strExpandLevels = (String)emxGetParameter(request, "expandLevel");
if(strExpandLevels != null && !"".equals(strExpandLevels)){
	requestMap.put("expandLevel",strExpandLevels);
}

String date = (String)emxGetParameter(request, "date");
String isdate = (String)emxGetParameter(request, "isdate");
String columnIndex = (String)emxGetParameter(request, "columnIndex");

String reloadProgram = (String)emxGetParameter(request, "ReloadProgram");
String reloadFunction = (String)emxGetParameter(request, "ReloadFunction");
String columnValuesRP = (String)emxGetParameter(request, "columnValues");
String rcType = (String)emxGetParameter(request, "rcType");
String rcTarget = (String)emxGetParameter(request, "rcTarget");
String rowValues = (String)emxGetParameter(request, "rowValues");

String customCalProgram = (String)emxGetParameter(request, "customCalProgram");
String customCalFunction = (String)emxGetParameter(request, "customCalFunction");
String allColValues = (String)emxGetParameter(request, "columnValues");
StringList slColVal = (StringList) FrameworkUtil.splitString(allColValues,"|~|");
try {
    // start transaction
    ContextUtil.startTransaction(context, updateTransaction);
    Document doc = null;

    if("remove".equals(sMode)) {
        indentedTableBean.removeCacheData(context, timeStamp, sLevelIds);
        ContextUtil.commitTransaction(context);
        return;
    }

    XMLOutputter  outputter = MxXMLUtils.getOutputter(true);
    if("true".equals(isdate)){

        int colIndex = new Integer(columnIndex).intValue();
        // get the table column definitions
        MapList columns = indentedTableBean.getColumns(tableData);
        HashMap columnMap =(HashMap) columns.get(colIndex);
        String sortType = indentedTableBean.getFormatedDate(context,date,columnMap,timeZone,request.getLocale());
        HashMap  lzMap = (HashMap) indentedTableBean.getLzDate(context,sortType, columnMap, requestMap, timeZone);
        String display = (String)lzMap.get("value");
        String msvalue = (String)lzMap.get("msValue");
        out.clear();
        response.setContentType("text/xml; charset=UTF-8");
        String dataXML = "<mxRoot><date>";
		         dataXML += "<actual>"+ XSSUtil.encodeForXML(context,date) +"</actual>";
		         dataXML += "<display>"+display+"</display>";
		         dataXML += "<msvalue>"+msvalue+"</msvalue>";
		         dataXML += "<sortType>"+sortType+"</sortType>";
        		 dataXML += "</date></mxRoot>";
        out.write(dataXML);
        ContextUtil.commitTransaction(context);
        return;

  }
    // if object id present
    if ("add".equals(sMode)) {
        requestMap.put("dataStatus",strDataStatus);
        if(isRowEditable != null && isRowEditable.equalsIgnoreCase("false")&& strDataStatus!=null && (strDataStatus.equalsIgnoreCase("committed")||strDataStatus.equalsIgnoreCase("success"))){
        MapList childObjectList = indentedTableBean.createChildList(context, sLevelIds, cids, strDataStatus);
            doc = indentedTableBean.updateCacheDataWithMask(context, timeStamp, childObjectList,timeZone,false);
        }else if(pacRowEditableFlag!= null && "true".equalsIgnoreCase(pacRowEditableFlag)){
            MapList childObjectList = indentedTableBean.createChildList(context, sLevelIds, cids, strDataStatus,true);
            doc = indentedTableBean.updateCacheDataWithMask(context, timeStamp, childObjectList,timeZone,true);
        }else{
            MapList childObjectList = indentedTableBean.createChildList(context, sLevelIds, cids, strDataStatus);
        doc = indentedTableBean.updateCacheData(context, timeStamp, childObjectList,timeZone);
		} 
        
        java.util.List<Element> lChildRows = doc.getRootElement().getChild("rows").getChildren();
        ArrayList aChildRowIds = new ArrayList();
        boolean childrenExists = false;
        for (Element childRow: lChildRows) {
            java.util.List<Element> columns = childRow.getChildren("c");
            if (columns != null && columns.size() > 0) {
                childrenExists = true;
            }
            aChildRowIds.add(childRow.getAttributeValue("id"));
        }

        if (!childrenExists) {
            Document childDoc = indentedTableBean.getXMLByLevelIDs(context, timeStamp, aChildRowIds, timeZone);
            java.util.List<Element> rows = doc.getRootElement().getChild("rows").getChildren();

            java.util.List<Element> rowsWithColumn = childDoc.getRootElement().getChild("rows").getChildren();

            for (Element row: rows) {

                String id = row.getAttributeValue("id");
                for (Element rowWithColumn: rowsWithColumn) {
                    String idWithColumn = rowWithColumn.getAttributeValue("id");
                    if (id.equals(idWithColumn)) {
                        java.util.List<Element> columns = rowWithColumn.getChildren();
                        for (Element column: columns) {
                            row.addContent((Content)column.clone());
                        }
                        break;
                    }
                }
            }
        }
    } else if ("changed".equals(sMode)) {
        StringList changedItems = FrameworkUtil.splitString(sLevelIds,"|~|");
        for(int i=0;i<changedItems.size();i++){
            
            StringList rowList = FrameworkUtil.splitString((String)changedItems.get(i),"|`|");
            
            Map childObjectList1 = indentedTableBean.createChildListForChanged(context,(String) rowList.get(1),tableData,timeZone,request.getLocale());
            
            TreeMap indexedObjectList = (TreeMap)tableData.get("IndexedObjectList");
            Map objInfoMap = (Map)indexedObjectList.get((String)rowList.get(0));
            
            java.util.Iterator itr = childObjectList1.keySet().iterator();
            
            while(itr.hasNext()){
               	String key = (String)itr.next();
                String value = (String)childObjectList1.get(key);

                if(objInfoMap.containsKey(key))
                {
                	objInfoMap.put(key,value);
                	ArrayList arrayList = (ArrayList)objInfoMap.get("sortBy");
                	HashMap sortMap =(HashMap)arrayList.get(0);
                	String sortKey = (String)sortMap.get("name");
                	if(sortKey.equals(key))
                		sortMap.put("value",value);
                }
            }
        }
        ContextUtil.commitTransaction(context);
        return;
    } else if (sObjectId != null || "true".equals(sFirstTime)) {
        if(sObjectId == null) {
        	sObjectId = "";
        }
        if(sSortColumnName != null){
        	requestMap.put("sortColumnName", sSortColumnName);
        	requestMap.put("sortDirection", sSortDirection);
        }
        // get xml
		if ( "TRUE".equalsIgnoreCase(isStructureCompare))
        {
			doc = structureCompareBean.getXMLByOID(context, timeStamp, sObjectId, timeZone);
        }
        else
        {
        	if ("true".equals(sFirstTime) && sSortColumnName != null) {
                if (sSortDirection == null || sSortDirection == "") {
                    sSortDirection = "";
              }
        		indentedTableBean.updateSortColumn(context, timeStamp, sSortColumnName,sSortDirection);
            }
        	doc = indentedTableBean.getXMLByOID(context, timeStamp, sObjectId, timeZone);
        }
    } else if (sLevelId != null) {

        String sDirection = (String)emxGetParameter(request, "direction");
        if (sDirection != null && sDirection.length() != 0) {
            requestMap.put("direction", sDirection);
        }

        String sSelectedType = (String)emxGetParameter(request, "selectedType");
        if (sSelectedType != null && sSelectedType.length() != 0) {
            requestMap.put("selectedType", sSelectedType);
        }

        String sSelectedRelationship = (String)emxGetParameter(request, "selectedRelationship");

        if (sSelectedRelationship != null && sSelectedRelationship.length() != 0) {
            requestMap.put("selectedRelationship", sSelectedRelationship);
        }
        requestMap.put("level", sLevelId);
        // get xml
        //doc = indentedTableBean.getXMLByLevelID(context, timeStamp, sLevelId);
        doc = indentedTableBean.getXMLByLevelID(context, timeStamp, sLevelId, timeZone);
    } else if (sRowIds != null) {
        StringTokenizer st = new StringTokenizer(sRowIds, ":");
        ArrayList aRowIds = new ArrayList();
        while (st.hasMoreTokens()) {
            String sRowId = (String)st.nextToken();
            aRowIds.add(sRowId);
        }

        if (sMassUpdateColumn == null) {
            doc = indentedTableBean.getXMLByLevelIDs(context, timeStamp, aRowIds, timeZone);
            // Bug 376653
            // this loop should be moved down into bean code
            // gqh: this has been moved to bean code.
            //java.util.List rowElems = doc.getRootElement().getChild("rows").getChildren("r");
            //for (int i=0; i<aRowIds.size() && i<rowElems.size(); i++) {
            //    Element rowElem = (Element)(rowElems.get(i));
            //    rowElem.setAttribute("id", (String)aRowIds.get(i));
            //}

        } else {
            doc = indentedTableBean.getXMLColumnInfo(context, timeStamp, sMassUpdateColumn, aRowIds);
        }
    } else if (sSortColumnName !=  null) {
        //doc = indentedTableBean.getXMLSorted(context, timeStamp, sSortColumnName, sSortDirection);
        doc = indentedTableBean.getXMLSorted(context, timeStamp, sSortColumnName, sSortDirection, timeZone);
    }else if(reloadProgram != null && reloadFunction != null && (reloadProgram.length() > 0 && reloadFunction.length() >0)){
    	
    	StringList reloadProgramList =  (StringList) FrameworkUtil.splitString(reloadProgram,",");
    	StringList reloadFunctionList = (StringList) FrameworkUtil.splitString(reloadFunction,",");
    	StringList columnIndexList = (StringList) FrameworkUtil.splitString(columnIndex,",");
    	StringList columnNames = (StringList) FrameworkUtil.splitString((String) emxGetParameter(request, "colNames"), ",");
    	StringList inputTypeList = (StringList) FrameworkUtil.splitString((String) emxGetParameter(request, "inputType"), ",");
    	String dataXML = "<mxRoot>";
    	HashMap colData = new HashMap();
    	
    	for(int i=0; i<reloadFunctionList.size(); i++)
    	{
    	boolean flag = false;
    	String columnXMLName = "<column name=\"" + columnNames.get(i) +"\">";
    	String columnXMLContent = "";
        int colIndex = new Integer((String)columnIndexList.get(i)).intValue();
        HashMap requestMapRP = indentedTableBean.getRequestMap(timeStamp);
        MapList columnsRP = indentedTableBean.getColumns(tableData);
        HashMap columnMapRP =(HashMap) columnsRP.get(colIndex-1);
        HashMap columnValRP = indentedTableBean.getDisplayValues(columnValuesRP);
        
        HashMap rowValMap   = new HashMap();
        JsonReader jsonReader = null;
		JsonObject rowValuesJson = null;
		
        try {
        	jsonReader = Json.createReader(new StringReader(rowValues));
        	rowValuesJson = jsonReader.readObject();
			Iterator itr   = rowValuesJson.keySet().iterator();
			while(itr.hasNext()) {
			    String key = (String)itr.next();
			    rowValMap.put(key,rowValuesJson.getString(key));
			}
        }catch (Exception ex) {
            
        }finally{
        	jsonReader.close();
        }
        
        HashMap columnDetails = new HashMap();
        
        HashMap eventDetails = new HashMap();
        eventDetails.put("Type",rcType);
        eventDetails.put("Target",rcTarget);
        HashMap paramMap = new HashMap();
        paramMap.put("columnMap", columnMapRP);
        paramMap.put("requestMap", requestMapRP);
        paramMap.put("columnValues", columnValRP);
        paramMap.put("rowValues", rowValMap);
        paramMap.put("Event", eventDetails);
        paramMap.put("ColumnNames",columnNames);
        String[] methodargs = JPO.packArgs(paramMap);

        
        // If same function,Program,Input Type do not invoke 
     if(!colData.isEmpty()){
        for ( int j=0; j<reloadProgramList.size()-1 && j<i ; j++)
        {
        	if( reloadProgramList.get(j).equals(reloadProgramList.get(i)) && reloadFunctionList.get(j).equals(reloadFunctionList.get(i)) && inputTypeList.get(j).equals(inputTypeList.get(i)))
        	{
        		String locXML = (String) colData.get(columnNames.get(j));
        		dataXML += columnXMLName + locXML;
        		flag=true;
        		break;
        	}
        }
     }
                
        if(!flag){
        FrameworkUtil.validateMethodBeforeInvoke(context, (String) reloadProgramList.get(i), (String) reloadFunctionList.get(i), "Program"); 	
        HashMap returnMap = (HashMap)JPO.invoke(context, (String) reloadProgramList.get(i), null,(String) reloadFunctionList.get(i), methodargs, HashMap.class);
        //Added to get the Input type from reload JPO --START
        if(returnMap.get("Input Type") == null){
        	returnMap.put("Input Type", (String)inputTypeList.get(i));
        }
        String busSelect = UITableCommon.getBusinessObjectSelect(columnMapRP);
        String busType = (String) rowValMap.get("type");
        if(returnMap.get("Input Type").toString().equals("textarea") && !UIUtil.isNullOrEmpty(busType)&& !UIUtil.isNullOrEmpty(busSelect)){
        	  if ("description".equals(busSelect)){
                  if(UIRTEUtil.isRTEEnabled(context, busType, busSelect)){
                	  returnMap.put(UITableCommon.ISRTEFIELD, "true");
              	}
              } else {
              	if (!"empty".equalsIgnoreCase(busSelect))
                {
            		try {
                    	String attributeName = UOMUtil.getAttrNameFromSelect(busSelect);
                    	if(UIRTEUtil.isRTEEnabled(context, busType, attributeName)){
                    		returnMap.put(UITableCommon.ISRTEFIELD, "true");
                        }
                    } catch(Exception e){
                   }
                }
            }
        }
        String colXMLString = UITableIndentedUtil.getColumnXMLString(context, returnMap);
        columnXMLContent += colXMLString + "</column>";
        colData.put(columnNames.get(i), columnXMLContent);
        dataXML += columnXMLName + columnXMLContent;
       }
        
    }
        out.clear();
        response.setContentType("text/xml; charset=UTF-8");
    	dataXML += "</mxRoot>";
        out.write(dataXML);
        ContextUtil.commitTransaction(context);
        return;
        
    }else if(customCalProgram!=null && customCalFunction!= null && customCalProgram.length() > 0 && customCalFunction.length() > 0 ){
        HashMap paramMap = new HashMap();
    	paramMap.put("columnValues", slColVal);
        String[] methodargs = JPO.packArgs(paramMap);
		FrameworkUtil.validateMethodBeforeInvoke(context, customCalProgram, customCalFunction, "Program");
        String sRtn = (String)JPO.invoke(context, customCalProgram, null, customCalFunction, methodargs, String.class);
        out.clear();
        response.setContentType("text/xml; charset=UTF-8");
        out.write(sRtn);
        ContextUtil.commitTransaction(context);
        return;
	}else {
        //doc = indentedTableBean.getWholeXML(context, timeStamp);
        doc = indentedTableBean.getWholeXML(context, timeStamp, timeZone);
    }

    // set output
    out.clear();
    response.setContentType("text/xml; charset=UTF-8");
    //Added for BUG:377321
      //outputter.output(doc, out);
    String outString = outputter.outputString(doc);
    out.print(outString);
	if(isLoggingEnabled) {
    	if(tableData != null) {
    		serverTimeLocal=System.currentTimeMillis()-serverTimeLocal;
    		serverTimeLocal+=(Long)tableData.get("totalServerTime");
    		tableData.put("totalServerTime", serverTimeLocal);
    	}
    }
    ContextUtil.commitTransaction(context);
    // End: Get Data
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
        out.clear();
        response.setContentType("text/xml; charset=UTF-8");
        ex.printStackTrace();
%><?xml version="1.0" encoding="UTF-8"?>
<mxRoot>
<action>error</action>
    <message><![CDATA[An error occurred while processing your request]]></message>
    <stack><![CDATA[Refer the console logs for stack trace]]></stack>
</mxRoot>
        <%
    }

%>
