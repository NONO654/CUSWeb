<%--  emxTeamFindLikeQuery.jsp   - execute the database query and produces the search result and displays it in the find Reults page.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTeamFindLikeQuery.jsp.rca 1.37 Wed Oct 22 16:06:28 2008 przemek Experimental przemek $
--%>

<%@ include file  = "eServiceUtil.inc" %>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxPaginationInclude.inc" %>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>

<%@ page import = "java.lang.reflect.*"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%



  boolean isSourcingInstalled = false;

  Class clsRTS=null;
  Class clsRTQ=null;

  try{
    clsRTS = Class.forName("com.matrixone.apps.sourcing.RequestToSupplier");
    clsRTQ = Class.forName("com.matrixone.apps.sourcing.RTSQuotation");
    isSourcingInstalled = true;


  }catch (Exception ex){
  }


  //RequestToSupplier rts     = (RequestToSupplier) DomainObject.newInstance(context, DomainConstants.TYPE_REQUEST_TO_SUPPLIER, DomainConstants.SOURCING);

  DomainObject rts=DomainObject.newInstance(context);
  Object objRts = null;
  Object objRtq = null;

  if(isSourcingInstalled){
    //RequestToSupplier rts     = (RequestToSupplier) DomainObject.newInstance(context, DomainConstants.TYPE_REQUEST_TO_SUPPLIER, DomainConstants.SOURCING);
    objRts = clsRTS.newInstance();
    objRtq = clsRTQ.newInstance();

  }


  Vector vectParamName      = new Vector();
  Map paramMap             = (Map) session.getAttribute("strParams");
  Iterator keyItr          = paramMap.keySet().iterator();
  double clientTZOffset    = (new Double((String)session.getValue("timeZone"))).doubleValue();

  while (keyItr.hasNext())
  {
    String name = (String) keyItr.next();
    String value = (String) paramMap.get(name);
    vectParamName.add(name);
    request.setAttribute(name, value);
  }
  com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
  Company companyObject = person.getCompany(context);
  String companyName = companyObject.getName(context);

  String languageStr          = request.getHeader("Accept-Language");
  String TypeString           = emxGetParameter(request,"TypeString");
  String ComboType            = emxGetParameter(request,"ComboType");
  String sLink                = emxGetParameter(request,"page");
  String sSearchType          = emxGetParameter(request,"searchType");
  String treeMenu             = "";
  String selWorkspaceFolder       = "to["+rts.RELATIONSHIP_VAULTED_DOCUMENTS+"].from.name";
  String selWorkspace             = "to[" + rts.RELATIONSHIP_VAULTED_DOCUMENTS + "].from.to[" + rts.RELATIONSHIP_WORKSPACE_VAULTS + "].from.name";
  String sRequestedDate ="SELECT_QUOTE_REQUESTED_BY_DATE";
  String sPackageName= "SELECT_PACKAGE_NAME";
  boolean adminType = false;

  boolean useTitle  = false;
  boolean allVaults = false;
  boolean treeFlag  = false;

  if (ComboType != null && (null!= Framework.getPropertyValue( session, "type_Part")) && Framework.getPropertyValue( session, "type_Part").equals(ComboType)){
    allVaults = true;
    sSearchType = "Part";
    treeFlag  = true;
    treeMenu = "type_Part"; //JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_Part");
  }
  if (ComboType != null && Framework.getPropertyValue( session, "type_Document").equals(ComboType)){
    useTitle = true;
    sSearchType = "File";
    treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_Document");
  }else if(ComboType != null && (Framework.getPropertyValue( session, "type_Company").equals(ComboType) || Framework.getPropertyValue( session, "type_Organization").equals(ComboType))){
    adminType = true;
    sSearchType ="Company";
    treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_Company");
  }else if(ComboType != null && Framework.getPropertyValue( session, "type_BusinessUnit").equals(ComboType)){
    adminType = true;
    sSearchType ="BU";
    treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_BusinessUnit");
  }else if(ComboType != null && Framework.getPropertyValue( session, "type_Person").equals(ComboType)){
    adminType = true;
    sSearchType ="Person";
    treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_Person");
  }else if(ComboType != null && (null!= Framework.getPropertyValue( session, "type_Package")) && Framework.getPropertyValue( session, "type_Package").equals(ComboType)){
    sSearchType = "Package";
    treeFlag  = true;
    treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_Package");
  }else if(ComboType != null && (null!= Framework.getPropertyValue( session, "type_RequestToSupplier")) && Framework.getPropertyValue( session, "type_RequestToSupplier").equals(ComboType)){
    sSearchType = "RFQ";
    treeFlag  = true;
    treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_RequestToSupplier");
  }else if(ComboType != null && (null!= Framework.getPropertyValue( session, "type_RTSQuotation")) && Framework.getPropertyValue( session, "type_RTSQuotation").equals(ComboType)){
    sSearchType = "Quotation";
    treeFlag  = true;
    treeMenu = JSPUtil.getApplicationProperty(context,application,"eServiceSuiteTeamCentral.emxTreeAlternateMenuName.type_RTSQuotation");
  }
  if(sLink == null){
    sLink = "";
  }
  String returnSearchFrameset = emxGetParameter(request, "returnSearchFrameset");
  String sBoType              = "";
  Enumeration eNumObj         = null;

  String sParameter           = "ComboType="+XSSUtil.encodeForJavaScript(context, ComboType)+"&TypeString="+XSSUtil.encodeForJavaScript(context, TypeString)+"&returnSearchFrameset="
                                +XSSUtil.encodeForJavaScript(context, returnSearchFrameset);

  String strTitleAttr         = "attribute["+rts.ATTRIBUTE_TITLE+"]";

  // Attribute string constants
  String sMatrixType         = "Type";
  String sMatrixName         = "Name";
  String sMatrixRevision     = "Revision";
  String sMatrixOwner        = "Owner";
  String sMatrixVault        = "Vault";
  String sMatrixDescription  = "Description";
  String sMatrixCurrent      = "Current";
  String sMatrixModified     = "Modified";
  String sMatrixOriginated   = "Originated";
  String sMatrixGrantor      = "Grantor";
  String sMatrixGrantee      = "Grantee";
  String sMatrixPolicy       = "Policy";

  // Symbolic Operator string constants
  // Symbolic Operator string constants
  String sAndOr                = "";
  sAndOr = emxGetParameter(request,"andOrParam");

  //default ot and if no param sent.
  if ("or".equals(sAndOr)){
    sAndOr = " || ";
  }else{
    sAndOr = " && ";
  }

  String sEqual              = " == ";
  String sNotEqual           = " != ";
  String sGreaterThan        = " > ";
  String sLessThan           = " < ";
  String sGreaterThanEqual   = " >= ";
  String sLessThanEqual      = " <= ";
  String sMatch              = " ~= ";
  String sQuote              = "\"";
  String sWild               = "*";
  String sOpenParen          = "(";
  String sCloseParen         = ")";
  String sAttribute          = "attribute";
  String sOpenBracket        = "[";
  String sCloseBracket       = "]";

  // Translated string operators
  String sMatrixIncludes     = "Includes";
  String sMatrixIsExactly    = "IsExactly";
  String sMatrixIsNot        = "IsNot";
  String sMatrixMatches      = "Matches";
  String sMatrixBeginsWith   = "BeginsWith";
  String sMatrixEndsWith     = "EndsWith";
  String sMatrixEquals       = "Equals";
  String sMatrixDoesNotEqual = "DoesNotEqual";
  String sMatrixIsBetween    = "IsBetween";
  String sMatrixIsAtMost     = "IsAtMost";
  String sMatrixIsAtLeast    = "IsAtLeast";
  String sMatrixIsMoreThan   = "IsMoreThan";
  String sMatrixIsLessThan   = "IsLessThan";
  String sMatrixIsOn         = "IsOn";
  String sMatrixIsOnOrBefore = "IsOnOrBefore";
  String sMatrixIsOnOrAfter  = "IsOnOrAfter";
  StringBuffer  sbWhereExp  = new StringBuffer();
  String sParam             = "";
  String sAttrib            = "";
  String sValue             = "";
  String sParamName         = "";
  String sWhereExpression   = "";
  Pattern patternAttribute  = new Pattern("");
  Pattern patternOperator   = new Pattern("");

  try {
    sBoType             = emxGetParameter(request, "ComboType");
    eNumObj             = emxGetParameterNames(request);
    if(sBoType == null) {
%>
      <jsp:forward page = "emxTeamFindResults.jsp"/>
<%
    }
    if (emxPage.isNewQuery()) {
    //Get the Advanced Findlike parameters
    String sTxtKeyword      = emxGetParameter(request, "txtKeyword");
    String sTxtFormat       = emxGetParameter(request, "txtFormat");
    String sFormat          = emxGetParameter(request, "comboFormat");

    if (sTxtKeyword == null){
      sTxtKeyword = "";
    }else{
      sTxtKeyword = sTxtKeyword.trim();
    }
    if (sTxtFormat == null){
      sTxtFormat = "";
    }else{
      sTxtFormat = sTxtFormat.trim();
    }
    //Set format as All
    if (sFormat == null){
      sFormat = "All";
    }else{
      sFormat = sFormat.trim();
    }
    //build select params
    SelectList selectStmts = new SelectList();
    selectStmts.addName();
    selectStmts.addId();
    selectStmts.addRevision();
    selectStmts.addCurrentState();
    selectStmts.addOwner();
    selectStmts.addCreationDate();
    selectStmts.addDescription();
    selectStmts.addAttribute(rts.ATTRIBUTE_CO_OWNER);
    selectStmts.addAttribute(rts.ATTRIBUTE_TITLE);
    selectStmts.add(rts.SELECT_LOCKED);

        
    //to construct Query object
    matrix.db.Query query   = new matrix.db.Query();
    //query.open(context);
    query.setBusinessObjectName("*");
    query.setBusinessObjectType(sBoType);
    query.setBusinessObjectRevision("*");
    query.setOwnerPattern("*");
    
    
    if (allVaults){
      query.setVaultPattern("*");
    }else{
      //query.setVaultPattern(context.getVault().getName());

      query.setVaultPattern("*");
    }

    String vaultName = person.getCompanyVaultName(context);

    if(ComboType != null && null != Framework.getPropertyValue( session, "type_Package") && Framework.getPropertyValue( session, "type_Package").equals(ComboType)){
        query.setVaultPattern(vaultName);
    }else if(ComboType != null && null != Framework.getPropertyValue( session, "type_RequestToSupplier") && Framework.getPropertyValue( session, "type_RequestToSupplier").equals(ComboType)){
        query.setVaultPattern(vaultName);
    }

    //Set the search text
    if (!sTxtKeyword.equals("")) {
      query.setSearchText(sTxtKeyword);
    } else {
      query.setSearchText("");
    }

    //Set the Search Format
    if (!sTxtFormat.equals("")) {
     query.setSearchFormat(sTxtFormat);
    } else if (sFormat != null) {

     if (sFormat.equals("All")) {
        query.setSearchFormat("*");
      } else {
        query.setSearchFormat(sFormat);
      }
    }
   
    
    //storing all the  parameter names into a vector
    while (eNumObj.hasMoreElements()) {
      sParam = (String)eNumObj.nextElement();
      vectParamName.add(sParam);
    }

    //Loop to get the parameter values
    for (int i = 0; i < vectParamName.size(); i++) {
     String sTextValue            = "";
      String sSelectValue          = "";
      sValue                       = "";
      sParamName = (String)vectParamName.elementAt(i);
      if (sParamName.length() > 17) {
        //Truncating the parameter name and add that in the pattern object
        if (sParamName.substring(0,16).equals("comboDescriptor_")) {
          sAttrib            = sParamName.substring(16,sParamName.length());
          patternAttribute   = new Pattern(sAttrib);
          //get value of descriptor
          String sArrayObj = (String) paramMap.get(sParamName);
          patternOperator = new Pattern(sArrayObj);
          sTextValue = (String) paramMap.get(sAttrib);
          if (sTextValue == null || sTextValue.equals("")) {
            sTextValue = (String) paramMap.get("txt_" + sAttrib);
          }
         //get value entered into select
            sSelectValue =(String) paramMap.get(sAttrib);
            if(sAttrib.indexOf("Date")>=0)
            {
              if(sSelectValue != null  && !"".equals(sSelectValue))
                sSelectValue= eMatrixDateFormat.getFormattedInputDate(context,sSelectValue,clientTZOffset,request.getLocale());
            }
          //check if text val exists, if not use select
          if(!patternOperator.match("*")) {
            if ((sTextValue == null) || (sTextValue.equals(""))) {
              sValue = sSelectValue;
            } else {
              sValue = sTextValue.trim();
            }
          }
          //To remove the "_" if any in the Attribute name done to  fix for
          //iplanet NN specific Bug
          sAttrib = sAttrib.replace('_',' ');
         //To get the where expression if any parameter values exists
          if ((sValue != null) && (!sValue.equals("")) && (!sValue.equals("*"))) {
            if (sbWhereExp.length() > 0) {
              sbWhereExp.append(sAndOr);
            }
            sbWhereExp.append(sOpenParen);
            if (patternAttribute.match(sMatrixType) ||
              patternAttribute.match(sMatrixName) ||
              patternAttribute.match(sMatrixRevision) ||
              patternAttribute.match(sMatrixOwner) ||
              patternAttribute.match(sMatrixVault) ||
              patternAttribute.match(sMatrixDescription) ||
              patternAttribute.match(sMatrixCurrent) ||
              patternAttribute.match(sMatrixModified) ||
              patternAttribute.match(sMatrixOriginated) ||
              patternAttribute.match(sMatrixGrantor) ||
              patternAttribute.match(sMatrixGrantee) ||
              patternAttribute.match(sMatrixPolicy) ||
              sAttrib.equals("State")) {
              sbWhereExp.append(sAttrib);
            } else {
              sbWhereExp.append(sAttribute + sOpenBracket + sAttrib + sCloseBracket);
            }
            if (patternOperator.match(sMatrixIncludes)) {
              sbWhereExp.append(sMatch + sQuote + sWild + sValue + sWild + sQuote);

            } else if (patternOperator.match(sMatrixIsExactly)) {
              sbWhereExp.append(sEqual + sQuote + sValue + sQuote);

            } else if (patternOperator.match(sMatrixIsNot)) {
              sbWhereExp.append(sNotEqual + sQuote + sValue + sQuote);

            } else if (patternOperator.match(sMatrixMatches)) {
              sbWhereExp.append(sMatch + sQuote + sValue + sQuote);

            } else if (patternOperator.match(sMatrixBeginsWith)) {
              sbWhereExp.append(sMatch + sQuote + sValue + sWild + sQuote);

            } else if (patternOperator.match(sMatrixEndsWith)) {
              sbWhereExp.append(sMatch + sQuote + sWild + sValue + sQuote);

            } else if (patternOperator.match(sMatrixEquals)) {
              sbWhereExp.append(sEqual + sValue);

            } else if (patternOperator.match(sMatrixDoesNotEqual)) {
              sbWhereExp.append(sNotEqual + sValue);

            } else if (patternOperator.match(sMatrixIsBetween)) {
              sValue       = sValue.trim();

              int iSpace   = sValue.indexOf(" ");
              String sLow  = "";
              String sHigh = "";

              if (iSpace == -1) {
                sLow  = "";
                sHigh = "";
              } else {
                sLow  = sValue.substring(0,iSpace);
                sHigh = sValue.substring(sLow.length(),sValue.length());
              }

              sbWhereExp.append(sGreaterThanEqual + sLow + sCloseParen + sAndOr + sOpenParen);

              if (patternAttribute.match(sMatrixDescription) ||
                patternAttribute.match(sMatrixCurrent) ||
                patternAttribute.match(sMatrixModified) ||
                patternAttribute.match(sMatrixOriginated) ||
                patternAttribute.match(sMatrixGrantor) ||
                patternAttribute.match(sMatrixGrantee) ||
                patternAttribute.match(sMatrixPolicy)) {
                sbWhereExp.append(sAttrib);

              } else {
                sbWhereExp.append(sAttribute + sOpenBracket + sAttrib + sCloseBracket);
              }
              sbWhereExp.append(sLessThanEqual + sHigh);

            } else if (patternOperator.match(sMatrixIsAtMost)) {
              sbWhereExp.append(sLessThanEqual + sValue);

            } else if (patternOperator.match(sMatrixIsAtLeast)) {
              sbWhereExp.append(sGreaterThanEqual + sValue);

            } else if (patternOperator.match(sMatrixIsMoreThan)) {
              sbWhereExp.append(sGreaterThan + sValue);

            } else if (patternOperator.match(sMatrixIsLessThan)) {
              sbWhereExp.append(sLessThan + sValue);
            } else if (patternOperator.match(sMatrixIsOn)) {
              sbWhereExp.append(sEqual + sQuote + sSelectValue + sQuote);

            } else if (patternOperator.match(sMatrixIsOnOrBefore)) {
              sbWhereExp.append(sLessThanEqual + sQuote + sSelectValue + sQuote);
            } else if (patternOperator.match(sMatrixIsOnOrAfter)) {
              sbWhereExp.append(sGreaterThanEqual + sQuote + sSelectValue + sQuote);
            }
            sbWhereExp.append(sCloseParen);
          }

        }
      }

    }
    sWhereExpression    = sbWhereExp.toString();
    String dateBegin    = emxGetParameter(request, "dateBegin");
    String dateEnd      = emxGetParameter(request, "dateEnd");
    String whereStart   = "";

    //Formatting Date to Ematrix Date Format
    if(dateBegin != null && !"".equals(dateBegin))
      dateBegin = eMatrixDateFormat.getFormattedInputDate(context,dateBegin,clientTZOffset,request.getLocale());
    if(dateEnd != null && !"".equals(dateEnd))
      dateEnd = eMatrixDateFormat.getFormattedInputDate(context,dateEnd,clientTZOffset,request.getLocale());

    if (!"".equals(sWhereExpression)){
      whereStart = "&&";
    }
    if ((dateBegin != null) && (!"".equals(dateBegin))) {
      sWhereExpression += whereStart + "(originated > \"" + dateBegin + "\")";
      whereStart = " && ";
    }
    if ((dateEnd != null) && (!"".equals(dateEnd))) {
      sWhereExpression += whereStart + "(originated < \"" + dateEnd +"\")";
      whereStart = " && ";
    }

    //check for read access at least.
    if (!"".equals(sWhereExpression)){
      whereStart = "&&";
    }else{
      whereStart = "";
    }
    sWhereExpression += whereStart + "(owner != \"#DENIED!\"";
   if(ComboType != null && Framework.getPropertyValue( session, "type_Person").equals(ComboType)){
    String sRelEmployee = Framework.getPropertyValue(session, "relationship_Employee");
    sWhereExpression += " && to["+sRelEmployee+"].from.Name  == \"" + companyName + "\")";
    }else{
      sWhereExpression += ")";
    }

    //to set the where expression in the query
    query.setWhereExpression(sWhereExpression);
    //Executing the Qery and storing the result in the business object list
    BusinessObjectWithSelectList boList = null;
    boList = query.select(context,selectStmts);
    //query.close(context);
    MapList maps = FrameworkUtil.toMapList(boList);
    if (ComboType != null && Framework.getPropertyValue( session, "type_Document").equals(ComboType)){
      MapList DocList = getDocumentMapList(context , session , maps);
      emxPage.getTable().setObjects(DocList);
      emxPage.getTable().setSelects(new SelectList());

    }else if (ComboType != null && Framework.getPropertyValue( session, "type_Package").equals(ComboType)){
      MapList m1 = getPackageMapList(context, session , maps);
      emxPage.getTable().setObjects(m1);
      emxPage.getTable().setSelects(new SelectList());
    }else if(ComboType != null && Framework.getPropertyValue( session, "type_RequestToSupplier").equals(ComboType)) {

      MapList m2 = getRFQMapList(context , session , maps);
      emxPage.getTable().setObjects(m2);
      emxPage.getTable().setSelects(new SelectList());
    }else if(ComboType != null && Framework.getPropertyValue( session, "type_RTSQuotation").equals(ComboType)){
      MapList m3 = getQuotationMapList(context, session , maps);
      emxPage.getTable().setObjects(m3);
      emxPage.getTable().setSelects(new SelectList());

    }else if(ComboType != null ){
      MapList m4 = getAdminMapList(context, session , maps ,ComboType);

      emxPage.getTable().setObjects(m4);
      emxPage.getTable().setSelects(new SelectList());

    }

  }

    // this Maplist is the one which is used to make the table.
    MapList constructedList = emxPage.getTable().evaluate(context, emxPage.getCurrentPage());

    int resultCount = 0;
%>

<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript">
  function newSearch() {
   parent.window.location.href=unescape(unescape("<%=XSSUtil.encodeForJavaScript(context, returnSearchFrameset)%>"));
  }

  function loadTree(id , treemenu) {
  var frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
<%
    String treePage = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=";
    if(!treeFlag){
%>
	<!-- //XSSOK -->
    frameContent.document.location.href = "<%=treePage%>" + id + "&treeMenu=" + treemenu;
<%
}else{
%>

    frameContent.document.location.href = "../common/emxTree.jsp?objectId=" + id;
<%
}
%>
    parent.window.closeWindow();
  }
</script>

<%@ include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
 String relCollaborationPartner  = Framework.getPropertyValue(session,"relationship_CollaborationPartner");
    boolean isHostRep   = false;
    boolean showURL   = true;
    String myCompanyId  = "";
    StringList sBUList = null;
    StringList partnersList = new StringList();
    if(ComboType.equals(rts.TYPE_ORGANIZATION) || ComboType.equals(rts.TYPE_COMPANY) || ComboType.equals(rts.TYPE_BUSINESS_UNIT)) {
      String relDivision              = Framework.getPropertyValue(session, "relationship_Division");
      com.matrixone.apps.common.Person myPerson = com.matrixone.apps.common.Person.getPerson(context);
      BusinessObject myCompany  = Company.getCompanyForRep(context,myPerson);
      myCompany.open(context);
      myCompanyId = myCompany.getObjectId();
      Organization templateObj = (Organization) DomainObject.newInstance(context, DomainConstants.TYPE_ORGANIZATION, DomainConstants.TEAM);
      templateObj.setId(myCompanyId);
      myCompany.close(context);
      isHostRep = Company.isHostRep(context,myPerson);
      String sBUId   = "from[" + relDivision + "].to.id";
      sBUList = templateObj.getInfoList(context,sBUId);
      partnersList = templateObj.getInfoList(context, "from["+relCollaborationPartner+"].to.id");
    }
%>

<form name="FindLikeSearchForm"  target="_parent" method="get">
<input type="hidden" name="page" value="<xss:encodeForHTMLAttribute><%=sLink%></xss:encodeForHTMLAttribute>" />


<%
 if (ComboType != null && Framework.getPropertyValue( session, "type_Document").equals(ComboType)){
%>
<!-- //XSSOK -->
<framework:sortInit defaultSortKey="Name" defaultSortType="string" mapList="<%=constructedList%>" resourceBundle="emxTeamCentralStringResource" ascendText="emxTeamCentral.Common.SortAscending" descendText="emxTeamCentral.Common.SortDescending" params = "<%=sParameter%>"  />



 <table class="list">
      <tr>
        <th>&nbsp;</th>
        <th nowrap>
          <framework:sortColumnHeader
            title="emxTeamCentral.Common.Name"
            sortKey="Name"
            sortType="string"
            anchorClass="sortMenuItem"/>
        </th>
        <th nowrap>
          <framework:sortColumnHeader
            title="emxTeamCentral.Common.Workspace"
            sortKey="WSName"
            sortType="string"
            anchorClass="sortMenuItem"/>
        </th>
        <th nowrap>
          <framework:sortColumnHeader
            title="emxTeamCentral.Common.Folder"
            sortKey="WSVaultName"
            sortType="string"
            anchorClass="sortMenuItem"/>
        </th>
        <th nowrap>
          <framework:sortColumnHeader
            title="emxTeamCentral.Common.Version"
            sortKey="Version"
            sortType="string"
            anchorClass="sortMenuItem"/>
        </th>
        <th nowrap>
          <framework:sortColumnHeader
            title="emxTeamCentral.Common.Description"
            sortKey="Description"
            sortType="string"
            anchorClass="sortMenuItem"/>
        </th>
      </tr>
      
      <%
 		 String sQueryLimit = emxGetParameter(request,"QueryLimit");
 		int iLimit = new Integer(sQueryLimit).intValue();
  		int i=0;
  		
  		if(constructedList.size()>iLimit){
  		String header = i18nNow.getI18nString("emxFramework.MessageHeader.Notice","emxFrameworkStringResource",languageStr);
        StringBuffer sMessage = new StringBuffer(64);
        sMessage.append(i18nNow.getI18nString("emxTeamCentral.FileSearch.MaxLimitWarning", "emxTeamCentralStringResource",languageStr));
        sMessage.append(" ");
        sMessage.append(iLimit);
        sMessage.append(" ");
        sMessage.append(i18nNow.getI18nString("emxTeamCentral.FileSearch.MaxLimitReached", "emxTeamCentralStringResource",languageStr));
	  %>
	  	<script language = "JavaScript">
   			alert("<%=header%>"+':\n\n'+"<%=sMessage.toString()%>");
 		 </script>
	  <%
  		}
	  %>
    <framework:mapListItr mapList="<%=constructedList%>" mapName="templateMap" >
    <%
    
    	
    	if( i<iLimit){
    		
      String sLocked          = (String)templateMap.get("Lock");
      String sObjName         = (String)templateMap.get("Name");
      String sWorkspaceName   = (String)templateMap.get("WSName");
      String sFolderName      = (String)templateMap.get("WSVaultName");
      String sVersion         = (String)templateMap.get("Version");
      String sDesc            = (String)templateMap.get("Description");
      String docId            = (String)templateMap.get("Id");
      String inRoute          = (String)templateMap.get("InRoute");
    %>
    <tr class='<framework:swap id="1"/>'>
<%
   if(inRoute != null && inRoute.equals("true")) {
          String sTip = i18nNow.getI18nString("emxTeamCentral.ContentSummary.DocumentInRoute","emxTeamCentralStringResource",sLanguage);
%>
          <td align="center" ><img src="images/iconLockedRoute.gif" alt="<%=sTip%>"/></td>
<%
         } else  if (sLocked != null && sLocked.equals("TRUE")) {
%>
           <td align="center" ><img src="images/iconLocked.gif" alt="<emxUtil:i18n localize='i18nId'>emxTeamCentral.AddContentSearchResult.Locked</emxUtil:i18n>"/></td>
<%
         } else {
%>
         <td>&nbsp;&nbsp;</td>
<%
       }
%>
       <!-- //XSSOK -->
       <td><a href="javascript:loadTree('<%=docId%>','<%=treeMenu%>')"><%=sObjName%></td>
      <td>&nbsp;<%=sWorkspaceName%></td>
      <td>&nbsp;<%=sFolderName%></td>
      <td>&nbsp;<%=sVersion%></td>
      <td>&nbsp;<%=sDesc%></td>
    </tr>


<% i++;} %>
    </framework:mapListItr>

</table>

 <%
}else if(ComboType != null && Framework.getPropertyValue( session, "type_Package").equals(ComboType) && isSourcingInstalled) {
 %>
<!-- //XSSOK -->
 <framework:sortInit defaultSortKey="<%= rts.SELECT_NAME %>" defaultSortType="string" mapList="<%=constructedList%>" resourceBundle="emxTeamCentralStringResource" ascendText="emxTeamCentral.Common.SortAscending" descendText="emxTeamCentral.Common.SortDescending" params = "<%=sParameter%>"/>

  <table class="list">
    <tr>
      <th>&nbsp;</th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.Common.Name"
          sortKey="<%=rts.SELECT_NAME %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap"><!-- //XSSOK -->
        <framework:sortColumnHeader title="emxTeamCentral.Common.Workspace" sortKey="<%=selWorkspace%>" sortType="string" anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap"><!-- //XSSOK -->
        <framework:sortColumnHeader title="emxTeamCentral.PackageSearch.Folder" sortKey="<%= selWorkspaceFolder %>" sortType="string" anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
        title="emxTeamCentral.Common.State"
        sortKey="<%= rts.SELECT_CURRENT %>"
        sortType="string"
        anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
        title="emxTeamCentral.PacakageSearch.DateOriginated"
        sortKey="<%= rts.SELECT_ORIGINATED %>"
        sortType="string"
        anchorClass="sortMenuItem" />
      </th>
    </tr>

   <framework:mapListItr mapList="<%= constructedList %>" mapName="map">
      <tr class='<framework:swap id="1"/>'>
<%
        String sDocId = (String)map.get(rts.SELECT_ID);
        String  sDocName = (String)map.get(rts.SELECT_NAME);
        String  sDocState = (String)map.get(rts.SELECT_CURRENT);
        String boolRouted  = (String)map.get("inRoute");
        String sLocked     = (String)map.get(rts.SELECT_LOCKED);
        if (boolRouted != null && boolRouted.equals("true")) {
          String sTip = i18nNow.getI18nString("emxTeamCentral.ContentSummary.DocumentInRoute","emxTeamCentralStringResource",sLanguage);
%>
        <td align="center" ><img src="images/iconLockedRoute.gif" alt="<%=sTip%>"/></td>
<%
         } else  if (sLocked != null && sLocked.equals("TRUE")) {
%>
           <td align="center" ><img src="images/iconLocked.gif" alt="<emxUtil:i18n localize='i18nId'>emxTeamCentral.AddContentSearchResult.Locked</emxUtil:i18n>"/></td>
<%
         } else {
%>
         <td>&nbsp;&nbsp;</td>
<%
        }
%>
        <!-- //XSSOK -->
        <td><a href="javascript:loadTree('<%=XSSUtil.encodeForURL(context,sDocId)%>','<%=treeMenu%>')"><%=XSSUtil.encodeForURL(context,sDocName)%></a></td>
        <!-- //XSSOK -->
		<td>&nbsp;<%= (map.get(selWorkspace)!=null)?(XSSUtil.encodeForHTML(context,(map.get(selWorkspace)).toString())):"" %></td>
        <!-- //XSSOK -->
		<td>&nbsp;<%= (map.get(selWorkspaceFolder)!=null)?(XSSUtil.encodeForHTML(context,map.get(selWorkspaceFolder).toString())):"" %></td>
        <!-- //XSSOK -->
		<td>&nbsp;<%=(XSSUtil.encodeForHTML(context, sDocState)) %></td>
        <!-- //XSSOK -->
		<td><emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTML(context, (String)session.getValue("timeZone"))%>' format='<%=DateFrm %>' ><%= (XSSUtil.encodeForHTML(context,map.get(rts.SELECT_ORIGINATED).toString())) %></emxUtil:lzDate></td>
        </tr>
    </framework:mapListItr>
  </table>

<%
}else if(ComboType != null && Framework.getPropertyValue( session, "type_RequestToSupplier").equals(ComboType) && isSourcingInstalled ){

            String selName            = rts.SELECT_NAME;
            String selId              = rts.SELECT_ID;
            String selState           = rts.SELECT_CURRENT;
            String selDesc            = rts.SELECT_DESCRIPTION;
            String selRev             = rts.SELECT_REVISION;
            String selworkspace         = "to[" + rts.RELATIONSHIP_VAULTED_DOCUMENTS + "].from.to[" + rts.RELATIONSHIP_WORKSPACE_VAULTS + "].from.name";


%><!-- //XSSOK -->
<framework:sortInit
    defaultSortKey="<%= rts.SELECT_NAME %>"
    defaultSortType="string"
    mapList="<%= constructedList %>"
    resourceBundle="emxTeamCentralStringResource"
    ascendText="emxTeamCentral.Common.SortAscending"
    descendText="emxTeamCentral.Common.SortDescending"
    params = "<%=sParameter%>"/>

  <table class="list">
    <tr>
      <th>&nbsp;</th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.Common.Name"
          sortKey="<%= rts.SELECT_NAME %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.Common.Round"
          sortKey="<%= rts.SELECT_REVISION %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.Common.State"
          sortKey="<%= rts.SELECT_CURRENT %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.Common.Owner"
          sortKey="null"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.RFQSearch.QuoteRequestedByDate"
          sortKey="<% =clsRTS.getField(sRequestedDate).get(objRts)%>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.RFQSearch.ResponseStatus"
          sortKey="null"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.Common.Package"
          sortKey="<% =clsRTS.getField(sPackageName).get(objRts)%>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap"><!-- //XSSOK -->
        <framework:sortColumnHeader
          title="emxTeamCentral.Common.Workspace"
          sortKey="<%=selworkspace%>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
    </tr>
  <framework:mapListItr mapList="<%= constructedList %>" mapName="map">
    <tr class='<framework:swap id="1"/>'>
<%
        String sDocId      = (String)map.get(selId);
        String boolRouted  = (String)map.get("InRoute");
        String sLocked     = (String)map.get(rts.SELECT_LOCKED);

        MapList totalresultList = null;
        if (boolRouted !=null && ("true").equals(boolRouted)) {
          String sTip = i18nNow.getI18nString("emxTeamCentral.ContentSummary.DocumentInRoute","emxTeamCentralStringResource",sLanguage);
%>
        <td align="center" ><img src="images/iconLockedRoute.gif" alt="<%=sTip%>"/></td>
<%
         } else  if (sLocked != null && sLocked.equals("TRUE")) {
%>
           <td align="center" ><img src="images/iconLocked.gif" alt="<emxUtil:i18n localize='i18nId'>emxTeamCentral.AddContentSearchResult.Locked</emxUtil:i18n>"/></td>
<%
         } else {
%>
         <td>&nbsp;&nbsp;</td>
<%
        }
%>
        <!-- //XSSOK -->
        <td><a href="javascript:loadTree('<%=XSSUtil.encodeForURL(context,(map.get(selId)).toString())%>','<%=treeMenu%>')"><%=XSSUtil.encodeForURL(context, (map.get(selName)).toString()) %></a></td>
        <td><%=XSSUtil.encodeForHTML(context,(map.get(selRev)).toString()) %>&nbsp;</td>
        <td><%= XSSUtil.encodeForHTML(context,map.get(selState).toString()) %>&nbsp;</td>
        <td><%= XSSUtil.encodeForHTML(context,map.get(rts.SELECT_OWNER).toString()) %>&nbsp;</td>
        <td><%= XSSUtil.encodeForHTML(context,(map.get(clsRTS.getField("SELECT_QUOTE_REQUESTED_BY_DATE").get(objRts))).toString()) %>&nbsp;</td>
        <td>
<%
        // Use try catch for String or StringList return handling
        StringList strList = new StringList();
        try
        {
          strList = (matrix.util.StringList)map.get(clsRTS.getField("SELECT_RTS_QUOTATION_CURRENT").get(objRts));
        }
        catch (Exception ex )
        {
          strList.addElement((String)map.get(clsRTS.getField("SELECT_RTS_QUOTATION_CURRENT").get(objRts)));
        }

%>
          <framework:stringCount list="<%= (java.util.List) strList%>"
            strings="<%= new String[] {person.STATE_RTS_QUOTATION_RETURNED,person.STATE_RTS_QUOTATION_CLOSED} %>" />
        &nbsp;
        </td>
        <!-- //XSSOK -->
		<td><%= (map.get(clsRTS.getField("SELECT_PACKAGE_NAME").get(objRts))!=null)?XSSUtil.encodeForHTML(context, map.get(clsRTS.getField("SELECT_PACKAGE_NAME").get(objRts)).toString()):"" %>&nbsp;</td>
        <!-- //XSSOK -->
		<td><%= (map.get(selworkspace)!=null)?XSSUtil.encodeForHTML(context,map.get(selworkspace).toString()):"" %>&nbsp;</td>
    </tr>
  </framework:mapListItr>
</table>
<%
}else if(ComboType != null && Framework.getPropertyValue( session, "type_RTSQuotation").equals(ComboType) && isSourcingInstalled ){
  //RTSQuotation rts1         = (RTSQuotation)   DomainObject.newInstance(context, DomainConstants.TYPE_RTS_QUOTATION, DomainConstants.SOURCING);
%>
<!-- //XSSOK -->
<framework:sortInit defaultSortKey="<%= person.SELECT_NAME%>" defaultSortType="string" mapList="<%=constructedList%>" resourceBundle="emxTeamCentralStringResource" ascendText="Sort Ascending" descendText="Sort Descending" params = "<%=sParameter%>"/>

  <table class="list">
    <tr>
      <th>&nbsp;</th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.Common.Quotation"
          sortKey="<%= person.SELECT_NAME %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.Common.State"
          sortKey="<%= person.SELECT_CURRENT %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.QuotationSearch.BuyerCompany"
          sortKey="<%= person.SELECT_RTS_QUOTATION_BUYER_COMPANY_NAME %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.QuotationSearch.RFQ"
          sortKey="<%= person.SELECT_QUOTATION_RTS_NAME %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
      <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.QuotationSearch.OriginatedDate"
          sortKey="<%= person.SELECT_ORIGINATED %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
       <th nowrap="nowrap"><!-- //XSSOK -->
        <framework:sortColumnHeader title="emxTeamCentral.QuotationSearch.CompletionDate" sortKey="<%= (String)clsRTQ.getField(\"SELECT_ACTUAL_COMPLETION\").get(objRtq) %>" sortType="string" anchorClass="sortMenuItem" />
      </th>
       <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.Common.Owner"
          sortKey="<%= person.SELECT_OWNER %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
       <th nowrap="nowrap">
        <framework:sortColumnHeader
          title="emxTeamCentral.Common.Package"
          sortKey="<%= person.SELECT_QUOTATION_RTS_PACKAGE_NAME %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
     </tr>

    <framework:mapListItr mapList="<%=constructedList%>" mapName="map">

      <tr class='<framework:swap id="1"/>'>
<%

        String sDocId = (String)map.get(person.SELECT_ID);
        String boolRouted  =(String)map.get("InRoute"); //isDocumentInARoute(context, session,sDocId);
        String sLocked     = (String)map.get(rts.SELECT_LOCKED);
        if (boolRouted != null && boolRouted.equals("true")) {
          String sTip = i18nNow.getI18nString("emxTeamCentral.ContentSummary.DocumentInRoute","emxTeamCentralStringResource",sLanguage);
%>
        <td align="center" ><img src="images/iconLockedRoute.gif" alt="<%=sTip%>" /></td>
<%
         } else  if (sLocked != null && sLocked.equals("TRUE")) {
%>
           <td align="center" ><img src="images/iconLocked.gif" alt="<emxUtil:i18n localize='i18nId'>emxTeamCentral.AddContentSearchResult.Locked</emxUtil:i18n>"/></td>
<%
         } else {
%>
         <td>&nbsp;&nbsp;</td>
<%
        }
%>
        <!-- //XSSOK -->
        <td><a href="javascript:loadTree('<%=XSSUtil.encodeForURL(context, map.get(person.SELECT_ID).toString())%>','<%=treeMenu%>')"><emxUtil:i18n localize="i18nId">emxTeamCentral.Common.Quotation</emxUtil:i18n></a></td>
        <td><%=XSSUtil.encodeForHTML(context, map.get(person.SELECT_CURRENT).toString()) %></td>
        <td><%= XSSUtil.encodeForHTML(context,map.get(person.SELECT_RTS_QUOTATION_BUYER_COMPANY_NAME).toString()) %></td>
        <!-- //XSSOK -->
		<td><a href="javascript:loadTree('<%=map.get(person.SELECT_QUOTATION_RTS_ID)%>' , '<%=treeMenu%>')"><%= XSSUtil.encodeForHTML(context,map.get(person.SELECT_QUOTATION_RTS_NAME).toString())  %></a></td>
        <td>
          <emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, (String)session.getValue("timeZone"))%>' format='<%=DateFrm %>' ><%= XSSUtil.encodeForHTML(context,map.get(person.SELECT_ORIGINATED).toString()) %></emxUtil:lzDate>
          &nbsp;
        </td>
        <td><!-- //XSSOK -->
          <emxUtil:lzDate localize="i18nId" tz='<%=XSSUtil.encodeForHTMLAttribute(context, (String)session.getValue("timeZone"))%>' format='<%=DateFrm %>' ><%= map.get(clsRTQ.getField("SELECT_ACTUAL_COMPLETION").get(objRtq)) %></emxUtil:lzDate>
          &nbsp;
        </td>
        <td><%= XSSUtil.encodeForHTML(context,map.get(person.SELECT_OWNER).toString()) %>&nbsp;</td>
        <!-- //XSSOK -->
        <td><a href="javascript:loadTree('<%=XSSUtil.encodeForURL(context,map.get(person.SELECT_QUOTATION_RTS_PACKAGE_ID).toString())%>' , '<%=treeMenu%>')"><%=XSSUtil.encodeForURL(context, map.get(person.SELECT_QUOTATION_RTS_PACKAGE_NAME).toString()) %></a>&nbsp;</td>
      </tr>
    </framework:mapListItr>
  </table>
<%
}else{
  Organization companyObj = new Organization();

  String sortNameType          = companyObj.SELECT_NAME;
  String sortPhoneType         = companyObj.SELECT_ORGANIZATION_PHONE_NUMBER;
  String sortFaxType           = companyObj.SELECT_ORGANIZATION_FAX_NUMBER;
  String sLink1                = "";
  String sImage                = "";
  String tempTreeUrl           = "";
  String treeUrl               = "";
  String sDispPersonName       = "";
  String selWorkPhoneNumber    = "";
  String selFaxNumber          = "";
  String selWebSite            ="";

  if (ComboType != null && Framework.getPropertyValue( session, "type_Organization").equals(ComboType) || Framework.getPropertyValue( session, "type_Company").equals(ComboType)){
      sImage = "images/iconSmallCompany.gif";

  }else if (ComboType != null && Framework.getPropertyValue( session, "type_BusinessUnit").equals(ComboType)){
     sImage                = "images/iconSmallBusinessUnit.gif";
  }else if (ComboType != null && Framework.getPropertyValue( session, "type_Person").equals(ComboType)){

      sLink1                 = "Person";
      sImage                = "images/iconSmallPerson.gif";
      sortNameType          = person.SELECT_LAST_NAME;
      sortPhoneType         = person.SELECT_WORK_PHONE_NUMBER;
      sortFaxType           = person.SELECT_FAX_NUMBER;
  }

%>
<table class="list"><!-- //XSSOK -->
  <framework:sortInit defaultSortKey="<%=sortNameType%>" defaultSortType="string" mapList="<%=constructedList%>" resourceBundle="emxTeamCentralStringResource" ascendText="emxTeamCentral.Common.SortAscending" descendText="emxTeamCentral.Common.SortDescending" params = "<%=sParameter%>"  />
   <tr>
    <th nowrap><!-- //XSSOK -->
      <framework:sortColumnHeader title="emxTeamCentral.Common.Name" sortKey="<%=sortNameType%>" sortType="string" anchorClass="sortMenuItem"/>
    </th>
    <th nowrap><!-- //XSSOK -->
      <framework:sortColumnHeader title="emxTeamCentral.AdminSearch.PhoneNumber" sortKey="<%=sortPhoneType%>" sortType="string" anchorClass="sortMenuItem"/>
    </th>
    <th nowrap><!-- //XSSOK -->
      <framework:sortColumnHeader title="emxTeamCentral.AdminSearch.FaxNumber" sortKey="<%=sortFaxType%>" sortType="string" anchorClass="sortMenuItem"/>
    </th>
    <th nowrap>
      <framework:sortColumnHeader
        title="emxTeamCentral.AdminSearch.WebSite"
        sortKey="<%=companyObj.SELECT_WEB_SITE%>"
        sortType="string"
        anchorClass="sortMenuItem"/>
    </th>
  </tr>

<framework:mapListItr mapList="<%=constructedList%>" mapName="templateMap">
  <tr class='<framework:swap id ="1" />'>
<%
    String sObjectId        = (String)templateMap.get(companyObj.SELECT_ID);
    selWebSite              = (String)templateMap.get(person.SELECT_WEB_SITE);
    treeUrl                 = "javascript:loadTree('" + XSSUtil.encodeForURL(context,sObjectId) + "','" + treeMenu + "')";

    if(sLink1.equals("Person") ) {
      sDispPersonName         = (String)templateMap.get(person.SELECT_LAST_NAME) + ", " + (String)templateMap.get(person.SELECT_FIRST_NAME);
      selWorkPhoneNumber      = (String)templateMap.get(person.SELECT_WORK_PHONE_NUMBER);
      selFaxNumber            = (String)templateMap.get(person.SELECT_FAX_NUMBER);
    } else {
      sDispPersonName         = (String)templateMap.get(companyObj.SELECT_NAME);
      selWorkPhoneNumber      = (String)templateMap.get(companyObj.SELECT_ORGANIZATION_PHONE_NUMBER);
      selFaxNumber            = (String)templateMap.get(companyObj.SELECT_ORGANIZATION_FAX_NUMBER);
    }
   if(!isHostRep) {
      if(ComboType.equals(rts.TYPE_COMPANY) || ComboType.equals(rts.TYPE_ORGANIZATION)) {
        if(partnersList.contains(sObjectId) || myCompanyId.equals(sObjectId)){
          showURL = true;
          }else{
            showURL = false;
          }
        } else if(ComboType.equals(rts.TYPE_BUSINESS_UNIT)) {

        if( partnersList.contains(sObjectId) || (myCompanyId.equals(sObjectId)) || (sBUList.contains(sObjectId))){
          showURL = true;
        }else{
            showURL = false;
        }
       }
    } else {
        showURL = true;
    }

if (showURL){
	//XSSOK
%>
    <!-- //XSSOK -->
	<td><a href="<%=treeUrl%>"><img src="<%=sImage%>" name="imgGeneric" id="imgGeneric" border="0" alt="" /> <%=XSSUtil.encodeForURL(context,sDispPersonName) %></a></td>

<%
}else{
%> <!-- //XSSOK -->
    <td><img src="<%=sImage%>" name="imgGeneric" id="imgGeneric" border="0" alt="" /> <%=XSSUtil.encodeForHTML(context,sDispPersonName) %></td>

<%
}
%>

    <td><%= XSSUtil.encodeForHTML(context,selWorkPhoneNumber) %>&nbsp;</td>
    <td><%= XSSUtil.encodeForHTML(context,selFaxNumber) %>&nbsp;</td>
<%
if(selWebSite.startsWith("http://")||selWebSite.startsWith("https://")){
%>
    <td><a href="<%= XSSUtil.encodeForURL(context,selWebSite )%>" target="_blank">
        <%= XSSUtil.encodeForHTML(context,selWebSite) %>
      </a>&nbsp;
    </td>
<%
  }else{
%>
    <td><a href="http://<%=XSSUtil.encodeForURL(context, selWebSite) %>" target="_blank">
        <%=XSSUtil.encodeForHTML(context, selWebSite) %>
      </a>&nbsp;
    </td>
<%
  }
%>
  </tr>
</framework:mapListItr>
</table>


<%
}
 %>


<table class="list">
<%

    if (constructedList.size() == 0) {
      String noresults = i18nNow.getI18nString("emxTeamCentral.FindLike.Common.NoResultsFound","emxTeamCentralStringResource",languageStr);
%>

      <tr class="even" ><td colspan="6" align="center" ><%=noresults%></td></tr>

<%
    }
%>
  </table>
<%
  } catch (MatrixException e) {
    session.putValue("error.message", e.toString());

%>
    <script language="Javascript" >
<%
  if(!sLink.equals("")) {
%>
     parent.window.location.href="emxTeamAdminSearchDialogFS.jsp?page=<%=XSSUtil.encodeForJavaScript(context,sLink)%>";
<%
  } else  {
%>
  parent.window.location.href="emxTeamSearchContentDialogFS.jsp?searchType=<%=XSSUtil.encodeForJavaScript(context,sSearchType)%>";
<%
  }
%>

    </script>
<%
  }
%>
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>




<%!
  //
  //Gets required Maplist for the Document type
  //
  public static MapList getDocumentMapList(matrix.db.Context context, HttpSession session , MapList mapList) {

        MapList finalMapList = new MapList();

   try{
      DomainObject domObj = null;
      Iterator maplistItr = mapList.iterator();

      String sTypeProject             = Framework.getPropertyValue(session,"type_Project");
      //String sTypeProjectMember       = Framework.getPropertyValue(session,"type_ProjectMember");
      String relWorkspaceVaults       = Framework.getPropertyValue(session, "relationship_ProjectVaults");
      String sProjectVaultType        = Framework.getPropertyValue(session, "type_ProjectVault");
      String sRelObjectRoute          = Framework.getPropertyValue(session,"relationship_ObjectRoute");
      String sTypeRoute               = Framework.getPropertyValue(session, "type_Route");

      String sTitleAttr               = "attribute["+DomainObject.ATTRIBUTE_TITLE+"]";
      String selRouteId       = "from["+sRelObjectRoute+"].to.id";


      //query selects
      StringList objectSelects = new StringList();
      Pattern typePattern;
      Pattern relPattern;
      // type and rel patterns to include in the final resultset
      Pattern includeTypePattern;
      Pattern includeRelPattern;

       objectSelects.add(DomainObject.SELECT_ID);
        objectSelects.add(DomainObject.SELECT_TYPE);
        objectSelects.add(DomainObject.SELECT_NAME);

        typePattern = new Pattern(sProjectVaultType);
        typePattern.addPattern(sTypeProject);
        //typePattern.addPattern(sTypeRoute);
        relPattern = new Pattern(relWorkspaceVaults);
        relPattern.addPattern(DomainObject.RELATIONSHIP_VAULTED_OBJECTS);
        relPattern.addPattern(DomainObject.RELATIONSHIP_SUBVAULTS);
        //relPattern.addPattern(sRelObjectRoute);
        //RELATIONSHIP_VAULTED_DOCUMENTS

        includeTypePattern = new Pattern(sTypeProject);
        includeRelPattern = new Pattern(sProjectVaultType);

    while(maplistItr.hasNext()){
          Map tempMap    =  (Map)maplistItr.next();
          String Id      =  (String)tempMap.get(DomainObject.SELECT_ID);
          String Title   =  (String)tempMap.get(sTitleAttr);
          String docName =  (String)tempMap.get(DomainObject.SELECT_NAME);
          String desc    =  (String)tempMap.get(DomainObject.SELECT_DESCRIPTION);
          String state   =  (String)tempMap.get(DomainObject.SELECT_CURRENT);
          String rev     =  (String)tempMap.get(DomainObject.SELECT_REVISION);
          String lock    =  (String)tempMap.get(DomainObject.SELECT_LOCKED);



          domObj = DomainObject.newInstance(context, Id);
          MapList wsMapList = domObj.getRelatedObjects(context,
                                                        relPattern.getPattern(),  //String relPattern
                                                        typePattern.getPattern(), //String typePattern
                                                        objectSelects,            //StringList objectSelects,
                                                        null,                     //StringList relationshipSelects,
                                                        true,                     //boolean getTo,
                                                        false,                     //boolean getFrom,
                                                        (short)0,                 //short recurseToLevel,
                                                        "",                       //String objectWhere,
                                                        "",                       //String relationshipWhere,
                                                        null,                     //Pattern includeType,
                                                        null,                     //Pattern includeRelationship,
                                                        null);                    //Map includeMap




          String wsName       = "";
          String wsVaultName  = "";
          StringList idList   = new StringList();
          String inRoute     = "false";
          HashMap finalMap = new HashMap();

          StringList objectSelects1 = new StringList();
                    objectSelects1.add(selRouteId);
                    Map routeInfo = domObj.getInfo(context,objectSelects1);
                    String routeId = (String)routeInfo.get(selRouteId);

          if (routeId != null && !routeId.equals("")){
            inRoute = "true";
          }

          Iterator wsMapListItr = wsMapList.iterator();
		  //Added for IR-071025V6R2012 starts
		  int i=0;
		  //Addition for IR-071025V6R2012 ends
          while(wsMapListItr.hasNext()){
            Map tempMap1      = (Map)wsMapListItr.next();
            String tempType  = (String)tempMap1.get(DomainObject.SELECT_TYPE);
            String tempName  = (String)tempMap1.get(DomainObject.SELECT_NAME);
            String ObID      = (String)tempMap1.get(DomainObject.SELECT_ID);
               if (!idList.contains(ObID)){
                idList.addElement(ObID);
                  if (tempType != null && tempType.equals(DomainConstants.TYPE_WORKSPACE)){
					  //Modified for IR-071025V6R2012 
                    wsName = wsName + tempName + (i==wsMapList.size()-1 ? "" : ";");
                   }else if (tempType != null && tempType.equals("Workspace Vault")){
                     String isConnected = (String)tempMap1.get("level");
                     if (isConnected != null && isConnected.equals("1")){
						 //Modified for IR-071025V6R2012
                      wsVaultName  = wsVaultName + tempName + (i==wsMapList.size()-2 ? "" : ";");
                    }

                  }
              }
               i++;
          }
        if (wsVaultName !=null && !"".equals(wsVaultName) && !"null".equals(wsVaultName)){
         finalMap.put("Title",Title);
         finalMap.put("Name",docName);
         finalMap.put("WSName"  ,wsName);
         finalMap.put("WSVaultName" , wsVaultName);
         finalMap.put("Version" , rev);
         finalMap.put("Description" , desc);
         finalMap.put("Id" , Id);
         finalMap.put("Lock" , lock);
         finalMap.put("InRoute" ,inRoute);
         finalMapList.add(finalMap);
       }
      }
    }catch(Exception e){

    }
   return finalMapList;
  }
%>

<%!
  //
  //Gets required Maplist for the Package type
  //
  public static MapList getPackageMapList(matrix.db.Context context, HttpSession session , MapList mapList) {
    MapList finalMapList = new MapList();

    try{
          DomainObject domObj = null;
          Iterator maplistItr = mapList.iterator();
          String sRelObjectRoute          = Framework.getPropertyValue(session,"relationship_ObjectRoute");
          String selWorkspaceFolder       = "to[" + DomainObject.RELATIONSHIP_VAULTED_DOCUMENTS + "].from.name";
          String selWorkspace             = "to[" + DomainObject.RELATIONSHIP_VAULTED_DOCUMENTS + "].from.to[" + DomainObject.RELATIONSHIP_WORKSPACE_VAULTS + "].from.name";
          String selRouteId               = "from[" + sRelObjectRoute + "].to.id";
          String sTypeProject             = Framework.getPropertyValue(session,"type_Project");
          String sProjectVaultType        = Framework.getPropertyValue(session, "type_ProjectVault");
          String sTitleAttr               = "attribute["+DomainObject.ATTRIBUTE_TITLE+"]";
		  String seletCompanyPackage = "to[" + DomainObject.RELATIONSHIP_COMPANY_PACKAGE + "]";

          //query selects
          StringList objectSelects = new StringList();
          Pattern typePattern;
          Pattern relPattern;
          // type and rel patterns to include in the final resultset
          Pattern includeTypePattern;
          Pattern includeRelPattern;

        while(maplistItr.hasNext())
            {
              Map tempMap    =  (Map)maplistItr.next();
              String Id      =  (String)tempMap.get(DomainObject.SELECT_ID);
              String Title   =  (String)tempMap.get(sTitleAttr);
              String docName =  (String)tempMap.get(DomainObject.SELECT_NAME);
              String desc    =  (String)tempMap.get(DomainObject.SELECT_DESCRIPTION);
              String state   =  (String)tempMap.get(DomainObject.SELECT_CURRENT);
              String rev     =  (String)tempMap.get(DomainObject.SELECT_REVISION);
              String lock    =  (String)tempMap.get(DomainObject.SELECT_LOCKED);

                domObj = DomainObject.newInstance(context, Id);
                objectSelects.add(domObj.SELECT_ID);
                objectSelects.add(domObj.SELECT_TYPE);
                objectSelects.add(domObj.SELECT_NAME);
                objectSelects.add(domObj.SELECT_CURRENT);
                objectSelects.add(domObj.SELECT_ORIGINATED);
                objectSelects.add(selWorkspaceFolder);
                objectSelects.add(selWorkspace);
                objectSelects.add(selRouteId);
		        objectSelects.add(seletCompanyPackage);
                typePattern = new Pattern(sProjectVaultType);
                typePattern.addPattern(sTypeProject);

             Map wsList = domObj.getInfo(context,objectSelects);

             String inRoute =  (String)wsList.get(selRouteId);
             try{
             String foldname = wsList.get(selWorkspaceFolder).toString();
             foldname = foldname.substring(1,foldname.length()-1);
             wsList.remove(selWorkspaceFolder);
             wsList.put(selWorkspaceFolder , foldname);
              }catch(Exception e){

              }

            if (inRoute != null && !inRoute.equals("") ){
               wsList.put("inRoute" , "true");
             }
              String companyPackage = (String)wsList.get(seletCompanyPackage);
              if( "false".equalsIgnoreCase(companyPackage))
              {
              		finalMapList.add(wsList);
			  }
             }

    }catch(Exception e){

    }

    return finalMapList;
  }

%>

<%!
  //
  //Gets required Maplist for the RFQ type
  //
  public static MapList getRFQMapList(matrix.db.Context context, HttpSession session , MapList mapList) {

    MapList finalMapList = new MapList();
    try{


        boolean isSourcingInstalled = false;

        Class clsRTS=null;
        try{
          clsRTS = Class.forName("com.matrixone.apps.sourcing.RequestToSupplier");
          isSourcingInstalled = true;

        }catch (Exception ex){

        }

        if(isSourcingInstalled){

          Object objRts = clsRTS.newInstance();
          Method getInfo = null;
          Method setId=null;

          Method[] methods = clsRTS.getMethods();
          for (int i=0; i<methods.length; i++){
            if(methods[i].getName().equals("setId")){
              setId = methods[i];
            }
          }

          Class[] clsArg = new Class[2];

          clsArg[0]  = Context.class;
          clsArg[1]  = StringList.class;
          getInfo = clsRTS.getMethod("getInfo",clsArg);


          //RequestToSupplier rts = (RequestToSupplier) DomainObject.newInstance(context, DomainConstants.TYPE_REQUEST_TO_SUPPLIER, DomainConstants.SOURCING);

          Iterator maplistItr = mapList.iterator();
          String sRelObjectRoute          = Framework.getPropertyValue(session,"relationship_ObjectRoute");
          String selWorkspaceFolder       = "to[" + DomainObject.RELATIONSHIP_VAULTED_DOCUMENTS + "].from.name";
          String selworkspace             = "to[" + DomainObject.RELATIONSHIP_VAULTED_DOCUMENTS + "].from.to[" + DomainObject.RELATIONSHIP_WORKSPACE_VAULTS + "].from.name";
          String selRouteId               = "from[" + sRelObjectRoute + "].to.id";
          String sTitleAttr               = "attribute["+DomainObject.ATTRIBUTE_TITLE+"]";
		  String seletCompanyRFQ = "to[" + DomainObject.RELATIONSHIP_COMPANY_RFQ + "]";
         //query selects
          StringList objectSelects = new StringList();
          Pattern typePattern;
          Pattern relPattern;
          // type and rel patterns to include in the final resultset
          Pattern includeTypePattern;
          Pattern includeRelPattern;

          objectSelects.add((String)clsRTS.getField("SELECT_ID").get(objRts));
          objectSelects.add((String)clsRTS.getField("SELECT_TYPE").get(objRts));
          objectSelects.add((String)clsRTS.getField("SELECT_NAME").get(objRts));
          objectSelects.add((String)clsRTS.getField("SELECT_CURRENT").get(objRts));
          objectSelects.add((String)clsRTS.getField("SELECT_ORIGINATED").get(objRts));
          objectSelects.add((String)clsRTS.getField("SELECT_PACKAGE_NAME").get(objRts));
          objectSelects.add((String)clsRTS.getField("SELECT_PACKAGE_ID").get(objRts));
          objectSelects.add((String)clsRTS.getField("SELECT_QUOTE_REQUESTED_BY_DATE").get(objRts));
          objectSelects.add((String)clsRTS.getField("SELECT_QUOTATION_RESPONSE_REVIEW").get(objRts));
          objectSelects.add((String)clsRTS.getField("SELECT_OWNER").get(objRts));
          objectSelects.add(selworkspace);
          objectSelects.add(selRouteId);
          objectSelects.add((String)clsRTS.getField("SELECT_REVISION").get(objRts));
          objectSelects.add(seletCompanyRFQ);

          while(maplistItr.hasNext()){
              Map tempMap    =  (Map)maplistItr.next();
              String Id      =  (String)tempMap.get(DomainObject.SELECT_ID);
              String Title   =  (String)tempMap.get(sTitleAttr);
              String docName =  (String)tempMap.get(DomainObject.SELECT_NAME);
              String desc    =  (String)tempMap.get(DomainObject.SELECT_DESCRIPTION);
              String state   =  (String)tempMap.get(DomainObject.SELECT_CURRENT);
              String rev     =  (String)tempMap.get(DomainObject.SELECT_REVISION);
              String lock    =  (String)tempMap.get(DomainObject.SELECT_LOCKED);
              //rts.setId(Id);
              setId.invoke(objRts,new Object[] {Id});

              //Map wsList= rts.getInfo(context,objectSelects);

              Object[] arguments = new Object[2];
              arguments[0]=context;
              arguments[1]=objectSelects;

              Map wsList= (Map)getInfo.invoke(objRts,arguments);

              String inRoute =  (String)wsList.get(selRouteId);

              if (inRoute != null && !inRoute.equals("") ){
                wsList.put("inRoute" , "true");
              }
              String companyRFQ = (String)wsList.get(seletCompanyRFQ);
              if( "false".equalsIgnoreCase(companyRFQ))
              {
              		finalMapList.add(wsList);
			  }
          }
        }

    }catch(Exception e){
        System.out.println("Exception : " + e.getMessage());
    }
    return finalMapList;
  }

%>




<%!
  //
  //Gets required Maplist for the Quotation type
  //
  public static MapList getQuotationMapList(matrix.db.Context context, HttpSession session , MapList mapList) {

    MapList finalMapList = new MapList();

    try{
          com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
          DomainObject domObj = null;

          boolean isSourcingInstalled = false;

          Class clsRTQ=null;
          try{
            clsRTQ = Class.forName("com.matrixone.apps.sourcing.RTSQuotation");
            isSourcingInstalled = true;

          }catch (Exception ex){

          }

          Object objRtq = clsRTQ.newInstance();
          //RTSQuotation rts = (RTSQuotation) DomainObject.newInstance(context, DomainConstants.TYPE_RTS_QUOTATION, DomainConstants.SOURCING);

          Iterator maplistItr = mapList.iterator();

          String sRelObjectRoute          = Framework.getPropertyValue(session,"relationship_ObjectRoute");
          String selWorkspaceFolder       = "to[" + DomainObject.RELATIONSHIP_VAULTED_DOCUMENTS + "].from.name";
          String selRouteId               = "from[" + sRelObjectRoute + "].to.id";
          String sTitleAttr               = "attribute["+DomainObject.ATTRIBUTE_TITLE+"]";
		  String seletCompanyRFQ = "to[" + DomainObject.RELATIONSHIP_RTS_QUOTATION + "].from.to["+ DomainObject.RELATIONSHIP_COMPANY_RFQ +"]";

         //query selects
          StringList objectSelects = new StringList();
          Pattern typePattern;
          Pattern relPattern;
          // type and rel patterns to include in the final resultset
          Pattern includeTypePattern;
          Pattern includeRelPattern;

          objectSelects.add(person.SELECT_ID);
          objectSelects.add(person.SELECT_TYPE);
          objectSelects.add(person.SELECT_NAME);
          objectSelects.add(person.SELECT_CURRENT);
          objectSelects.add(person.SELECT_ORIGINATED);
          objectSelects.add(person.SELECT_RTS_QUOTATION_BUYER_COMPANY_NAME);
          objectSelects.add(person.SELECT_QUOTATION_RTS_NAME);
          objectSelects.add(person.SELECT_QUOTATION_RTS_ID);
          objectSelects.add(person.SELECT_QUOTATION_RTS_PACKAGE_NAME);
          objectSelects.add(person.SELECT_QUOTATION_RTS_PACKAGE_ID);
          objectSelects.add(person.SELECT_OWNER);
          objectSelects.add((String)clsRTQ.getField("SELECT_ACTUAL_COMPLETION").get(objRtq));
          objectSelects.add(person.SELECT_LOCKED);
          objectSelects.add(selRouteId);
          objectSelects.add(seletCompanyRFQ);

          while(maplistItr.hasNext()){
            Map tempMap    =  (Map)maplistItr.next();
            String Id      =  (String)tempMap.get(DomainObject.SELECT_ID);
            String Title   =  (String)tempMap.get(sTitleAttr);
            String docName =  (String)tempMap.get(DomainObject.SELECT_NAME);
            String desc    =  (String)tempMap.get(DomainObject.SELECT_DESCRIPTION);
            String state   =  (String)tempMap.get(DomainObject.SELECT_CURRENT);
            String rev     =  (String)tempMap.get(DomainObject.SELECT_REVISION);
            String lock    =  (String)tempMap.get(DomainObject.SELECT_LOCKED);
            domObj         =  DomainObject.newInstance(context, Id);

            Map wsList= domObj.getInfo(context,objectSelects);

              String inRoute =  (String)wsList.get(selRouteId);
              if (inRoute != null && !inRoute.equals("") ){
                   wsList.put("inRoute" , "true");
               }
              String companyRFQ = (String)wsList.get(seletCompanyRFQ);
              if( "false".equalsIgnoreCase(companyRFQ))
              {
              		finalMapList.add(wsList);
			  }
             }

      }catch(Exception e){

     }
       return finalMapList;
  }

%>

<%!
  //
  //Gets required Maplist for the Admin type
  //
  public static MapList getAdminMapList(matrix.db.Context context, HttpSession session , MapList mapList , String type) {

    MapList finalMapList = new MapList();

     try{
         //query selects
         StringList objectSelects = new StringList();
         Iterator maplistItr = mapList.iterator();

        if(type != null &&  Framework.getPropertyValue( session, "type_Person").equals(type)){

            while(maplistItr.hasNext()){
                 Map tempMap    =  (Map)maplistItr.next();
                 String Id      =  (String)tempMap.get(DomainObject.SELECT_ID);

                 com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person) DomainObject.newInstance(context, DomainConstants.TYPE_PERSON, DomainConstants.TEAM);
                 person.setId(Id);

                   objectSelects.add(person.SELECT_ID);
                   objectSelects.add(person.SELECT_CURRENT);
                   objectSelects.add(person.SELECT_LAST_NAME);
                   objectSelects.add(person.SELECT_FIRST_NAME);
                   objectSelects.add(person.SELECT_EMAIL_ADDRESS);
                   objectSelects.add(person.SELECT_WORK_PHONE_NUMBER);
                   objectSelects.add(person.SELECT_WEB_SITE);
                   objectSelects.add(person.SELECT_FAX_NUMBER);
               Map wsList= person.getInfo(context,objectSelects);
               finalMapList.add(wsList);
               person = null;

              }

        }else{
               Organization companyObj = (Organization) DomainObject.newInstance(context, DomainConstants.TYPE_ORGANIZATION, DomainConstants.TEAM);
               while(maplistItr.hasNext()){
                 Map tempMap           =  (Map)maplistItr.next();
                 String Id             =  (String)tempMap.get(DomainObject.SELECT_ID);
                 companyObj.setId(Id);
                   objectSelects.add(companyObj.SELECT_ID);
                   objectSelects.add(companyObj.SELECT_NAME);
                   objectSelects.add(companyObj.SELECT_ORGANIZATION_PHONE_NUMBER);
                   objectSelects.add(companyObj.SELECT_ORGANIZATION_FAX_NUMBER);
                   objectSelects.add(companyObj.SELECT_WEB_SITE);

               Map wsList= companyObj.getInfo(context,objectSelects);

               finalMapList.add(wsList);

               }
        }
     }catch(Exception e){

     }
    return finalMapList;
  }
%>



