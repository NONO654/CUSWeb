<%-- emxCompMailSelectPeopleResults.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxCompMailSelectPeopleResults.jsp.rca 1.26 Wed Oct 22 15:48:57 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.*,com.matrixone.apps.framework.ui.*"%>

<% 
  BusinessObject personObject=null;
  String userCompany ="";
  Iterator exportIterator =null;
  StringTokenizer strTok = null;
  String sUserID = "";
  String sFullName="";
  HashMap temHashMap =null;
  MapList tempMapList = new MapList();
  BusinessObjectList boListGeneric =null;
  String searchResults = "";
    String toPeople           = emxGetParameter(request,"toPeople");
	String ccPeople           = emxGetParameter(request,"ccPeople");
  
  String suiteKey           = emxGetParameter(request,"suiteKey");
  String sLink              = emxGetParameter(request,"page");
  String sUsername          = emxGetParameter(request,"txtUsername");
  String sFirstName         = emxGetParameter(request,"txtFirstName");
  String sLastName          = emxGetParameter(request,"txtLastName");
  String sCompany           = emxGetParameter(request,"txtCompany");
  String sNextSortOrder     = emxGetParameter(request, "sort");
  String sFilter            = emxGetParameter(request, "filter");
  String sSortImage         = emxGetParameter(request, "sortImage");
  String sFilterKey         = emxGetParameter(request, "key");
 String sFilterOption       = emxGetParameter(request, "FilterOption");
    String squeryfilter        = emxGetParameter(request, "queryfilter");
    String sBusId                   = emxGetParameter(request, "objectId");
    String jsTreeID                 = emxGetParameter(request,"jsTreeID");
    StringBuffer sParams = new StringBuffer(50);
    sSortImage="";
    sParams.append("jsTreeID=");
    sParams.append(jsTreeID);
    sParams.append("&objectId=");
    sParams.append(sBusId);
    sParams.append("&suiteKey=");
    sParams.append(suiteKey);
  //END OF ADDITION
  String sAll = "*";
  if(sLink == null)
    sLink ="";

%>

<script language="javascript">

  function submitform(){
    var checkedFlag = "false";
    var checkedvalue ="";
    var link =false;
<%
  if(sLink.equals("To")) {
%>
  link=true;
 checkedvalue="<%=XSSUtil.encodeForJavaScript(context,toPeople)%>";
<%
}else {
%>
link =false; 
checkedvalue="<%=XSSUtil.encodeForJavaScript(context,ccPeople)%>";
<%
}
%>

    // force to select atleast one member to remove

    if (document.templateresults.chkItem1== null)
    {
      alert("<emxUtil:i18nScript  localize='i18nId'>emxFramework.IconMail.Common.SelectPerson</emxUtil:i18nScript>");
      return;
    }

		 var value ;
    if (document.templateresults.chkItem1.length != null)
    {
      for( var i = 0; i < document.templateresults.chkItem1.length; i++ ){
        if (document.templateresults.chkItem1[i].checked ){
          checkedFlag = "true";
             value = document.templateresults.chkItem1[i].value+";";
		  
		  if(checkedvalue.indexOf(value)==-1){
		  
		 checkedvalue = checkedvalue+value;
		  }
        }
      }
    }
    if (document.templateresults.chkItem1 != null && document.templateresults.chkItem1.checked)
    {
      checkedFlag = "true";
      value = document.templateresults.chkItem1.value+";";
       if(checkedvalue.indexOf(value)==-1){
	    
		checkedvalue = checkedvalue+value;
		
		  }
    }

    if (checkedFlag == "false") {
      alert("<emxUtil:i18nScript  localize='i18nId'>emxFramework.IconMail.Common.SelectPerson</emxUtil:i18nScript>");
      return;
    } else {
      if(link) {

      parent.window.getWindowOpener().parent.frames['pagecontent'].document.forms['mailDialog'].txtToAddress.value=checkedvalue;
      } else {
      parent.window.getWindowOpener().parent.frames['pagecontent'].document.forms['mailDialog'].txtCcAddress.value=checkedvalue;
      }
      parent.window.closeWindow();
    }
  }

  function closeWindow() {
    parent.window.closeWindow();
    return;
  }
  //BUG Start 339066
function doCheck() {
    var objForm = document.templateresults;
    var chkList = objForm.chkList;
    for (var i=0; i < objForm.elements.length; i++)
      if (objForm.elements[i].name.indexOf('chkItem1') > -1)
        objForm.elements[i].checked = chkList.checked;
  }
  //BUG End 339066
</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
 
  if(sCompany == null) {
     sCompany = "*";
  }

  String strFirstNameAttr                = PropertyUtil.getSchemaProperty(context, "attribute_FirstName");
  String strLastNameAttr                 = PropertyUtil.getSchemaProperty(context, "attribute_LastName");
  String sType                           = PropertyUtil.getSchemaProperty(context, "type_Person");
  String sRelCustomers                   = PropertyUtil.getSchemaProperty(context, "relationship_Customer");
  String sRelSuppliers                   = PropertyUtil.getSchemaProperty(context, "relationship_Supplier");
  String sRelCollaborationPartners       = PropertyUtil.getSchemaProperty(context, "relationship_CollaborationPartner");
  String sTypeCompany                    = PropertyUtil.getSchemaProperty(context, "type_Company");
  String sRelEmployee                    = PropertyUtil.getSchemaProperty(context, "relationship_Employee");
  boolean isEntireDatabase=false;

  if(PersonUtil.isPersonObjectSchemaExist(context))
  {
     personObject =PersonUtil.getPersonObject(context);
     personObject.open(context);
     BusinessObject boCompanyName = FrameworkUtil.getOrganization(context, personObject, sRelEmployee);
     userCompany = boCompanyName.getName().toString();
     
     StringBuffer bufRelPattern = new StringBuffer(40);

     StringTokenizer st = new StringTokenizer(squeryfilter, "|");
     boolean optionMyCompany = false;
     while(st.hasMoreTokens())
      {
        String sToken=st.nextToken().trim();
        if(sToken.equals("Customers") && sRelCustomers.length() !=0 ){
           if(bufRelPattern.length()>0) {
                bufRelPattern.append(",");
           }
           bufRelPattern.append(sRelCustomers);
        }else if (sToken.equals("Suppliers")  && sRelSuppliers.length() !=0){
           if(bufRelPattern.length()>0) {
                bufRelPattern.append(",");
           }
           bufRelPattern.append(sRelSuppliers);
        }else if (sToken.equals("Collaboration Partners") && sRelCollaborationPartners.length() !=0){
           if(bufRelPattern.length()>0) {
                bufRelPattern.append(",");
           }
           bufRelPattern.append(sRelCollaborationPartners);
        }else if (sToken.equals("My Company") && sRelEmployee.length() !=0){
           optionMyCompany = true;
        }else if (sToken.equals("Entire Database") ){
           isEntireDatabase=true;
        }
      }

      matrix.db.Query qryGeneric    = null;
      if(isEntireDatabase) {
          qryGeneric    = new matrix.db.Query();
          qryGeneric.create(context);
          //set the Type where clause
          qryGeneric.setBusinessObjectType(sType);
          qryGeneric.setBusinessObjectName(sUsername);
          qryGeneric.setBusinessObjectRevision("*");
          qryGeneric.setOwnerPattern("*");
          qryGeneric.setVaultPattern("*");
      }
      StringBuffer  sWhereExpression  = new StringBuffer(200);
      boolean bLastname =false;
      boolean bFirstname =false;

      if((sLastName!=null) && !(sLastName.equals("*"))) {
        sWhereExpression.append("(attribute[");
        sWhereExpression.append(strLastNameAttr);
        sWhereExpression.append("] ~= '");
        sWhereExpression.append(sLastName);
        sWhereExpression.append("')");
        bLastname=true;
      }
      if((sFirstName!=null) && !(sFirstName.equals("*"))) {
        if (bLastname)
          sWhereExpression.append("&&");
        sWhereExpression.append("(attribute[");
        sWhereExpression.append(strFirstNameAttr);
        sWhereExpression.append("] ~= '");
        sWhereExpression.append(sFirstName);
        sWhereExpression.append("')");
        bFirstname=true;
      }
    String sExp = sWhereExpression.toString();
    StringBuffer bufWhereClause = new StringBuffer(100);

    if(!isEntireDatabase)
    {
        if(sUsername != null && !"*".equals(sUsername)) {
            bufWhereClause.append(DomainConstants.SELECT_NAME);
            bufWhereClause.append(" ~= \"");
            bufWhereClause.append(sUsername);
            bufWhereClause.append("\"");
        }

        if(bFirstname || bLastname) {
            if(bufWhereClause.length()>0) {
                bufWhereClause.append(" && ");
            }
            bufWhereClause.append(sExp);
        }

    }
    
    //FIX for IR-041159V6R2011
    if(bufWhereClause.length() > 0) bufWhereClause.append(" && ");
        
    bufWhereClause.append("current == 'Active'");

    if(isEntireDatabase) {
        qryGeneric.setWhereExpression(sExp);
        boListGeneric = qryGeneric.evaluate(context);
        qryGeneric.close(context);
        searchResults = "None";
    }else {
        //create set
        boolean onlyHostPerson = true;
        String objId = boCompanyName.getObjectId();
        StringBuffer mqlString = new StringBuffer(100);
     
        if(bufRelPattern.length() > 0) {
            onlyHostPerson = false;
            StringTokenizer sToken = new StringTokenizer(bufRelPattern.toString(), ",");
            StringList sList = new StringList();
            while (sToken.hasMoreTokens()) {
            	sList.addElement(sToken.nextToken().trim());	           
	        }
            //mql injection parameterization of query type: "expand bus id rel 'r1,r2,r3' type TYPE into set SET select bus ID;
            
            String sSet = MqlUtil.mqlCommand(context, "list set $1",".emxPersonSet");
            if( UIUtil.isNullOrEmpty(sSet)){
            	MqlUtil.mqlCommand(context, "add set $1",".emxPersonSet");
            }
            StringBuffer strBuf = new StringBuffer();
            strBuf.append("expand bus $1");
            String[] methodArgs = new String[sList.size()+4];
            methodArgs[0]       = objId;
        	strBuf.append(" rel '"); 

            int cmdCount = 0;
            int argCount = 0;
            
            if (sList != null && sList.size() > 0) {
                for (int i = 0; i < sList.size(); i++) 
                {
                	if(i != sList.size()-1){
                	strBuf.append("$").append(i+2).append(",");
                	} else {
                		strBuf.append("$").append(i+2);
                	}
                    methodArgs[i+1] = (String) sList.get(i);
                    cmdCount = i+2;
                    argCount = i+1;
                    
                }
            }
            strBuf.append("' type ");
            cmdCount = cmdCount+1;
            strBuf.append("$").append(cmdCount).append(" ");
            argCount = argCount+1;
            methodArgs[argCount] = sTypeCompany;
            strBuf.append(" into set ");
            cmdCount = cmdCount+1;
            strBuf.append("$").append(cmdCount).append(" ");
            argCount = argCount+1;
            methodArgs[argCount] = ".emxPersonSet";
            strBuf.append(" select bus ");
            cmdCount = cmdCount+1;
            strBuf.append("$").append(cmdCount).append(" ");
            argCount = argCount+1;
            methodArgs[argCount] = "id";
            strBuf.append(";");
            try {
                MqlUtil.mqlCommand(context, strBuf.toString(), false, methodArgs);
            } catch (Exception ex) {
                throw ex;
            } 

           
        }

        if(optionMyCompany && !onlyHostPerson) {
            //add Host Company bus id to set
           MqlUtil.mqlCommand(context,"modify set $1 add bus $2",".emxPersonSet",objId);
        }
        
        //get all persons
       String busOrSet = onlyHostPerson ? "bus" : "set";
	   String setNameOrBusId = onlyHostPerson ? objId : ".emxPersonSet";

	   searchResults = MqlUtil.mqlCommand(context,"expand $1  $2 from rel $3 type $4 select bus name where $5 dump $6",busOrSet, setNameOrBusId, sRelEmployee, sType, bufWhereClause.toString(), "|").trim();
	 }
  }
  else
  {
    String output = MqlUtil.mqlCommand(context, "list person $1 select $2 $3 dump $4","*","name","hidden","|");
    strTok = new StringTokenizer(output,"\n");
    searchResults = "None";
  }
String classname = "odd";
%>

<form name="templateresults" id="templateresults" method="post" onSubmit="submitform(); return false">
  <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="key"  value="<xss:encodeForHTMLAttribute><%=sFilterKey%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="sort" value="<xss:encodeForHTMLAttribute><%=sNextSortOrder%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="filter" value="false"/>
  <input type="hidden" name="sortImage" value="<xss:encodeForHTMLAttribute><%=sSortImage%></xss:encodeForHTMLAttribute>"/>

  <table border="0" cellpadding="3" cellspacing="2" width="100%">
<%
    if((boListGeneric != null && boListGeneric.size()==0 )|| (strTok!=null && strTok.countTokens() == 0) || "".equals(searchResults)) {
%>
      <tr class="odd">
        <td class="noresult" colspan="4"><emxUtil:i18n localize="i18nId">emxFramework.IconMail.Common.NoMatchFound</emxUtil:i18n></td>
      </tr>

<%
    }
  if(PersonUtil.isPersonObjectSchemaExist(context))
  {
    if(isEntireDatabase) {
        BusinessObject boGeneric = null;
        BusinessObjectItr boItrGeneric = new BusinessObjectItr(boListGeneric);
        
        while (boItrGeneric.next()) {
          boGeneric = boItrGeneric.obj();
          boGeneric.open(context);
          sUserID = boGeneric.getName();
          sFullName=PersonUtil.getFullName(context,sUserID);
          temHashMap =  new HashMap();
          temHashMap.put("UserId",sUserID);
          temHashMap.put("FullName",sFullName);
          tempMapList.add(temHashMap);
          boGeneric.close(context);
        }
    }else {
        if(!"".equals(searchResults)) {
            //parse the string
            StringTokenizer tokenPerson = new StringTokenizer(searchResults, "\n");
            while(tokenPerson.hasMoreTokens()) {
                sUserID = tokenPerson.nextToken().trim();
                sUserID = sUserID.substring(sUserID.lastIndexOf("|") + 1).trim();
                //Fix for 337552
                String sHidden = MqlUtil.mqlCommand(context, "print Person $1 select $2 dump",sUserID,"hidden");
                if("TRUE".equalsIgnoreCase(sHidden)) {
                    continue;
                }
                sFullName=PersonUtil.getFullName(context,sUserID);
                temHashMap =  new HashMap();
                temHashMap.put("UserId",sUserID);
                temHashMap.put("FullName",sFullName);
                tempMapList.add(temHashMap);
            }
        }
    }
  }
  else
  {
    StringTokenizer strTok1=null;
    String sNext="";
    while (strTok.hasMoreTokens())
    {
        sFullName="";
        sNext=strTok.nextToken();
        strTok1=new StringTokenizer(sNext,"|");
        sUserID=strTok1.nextToken();
        temHashMap =  new HashMap();
        temHashMap.put("UserId",sUserID);
        if (strTok1.nextToken().equals("FALSE"))
        {
            sFullName=PersonUtil.getFullName(context,sUserID);
            temHashMap.put("FullName",sFullName);
        }
        tempMapList.add(temHashMap);
    }
  }
%>
    <framework:sortInit
     defaultSortKey="UserId"
     defaultSortType="string"
     mapList="<%=tempMapList%>"
     params=''
     resourceBundle="emxFrameworkStringResource"
     ascendText="emxFramework.Common.SortAscending"
     descendText="emxFramework.Common.SortDescending"/>

    <tr>
      <th width="5%" style="text-align:center"><input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" /></th>
      <th>
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
         <th nowrap>
           <framework:sortColumnHeader
             title= "emxFramework.IconMail.Common.UserID"
             sortKey="UserId"
             sortType="string"
             anchorClass="sortMenuItem"/>
            </th>
              <td></td>
          </tr>
        </table>
      </th>
      <th>
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
         <th nowrap>
           <framework:sortColumnHeader
             title= "emxFramework.IconMail.Common.FullName"
             sortKey="FullName"
             sortType="string"
             anchorClass="sortMenuItem"/>
            </th>
              <td></td>
          </tr>
        </table>
      </th>
    </tr>
  <framework:mapListItr mapList="<%=tempMapList%>" mapName="tempMap">
      <tr class='<framework:swap id ="1" />'>
        <td><input type="checkbox" name ="chkItem1" id="chkItem1" value = "<%=XSSUtil.encodeForHTMLAttribute(context, (String)tempMap.get("UserId"))%>" /></td>
        <td><%=XSSUtil.encodeForHTML(context, (String)tempMap.get("UserId"))%></td>
        <td><%=XSSUtil.encodeForHTML(context, (String)tempMap.get("FullName"))%>&nbsp;</td>
    </framework:mapListItr>
  </table>
</form>
<%
  // ----- Common Page End Include  -------
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

