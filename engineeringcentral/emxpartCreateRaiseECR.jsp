 <%--  emxpartCreateRaiseECR.jsp   - The Processing page for Creation of ECRs by a Customer
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>

<%

  Part ecrableObj = (Part)DomainObject.newInstance(context,
                  DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  ECR ecrId = (ECR)DomainObject.newInstance(context,
                  DomainConstants.TYPE_ECR,DomainConstants.ENGINEERING);
  //ProductLine productLineId = (ProductLine)DomainObject.newInstance(context,
                //  DomainConstants.TYPE_PRODUCTLINE,DomainConstants.ENGINEERING);

  String sRelType = "";
  String sECRType = PropertyUtil.getSchemaProperty(context, "type_ECR");

  // Get the attribute names
  String ECREvaluatorAttr                     = PropertyUtil.getSchemaProperty(context, "attribute_ECREvaluator");
  String responsibleDesignEngineerAttr        = PropertyUtil.getSchemaProperty(context,"attribute_ResponsibleDesignEngineer");
  String attributeWhereUsedComponentReference = PropertyUtil.getSchemaProperty(context,"attribute_WhereUsedComponentReference");
  String attributeSpecificDescriptionofChange = PropertyUtil.getSchemaProperty(context,"attribute_SpecificDescriptionofChange");
  String relAffectedItem = PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem");
  String Create = emxGetParameter(request,"Create");
  String Relationship = emxGetParameter(request,"Relationship");
  //Fixed to get RDO id
  //String rdoId = emxGetParameter(request,"rdoId");
  String rdoId = emxGetParameter(request,"RDOId");
  String policy = emxGetParameter(request,"policy");
  if(Create==null){
    Create="";
  }
  // 374591
  String policyClassName = "policy_ECR";

  String ecrableId="";
  String selectedType         = emxGetParameter(request, "selectedType");
  String reasonForChange      = emxGetParameter(request, "reasonForChange") + " ";
  session.setAttribute("ReasonForChange_KEY",reasonForChange);//IR-069928V6R2012
  String suiteKey             = emxGetParameter(request, "suiteKey");
  String selectedParts      = (String)session.getAttribute("selectedParts");
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String rdoName      = (String)session.getAttribute("rdoName");
  String checkedButtonValue=emxGetParameter(request,"checkedButtonValue");
  String prevmode  = emxGetParameter(request,"prevmode");
  String sName = emxGetParameter(request,"Name");
  String sRev = emxGetParameter(request,"Rev");
  String partsConnected =emxGetParameter(request,"partsConnected");

  //X3 Start - Added for EBOM Substitute Mass Change
  String ebomSubstituteChange = (String)session.getAttribute("ebomSubstituteChange");
  boolean isEBOMSub = false;
  if (ebomSubstituteChange != null && ebomSubstituteChange.equals("true")) isEBOMSub = true;
  //X3 End - Added for EBOM Substitute Mass Change

  String whereUsedComponentReferencecheckBox = emxGetParameter(request,"checkboxValue");
  if(whereUsedComponentReferencecheckBox==null || "".equals(whereUsedComponentReferencecheckBox) || "null".equals(whereUsedComponentReferencecheckBox))
  {
	  whereUsedComponentReferencecheckBox="unchecked";
  }
  String executeMassChangeOpertaionscheckBox = emxGetParameter(request,"checkboxValue");
  if(executeMassChangeOpertaionscheckBox==null || "".equals(executeMassChangeOpertaionscheckBox) || "null".equals(executeMassChangeOpertaionscheckBox))
  {
	  executeMassChangeOpertaionscheckBox="unchecked";
  }

  //String sProductLineId       = "";
  String sVault               = "";
  String sPolicy              = "";
  String sDescription         = "";
  String partObjectId         = emxGetParameter(request, "objectId");
  String objectId             = "";
  String strEcrId             = "";
  Vault vault                 = new Vault(JSPUtil.getVault(context,session));
  String attrValue            = "";
  String attrName             = "";
  java.util.Set keys          = null;
  Iterator itr                = null;
  HashMap relAttrmap          = new HashMap();
  Map dispMap                 = (Map) session.getAttribute("dispAttribs");
  String SrelTypeCheck        = "";
  boolean ignoreAssembly      = false;
  String ignoreAssemblyParts  = "";
  boolean ignoreFlag          = false;

  ecrableObj.setId(partObjectId);
  String sWhereUsedcomRef     = ecrableObj.getInfo(context,DomainObject.SELECT_TYPE)+" "+ ecrableObj.getInfo(context,DomainObject.SELECT_NAME)+" "+ ecrableObj.getInfo(context,DomainObject.SELECT_REVISION);

  itr = dispMap.keySet().iterator();
  while (itr.hasNext()){
    Map valueMap = (Map)dispMap.get((String)itr.next());
    relAttrmap.put((String)valueMap.get("name"),(String)valueMap.get("value"));
  }
  relAttrmap.put(attributeSpecificDescriptionofChange,reasonForChange);
  StringList selectList = new StringList();
  selectList.addElement(DomainObject.SELECT_ID);
  StringList relSelects = new StringList();
  DomainRelationship doRel = null;
  objectId = selectedType;
  ecrId.setId(objectId);

 if(!Create.equals("true"))
  {
%>
   <%@include file = "emxEngrStartUpdateTransaction.inc"%>
   <%
    try
    {



      String relationshipId="";
      StringTokenizer st = new StringTokenizer(selectedParts, ",");
      while(st.hasMoreTokens())
      {
        String stInfo = st.nextToken();

        StringTokenizer stId = new StringTokenizer(stInfo, "|");
        ecrableId = stId.nextToken();
        sRelType=Relationship;
        ecrableObj.setId(ecrableId);

        boolean isPart = true;
        String sBaseType = FrameworkUtil.getBaseType(context,ecrableObj.getInfo(context,DomainConstants.SELECT_TYPE), vault);

        if(!((DomainConstants.TYPE_PART).equals(sBaseType))) {

          isPart = false;
          sRelType = relAffectedItem;
          ignoreAssembly=false;
          Relationship = relAffectedItem;
		  // 359020 - if static approval, use request spec revision rel to connect specs.
         // if (!PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem").equals(Relationship))
	      //    Relationship = DomainConstants.RELATIONSHIP_REQUEST_SPECIFICATION_REVISION;
        }
		//Start - Modify to remove invalid class references
        //ECRable ecrable = (ECRable) DomainObject.newInstance(context,ecrableId,DomainConstants.ENGINEERING);
        //ECRManager mgr =(ECRManager)ecrable.getECRManager(sRelType);
		DomainObject ecrable = new DomainObject(ecrableId);
		//End - Modify to remove invalid class references
        Part partId = new Part(ecrableId);

        MapList ebomMarkupList = partId.getRelatedObjects(context,
                                                          DomainObject.RELATIONSHIP_EBOM_MARKUP,
                                                          "*",
                                                           selectList,
                                                           relSelects,
                                                           false,
                                                           true,
                                                           (short)1,
                                                           null,
                                                           null);

        // Ignore the assembly if already connected to relationship Request Part Obsolecence
        MapList mapListofRaiseAgainst = new MapList();
        String RANGE_FOR_OBSOLETE="For Obsolescence";
        String whereclause = "(attribute[" + PropertyUtil.getSchemaProperty(context,"attribute_RequestedChange") + "]==\"" +
        ""+RANGE_FOR_OBSOLETE+"\")" ;
        if(isPart)
        {
            SrelTypeCheck = relAffectedItem;
         // if(sRelType.equals(DomainConstants.RELATIONSHIP_REQUEST_PART_OBSOLESCENCE)) {
        //    SrelTypeCheck=DomainConstants.RELATIONSHIP_REQUEST_PART_REVISION;
        //  }
        //  else {
         //   SrelTypeCheck=DomainConstants.RELATIONSHIP_REQUEST_PART_OBSOLESCENCE;
        //  }
          //Start - Modify to remove invalid class references
		  mapListofRaiseAgainst = ecrId.getRelatedObjects(context,
                                                     SrelTypeCheck,
                                                     "*",
                                                     null,
                                                     null,
                                                     false,  //mgr.isDomainObjectFrom(), //false
                                                     true, //!mgr.isDomainObjectFrom(),//true Mass BOM
                                                     (short) 1,
                                                     "id == " + ecrableId,
                                                     whereclause);
		  //End - Modify to remove invalid class references
          if(mapListofRaiseAgainst.size() != 0)
          {
            ignoreAssembly=true;
            ignoreFlag=true;
            ignoreAssemblyParts+=ecrableObj.getInfo(context,DomainConstants.SELECT_NAME)+", ";
          }

        }

        if(ignoreAssembly==false)
        {
          StringList objectSelect  = new StringList();
          objectSelect.add("id");
          StringList relSelect  = new StringList();
          relSelect.add(DomainConstants.SELECT_RELATIONSHIP_ID);
          MapList resultList = ecrableObj.getRelatedObjects(context, sRelType + "," + PropertyUtil.getSchemaProperty(context,"relationship_AffectedItem"),sECRType , objectSelect,relSelect, true, false, (short)1, null, null);
          boolean boolConnected=false;
          Iterator mapItr = resultList.iterator();
          while (mapItr.hasNext()) {
            Map map = (Map)mapItr.next();
            strEcrId = (String)map.get("id");
            if(strEcrId.equals(selectedType)) {
              relationshipId=(String)map.get(DomainConstants.SELECT_RELATIONSHIP_ID);
              boolConnected=true;
              break;
            }
          }

          if(boolConnected){

            DomainRelationship domainRel = DomainRelationship.newInstance(context,relationshipId);

            Map attrMap = domainRel.getAttributeDetails(context);
            HashMap specRelAttrmap = new HashMap();
            String key;
            String attrDataType;
            itr = attrMap.keySet().iterator();
            while(itr.hasNext())
            {
              attrValue ="";
              key = (String) itr.next();
              Map mapinfo = (Map) attrMap.get(key);
              attrName = (String)mapinfo.get("name");
              if(attrName.equals(attributeSpecificDescriptionofChange))
              {
                if(!isPart)
                {
                  specRelAttrmap.put(attrName,(String)mapinfo.get("value") + " " + reasonForChange);
                }
                else
                {
                  relAttrmap.put(attrName, (String)mapinfo.get("value") + " " + reasonForChange);
                }

              }
              else if(attrName.equals(attributeWhereUsedComponentReference))
              {
                //if(isPart && Relationship.equals(DomainConstants.RELATIONSHIP_REQUEST_PART_REVISION))
                    if(isPart)
                {
                  if(whereUsedComponentReferencecheckBox.equals("checked"))
                  {
                    if( ((String)mapinfo.get("value")).indexOf(sWhereUsedcomRef) < 0 )
                    {
                      relAttrmap.put(attributeWhereUsedComponentReference,(String)mapinfo.get("value")+" "+sWhereUsedcomRef);
                    }
                  }
                }
              }
            }

            if(isPart)
            {
              domainRel.setAttributeValues(context,relAttrmap);
            }
            else
            {
              domainRel.setAttributeValues(context,specRelAttrmap);
            }
          }
          else
          {
            if(isPart)
            {
              relAttrmap.put(attributeSpecificDescriptionofChange,reasonForChange);
             // if(Relationship.equals(DomainConstants.RELATIONSHIP_REQUEST_PART_REVISION) && whereUsedComponentReferencecheckBox.equals("checked"))
                 if(whereUsedComponentReferencecheckBox.equals("checked"))
              {
                relAttrmap.put(attributeWhereUsedComponentReference,sWhereUsedcomRef);
              }
              //Start - Modify to remove invalid class references
			  //mgr.connect(context,selectedType,relAttrmap);
			  doRel = DomainRelationship.connect(context,new DomainObject(selectedType),Relationship,(DomainObject)ecrable);
	  		  doRel.setAttributeValues(context,relAttrmap);
			  //End - Modify to remove invalid class references
			  
              DomainObject ecrObj = new DomainObject(selectedType);
              ArrayList relIdList = new ArrayList();
              int i=0;
              Iterator ecrItr = ebomMarkupList.iterator();
              String relTypes = PropertyUtil.getSchemaProperty(context,"relationship_ProposedMarkup") + "," + PropertyUtil.getSchemaProperty(context,"relationship_AppliedMarkup");
              String types = DomainConstants.TYPE_ECR + "," + DomainConstants.TYPE_ECO;

              while(ecrItr.hasNext())
              {
				  Map ecrMap =(Map)ecrItr.next();
				  String markupId = (String)ecrMap.get(DomainObject.SELECT_ID);
				  DomainObject markupObj = new DomainObject(markupId);
				  StringList markupSelects = new StringList();
				  markupSelects.addElement(DomainObject.SELECT_ID);
				  StringList markupRelSelects = new StringList();
				  MapList markupList = markupObj.getRelatedObjects(context,
				  												   relTypes,
				  												   types,
				  												   markupSelects,
				  												   markupRelSelects,
				  												   true,
				  												   false,
				  												   (short)1,
				  												   null,
				  												   null);
                 if(markupList.size()>0)
                 {
					 continue;
				 }
                 relIdList.add(markupId);

                 i++;
			  }
              String relatedIds [] = (String [])relIdList.toArray(new String[relIdList.size()]);
			  if(relatedIds.length>0)
		      {
          		DomainRelationship.connect(context,ecrObj,PropertyUtil.getSchemaProperty(context,"relationship_ProposedMarkup"),true,relatedIds);
			  }
            }
            else
            {
              HashMap specRelAttrmap = new HashMap();
              specRelAttrmap.put(attributeSpecificDescriptionofChange,reasonForChange);
              //Start - Modify to remove invalid class references
              //mgr.connect(context,selectedType,specRelAttrmap);
			  //doRel = DomainRelationship.connect(context,new DomainObject(selectedType),Relationship,ecrId);
			  doRel = DomainRelationship.connect(context,new DomainObject(selectedType),Relationship,(DomainObject)ecrable);
    		  doRel.setAttributeValues(context,specRelAttrmap);
			  //End - Modify to remove invalid class references
            }
          }
		  // 359020 -  connect ECR and Part with Raised Against ECR rel as well.
		  DomainObject ecrObject = new DomainObject(selectedType);

		  // 366834
		  StringList toObjId = ecrObject.getInfoList(context, "from["+DomainConstants.RELATIONSHIP_RAISED_AGAINST_ECR+"].to.id");
		  if (!toObjId.contains(ecrableId))
	          	DomainRelationship.connect(context, new DomainObject(selectedType), DomainConstants.RELATIONSHIP_RAISED_AGAINST_ECR, (DomainObject)ecrable);
        }
      }
    }
    catch(Exception e)
    {
%>
    <%@include file = "emxEngrAbortTransaction.inc"%>
<%

    throw e;
  }
%>
  <%@include file = "emxEngrCommitTransaction.inc"%>

<%
    
}
String url =  "../common/emxTree.jsp?objectId=" + objectId + "&suiteKey=" + suiteKey + "&emxSuiteDirectory=engineeringcentral";
%>

<%@include file = "emxDesignBottomInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">
<%
  if(ignoreFlag==true)
  {
    ignoreAssemblyParts = ignoreAssemblyParts.trim();
    ignoreAssemblyParts = ignoreAssemblyParts.substring(0,ignoreAssemblyParts.length()-1) ;
%>
//XSSOK
  alert("<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.WARNING</emxUtil:i18n>\n\n<emxUtil:i18n localize="i18nId">emxEngineeringCentral.RaiseECR.AlertItemsAlreadyRaised1</emxUtil:i18n> <%=SrelTypeCheck%> <emxUtil:i18n localize="i18nId">emxEngineeringCentral.RaiseECR.AlertItemsAlreadyRaised2</emxUtil:i18n> \n\n <%=ignoreAssemblyParts%>");

<%
  }
%>
<%
if (executeMassChangeOpertaionscheckBox.equals("unchecked")){
%>
  var contentFrame = getTopWindow().getWindowOpener().getTopWindow().findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");
  if(contentFrame == null){
	  //XSSOK
	  getTopWindow().getWindowOpener().getTopWindow().location.href = "<%=XSSUtil.encodeForJavaScript(context,url)%>";
	  parent.closeWindow();
  }
  else {
	  //XSSOK
    contentFrame.location.replace("<%=XSSUtil.encodeForJavaScript(context,url)%>");
    parent.closeWindow();
  }
</script>
  <% }
  else
  {
	  //X3 Start - Added for EBOM Substitute mass change
	  String contentUrl = "";
	  if(isEBOMSub) {
		  contentUrl = "emxengchgEBOMSubstituteUpdateDialogFS.jsp?suiteKey=EngineeringCentral&initSource=&jsTreeID=null&objectId="+ partObjectId+"&ecrId="+ecrId.getId()+"&contentPageIsDialog=true&warn=true&policy="+policy;
	  }else {
	  //X3 End - Added for EBOM Substitute mass change
		  contentUrl = "emxengchgEBOMUpdateDialogFS.jsp?suiteKey=EngineeringCentral&initSource=&jsTreeID=null&objectId="+ partObjectId+"&ecrId="+ecrId.getId()+"&contentPageIsDialog=true&warn=true&policy="+policy;
  	  //X3 Start - Added for EBOM Substitute mass change
	  }
 	  //X3 End - Added for EBOM Substitute mass change

  request.setAttribute("rdoName",rdoName);
  request.setAttribute("checkedButtonValue",checkedButtonValue);
  request.setAttribute("prevmode",prevmode);
  request.setAttribute("sName",sName);
  request.setAttribute("sRev",sRev);
  request.setAttribute("selectedType",selectedType);
  request.setAttribute("Relationship",Relationship);
  request.setAttribute("policy",policy);
  RequestDispatcher rd = request.getRequestDispatcher(contentUrl);
  rd.forward(request,response);
}
%>
