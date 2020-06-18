 <%--  smaAdvisePreprocessDatasetImport.jsp - this jsp creates the case and document, and then generates a ticket
 to upload the dataset file.
 * (c) Dassault Systemes, 2013
 *
--%>
<%-- Common Includes --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "java.util.Enumeration"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainSymbolicConstants"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.XmlTableUtil"%>
<%@page import = "com.dassault_systemes.smaslm.common.util.StringUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.AnalyticsCaseEntityWUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>
<%@page import = "matrix.db.JPO"%>
<%@page import = "matrix.util.MatrixException"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.jdom.Document"%>
<%@page import="com.matrixone.jdom.Element"%>
<%@page import="java.net.URL"%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        
<%
    /****************************************************************
     * For this JSP, the correct context must be obtained from
     * request.getAttribute("context"). This is the context of the
     * containing jsp that is calling us, and was put there by the
     * containing jsp.
     * Otherwise, this jsp ends up with its own context, separate from
     * that of the containing jsp, which also results in a separate
     * database context, which is not good.
     ****************************************************************/
     matrix.db.Context context2 = 
         (matrix.db.Context)request.getAttribute("context");
     if (context2 != null)
         context = context2;
     
     String fileName = java.net.URLDecoder.decode(request.getParameter("fname"), "UTF-8");
     String fileFormat = request.getParameter("fformat");
     String caseTitle = java.net.URLDecoder.decode(request.getParameter("ctitle"), "UTF-8");
     String documentTitle = java.net.URLDecoder.decode(request.getParameter("documentTitle"), "UTF-8");

     if(fileName == null) {
         fileName = "";
     }
     //System.out.println("====smaAdvisePreprocessDatasetImport.jsp=====");
     //System.out.println("filename : "+fileName);
     int dotIndex = fileName.lastIndexOf('.');
     //System.out.println("dotIndex:"+dotIndex);
     if(dotIndex<=0){
         throw new Exception("Bad filename"); 
     }
     String fileName_noExtention = fileName.substring(0,dotIndex);
     if(fileFormat==null || fileFormat.length()<1){
         fileFormat = "generic";
     }
     
     // try to get Document ID from the URL args;
     // if this JSP is called for the second file, the caller will send in
     // document ID in the URL arguments; this is a flag that we do not
     // need to create a Document object, only checkin a new file into
     // an existing Document
     String documentOID = request.getParameter("documentOID");
     String caseId = request.getParameter("caseOID");
     String ticket = null;
     //System.out.println("documentOID : "+documentOID);
     //System.out.println("caseOID : "+caseId);
    
     try {
        
        if(documentOID == null) {

            //System.out.println("===Creating Document and AdviseCase...");
     
            String symbtype_document = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_SimulationDocument_NonVersioned);
            String symbtype_case = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_type_AnalyticsCase);
            String symbRel_vaultedObject = SimulationUtil.getSchemaProperty( DomainConstants.RELATIONSHIP_VAULTED_OBJECTS);
            String vault = SimulationUIUtil.getUserDefaultVault(context);
            String symbPolicy_case = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_policy_AnalyticsCase);
            String symbPolicy_document = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_policy_SimulationDocument);
            String attr_title = SimulationUtil.getSchemaProperty(DomainSymbolicConstants.SYMBOLIC_attribute_Title);

            ContextUtil.startTransaction(context, true);
     
            /* First create a document object*/
            DomainObject documentObject = new DomainObject();
            String documentName = "DataSet-"+fileName_noExtention + System.currentTimeMillis();
            if(documentTitle == null || documentTitle.trim().equals("")) {
                documentTitle = "DataSet-"+fileName_noExtention;
            }
            else {
                documentName = documentTitle.replace(' ', '_').replace('.','_') + "_" + System.currentTimeMillis();
            }
            documentObject.createObject(context, symbtype_document, documentName, null, symbPolicy_document, vault);
            documentObject.open(context);
            documentOID = documentObject.getId(context);
            documentObject.setAttributeValue(context, attr_title, documentTitle);
    
            //System.out.println("Document created, id = "+documentOID);

            /* Second create a case object*/
            
            if(caseTitle.equals("NOCASECREATED")) {
            	// case not needed, only document
                //System.out.println("CASE not needed!");
            }
            else {
            	String name = "AnalyticsCase-" + fileName_noExtention + "-" + System.currentTimeMillis();
    
            	if(caseTitle == null || caseTitle.trim().equals("")){
                	caseTitle = "AnalyticsCase-" + fileName_noExtention + "-" + System.currentTimeMillis();  //This is a placeholder for if a non-random name is desired.
            	} else {
                	name = "AnalyticsCase-" + caseTitle + "-" + System.currentTimeMillis();
            	}

                //System.out.println("Creating Analytics CASE title = " + caseTitle);
    
            	DomainObject caseObject = new DomainObject();
            	caseObject.createObject(context, symbtype_case, name, null, symbPolicy_case, vault);
            	caseObject.open(context);
            	caseId = caseObject.getId(context);
            	caseObject.setAttributeValue(context, attr_title, caseTitle);
            	//System.out.println("Case created, id = "+caseId);
            }

            // if we either created a new Case object, or it's ID was passed in the arguments,
            // connect the new Document to the Case
            if(caseId != null) {

            	/* Connect the case to the Document object */
            	HashMap programMap = new HashMap();
            	HashMap paramMap = new HashMap();
            	paramMap.put("New OID", documentOID); //ID of connector from job to activity
            	paramMap.put("New Value", documentOID); //Job ID advise case should be connected to
            	paramMap.put("objectId", caseId);  //This is the case id.
            	programMap.put("paramMap", paramMap);
            	JPO.invoke(
                    context,
                    "jpo.simulation.AnalyticsCase",
                    null,
                    "CreateAndConnect",
                    JPO.packArgs(programMap));
    
            	//System.out.println("Document and case connected.");
            }
        
            ContextUtil.commitTransaction(context);
        }

        //System.out.println("====getting dataset ticket...");
        /* Generate the Ticket to upload the file */
        ticket = AnalyticsCaseEntityWUtil.getDataSetTicket(context, documentOID, SimulationConstants.XML_DOC_ELEM_CHECKIN, fileName, fileFormat, request);
        //System.out.println("===Obtained ticket for checking in the file: "+ ticket);
    
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
</head>
<body>
<div class="documentID"><%=documentOID%></div>
<div class="caseID"><%=caseId%></div>
<div class="fileName"><%=fileName%></div>
<div class="ticket"><%=ticket%></div>
</body>
