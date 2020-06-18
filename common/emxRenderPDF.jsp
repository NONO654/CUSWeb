<%--  emxRenderPDF.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxRenderPDF.jsp.rca 1.12 Wed Oct 22 15:47:59 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
    com.matrixone.apps.framework.ui.RenderPDF renderPDF = new com.matrixone.apps.framework.ui.RenderPDF();
    String folderName = "";
    String useAdlibSetup="";
    String uiType = "";
    MatrixLogWriter logWriter = new MatrixLogWriter(context);

    try
    {
        String languageCode = request.getHeader("Accept-Language");
        String objectId = emxGetParameter(request, "objectId");
        String suiteKey = emxGetParameter(request, "suiteKey");
        HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);
        HashMap imageData = UINavigatorUtil.getImageData(context, pageContext);
        if (languageCode != null && languageCode.indexOf(",") != -1)
        {
            languageCode=languageCode.substring(0,languageCode.indexOf(","));
        }
        String charSet ="";
        try
        {
            charSet = EnoviaResourceBundle.getProperty(context, "emxFramework.Charset." + languageCode);
        }
        catch ( Exception e)
        {
           languageCode = PersonUtil.getLanguage(context);
           try
           {
               charSet = EnoviaResourceBundle.getProperty(context, "emxFramework.Charset." + languageCode);
           }
           catch ( Exception ex)
           {
               languageCode = "en";
               charSet="UTF8";
           }
        }
        requestMap.put("languageCode", languageCode);

        // time zone to be used for the date fields
        String timeZone = (String)session.getAttribute("timeZone");
        requestMap.put("timeZone", timeZone);
        requestMap.put("PDFrender", "true");
        requestMap.put("ImageData", imageData);

		uiType =emxGetParameter(request, "uiType");
		useAdlibSetup = (String) requestMap.get("useAdlibSetup");
		String pdfFileName = "";
		String fileName = "";
		if("table".equalsIgnoreCase(uiType))
		{
			String timeStamp =emxGetParameter(request, "timeStamp");
			HashMap tableData = tableBean.getTableData(timeStamp);
			if(tableData == null) {
				tableBean.setTableData(context, requestMap, timeStamp, PersonUtil.getAssignments(context));
				tableData = tableBean.getTableData(timeStamp);
			}

        	requestMap.put("tableData", tableData);
        	String subHeader =  emxGetParameter(request, "subHeader");
        	fileName = tableBean.getPageHeader(tableBean.getControlMap(tableData));
        	if ( (subHeader != null) && (subHeader.trim().length() > 0) )
        	{
            	subHeader = UINavigatorUtil.parseHeader(context, pageContext, subHeader, objectId, suiteKey, request.getHeader("Accept-Language"));
            	requestMap.put("subHeader", subHeader);
			}
		}
		else if("form".equalsIgnoreCase(uiType))
		{
			String originalHeader =emxGetParameter(request, "originalHeader");
			String parsedHeader = UIForm.getFormHeaderString(context, pageContext, originalHeader, objectId, suiteKey, languageCode);
			requestMap.put("parseHeader", parsedHeader);
	       	if (objectId != null && !objectId.equalsIgnoreCase("null") && !objectId.equalsIgnoreCase("")) {
	        	DomainObject object = DomainObject.newInstance(context, objectId);
	            StringList selectList = new StringList(4);
	            selectList.add(DomainObject.SELECT_NAME);
	            selectList.add(DomainObject.SELECT_REVISION);
	            String strRev=UINavigatorUtil.getI18nString("emxFramework.Common.Rev","emxFrameworkStringResource",languageCode);

	            Map objectMap = object.getInfo(context, selectList);
	            String objName = (String)objectMap.get(DomainObject.SELECT_NAME);
	            String objRev = (String)objectMap.get(DomainObject.SELECT_REVISION);

	            if (objRev.length() > 100)
	            {
	               objRev="_";
	            }
	            fileName = objName+"-"+strRev+objRev ;
            }
		}
			if("structureBrowser".equalsIgnoreCase(uiType)){
				
				String htmlContent = "";
				BufferedReader reader = new BufferedReader(new InputStreamReader(request.getInputStream(),"UTF-8"));
				Writer writer = new StringWriter();
				char[] buffer = new char[1024];
				int n;
				while ((n = reader.read(buffer)) != -1) {
				writer.write(buffer, 0, n);
				
		    }
		    htmlContent = writer.toString();
					
		    requestMap.put("htmlContent",htmlContent);			    	
			String timeStamp =(String)requestMap.get("timeStamp");
			HashMap tableData = tableBean.getTableData(timeStamp);			
        	fileName="download";
        	
		}
			
		fileName=fileName.replace(' ','_');
		fileName=fileName.replace(':','_');
		pdfFileName =  fileName + ".pdf";
		String appUrl = FrameworkUtil.getMyAppsURL(context, request, response);
		requestMap.put("appUrl", appUrl);
		String realPath = getServletContext().getRealPath("/");		
		requestMap.put("realPath", realPath);
		requestMap.put("fileName", fileName);	
        String[] args = JPO.packArgs(requestMap);        
        
        
        if(useAdlibSetup.equals("true")&&!uiType.equals("structureBrowser")){
        	folderName = renderPDF.streamRenderPDF(context,args);
        }else {
        	folderName = renderPDF.streamRenderPDFFop(context,args);        	
        }
        if ( folderName != null && !"null".equals(folderName) && folderName.length() > 0)
        {
        	 response.setContentType("application/octet-stream");
             response.setHeader ("Content-Disposition","attachment; filename=\"" + pdfFileName +"\"");
             
             InputStream in=null;
        	
        	if(useAdlibSetup.equals("true")&&!uiType.equals("structureBrowser")){
        		 pdfFileName=pdfFileName.replace(' ','_');
                 pdfFileName = FrameworkUtil.encodeURL(pdfFileName,charSet);
        		 String ftpOutputFolder = renderPDF.outputFolder+java.io.File.separator+folderName;
                 com.matrixone.apps.domain.util.mxFtp clientCheckIn= new com.matrixone.apps.domain.util.mxFtp();
                 clientCheckIn.connect(renderPDF.strProtocol, renderPDF.strHostName, null, renderPDF.strUserName, renderPDF.strPassword, ftpOutputFolder, true);
                 clientCheckIn.open(pdfFileName);
                 in = new MyFtpInputStream(clientCheckIn);
        		
        		
        	}else {        		
        		pdfFileName=folderName.substring(folderName.lastIndexOf(java.io.File.separator)+1,folderName.length());
            	pdfFileName=pdfFileName.replace(' ','_');            	
                pdfFileName = FrameworkUtil.encodeURL(pdfFileName,charSet);
                response.setContentType("application/octet-stream");
                response.setHeader ("Content-Disposition","attachment; filename=\"" +pdfFileName +"\"");
                response.addHeader("fileName", pdfFileName);                
                in = new FileInputStream(folderName);
        	}
        	ServletOutputStream sout = response.getOutputStream();
            int count;
            int buffSize = 8*1024;
            byte[] buf = new byte[buffSize];
            while((count = in.read(buf,0,buffSize)) > 0)
            {
                sout.write(buf,0,count);
            }
            in.close();
            sout.close();
            sout.flush();
        }
        out.clear();
        out = pageContext.pushBody();
    } catch(Exception ex)
      {

         if (ex != null &&  ex.toString().trim().equals("java.lang.Exception: PDF Not generated"))
          {
%>
             <script language = "javascript">
              alert("<emxUtil:i18nScript localize="i18nId">emxFramework.RenderPDF.RenderPDFAdLibErrorMessage</emxUtil:i18nScript>");
              parent.closeWindow();
             </script>
<%
          }
          else if (ex != null &&  ex.toString().trim().indexOf("java.io.IOException: 550") > -1)
          {
%>
             <script language = "javascript">
              alert("<emxUtil:i18nScript localize="i18nId">emxFramework.RenderPDF.RenderPDFFolderErrorMessage</emxUtil:i18nScript>");
              parent.closeWindow();
             </script>
<%
          }
          else if (ex != null &&  ( ex.toString().trim().equals("java.io.IOException:") || ex.toString().trim().equals("java.lang.NullPointerException")) )
          {
               if(useAdlibSetup.equals("true")&&!uiType.equals("structureBrowser")){        	 
            	   %>
        		    <script language = "javascript">
               alert("<emxUtil:i18nScript localize="i18nId">emxFramework.RenderPDF.RenderPDFFTPErrorMessage</emxUtil:i18nScript>");
               parent.closeWindow();
              </script>
            <%
        	 }else {        		 
        		 response.setStatus(500);        		 
        		 logWriter.write(ex.toString());
        	}
               
          }else {        	 
        	  
        	  if(useAdlibSetup.equals("true")&&!uiType.equals("structureBrowser")){
        	 
        	  %>
        		    <script language = "javascript">
               alert("<emxUtil:i18nScript localize="i18nId">emxFramework.RenderPDF.RenderPDFFTPErrorMessage</emxUtil:i18nScript>");
               parent.closeWindow();
              </script>
              
            <%
        	 }else {
        		
        		 response.setStatus(500);        		 
        		 logWriter.write(ex.toString());
        	}
          }
     }
     finally
     {
         if ( folderName != null && !"null".equals(folderName) && folderName.length() > 0)
        {
        	 if(useAdlibSetup.equals("true")&&!uiType.equals("structureBrowser")){
        		 renderPDF.cleanupPdfInputOpuputDirectories(context, folderName);
        		 
        	 }else {
        		 
        		 renderPDF.cleanupDirectory(context, folderName);
        	 }
        	 
             
        }
     }
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc" %>
