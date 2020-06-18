<% response.setContentType("text/xml; charset=UTF-8"); %>
<%--  CompositeDocument.jsp
   static const char RCSID[] = $Id: /ENORequirementsManagementBase/CNext/webroot/requirements/CompositeDocumentReport.jsp 1.4.2.1.1.1 Wed Oct 29 22:20:01 2008 GMT przemek Experimental$
--%>
<%@include file = "../emxRequestWrapperMethods.inc"%>

<%@page import="com.matrixone.jdom.Document"%>
<%@page import="com.matrixone.jdom.Element"%>
<%@page import="com.matrixone.jdom.output.XMLOutputter"%>
<%@page import="com.matrixone.util.MxXMLUtils"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.requirements.CompositeDocument"%>
<%@page import="com.matrixone.apps.requirements.RIFDocumentUtil"%>
<%
   // Named href parameters recognized by this JSP code:
   String	program = emxGetParameter(request, "program");
   String	exptype = emxGetParameter(request, "exportType");

   String	objId   = emxGetParameter(request, "objectId");
   String	fncId   = emxGetParameter(request, "functionId");
   String	logId   = emxGetParameter(request, "logicalId");
   String   phyId   = emxGetParameter(request, "physicalId");
   
   // Context initialization
   Context context = Framework.getFrameContext(request);

   // Extract Table Row ids of the checkboxes selected.
   String[] arrRowIds = emxGetParameterValues(request, "emxTableRowId");
   
   if (arrRowIds == null || arrRowIds.length == 0)
   {
      arrRowIds = new String[1];
      arrRowIds[0] = objId;
   }
   else if (objId == null || objId.equals("null"))
   {
      objId = arrRowIds[0];
   }

   // Extract the Object ids of the Objects to be processed...
   boolean bIsFromTree = (arrRowIds[0].indexOf("|") >= 0);
   String[] arrObjIds = (bIsFromTree? new String[arrRowIds.length]: arrRowIds);

   if (bIsFromTree)
   {
      for (int ii = 0; ii < arrRowIds.length; ii++)
      {
         String[] tokens = arrRowIds[ii].split("[|]");
         arrObjIds[ii] = (tokens.length > 1? tokens[1]: tokens[0]);
      }
   }

   // Export the selected object, using the JPO method specified in the href...
   MapList     expList = new MapList();
   try
   {
      int      separator = program.indexOf(":");
      String   jpoProgram = program.substring(0, separator);
      String   jpoMethod = program.substring(separator+1);

      String[] auth = null;
      String[] objIds = new String[4];
      objIds[0] = objId;
      objIds[1] = fncId;
      objIds[2] = logId;
      objIds[3] = phyId;

      // Invoke the JPO method to export the specified content.
      HashMap programMap = new HashMap();
      HashMap paramMap = new HashMap();
      paramMap.put("rowIds", objIds);
      programMap.put("paramMap", paramMap);

      HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
      programMap.put("requestMap", requestMap);

      String[] args = JPO.packArgs(programMap);
      
      if (!exptype.equals("ICD"))
      {
      	expList = (MapList) JPO.invoke(context, jpoProgram, auth, jpoMethod, args, MapList.class);
      }
      
	   // Place the MapList data into a DOM structure that can be printed as XML
	   XMLOutputter  xmlOut = MxXMLUtils.getOutputter(false);
	   Document      xmlDoc = null;
	
	   if (exptype.equals("RIF"))
	   {
	      xmlDoc = RIFDocumentUtil.buildDocumentStructure(context, UINavigatorUtil.getRequestParameterMap(pageContext), expList);
	   }
	   else if(exptype.equals("ICD"))
	   {
	   	  try
	   	  {
		  	xmlDoc = (Document)JPO.invoke(context, jpoProgram, auth, jpoMethod, args, Document.class);
		  }
		  catch(MatrixException ex)
		  {
		    //fall back to old code that returns a MapList
		    if(ex.getMessage() != null && ex.getMessage().indexOf("ClassCastException") >= 0){
		      expList = (MapList) JPO.invoke(context, jpoProgram, auth, jpoMethod, args, MapList.class);
		      xmlDoc = CompositeDocument.buildDocumentStructure(context, UINavigatorUtil.getRequestParameterMap(pageContext), expList);
		    }
		    else{
		      throw ex;
		    }
		  }
	   }
	   else
	   {
	      xmlDoc = CompositeDocument.buildDocumentStructure(context, UINavigatorUtil.getRequestParameterMap(pageContext), expList);
	 
	   }
       Element       xmlRoot = xmlDoc.getRootElement();
       Date          nowDate = new Date();
       xmlRoot.setAttribute("date", nowDate.toString());
       xmlRoot.setAttribute("user", PersonUtil.getFullName(context));
	
	   // Now output the whole shebang:
	   out.clearBuffer();
	   xmlOut.output(xmlDoc, out);
   }
   catch(Exception e)
   {
      e.printStackTrace(System.err);
   }

%>
