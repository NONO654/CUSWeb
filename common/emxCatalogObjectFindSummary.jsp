 <%--  emxDocumentObjectFindSummary.jsp   -
   Copyright (c) 1992-2008 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: Page display the results of the search

   Parameters : DialogAction (SearchResults, AddChildren, SearchIn, Chooser)
                baseType (Library/Bookshelf/Book/GenericDocument/All)
                searchDirection (Up, Down, None) - search direction for expand construction
                objectId
                sUITable
                selectOption
                folderContentAdd
                showPaginationMinimized
                Accept-Language
                forceRefresh (TRUE/FALSE) - causes query results to be rebuilt on reload.


   static const char RCSID[] = "$Id: emxLibraryCentralObjectFindSummary.jsp.rca 1.10.1.1.1.3 Thu Feb  7 19:52:48 2008 przemek Experimental $":
--%>
<%@ page import = "matrix.db.*,matrix.util.*,com.matrixone.servlet.*,java.util.*,java.io.*,java.net.URLEncoder,
                   java.util.*,java.text.*" errorPage="../common/emxNavigatorErrorPage.jsp"%>

<%@ page import =  "com.matrixone.apps.common.BuyerDesk,com.matrixone.apps.common.BusinessUnit,com.matrixone.apps.common.Company,com.matrixone.apps.common.Document,com.matrixone.apps.common.DocumentHolder,com.matrixone.apps.common.Location,com.matrixone.apps.common.Message,com.matrixone.apps.common.Meeting,com.matrixone.apps.common.MessageHolder,com.matrixone.apps.common.Organization,com.matrixone.apps.common.Person,com.matrixone.apps.common.Part,com.matrixone.apps.common.Subscribable,com.matrixone.apps.common.SubscriptionManager,com.matrixone.apps.common.Workspace,com.matrixone.apps.common.WorkspaceVault,com.matrixone.apps.common.DiscussionEvent"%>

<%@ page import = "com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,com.matrixone.apps.common.util.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.framework.taglib.*" %>

<%@ include file = "../emxTagLibInclude.inc"%>
<%@ include file = "../emxI18NMethods.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@ include file = "../emxPaginationInclude.inc"%>
 <%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
	// Getting The Request Parameters
	String dialogAction = emxGetParameter(request, "DialogAction");
	String sName = emxGetParameter(request,"attribute_Name");
	String txtVaultOption = emxGetParameter(request,"attribute_Vault");
	String baseType = emxGetParameter(request, "baseType");
	String searchType = emxGetParameter(request, "searchType");
	String searchDirection = emxGetParameter(request, "searchDirection");
	String parentOId = emxGetParameter(request, "objectId");
	String selectOption = emxGetParameter(request, "selectOption");
	String languageStr = request.getHeader("Accept-Language");
	String forceRefresh = emxGetParameter(request, "forceRefresh");
	String showPrinterFriendly = emxGetParameter(request,
			"PrinterFriendly");
	String sQueryLimit = emxGetParameter(request, "sQueryLimit");
	String strUseMode = "classifiedItems";

	boolean showNoResults = false;
	//-Getting the TypeName for corresponding Symbolic name ----

	// will be '0' when user enters '0' or negative no. for search limit.
	if (sQueryLimit != null && "0".equalsIgnoreCase(sQueryLimit)) {
		showNoResults = true;
	}
	if(sQueryLimit == null)
		sQueryLimit = "100";

	String sVault="";
	String strVaults="";
	StringList strListVaults=new StringList();

	if(txtVaultOption.equals("ALL_VAULTS"))
    {
      strListVaults = com.matrixone.apps.common.Person.getCollaborationPartnerVaults(context,null);
      StringItr strItr = new StringItr(strListVaults);
      if(strItr.next()){
        strVaults =strItr.obj().trim();
      }
      while(strItr.next())
      {
        strVaults += "," + strItr.obj().trim();
      }
      sVault = strVaults;
    }
    else if(txtVaultOption.equals("LOCAL_VAULTS"))
    {
      com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
      Company company = person.getCompany(context);
      sVault = company.getLocalVaults(context);
    }
    else if (txtVaultOption.equals("DEFAULT_VAULT"))
    {
      sVault = context.getVault().getName();
    }
    else
    {
      sVault = txtVaultOption;

    }
	StringBuffer refineSearchUrl = new StringBuffer(
			"emxGetFromCatalogVPLMDialogFS.jsp?refineSearch=true");

	Enumeration enumParamNames = emxGetParameterNames(request);
	HashMap aMap = new HashMap();

	// loop through form parameters, build supportinng objects.
	while (enumParamNames.hasMoreElements()) {

		String paramName = (String) enumParamNames.nextElement();
		String paramValue = (String) emxGetParameter(request, paramName);

		// when this is true, it indicates user entered invalid search limit like '0' or negative in dialog page
		// reset querylimit to default value '100'
		if (showNoResults
				&& (paramName.equals("sQueryLimit") || paramName
						.equals("QueryLimit"))) {
			paramValue = "100";
		}

		// build string for reload/refine load.
		refineSearchUrl.append("&" + paramName + "=" + paramValue);

		// build map of serach criteria.
		// if showNoResults is true,user had keyed in '0' or invalid search limit and hence show no results
		if (!showNoResults && paramValue != null
				&& paramValue.trim().length() > 0) {
			// all attributes including date attributes will be processed in JPO
			aMap.put(paramName, paramValue);
		}
	}
	refineSearchUrl.append("&searchName=" + sName);
	refineSearchUrl.append("&searchVault=" + sVault);

	// Encoding refine SearchUrl
	String refineSearchUrlEncoded = Framework.encodeURL(response,
			refineSearchUrl.toString());

	// URL for new Search Link
	StringBuffer returnSearchFrameset = new StringBuffer(
			"emxGetFromCatalogVPLMDialogFS.jsp");

	returnSearchFrameset.append("?DialogAction=" + dialogAction);
	returnSearchFrameset.append("&searchDirection=" + searchDirection);
	returnSearchFrameset.append("&objectId=" + parentOId);
	returnSearchFrameset.append("&selectOption=" + selectOption);
	refineSearchUrl.append("&sQueryLimit=" + sQueryLimit);
	// If dialog Action is Search results or its case of Addtofolders
	// all search Links Should be there else only for baseType SearchLink
	returnSearchFrameset.append("&baseType=" + baseType);
	returnSearchFrameset.append("&searchType=" + searchType);
	returnSearchFrameset.append("&useMode=" + strUseMode);
	// Encoding The URL
	String sreturnSearchFramesetEncoded = Framework.encodeURL(response,
			returnSearchFrameset.toString());

	MapList searchMaplist = null;

	// if query needs built depending on parameter, call query method and attach
	// results to emxPage
	if (emxPage.isNewQuery()) {
		if (!showNoResults) {
			// Perform query, get maplist of objects.
			//MapList mpList = (MapList) DocumentCentralCommon.findObjects ( context, aMap );
			SelectList select = new SelectList(4);

			select.add(DomainObject.SELECT_ID);
			select.add(DomainObject.SELECT_TYPE);
			select.add(DomainObject.SELECT_NAME);
			select.add(DomainObject.SELECT_DESCRIPTION);
			
            //MUT R217 NameMappingRemoval Migration
            if(com.matrixone.vplm.m1mapping.MappingManager.nameMapping())
            // old names
            {
                select.addAttribute("VPLMatt/PLMEntity/PLM_ExternalID");
            }
            else
            // new names
            {
               select.addAttribute("PLMEntity.PLM_ExternalID");
            }
            //MUT R217 NameMappingRemoval Migration

			String sWhere = "";
			//MapList mpList = (MapList)Classification.findObjects ( context,aMap ); //Divya
			MapList mpList = DomainObject.findObjects(context,
					baseType, sName, "*", "*", sVault, sWhere, null, true,
					select, Short.parseShort("100"));
			// Setting the search Map list as table MapList
			emxPage.getTable().setObjects(mpList);
			//emxPage.getTable().setObjects(new MapList());
		} else {
			// when user keys in '0' or negative no. for search limit, show no result
			emxPage.getTable().setObjects(new MapList());
		}
	}

	// Getting the current mapList from the table
	searchMaplist = emxPage.getTable().evaluate(context,
			emxPage.getCurrentPage());

	// The accessInfo conatins information of select which is determined
	// on fly according to dialog Action in JPO.
	// This acess Info is used in AddChildren case where we need to gray if
	// releavent access is not there( tcconnect or fromconnect)
	String aceessInfo = null;

	// Incase of AddChildren(fromAddExisiting Link) or add to folders case
	// We need to check toconnect on searched objects.
	if (dialogAction.equalsIgnoreCase("AddChildren")) {
		aceessInfo = "toconnect";
	}
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="frmMain" action="" target="_parent" method="post">
<input type="hidden" name="callPage" value="">
<%
	// All the request parameters are made hidden elements
	Enumeration tempEnumParamNames = emxGetParameterNames(request);

	while (tempEnumParamNames.hasMoreElements()) {
		String paramName = (String) tempEnumParamNames.nextElement();
		String paramValue = (String) emxGetParameter(request, paramName);

		// don't add 'emxTableRowId' elements from previous time page was
		// displayed.
		if (!paramName.equals("emxTableRowId")) {
%>
  <input type="hidden" name="<%=paramName%>" value="<%=paramValue%>" />
<%
	}
	}
%>
  <framework:sortInit
    defaultSortKey="<%=DomainConstants.SELECT_NAME%>"
    defaultSortType="string"
    mapList="<%=searchMaplist%>"
    resourceBundle="emxLibraryCentralStringResource"
    ascendText="emxDocumentCentral.Common.SortAscending"
    descendText="emxDocumentCentral.Common.SortDescending"/>

  <table border="0" cellpadding="5" cellspacing="2" width="100%">

    <!-- Table Column Headers -->

    <th width="5%">
      <table>
        <tr>
          <td align="center">
            <input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" />
          </td>
        </tr>
      </table>
    </th>
<%
	// Show lock status column when Dialog Action is chooser
	if (dialogAction.equalsIgnoreCase("addChildren")) {
%>
    <th nowrap="nowrap">
      <framework:sortColumnHeader
        title="emxDocumentCentral.Common.Name"
        sortKey="<%=DomainConstants.SELECT_NAME %>"
        sortType="string"
        anchorClass="sortMenuItem" />
    </th>

     <th nowrap="nowrap">
      <framework:sortColumnHeader
        title="emxDocumentCentral.Common.Description"
        sortKey="<%=DomainConstants.SELECT_DESCRIPTION%>"
        sortType="string"
        anchorClass="sortMenuItem"/>
    </th>

    <th width="5%">
      &nbsp;
    </th>
<%
	}
%>
  <framework:mapListItr mapList="<%=searchMaplist%>" mapName="templateMap">

    <tr class='<framework:swap id="1" first="odd" second="even" />'>

<%
	// Getting the ObjectIcon name from the type from Property file name
	

	    String objectIcon ="";
        String alias = FrameworkUtil.getAliasForAdmin(context,"type",
        		(String)templateMap.get(DomainConstants.SELECT_TYPE),true);

        
        try{
            objectIcon  = FrameworkProperties.getProperty(alias + ".SmallIcon");
          }catch(Exception e)
          {
          }

        // Setting default Icon if no icon found for type in Properties file
        // for pariculat type
        //
        if (objectIcon==null|| objectIcon.equals("null")||objectIcon.length()<1)
        {
           objectIcon  = FrameworkProperties.getProperty("type_Default.SmallIcon");
        }


	// Getting object Id and Internationalized Type
	String objectId = (String) templateMap
			.get(DomainConstants.SELECT_ID);
	// Graying out if any of there case fails Its Locked,Relevent access is not
	// there and Its already Added(addedList) in case of AddChildren and Chooser

        String paramName; 
        //MUT R217 NameMappingRemoval Migration
        if(com.matrixone.vplm.m1mapping.MappingManager.nameMapping())
        // old names
        {
            paramName=(String)templateMap.get("attribute[VPLMatt/PLMEntity/PLM_ExternalID]");
        }
        else
        // new names
        {
           paramName=(String)templateMap.get("attribute[PLMEntity.PLM_ExternalID]" );
        }
        //MUT R217 NameMappingRemoval Migration
%>
    <th width="5%">
      <table>
        <tr>
          <td align="center">
            <input type="checkbox" name="emxTableRowId" id="emxTableRowId" onclick="updateCheck()" value="<%=objectId%>" />
          </td>
        </tr>
      </table>
    </th>

      <td >
        <table border="0">
          <tr>
    	       <td valalign="top"><img src="../common/images/<%=objectIcon%>" border="0" /></td>
               <td class="object"><%=paramName%></td>
              <input type="hidden" name="hiddenname" value="<%=paramName%>" />
            </tr>
          </table>
      </td>

       <td><%=templateMap.get(DomainConstants.SELECT_DESCRIPTION)%>&nbsp;</td>

      <td><a href ="javascript:showDetailsPopUp('<%=objectId%>')"><img src="./images/iconNewWindow.gif" border="0" alt="emxDocumentCentral.Common.OpenNew" ></a>&nbsp;</td>

    </tr>
  </framework:mapListItr>
  </table>


<script language="javascript" type="text/javaScript">//<![CDATA[
  <!-- hide JavaScript from non-JavaScript browsers
  //---------Fucntion on cancel Button-------------------
  function close()
  {
    parent.window.close();
  }

  //---------Fucntion on New Search Action Link-------------------
  function newSearch()
  {
	top.location.href = "<%=sreturnSearchFramesetEncoded%>";
  }

  //Function when search is used as chooser(single/multiple)
  //Javascript based writing if single select else callling search prosess jsp
  //in case of multiselect

  var resultsArray=new Array();

  function select()
  {
    alert("Select");
  	if("<%=selectOption%>"=="single")
    {
      var count =0;
      var objForm = document.forms[0];
      var checked ="false";

     //--At least one checkbox checked

      for (var i=1; i < objForm.elements.length; i++)
      {
           alert("Select loop");
         if (objForm.elements[i].name.indexOf('emxTableRowId') > -1 && objForm.elements[i].  checked==true)
        {
            alert("Select test");
          if(count==0)
          {
            resultsArray[count]=objForm.elements[i].value;
            resultsArray[count+1]=objForm.elements[i+1].value;
            count++;
            checked ="true";
          }
          //--------Message if in single selects multi-Items selected
          else
          {
            alert("SelectOnlyOneItem");
            return;
          }
        }
      }

      //If no CheckBox Selected

      if (checked == "false")
      {
        //---------If Search returns 0 results

          alert("SelectItem");
          return;
      }

      parent.window.opener.searchTypeId.value =resultsArray[count-1];
      parent.window.opener.searchTypeName.value =resultsArray[count] ;
      parent.window.close();
    }
  }

  // function checks or unchecks column of checkboxes associated
  // with table rows
  function doCheck()
  {

    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;

    for (var i=0; i < objForm.elements.length; i++)
    {
      if (objForm.elements[i].name.indexOf('emxTableRowId') > -1)
      {
        if(!objForm.elements[i].disabled)
        {
          objForm.elements[i].checked = chkList.checked;
        }
      }
    }
  }


  function updateCheck()
  {

    var objForm = document.forms[0];
    var chkList = objForm.chkList;
    var reChkName = /chkItem/gi;
  }

  // Function to open new window on clicking details Icon
  function showDetailsPopUp(objectID)
  {
    treeURl= "../common/emxTree.jsp?mode=insert&emxSuiteDirectory=documentcentral&objectId="+objectID;

    showNonModalDialog(treeURl,875,550,true);
  }

  // Opens details in tree view at Navigator frame
  function showDetails(objectID)
  {
    treeURl= "../common/emxTree.jsp?mode=insert&emxSuiteDirectory=documentcentral&objectId="+objectID;
    parent.window.opener.frames[1].frames[1].location=treeURl;
    //parent.window.close();
  }

  //--------------Refine search Action Link--------
  function refineSearch()
  {
    top.location.href = "<%=refineSearchUrlEncoded%>";
  }


  // Checks for at least 1 checkbox checked else appropriate message
  function isChecked()
  {
    var objForm = document.forms[0];
    var checked ="false";

    for (var i=0; i < objForm.elements.length; i++)
    {
      if (objForm.elements[i].name.indexOf('emxTableRowId') > -1 && objForm.elements[i].  checked==true)
      {
        checked ="true";
      }
    }

    if(checked=="false")
    {
    
        alert("SelectItem");
        return false;
    }

    return checked;
  }


  // Function for Add selectedcase,The form is submitted to addcontents--
  function addChild()
  {
    if(isChecked()=="true")
    {
     if("<%=strUseMode%>" == "classifiedItems"){
		     document.frmMain.action="emxSynchronizeWithVPLMDialogFS.jsp?GET_FROM_CATALOG=1&titleKey=emxVPMCentral.Catalog.Command.GetFromCatalog.Title";
    	  }
	  
      if(jsDblClick())
      {
        document.frmMain.submit();
      }
    }
    else
    {
      return;
    }
  }
    
   

    
 //Stop hiding here -->//]]>
</script>
</form>
<%@ include file = "../emxUICommonEndOfPageInclude.inc" %>

