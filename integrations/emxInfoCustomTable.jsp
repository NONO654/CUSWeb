<%--  emxInfoCustomTable.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--
  Description : This file sets the framset for custom table page.
--%>

<html>

<%@include file = "MCADTopInclude.inc"%>
<%@include file = "MCADTopErrorInclude.inc"%>
<%@include file = "emxInfoCustomTableInclude.inc"%>

<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	String objectID = emxGetParameter(request, "objectId");
    
	//Sets the Target Page value in the session
    String pageName = "emxInfoCustomTable.jsp";
    if (emxGetQueryString(request) != null) 
	{
        pageName += "?" + emxGetQueryString(request);
    }

    Framework.setTargetPage(session, pageName);
	
    //Get no of items per page as specified in request parameters
    String pagination = emxGetParameter(request, "custPagination");
 
    //Gets JPO program Name
    String programName = emxGetParameter(request, "custProgram");
    String sHelpMarker = emxGetParameter(request, "HelpMarker");
    
    //Get timeStamp to handle the table data,column definitions and current index
    String timeStamp = Long.toString(System.currentTimeMillis());

    //Collect all the parameters passed-in and forward them to Tree frame.
    String appendParams = "timeStamp=" + timeStamp + "&" + emxGetQueryString(request) + "&HelpMarker=" + sHelpMarker;
     
    String tableHeaderURL = UINavigatorUtil.encodeURL("emxInfoCustomTableHeader.jsp?" + appendParams);    
    String tableBodyURL = UINavigatorUtil.encodeURL("emxInfoCustomTableBody.jsp?" + appendParams);

    //Create CustomMaplist which will be used to collect table data
    CustomMapList tableData = new CustomMapList();

    //Create collection to store column definitions
    ArrayList columnDefs = new ArrayList();

    try 
    { 
		//Parse JPO name specfied as request parameter
        if (programName != null && programName.length() > 0 ) 
        {
            String tableDataMethodName			= "getTableData";
   	        String columnDefinitionsMethodName	= "getColumnDefinitions";
            
			// Build hasmap out of parameters that were passed as request parameters to this page
			// this hashmap is sent as an input parameter to the JPO being called
			Enumeration enumParamNames = emxGetParameterNames(request);
	   
			HashMap paramMap = new HashMap();
			while(enumParamNames.hasMoreElements())
			{
				String paramName	= (String) enumParamNames.nextElement();
				String paramValue	= (String)emxGetParameter(request, paramName);
				if (paramValue != null && paramValue.trim().length() > 0 )
					paramMap.put(paramName, paramValue);
			}

			paramMap.put("languageStr", request.getHeader("Accept-Language") );
			
			MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

			String integrationName = util.getIntegrationName(context, objectID);
			
			//Pass global config object through gcoString			
			MCADGlobalConfigObject globalConfigObject = integSessionData.getGlobalConfigObject(integrationName,context);
			paramMap.put("GCOObject", globalConfigObject);
			
			try 
			{
				String[] intArgs = new String[]{};

				tableData = (CustomMapList)JPO.invoke(context, programName, intArgs, "getTableData", JPO.packArgs(paramMap), CustomMapList.class);
				columnDefs = (ArrayList)JPO.invoke(context, programName, intArgs,"getColumnDefinitions", JPO.packArgs(paramMap), ArrayList.class);
				
			} 
			catch (MatrixException me)
			{
				emxNavErrorObject.addMessage("Unable to invoke Method : " + "in JPO : " + programName);
				if (me.toString() != null && (me.toString().trim()).length() > 0)
					emxNavErrorObject.addMessage(me.toString().trim());
			}
    	}

	    // Determine number of objects to be displayed at a time on a page
        if ( ( tableData != null ) && ( tableData.size() > 0 ) )
        {
            int noOfItemsPerPage = 0;
            if (pagination != null)
            {
                noOfItemsPerPage = Integer.parseInt(pagination);
                if (noOfItemsPerPage == 0)
               	    noOfItemsPerPage = tableData.size();
            }

            //Save the resuls of JPO into session
			//Save current index in the session
            Integer currentIndex = new Integer((noOfItemsPerPage));
            session.setAttribute("TableData" + timeStamp, tableData);
            session.setAttribute("CurrentIndex" + timeStamp, currentIndex);	      
        }

		//Save column definitons in the session
        if(columnDefs != null && columnDefs.size()>0 )
        {       
      	    session.setAttribute("ColumnDefinitions" + timeStamp,columnDefs);
        }    
    } 
	catch (Exception ex)
	{
    	if (ex.toString() != null && (ex.toString().trim()).length() > 0)
        	emxNavErrorObject.addMessage(ex.toString().trim());
	} 
%>
	<head>
	<title>ENOVIA - Table View</title>
	<%@include file = "MCADBottomErrorInclude.inc"%>
	</head>

	 <frameset rows="85,*,50,0" framespacing="0" frameborder="no" border="0" onunload="JavaScript:cleanupCustomTableSession('<%=XSSUtil.encodeForJavaScript(context,timeStamp)%>')">
	    <!--XSSOK-->
     	<frame name="listHead" src="<%=tableHeaderURL%>" noresize="noresize" marginheight="10" marginwidth="10" border="0" scrolling="auto" />
		<!--XSSOK-->
     	<frame name="listDisplay" src="<%=tableBodyURL%>" noresize="noresize marginheight="0" marginwidth="10" />
     	<frame name="listFoot" src="../common/emxBlank.jsp" noresize="noresize" marginheight="0" marginwidth="10" border="0" scrolling="no" />
		<frame name="hiddenCustomFrame" id="hiddenCustomFrame" noresize src="../common/emxBlank.jsp" scrolling="no" marginheight="0" marginwidth="0" frameborder="0" />
    </frameset>
</html>
<%
  //Sets current page in session variable
  Framework.setCurrentPage(session, Framework.getTargetPage(session));
%>


