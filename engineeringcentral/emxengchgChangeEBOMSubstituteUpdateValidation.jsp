<%--  emxengchgChangeEBOMSubstituteUpdateValidation.jsp   -   Validation page for Mass Change
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

 <%
  framesetObject fs = new framesetObject();

  fs.setDirectory(appDirectory);

  String initSource = emxGetParameter(request,"initSource");
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

			domObj.setId(objectId);
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
  partId = objectId;
  String strEBOMSubRelName = PropertyUtil.getSchemaProperty(context,"relationship_EBOMSubstitute");
  String strEBOMRelName = PropertyUtil.getSchemaProperty(context,"relationship_EBOM");
  StringList relEBOMMarkup  = partObj.getInfoList(context,"from["+strEBOMRelName+"].frommid["+strEBOMSubRelName+"].to.id");
  StringList relEBORel  = partObj.getInfoList(context,"from["+strEBOMRelName+"].frommid["+strEBOMSubRelName+"].id");
	if(relEBOMMarkup!=null && relEBOMMarkup.size()>0)
	{
		int iSize = relEBOMMarkup.size();
		for(int i=0;i<iSize;i++)
		{
			if( i < iSize-1)
			{
				selectedObjs = selectedObjs + relEBOMMarkup.get(i).toString() +",";
			}
			else
			{
				selectedObjs = selectedObjs + relEBOMMarkup.get(i).toString();
			}
		}
	}
				
	if(selectedObjs.indexOf(",")<0)
	{
	  String[] selectedObjects = new String[1];
	  selectedObjects[0] = (String)relEBORel.get(0)+", "+objectId;
	  session.setAttribute("selectedObjs", selectedObjects);
	}
	else
	{
	StringList busSelects = new StringList(2);
	busSelects.add(DomainConstants.SELECT_ID);
	busSelects.add(DomainConstants.SELECT_TYPE);
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
	for(i=0; i<selectedObjects.length; i++)
	{
		aList.add(selectedObjects[i]);
	}
	String[] partIds = (String[])aList.toArray(new String[aList.size()]);
	session.setAttribute("selectedObjs", partIds);
	} 
	
	if(relEBOMMarkup!=null && relEBOMMarkup.size()>0){
	%>
			<!-- XSSOK -->
			<script language="Javascript">	emxShowModalDialog('emxengchgChangeEBOMSubstituteUpdateDialogFS.jsp?affectedaction=AffectedItemSubstituteMassChange&objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&dojObjName=<%=dojObjName%>&partId=<%=partId%>&HelpMarker=emxhelpaffecteditemsedit&relationship=relationship_AffectedItem', 750,600,false);
			</script>
	<%}
	else{
	%>
		   <script language="Javascript">
		   alert("<emxUtil:i18nScript  localize="i18nId">emxEngineeringCentral.Alert.SubstituteMassChangeUpdate</emxUtil:i18nScript>");
		   </script>
	<%}
	%>
