<%--  emxpartCopyComponentsIntermediateProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "emxengchgValidationUtil.js" %>

<%
  Part domObj = (Part)DomainObject.newInstance(context,
                    DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  int totalSelParts       =0;
  String RelId            ="";

  //Declare display variables
  String objectId         = "";
  String objectName       = "";
  String objectRev        = "";
  String objectState      = "";
  String objectOwner      = "";
  String objectType      = "";
  String sRelId           = "";
  String sPolicy          = "";
  String rdValue  ="";

  String languageStr      = request.getHeader("Accept-Language");
  String jsTreeID         = emxGetParameter(request,"jsTreeID");
  String suiteKey         = emxGetParameter(request,"suiteKey");
  String strObjectId      = emxGetParameter(request,"objectId");
  String attrFindNumber   = PropertyUtil.getSchemaProperty(context, "attribute_FindNumber");
  String attrQuantity     = PropertyUtil.getSchemaProperty(context, "attribute_Quantity");
  String sAttUM           = PropertyUtil.getSchemaProperty(context, "attribute_UnitofMeasure");
  String ATTRIBUTE_NOTE = PropertyUtil.getSchemaProperty(context, "attribute_Notes");
  String SELECT_ATTRIBUTE_NOTE = "attribute[" + ATTRIBUTE_NOTE + "]";
  String ATTRIBUTE_SOURCE = PropertyUtil.getSchemaProperty(context, "attribute_Source");
  String SELECT_ATTRIBUTE_SOURCE = "attribute[" + ATTRIBUTE_SOURCE + "]";
  
  String strRd= "";
  String selectedId = emxGetParameter(request,"checkBox");
  if (selectedId == null || "null".equals(selectedId)){
    selectedId = "";
  }

  // Get the Selected Part ID from Session
  String errorFlag = emxGetParameter(request,"errorFlag");
  if(errorFlag==null || "null".equals(errorFlag)){
    errorFlag="";
  }

  if(!errorFlag.equals("true")){
    Properties selectedPARTprop  = new Properties();
    selectedPARTprop.setProperty("selectedId_KEY",selectedId);
    session.setAttribute("selectedPARTprop",selectedPARTprop);
  }
  if(errorFlag.equals("true")){
    strObjectId      = emxGetParameter(request,"objectId");
  }else{
    strObjectId      = selectedId;
  }

  domObj.setId(strObjectId);
  domObj.open(context);


%>
     <script language="Javascript">

<%
        StringList selectStmts = new StringList(3);
        selectStmts.addElement(DomainConstants.SELECT_ID);
        StringList selectRelStmts = new StringList(2);
        selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);
        selectRelStmts.addElement(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);
        // get Relationship Data like Find Number and use in checking for uniqueness
        MapList ebomList = domObj.getRelatedObjects(context,
                                             DomainConstants.RELATIONSHIP_EBOM,           // relationship pattern
                                             DomainConstants.TYPE_PART,                   // object pattern
                                             selectStmts,                 // object selects
                                             selectRelStmts,              // relationship selects
                                             false,                        // to direction
                                             true,                       // from direction
                                             (short)1,                    // recursion level
                                             null,                        // object where clause
                                             null);
        int k = 0;
        int j= 0;
        String fnValue = "";
        Iterator bomItr = ebomList.iterator();
        while(bomItr.hasNext())
        {
            j++;
            Map bomMap = (Map)bomItr.next();
            fnValue = (String)bomMap.get(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);
            rdValue = (String)bomMap.get(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);
            if(j==1)
            {
             strRd=rdValue;
            }
            else{
              strRd=strRd + "," + rdValue;
            }

%>
			//XSSOK
            rdArray["<%=k%>"]="<%=rdValue%>";
          	//XSSOK
            fnArray["<%=k%>"]="<%=fnValue%>";
<%
            k++;
        }
%>

   </script>
<script language="javascript">
var fnPropertyArray = new Array();
var rdPropertyArray = new Array();
var TNRArray = new Array();

 function submit() {

    var totcount = document.editForm.selCount.value;
    //XSSOK
    var fnLength   = "<%=fnLength%>";
  	//XSSOK
    var rdLength   = "<%=rdLength%>";
  //XSSOK
    var fnUniqueness = "<%=fnUniqueness%>";
    var TNRDArray=new Array();
    var RdClientArray=new Array();
    var rdunique="false";
    var uniq ="true";
    var RefArray = new Array();
    RefArray=rdArray;
    var fnRequired ="";
    var rdRequired ="";
  //XSSOK
    var rdUniqueness = "<%=rdUniqueness%>";
  //XSSOK
    var ebomUniquenessOperator="<%=ebomUniquenessOperator%>";
    document.editForm.action="emxpartCopyComponentsProcess.jsp?objectId=<xss:encodeForJavaScript><%=strObjectId%></xss:encodeForJavaScript>";
    document.editForm.submit();
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  // get the Selected EBOM's RelIds
  String strRelEbomIds = (String) session.getAttribute("strRelEbomIds");

  Map attDetailsMap = new HashMap();
  Map finalattDetailsMap = new HashMap();
  MapList tempList1 = new MapList();

  // getting objectIds from RelIds
  if(strRelEbomIds !=null){
    StringTokenizer st = new StringTokenizer(strRelEbomIds, ",");
     int count =st.countTokens();
     String[] RelIdArray = new String[count];
     int i=0;
     while(st.hasMoreTokens()){
      RelId = st.nextToken();
      RelIdArray[i]=RelId;
      DomainRelationship DomRelObj = DomainRelationship.newInstance(context,RelId);
      attDetailsMap = DomRelObj.getAttributeDetails(context,false);
      finalattDetailsMap.put(RelId,attDetailsMap);
      totalSelParts++;
      i++;
     }

    SelectList resultSelects1 = new SelectList(8);
    resultSelects1.add("to."+DomainObject.SELECT_ID);
    resultSelects1.add("to."+DomainObject.SELECT_TYPE);
    resultSelects1.add("to."+DomainObject.SELECT_NAME);
    resultSelects1.add("to."+DomainObject.SELECT_REVISION);
    resultSelects1.add("to."+DomainObject.SELECT_DESCRIPTION);
    resultSelects1.add("to."+DomainObject.SELECT_CURRENT);
    resultSelects1.add("to."+DomainObject.SELECT_OWNER);
    resultSelects1.add("to."+DomainObject.SELECT_ATTRIBUTE_UNITOFMEASURE);
    resultSelects1.add(DomainRelationship.SELECT_ID);
    resultSelects1.addElement("to."+"policy");
    //IR-0597773: Added selectables to get BOM attributes
    resultSelects1.add(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);	 
    resultSelects1.add(DomainConstants.SELECT_ATTRIBUTE_QUANTITY);	 
    resultSelects1.add(DomainConstants.SELECT_ATTRIBUTE_USAGE);	 
    resultSelects1.add(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);	 
    resultSelects1.add(DomainConstants.SELECT_ATTRIBUTE_COMPONENT_LOCATION);
    resultSelects1.add(DomainConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
    resultSelects1.add(SELECT_ATTRIBUTE_NOTE);
    resultSelects1.add(SELECT_ATTRIBUTE_SOURCE);
	//End
    tempList1  = DomainRelationship.getInfo(context, RelIdArray,resultSelects1 );
  }

  Map finalRestoreMap = (Map)session.getAttribute("StoredAttrMapList");
  finalRestoreMap=(finalRestoreMap==null)?new HashMap():finalRestoreMap;

%>
	<body onLoad = "javascript:submit(); return false">
  <form name="editForm" method="post" target="_parent" onSubmit="javascript:submit(); return false">
  <input type="hidden" name="selCount" value="<xss:encodeForHTMLAttribute><%=totalSelParts%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="sObjectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
<%
	  String sRelType = PropertyUtil.getSchemaProperty(context,"relationship_EBOM");
      Map attrMap     = DomainRelationship.getTypeAttributes(context,sRelType);
      Iterator itr    = attrMap.keySet().iterator();
  int i=0;
%>
<!-- XSSOK -->
<fw:mapListItr mapList="<%= tempList1 %>" mapName="resultsMap">
<%
      objectId    = (String)resultsMap.get("to."+DomainObject.SELECT_ID);
      objectName  = (String)resultsMap.get("to."+DomainObject.SELECT_NAME);
      objectRev   = (String)resultsMap.get("to."+DomainObject.SELECT_REVISION);
      objectState = (String)resultsMap.get("to."+DomainObject.SELECT_CURRENT);
      objectOwner = (String)resultsMap.get("to."+DomainObject.SELECT_OWNER);
      objectType  = (String)resultsMap.get("to."+DomainObject.SELECT_TYPE);
      sRelId      = (String)resultsMap.get(DomainRelationship.SELECT_ID);
      sPolicy     = (String)resultsMap.get("to."+"policy");
      //IR-0597773:Added to retrieve BOM attributes
      String FN = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_FIND_NUMBER);	 
      String QTY = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_QUANTITY);	 
      String USG = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_USAGE);	 
      String RD = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR);	 
      String CMPLOC = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_COMPONENT_LOCATION);
      String NOTE = (String)resultsMap.get(SELECT_ATTRIBUTE_NOTE);
      String SOURCE = (String)resultsMap.get(SELECT_ATTRIBUTE_SOURCE);
      String UOM = (String)resultsMap.get(DomainConstants.SELECT_ATTRIBUTE_UNITOFMEASURE);
      //End	  
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
      StringBuffer partTNR = new StringBuffer();
      partTNR.append(objectType);
      partTNR.append(" ");
      partTNR.append(objectName);
      partTNR.append(" ");
      partTNR.append(objectRev);

%>
  <script language ="Javascript">
  //XSSOK
     fnPropertyArray["<%=i%>"]="<%=fnRequired%>";
     //XSSOK
     rdPropertyArray["<%=i%>"]="<%=rdRequired%>";
     //XSSOK
     TNRArray["<%=i%>"]="<%=partTNR.toString()%>";
  </script>

      <input type="hidden" name="selId<%=i%>" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
      <!--IR-0597773: Following code to send BOM attribute values to process page -->
       <input type="hidden" name="selFN<%=i%>" value="<xss:encodeForHTMLAttribute><%= FN %></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selQTY<%=i%>" value="<xss:encodeForHTMLAttribute><%= QTY %></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selUSG<%=i%>" value="<xss:encodeForHTMLAttribute><%= USG %></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selRD<%=i%>" value="<xss:encodeForHTMLAttribute><%= RD %></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selCMPLOC<%=i%>" value="<xss:encodeForHTMLAttribute><%= CMPLOC %></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selNOTE<%=i%>" value="<xss:encodeForHTMLAttribute><%= NOTE%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="selSOURCE<%=i%>" value="<xss:encodeForHTMLAttribute><%= SOURCE%></xss:encodeForHTMLAttribute>" />
           <input type="hidden" name="selUOM<%=i%>" value="<xss:encodeForHTMLAttribute><%= UOM%></xss:encodeForHTMLAttribute>" />
<%
        String attribute="";
        Map attrTypeMap = (Map) finalattDetailsMap.get(sRelId);
        itr = attrMap.keySet().iterator();
        while(itr.hasNext())
        {
          attribute = (String)itr.next();
          Map info = (Map) attrTypeMap.get(attribute);

          if(finalRestoreMap.size()>0)
          {
            Map tempMap=(Map)finalRestoreMap.get(sRelId);
            tempMap=(tempMap==null)?new HashMap():tempMap;
            if(tempMap.size()>0)
            {
              info.put("value",tempMap.get(attribute));
            }
          }
          if (attribute.equals(attrFindNumber)){
              attribute="FindNumber";
          }
          if (attribute.equals(attrQuantity)){
              attribute="Qty";
          }
%>

<%
        }
      i++;
%>

  </fw:mapListItr>
  <%
  session.removeAttribute("StoredAttrMapList");
  %>
  </form>
  </body>
  <%@include file = "../emxUICommonEndOfPageInclude.inc" %>
