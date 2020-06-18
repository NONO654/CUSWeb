<%--  emxpartOrganizationSearchResults.jsp  -  Search results summary page for main search
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

<%
    String languageStr      = request.getHeader("Accept-Language");
    String suiteKey         = emxGetParameter(request,"suiteKey");
    String selectType       = emxGetParameter(request, "searchtype");
    String attrOrgId               = PropertyUtil.getSchemaProperty(context, "attribute_OrganizationID");
    String attrCageCode            = PropertyUtil.getSchemaProperty(context, "attribute_CageCode");
    String compId = "";
   String customRevision = FrameworkProperties.getProperty(context, "emxManufacturerEquivalentPart.MEP.allowCustomRevisions");
   String uniqueIdentifier = FrameworkProperties.getProperty(context, "emxManufacturerEquivalentPart.MEP.UniquenessIdentifier");
    String searchMode = emxGetParameter(request, "searchMode");
    if (uniqueIdentifier != null)
    {
        uniqueIdentifier = uniqueIdentifier.trim();
    }
    if( customRevision == null)
    {
        customRevision = "false";
    }
    else
    {
        customRevision = customRevision.trim();
    }
    if (!"attribute_CageCode".equals(uniqueIdentifier) && !"Policy".equals(uniqueIdentifier) )
    {
        uniqueIdentifier = "attribute_OrganizationID";
    }
    String txtName          = emxGetParameter(request, "txtName");
    String role             = emxGetParameter(request, "role");
    if (txtName == null || txtName.equalsIgnoreCase("null") || txtName.length() <= 0)
    {
        txtName = "*";
    }
    String queryLimit = emxGetParameter(request,"queryLimit");
    if (queryLimit == null || queryLimit.equals("null") || queryLimit.equals("")){
        queryLimit = "0";
    }

    String sForm  = emxGetParameter(request,"form");
    String sField = emxGetParameter(request,"field");
    String sFieldId = emxGetParameter(request,"fieldId");
    String sFieldRev = emxGetParameter(request,"fieldRev");
    String srole = emxGetParameter(request,"role");
    String isPartEdit     = emxGetParameter(request,"isPartEdit");
    String objectId       = emxGetParameter(request,"objectId");
	String sWhereExp="";
    
    // Added for MCC EC Interoperability Feature
    String sFieldManufacturerLocationIdDisplay = emxGetParameter(request,"fieldManufacturerLocation");
    String sFieldManufacturerLocationId = emxGetParameter(request,"fieldManufacturerLocationId");
    //end 

    if(sFieldRev == null || "null".equals(sFieldRev)  )
    {
        sFieldRev = "";
    }
    if(isPartEdit == null || "null".equals(isPartEdit))
    {
        isPartEdit = "";
    }
    if(objectId == null || "null".equals(objectId))
    {
        objectId = "";
    }
    boolean isMep = false;
    if(!"".equals(objectId))
    {
        DomainObject domObj = new DomainObject(objectId);
        String strPolicyClassification = domObj.getInfo(context,"policy.property[PolicyClassification].value");
        if("Equivalent".equals(strPolicyClassification))
        {
            isMep = true;
        }
    }

    // Get default icon for type
    String defaultTypeIcon    = JSPUtil.getCentralProperty(application, session, "type_Default", "SmallIcon");

    MapList totalresultList   = null;
    String queryString = emxGetQueryString(request);
    boolean hasFromConnectAccess=false;


    //Declare display variables
    String objectName   = "";
    String typeIcon     = "";
    String code         ="";
    SelectList resultSelects = new SelectList(7);
    resultSelects.add(DomainObject.SELECT_ID);
    resultSelects.add(DomainObject.SELECT_TYPE);
    resultSelects.add(DomainObject.SELECT_NAME);
    resultSelects.add(DomainConstants.SELECT_CURRENT);
    resultSelects.add(DomainObject.SELECT_DESCRIPTION);
    resultSelects.add("attribute["+attrCageCode+"]");
    resultSelects.add("attribute["+attrOrgId+"]");
    resultSelects.add("current.access[fromconnect]");

    // Determine if we should use printer friendly version
    boolean isPrinterFriendly = false;
    String printerFriendly    = emxGetParameter(request, "PrinterFriendly");

    if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly)) {
        isPrinterFriendly = "true".equals(printerFriendly);
    }

    com.matrixone.apps.common.Person person = com.matrixone.apps.common.Person.getPerson(context);
    String vaultPattern = person.getCompany(context).getAllVaults(context, true);

    if(searchMode != null && searchMode.equals("Manufacturer"))
    {
        String manufacturerId=com.matrixone.apps.common.Company.getHostCompany(context);
        com.matrixone.apps.common.Company company =new  com.matrixone.apps.common.Company(manufacturerId);
        if(selectType.equals(PropertyUtil.getSchemaProperty(context, "type_BusinessUnit")))
        {
            if (!"*".equals(txtName))
            {
                sWhereExp = " name ~~ \""+txtName+"\" ";
                sWhereExp +=" && ";
            }
            sWhereExp += "current == Active";

            String srelPattern =   PropertyUtil.getSchemaProperty(context,"relationship_Division");
            totalresultList = company.getRelatedObjects(context,
                                         srelPattern,         //java.lang.String relationshipPattern,
                                         selectType,                 //java.lang.String typePattern,
                                         resultSelects,           //matrix.util.StringList objectSelects,
                                         null,                //matrix.util.StringList relationshipSelects,
                                         true,                //boolean getTo,
                                         true,               //boolean getFrom,
                                         (short)1,            //short recurseToLevel,
                                         sWhereExp,         //java.lang.String objectWhere,
                                         null);
        }
        else if(selectType.equals("Company"))
        {
            if (!"*".equals(txtName))
            {
                sWhereExp = " name ~~ \""+txtName+"\" ";
                sWhereExp +=" && ";
            }
            sWhereExp += "current == Active";
            totalresultList=company.getSuppliers(context,resultSelects, null,sWhereExp,null);
        }
    }
    else
    {

    if (role != null && !"null".equals(role) && !"".equals(role))
    {
        String srelPattern =   PropertyUtil.getSchemaProperty(context,"relationship_Member");
        SelectList busSelect = new SelectList(5);
        busSelect.add(DomainConstants.SELECT_ID);
        busSelect.add(DomainConstants.SELECT_TYPE);
        busSelect.add(DomainConstants.SELECT_NAME);
        busSelect.add(DomainConstants.SELECT_DESCRIPTION);
        busSelect.add("current.access[fromconnect]");
        SelectList relSelect = new SelectList(1);
        relSelect.add(DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_PROJECT_ROLE));
        
        if (!"*".equals(txtName))
        {
                sWhereExp = " name ~~ \""+txtName+"\" ";
        }


        MapList tempresultList=new MapList();
        totalresultList =  person.getRelatedObjects(context,
                                         srelPattern,         //java.lang.String relationshipPattern,
                                         selectType,                 //java.lang.String typePattern,
                                         busSelect,           //matrix.util.StringList objectSelects,
                                         relSelect,                //matrix.util.StringList relationshipSelects,
                                         true,                //boolean getTo,
                                         false,               //boolean getFrom,
                                         (short)1,            //short recurseToLevel,
                                         sWhereExp,         //java.lang.String objectWhere,
                                         null);               //java.lang.String relationshipWhere)
        for(int i=0; i< totalresultList.size() ; i++)
        {
            Map map= (Map)totalresultList.get(i);
            String projectRole= (String)map.get(DomainObject.getAttributeSelect(DomainConstants.ATTRIBUTE_PROJECT_ROLE));
            StringList roleSelected=FrameworkUtil.split(projectRole,"~");
            if (roleSelected.contains(role))
            { 
                tempresultList.add(map);
            }
        }
        
        totalresultList = tempresultList;
        tempresultList = null;
    }
    else 
    {
        String policyOrganization  =     PropertyUtil.getSchemaProperty(context, "policy_Organization");
 	String stateActive         =     FrameworkUtil.lookupStateName(context, policyOrganization , "state_Active");
        sWhereExp += "current == "+stateActive;
      //Added for RDO Convergence Start
        String sPersonId = person.getId();     	             	        	           	        	  
    	if(sWhereExp != null && !"".equals(sWhereExp)) {     		
    		sWhereExp += " && from["+DomainConstants.RELATIONSHIP_MEMBER+"|to.id=="+sPersonId+"]";
    		
    	} else {    	   	
    	   	sWhereExp = " from["+DomainConstants.RELATIONSHIP_MEMBER+"|to.id=="+sPersonId+"]";
    	}
    	//Added for RDO Convergence End
        
     totalresultList = DomainObject.findObjects(context,
                                                 selectType,
                                                 txtName,
                                                 "*",
                                                 "*",
                                                 "*",
                                                 sWhereExp, 
                                                 ".finder",
                                                 true,
                                                 resultSelects,
                                                 Short.parseShort(queryLimit));
    }
	}

	// Added for RCO
	if(session.getAttribute("CreateECR")!=null)
	{
		MapList RCOMapList = new MapList();
		
		Iterator mapListItrECR =  totalresultList.iterator();
		while(mapListItrECR.hasNext())
		{
			Map map = (Map) mapListItrECR.next();
			String id = (String) map.get(DomainConstants.SELECT_ID);
			String relName = PropertyUtil.getSchemaProperty(context,"relationship_LeadResponsibility");
			String plantName = PropertyUtil.getSchemaProperty(context,"type_Plant");
			DomainObject boObj = new DomainObject(id);
			MQLCommand mCmd = new MQLCommand();
			mCmd.executeCommand(context,"print bus $1 select $2",id,"relationship["+relName+"].attribute["+DomainConstants.ATTRIBUTE_PROJECT_ROLE+"]");
			String result = mCmd.getResult();
			if(result.contains("role_ECRCoordinator") && result.contains("role_ECRChairman") && !plantName.equals(boObj.getName()))
				RCOMapList.add(map);
		}
		
		totalresultList = RCOMapList;

	}


%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<script language="Javascript">

    function newSearch()
    {
<%
	String sURL = "";
	if(session.getAttribute("CreateECR")!=null)
	{
      sURL  = "emxpartRDOSearchDialogFS.jsp?form=" + sForm + "&field=" + sField + "&fieldId=" + sFieldId + "&fieldRev=" + sFieldRev + "&role="+srole+"&searchMode="+searchMode  +"&searchLinkProp=SearchRDOLinks&pageFlag=eServiceSearchLinkOrganization&CreateECR=true";
	}
	else
		{
			sURL  = "emxpartRDOSearchDialogFS.jsp?form=" + sForm + "&field=" + sField + "&fieldId=" + sFieldId + "&fieldRev=" + sFieldRev + "&role="+srole+"&searchMode="+searchMode  +"&searchLinkProp=SearchRDOLinks&pageFlag=eServiceSearchLinkOrganization";
		}

        if(sFieldManufacturerLocationId != null &&  !"null".equalsIgnoreCase(sFieldManufacturerLocationId) && !"".equals(sFieldManufacturerLocationId)) 
        {
           //Modified for the IR-026974 
           if(searchMode != null && searchMode.equals("Manufacturer")) 
                  sURL  = "emxpartRDOSearchDialogFS.jsp?form=" + sForm + "&field=" + sField + "&fieldId=" + sFieldId + "&fieldRev=" + sFieldRev + "&role="+srole+"&searchMode="+searchMode  +"&searchLinkProp=SearchOrgLinks&pageFlag=eServiceSearchLinkOrganization";
           sURL +="&fieldManufacturerLocation="+sFieldManufacturerLocationIdDisplay+"&fieldManufacturerLocationId="+sFieldManufacturerLocationId+"&searchMode="+searchMode;
           //IR-026974 ends
        }
		session.removeAttribute("CreateECR");
%>
//XSSOK
        parent.location="<%=XSSUtil.encodeForJavaScript(context,sURL)%>";
    }

    function selectDone()
    {
        var bool=false;
        //XSSOK
        var uniqueId="<%=uniqueIdentifier%>";
        //XSSOK
        var revision = "<%=customRevision%>";
        var temp2 = "";
        var id = false;
        var count=0;
        //XSSOK
        var isPartEdit = "<xss:encodeForJavaScript><%=isPartEdit%></xss:encodeForJavaScript>";
        //XSSOK
        var isMep = <%=isMep%>;

		try {
		parent.window.getWindowOpener().document.editDataForm.ResponsibleManufacturingEngineerDisplay.value = "";
		parent.window.getWindowOpener().document.editDataForm.ResponsibleManufacturingEngineerOID.value = "";
		parent.window.getWindowOpener().document.editDataForm.ResponsibleManufacturingEngineer.value = "";		
		parent.window.getWindowOpener().document.editDataForm.ResponsibleDesignEngineerDisplay.value = "";
		parent.window.getWindowOpener().document.editDataForm.ResponsibleDesignEngineerOID.value = "";
		parent.window.getWindowOpener().document.editDataForm.ResponsibleDesignEngineer.value = "";
			}catch(e)
		{
		}

		try {
		parent.window.getWindowOpener().document.editDataForm.RDEngineerDisplay.value = "";
		parent.window.getWindowOpener().document.editDataForm.RDEngineerOID.value = "";
		parent.window.getWindowOpener().document.editDataForm.RDEngineer.value = "";
		}catch(e)
		{
		}

		try {
		parent.window.getWindowOpener().document.editDataForm.ReviewersListDisplay.value = "";
		parent.window.getWindowOpener().document.editDataForm.ReviewersListOID.value = "";
		parent.window.getWindowOpener().document.editDataForm.ReviewersList.value = "";
		parent.window.getWindowOpener().document.editDataForm.DistributionListDisplay.value = "";
		parent.window.getWindowOpener().document.editDataForm.DistributionListOID.value = "";
		parent.window.getWindowOpener().document.editDataForm.DistributionList.value = "";
		parent.window.getWindowOpener().document.editDataForm.ApprovalListDisplay.value = "";
		parent.window.getWindowOpener().document.editDataForm.ApprovalListOID.value = "";
		parent.window.getWindowOpener().document.editDataForm.ApprovalList.value = "";
		}
		catch(e)
		{
		}

        for (var i = 0; i<document.formDataRows.elements.length; i++)
        {
              
            if(document.formDataRows.elements[i].type == "radio")
            {
                if(document.formDataRows.elements[i].checked == true)
                {
                    bool=true;
                    var temp = document.formDataRows.elements[i].value;
                    var temp1 = eval('document.formDataRows.fieldId' + count + '.value');

<%
                    if(!"".equals(sFieldRev))
                    {
  
%>
if(uniqueId == "attribute_OrganizationID")
                        {
                            temp2 = eval('document.formDataRows.fieldOrgId' + count + '.value');
                            id=true;
                        }
                        else if(uniqueId == "attribute_CageCode")
                        {
                            temp2 = eval('document.formDataRows.fieldCageCode' + count + '.value');
                            id=true;
                        }
<%
                    }
%>
                    break;
                }
                //ByPassing the count increment for greyed out results --049246V6R2011
                if (document.formDataRows.elements[i].value != "on")
                       count++;
            }
        }
        if(!bool)
        {
            alert("<emxUtil:i18nScript localize="i18nId" >emxEngineeringCentral.Common.PleaseMakeASelection</emxUtil:i18nScript>");
        }
        else
        {
<%
            //this revision check is added for mcc 
            if ( !"".equals(sFieldRev) && !("Revision".equals(sFieldRev)))
            {
 
%>
                if(id == true)
                {
                    if("true" == isPartEdit && isMep )
                    {
                        if(temp2.length == 0)
                        {
                            if("attribute_CageCode" == uniqueId)
                            {
                                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MEP.CageCodeEmpty</emxUtil:i18nScript>");
                                return;
                            }
                            else if("attribute_OrganizationID" == uniqueId)
                            {
                                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.MEP.CompanyIDEmpty</emxUtil:i18nScript>");
                                return;
                            }
                        }
                        else
                        { 
                           
                            /* EC-MCC interoperability */
                            parent.window.getWindowOpener().document.<xss:encodeForJavaScript><%=sForm%></xss:encodeForJavaScript>.<xss:encodeForJavaScript><%=sFieldRev%></xss:encodeForJavaScript>.value=temp2;  // = tempOrgId;
                            /* EC-MCC interoperability */
                        }
                    }
                    else
                    {
                       
                        /* EC-MCC interoperability */
                        parent.window.getWindowOpener().document.<xss:encodeForJavaScript><%=sForm%></xss:encodeForJavaScript>.<xss:encodeForJavaScript><%=sFieldRev%></xss:encodeForJavaScript>.value=temp2;
                        /* EC-MCC interoperability */
                    }
                }
<%
            } else if( !"".equals(sFieldRev)) {
            /* EC-MCC interoperability */
%>
             parent.window.getWindowOpener().document.<xss:encodeForJavaScript><%=sForm%></xss:encodeForJavaScript>.<xss:encodeForJavaScript><%=sFieldRev%></xss:encodeForJavaScript>.value=temp2;
<%
            /* EC-MCC interoperability */
            }

%>
//added for the bug 319308
var sfrm = "<xss:encodeForJavaScript><%=sForm%></xss:encodeForJavaScript>";
var sfld = "<xss:encodeForJavaScript><%=sField%></xss:encodeForJavaScript>";
var sfldId = "<xss:encodeForJavaScript><%=sFieldId%></xss:encodeForJavaScript>";



              parent.window.getWindowOpener().document.forms[sfrm].elements[sfld].value = temp;

            parent.window.getWindowOpener().document.forms[sfrm].elements[sfldId].value=temp1;
//Till here
<%
            // Added for MCC EC Interoperability Feature.Reset the Manufacturer Location field value
            if(sFieldManufacturerLocationId != null &&  !"null".equalsIgnoreCase(sFieldManufacturerLocationId) && !"".equals(sFieldManufacturerLocationId)) 
            {
%>
                parent.window.getWindowOpener().document.<xss:encodeForJavaScript><%=sForm%></xss:encodeForJavaScript>.<xss:encodeForJavaScript><%=sFieldManufacturerLocationIdDisplay%></xss:encodeForJavaScript>.value="";
                parent.window.getWindowOpener().document.<xss:encodeForJavaScript><%=sForm%></xss:encodeForJavaScript>.<xss:encodeForJavaScript><%=sFieldManufacturerLocationId%></xss:encodeForJavaScript>.value="";     
<%       
            }
%>
            getTopWindow().closeWindow();
        }
    }

</script>
 <script language="Javascript">
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
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
  <table class="list">
    <tr>
      <th>&nbsp;</th>
      <th nowrap="nowrap">
      <!-- XSSOK -->
        <fw:sortColumnHeader
          title="emxEngineeringCentral.Common.Name"
          sortKey="<%= DomainObject.SELECT_NAME %>"
          sortType="string"/>
      </th>

      <th nowrap="nowrap">
       <!-- XSSOK -->
        <fw:sortColumnHeader
          title="emxEngineeringCentral.Common.Type"
          sortKey="<%= DomainObject.SELECT_TYPE %>"
          sortType="string"/>
      </th>

      <th nowrap="nowrap">
      <!-- XSSOK -->
        <fw:sortColumnHeader
          title="emxEngineeringCentral.Common.Description"
          sortKey="<%= DomainObject.SELECT_DESCRIPTION %>"
          sortType="string"/>
      </th>
    <%if(searchMode != null && searchMode.equals("Manufacturer"))
    {%>
        <th nowrap="nowrap">
	<!-- XSSOK -->
        <fw:sortColumnHeader
          title="emxEngineeringCentral.Common.State"
          sortKey="<%= DomainObject.SELECT_CURRENT %>"
          sortType="string"/>
      </th>
    <%}%>


<%
      int i=0;
%>
	<!-- XSSOK -->
      <fw:mapListItr mapList="<%= totalresultList %>" mapName="resultsMap">
<%
        objectName      = (String)resultsMap.get(DomainObject.SELECT_NAME);

%>
        <!-- XSSOK -->
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

          hasFromConnectAccess = ((String) resultsMap.get("current.access[fromconnect]")).equalsIgnoreCase("true")?true:false;
          if (!isPrinterFriendly) {
            if(hasFromConnectAccess){
%>
              <td><input type="radio" name="radio" value="<%=objectName %>" /></td>
              <input type="hidden" name="fieldId<%=i%>" value="<xss:encodeForHTMLAttribute><%=(String)resultsMap.get(DomainObject.SELECT_ID)%></xss:encodeForHTMLAttribute>" />
              <input type="hidden" name="fieldCageCode<%=i%>" value="<xss:encodeForHTMLAttribute><%=(String)resultsMap.get("attribute["+attrCageCode+"]")%></xss:encodeForHTMLAttribute>" />
              <input type="hidden" name="fieldOrgId<%=i%>" value="<xss:encodeForHTMLAttribute><%=(String)resultsMap.get("attribute["+attrOrgId+"]")%></xss:encodeForHTMLAttribute>" />

<%
            i++;
            }else{

%>
              <td><input type="radio" name="radio" disabled="true" /></td>
<%
            }
          }
%>

          <td><img src="../common/images/<%=typeIcon%>" border="0" /><xss:encodeForHTML><%=objectName%></xss:encodeForHTML>&nbsp;</td>
          <!-- XSSOK -->
          <td><%=i18nNow.getTypeI18NString((String)resultsMap.get(DomainObject.SELECT_TYPE),languageStr)%>&nbsp;</td>
          <!-- XSSOK -->
          <td><%=(String)resultsMap.get(DomainObject.SELECT_DESCRIPTION)%>&nbsp;</td>
    <%if(searchMode != null && searchMode.equals("Manufacturer"))
    {%>
    		<!-- XSSOK -->
          <td><%=(String)resultsMap.get(DomainObject.SELECT_CURRENT)%>&nbsp;</td>
    <%}%>

        </tr>
    </fw:mapListItr>
<%
    if (totalresultList.size() == 0){
%>
      <tr class="even" ><td colspan="5" align="center" ><emxUtil:i18n localize="i18nId">emxEngineeringCentral.BasicSearch.TxtStatusNoResults</emxUtil:i18n></td></tr>
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

