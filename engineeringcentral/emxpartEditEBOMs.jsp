<%--  emxpartEditEBOMs.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "emxengchgValidationUtil.js"%>
<%@include file = "emxengchgJavaScript.js"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
  <%@include file = "../common/emxUIConstantsInclude.inc"%>
  <script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>

<%
  String languageStr              = request.getHeader("Accept-Language");
  String strObjectId              = emxGetParameter(request,"objectId");
  String removalFlag              = emxGetParameter(request,"removalFlag");
  String timeStamp                = emxGetParameter(request,"timeStamp");
  int totalSelParts               = 0;
  String SelEbomIds               = (String)session.getAttribute("SelEbomIds");
  Map finalRestoreMap             = (Map)session.getAttribute("finalRestoreMap");
  Map finalremovalMap             = (Map)session.getAttribute("finalremovalMap");
  String partType                 = DomainObject.TYPE_PART;

  //Declare display variables
  String objectId                 = "";
  String objectType               = "";
  String objectName               = "";
  String objectRev                = "";
  String objectDesc               = "";
  String objectState              = "";
  String objectOwner              = "";
  String srelId                   = "";
  String txtName                  = "";
  String txtRev                   = "";
  String txtDisplay               = "";
  String txtValue                 = "";
  double tz                       = (new Double((String)session.getAttribute("timeZone"))).doubleValue();
  removalFlag                     = (removalFlag==null)?"":removalFlag;
  finalRestoreMap                 = (finalRestoreMap==null)?new HashMap():finalRestoreMap;
  finalremovalMap                 = (finalremovalMap==null)?new HashMap():finalremovalMap;

  Part domObj = (Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  domObj.setId(strObjectId);

  StringTokenizer stringTokenizer = new StringTokenizer(SelEbomIds, ",");
  totalSelParts=stringTokenizer.countTokens();
  SelectList resultSelects = new SelectList(9);
  resultSelects.add("to."+DomainObject.SELECT_ID);
  resultSelects.add("to."+DomainObject.SELECT_TYPE);
  resultSelects.add("to."+DomainObject.SELECT_NAME);
  resultSelects.add("to."+DomainObject.SELECT_REVISION);
  resultSelects.add("to."+DomainObject.SELECT_DESCRIPTION);
  resultSelects.add("to."+DomainObject.SELECT_CURRENT);
  resultSelects.add("to."+DomainObject.SELECT_OWNER);
  resultSelects.add("to."+DomainObject.SELECT_ATTRIBUTE_UNITOFMEASURE);
  resultSelects.add("id");
  resultSelects.addElement("to."+"policy");

  // storing the relationship id in an array
  String[] RelIdArray = new String[totalSelParts];
  int counter=0;
  while(stringTokenizer.hasMoreTokens())
  {
    RelIdArray[counter] = stringTokenizer.nextToken().trim();
    counter++;
  }

  // Performance Improvement:
  // Get the Attribute information for one of the ebom rels.  All data information
  // is the same for all attributes except the values, which are fetched with the getInfo call
  String key0;
  String attrName0;
  // map to store the details of the relationship attributes.
  Map attDetailsMap  = null;

  // if no eboms, just get attribute info for headers.
  if (counter > 0)
  {
      // need to call getAttributeDetails in order to fetch multiline value
      DomainRelationship relation = DomainRelationship.newInstance(context,RelIdArray[0]);
      attDetailsMap = relation.getAttributeDetails(context);

      Iterator itr = null;

      // Included this condition to avoid Null Pointer exception
      if(attDetailsMap != null) {
        itr = attDetailsMap.keySet().iterator();
        while(itr.hasNext())
        {
          key0 = (String) itr.next();
          Map mapinfo = (Map) attDetailsMap.get(key0);
          attrName0 = (String)mapinfo.get("name");
          resultSelects.add("attribute["+attrName0+"]");
        }
      }
  }
  else
  {
      attDetailsMap = DomainRelationship.getTypeAttributes(context,DomainConstants.RELATIONSHIP_EBOM);
  }


  // get the attribute details of the EBOM Relationship
  MapList resultList  = DomainRelationship.getInfo(context, RelIdArray,resultSelects );

  //Determine if we should use printer friendly version
  boolean isPrinterFriendly = false;
  String printerFriendly = emxGetParameter(request, "PrinterFriendly");

  if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly)) {
    isPrinterFriendly = "true".equals(printerFriendly);
  }
%>

<script language="javascript">
  var fnPropertyArray = new Array();
  var rdPropertyArray = new Array();
  //abstracts be selected
  var bAbstractSelect = false;
  // Allow multiselect
  var bMultiSelect = false;
  var bReload = false;
  //Types to be passed
  //XSSOK
  var arrTypes = new Array("<%=partType%>|<%=i18nNow.getTypeI18NString(partType,languageStr)%>");
  //specify the place to return the string AS A STRING...
  var strTxtType = "document.forms['editForm'].type";
  var txtType = null;
  var strTxtTypeDisp = "document.forms['editForm'].typeDisp";
  var txtTypeDisp = null;
  var btnName = null;
  var val     = null;
  var modified = false;
  //to check the checkbox if only date field is modified .
  function checkDateFields()
  {
     var elementsSize = document.editForm.elements.length;
     var isDateField;
     var elementName="";
     var elementPos;
     for(var i=0;i<elementsSize;i++)
     {
         elementName=document.editForm.elements[i].name;
         if(elementName.indexOf("hid_")!=0)
         {
            isDateField = elementName.indexOf('Date');
            if(isDateField>0)
            {
                elementPos = elementName.substring(isDateField+4,elementName.length);
                dateChangeCheck(elementPos,elementName);
            }
        }
     }
  }

  function cancel()
  {
      var objWin = getTopWindow().getWindowOpener().parent;
      if(getTopWindow().getWindowOpener().parent.name == "treeContent")
      {
         objWin=getTopWindow().getWindowOpener();
      }
      var reload = "<xss:encodeForJavaScript><%=removalFlag%></xss:encodeForJavaScript>";
      if(reload && reload == "true")
      {
        objWin.document.location.href = objWin.document.location.href;
      }
      parent.closeWindow();
  }


  // function to handle the change event for text box value change
  function textBoxChangeCheck(checkBoxNumber)
  {
    modified = true;
    tempCount = checkBoxNumber-1;
    chbCount = 0;
    if(tempCount>=0) {
        for(j=0; j<document.editForm.elements.length; j++) {
            if(document.editForm.elements[j].type=="text" && eval(document.editForm.elements[j].name=="txtName"+tempCount)) {
                chbCount = j;
                break;
            }
        }
    }else {
        chbCount=0; 
    }
    for(; chbCount<document.editForm.elements.length; chbCount++) {
        if(document.editForm.elements[chbCount].type=="checkbox" && document.editForm.elements[chbCount].name=="checkBox") {
            document.editForm.elements[chbCount].checked=true;
            break;
        }
    }
  }
  // function to handle the change event for date text box value change
  function dateChangeCheck(checkBoxNumber,dateField)
  {
    modified = true;
    var oldDateObj = eval("document.editForm.elements['hid_"+dateField+"']");
    if(oldDateObj.value!=document.forms['editForm'].elements[dateField].value)
    {
      var checkElement = eval('document.editForm.checkBox['+ checkBoxNumber +']');
      if(!checkElement) {
        checkElement = eval('document.editForm.checkBox');
      }

      checkElement.checked=true;
    }
  }
  // function to handle the change event for type chooser text box value change
  function typeChooserChangeCheck(checkBoxNumber)
  {
    modified = true;
    txtTypeDisp = eval(strTxtTypeDisp+checkBoxNumber);
    if(val!=null && val!=txtTypeDisp.value)
    {
      var checkElement = eval('document.editForm.checkBox['+ checkBoxNumber +']');
      if(!checkElement) {
        checkElement = eval('document.editForm.checkBox');
      }

      checkElement.checked=true;
    }
    val=null;
  }

  function submit()
  {
    var fnRequired = "";
    var rdRequired ="";
    //XSSOK
    var fnLength   = "<%=fnLength%>";
  //XSSOK
    var rdLength   = "<%=rdLength%>";
  //XSSOK
    var fnUniqueness = "<%=fnUniqueness%>";
  //XSSOK
    var rdUniqueness = "<%=rdUniqueness%>";
  //XSSOK
    var ebomUniquenessOperator="<%=ebomUniquenessOperator%>";
    checkDateFields();
    var SelEbomIdsSubmit="";
    var temp;
    var totcount = document.editForm.selCount.value;

    cbCount = 0;
    for(j=0; j<document.editForm.elements.length; j++) 
    {
        if(document.editForm.elements[j].type=="checkbox" && document.editForm.elements[j].name!="checkAll")
        {
            cbCount++;
        }
    }
    var CheckBoxNumber = -1;
    if(cbCount > 0)
    {
        for(var i = 0; i < totcount; i++)
        {
            isChkBox = eval("document.editForm.isCheckBox"+i+".value");
            if("N" == isChkBox)
            {
                continue;
            }
            CheckBoxNumber++;
            
          var checkElement = eval('document.editForm.checkBox['+ CheckBoxNumber +']');
          if(!checkElement)
          {
            checkElement = eval('document.editForm.checkBox');
          }
          if(checkElement && (checkElement.checked == true))
          {
        	  //XSSOK
            var rdobj = eval('document.editForm.elements["<%=DomainObject.ATTRIBUTE_REFERENCE_DESIGNATOR%>'+ i +'"]');
            var fnobj = eval('document.editForm.FindNumber'+i);

          fnRequired = fnPropertyArray[i];
          rdRequired = rdPropertyArray[i];
          if(fnobj != null)
          {
            fnobj.value = trim(fnobj.value);
            var fnvalue = fnobj.value;
            var rdvalue = rdobj.value;
            if(!validateFNRD(fnobj,rdobj,fnRequired,rdRequired,i,totcount))
            {
                return;
            }
            if(fnUniqueness=="true" && !isFNUnique(fnvalue,i))
            {
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
                if(fnobj.type=="text") {
                    fnobj.focus();
                }
                return;
            }
            else if(fnUniqueness!="true" && rdUniqueness!="true")
            {
                if(!isFNUnique(fnvalue,i))
                {
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BuildEBOM.FNFieldNotUniquePleaseReEnter</emxUtil:i18nScript>");
                    if(fnobj.type=="text") {
                        fnobj.focus();
                    }
                    return;
                }
            }
            else if(rdUniqueness=="true")
            {
                if (!checkRefUnique())
                {
                    if(rdobj.type=="text") {
                        rdobj.focus();
                    }
                    return;
                }
            }
          }

          var txtobj = eval('document.editForm.txtName'+i);
                if(txtobj != null)
                {
                  txtobj.value = trim(txtobj.value);
                  var txtvalue = txtobj.value;
                  if(isEmpty(txtvalue) )
                  {
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.PleaseEnterAPartName</emxUtil:i18nScript>");
                    txtobj.focus();
                    return;
                  }
          }
			//XSSOK
          var qtyobj = eval('document.editForm.<%=DomainObject.ATTRIBUTE_QUANTITY%>' + i);
          if(qtyobj != null)
          {
            qtyobj.value = trim(qtyobj.value);
            var qtyvalue = qtyobj.value;
            if(!isNumeric(qtyvalue))
            {
              alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeANumber</emxUtil:i18nScript>");
              qtyobj.focus();
              return;
            }
            if((qtyvalue).substr(0,1) == '-')
            {
              alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.QuantityHasToBeAPositiveNumber</emxUtil:i18nScript>");
              qtyobj.focus();
              return;
            }
            if(!isEmpty(rdobj.value))
            {
                var qt = getRDQuantity(rdobj.value)
                if (qtyvalue != qt)
                {
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity</emxUtil:i18nScript>");
                    qtyobj.focus();
                    return;
                }
                if(qt==0)
                {
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.ReferenceDesignator.SingleQuantity</emxUtil:i18nScript>");
                    qtyobj.focus();
                    return;
                }
            }

          }
          temp = true;
          SelEbomIdsSubmit += checkElement.value+",";
          }
        }
    }

    SelEbomIdsSubmit = SelEbomIdsSubmit.substring(0,SelEbomIdsSubmit.lastIndexOf(','));
    if(SelEbomIdsSubmit.indexOf('on')>=0)
    {
      SelEbomIdsSubmit =SelEbomIdsSubmit.substring(3,SelEbomIdsSubmit.length);
    }
    if(modified && !temp)
    {
       alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.PleasemakeaselectiontoSubmit</emxUtil:i18nScript>");
       return;
    }
    if(modified)
    {
       document.editForm.action = "emxpartEditEBOMsProcess.jsp?removalFlag=false&SelEbomIdsSubmit="+SelEbomIdsSubmit;
       document.editForm.submit();
    }
    else
    {
       cancel();
    }

  }

  function removeSelected()
  {
    var SelEbomIds="";
    var NotSelectedRowIds="";
    var RemovalRowIds="";
    var temp;
    var totcount = document.editForm.selCount.value;

    var tempId = ""; 
    var ebomIds = "<xss:encodeForJavaScript><%=SelEbomIds%></xss:encodeForJavaScript>";
    if(ebomIds != null && ebomIds != "" && ebomIds != "null") {
        if(ebomIds.charAt(ebomIds.length-1) == ",") {
            ebomIds = ebomIds.substring(0,ebomIds.length-1)
        }
    }
    var ebomArray = ebomIds.split(",");
    cbCount = 0;
    for(j=0; j<document.editForm.elements.length; j++) {
        if(document.editForm.elements[j].type=="checkbox" && document.editForm.elements[j].name!="checkAll") {
            cbCount++;
        }
    }
    
        
        var test = "";
        for (var i = 0; i < cbCount; i++)
        {
          var checkElement = eval('document.editForm.checkBox['+ i +']');
          if( !(checkElement!=null && checkElement!="undefined" && checkElement!="null" && checkElement!="")) {
              checkElement = eval('document.editForm.checkBox');
          }

          if(checkElement && checkElement.name != "checkAll")
          {
            if(checkElement.checked == true)
            {
              temp = true;
              tempId = checkElement.value;
              for(k=0; k<ebomArray.length; k++) {
                  if(tempId==ebomArray[k]) {
                      RemovalRowIds += (k+1) + ",";
                  }
              }
            }
          }
        }
        for(i=0; i<ebomArray.length; i++) {
            test += (i+1) +",";
        }
        var RemovalRowIdsArray = RemovalRowIds.split(",");
        for(i=0; i<RemovalRowIdsArray.length-1; i++) {
            x = test.indexOf(RemovalRowIdsArray[i]);
            y = test.indexOf(",",x);
            if(y!=-1) {
                test = test.substring(0,x) + test.substring(y+1)
            } else {
                test = test.substring(0,x);
            }
        }
        NotSelectedRowIds = test;

    SelEbomIds = SelEbomIds.substring(0,SelEbomIds.lastIndexOf(','));
    if(SelEbomIds.indexOf('on')>=0)
    {
      SelEbomIds =SelEbomIds.substring(3,SelEbomIds.length);
    }
    if(!temp)
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.PleaseMakeASelection</emxUtil:i18nScript>");
      return;
    }
    else
    {
      if(confirm("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Common.MsgConfirm</emxUtil:i18nScript>"))
      {
        document.editForm.action = "emxpartEditEBOMsProcess.jsp?objectId=<xss:encodeForJavaScript><%=strObjectId%></xss:encodeForJavaScript>&removalFlag=true&NotSelectedRowIds="+NotSelectedRowIds+"&RemovalRowIds="+RemovalRowIds;
        document.editForm.submit();
      }
      else
      {
        return;
      }
    }
  }

</script>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
  String txtType="document.forms['editForm'].type";
  // map to store the values of the attributes at the time when the Edit page is opened.
  Map storedMap           = new HashMap();
 %>
  <form name="editForm" method="post" action="" target="_parent" onsubmit="javascript:submit(); return false">
  <table class="list" id="UITable" width="700" border="0" cellpadding="3" cellspacing="2">
  <tr>
<%
    if (!isPrinterFriendly) {
%>
    <th><input type="checkbox" name="checkAll" onClick="allSelected('editForm')" /></th>
    <input type="hidden" name="selCount" value="<xss:encodeForHTMLAttribute><%=totalSelParts%></xss:encodeForHTMLAttribute>" />
<%
    }
%>
  <th><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Type</emxUtil:i18n>&nbsp;</th>
  <th><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Part</emxUtil:i18n>&nbsp;</th>
  <th><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Rev</emxUtil:i18n>&nbsp;</th>
<%
    // get the attribute names and show as headings
    String key;
    String attrName;
    Iterator iterator    = attDetailsMap.keySet().iterator();
    while(iterator.hasNext())
    {
      key = (String) iterator.next();
      Map mapinfo = (Map) attDetailsMap.get(key);
      attrName = (String)mapinfo.get("name");
%>
<!-- XSSOK -->
  <th class="label"><%=i18nNow.getAttributeI18NString(attrName,languageStr)%></th>
<%
      }
%>
<th><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.UOM</emxUtil:i18n>&nbsp;</th>
<th><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.State</emxUtil:i18n>&nbsp;</th>
<th><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Owner</emxUtil:i18n>&nbsp;</th>

</tr>

<%
  int i=0;
  String strIsCheckBox = "";
// check if there is data to show
if(resultList.size()>0)
{
%>
	<!-- XSSOK -->
  <fw:mapListItr mapList="<%= resultList %>" mapName="resultsMap">
<%
      objectId    = (String)resultsMap.get("to."+DomainObject.SELECT_ID);
      objectType  = (String)resultsMap.get("to."+DomainObject.SELECT_TYPE);
      objectName  = (String)resultsMap.get("to."+DomainObject.SELECT_NAME);
      objectRev   = (String)resultsMap.get("to."+DomainObject.SELECT_REVISION);
      objectState = (String)resultsMap.get("to."+DomainObject.SELECT_CURRENT);
      objectDesc  = (String)resultsMap.get("to."+DomainObject.SELECT_ATTRIBUTE_UNITOFMEASURE);
      objectOwner = (String)resultsMap.get("to."+DomainObject.SELECT_OWNER);
      srelId       = (String)resultsMap.get("id");
      String sPolicy  = (String)resultsMap.get("to."+"policy");
     String parentAlias  = FrameworkUtil.getAliasForAdmin(context, "type", objectType, true);
     String fnRequired   = JSPUtil.getCentralProperty(application, session,parentAlias,"FindNumberRequired");
     if(fnRequired==null || "null".equals(fnRequired) || "".equals(fnRequired))
     {
       fnRequired= EngineeringUtil.getParentTypeProperty(context,objectType,"FindNumberRequired");
     }
     String rdRequired   = JSPUtil.getCentralProperty(application, session,parentAlias,"ReferenceDesignatorRequired");
     if(rdRequired==null || "null".equals(rdRequired) || "".equals(rdRequired))
     {
       rdRequired= EngineeringUtil.getParentTypeProperty(context,objectType,"ReferenceDesignatorRequired");
     }
%>
<script language ="Javascript">
	//XSSOK
    fnPropertyArray["<%=i%>"]="<%=fnRequired%>";
  //XSSOK
    rdPropertyArray["<%=i%>"]="<%=rdRequired%>";
</script>
<%
      // setup storedMap for processing page - moved from above
      Map newMap    = new HashMap();
      newMap.put("name",objectName);
      newMap.put("revision",objectRev);
      newMap.put("type",objectType);
%>
  <!-- XSSOK -->
  <tr class='<fw:swap id="even"/>'>
<%
      txtName         = "txtName"+i;
      txtRev          = "txtRev"+i;
      txtDisplay      = "type"+i;
      txtValue        = "typeDisp"+i;
      if(finalRestoreMap.size()>0)
      {
        // restoring the values from the Map.
        Map tempMap=(Map)finalRestoreMap.get(srelId);
        tempMap=(tempMap==null)?new HashMap():tempMap;
        if(tempMap.size()>0)
        {
          objectName=(String)tempMap.get("name");
          objectRev=(String)tempMap.get("revision");
          objectType=(String)tempMap.get("type");
        }
      }
      // to restore the values entered by the user after the removal of EBOM.
      if(removalFlag.equals("true"))
      {
        if(finalremovalMap.size()>0)
        {
          Map tempMap=(Map)finalremovalMap.get(srelId);
          tempMap=(tempMap==null)?new HashMap():tempMap;
          if(tempMap.size()>0)
          {
            objectName=(String)tempMap.get("name");
            objectRev=(String)tempMap.get("revision");
            objectType=(String)tempMap.get("type");
          }
        }
      }

// this variable determines if there is a checkbox for the row or not
strIsCheckBox = "N";
if (!isPrinterFriendly && (objectState.equalsIgnoreCase(DomainConstants.STATE_PART_PRELIMINARY)))
{
    strIsCheckBox = "Y";
%>
  <td><input type="checkbox" name="checkBox" value="<xss:encodeForHTMLAttribute><%= srelId %></xss:encodeForHTMLAttribute>" onClick="updateSelected('editForm')" /></td>
  
<%
}
else
{
%>
  <td>&nbsp;</td>
<%
}
%>
<input type="hidden" name="isCheckBox<%=i%>" value="<xss:encodeForHTMLAttribute><%=strIsCheckBox%></xss:encodeForHTMLAttribute>" />
  <td>
  <table>
  <tr>
  <%
   if (!isPrinterFriendly)
   {
  %>
  <td>
  <input type="hidden" name="<%=txtDisplay%>" value="<xss:encodeForHTMLAttribute><%=objectType%></xss:encodeForHTMLAttribute>" />
  <input type="text" size="10" name="<%=txtValue%>" readonly="readonly" onblur="typeChooserChangeCheck('<%=i%>')" value="<xss:encodeForHTMLAttribute><%=i18nNow.getTypeI18NString(objectType,languageStr)%></xss:encodeForHTMLAttribute>" />
  </td>
<%
  }
  else
  {
%>
<!-- XSSOK -->
  <td width="70"><%=i18nNow.getTypeI18NString(objectType,languageStr)%>&nbsp;</td>
<%
  }
 if (!isPrinterFriendly)
 {
%>
  <td>
  &nbsp;
  </td>
<%
  }
%>
  </tr>
  </table>
  </td>
  <td>
  <input type="hidden" name="selId<%=i%>" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />

  <table>
  <tr>
<%

      if (!isPrinterFriendly)
      {
%>
  <td><input type="text" name="<%=txtName%>" size="16" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=objectName%></xss:encodeForHTMLAttribute>" />&nbsp;</td>
<%
      }
      else
      {
%>
	<!--XSSOK-->
  <td width="70"><%=objectName%>&nbsp;
  </td>
<%
      }
%>
  </tr>
  </table>
  </td>
<%
      if (!isPrinterFriendly)
      {
%>
  <td><input type="text" name="<%=txtRev%>" size="16" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=objectRev%></xss:encodeForHTMLAttribute>" />&nbsp;
  </td>
<%
      }
      else
      {
%>
<!--XSSOK-->
  <td width="70"><%=objectRev%>&nbsp;
  </td>
<%
      }
      //use same attribute details map each time, only get value from results map
      Map attrTypeMap = attDetailsMap;
      HashMap UOMTypeMap = EngineeringUtil.getMappingUOMValues(context, new String[] {objectId});
      Iterator itr2 = attrTypeMap.keySet().iterator();
      String key1 = "";
      String attrValue = "";
      while(itr2.hasNext())
      {
        key1 = (String)itr2.next();
        Map info = (Map) attrTypeMap.get(key1);
        String namesrelId="srelId"+i;
        String displayName=key1+i;
       // store this relationship attribute value in info map
        info.put("value",(String)resultsMap.get("attribute["+key1+"]"));

        if(finalRestoreMap.size()>0)
        {
          Map tempMap=(Map)finalRestoreMap.get(srelId);
          tempMap=(tempMap==null)?new HashMap():tempMap;
          if(tempMap.size()>0)
          {
            attrValue = tempMap.get(key1).toString();
            // if the attribute is of timeStamp type then format it and put in the map
            if(info.get("type").equals("timestamp") && !attrValue.equals("") && !attrValue.equals(null))
            {
              attrValue = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,attrValue,tz,request.getLocale());
            }
            info.put("value",attrValue);
          }
        }
        if(key1.equalsIgnoreCase(DomainObject.ATTRIBUTE_FIND_NUMBER))
        {
            key1 = removeWhiteSpace(key1);
        }
        if(removalFlag.equals("true"))
        {
          if(finalremovalMap.size()>0)
          {
            Map tempMap=(Map)finalremovalMap.get(srelId);
            tempMap=(tempMap==null)?new HashMap():tempMap;
            if(tempMap.size()>0)
            {
              attrValue = tempMap.get(key1).toString();
              // if the attribute is of timeStamp type then format it and put in the map
              if(info.get("type").equals("timestamp") && !attrValue.equals(null) && !attrValue.equals(""))
              {
                attrValue = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,attrValue,tz);
              }
              info.put("value",attrValue);
            }
          }
        }
        String displayValue=(String)info.get("value");
        if(key1.equalsIgnoreCase(DomainObject.ATTRIBUTE_FIND_NUMBER))
        {
            key1 = removeWhiteSpace(key1);
        }
        if(key1.equalsIgnoreCase(DomainConstants.ATTRIBUTE_UNIT_OF_MEASURE))
        {
        	 info.put("choices", UOMTypeMap.get(objectId));
        }
        // store attribute value in the storeMap for processing page
        newMap.put(key1,(String)resultsMap.get("attribute["+key1+"]"));

%>
  <input type="hidden" name="<%=namesrelId%>" value="<xss:encodeForHTMLAttribute><%=srelId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>" />
<%
        if (!isPrinterFriendly && (objectState.equalsIgnoreCase(DomainConstants.STATE_PART_PRELIMINARY)))
        {
        	String fieldString= EngineeringUtil.displayField(context,info,"edit",languageStr,session,key1+"|"+i,"editForm",true);
        	fieldString =fieldString.replaceAll("textarea", "textarea style=\"width:210px;\"");
%>
<!--XSSOK-->
  <td width="150%"><%=fieldString%>&nbsp;</td>
<%
        }
        else
        {
            String keyValue = (String)info.get("value");
%>
<!--XSSOK-->
  <td width="70"><%=keyValue%>&nbsp;</td>
  <!-- XSSOK -->
  <input type="hidden" name="<%=key1+i%>" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>" />
<%
        }
      }
      storedMap.put(srelId,newMap);
      i++;
%>
<!--XSSOK-->
  <td><%=objectDesc%>&nbsp;</td>
  <!-- XSSOK -->
  <td><%=i18nNow.getStateI18NString(sPolicy,objectState,languageStr)%></td>
  <!-- XSSOK -->
  <td><%=PersonUtil.getFullName(context,objectOwner)%></td>
  </tr>

  </fw:mapListItr>
<%
  }  // show this row if there is no EBOM
  else
  {
%>
  <!-- XSSOK -->
  <tr class='<fw:swap id="even"/>'>
  <td colspan=14 align="center" ><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Part.NoBOMFound</emxUtil:i18n></td>
  </tr>
<%
  }
%>
</table>
  <input type="image" height="1" width="1" border="0" />
</form>
<%
    //removal of the session values.
    session.setAttribute("storedMap",storedMap);
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "emxDesignBottomInclude.inc"%>
<%!
/**
      * This method is used for removing whitespaces from the Attribute Name
      * @param String - Name of the Attribute
      * @return Attribute name without whitespaces
      * @exception java.lang.Exception The exception description
      **/
    public String removeWhiteSpace(String str) throws Exception
    {
        String whiteSpace = " ";
        String newstr = "";
        try{
            for(int i=0;i<str.length();i++){
                String chstr  =  str.charAt(i)+"";
                if (chstr.equals(whiteSpace)){
                    newstr = str.substring(0,i) + str.substring(i+1, str.length());
                    str=newstr;
                }
            }
        }
        catch(Exception e){
                throw e;
        }
        return str;
    }
%>
