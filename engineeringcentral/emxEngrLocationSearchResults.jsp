<%--  emxEngrLocationSearchResults.jsp  -  Search results summary page for Location search
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@ include file = "emxDesignTopInclude.inc"%>
<%@ include file = "emxEngrVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>

<%@ page import="com.matrixone.apps.common.Person" %>
<%@ page import="com.matrixone.apps.common.Company" %>


<%

    String rowselect = emxGetParameter(request,"rowselect");
    boolean selectable = true;

    String isAVLReport = emxGetParameter(request,"isAVLReport");
    if(isAVLReport == null)
    {
        isAVLReport = "FALSE";
    }

    if(!"TRUE".equals(isAVLReport) && !"FALSE".equals(isAVLReport)) 
    {
        isAVLReport = "FALSE";
    }

    if(rowselect == null || "".equals(rowselect) || "null".equalsIgnoreCase(rowselect) )
    {
        rowselect = "multi";
    } 

   // Added for MCC EC Interoperability Feature
   String sFieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
   String sFieldNameId = emxGetParameter(request,"fieldNameId");
   String sSelManufacturerId = emxGetParameter(request,"manufacturerId");
   String sFormName = emxGetParameter(request,"formName");
   String isManufacturingLocation = emxGetParameter(request,"isManufacturingLocation");
   // Modified for Bug No:329148 - Start
   String checkFromConnectAccess = emxGetParameter(request,"checkFromConnectAccess");
   // Modified for Bug No:329148 - End
   String relWhere = "";
   //end
   if(sFieldNameDisplay == null || "null".equals(sFieldNameDisplay) || "".equals(sFieldNameDisplay))
		sFieldNameDisplay = (String)session.getAttribute("fieldNameDisplay");
    try
    {
        //removing from session
        session.removeAttribute("rowselect");
        session.removeAttribute("isAVLReport");

         // Added for MCC EC Interoperability Feature
         session.removeAttribute("fieldNameDisplay");
         session.removeAttribute("fieldNameId");
         session.removeAttribute("manufacturerId");
         session.removeAttribute("formName");
		 session.removeAttribute("isMepLocation");
         //end 
    }
    catch(Exception ex)
    {
        //do nothing......catching IllegalStateException
    }

    Person person = (Person)DomainObject.newInstance(context, DomainConstants.TYPE_PERSON);
    String hostCompany    = person.getPerson(context).getCompany(context).getName(context);

    String languageStr      = request.getHeader("Accept-Language");
    String suiteKey         = emxGetParameter(request,"suiteKey");
    String selectType       = emxGetParameter(request, "typename");
	String isMepLocation    = emxGetParameter(request, "isMepLocation");
    
    String strDefaultType = "ENCGeneralLocation";

    if("Company".equals(selectType))
    {
        strDefaultType = "ENCFindCompany";
    }
    else if("Organization".equals(selectType))
    {
        strDefaultType = "ENCFindOrganization";
    }
    else if("Business Unit".equals(selectType))
    {
        strDefaultType = "ENCFindBusinessUnit";
    }
    else if("Department".equals(selectType))
    {
        strDefaultType = "ENCFindDepartment";
    }
    else if("Location".equals(selectType))
    {
        strDefaultType = "ENCFindLocation";
    }

    String txtName          = emxGetParameter(request, "txtLocName");

    if (txtName == null || txtName.equalsIgnoreCase("null") || txtName.length() <= 0)
    {
        txtName = "*";
    }

    // Get the user's vault option & call corresponding methods to get the vault's.
    String txtVault   ="";
    String strVaults  ="";
    boolean strList   =false;
    boolean maplist   =false;
    StringList strListVaults  =new StringList();
    MapList maplst            = new MapList();

    String txtVaultOption = emxGetParameter(request, "vaultOption");
//317241
    Company company = person.getPerson(context).getCompany(context);
//end

    if(txtVaultOption==null)
    {
        txtVaultOption="";
    }
    if(vaultAwarenessString.equalsIgnoreCase("true"))
    {
        if(txtVaultOption.equals("ALL_VAULTS"))
        {
            strListVaults = person.getPerson(context).getCollaborationPartnerVaults(context,null);
            strList=true;
        }
        else if(txtVaultOption.equals("LOCAL_VAULTS"))
        {
            strVaults = company.getLocalVaults(context);
            if(strVaults.indexOf(',')>0)
            {
                StringTokenizer sVaults = new StringTokenizer(strVaults,",");
                if(sVaults.hasMoreTokens())
                {
                    strVaults = sVaults.nextToken();
                }
                while(sVaults.hasMoreTokens())
                {
                    strVaults += "," + sVaults.nextToken();
                }
            }
            txtVault=strVaults;
        }
        else if (txtVaultOption.equals("DEFAULT_VAULT"))
        {
            txtVault = context.getVault().getName();
        }
        else
        {
            txtVault = txtVaultOption;
        }
    }
    else
    {
        if(txtVaultOption.equals("ALL_VAULTS"))
        {
            maplst = VaultUtil.getVaults(context);
            maplist=true;
        }
        else if(txtVaultOption.equals("LOCAL_VAULTS"))
        {
            // get All Local vaults 
            strListVaults = OrganizationUtil.getLocalVaultsList(context, company.getObjectId());
            strList=true;
        }
        else if (txtVaultOption.equals("DEFAULT_VAULT"))
        {
            txtVault = context.getVault().getName();
        }
        else
        {
            txtVault = txtVaultOption;
        }
    }

    // Iterate the StringList & store it in a string as comma separated values.
    if(strList)
    {
        StringItr strItr = new StringItr(strListVaults);
        if(strItr.next())
        {
            strVaults =strItr.obj();
        }
        while(strItr.next())
        {
            strVaults += "," + strItr.obj();
        }
        txtVault=strVaults;
    }
    // Iterate the maplist & store it in a string as comma separated values.
    if(maplist)
    {
        Iterator mapItr = maplst.iterator();
        if(mapItr.hasNext())
        {
            Map map = (Map)mapItr.next();
            strVaults =(String)map.get("name");
        }
        while (mapItr.hasNext())
        {
            Map map = (Map)mapItr.next();
            strVaults += "," + (String)map.get("name");
        }
        txtVault=strVaults;
    }
    String queryLimit = emxGetParameter(request,"QueryLimit");

    if (queryLimit == null || queryLimit.equals("null") || queryLimit.equals(""))
    {
        queryLimit = "0";
    }

    String whereClause = "";

    // Get default icon for type
    String defaultTypeIcon    = JSPUtil.getCentralProperty(application, session, "type_Default", "SmallIcon");

    MapList totalresultList   = null;
    String queryString = emxGetQueryString(request);
    boolean hasFromConnectAccess=false;

    //Declare display variables
    String objectName   = null;
    String typeIcon     = null;

    SelectList resultSelects = new SelectList(7);
    resultSelects.add(DomainObject.SELECT_ID);
    resultSelects.add(DomainObject.SELECT_TYPE);
    resultSelects.add(DomainObject.SELECT_NAME);
    resultSelects.add(DomainObject.SELECT_DESCRIPTION);
    resultSelects.add("current.access[fromconnect]");
    /* EC-MCC interop */
    String attrPlantId   = PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_attribute_PlantID);
    resultSelects.add(DomainObject.getAttributeSelect(attrPlantId));
    /* EC-MCC interop */

    // Determine if we should use printer friendly version
    boolean isPrinterFriendly = false;
    String printerFriendly    = emxGetParameter(request, "PrinterFriendly");

    if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly))
    {
        isPrinterFriendly = "true".equals(printerFriendly);
    }
//bug 317241
       String objectId    = company.getId();

       String strRelLocation = "*";
       String strTypeLocation = "*";

        SelectList busSelects = new SelectList(1);
        busSelects.add(DomainConstants.SELECT_ID);
        busSelects.add(DomainConstants.SELECT_TYPE);
        busSelects.add(DomainConstants.SELECT_NAME);
        busSelects.add(DomainConstants.SELECT_DESCRIPTION);
        busSelects.add("current.access[fromconnect]");

        SelectList relSelects = new SelectList(1);
        relSelects.add( DomainConstants.SELECT_RELATIONSHIP_ID );

       String sWhereExp=null;
        if (!"*".equals(txtName))
        {
                sWhereExp = " name ~~ \""+txtName+"\" ";
        }

    //set the type & relationship names as per individual search
    if("Company".equals(selectType))
    {
        strRelLocation = DomainConstants.RELATIONSHIP_SUBSIDIARY;
        //strTypeLocation = DomainConstants.TYPE_COMPANY;
    }
        else if("Organization".equals(selectType))
    {
        strTypeLocation = DomainConstants.TYPE_ORGANIZATION;
    }
    else if("Business Unit".equals(selectType))
    {
        strRelLocation = DomainConstants.RELATIONSHIP_DIVISION;
        //strTypeLocation = DomainConstants.TYPE_BUSINESS_UNIT;
    }
   else if("Department".equals(selectType))
    {
        strRelLocation = DomainConstants.RELATIONSHIP_COMPANY_DEPARTMENT;
    }
    else if("Location".equals(selectType))
    {
        strRelLocation = DomainConstants.RELATIONSHIP_ORGANIZATION_LOCATION;
        /* EC-MCC Interop*/
        if(isManufacturingLocation != null && "Yes".equalsIgnoreCase(isManufacturingLocation)) {
            String attrManufacturingSite = PropertyUtil.getSchemaProperty(context,DomainSymbolicConstants.SYMBOLIC_attribute_ManufacturingSite);
            relWhere = DomainObject.getAttributeSelect(attrManufacturingSite) +" == Yes";
        }
   }


   // Added for MCC EC Interoperability Feature
   if(sSelManufacturerId != null &&  !"null".equalsIgnoreCase(sSelManufacturerId) && !"".equals(sSelManufacturerId)) 
   {
        String relPattern    = PropertyUtil.getSchemaProperty(context,"relationship_OrganizationLocation");
        String typePattern = PropertyUtil.getSchemaProperty(context,"type_Location");
        if(txtVaultOption.equals("ALL_VAULTS"))
        {
          txtVault="Vault ~= const\"*\"";
           //(Vault==\"eService Production\" || Vault== \"AEF NonHost1 Vault1\")
        }
        else if(txtVaultOption.equals("LOCAL_VAULTS"))
        {
           // Iterate the StringList & store it in a string as || separated values.
           if(txtVault.indexOf(',')>0)
           {
                StringTokenizer sVaults = new StringTokenizer(txtVault,",");
                if(sVaults.hasMoreTokens())
                {
                    
                    strVaults ="(Vault==\""+sVaults.nextToken()+"\"";
                }
                while(sVaults.hasMoreTokens())
                {
                    strVaults += "|| Vault==\"" + sVaults.nextToken()+"\"";
                }
                txtVault=strVaults+")" ;
           }
           else
           {
              txtVault="Vault ==\""+txtVault+"\"" ;
           }
        }
        else
        {
          txtVault="Vault ==\""+txtVault+"\"" ;
        }
        
        whereClause = "name ~= const\""+txtName+"\" && "+txtVault+"";
        
        // get only active locations
        whereClause += " && current == \"" + PropertyUtil.getSchemaProperty(context,"policy",DomainObject.POLICY_LOCATION,"state_Active") +"\"" ;

        //matrix.db.BusinessObject busObj = new matrix.db.BusinessObject(sSelManufacturerId.trim());
        DomainObject busObj = new DomainObject(sSelManufacturerId.trim());
        boolean closeConnection = false;

        if (busObj.isOpen() == false)
        {
        busObj.open(context);
        closeConnection = true;
        }

		matrix.db.ExpansionIterator expSelect = busObj.getExpansionIterator(context, relPattern, typePattern,
		        resultSelects, new matrix.util.SelectList(), true, true, (short)1,
		        whereClause, relWhere, Short.parseShort(queryLimit),
            false, false, (short)0, false);
        // Close the object, if necessary.
        if (closeConnection)
        {
        busObj.close(context);
        }
        
        MapList returnMapList = null;
        com.matrixone.apps.domain.util.ContextUtil.startTransaction(context, false);
        try {        	        
            returnMapList = com.matrixone.apps.domain.util.FrameworkUtil.toMapList(expSelect,(short)0, null, null, null, null);
            com.matrixone.apps.domain.util.ContextUtil.commitTransaction(context);
        } catch (Exception e) {
        	com.matrixone.apps.domain.util.ContextUtil.abortTransaction(context);
        	throw e;
        }

        Map finalMap = null;
        //the following code is not to generate classcast exception 
        int size = returnMapList.size();
        totalresultList=new MapList();
        for(int i=0;i<size;i++)
        {
         finalMap = null;
         finalMap = (Map) returnMapList.get(i);
         
         String strListValue = (String)finalMap.get(DomainConstants.SELECT_ID);
         finalMap.put(DomainConstants.SELECT_ID,strListValue);
         
         strListValue = (String)finalMap.get(DomainObject.SELECT_TYPE);
         finalMap.put(DomainObject.SELECT_TYPE,strListValue);
         
         strListValue = (String)finalMap.get(DomainObject.SELECT_NAME);
         finalMap.put(DomainObject.SELECT_NAME,strListValue);

         strListValue = (String)finalMap.get(DomainObject.SELECT_DESCRIPTION);
        finalMap.put(DomainObject.SELECT_DESCRIPTION,strListValue);

         strListValue = (String)finalMap.get("current.access[fromconnect]");
         finalMap.put("current.access[fromconnect]",strListValue);
         //Constructing MapList needed for sorting
         totalresultList.add(finalMap);
        }
         
    }
    else
    {  // End for MCC EC Interoperability Feature

        totalresultList = company.getRelatedObjects(context,
                                         strRelLocation,     // relationship pattern
                                         strTypeLocation,                    // object pattern
                                         busSelects,                 // object selects
                                         relSelects,              // relationship selects
                                         false,                       // to direction
                                         true,                        // from direction
                                         (short) 1,                   // recursion level
                                         sWhereExp,                        // object where clause
                                         relWhere);                       // relationship where clause
    }
//end for bug 317241
%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%@include file = "emxengchgJavaScript.js" %>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript">

    function newSearch()
    {
<%
     //Added for MCC EC Interoperability Feature
     String URL ="";
	 //R
     if(sSelManufacturerId != null &&  !"null".equalsIgnoreCase(sSelManufacturerId) && !"".equals(sSelManufacturerId)) 
     {
       URL = "../common/emxSearch.jsp?typename="+selectType+"&toolbar=ENCSearchCompanyLocationToolbar&title=Location&rowselect="+rowselect+"&manufacturerId="+sSelManufacturerId+"&fieldNameDisplay="+sFieldNameDisplay+"&fieldNameId="+sFieldNameId+"&formName="+sFormName+"&isManufacturingLocation="+isManufacturingLocation + "&checkFromConnectAccess="+checkFromConnectAccess+"&isMepLocation="+isMepLocation; 

     }
     else
     { //end
        URL = "../common/emxSearch.jsp?defaultSearch="+strDefaultType+"&typename="+selectType+"&toolbar=ENCFindLocationsToolBar&rowselect="+rowselect+"&isAVLReport="+isAVLReport+"&isManufacturingLocation="+isManufacturingLocation+"&checkFromConnectAccess="+checkFromConnectAccess+"&isMepLocation="+isMepLocation+"&fieldNameDisplay="+sFieldNameDisplay;
     }
%>
//XSSOK
        getTopWindow().location="<%=XSSUtil.encodeForJavaScript(context,URL)%>";
    }


    function addToCollection()
    {
        var bool=false;
        var selectedItems = new Array;
        var selectCount = 0;

        for (var i = 0; i<document.formDataRows.elements.length; i++)
        {
            if(document.formDataRows.elements[i].name == "emxTableRowId" &&
                document.formDataRows.elements[i].checked == true)
            {
                bool=true;
                var temp = document.formDataRows.elements[i].value;
                selectedItems[selectCount] = temp;
                selectCount++;
            }
        }//end of for

        if(bool)
        {
            document.formDataRows.target = "_top";
            document.formDataRows.action = "../common/emxCollectionsSelectCreateDialogFS.jsp";
            document.formDataRows.submit();
        }
        else
        {
            alert("<emxUtil:i18nScript localize="i18nId" >emxEngineeringCentral.Common.PleaseMakeASelection</emxUtil:i18nScript>");
        }

    }//end of addToCollection()

    function close()
    {
        getTopWindow().closeWindow();
    }

    function selectDone()
    {
        var newLocationIds = '';
        var bool=false;
        var count=0;
        for (var i = 0; i<document.formDataRows.elements.length; i++)
        {
<%
            if(rowselect.equals("single") )
            {
%>
                if(document.formDataRows.elements[i].type == "radio")
                {

                    if(document.formDataRows.elements[i].checked == true)
                    {
                        bool=true;
                        var temp = document.formDataRows.elements[i].value;
                        var temp1 = eval('document.formDataRows.fieldName' + count + '.value');
                        /* EC-MCC interop */
                        var plantId = eval('document.formDataRows.fieldPlantId' + count + '.value');
                        break;
                    }
                    count++;
                }

<%
            }
            else if(rowselect.equals("multi") )
            {
%>
                if(document.formDataRows.elements[i].type == "checkbox")
                {
                    if(document.formDataRows.elements[i].name == "emxTableRowId" &&
                        document.formDataRows.elements[i].checked == true)
                    {
                        bool=true;
                        var temp =document.formDataRows.elements[i].value;
                        newLocationIds = newLocationIds + temp + "|";
                        count++;
                    }
                }
<%
            }
%>

        }//end of for


        if(!bool)
        {
            alert("<emxUtil:i18nScript localize="i18nId" >emxEngineeringCentral.Common.PleaseMakeASelection</emxUtil:i18nScript>");
        }
        else
        {
<%        
            if(rowselect.equals("single") ) 
            {
                //Added for MCC EC Interoperability Feature
                if(sSelManufacturerId != null &&  !"null".equalsIgnoreCase(sSelManufacturerId) && !"".equals(sSelManufacturerId)) 
                {
                   if(sFormName  != null && !"".equals(sFormName)  && !"null".equals(sFormName))
                   {
%>
                       eval("getTopWindow().getWindowOpener().document.forms['<xss:encodeForJavaScript><%=sFormName%></xss:encodeForJavaScript>'].<xss:encodeForJavaScript><%=sFieldNameDisplay%></xss:encodeForJavaScript>.value='"+temp1+"';");
                       eval("getTopWindow().getWindowOpener().document.forms['<xss:encodeForJavaScript><%=sFormName%></xss:encodeForJavaScript>'].<xss:encodeForJavaScript><%=sFieldNameId%></xss:encodeForJavaScript>.value='"+temp+"';");
<%                 }
                   else
                   {
%>                      getTopWindow().getWindowOpener().document.forms[0].<xss:encodeForJavaScript><%=sFieldNameDisplay%></xss:encodeForJavaScript>.value=temp1;
                        getTopWindow().getWindowOpener().document.forms[0].<xss:encodeForJavaScript><%=sFieldNameId%></xss:encodeForJavaScript>.value=temp;
<%                 }
%>
                   /* EC-MCC interop */
                   getTopWindow().getWindowOpener().setRevision(plantId);
                   /* EC-MCC interop */
<%
                }
                else
                {
					//Added to fix bug 327627
				   if(sFieldNameDisplay  != null && !"".equals(sFieldNameDisplay)  && !"null".equals(sFieldNameDisplay))

                   {
%>                  // end Added for MCC EC Interoperability Feature
				   getTopWindow().getWindowOpener().setLocation(temp,temp1);
<%
                   } 
				   if(isMepLocation != null &&  "true".equalsIgnoreCase(isMepLocation))  {
%>
				   temp = temp+"|";
                   getTopWindow().getWindowOpener().addLocations(temp);
<%
                    //end of bug fix 327627
                    }
                  }
            }
            else if(rowselect.equals("multi") ) 
            {
%>
                getTopWindow().getWindowOpener().addLocations(newLocationIds);
<%
            }
%>
            getTopWindow().closeWindow();
        }
    }//end of selectDone()

</script>

  <fw:sortInit
    defaultSortKey="<%= DomainObject.SELECT_NAME %>"
    defaultSortType="string"
    resourceBundle="emxEngineeringCentralStringResource"
    mapList="<%= totalresultList %>"
    params="<%= queryString %>"
    ascendText="emxEngineeringCentral.Common.SortAscending"
    descendText="emxEngineeringCentral.Common.SortDescending" />

<form name="formDataRows" method="post" action="">
  <table width="100%" border="0" cellpadding="3" cellspacing="2">
    <tr>
<%
          if (!isPrinterFriendly) {
            if (selectable) {
              if(rowselect.equals("multi") ) {
%>
                <th><input type="checkbox" name="checkAll" onClick="allSelected('formDataRows')" /></th>
<%
              } else {
%>
                <th>&nbsp;</th>
<%
              }
            }
          }
%>
      <th nowrap="nowrap">
      <!-- XSSOK -->
        <fw:sortColumnHeader
          title="emxEngineeringCentral.Common.Name"
          sortKey="<%= DomainObject.SELECT_NAME %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>

      <th nowrap="nowrap">
      <!-- XSSOK -->
        <fw:sortColumnHeader
          title="emxEngineeringCentral.Common.Type"
          sortKey="<%= DomainObject.SELECT_TYPE %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>

      <th nowrap="nowrap">
      <!-- XSSOK -->
        <fw:sortColumnHeader
          title="emxEngineeringCentral.Common.Description"
          sortKey="<%= DomainObject.SELECT_DESCRIPTION %>"
          sortType="string"
          anchorClass="sortMenuItem" />
      </th>
<%
      int i=0;
%>
<!-- XSSOK -->
      <fw:mapListItr mapList="<%= totalresultList %>" mapName="resultsMap">
<%
        objectName      = (String)resultsMap.get(DomainObject.SELECT_NAME);

%><!-- XSSOk -->
        <tr class='<fw:swap id="even"/>'>
<%
          // Get the alias name for this type.  If there is an icon defined in the
          // EC properties file for this alias, then use it.  Otherwise, use the
          // default icon
          // TODO!  This could be smarter by figuring out if we already have this icon
          //        by using some sort of cache.
          //
          String alias = FrameworkUtil.getAliasForAdmin(context, "type", (String)resultsMap.get(DomainObject.SELECT_TYPE), true);

          if ( (alias == null) || (alias.equals("null")) || (alias.equals("")) ){
            typeIcon = defaultTypeIcon;
          } else {
            typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
          }

          // Modified for Bug No:329148 - Start
          if(checkFromConnectAccess != null && "false".equalsIgnoreCase(checkFromConnectAccess))
          {
            hasFromConnectAccess = true;
          }
          else
          {
            hasFromConnectAccess = ((String) resultsMap.get("current.access[fromconnect]")).equalsIgnoreCase("true")?true:false;
          }
          // Modified for Bug No:329148 - End

          if (!isPrinterFriendly) {
            if(rowselect.equals("single") ) {
                if(hasFromConnectAccess) {
                  /*   EC-MCC InterOp   */
                  String plantId  = "";
                  try {
                      plantId  = (String)resultsMap.get("attribute["+attrPlantId+"]");
                  }catch(ClassCastException cce) {
                      StringList plantIdList = (StringList)resultsMap.get("attribute["+attrPlantId+"]");
                      plantId  = (String)plantIdList.elementAt(0);
                  }
                  /*   EC-MCC InterOp   */
%>
                  <td><input type="radio" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=(String)resultsMap.get(DomainObject.SELECT_ID) %></xss:encodeForHTMLAttribute>" /></td>
                  <input type="hidden" name="fieldId<%=i%>" value="<xss:encodeForHTMLAttribute><%=(String)resultsMap.get(DomainObject.SELECT_ID) %></xss:encodeForHTMLAttribute>" />
                  <input type="hidden" name="fieldName<%=i%>" value="<xss:encodeForHTMLAttribute><%=objectName %></xss:encodeForHTMLAttribute>" />
                 <!--  EC-MCC InterOp  -->
                  <input type="hidden" name="fieldPlantId<%=i%>" value="<xss:encodeForHTMLAttribute><%=plantId %></xss:encodeForHTMLAttribute>" />
                  <!--  EC-MCC InterOp  -->

<%
                  i++;
                }else{
%>
                   <td><img src="../common/images/utilRadioOffDisabled.gif" /></td>
<%
                }
            }else if(rowselect.equals("multi") ) {
                if(hasFromConnectAccess){

%>
                  <td><input type="checkbox" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=(String)resultsMap.get(DomainObject.SELECT_ID) %></xss:encodeForHTMLAttribute>" /></td>
                  <input type="hidden" name="fieldId<%=i%>" value="<xss:encodeForHTMLAttribute><%=(String)resultsMap.get(DomainObject.SELECT_ID) %></xss:encodeForHTMLAttribute>" />
                  <input type="hidden" name="fieldName<%=i%>" value="<xss:encodeForHTMLAttribute><%=objectName %></xss:encodeForHTMLAttribute>" />

<%
                  i++;
                }else{
%>
                   <td><img src="../common/images/utilCheckOffDisabled.gif" /></td>
<%
                }


            }

          }
%>
		<!-- XSSOK -->
          <td><img src="../common/images/<%=typeIcon%>" border="0" /><xss:encodeForHTML><%=objectName%></xss:encodeForHTML>&nbsp;</td>
          <!-- XSSOK -->
          <td><%=i18nNow.getTypeI18NString((String)resultsMap.get(DomainObject.SELECT_TYPE),languageStr)%>&nbsp;</td>
          <!-- XSSOK -->
          <td><%=(String)resultsMap.get(DomainObject.SELECT_DESCRIPTION)%>&nbsp;</td>
        </tr>
    </fw:mapListItr>
<%
    if (totalresultList.size() == 0){
%>
      <tr class="even" ><td colspan="4" align="center" ><emxUtil:i18n localize="i18nId">emxEngineeringCentral.BasicSearch.TxtStatusNoResults</emxUtil:i18n></td></tr>
<%
    }
%>
  </table>
  <input type="hidden" name="txtName" value="<xss:encodeForHTMLAttribute><%=txtName%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="queryLimit" value="<xss:encodeForHTMLAttribute><%=queryLimit%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
</form>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
