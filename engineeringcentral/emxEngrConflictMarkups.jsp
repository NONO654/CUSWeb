<%--  emxEngrConflictMarkups.jsp  - Resolve Markup Conflict Page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@ include file = "emxDesignTopInclude.inc"%>
<%@ include file = "emxEngrVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@ page import="com.matrixone.jdom.Attribute,com.matrixone.jdom.Element"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%!
	public HashMap convertToStructureXML (Context context, Element eleRelationship, String strParentPartId) throws Exception
	{
		HashMap hmpReturnInfo = new HashMap();

		StringBuffer sbfHTML = new StringBuffer("");

		StringBuffer sbfAddXML = new StringBuffer("");
		StringBuffer sbfDeleteXML = new StringBuffer("");
		StringBuffer sbfModifyXML = new StringBuffer("");
		StringBuffer sbfFinalXML = new StringBuffer("<mxRoot>");
		StringBuffer sbfXMLTag  =  null;
		StringBuffer sbfAttrXMLTag = null;

		Element eleRoot = null;
		Element eleObjectInfo = null;
		Element eleRelatioshipInfo = null;
		Element eleAttribute = null;
		Element eleRelType = null;
		Element eleParentInfo = null;

		Attribute attrEBOMChgType = null;
		Attribute attrChgType = null;
		Attribute attrRelId = null;

		java.util.List listFromRelationships = null;
		java.util.List listFromAttributes = null;

		Iterator itrRelationships = null;
		Iterator itrAttributes = null;

		String strMarkupId = null;
		String strMarkupName = null;
		String strXMLFileName = null;
		String strPartType =  null;
		String strPartId =  null;
		String strRelId =  null;
		String strRelType =  null;
		String strPartName =  null;
		String strPartRev  =  null;
		String strPartVault  =  null;
		String strPartFN   =  null;
		String strPartRD   =  null;
		String strPartNewFN   =  null;
		String strPartNewRD   =  null;
		String strEBOMChgType  =  null;
		String strEBOMKey  =  null;
		String strAttrName  =  null;
		String strAttrValue  =  null;
		String strParentPartType =  null;
		String strParentPartName =  null;
		String strParentPartRev  =  null;
		String strParentPartVault  =  null;
		String strEBOMFN   =  null;
		String strEBOMRD   =  null;

		BusinessObject boMarkup = null;
		DomainObject doChild = null;
		DomainObject doParent = new DomainObject(strParentPartId);

		StringList strlPartSelects = new StringList(1);
		strlPartSelects.addElement(DomainConstants.SELECT_ID);

		StringList strlEBOMRelSelects = new StringList(1);
		strlEBOMRelSelects.addElement(DomainConstants.SELECT_RELATIONSHIP_ID);


		MapList mapListBOMs = null;

		eleObjectInfo = eleRelationship.getChild("relatedObject").getChild("businessObjectRef");
		eleRelatioshipInfo = eleRelationship.getChild("attributeList");
		eleRelType = eleRelationship.getChild("relationshipDefRef");

		//IR-045004: Decoding the encoded type, name,rev,vault
		//strPartType = eleObjectInfo.getChild("objectType").getText();
		//strPartName = eleObjectInfo.getChild("objectName").getText();
		//strPartRev  = eleObjectInfo.getChild("objectRevision").getText();
		//strPartVault  = eleObjectInfo.getChild("vaultRef").getText();

		strPartType = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectType").getText());
		//strPartName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectName").getText());
		if (null !=eleObjectInfo.getChild("objectNameEncoded")){
		    strPartName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectNameEncoded").getText());
		}
		else{
		strPartName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectName").getText());
		}
		strPartRev  = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectRevision").getText());
		strPartVault  = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("vaultRef").getText());

		int intNumHTMLCount = 0;

		strRelType = eleRelType.getText();

		if ((DomainConstants.RELATIONSHIP_EBOM).equals(strRelType))
		{
			strRelType = "relationship_EBOM";
		}

		doChild = new DomainObject(new BusinessObject(strPartType,strPartName,strPartRev,strPartVault));

		doChild.open(context);

		strPartId = doChild.getObjectId();

		doChild.close(context);

		attrEBOMChgType = eleRelationship.getAttribute("chgtype");

		strEBOMChgType = null;

		if (attrEBOMChgType != null )
		{
			strEBOMChgType = attrEBOMChgType.getValue();
		}

		attrRelId = eleRelType.getAttribute("relid");

		if (attrRelId != null)
		{
			strRelId = attrRelId.getValue();
		}

		listFromAttributes = eleRelatioshipInfo.getChildren();
		itrAttributes = listFromAttributes.iterator();

		if ("A".equals(strEBOMChgType))
		{

			strRelId = "";
			sbfXMLTag = new StringBuffer("<object objectId=\"");
			sbfXMLTag.append(strPartId);
			sbfXMLTag.append("\" relId=\"");
			sbfXMLTag.append(strRelId);
			sbfXMLTag.append("\" relType=\"");
			sbfXMLTag.append(strRelType);
			sbfXMLTag.append("\" markup=\"");
			sbfXMLTag.append("add");
			sbfXMLTag.append("\">");
			while (itrAttributes.hasNext())
			{
				eleAttribute = (Element) itrAttributes.next();

				strAttrName = eleAttribute.getChild("name").getText();

				sbfXMLTag.append("<column name=\"");
				sbfXMLTag.append(strAttrName);
				sbfXMLTag.append("\">");

				if ("Find Number".equals(strAttrName))
				{
					strAttrValue = eleAttribute.getChild("string").getText();

				}
				else if ("Reference Designator".equals(strAttrName))
				{
					strAttrValue = eleAttribute.getChild("string").getText();
				}
				else if ("Quantity".equals(strAttrName))
				{
					strAttrValue = eleAttribute.getChild("real").getText();
				}
				else if ("Component Location".equals(strAttrName))
				{
					strAttrValue = eleAttribute.getChild("string").getText();
				}
				else if ("Usage".equals(strAttrName))
				{
					strAttrValue = eleAttribute.getChild("string").getText();
				}
				else if ("Notes".equals(strAttrName))
				{
					strAttrValue = eleAttribute.getChild("string").getText();
				}
				else if ("Has Manufacturing Substitute".equals(strAttrName))
				{
					strAttrValue = eleAttribute.getChild("boolean").getText();
				}

				sbfXMLTag.append(strAttrValue);
				sbfXMLTag.append("</column>");

			}

			sbfXMLTag.append("<column name=\"");
			sbfXMLTag.append("Edit");
			sbfXMLTag.append("\">");
			sbfXMLTag.append("");
			sbfXMLTag.append("</column>");

			sbfXMLTag.append("</object>");

			sbfAddXML.append(sbfXMLTag);

			hmpReturnInfo.put("XMLINFO", sbfAddXML);
			hmpReturnInfo.put("HTMLINFO", sbfHTML);
			return hmpReturnInfo;



		}
		else if ("D".equals(strEBOMChgType))
		{
			strRelId = null;
			 if (strRelId == null || strRelId.length() <=0)
			{

				while (itrAttributes.hasNext())
				{
					eleAttribute = (Element) itrAttributes.next();

					strAttrName = eleAttribute.getChild("name").getText();

					if ("Find Number".equals(strAttrName))
					{
						strEBOMFN = eleAttribute.getChild("string").getText();

					}
					else if ("Reference Designator".equals(strAttrName))
					{
						strEBOMRD = eleAttribute.getChild("string").getText();
					}

				}

				String strObjWhereClause = "id == \"" + strPartId + "\"";

				String strRelWhereClause = null;

				if (strEBOMFN.length() > 0 )
				{
					strRelWhereClause = DomainConstants.SELECT_FIND_NUMBER + " == \"" + strEBOMFN + "\"";
				}

				if (strEBOMRD.length() > 0 )
				{
					if (strRelWhereClause != null)
					{
						strRelWhereClause = strRelWhereClause + " && " + DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR + " == \"" + strEBOMRD + "\"";
					}
					else
					{
						strRelWhereClause = DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR + " == \"" + strEBOMRD + "\"";
					}
				}


				mapListBOMs = doParent.getRelatedObjects(context,
									DomainConstants.RELATIONSHIP_EBOM,  // relationship pattern
									DomainConstants.TYPE_PART,          // object pattern
									strlPartSelects,                 // object selects
									strlEBOMRelSelects,              // relationship selects
									false,                        // to direction
									true,                       // from direction
									(short)1,                    // recursion level
									strObjWhereClause,                        // object where clause
									strRelWhereClause);


				if (mapListBOMs == null || mapListBOMs.size() == 0)
				{
					hmpReturnInfo.put("XMLINFO", new StringBuffer());
					hmpReturnInfo.put("HTMLINFO", new StringBuffer());
					return hmpReturnInfo;
				}

				Map mapBOM = (Map) mapListBOMs.get(0);
				strRelId = (String) mapBOM.get(DomainConstants.SELECT_RELATIONSHIP_ID);
			}

			sbfXMLTag = new StringBuffer("<object objectId=\"");
			sbfXMLTag.append(strPartId);
			sbfXMLTag.append("\" relId=\"");
			sbfXMLTag.append(strRelId);
			sbfXMLTag.append("\" relType=\"");
			sbfXMLTag.append(strRelType);
			sbfXMLTag.append("\" markup=\"");
			sbfXMLTag.append("cut");
			sbfXMLTag.append("\"/>");

			sbfDeleteXML.append(sbfXMLTag);

			hmpReturnInfo.put("XMLINFO", sbfDeleteXML);
			hmpReturnInfo.put("HTMLINFO", sbfHTML);
			return hmpReturnInfo;


		}
		else if ("C".equals(strEBOMChgType))
		{

			sbfAttrXMLTag = new StringBuffer("");

			while (itrAttributes.hasNext())
			{
				eleAttribute = (Element) itrAttributes.next();

				strAttrName = eleAttribute.getChild("name").getText();

				attrChgType = eleAttribute.getAttribute("chgtype");

				strAttrValue = null;
				String strAttrOldValue = null;

				if ("Find Number".equals(strAttrName))
				{
					if (attrChgType != null)
					{
						strEBOMFN = eleAttribute.getChild("oldvalue").getText();
						strAttrValue = eleAttribute.getChild("newvalue").getText();
						strAttrOldValue = eleAttribute.getChild("oldvalue").getText();
					}
					else
					{
						strEBOMFN = eleAttribute.getChild("string").getText();
					}

				}
				else if ("Reference Designator".equals(strAttrName))
				{
					if (attrChgType != null)
					{
						strEBOMRD = eleAttribute.getChild("oldvalue").getText();
						strAttrValue = eleAttribute.getChild("newvalue").getText();
						strAttrOldValue = eleAttribute.getChild("oldvalue").getText();
					}
					else
					{
						strEBOMRD = eleAttribute.getChild("string").getText();
					}
				}
				else if ("Quantity".equals(strAttrName))
				{
					if (attrChgType != null)
					{
						strAttrValue = eleAttribute.getChild("newvalue").getText();
						strAttrOldValue = eleAttribute.getChild("oldvalue").getText();
					}

				}
				else if ("Component Location".equals(strAttrName))
				{
					if (attrChgType != null)
					{
						strAttrValue = eleAttribute.getChild("newvalue").getText();
						strAttrOldValue = eleAttribute.getChild("oldvalue").getText();
					}

				}
				else if ("Usage".equals(strAttrName))
				{
					if (attrChgType != null)
					{
						strAttrValue = eleAttribute.getChild("newvalue").getText();
						strAttrOldValue = eleAttribute.getChild("oldvalue").getText();
					}
				}
				else if ("Notes".equals(strAttrName))
				{
					if (attrChgType != null)
					{
						strAttrValue = eleAttribute.getChild("newvalue").getText();
						strAttrOldValue = eleAttribute.getChild("oldvalue").getText();
					}


				}

				if (strAttrValue != null)
				{
					sbfAttrXMLTag.append("<column name=\"");
					sbfAttrXMLTag.append(strAttrName);
					sbfAttrXMLTag.append("\">");
					sbfAttrXMLTag.append(strAttrValue);
					sbfAttrXMLTag.append("</column>");

					if (intNumHTMLCount > 0)
					{
						sbfHTML.append("<P/>");
					}
					sbfHTML.append(strAttrName);
					sbfHTML.append(": <FONT COLOR=\"#FF0000\"><S>");
					sbfHTML.append(strAttrOldValue);
					sbfHTML.append("</S></FONT> ");
					sbfHTML.append(strAttrValue);

					intNumHTMLCount ++;
				}
			}
			strRelId = null;
			if (strRelId == null || strRelId.length() <=0)
			{

				String strObjWhereClause = "id == \"" + strPartId + "\"";

				String strRelWhereClause = null;

				if (strEBOMFN.length() > 0 )
				{
					strRelWhereClause = DomainConstants.SELECT_FIND_NUMBER + " == \"" + strEBOMFN + "\"";
				}

				if (strEBOMRD.length() > 0 )
				{
					if (strRelWhereClause != null)
					{
						strRelWhereClause = strRelWhereClause + " && " + DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR + " == \"" + strEBOMRD + "\"";
					}
					else
					{
						strRelWhereClause = DomainConstants.SELECT_ATTRIBUTE_REFERENCE_DESIGNATOR + " == \"" + strEBOMRD + "\"";
					}
				}

				mapListBOMs = doParent.getRelatedObjects(context,
									DomainConstants.RELATIONSHIP_EBOM,  // relationship pattern
									DomainConstants.TYPE_PART,          // object pattern
									strlPartSelects,                 // object selects
									strlEBOMRelSelects,              // relationship selects
									false,                        // to direction
									true,                       // from direction
									(short)1,                    // recursion level
									strObjWhereClause,                        // object where clause
									strRelWhereClause);

				if (mapListBOMs == null || mapListBOMs.size() == 0)
				{
					hmpReturnInfo.put("XMLINFO", new StringBuffer());
					hmpReturnInfo.put("HTMLINFO", new StringBuffer());
					return hmpReturnInfo;
				}

				Map mapBOM = (Map) mapListBOMs.get(0);
				strRelId = (String) mapBOM.get(DomainConstants.SELECT_RELATIONSHIP_ID);
			}


			sbfXMLTag = new StringBuffer("<object objectId=\"");
			sbfXMLTag.append(strPartId);
			sbfXMLTag.append("\" relId=\"");
			sbfXMLTag.append(strRelId);
			sbfXMLTag.append("\" parentId=\"");
			sbfXMLTag.append(strParentPartId);
			sbfXMLTag.append("\" relType=\"");
			sbfXMLTag.append(strRelType);
			sbfXMLTag.append("\" markup=\"");
			sbfXMLTag.append("changed");
			sbfXMLTag.append("\">");
			sbfXMLTag.append(sbfAttrXMLTag);
			sbfXMLTag.append("</object>");

			sbfModifyXML.append(sbfXMLTag);

			hmpReturnInfo.put("XMLINFO", sbfModifyXML);
			hmpReturnInfo.put("HTMLINFO", sbfHTML);
			return hmpReturnInfo;

		}

		return hmpReturnInfo;

	}
	%>
<%
    String languageStr      = request.getHeader("Accept-Language");

	String searchMode = null;



  String emxSuiteDirectory = emxGetParameter(request,"emxSuiteDirectory");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String relId = emxGetParameter(request,"relId");
  String objectId = emxGetParameter(request,"objectId");
  String parentOID = emxGetParameter(request,"parentOID");

  String strKey = emxGetParameter(request,"key");
  String strLevel = emxGetParameter(request,"level");
  String printerFriendly = emxGetParameter(request, "PrinterFriendly");
  boolean isPrinterFriendly = false;
  if (printerFriendly != null && !"null".equals(printerFriendly) && !"".equals(printerFriendly)) {
	    isPrinterFriendly = "true".equals(printerFriendly);
	  }

	Hashtable htConflicts = (Hashtable) session.getAttribute("ConflictList");

	MapList totalresultList = new MapList();

	HashMap hmpMarkUpInfo = null;


	ArrayList arlConflicts = null;

	Element eleRelationship = null;

	String strMarkupName = null;

	StringBuffer sbfReturnXML = null;

	StringBuffer sbfFinalXML = null;

	StringBuffer sbfHTML = null;

	String strChgTypeVal = null;

	Iterator itrRelationships = null;

	HashMap hmpReturnInfo = null;

	if(htConflicts.containsKey(strKey)){
		arlConflicts = (ArrayList) htConflicts.get(strKey);

		itrRelationships = arlConflicts.iterator();

		while (itrRelationships.hasNext())
		{
			hmpMarkUpInfo = new HashMap();
			eleRelationship = (Element) itrRelationships.next();

			strChgTypeVal = eleRelationship.getAttribute("chgtype").getValue();

			strMarkupName = eleRelationship.getAttribute("markupname").getValue();

			hmpMarkUpInfo.put("Markup Name", strMarkupName);

			sbfFinalXML = new StringBuffer("<mxRoot>");


			hmpReturnInfo = (HashMap) convertToStructureXML(context, eleRelationship, parentOID);
			sbfReturnXML = (StringBuffer) hmpReturnInfo.get("XMLINFO");
			sbfHTML = (StringBuffer) hmpReturnInfo.get("HTMLINFO");


			if ("A".equals(strChgTypeVal))
			{
				sbfFinalXML.append("<object objectId=\"");
				sbfFinalXML.append(parentOID);
				sbfFinalXML.append("\">");
				sbfFinalXML.append(sbfReturnXML);
				sbfFinalXML.append("</object>");
				hmpMarkUpInfo.put("Change", "Add");
			}
			else if ("C".equals(strChgTypeVal))
			{
				sbfFinalXML.append(sbfReturnXML);
				hmpMarkUpInfo.put("Change", sbfHTML.toString());
			}
			else if ("D".equals(strChgTypeVal))
			{
				sbfFinalXML.append("<object objectId=\"");
				sbfFinalXML.append(parentOID);
				sbfFinalXML.append("\">");
				sbfFinalXML.append(sbfReturnXML);
				sbfFinalXML.append("</object>");
				hmpMarkUpInfo.put("Change", "Delete");
			}

			sbfFinalXML.append("</mxRoot>");
			hmpMarkUpInfo.put("XMLInfo", sbfFinalXML.toString());

			totalresultList.add(hmpMarkUpInfo);
		}
	}

String queryString = emxGetQueryString(request);
String defaultTypeIcon    = JSPUtil.getCentralProperty(application, session, "type_Default", "SmallIcon");
//Multitenant
//String markupName = i18nNow.getI18nString("emxEngineeringCentral.Markup.MarkupName","emxEngineeringCentralStringResource",languageStr) ;
String markupName = EnoviaResourceBundle.getProperty(Framework.getContext(session),"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.MarkupName"); 
//Multitenant
//String confilctName = i18nNow.getI18nString("emxEngineeringCentral.Markup.MarkupConflict","emxEngineeringCentralStringResource",languageStr) ;
String confilctName = EnoviaResourceBundle.getProperty(Framework.getContext(session),"emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.MarkupConflict");

%>

</script>
 <script language="Javascript">
	
<%
if (isPrinterFriendly) {%>
	addStyleSheet("emxUIDefaultPF");
	addStyleSheet("emxUILifecyclePF");
<%} else {%>
  addStyleSheet("emxUIDefault");
  addStyleSheet("emxUIList");
  <%}%>
 </script>
 
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<script language="Javascript">

    function submit()
    {
		var checkedValue = "";
		var fieldValue = "";
		var j = 0;
		for ( var i = 0; i < document.formConflictMarkup.elements.length; i++ ) {
		if (document.formConflictMarkup.elements[i].type == "checkbox" ||document.formConflictMarkup.elements[i].type == "radio"){
		  if( document.formConflictMarkup.elements[i].checked && document.formConflictMarkup.elements[i].name.indexOf('MarkupName') > -1){
			checkedValue += document.formConflictMarkup.elements[i].value + ",";
			fieldValue = "fieldId"+j;
		  }
		  j++;

		}

    }
    if(checkedValue == "") {
       alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.ErrorMsg.SelectMarkup</emxUtil:i18nScript>");
       return;
    }
    else
    {
		document.formConflictMarkup.action="emxEngrConflictMarkupsProcess.jsp?checkedValue="+checkedValue+"&fieldId="+fieldValue;
		document.formConflictMarkup.submit();
	}
    }

</script>

  <fw:sortInit
    defaultSortKey="<%= DomainObject.SELECT_NAME %>"
    defaultSortType="string"
    resourceBundle="emxEngineeringCentralStringResource"
    mapList="<%= totalresultList %>"
    params="<%= queryString %>"
    ascendText="emxEngineeringCentral.Common.SortAscending"
    descendText="emxEngineeringCentral.Common.SortDescending" />

<form name="formConflictMarkup" method="post" action="" onSubmit="javascript:submit()">
  <table class="list">
    <tr>
    
     <%
      if (!isPrinterFriendly) {
	 %>
      <th>&nbsp;</th>
      <th nowrap="nowrap">
        <fw:sortColumnHeader
          title="<%=markupName %>"
           
          sortKey="<%= DomainObject.SELECT_NAME %>"
          sortType="string"/>
      </th>

      <th nowrap="nowrap">
        <fw:sortColumnHeader
          title="<%=confilctName %>"
          
          sortKey="Conflict"
          sortType="string" />
      </th>
	<%
        }
      else{
	%>	
	
      <th nowrap="nowrap">
      <!-- XSSOK -->
         <%=markupName %>            
      </th>
      <th nowrap="nowrap">        
      <!-- XSSOK -->    
         <%=confilctName %>               
      </th>
	<%
        }
	 %>

<%
      int i=0;
%>
      <fw:mapListItr mapList="<%= totalresultList %>" mapName="resultsMap">
<%
        String objectName      = (String)resultsMap.get("Markup Name");
		session.setAttribute("fieldId" + i++, (String)resultsMap.get("XMLInfo"));
		
		String changeVal = null;
		String attriConv = null;
		String finalVal = null;
		StringList strListTemp = null;
		changeVal = (String)resultsMap.get("Change");
		strListTemp =  FrameworkUtil.split(changeVal,":");
		
		if(strListTemp.size()==2){
		 attriConv = i18nNow.getAttributeI18NString((String)strListTemp.get(0),languageStr);
		 finalVal = attriConv+":"+strListTemp.get(1);
		}
		else if(strListTemp.size()==1 && strListTemp.get(0).equals("Delete"))
		{
			//Multitenant
			//finalVal = i18nNow.getI18nString("emxEngineeringCentral.Button.Delete","emxEngineeringCentralStringResource",languageStr) ;
			finalVal = EnoviaResourceBundle.getProperty(Framework.getContext(session), "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Button.Delete");
		}
		else
			finalVal = changeVal;
		
		session.setAttribute("count", i);
	if (!isPrinterFriendly) {
%>
      <!-- XSSOK -->
        <tr class='<fw:swap id="even"/>'>
        <td><input type="radio" name="MarkupName" value="<xss:encodeForHTMLAttribute><%=objectName %></xss:encodeForHTMLAttribute>" /></td>
          <td><img src="../common/images/<%=defaultTypeIcon%>" border="0" /><xss:encodeForHTML><%=objectName%></xss:encodeForHTML>&nbsp;</td>
          <!-- XSSOK -->
        <td><%=i18nNow.getTypeI18NString((String)resultsMap.get("Change"),languageStr)%>&nbsp;</td>
        </tr>
				<%
					} else {
				%>
				<!-- XSSOK -->
				<tr class='<fw:swap id="even"/>'>
					<!-- <td><name="MarkupName" value="<xss:encodeForHTMLAttribute><%=objectName%></xss:encodeForHTMLAttribute>" /></td>-->
					<td><img src="../common/images/<%=defaultTypeIcon%>"
						border="0" />
					<xss:encodeForHTML><%=objectName%></xss:encodeForHTML>&nbsp;</td>
					<!-- XSSOK -->
					<td><%=i18nNow.getTypeI18NString(
							(String) resultsMap.get("Change"), languageStr)%>&nbsp;</td>
				</tr>
				<%
					}
			
				%>
    </fw:mapListItr>
<%
    if (totalresultList.size() == 0){
%>
      <tr class="even" ><td colspan="5" align="center" ><emxUtil:i18n localize="i18nId">emxEngineeringCentral.BasicSearch.TxtStatusNoResults</emxUtil:i18n></td></tr>
<%
    }
%>
  </table>
  <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="level" value="<xss:encodeForHTMLAttribute><%=strLevel%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="key" value="<xss:encodeForHTMLAttribute><%=strKey%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="relId" value="<xss:encodeForHTMLAttribute><%=relId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="parentOID" value="<xss:encodeForHTMLAttribute><%=parentOID%></xss:encodeForHTMLAttribute>" />
 </form>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

