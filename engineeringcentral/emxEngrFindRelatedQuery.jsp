<%--  emxEngrFindRelatedQuery.jsp   - execute the database query and produces the search
      result and displays it in the find Reults page.

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<html>
<body>


<%@ include file = "emxDesignTopInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
  String markup         = PropertyUtil.getSchemaProperty(context, "relationship_Markup");
  String languageStr    = request.getHeader("Accept-Language");
  String suiteKey       = emxGetParameter(request,"suiteKey");

  if (suiteKey == null || suiteKey.equals("null") || suiteKey.equals("")){
    suiteKey = "eServiceSuiteEngineeringCentral";
  }

  // Check query limit
  String queryLimit = emxGetParameter(request,"queryLimit");
  if (queryLimit == null || queryLimit.equals("null") || queryLimit.equals("")){
    queryLimit = "0";
  }
  // hold the business type and parameters
  String sBoType = "";

  String sAnd                = " && ";
  String sOr                 = " || ";
  String sEquals             = " == ";
  String sNotMatchCase       = " ~= ";
  String sWild               = "*";
  String sOpenParen          = "(";
  String sCloseParen         = ")";
  String sOpenBracket        = "[";
  String sCloseBracket       = "]";
  String sDot                = ".";
  String sQuote              = "\"";
  String sRelationship       = "relationship";
  String sTypeStr            = "type";
  String sNameStr            = "name";
  String sRevStr             = "revision";

  String setName = "";
  String sName   = "";
  String sRev    = "";
  String otherSide = "";
  boolean includeSubTypes = true;

  //Declare display variables
  String nextURL    = "";
  String target     = "";
  String objectId   = null;
  String objectType = null;
  String objectName = null;
  String objectRev  = null;
  String objectDesc = null;
  String objectState= null;

  String sUseAndOr = emxGetParameter(request, "andOr");
  String sAndOr = sAnd;
  if (sUseAndOr.equals("or"))
  {
    sAndOr = sOr;
  }

  sBoType = emxGetParameter(request, "selType");

  StringBuffer sbWhereExp = new StringBuffer(256);
  StringBuffer primaryWhere = new StringBuffer(256);

  //MQLCommand mqlCmd = new MQLCommand();
  //mqlCmd.open(context);

  //Loop to get the parameter values
  int i = 1;
  String sType = emxGetParameter(request,("type" + i));

  StringBuffer searchType = new StringBuffer(256);
  StringBuffer searchName = new StringBuffer(256);
  StringBuffer searchRev = new StringBuffer(256);

  if((sType == null) || (sType.equals("")))
  {
    i++;
    sType = emxGetParameter(request,("type" + i));
  }

  while((sType != null) && (!sType.equals("")))
  {
      if (searchType.length() > 0)
      {
         searchType.append(",");
      }
      searchType.append(sType);

      sName   = emxGetParameter(request, ("name" + i));
      if (searchName.length() > 0)
      {
         searchName.append(",");
      }

      if (sName == null || sName.trim().equals(""))
      {
         searchName.append(sWild);
      }
      else
      {
         searchName.append(sName);
      }

      sRev    = emxGetParameter(request, ("rev" + i));
      if (searchRev.length() > 0)
      {
         searchRev.append(",");
      }
      if (sRev == null || sRev.trim().equals(""))
      {
         searchRev.append(sWild);
      }
      else
      {
         searchRev.append(sRev);
      }

      i++;
      sType = emxGetParameter(request,("type" + i));
      if((sType == null) || (sType.equals("")))
      {
        i++;
        sType = emxGetParameter(request,("type" + i));
      }
  }
  if (searchName.length() == 0)
  {
     searchName.append(sWild);
  }
  if (searchRev.length() == 0)
  {
     searchRev.append(sWild);
  }

  com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
  String vaultPattern = person.getCompany(context).getAllVaults(context, true);

  setName = ".tmpSet_" + System.currentTimeMillis();
  matrix.db.Query queryOne = new matrix.db.Query("");
  queryOne.setBusinessObjectType(searchType.toString());
  queryOne.setBusinessObjectName(searchName.toString());
  queryOne.setBusinessObjectRevision(searchRev.toString());
  queryOne.setVaultPattern(vaultPattern);
  queryOne.setOwnerPattern(sWild);
  queryOne.setWhereExpression("");
  queryOne.setExpandType(true);

  long startTime1 = System.currentTimeMillis();
  queryOne.evaluateIntoNamedSet(context,setName, true);

  //now go thru all rows and create where clause to apply to set
  i = 1;
  sType = emxGetParameter(request,("type" + i));
  if((sType == null) || (sType.equals("")))
  {
    i++;
    sType = emxGetParameter(request,("type" + i));
  }
  String direct = "";
  String relName = "";
  while((sType != null) && (!sType.equals("")))
  {
    direct  = emxGetParameter(request, ("reldir" + i));
    relName = emxGetParameter(request, "hiddenRel" + i);

    if (sbWhereExp.length() > 0)
    {
      sbWhereExp.append(sAndOr);
    }

    if (direct.equalsIgnoreCase("to"))
    {
       sbWhereExp.append("fromset");
    }
    else
    {
       sbWhereExp.append("toset");
    }
    sbWhereExp.append(sOpenBracket);
    sbWhereExp.append(setName);
    sbWhereExp.append(",");
    sbWhereExp.append(relName);
    sbWhereExp.append(sCloseBracket);
    sbWhereExp.append(sEquals);
    sbWhereExp.append("True");

    if (!markup.equalsIgnoreCase(relName))
            {
              sbWhereExp.append(sAndOr);


                  if (direct.equalsIgnoreCase("to"))
                  {
                     sbWhereExp.append("fromset");
                  }
                  else
                  {
                     sbWhereExp.append("toset");
                  }
                  sbWhereExp.append(sOpenBracket);
                  sbWhereExp.append(setName);
                  sbWhereExp.append(",");
                  sbWhereExp.append(relName);
                  sbWhereExp.append(sCloseBracket);
                  sbWhereExp.append(sEquals);
                  sbWhereExp.append("True");
        }

    i++;
    sType = emxGetParameter(request,("type" + i));
    if((sType == null) || (sType.equals("")))
    {
      i++;

      sType = emxGetParameter(request,("type" + i));
    }
  }

  Integer qLimit = new Integer(queryLimit);
  short shQueryLimit = (short)qLimit.intValue();

%>

      <form name="formDataRows" method="post" action="../common/emxTable.jsp" target="_parent" onSubmit="return false">
         <input type="hidden" name="txtWhere" value="<xss:encodeForHTMLAttribute><%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(sbWhereExp.toString())%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtSearch" value="" />
         <input type="hidden" name="txtFormat" value="" />
         <input type="hidden" name="ckSaveQuery" value="" />
         <input type="hidden" name="txtQueryName" value="" />
         <input type="hidden" name="ckChangeQueryLimit" value="" />
         <input type="hidden" name="queryLimit" value="<xss:encodeForHTMLAttribute><%=shQueryLimit%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="fromDirection" value="" />
         <input type="hidden" name="toDirection" value="" />
         <input type="hidden" name="selType" value="<xss:encodeForHTMLAttribute><%=sBoType%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtName" value="<xss:encodeForHTMLAttribute><%=sWild%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtRev" value="<xss:encodeForHTMLAttribute><%=sWild%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtOwner" value="<xss:encodeForHTMLAttribute><%=sWild%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtOriginator" value="<xss:encodeForHTMLAttribute><%=sWild%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="txtDesc" value="" />
<%
         if (sBoType.equals(DomainConstants.TYPE_PART))
         {
%>
           <input type="hidden" name="table" value="ENCPartSearchResult" />
<%
         }
         else
         {
%>
           <input type="hidden" name="table" value="ENCGeneralSearchResult" />
<%
         }
%>

         <input type="hidden" name="selection" value="multiple" />
         <input type="hidden" name="header" value="emxEngineeringCentral.Common.SearchResults" />
         <input type="hidden" name="sortColumnName" value="Name" />
         <input type="hidden" name="sortDirection" value="ascending" />
         <input type="hidden" name="program" value="emxPart:getPartSearchResult" />
         <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="languageStr" value="<xss:encodeForHTMLAttribute><%=languageStr%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="vault" value="<xss:encodeForHTMLAttribute><%=JSPUtil.getVault(context,session)%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="toolbar" value="ENCSearchResultToolbar" />
         <input type="hidden" name="CancelButton" value="true" />
         <input type="hidden" name="HelpMarker" value="emxhelpsearchfindrelated" />
         <input type="hidden" name="Style" value="Dialog" />
         <input type="hidden" name="CancelLabel" value="emxEngineeringCentral.Common.Close" />
         <input type="hidden" name="TransactionType" value="update" />
         <input type="hidden" name="tempStore" value="" />
         <input type="hidden" name="mode" value="" />
         <input type="hidden" name="saveQuery" value="false" />
         <input type="hidden" name="changeQueryLimit" value="true" />
         <input type="hidden" name="removeSet" value="<xss:encodeForHTMLAttribute><%=setName%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="vaultAwarenessString" value="<xss:encodeForHTMLAttribute><%=vaultAwarenessString%></xss:encodeForHTMLAttribute>" />
         <input type="hidden" name="incECRECOImage" value="true" />
         <input type="hidden" name="pagination" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"pagination")%></xss:encodeForHTMLAttribute>" /> 
      </form>

<%@include file = "emxDesignBottomInclude.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

<script language="javascript">
   document.formDataRows.submit();
</script>
