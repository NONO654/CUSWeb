<%--  emxEngrFindLikeQuery.jsp   - execute the database query and produces the search result and displays it in the find Reults page.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ include file  = "emxDesignTopInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  Map paramMap = (Map) session.getAttribute("strParams");
  Iterator keyItr = paramMap.keySet().iterator();
  while (keyItr.hasNext()) {
    String name = (String) keyItr.next();
    String value = (String) paramMap.get(name);
   request.setAttribute(name, value);
  }

  String vault = (String)request.getAttribute("Vault");
  String languageStr = request.getHeader("Accept-Language");
  String TypeString  = emxGetParameter(request,"TypeString");
  String ComboType   = emxGetParameter(request,"ComboType");
  String suiteKey    = emxGetParameter(request,"suiteKey");
  String strMultiSelect    = emxGetParameter(request,"multiSelect");

  double clientTZOffset    = (new Double((String)session.getValue("timeZone"))).doubleValue();

  if (suiteKey == null || suiteKey.equals("null") || suiteKey.equals("")) {
    suiteKey = "eServiceSuiteEngineeringCentral";
  }

  //Determine if we should use printer friendly version
  boolean isPrinterFriendly = false;
  String printerFriendly = emxGetParameter(request, "PrinterFriendly");

  if (printerFriendly != null &&
                        !"null".equals(printerFriendly) &&
                                !"".equals(printerFriendly)) {
    isPrinterFriendly = "true".equals(printerFriendly);
  }

  // Check query limit
  String queryLimit = emxGetParameter(request,"queryLimit");
  if (queryLimit == null ||
            queryLimit.equals("null") ||
                    queryLimit.equals("")) {
    queryLimit = "0";
  }
  String pagination = emxGetParameter(request,"pagination");
  Integer qLimit = new Integer(queryLimit);
  short shQueryLimit = (short)qLimit.intValue();


  //to get the business type
  String sBoType             = "";
  Enumeration eNumObj        = null;


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
  String sOr                 = "||";
  String sAnd                = " &&";
  String sEqual              = " == const";
  String sNotEqual           = " != const";
  String sGreaterThan        = " > const";
  String sLessThan           = " < const";
  String sGreaterThanEqual   = " >= const";
  String sLessThanEqual      = " <= const";

  //modified for fix of bug 300647
  String sMatch              = "";
  String CaseMatchOption = JSPUtil.getCentralProperty(application,
                               session,"emxEngineeringCentral","Search.FindLike.CaseMatchOption");
  if (CaseMatchOption.equalsIgnoreCase("true")){
    sMatch         = " ~= const"; //case-sensitive matching for bug #243366
  }else {
    sMatch         = " ~~ "; //case-insensitive mar=tching
  }
  //end of fix

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

  String startDayTime = "12:00:00 AM";
  String endDayTime = "11:59:59 PM";

  String CloseSearchResultsOnNameClick = JSPUtil.getCentralProperty(application,
                               session,"emxFramework","Search.OnSelect.Action");

  if (CloseSearchResultsOnNameClick == null ||
            CloseSearchResultsOnNameClick.equals("null")) {
    CloseSearchResultsOnNameClick = "";
  }
  CloseSearchResultsOnNameClick = CloseSearchResultsOnNameClick.trim();


  StringBuffer sbWhereExp = new StringBuffer(256);
  sBoType             = emxGetParameter(request, "ComboType");
  eNumObj             = emxGetParameterNames(request);

  //Get the Advanced Findlike parameters
  String sTxtKeyword      = emxGetParameter(request, "txtKeyword");
  String sFormat          = emxGetParameter(request, "comboFormat");

  if (sTxtKeyword == null || "".equals(sTxtKeyword) || "null".equals(sTxtKeyword)) {
      sTxtKeyword = "";
  }else {
      sTxtKeyword = sTxtKeyword.trim();
  }

  if (sFormat == null){
    sFormat = "*";
  }else{
    sFormat = sFormat.trim();
  }

  if(sBoType.indexOf(',') != -1) {
    sBoType = FrameworkUtil.findAndReplace(sBoType, ",", "?");
  }

  String wildPattern = "*";

  //to store the parameters passed
  Vector vectParamName = new Vector(10);
  String sParam = "";
  String sAttrib = "";
  String sValue = "";

  Pattern patternAttribute  = new Pattern("");
  Pattern patternOperator   = new Pattern("");

  //storing all the  parameter names into a vector
  while (eNumObj.hasMoreElements()) {
    sParam = (String)eNumObj.nextElement();
    vectParamName.add(sParam);
  }

  eNumObj = request.getAttributeNames();
  while (eNumObj.hasMoreElements()) {
    sParam = (String)eNumObj.nextElement();
    vectParamName.add(sParam);
  }

  String sParamName              = "";

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

        if (sTextValue == null || sTextValue.equals("") || "null".equals(sTextValue)) {
           sTextValue = (String) paramMap.get("txt_" + sAttrib);
        }

        //get value entered into select
        sSelectValue =(String) paramMap.get(sAttrib);
        //check if text val exists, if not use select
        if(!patternOperator.match("*")) {
          if ((sTextValue == null) || (sTextValue.equals("")) || ("null".equals(sTextValue))) {
            if(sSelectValue!=null) {
              sValue = sSelectValue;

            }
          }else {
            sValue = sTextValue.trim();
          }
        }

        //To get the where expression if any parameter values exists
        if ((!sValue.equals("")) && (!sValue.equals("*"))) {
          if (sbWhereExp.length() > 0) {
            sbWhereExp.append(sAnd);
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
          }else {
            sbWhereExp.append(sAttribute);
            sbWhereExp.append(sOpenBracket);
            sbWhereExp.append(sAttrib);
            sbWhereExp.append(sCloseBracket);
          }

          if (patternOperator.match(sMatrixIncludes)) {
            sbWhereExp.append(sMatch);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sWild);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sWild);
            sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixIsExactly)) {
              if(sAttrib.equals("Vault") && sValue.indexOf(',') >0) {
                StringTokenizer sVaults = new StringTokenizer(sValue,",");
                if(sVaults.hasMoreTokens()) {
                  String selVault1 = (String)sVaults.nextToken();
                  sbWhereExp.append(sEqual);
                  sbWhereExp.append(sQuote);
                  sbWhereExp.append(selVault1);
                  sbWhereExp.append(sQuote);
                }

                while(sVaults.hasMoreTokens()) {
                  String selVault = (String)sVaults.nextToken();
                  sbWhereExp.append(sOr);
                  sbWhereExp.append(sAttrib);
                  sbWhereExp.append(sEqual);
                  sbWhereExp.append(sQuote);
                  sbWhereExp.append(selVault);
                  sbWhereExp.append(sQuote);
                }
              }else {
               sbWhereExp.append(sEqual);
               sbWhereExp.append(sQuote);
               sbWhereExp.append(sValue);
               sbWhereExp.append(sQuote);
              }
          }else if (patternOperator.match(sMatrixIsNot)) {
              if(sAttrib.equals("Vault") && sValue.indexOf(',') >0) {
                StringTokenizer sVaults = new StringTokenizer(sValue,",");
                if(sVaults.hasMoreTokens()) {
                  String selVault1 = (String)sVaults.nextToken();
                  sbWhereExp.append(sNotEqual);
                  sbWhereExp.append(sQuote);
                  sbWhereExp.append(selVault1);
                  sbWhereExp.append(sQuote);
                }
                while(sVaults.hasMoreTokens()) {
                  String selVault = (String)sVaults.nextToken();
                  sbWhereExp.append(sAnd);
                  sbWhereExp.append(sAttrib);
                  sbWhereExp.append(sNotEqual);
                  sbWhereExp.append(sQuote);
                  sbWhereExp.append(selVault);
                  sbWhereExp.append(sQuote);
                }
              }else {
                 sbWhereExp.append(sNotEqual);
                 sbWhereExp.append(sQuote);
                 sbWhereExp.append(sValue);
                 sbWhereExp.append(sQuote);
               }
          }else if (patternOperator.match(sMatrixMatches)) {
             if(sAttrib.equals("Vault") && sValue.indexOf(',') >0) {
                StringTokenizer sVaults = new StringTokenizer(sValue,",");
                if(sVaults.hasMoreTokens()) {
                  String selVault1 = (String)sVaults.nextToken();
                  sbWhereExp.append(sMatch);
                  sbWhereExp.append(sQuote);
                  sbWhereExp.append(selVault1);
                  sbWhereExp.append(sQuote);
                }
                while(sVaults.hasMoreTokens()) {
                  String selVault = (String)sVaults.nextToken();
                  sbWhereExp.append(sOr);
                  sbWhereExp.append(sAttrib);
                  sbWhereExp.append(sMatch);
                  sbWhereExp.append(sQuote);
                  sbWhereExp.append(selVault);
                  sbWhereExp.append(sQuote);
                }
            }else{
                sbWhereExp.append(sMatch);
                sbWhereExp.append(sQuote);
				//addded for the bug 251223
				sbWhereExp.append(sWild);
                sbWhereExp.append(sValue);
				//addded for the bug 251223
				sbWhereExp.append(sWild);
                sbWhereExp.append(sQuote);
            }
          }else if (patternOperator.match(sMatrixBeginsWith)) {
            sbWhereExp.append(sMatch);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sWild);
            sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixEndsWith)) {
            sbWhereExp.append(sMatch);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sWild);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixEquals)) {
            sbWhereExp.append(sEqual);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixDoesNotEqual)) {
           sbWhereExp.append(sNotEqual);
           sbWhereExp.append(sQuote);
           sbWhereExp.append(sValue);
           sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixIsBetween)) {
            sValue = sValue.trim();
            int iSpace = sValue.indexOf(" ");
            String sLow  = "";
            String sHigh = "";

            if (iSpace == -1) {
              sLow  = sValue;
              sHigh = sValue;
            }else {
              sLow  = sValue.substring(0,iSpace);
              sHigh = sValue.substring(sLow.length()+1,sValue.length());

              // Check for extra values and ignore
              //
              iSpace = sHigh.indexOf(" ");

              if (iSpace != -1) {
                sHigh = sHigh.substring(0, iSpace);
              }
            }

            sbWhereExp.append(sGreaterThanEqual);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sLow);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sCloseParen);
            sbWhereExp.append(sAnd);
            sbWhereExp.append(sOpenParen);

            if (patternAttribute.match(sMatrixDescription) ||
                    patternAttribute.match(sMatrixCurrent)     ||
                    patternAttribute.match(sMatrixModified)    ||
                    patternAttribute.match(sMatrixOriginated)  ||
                    patternAttribute.match(sMatrixGrantor)     ||
                    patternAttribute.match(sMatrixGrantee)     ||
                    patternAttribute.match(sMatrixPolicy)) {
              sbWhereExp.append(sAttrib);
            }else {
              sbWhereExp.append(sAttribute);
              sbWhereExp.append(sOpenBracket);
              sbWhereExp.append(sAttrib);
              sbWhereExp.append(sCloseBracket);
            }
            sbWhereExp.append(sLessThanEqual);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sHigh);
            sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixIsAtMost)) {
            sbWhereExp.append(sLessThanEqual);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixIsAtLeast)) {
            sbWhereExp.append(sGreaterThanEqual);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixIsMoreThan)) {
            sbWhereExp.append(sGreaterThan);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixIsLessThan)) {
            sbWhereExp.append(sLessThan);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixIsOn)) {
            sValue=eMatrixDateFormat.getFormattedInputDateTime(context,sSelectValue,startDayTime,clientTZOffset,request.getLocale());
            sbWhereExp.append(sGreaterThanEqual);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sQuote);

            sbWhereExp.append(" && ");

            if (patternAttribute.match(sMatrixModified) || patternAttribute.match(sMatrixOriginated)) {
              sbWhereExp.append(sAttrib);
            }else {
              sbWhereExp.append(sAttribute);
              sbWhereExp.append(sOpenBracket);
              sbWhereExp.append(sAttrib);
              sbWhereExp.append(sCloseBracket);
            }
            sValue=eMatrixDateFormat.getFormattedInputDateTime(context,sSelectValue,endDayTime,clientTZOffset,request.getLocale());
            sbWhereExp.append(sLessThanEqual);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixIsOnOrBefore)) {
            sValue=eMatrixDateFormat.getFormattedInputDateTime(context,sSelectValue,endDayTime,clientTZOffset,request.getLocale());
            sbWhereExp.append(sLessThanEqual);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sQuote);
          }else if (patternOperator.match(sMatrixIsOnOrAfter)) {
            sValue=eMatrixDateFormat.getFormattedInputDateTime(context,sSelectValue,startDayTime,clientTZOffset,request.getLocale());
            sbWhereExp.append(sGreaterThanEqual);
            sbWhereExp.append(sQuote);
            sbWhereExp.append(sValue);
            sbWhereExp.append(sQuote);
          }
          sbWhereExp.append(sCloseParen);
        }
      }
    }
  }

  String dateBegin    = emxGetParameter(request, "dateBegin");
  String dateEnd      = emxGetParameter(request, "dateEnd");
  String whereStart   = "";

  if (!"".equals(sbWhereExp.toString())) {
    whereStart = "&&";
  }

  if ((dateBegin != null) && (!"".equals(dateBegin))) {
    sbWhereExp.append(whereStart);
    sbWhereExp.append("(originated > \"");
    sbWhereExp.append(dateBegin);
    sbWhereExp.append("\")");
    whereStart = " && ";
  }

  if ((dateEnd != null) && (!"".equals(dateEnd))) {
    sbWhereExp.append(whereStart);
    sbWhereExp.append("(originated < \"");
    sbWhereExp.append(dateEnd);
    sbWhereExp.append("\")");
    whereStart = " && ";
  }
%>

<%
    String actionUrl = "../common/emxTable.jsp";
    String helpMarker = "emxhelpsearch";

    String objectId   = emxGetParameter(request,"objectId");
    String targetSearchPage = emxGetParameter(request,"targetSearchPage");
    String page1Heading = emxGetParameter(request,"page1Heading");
    String page2Heading = emxGetParameter(request,"page2Heading");
    String omitSpareParts = emxGetParameter(request,"omitSpareParts");
    String omitAllRevisions = emxGetParameter(request,"omitAllRevisions");
    String isAVLReport = emxGetParameter(request,"AVLReport");
    String searchType = emxGetParameter(request,"searchType");

    String program = emxGetParameter(request,"program");
    String table = emxGetParameter(request,"table");
    String targetResultsPage = emxGetParameter(request,"targetResultsPage");

    if(searchType != null && searchType.equals("eBomFindLike")) {
        actionUrl = "emxEngrCommonPartSearchResultsFS.jsp";
        helpMarker = "emxhelpfindselect";
    }


%>
	<!-- XSSOK -->
      <form name="formDataRows" method="get" action="<%=actionUrl%>" target="_parent" onSubmit="return false">
         <input type="hidden" name="txtWhere" value="<xss:encodeForHTMLAttribute><%=java.net.URLEncoder.encode(sbWhereExp.toString(), "UTF-8")%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtSearch" value="<xss:encodeForHTMLAttribute><%=sTxtKeyword%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtFormat" value="<xss:encodeForHTMLAttribute><%=sFormat%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="ckSaveQuery" value="" />
         <input type="hidden" name="txtQueryName" value="" />
         <input type="hidden" name="ckChangeQueryLimit" value="" />
         <input type="hidden" name="queryLimit" value="<xss:encodeForHTMLAttribute><%=shQueryLimit%></xss:encodeForHTMLAttribute>" />
     <input type="hidden" name="pagination" value="<xss:encodeForHTMLAttribute><%=pagination%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="fromDirection" value="" />
         <input type="hidden" name="toDirection" value="" />
         <input type="hidden" name="selType" value="<xss:encodeForHTMLAttribute><%=sBoType%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtName" value="<xss:encodeForHTMLAttribute><%=sWild%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtRev" value="<xss:encodeForHTMLAttribute><%=sWild%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtOwner" value="<xss:encodeForHTMLAttribute><%=sWild%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtOriginator" value="<xss:encodeForHTMLAttribute><%=sWild%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtDesc" value="" />
         <input type="hidden" name="incECRECOImage" value="true" />
<%

         if(table == null || "".equals(table) || "null".equals(table)) {
            if(sBoType.equals(com.matrixone.apps.domain.DomainConstants.TYPE_PART)) {
                table = "ENCPartSearchResult";
            }else {
                table = "ENCGeneralSearchResult";
            }
         }
%>
         <input type="hidden" name="table" value="<xss:encodeForHTMLAttribute><%=table%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="selection" value="multiple" />
         <input type="hidden" name="header" value="emxEngineeringCentral.Common.SearchResults" />
         <input type="hidden" name="sortColumnName" value="Name" />
         <input type="hidden" name="sortDirection" value="ascending" />
<%
        if(program == null || "".equals(program) || "null".equals(program)) {
            program = "emxPart:getPartSearchResult";
        }
%>
         <input type="hidden" name="program" value="<xss:encodeForHTMLAttribute><%=program%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%=languageStr%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="vault" value="<xss:encodeForHTMLAttribute><%=vault%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="vaultOption" value="<xss:encodeForHTMLAttribute><%=vault%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="toolbar" value="ENCSearchResultToolbar" />
         <input type="hidden" name="topActionbar" value="ENCSearchResultTopActionbar" />
         <input type="hidden" name="bottomActionbar" value="ENCSearchResultBottomActionbar" />
         <input type="hidden" name="CancelButton" value="true" />
         <input type="hidden" name="HelpMarker" value="emxhelpsearch" />
         <input type="hidden" name="Style" value="Dialog" />
         <input type="hidden" name="CancelLabel" value="emxEngineeringCentral.Common.Close" />
         <input type="hidden" name="TransactionType" value="update" />
         <input type="hidden" name="tempStore" value="" />
         <input type="hidden" name="mode" value="" />
         <input type="hidden" name="saveQuery" value="false" />
         <input type="hidden" name="changeQueryLimit" value="true" />
         <input type="hidden" name="vaultAwarenessString" value="<xss:encodeForHTMLAttribute><%=vaultAwarenessString%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="targetResultsPage" value="<xss:encodeForHTMLAttribute><%=targetResultsPage%></xss:encodeForHTMLAttribute>" />

<%
    if(searchType != null && searchType.equals("eBomFindLike")) {

%>
    <input type="hidden" name="AVLReport" value="<xss:encodeForHTMLAttribute><%=isAVLReport%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="page1Heading" value="<xss:encodeForHTMLAttribute><%=page1Heading%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="page2Heading" value="<xss:encodeForHTMLAttribute><%=page2Heading%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="targetSearchPage" value="<xss:encodeForHTMLAttribute><%=targetSearchPage%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="omitSpareParts" value="<xss:encodeForHTMLAttribute><%=omitSpareParts%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="omitAllRevisions" value="<xss:encodeForHTMLAttribute><%=omitAllRevisions%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="searchType" value="<xss:encodeForHTMLAttribute><%=searchType%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="header" value="<xss:encodeForHTMLAttribute><%=page2Heading%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="SubmitURL" value="<xss:encodeForHTMLAttribute><%=targetSearchPage%></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="CancelButton" value="true" />
<%
    if("".equals(strMultiSelect) || strMultiSelect == null || "null".equals(strMultiSelect))
        {
%>
        <input type="hidden" name="multiSelect" value="null" />
<%
        }
    else
        {
%>
    <input type="hidden" name="multiSelect" value="<xss:encodeForHTMLAttribute><%=strMultiSelect%></xss:encodeForHTMLAttribute>" />
<%
        }
    }
%>
      </form>

<script language="javascript">
   document.formDataRows.submit();
</script>

<%@include file = "emxDesignBottomInclude.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
