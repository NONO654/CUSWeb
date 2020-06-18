<%-- emxMultipleClassificationEndItemsSearch.jsp

   static const char RCSID[] = $Id: emxMultipleClassificationEndItemsSearch.jsp.rca 1.1.3.2 Wed Oct 22 16:02:19 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
<emxUtil:localize id="i18nId" bundle="emxLibraryCentralStringResource" locale='<xss:encodeForHTML><%= request.getHeader("Accept-Language") %></xss:encodeForHTML>' />

<%
    String strDocumentCentralAppDir   = "documentcentral";
    String strClassificationModuleDir = emxGetParameter(request, "SuiteDirectory");
    //type_Library is the symbolic name for "Document Library" 
    String strDocumentLibrary = PropertyUtil.getSchemaProperty(context, "type_Library");
    String strBookShelf       = PropertyUtil.getSchemaProperty(context, "type_Bookshelf");
    String strBook            = PropertyUtil.getSchemaProperty(context, "type_Book");

    String strFormActionURL = "../" + strDocumentCentralAppDir + "/emxLibraryCentralClassifiedEndItemsSearch.jsp";

    // The page to be used when the main search dialog is to be dispalyed. This new page will have the 
    // attribute groups listed on it for putting search criteria.
    String strSearchPageURL = "../" + strClassificationModuleDir + "/emxMultipleClassificationEndItemsSearchView.jsp";
    
    // The page to be used when the Type is selected and the page is required to be refreshed.
    String strMainSearchDialogPage = strSearchPageURL;

    // The page to be used when the search button is clicked.
    String strSearchProcessPage = "../" + strClassificationModuleDir + "/emxMultipleClassificationSearchWithInProcess.jsp";
    
    String emxTableRowIds[] = (String[]) emxGetParameterValues(request, "emxTableRowId");
    String emxTableRowId   = getTableRowIDsString(emxTableRowIds);

    String objId = "";

    String strParameterName  = "";
    String strParameterValue = "";
    java.util.Enumeration enumParameters = emxGetParameterNames(request);

    StringBuffer queryString  = new StringBuffer("?");
    
    while (enumParameters.hasMoreElements())
    {
        strParameterName  = (String)enumParameters.nextElement();
        strParameterValue = emxGetParameter(request, strParameterName);
        if("objectId".equals(strParameterName))
        {
            if(strParameterValue==null || "null".equals(strParameterValue) || "".equals(strParameterValue))
            {
                strParameterValue = emxTableRowId;
                objId = emxTableRowId;
            }
            else
            {
                objId = strParameterValue;
            }
        } else if("uiType".equals(strParameterName) || "rowIds".equals(strParameterName)) {
            continue;
        }
        queryString.append(strParameterName);
        queryString.append("=");
        queryString.append(strParameterValue);
        queryString.append("&");
    }//while !
    queryString.append("urlSearchContentPage=");
    queryString.append(strSearchPageURL);
    queryString.append("&searchProcessPage=");
    queryString.append(strSearchProcessPage);
    queryString.append("&mainSearchDialogPage=");
    queryString.append(strMainSearchDialogPage);
    if(objId.equals("") || "".equals(objId)) {
        objId = emxTableRowId;
        queryString.append("&objectId=");
        queryString.append(objId);
    }
    String strSubmitActionURL = strFormActionURL + queryString.toString();
    
    String systemQueryType = EnoviaResourceBundle.getProperty(context,"emxFramework.FullTextSearch.QueryType");
    String libraryQueryType = EnoviaResourceBundle.getProperty(context,"emxLibraryCentral.SearchWithIn.QueryType");
    boolean showFullTextsearch = false;
    StringBuffer sbSubmitActionURL = null;
    if("Indexed".equals(systemQueryType) && "Indexed".equals(libraryQueryType)){
        String searchWithinLevel = emxGetParameter(request,"searchWithinLevel");
        String searchResultsTable = "";
        if("Library".equals(searchWithinLevel)){
            searchResultsTable = "LCSearchClassificationListAtLibrary";
        }else{
            searchResultsTable = "LCSearchClassificationList";
        }
        
        DomainObject domObj = new DomainObject(objId);
        String typeName = domObj.getInfo(context,domObj.SELECT_TYPE);
        String interfaceValue = domObj.getAttributeValue(context, domObj.ATTRIBUTE_MXSYSINTERFACE);
        
		// Changes done by PSA11 start(IR-532768-3DEXPERIENCER2018x).
        StringBuffer sbFieldParam = new StringBuffer();
        sbFieldParam.append("INTERFACES=");
        sbFieldParam.append(interfaceValue);
		// Changes done by PSA11 end.
		
		// Pack the ObjectId of class
    	HashMap hmObj = new HashMap();
    	hmObj.put("objectId",objId);
        
		// Find the attribute list for this Class Object ID.
        String attributeList = (String) JPO.invoke(context, "emxLibraryCentralClassificationAttributes", null, "getFormInclusionList", JPO.packArgs(hmObj), String.class);
        
        sbSubmitActionURL = new StringBuffer("../common/emxFullSearch.jsp?");
        //sbSubmitActionURL.append("field="+FrameworkUtil.encodeURL(sbFieldParam.toString()));
		// Changes for Advanced Search Highlight Start
		if(!attributeList.isEmpty()){
        	sbSubmitActionURL.append("&formInclusionList=" + attributeList);
			sbSubmitActionURL.append("&tableInclusionList=" + attributeList);
        }
		sbSubmitActionURL.append("&fieldQueryProgram=emxLibraryCentralUtil:getClassInterfaceValue");
		// Changes for Advanced Search Highlight End
        sbSubmitActionURL.append("&table="+searchResultsTable);
        sbSubmitActionURL.append("&HelpMarker=emxhelpfullsearch");
        sbSubmitActionURL.append("&showInitialResults=false");
        sbSubmitActionURL.append("&suiteKey=LibraryCentral");
        sbSubmitActionURL.append("&selection=multiple");
        sbSubmitActionURL.append("&StringResourceFileId=emxLibraryCentralStringResource");
        sbSubmitActionURL.append("&SuiteDirectory=documentcentral");
        sbSubmitActionURL.append("&objectId="+objId);
        
        showFullTextsearch = true;
    }
    
%>
<body>
</body>
<% if(showFullTextsearch){%>
    <script language="javascript">
    showModalDialog("<xss:encodeForJavaScript><%=sbSubmitActionURL.toString()%></xss:encodeForJavaScript>","SearchIn", 700, 500, true);
    </script>
<%}else{ %>
    <script language="javascript">
    showModalDialog("<xss:encodeForJavaScript><%=strSubmitActionURL%></xss:encodeForJavaScript>","SearchIn", 700, 500, true);
    </script>
<%} %>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
