<%--  emxCalendarLoad.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCalendarLoad.jsp.rca 1.14 Wed Oct 22 15:48:16 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@ page import = "matrix.db.*" %>
<%@ page import = "com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.eMatrixDateFormat"%>
<%@ page import="com.matrixone.apps.domain.util.MapList,com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@ page import = "java.util.*"%>
<%@page import="java.text.*"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session" />
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>    
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
    
<%  //clear the output buffer
    out.clear();
    String calendarProgram = (String)emxGetParameter(request, "CalendarProgram");
    String calendarFunction = (String)emxGetParameter(request, "CalendarFunction");
    String calStartDate_msValue = (String)emxGetParameter(request, "calStartDate");
    String calEndDate_msValue = (String)emxGetParameter(request, "calEndDate");
    String componentType = (String)emxGetParameter(request, "componentType");
    String mode = (String)emxGetParameter(request, "mode");
    String strObjectId = (String)emxGetParameter(request, "objectId");
    String strrelationId = (String)emxGetParameter(request, "relationId");
    //Added:25-01-10:nr2:IR-035216V6R2011      
    String strcolumnName = (String)emxGetParameter(request, "columnName");
    //End:25-01-10:nr2:IR-035216V6R2011
    if(null!= componentType && !"".equals(componentType) && componentType.equalsIgnoreCase("structureBrowser")){
    	componentType = "SB";
    }
    	
    Map requestMap = new HashMap();
    //Formatting Date
    String calStartDate = "";
    String calEndDate = "";
    try{
    	String timeZone = (String)session.getAttribute("timeZone");
    	calStartDate = eMatrixDateFormat.getDateValue(context,calStartDate_msValue,timeZone,request.getLocale());
        calEndDate = eMatrixDateFormat.getDateValue(context,calEndDate_msValue,timeZone,request.getLocale());        
    }catch(Exception e){
    	e.getMessage();
    }
    
    HashMap fields = new HashMap();
    String[] methodArgs = null;
    //Get timestamp here
       String timeStamp = (String)emxGetParameter(request, "calBeanTimeStamp");
    try{
       if(!"".equals(componentType) && (componentType.equals("form") || componentType.equals("table") || (componentType.equals("SB")))){ 
    	   if(componentType.equals("form")){
	    	   if(!"".equals(mode) && "edit".equals(mode)){  
	    		    fields = formEditBean. getFormData(timeStamp.toString());
	    	   }
	    	   else{
	               fields = createBean. getFormData(timeStamp.toString());
	    	   }
	       }
    	   else if(componentType.equals("table")){
               if(!"".equals(mode) && "edit".equals(mode)){  
                   fields = tableBean.getTableData(timeStamp.toString());
              }
    	   }
    	   else if(componentType.equals("SB")){
    		   fields = indentedTableBean.getTableData(timeStamp.toString());
    	   }
       }

    	if(fields != null){
    		   if(fields.containsKey("requestMap")) 
    			   requestMap = (HashMap)fields.get("requestMap");
    		   else
    			   requestMap = (HashMap)fields.get("RequestMap"); //For SB

    		//Add Calendar Start Date and End Date in the requestMap
               if(requestMap != null){
		           requestMap.put("calStDate",calStartDate);
		           requestMap.put("calLastDate",calEndDate);
		           requestMap.put("calStartDate_msValue",calStartDate_msValue);
		           requestMap.put("calEndDate_msValue",calEndDate_msValue);
	               if(strObjectId != null && !"".equals(strObjectId))
	                   requestMap.put("objectId",strObjectId);
                   if(strrelationId != null && !"".equals(strrelationId))
	                   requestMap.put("relId",strrelationId);
                   //Added:25-01-10:nr2:IR-035216V6R2011
	               if(null != strcolumnName && !"".equals(strcolumnName))
	                   requestMap.put("columnName",strcolumnName);
                   //End:25-01-10:nr2:IR-035216V6R2011
               }

    	   //Add requestMap to fields
           fields.put("requestMap",requestMap);
       //End
    	   if(requestMap != null)
    		   methodArgs = JPO.packArgs(fields);
       }
    }catch(Exception e){
    	e.getMessage();
    }
    //Get Calendar Program and Calendar function
    Map returnVal = new HashMap();
    if(calendarProgram != null && !"".equals(calendarProgram) && calendarFunction != null && !"".equals(calendarFunction)) {
        FrameworkUtil.validateMethodBeforeInvoke(context, calendarProgram, calendarFunction, "Program");
        returnVal = (HashMap)JPO.invoke(context,calendarProgram,null,calendarFunction,methodArgs,HashMap.class);
    }
    //Process this returnVal
    java.util.Set keyset = returnVal.keySet();
    Iterator it = keyset.iterator();
    StringBuffer returnToJS = new StringBuffer();
    returnToJS.append("");
    long date_msValue = 0l;
    while(it.hasNext()){
    	Date date = (Date)it.next();
    	date_msValue = date.getTime();
    	String value = (String)returnVal.get(date);
    	//Get color from properties file
    	   String calColorProp = "";
    	try{
    	   calColorProp = EnoviaResourceBundle.getProperty(context, "emxFramework.Calendar.Events");
    	}
    	catch (Exception e)
    	{
    		   e.getMessage();	
    	}
    	   String[] arrCalColorProp = new String[10];
    	   if(calColorProp.indexOf(',')!= -1)
    		    arrCalColorProp = calColorProp.split(",");
    	   else
    		   arrCalColorProp[0] = calColorProp;
    	   
    	   boolean found = false;
    	   for(int i=0;i<arrCalColorProp.length;i++){
    		   String iden = arrCalColorProp[i].split("\\|")[0];
    		   if(value.trim().equals(iden.trim())){
    			   value = arrCalColorProp[i];
    		       found = true;
    		       break;
    		   }
    	   }
    	   
    	   if(!found)
    		   value = "DUMMY||selectable";
    	//End  
    	if(returnToJS.length()==0)
    		   returnToJS = returnToJS.append(date_msValue + "|" + value);
    	else
    		returnToJS = returnToJS.append("," + date_msValue + "|" + value);
    }
    //End
    //Just for test if it returns text to Ajax
    response.setContentType("text/plain; charset=UTF-8");
    response.setHeader("Cache-Control", "no-cache");
    response.setHeader("Pragma", "no-cache");

    //Write response back to browser
%><%=returnToJS.toString() %>
