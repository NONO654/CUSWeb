<%--  emxengchgChangeEBOMUpdateValidation.jsp   -   Validation page for Mass Change
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

 <%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
  String suiteKey           = emxGetParameter(request,"suiteKey");
  String selectedObjs ="";
  String[] selectedObjsarr = new String[10];
  String dojObjName="";
  String partId="";
  if (initSource == null)
	{
	initSource = "";
	}
	String objectId = emxGetParameter(request,"objectId");
    DomainObject domObj = DomainObject.newInstance(context);
	String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");	
	String sObjId = "";
		
    if(checkBoxId != null )
    {
			try
			{
			StringTokenizer st = null;
			String sRelId = "";

			for(int i=0;i<checkBoxId.length;i++)
			{
			if(checkBoxId[i].indexOf("|") != -1)
			{
				st = new StringTokenizer(checkBoxId[i], "|");
				sRelId = st.nextToken();
				sObjId = st.nextToken();
			}
			else
			{
				sObjId = checkBoxId[i];
			}

			domObj.setId(sObjId);
			dojObjName=domObj.getInfo(context,"name");
			}
			}
			catch (Exception e)
			{
			session.setAttribute("error.message", e.getMessage());
			}
    }
  

  Part partObj = (Part)DomainObject.newInstance(context,
                                                DomainConstants.TYPE_PART,
                                                DomainConstants.ENGINEERING);
  partObj.setId(sObjId);
  String partName = partObj.getInfo(context,"name");
  partId = partObj.getInfo(context,"id");
  StringList relSelects1 = new StringList();
  StringList objSelects = new StringList();
  String relationshipWhere="";
  relSelects1.add(DomainConstants.SELECT_RELATIONSHIP_ID);
  objSelects.add(DomainConstants.SELECT_ID);
  //relationshipWhere = "to.id==" + partId;
  String objWhere="";
  objWhere = "current=="+DomainConstants.STATE_PART_RELEASE;
  MapList relEBOMMarkup = partObj.getRelatedObjects(context,
                                                   PropertyUtil.getSchemaProperty(context,"relationship_EBOM"),
                                                   PropertyUtil.getSchemaProperty(context,"type_Part"),
                                                   objSelects,
                                                   relSelects1,
                                                   true,
                                                   false,
                                                   (short)1,
                                                   objWhere,
                                                   relationshipWhere);
  
	if(relEBOMMarkup!=null && relEBOMMarkup.size()>0)
	{
		Iterator objItr= relEBOMMarkup.iterator();
		while(objItr.hasNext())
		{
			Map objMap1 = (Map) objItr.next();
			if(objItr.hasNext())
			{
			selectedObjs = selectedObjs + objMap1.get("id").toString() +",";
			}
			else
			{
			selectedObjs = selectedObjs + objMap1.get("id").toString();
			}
		}
	}
				
	if(selectedObjs.indexOf(",")<0)
	{
	  String[] selectedObjects = new String[1];
	  selectedObjects[0] = selectedObjs;
	  session.setAttribute("selectedObjs", selectedObjects);
	}
	else
	{
	StringList busSelects = new StringList(2);
	busSelects.add(DomainConstants.SELECT_ID);
	busSelects.add(DomainConstants.SELECT_TYPE);
	StringList relSelects = new StringList(2);
	relSelects.addElement(DomainObject.SELECT_RELATIONSHIP_ID);
	relSelects.addElement("attribute["+DomainConstants.ATTRIBUTE_FIND_NUMBER+"].value");
	StringTokenizer st = new StringTokenizer(selectedObjs, ",");
	String[] selectedObjects = new String[st.countTokens()];
	session.setAttribute("selectedObjs", selectedObjects);
	String selectedType = "";
	int i = 0;
	while(st.hasMoreTokens())
	{
	  selectedObjects[i] = st.nextToken();
	  i++;
	}
	ArrayList aList = new ArrayList();
	Vault vault = new Vault(JSPUtil.getVault(context,session));
	String sBaseType = "";
	String selectedObjId = null;
	DomainObject dObj = new DomainObject();
	for(i=0; i<selectedObjects.length; i++)
	{
		aList.add(selectedObjects[i]);
	}
	String[] partIds = (String[])aList.toArray(new String[aList.size()]);
	session.setAttribute("selectedObjs", partIds);
	} 

	if(relEBOMMarkup!=null && relEBOMMarkup.size()>0){
	%>
			<script language="Javascript">	emxShowModalDialog('emxengchgChangeEBOMUpdateDialogFS.jsp?affectedaction=AffectedItemMassChange&suiteKey=<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>&objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&dojObjName=<xss:encodeForJavaScript><%=dojObjName%></xss:encodeForJavaScript>&partId=<xss:encodeForJavaScript><%=partId%></xss:encodeForJavaScript>&HelpMarker=emxhelpaffecteditemsedit&relationship=relationship_AffectedItem', 850,630,false);
			</script>
	<%}
	else{
	%>
		   <script language="Javascript">
		   alert("<emxUtil:i18nScript  localize="i18nId">emxEngineeringCentral.Alert.MassUpdate</emxUtil:i18nScript>");
		   </script>
	<%}
	%>
