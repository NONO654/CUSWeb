<%--
  emxProgramCentralImportSummary.jsp

  Preprocess form for importing a type and it's related sub-types.  The
  ProgramCentralUtil bean contains static methods that handle the parsing of the
  csv input file and the type specific validation for each import.  If new types
  are added to the import a type specific validation will need to be written for
  each.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program.

  static const char RCSID[] = "$Id: emxProgramCentralImportSummary.jsp.rca 1.22 Wed Oct 22 15:49:29 2008 przemek Experimental przemek $";
--%>

<%@include file = "emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxProgramCentralImportUtil.inc"%>

<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  String language     = request.getHeader("Accept-Language");
  String errorsOnPage = "False";

  String printerFriendly = emxGetParameter(request,"PrinterFriendly");
  if (!"true".equals(printerFriendly)) {
    formBean.processForm(session, request);
  }

  //get form values;
  String objectId        = (String) formBean.getElementValue("objectId");
  String fileName        = (String) formBean.getElementValue("fileName");
  String importType      = (String) formBean.getElementValue("importType");


  java.io.File inputFile = (java.io.File) formBean.getElementValue("FilePath");

  String inputFilePath = "";
  if (inputFile == null || "null".equals(inputFile) || "".equals(inputFile)) {
    inputFilePath = (String) session.getAttribute("inputFilePath");
    inputFile = new java.io.File(inputFilePath);
  } else {
    session.setAttribute("inputFilePath", inputFile.toString());
  }

  MapList resultSet = new MapList();
  try {
		if (inputFile != null){
			resultSet = (MapList) ImportUtil.loadAndValidateImport(inputFile,importType,language,context);
		}

		HashMap rpnCounter = new HashMap();
		if (importType.equals(DomainConstants.TYPE_RISK)){
			int lastRecord = resultSet.size();
			lastRecord--;
			rpnCounter = (HashMap) resultSet.remove(lastRecord);
			session.setAttribute("rpnCounter", rpnCounter);
		}

		StringList validHeaders        = new StringList();
		StringList riskHeader          = new StringList();
		StringList rpnHeader           = new StringList();
		StringList financialItemHeader = new StringList();
		StringList costItemHeader      = new StringList();
		StringList benefitItemHeader   = new StringList();
		StringList qualityHeader       = new StringList();
		StringList dMetricHeader       = new StringList();
		StringList cMetricHeader       = new StringList();

		String type_risk =
			PropertyUtil.getSchemaProperty(context,"type_Risk");
		StringList riskSubtypeStringList = ProgramCentralUtil.getSubTypesList(context,type_risk);
		String type_rpn =
			PropertyUtil.getSchemaProperty(context,"type_RPN");
		String type_financialitem =
			PropertyUtil.getSchemaProperty(context,"type_FinancialItem");
		String type_benefititem =
			PropertyUtil.getSchemaProperty(context,"type_BenefitItem");
		String type_costitem =
			PropertyUtil.getSchemaProperty(context,"type_CostItem");
		String type_quality =
			PropertyUtil.getSchemaProperty(context,"type_Quality");
		// Metrics use the type Metric but discrete use different attribues
		String type_dMetric = "DiscreteMetric";
		String type_cMetric = "ContinuousMetric";

		validHeaders.addAll(riskSubtypeStringList);
		validHeaders.add(type_rpn);
		validHeaders.add(type_financialitem);
		validHeaders.add(type_benefititem);
		validHeaders.add(type_costitem);
		validHeaders.add(type_quality);
		validHeaders.add(type_dMetric);
		validHeaders.add(type_cMetric);

		// Load the headers for each type that will be imported.
		if (importType.equals(type_risk)){
			riskHeader          = (StringList) ImportUtil.loadHeaderList(type_risk,
																												language, context);
			rpnHeader           = (StringList) ImportUtil.loadHeaderList(type_rpn,
																												language, context);
		} else if (importType.equals(type_financialitem)){
			financialItemHeader = (StringList) ImportUtil.loadHeaderList("FinancialItem",
																												language, context);
			benefitItemHeader   = (StringList) ImportUtil.loadHeaderList("BenefitItem",
																												language, context);
			costItemHeader      = (StringList) ImportUtil.loadHeaderList("CostItem",
																												language, context);
		} else if (importType.equals(type_quality)){
			qualityHeader       = (StringList) ImportUtil.loadHeaderList(type_quality,
																												language, context);
			dMetricHeader       = (StringList) ImportUtil.loadHeaderList(type_dMetric,
																												language, context);
			cMetricHeader       = (StringList) ImportUtil.loadHeaderList(type_cMetric,
																												language, context);
		}

		String headerType = "";
		StringList typeHeader = new StringList();


		if ("true".equals(printerFriendly)) {
			formBean.processForm(session, request);
			//get form values;
			String xobjectId   = objectId;
			String xfileName   = fileName;
			String ximportType = importType;
			java.io.File xinputFile = inputFile;
			formBean.processForm(session, request);
		}
%>

<html>
<%
	if(!"true".equals(printerFriendly)){
%>
  <body class="white">
    <form name="TypeImportSummary" action="" method="post">
<%
	} else {
%>
  <body class="white" onUnLoad="reloadImport()">
    <form name="TypeImportSummary" action="" method="post">
<%
	}
%>
      <input type="hidden" name="importType" value="<xss:encodeForHTMLAttribute><%=importType%></xss:encodeForHTMLAttribute>" />
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	  
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
      <table class="list" border="0" width="100%">
      <%-- XSSOK--%>  
             <framework:mapListItr mapList="<%= resultSet %>" mapName="currentEntry">
          <%
            String entryType = (String) currentEntry.get("Type");
            String errorStr = (String) currentEntry.get("Error");
            // Determine if we need to print the header row
          %>
        <%-- XSSOK--%> 
              <framework:ifExpr expr='<%=(headerType != null && !(headerType.equals(entryType)))%>'>
            <%  headerType = entryType;
            if (validHeaders.contains(entryType)){%>
           <%-- XSSOK--%>   
                  <framework:ifExpr expr='<%=(riskSubtypeStringList.contains(headerType))%>'>
                <% typeHeader = riskHeader; %>
              </framework:ifExpr>
           <%-- XSSOK--%> 
                  <framework:ifExpr expr='<%=(headerType.equals(type_rpn))%>'>
                <% typeHeader = rpnHeader;  %>
              </framework:ifExpr>
           <%-- XSSOK--%> 
                  <framework:ifExpr expr='<%=(headerType.equals(type_financialitem))%>'>
                <% typeHeader = financialItemHeader; %>
              </framework:ifExpr>
            <%-- XSSOK--%>  
                 <framework:ifExpr expr='<%=(headerType.equals(type_costitem))%>'>
                <% typeHeader = costItemHeader; %>
              </framework:ifExpr>
            <%-- XSSOK--%>  
               <framework:ifExpr expr='<%=(headerType.equals(type_benefititem))%>'>
                <% typeHeader = benefitItemHeader; %>
              </framework:ifExpr>
            <%-- XSSOK--%>  
                 <framework:ifExpr expr='<%=(headerType.equals(type_quality))%>'>
                <% typeHeader = qualityHeader; %>
              </framework:ifExpr>
            <%-- XSSOK--%> 
                <framework:ifExpr expr='<%=(headerType.equals(type_dMetric))%>'>
                <% typeHeader = dMetricHeader; %>
              </framework:ifExpr>
            <%-- XSSOK--%> 
                   <framework:ifExpr expr='<%=(headerType.equals(type_cMetric))%>'>
                <% typeHeader = cMetricHeader; %>
              </framework:ifExpr>

              <% // First translate the header strings into the correct language
              StringList newTypeHeaderList = ImportUtil.translateHeaderList(entryType,
                                                           typeHeader,
                                                           context.getLocale(),
                                                           language,
                                                           context);
              Iterator typeHeaderItr = newTypeHeaderList.iterator();
              while (typeHeaderItr.hasNext()){
                String header = (String) typeHeaderItr.next(); %>
                <th>
                  <%=header%>
                </th> <%
              }
            } // End of if valid entryType  %>
                <th>
                  <emxUtil:i18n localize="i18nId">
                    emxProgramCentral.Common.ERROR
                  </emxUtil:i18n>
                </th>
          </framework:ifExpr>

          <tr>
            <% // Print out the values in the HTML
            if (validHeaders.contains(entryType)){
              Iterator dataKeyItr = typeHeader.iterator();
              while (dataKeyItr.hasNext()){
                String key = (String) dataKeyItr.next();
                String value = (String) currentEntry.get(key);%>
                <td class="required" align="center">
                  <%=value%>
                </td> <%
              }
            }

            //If there was an error on this entry, print it %>
            <framework:ifExpr expr='<%=(errorStr != null &&
                                        !errorStr.equals(""))%>'>
              <% errorsOnPage = "True"; %>
              <td class="error" align="center">
                <%=errorStr%>
              </td>
            </framework:ifExpr>
          </tr>
        </framework:mapListItr>

       <%-- XSSOK--%> 
             <framework:ifExpr expr='<%=(errorsOnPage.equals("False"))%>'>
          <% session.setAttribute("resultSet", resultSet); %>
        </framework:ifExpr>
<%
  	} catch(Exception e) {
	    session.putValue("error.message", e.getMessage());
%>
        <script language="javascript" type="text/javaScript">
            parent.window.location.href="emxProgramCentralImportTypeFS.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>";
        </script>
<%
    }
%>
		    </table>
		  <input type="hidden" name="errorsOnPage" value="<xss:encodeForHTMLAttribute><%=errorsOnPage%></xss:encodeForHTMLAttribute>" />
    </form>

    <%-- hidden form for refresh --%>
    <form name="HiddenForm" method="post">
      <input type="hidden" name="objectId" />
      <input type="hidden" name="fileName" value="<xss:encodeForHTMLAttribute><%=fileName%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="importType" />
      <input type="hidden" name="inputFilePath" value="<xss:encodeForHTMLAttribute><%=inputFilePath%></xss:encodeForHTMLAttribute>" />
    </form>
  </body>

  <script language="javascript" type="text/javaScript">//<![CDATA[
  <!-- hide JavaScript from non-JavaScript browsers
    f = document.TypeImportSummary;

    turnOffProgress();

    function reloadImport() {
      getTopWindow().getWindowOpener().parent.frames[1].refreshImport();
    }

    function refreshImport(){
      form = document.HiddenForm;
      form.action = "emxProgramCentralImportSummary.jsp";
      f.submit();
    }

    function backUp() {
      f.action = "emxProgramCentralImportType.jsp?objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>";
      f.submit();
    }

    function cancel() {
      //parent.window.getWindowOpener().parent.document.location.reload();
      parent.window.closeWindow();
    }

    function validateForm () {
      var jsErrorsOnPage = f.errorsOnPage.value;
      f.action = "emxProgramCentralImportAction.jsp?objectId="+f.objectId.value+
                 "&importType="+f.importType.value;
      if ( "True" == jsErrorsOnPage){
        alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Import.CorrectErrorsAndReImport</emxUtil:i18nScript>");
        f.action="emxProgramCentralImportType.jsp?objectId="+f.objectId.value+
                 "&importType="+f.importType.value;
      }
      startProgressBar(false);
      f.submit();
    }
  //Stop hiding here -->//]]>
  </script>
</html>
