<%--  emxEngrMarkupPreProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@ page import="java.util.*,java.io.*,
                com.matrixone.jdom.*,
                com.matrixone.jdom.output.*,
                com.matrixone.apps.engineering.*,
                com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.ContextUtil"%>


<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>


<%
ContextUtil.pushContext(context);
%>


<%!
	public String mergeMarkupsForOpening(Context context, StringList strlMarkupIds, String strPartId, Hashtable htConflictBOMs) throws Exception
	{
		Hashtable htChangedBOMs = new Hashtable();
		Hashtable htNewChangedBOMs = new Hashtable();
		Hashtable htAddedBOMs = new Hashtable();
		Hashtable htDeletedBOMs = new Hashtable();
		Hashtable htUnChangedBOMs = new Hashtable();

		String XMLFORMAT = PropertyUtil.getSchemaProperty(context, "format_XML");
		String strLanguage = context.getSession().getLanguage(); //Added for IR-149745

		// create a temporary workspace directory
		String strTransPath = context.createWorkspace();
  		java.io.File fEmatrixWebRoot = new java.io.File(strTransPath);

		Iterator itrMarkups = strlMarkupIds.iterator();

		BusinessObject boMarkup = null;

		String strMarkupId = null;
		String strMarkupName = null;
		String strXMLFileName = null;

		com.matrixone.jdom.input.SAXBuilder builder = new com.matrixone.jdom.input.SAXBuilder();
		builder.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
		builder.setFeature("http://xml.org/sax/features/external-general-entities", false);
		builder.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
		Document docXML = null;

		Element eleRoot = null;
		Element eleRelatioship = null;
		Element eleObjectInfo = null;
		Element eleRelatioshipInfo = null;
		Element eleAttribute = null;

		Element eleBusinessObject = null;
		Element eleCreationProps = null;

		Element eleMergedMarkup = new Element("ematrix");
		Element eleMergedRelationships = null;

		java.util.List listFromRelationships = null;
		java.util.List listFromAttributes = null;

		Iterator itrRelationships = null;
		Iterator itrAttributes = null;

		com.matrixone.jdom.Attribute attrEBOMChgType = null;
		com.matrixone.jdom.Attribute attrChgType = null;

		Element eleConflictRelationship = null;

		String strPartType =  null;
		String strPartName =  null;
		String strPartRev  =  null;
		String strPartFN   =  null;
		String strPartRD   =  null;
		String strPartNewFN   =  null;
		String strPartNewRD   =  null;
		String strEBOMChgType  =  null;
		String strEBOMKey  =  null;

		boolean bolIsConflict = false;

		while (itrMarkups.hasNext())
		{
			strMarkupId = (String) itrMarkups.next();

			boMarkup = new BusinessObject(strMarkupId);

			boMarkup.open(context);

			strMarkupName = MqlUtil.mqlCommand(context, "print bus $1 select $2 dump", strMarkupId,"name");

			strXMLFileName = strMarkupName + ".xml";

			boMarkup.checkoutFile(context, false, XMLFORMAT, strXMLFileName, strTransPath);

			boMarkup.close(context);

  			java.io.File fMarkupXML = new java.io.File(fEmatrixWebRoot, strXMLFileName);

  			if (fMarkupXML == null)
  			{
				continue;
			}

			docXML = builder.build(fMarkupXML);
			eleRoot = docXML.getRootElement();

			eleBusinessObject = eleRoot.getChild("businessObject");
			eleCreationProps = eleRoot.getChild("creationProperties");

           listFromRelationships = eleRoot.getChild("businessObject").getChild("fromRelationshipList").getChildren();
           itrRelationships = listFromRelationships.iterator();

           try
           {

			while (itrRelationships.hasNext())
			{
				eleRelatioship = (Element) itrRelationships.next();
				eleRelatioship.setAttribute("markupname", strMarkupName);
				eleObjectInfo = eleRelatioship.getChild("relatedObject").getChild("businessObjectRef");
				eleRelatioshipInfo = eleRelatioship.getChild("attributeList");
                //IR-058430V6R2011x
				//IR-021110: Decoding the encoded type, name,rev
				//strPartType = eleObjectInfo.getChild("objectType").getText();
				strPartType = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectType").getText());
				//strPartName = eleObjectInfo.getChild("objectName").getText();
				if (null !=eleObjectInfo.getChild("objectNameEncoded")){
				    strPartName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectNameEncoded").getText());
				}
				else{
				strPartName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectName").getText());
				}
				//strPartRev  = eleObjectInfo.getChild("objectRevision").getText();
				strPartRev  = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectRevision").getText());
				//End



				attrEBOMChgType = eleRelatioship.getAttribute("chgtype");

				listFromAttributes = eleRelatioshipInfo.getChildren();
				itrAttributes = listFromAttributes.iterator();

				strEBOMChgType = null;

				if (attrEBOMChgType != null )
				{
					strEBOMChgType = attrEBOMChgType.getValue();
				}

				if (strEBOMChgType == null || "A".equals(strEBOMChgType) || "D".equals(strEBOMChgType))
				{
					while (itrAttributes.hasNext())
					{
						eleAttribute = (Element) itrAttributes.next();

						if ("Find Number".equals(eleAttribute.getChild("name").getText()))
						{
							strPartFN = eleAttribute.getChild("string").getText();
						}
						else if ("Reference Designator".equals(eleAttribute.getChild("name").getText()))
						{
							strPartRD = eleAttribute.getChild("string").getText();
						}
					}
				}
				else
				{
					while (itrAttributes.hasNext())
					{
						eleAttribute = (Element) itrAttributes.next();

						attrChgType = eleAttribute.getAttribute("chgtype");

						if ("Find Number".equals(eleAttribute.getChild("name").getText()))
						{
							if (attrChgType != null)
							{
								strPartFN = eleAttribute.getChild("oldvalue").getText();
								strPartNewFN = eleAttribute.getChild("newvalue").getText();
							}
							else
							{
								strPartFN = eleAttribute.getChild("string").getText();
							}
						}
						else if ("Reference Designator".equals(eleAttribute.getChild("name").getText()))
						{
							if (attrChgType != null)
							{
								strPartRD = eleAttribute.getChild("oldvalue").getText();
								strPartNewRD = eleAttribute.getChild("newvalue").getText();
							}
							else
							{
								strPartRD = eleAttribute.getChild("string").getText();
							}
						}
					}
				}

				strEBOMKey = strPartType + "~" + strPartName + "~" + strPartRev + "~" + strPartFN + "~" + strPartRD;

				if (strEBOMChgType == null)
				{

					if (!htDeletedBOMs.containsKey(strEBOMKey) && !htChangedBOMs.containsKey(strEBOMKey) && !htUnChangedBOMs.containsKey(strEBOMKey))
					{
						htUnChangedBOMs.put(strEBOMKey, eleRelatioship);
					}
				}
				else if ("D".equals(strEBOMChgType))
				{
					if (htChangedBOMs.containsKey(strEBOMKey) || htAddedBOMs.containsKey(strEBOMKey) || htConflictBOMs.containsKey(strEBOMKey))
					{
						bolIsConflict = true;
						if (htChangedBOMs.containsKey(strEBOMKey))
						{
							eleConflictRelationship = (Element)htChangedBOMs.get(strEBOMKey);
							htChangedBOMs.remove(strEBOMKey);
						}
						else if (htAddedBOMs.containsKey(strEBOMKey))
						{
							eleConflictRelationship = (Element)htAddedBOMs.get(strEBOMKey);
							htAddedBOMs.remove(strEBOMKey);
						}
						if (htConflictBOMs.containsKey(strEBOMKey))
						{
							ArrayList arlConflict = (ArrayList) htConflictBOMs.get(strEBOMKey);

							if (!arlConflict.contains(eleConflictRelationship))
							{
								arlConflict.add(eleConflictRelationship);
							}

							arlConflict.add(eleRelatioship);

							htConflictBOMs.remove(strEBOMKey);
							htConflictBOMs.put(strEBOMKey, arlConflict);
						}
						else
						{
							ArrayList arlConflict = new ArrayList();

							arlConflict.add(eleConflictRelationship);
							arlConflict.add(eleRelatioship);

							htConflictBOMs.put(strEBOMKey, arlConflict);
						}

					}
					else
					{
						htDeletedBOMs.put(strEBOMKey, eleRelatioship);
						if (htUnChangedBOMs.containsKey(strEBOMKey))
						{
							htUnChangedBOMs.remove(strEBOMKey);
						}
					}

				}
				else if ("C".equals(strEBOMChgType))
				{
					if (htDeletedBOMs.containsKey(strEBOMKey) || htChangedBOMs.containsKey(strEBOMKey) || htAddedBOMs.containsKey(strEBOMKey) || htConflictBOMs.containsKey(strEBOMKey))
					{
						bolIsConflict = true;
						if (htDeletedBOMs.containsKey(strEBOMKey))
						{
							eleConflictRelationship = (Element)htDeletedBOMs.get(strEBOMKey);
							htDeletedBOMs.remove(strEBOMKey);
						}
						else if (htChangedBOMs.containsKey(strEBOMKey))
						{
							eleConflictRelationship = (Element)htChangedBOMs.get(strEBOMKey);
							htChangedBOMs.remove(strEBOMKey);
						}
						else if (htAddedBOMs.containsKey(strEBOMKey))
						{
							eleConflictRelationship = (Element)htAddedBOMs.get(strEBOMKey);
							htAddedBOMs.remove(strEBOMKey);
						}
						if (htConflictBOMs.containsKey(strEBOMKey))
						{
							ArrayList arlConflict = (ArrayList) htConflictBOMs.get(strEBOMKey);

							if (!arlConflict.contains(eleConflictRelationship))
							{
								arlConflict.add(eleConflictRelationship);
							}

							arlConflict.add(eleRelatioship);

							htConflictBOMs.remove(strEBOMKey);
							htConflictBOMs.put(strEBOMKey, arlConflict);
						}
						else
						{
							ArrayList arlConflict = new ArrayList();

							if (!arlConflict.contains(eleConflictRelationship))
							{
								arlConflict.add(eleConflictRelationship);
							}

							arlConflict.add(eleRelatioship);

							htConflictBOMs.put(strEBOMKey, arlConflict);
						}
					}
					else
					{
						htChangedBOMs.put(strEBOMKey, eleRelatioship);
						if (htUnChangedBOMs.containsKey(strEBOMKey))
						{
							htUnChangedBOMs.remove(strEBOMKey);
						}

					}
					if (strPartNewFN != null)
					{
						strEBOMKey = strPartType + "~" + strPartName + "~" + strPartRev + "~" + strPartNewFN;
					}
					else
					{
						strEBOMKey = strPartType + "~" + strPartName + "~" + strPartRev + "~" + strPartFN;
					}

					if (strPartNewRD != null)
					{
						strEBOMKey =  strEBOMKey + "~" + strPartNewRD;
					}
					else
					{
						strEBOMKey =  strEBOMKey + "~" + strPartRD;
					}

					if (htNewChangedBOMs.containsKey(strEBOMKey))
					{

					}
					else
					{
						htNewChangedBOMs.put(strEBOMKey, eleRelatioship);
					}
				}
				else if ("A".equals(strEBOMChgType))
				{
					if (htDeletedBOMs.containsKey(strEBOMKey) || htNewChangedBOMs.containsKey(strEBOMKey) || htConflictBOMs.containsKey(strEBOMKey))
					{
						bolIsConflict = true;
						if (htDeletedBOMs.containsKey(strEBOMKey))
						{
							eleConflictRelationship = (Element)htDeletedBOMs.get(strEBOMKey);
							htDeletedBOMs.remove(strEBOMKey);
						}
						else if (htNewChangedBOMs.containsKey(strEBOMKey))
						{
							eleConflictRelationship = (Element)htNewChangedBOMs.get(strEBOMKey);
							htNewChangedBOMs.remove(strEBOMKey);
						}
						else if (htAddedBOMs.containsKey(strEBOMKey))
						{
							eleConflictRelationship = (Element)htAddedBOMs.get(strEBOMKey);
							htAddedBOMs.remove(strEBOMKey);
						}
						if (htConflictBOMs.containsKey(strEBOMKey))
						{
							ArrayList arlConflict = (ArrayList) htConflictBOMs.get(strEBOMKey);

							if (!arlConflict.contains(eleConflictRelationship))
							{
								arlConflict.add(eleConflictRelationship);
							}

							arlConflict.add(eleRelatioship);

							htConflictBOMs.remove(strEBOMKey);
							htConflictBOMs.put(strEBOMKey, arlConflict);
						}
						else
						{
							ArrayList arlConflict = new ArrayList();

							arlConflict.add(eleConflictRelationship);
							arlConflict.add(eleRelatioship);

							htConflictBOMs.put(strEBOMKey, arlConflict);
						}
					}
					else
					{
						htAddedBOMs.put(strEBOMKey, eleRelatioship);
					}
				}

			}
		}
		catch (Exception e)
		{
		}

		}

		eleMergedRelationships = new Element("fromRelationshipList");
		eleMergedRelationships.setAttribute("count", "" + htAddedBOMs.size() + htDeletedBOMs.size() + htChangedBOMs.size());

		StringBuffer sbfAddXML = new StringBuffer("");
		StringBuffer sbfDeleteXML = new StringBuffer("");
		StringBuffer sbfModifyXML = new StringBuffer("");
		StringBuffer sbfFinalXML = new StringBuffer("<mxRoot>");

		Element eleTemp = null;

		Enumeration enumKeys = htAddedBOMs.keys();


		while (enumKeys.hasMoreElements())
		{
			String strKey = (String) enumKeys.nextElement();
			eleTemp = (Element) htAddedBOMs.get(strKey);
			sbfAddXML.append(convertToStructureXML(context, (Element) eleTemp.detach(), strPartId));
		}


		enumKeys = htDeletedBOMs.keys();

		while (enumKeys.hasMoreElements())
		{
			String strKey = (String) enumKeys.nextElement();
			eleTemp = (Element) htDeletedBOMs.get(strKey);
			sbfDeleteXML.append(convertToStructureXML(context, (Element) eleTemp.detach(), strPartId));
		}


		enumKeys = htChangedBOMs.keys();


		while (enumKeys.hasMoreElements())
		{
			String strKey = (String) enumKeys.nextElement();
			eleTemp = (Element) htChangedBOMs.get(strKey);
			sbfModifyXML.append(convertToStructureXML(context, (Element) eleTemp.detach(), strPartId));
		}


		if (sbfAddXML.length() > 0 || sbfDeleteXML.length() > 0)
		{
			sbfFinalXML.append("<object objectId=\"");
			sbfFinalXML.append(strPartId);
			sbfFinalXML.append("\">");
			sbfFinalXML.append(sbfAddXML);
			sbfFinalXML.append(sbfDeleteXML);
			sbfFinalXML.append("</object>");
		}

		if (sbfModifyXML.length() > 0)
		{
			sbfFinalXML.append(sbfModifyXML);
		}

		enumKeys = htConflictBOMs.keys();
		ArrayList arlElements = null;
		Iterator itrList = null;
		com.matrixone.jdom.Attribute attrConflictEBOMChgType = null;
		com.matrixone.jdom.Attribute attrConflictChgType = null;
		com.matrixone.jdom.Attribute attrConflictMarkup = null;
		String strConflictEBOMMarkup = null;
		String strConflictEBOMChgType = null;
		String strAttrValue = null;
		String strAttrName = null;
		Element eleConflictAttribute = null;
		HashMap hmpAttributes = null;
		HashMap hmpConflictAttributes = null;

		java.util.List listConflictFromAttributes = null;
		Iterator itrConflictAttributes = null;

		ArrayList arlNoConflicts = new ArrayList();
		ArrayList arlConflicts = new ArrayList();

		Hashtable htNewConflicts = new Hashtable();

		boolean blnOtherChange = true;

		while (enumKeys.hasMoreElements())
		{
			String strKey = (String) enumKeys.nextElement();
			arlElements = (ArrayList) htConflictBOMs.get(strKey);
			itrList = arlElements.iterator();

			hmpAttributes = new HashMap();
			hmpConflictAttributes = new HashMap();

			arlConflicts = new ArrayList();

			blnOtherChange = true;

			while (itrList.hasNext())
			{
				strConflictEBOMChgType = null;
				strConflictEBOMMarkup = null;
				eleTemp = (Element) itrList.next();
				attrConflictEBOMChgType = eleTemp.getAttribute("chgtype");

				if (attrConflictEBOMChgType != null)
				{
					strConflictEBOMChgType = attrConflictEBOMChgType.getValue();
				}

				if ("C".equals(strConflictEBOMChgType))
				{
					Element eleConflictRelatioshipInfo = eleTemp.getChild("attributeList");
					listConflictFromAttributes = eleConflictRelatioshipInfo.getChildren();
					itrConflictAttributes = listConflictFromAttributes.iterator();

					while (itrConflictAttributes.hasNext())
					{
						eleConflictAttribute = (Element) itrConflictAttributes.next();

						strAttrName = eleConflictAttribute.getChild("name").getText();

						attrConflictChgType = eleConflictAttribute.getAttribute("chgtype");

						strAttrValue = null;

						if ("Find Number".equals(strAttrName))
						{
							if (attrConflictChgType != null)
							{
								strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
							}

						}
						else if ("Reference Designator".equals(strAttrName))
						{
							if (attrConflictChgType != null)
							{
								strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
							}
						}
						else if ("Quantity".equals(strAttrName))
						{
							if (attrConflictChgType != null)
							{
								strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
							}
						}
						else if ("Component Location".equals(strAttrName))
						{
							if (attrConflictChgType != null)
							{
								strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
							}
						}
						else if ("Usage".equals(strAttrName))
						{
							if (attrConflictChgType != null)
							{
								strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
								//Commented for IR-153615
								//Added for IR-149745 start         							    
	                        	//strAttrValue = i18nNow.getRangeI18NString(strAttrName, strAttrValue, strLanguage);                         	                           	                         	                         
	                            //Added for IR-149745 end
							}

						}
                        else if ("Notes".equals(strAttrName))
                        {
                            if (attrConflictChgType != null)
                            {
                                strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
                            }

                        }

						if (strAttrValue != null)
						{
							if (hmpAttributes.containsKey(strAttrName))
							{
								if (!strAttrValue.equals((String)hmpAttributes.get(strAttrName)))
								{
									hmpConflictAttributes.put(strAttrName, "TRUE");
								}
							}
							else
							{
								hmpAttributes.put(strAttrName, strAttrValue);
							}
						}

					}
				}
				else
				{
					blnOtherChange = false;
					break;
				}
			}

			if (blnOtherChange)
			{
				itrList = arlElements.iterator();

				HashMap hmpNonConflictAttrAdded = new HashMap();

				while (itrList.hasNext())
				{
					strConflictEBOMChgType = null;
					eleTemp = (Element) itrList.next();

					attrConflictEBOMChgType = eleTemp.getAttribute("chgtype");
					attrConflictMarkup = eleTemp.getAttribute("markupname");

					if (attrConflictEBOMChgType != null)
					{
						strConflictEBOMChgType = attrConflictEBOMChgType.getValue();
					}

					if (attrConflictMarkup != null)
					{
						strConflictEBOMMarkup = attrConflictMarkup.getValue();
					}

					if ("C".equals(strConflictEBOMChgType))
					{
						Element eleConflictObjectInfo = eleTemp.getChild("relatedObject").getChild("businessObjectRef");
						Element eleRelatioshipDescInfo = eleTemp.getChild("relationshipDefRef");
						com.matrixone.jdom.Attribute attrRelId = eleRelatioshipDescInfo.getAttribute("relid");
						String strRelId = "";
						if (attrRelId != null)
						{
							strRelId = attrRelId.getValue();
						}
						com.matrixone.jdom.Attribute attrObjId = eleTemp.getChild("relatedObject").getAttribute("relatedobjid");
						String strObjId = "";
						if (attrObjId != null)
						{
							strObjId = attrObjId.getValue();
						}


						Element eleNewRel = new Element("relationship");
						eleNewRel.setAttribute("chgtype", "C");
						if (strConflictEBOMMarkup != null)
						{
							eleNewRel.setAttribute("markupname",strConflictEBOMMarkup);
						}
						Element eleRelDesc = new Element("relationshipDefRef");
						eleRelDesc.addContent(eleRelatioshipDescInfo.getText());
						eleRelDesc.setAttribute("relid", strRelId);
						eleNewRel.addContent(eleRelDesc);
						Element eleNewRelationship = new Element("relatedObject");
						eleNewRel.addContent(eleNewRelationship);
						eleNewRelationship.setAttribute("relatedobjid", strObjId);
						Element eleNewBusInfo = new Element("businessObjectRef");
						eleNewRelationship.addContent(eleNewBusInfo);
						Element eleNewAttrInfo = new Element("attributeList");
						eleNewRel.addContent(eleNewAttrInfo);
						Element eleNewAttr = new Element("attribute");
						Element eleNewVal = new Element("newvalue");
						Element eleNameVal = new Element("name");
						Element eleOldVal = new Element("oldvalue");

						Element eleNewConflictRel = new Element("relationship");
						eleNewConflictRel.setAttribute("chgtype", "C");
						if (strConflictEBOMMarkup != null)
						{
							eleNewConflictRel.setAttribute("markupname",strConflictEBOMMarkup);
						}
						Element eleConflictRelDesc = new Element("relationshipDefRef");
						eleConflictRelDesc.addContent(eleRelatioshipDescInfo.getText());
						eleConflictRelDesc.setAttribute("relid", strRelId);
						eleNewConflictRel.addContent(eleConflictRelDesc);
						Element eleNewConflictRelationship = new Element("relatedObject");
						eleNewConflictRel.addContent(eleNewConflictRelationship);
						eleNewConflictRelationship.setAttribute("relatedobjid", strObjId);
						Element eleNewConflictBusInfo = new Element("businessObjectRef");
						eleNewConflictRelationship.addContent(eleNewConflictBusInfo);
						Element eleNewConflictAttrInfo = new Element("attributeList");
						eleNewConflictRel.addContent(eleNewConflictAttrInfo);
						Element eleNewConflictAttr = new Element("attribute");
						Element eleNewConflictVal = new Element("newvalue");
						Element eleNameConflictVal = new Element("name");
						Element eleOldConflictVal = new Element("oldvalue");

                        //IR-058430V6R2011x
						//Start : HF-054311V6R2010
						//String strConflictPartType = 	eleConflictObjectInfo.getChild("objectType").getText();
						//String strConflictPartName = 	eleConflictObjectInfo.getChild("objectName").getText();
						//String strConflictPartRev  = 	eleConflictObjectInfo.getChild("objectRevision").getText();
						//String strConflictPartVault  = eleConflictObjectInfo.getChild("vaultRef").getText();
						String strConflictPartName = null;
						String strConflictPartUOM    = eleConflictObjectInfo.getChild("UOM").getText();
						String strConflictPartState  = eleConflictObjectInfo.getChild("objectState").getText();
						String strConflictPartType = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleConflictObjectInfo.getChild("objectType").getText());
//						 strPartName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectNameEncoded").getText());
						if (null !=eleObjectInfo.getChild("objectNameEncoded")){						   
						    strConflictPartName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleConflictObjectInfo.getChild("objectNameEncoded").getText());
						}
						else{
						    strConflictPartName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleConflictObjectInfo.getChild("objectName").getText());
						}
						//String strConflictPartName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleConflictObjectInfo.getChild("objectName").getText());
						String strConflictPartRev  = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleConflictObjectInfo.getChild("objectRevision").getText());
						String strConflictPartVault  = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleConflictObjectInfo.getChild("vaultRef").getText());
                        //End : HF-054311V6R2010

						Element eleObjectType = new Element("objectType");
						eleObjectType.addContent(strConflictPartType);
						Element eleObjectName = new Element("objectName");
						eleObjectName.addContent(strConflictPartName);
						Element eleObjectRevision = new Element("objectRevision");
						eleObjectRevision.addContent(strConflictPartRev);
						Element eleObjectVault = new Element("vaultRef");
						eleObjectVault.addContent(strConflictPartVault);
						Element eleObjectUOM = new Element("UOM");
						eleObjectUOM.addContent(strConflictPartUOM);
						Element eleObjectState = new Element("objectState");
						eleObjectState.addContent(strConflictPartState);

						eleNewBusInfo.addContent(eleObjectType);
						eleNewBusInfo.addContent(eleObjectName);
						eleNewBusInfo.addContent(eleObjectRevision);
						eleNewBusInfo.addContent(eleObjectVault);
						eleNewBusInfo.addContent(eleObjectUOM);
						eleNewBusInfo.addContent(eleObjectState);


						Element eleConflictObjectType = new Element("objectType");
						eleConflictObjectType.addContent(strConflictPartType);
						Element eleConflictObjectName = new Element("objectName");
						eleConflictObjectName.addContent(strConflictPartName);
						Element eleConflictObjectRevision = new Element("objectRevision");
						eleConflictObjectRevision.addContent(strConflictPartRev);
						Element eleConflictObjectVault = new Element("vaultRef");
						eleConflictObjectVault.addContent(strConflictPartVault);
						Element eleConflictObjectUOM = new Element("UOM");
						eleConflictObjectUOM.addContent(strConflictPartUOM);
						Element eleConflictObjectState = new Element("objectState");
						eleConflictObjectState.addContent(strConflictPartState);

						eleNewConflictBusInfo.addContent(eleConflictObjectType);
						eleNewConflictBusInfo.addContent(eleConflictObjectName);
						eleNewConflictBusInfo.addContent(eleConflictObjectRevision);
						eleNewConflictBusInfo.addContent(eleConflictObjectVault);
						eleNewConflictBusInfo.addContent(eleConflictObjectUOM);
						eleNewConflictBusInfo.addContent(eleConflictObjectState);



						Element eleConflictRelatioshipInfo = eleTemp.getChild("attributeList");
						listConflictFromAttributes = eleConflictRelatioshipInfo.getChildren();
						itrConflictAttributes = listConflictFromAttributes.iterator();

						int intConflictCount = 0;
						int intNonConflictCount = 0;

						String strConflictFN = null;
						String strConflictRD = null;
						boolean blnFNConflict = false;
						boolean blnRDConflict = false;
						boolean blnFNNonConflict = false;
						boolean blnRDNonConflict = false;


						Element eleFN = null;
						Element eleRD = null;

						Element eleNonConflictFN = null;
						Element eleNonConflictRD = null;


						while (itrConflictAttributes.hasNext())
						{
							eleConflictAttribute = (Element) itrConflictAttributes.next();

							strAttrName = eleConflictAttribute.getChild("name").getText();

							attrConflictChgType = eleConflictAttribute.getAttribute("chgtype");

							eleNewAttr = new Element("attribute");
							eleNewVal = new Element("newvalue");
							eleOldVal = new Element("oldvalue");
							eleNameVal = new Element("name");


							strAttrValue = null;
							String strAttrOldValue = null;

							if ("Find Number".equals(strAttrName))
							{
								if (attrConflictChgType != null)
								{
									strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
									strAttrOldValue = eleConflictAttribute.getChild("oldvalue").getText();
									strConflictFN = eleConflictAttribute.getChild("oldvalue").getText();
								}
								else
								{
									strConflictFN = eleConflictAttribute.getChild("string").getText();
								}

								eleFN = new Element("attribute");

								eleNonConflictFN  = new Element("attribute");

								eleNewVal = new Element("string");
								eleNameVal = new Element("name");

								eleFN.addContent(eleNameVal);
								eleNameVal.addContent(strAttrName);
								eleFN.addContent(eleNewVal);
								eleNewVal.addContent(strConflictFN);

								eleNewVal = new Element("string");
								eleNameVal = new Element("name");

								eleNonConflictFN.addContent(eleNameVal);
								eleNameVal.addContent(strAttrName);
								eleNonConflictFN.addContent(eleNewVal);
								eleNewVal.addContent(strConflictFN);

							}
							else if ("Reference Designator".equals(strAttrName))
							{
								if (attrConflictChgType != null)
								{
									strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
									strAttrOldValue = eleConflictAttribute.getChild("oldvalue").getText();
									strConflictRD = eleConflictAttribute.getChild("oldvalue").getText();
								}
								else
								{
									strConflictRD = eleConflictAttribute.getChild("string").getText();
								}

								eleRD = new Element("attribute");

								eleNonConflictRD  = new Element("attribute");

								eleNewVal = new Element("string");
								eleNameVal = new Element("name");

								eleRD.addContent(eleNameVal);
								eleNameVal.addContent(strAttrName);
								eleRD.addContent(eleNewVal);
								eleNewVal.addContent(strConflictRD);

								eleNewVal = new Element("string");
								eleNameVal = new Element("name");

								eleNonConflictRD.addContent(eleNameVal);
								eleNameVal.addContent(strAttrName);
								eleNonConflictRD.addContent(eleNewVal);
								eleNewVal.addContent(strConflictRD);
							}
							else if ("Quantity".equals(strAttrName))
							{
								if (attrConflictChgType != null)
								{
									strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
									strAttrOldValue = eleConflictAttribute.getChild("oldvalue").getText();
								}
							}
							else if ("Component Location".equals(strAttrName))
							{
								if (attrConflictChgType != null)
								{
									strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
									strAttrOldValue = eleConflictAttribute.getChild("oldvalue").getText();
								}
							}
							else if ("Usage".equals(strAttrName))
							{
								if (attrConflictChgType != null)
								{
									strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
									strAttrOldValue = eleConflictAttribute.getChild("oldvalue").getText();
									
									//Commented for IR-153615
									//Added for IR-149745 start         								    
		                        	//strAttrValue = i18nNow.getRangeI18NString(strAttrName, strAttrValue, strLanguage);   
		                        	//strAttrOldValue = i18nNow.getRangeI18NString(strAttrName, strAttrOldValue, strLanguage);
		                            //Added for IR-149745 end
									
								}
							}else if ("Notes".equals(strAttrName))
                            {
                                if (attrConflictChgType != null)
                                {
                                    strAttrValue = eleConflictAttribute.getChild("newvalue").getText();
                                    strAttrOldValue = eleConflictAttribute.getChild("oldvalue").getText();
                                }
                            }

							if (strAttrValue != null)
							{
								if (hmpConflictAttributes.containsKey(strAttrName))
								{
									if ("Find Number".equals(strAttrName))
									{
										blnFNConflict = true;
									}
									else if ("Reference Designator".equals(strAttrName))
									{
										blnRDConflict = true;
									}

									eleNewConflictAttr = new Element("attribute");
									eleNewConflictAttr.setAttribute("chgtype", "C");
									eleNewConflictVal = new Element("newvalue");
									eleOldConflictVal = new Element("oldvalue");
									eleNameConflictVal = new Element("name");

									eleNewConflictAttrInfo.addContent(eleNewConflictAttr);
									eleNewConflictAttr.addContent(eleNameConflictVal);
									eleNameConflictVal.addContent(strAttrName);
									eleNewConflictAttr.addContent(eleOldConflictVal);
									eleOldConflictVal.addContent(strAttrOldValue);
									eleNewConflictAttr.addContent(eleNewConflictVal);
									eleNewConflictVal.addContent(strAttrValue);
									intConflictCount++;
								}
								else
								{
									if (!hmpNonConflictAttrAdded.containsKey(strAttrName))
									{

									if ("Find Number".equals(strAttrName))
									{
										blnFNNonConflict = true;
									}
									else if ("Reference Designator".equals(strAttrName))
									{
										blnRDNonConflict = true;
									}

									eleNewAttr = new Element("attribute");
									eleNewAttr.setAttribute("chgtype", "C");
									eleNewVal = new Element("newvalue");
									eleOldVal = new Element("oldvalue");
									eleNameVal = new Element("name");

									eleNewAttrInfo.addContent(eleNewAttr);
									eleNewAttr.addContent(eleNameVal);
									eleNameVal.addContent(strAttrName);
									eleNewAttr.addContent(eleOldVal);
									eleOldVal.addContent(strAttrOldValue);
									eleNewAttr.addContent(eleNewVal);
									eleNewVal.addContent(strAttrValue);

									intNonConflictCount++;
										hmpNonConflictAttrAdded.put(strAttrName, strAttrValue);
									}

								}
							}

						}

						if (!blnFNConflict)
						{
							eleNewConflictAttrInfo.addContent(eleFN);
						}
						if (!blnRDConflict)
						{
							eleNewConflictAttrInfo.addContent(eleRD);
						}

						if (!blnFNNonConflict)
						{
							eleNewAttrInfo.addContent(eleNonConflictFN);
						}
						if (!blnRDNonConflict)
						{
							eleNewAttrInfo.addContent(eleNonConflictRD);
						}


						if (intConflictCount > 0)
						{
							arlConflicts.add(eleNewConflictRel);
						}
						if (intNonConflictCount > 0)
						{
							arlNoConflicts.add(eleNewRel);
						}
					}
				}

				if (arlConflicts.size() > 0)
				{
					htNewConflicts.put(strKey, arlConflicts);
				}
				else
				{
					htConflictBOMs.remove(strKey);
				}

			}



		}

		htConflictBOMs.putAll(htNewConflicts);

		Iterator itrNoConlicts = arlNoConflicts.iterator();

		StringBuffer sbfNewConflictsXML = new StringBuffer("");

		while (itrNoConlicts.hasNext())
		{
			sbfNewConflictsXML.append(convertToStructureXML(context, (Element) itrNoConlicts.next(), strPartId));
		}
		sbfFinalXML.append(sbfNewConflictsXML);


		sbfFinalXML.append("</mxRoot>");


		return sbfFinalXML.toString();
	}

	public StringBuffer convertToStructureXML (Context context, Element eleRelationship, String strParentPartId) throws Exception
	{
		try
		{
			StringBuffer sbfAddXML = new StringBuffer("");
			StringBuffer sbfDeleteXML = new StringBuffer("");
			StringBuffer sbfModifyXML = new StringBuffer("");
			StringBuffer sbfXMLTag  =  null;
			StringBuffer sbfAttrXMLTag = null;
			String strLanguage = context.getSession().getLanguage(); //Added for IR-149745
		    String strAttrDisValue = "";
			Element eleRoot = null;
			Element eleObjectInfo = null;
			Element eleRelatioshipInfo = null;
			Element eleAttribute = null;
			Element eleRelType = null;
			Element eleParentInfo = null;
			com.matrixone.jdom.Attribute attrPartId = null;
			com.matrixone.jdom.Attribute attrRelId = null;

			com.matrixone.jdom.Attribute attrEBOMChgType = null;
			com.matrixone.jdom.Attribute attrChgType = null;

			java.util.List listFromRelationships = null;
			java.util.List listFromAttributes = null;

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
            //IR-058430V6R2011x
            //IR-021110: Decoding the encoded type, name,rev
			//strPartType = eleObjectInfo.getChild("objectType").getText();
			strPartType =com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectType").getText());
            //strPartName = eleObjectInfo.getChild("objectName").getText();
			//strPartName=com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectName").getText());
			if (null !=eleObjectInfo.getChild("objectNameEncoded")){
			    strPartName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectNameEncoded").getText());
			}
			else{
			strPartName = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectName").getText());
			}
			//strPartRev  = eleObjectInfo.getChild("objectRevision").getText();
			strPartRev=com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("objectRevision").getText());
			//strPartVault  = eleObjectInfo.getChild("vaultRef").getText();
			strPartVault=com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(eleObjectInfo.getChild("vaultRef").getText());
            		//End

			strRelType = eleRelType.getText();

            // Modified for V6R2009.HF0.2 - Starts
            if (DomainConstants.RELATIONSHIP_EBOM_MARKUP.equals(strRelType) || DomainConstants.RELATIONSHIP_EBOM.equals(strRelType))
            // Modified for V6R2009.HF0.2 - Ends
			{
				strRelType = "relationship_EBOM";
			}

			attrPartId = eleRelationship.getChild("relatedObject").getAttribute("relatedobjid");

			if (attrPartId != null)
			{
				strPartId = attrPartId.getValue();
			}

			if (strPartId == null || strPartId.length() <= 0)
			{

				doChild = new DomainObject(new BusinessObject(strPartType,strPartName,strPartRev,strPartVault));

				doChild.open(context);

				strPartId = doChild.getObjectId();
			}

			attrRelId = eleRelType.getAttribute("relid");

			if (attrRelId != null)
			{
				strRelId = attrRelId.getValue();
			}

			attrEBOMChgType = eleRelationship.getAttribute("chgtype");

			strEBOMChgType = null;

			if (attrEBOMChgType != null )
			{
				strEBOMChgType = attrEBOMChgType.getValue();
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
						//Commented for IR-153615
						//Added for IR-149745 start         						    
                        	strAttrDisValue = i18nNow.getRangeI18NString(strAttrName, strAttrValue, strLanguage);                         	                           	                         	                         
                        //Added for IR-149745 end
					}
					else if ("Has Manufacturing Substitute".equals(strAttrName))
					{
						strAttrValue = eleAttribute.getChild("boolean").getText();
					}else if ("Notes".equals(strAttrName))
                    {
                        strAttrValue = eleAttribute.getChild("string").getText();
                    }
					else if ("UOM".equals(strAttrName))
                    {
                        strAttrValue = eleAttribute.getChild("string").getText();
                    }
					//IR-076128V6R2012 starts
					else if ("Source".equals(strAttrName))  
                    {
                        strAttrValue = eleAttribute.getChild("string").getText();
                    }
					////IR-076128V6R2012 ends
					else if ("isVPMVisible".equals(strAttrName))  
                    {
                        continue;
                    }
					
					sbfXMLTag.append("<column name=\"");
					sbfXMLTag.append(strAttrName);
					sbfXMLTag.append("\" edited=\"true\" a=\""+strAttrValue+"\">");
					if("Usage".equals(strAttrName)) {						  
						sbfXMLTag.append(strAttrDisValue);
					} else {						
                        sbfXMLTag.append(strAttrValue);
					}
					
					sbfXMLTag.append("</column>");

				}

				sbfXMLTag.append("</object>");

				sbfAddXML.append(sbfXMLTag);

				return sbfAddXML;

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
						return new StringBuffer();
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

				return sbfDeleteXML;

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

					if ("Find Number".equals(strAttrName))
					{
						if (attrChgType != null)
						{
							strEBOMFN = eleAttribute.getChild("oldvalue").getText();
							strAttrValue = eleAttribute.getChild("newvalue").getText();
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
						}
					}
					else if ("Component Location".equals(strAttrName))
					{
						if (attrChgType != null)
						{
							strAttrValue = eleAttribute.getChild("newvalue").getText();
						}

					}
					else if ("Usage".equals(strAttrName))
					{
						if (attrChgType != null)
						{
							strAttrValue = eleAttribute.getChild("newvalue").getText();
							//Commented for IR-153615
							//Added for IR-149745 start         						    
                        	strAttrDisValue = i18nNow.getRangeI18NString(strAttrName, strAttrValue, strLanguage);                         	                           	                         	                         
                           //Added for IR-149745 end
						}
					}
					else if ("Notes".equals(strAttrName))
                    {
                        if (attrChgType != null)
                        {
                            strAttrValue = eleAttribute.getChild("newvalue").getText();
                        }
                    }
					else if ("UOM".equals(strAttrName))
                    {
                        if (attrChgType != null)
                        {
                            strAttrValue = eleAttribute.getChild("newvalue").getText();
                        }
                    }

					if (strAttrValue != null)
					{
						sbfAttrXMLTag.append("<column name=\"");
						sbfAttrXMLTag.append(strAttrName);
						//sbfAttrXMLTag.append("\" edited=\"true\">");
						sbfAttrXMLTag.append("\" edited=\"true\" a=\""+strAttrValue+"\">");
						if ("Usage".equals(strAttrName)){
                            sbfAttrXMLTag.append(strAttrDisValue);
                        }
                        else
                        {
                            sbfAttrXMLTag.append(strAttrValue);
                        }
						//sbfAttrXMLTag.append(strAttrValue);
						sbfAttrXMLTag.append("</column>");
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
						return new StringBuffer();
					}

					Map mapBOM = (Map) mapListBOMs.get(0);
					strRelId = (String) mapBOM.get(DomainConstants.SELECT_RELATIONSHIP_ID);
				}

				if (sbfAttrXMLTag.length() > 0)
				{
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
				}

				return sbfModifyXML;

			}

			return new StringBuffer();
		}
		catch (Exception excep)
		{
			return new StringBuffer();
		}

	}
%>

<%
String timeStamp = emxGetParameter(request, "timeStamp");
String Location = emxGetParameter(request,"Location");

String strMarkupIds = emxGetParameter(request, "markupIds"); //(String) requestMap.get("markupIds");
String strPartId = emxGetParameter(request, "objectId"); //(String) requestMap.get("objectId");

String suiteKey = emxGetParameter(request, "suiteKey");
String ECRObjectId = emxGetParameter(request, "sChangeOID");

StringList strlMarkupIds = FrameworkUtil.split(strMarkupIds, ",");
Hashtable htConflictBOMs = new Hashtable();
String strMarkupXML = mergeMarkupsForOpening(context, strlMarkupIds, strPartId, htConflictBOMs);
strMarkupXML = strMarkupXML.replaceAll("\"", "\'");

session.removeAttribute("XMLINFO");
session.removeAttribute("ConflictList");
session.setAttribute("XMLINFO", strMarkupXML);
session.setAttribute("ConflictList", htConflictBOMs);

ContextUtil.popContext(context);
String contentURL ="../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOMForMarkupView&fromOpenMarkup=true&table=ENCEBOMIndentedSummary&header=emxFramework.Command.BOMMarkups&reportType=BOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelpaffecteditemsmarkupopen&PrinterFriendly=true&objectId="+strPartId+"&suiteKey="+suiteKey+"&mode=edit&showApply=FALSE&markupIds=" + strMarkupIds +"&preProcessJPO=emxPart:sendXMLForLoadMarkup&selection=multiple&freezePane=Name&sChangeOID="+ECRObjectId+"&showRMBInlineCommands=true&editRootNode=false";

//Modified for ENG Convergence start
//if("".equals(Location) || "null".equals(Location) || Location == null){ //Commented for ENG Convergence
boolean isDiffCA = false;	
boolean isProposedMarkup = true;
String POLICY_PARTMARKUP=PropertyUtil.getSchemaProperty(context,"policy_PartMarkup");

DomainObject dObj = new DomainObject(strPartId);
String strPolicy = dObj.getInfo(context, DomainConstants.SELECT_POLICY);
String strPolicyClassification = EngineeringUtil.getPolicyClassification(context,strPolicy);
String strMarkupsWithDiffCAMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.CannotSaveMarkupsWithDiffCR");

      if("Production".equalsIgnoreCase(strPolicyClassification))
      {		
   	    String RELATIONSHIP_APPLIED_MARKUP =PropertyUtil.getSchemaProperty(context,"relationship_AppliedMarkup");
      	String strMarkupId = "";
      	String strtempCAId = "";      
      	StringTokenizer stMarkups = new StringTokenizer(strMarkupIds,",");
      	while(stMarkups.hasMoreTokens()) {
      		strMarkupId = stMarkups.nextToken();      		
      		DomainObject dMarkObj = new DomainObject(strMarkupId);
      		String strCAId = dMarkObj.getInfo(context, "to["+RELATIONSHIP_APPLIED_MARKUP+"].from.name");
      		String strCAState = dMarkObj.getInfo(context, DomainConstants.SELECT_CURRENT);      	
      		
      		if(UIUtil.isNullOrEmpty(strtempCAId)) {
      			strtempCAId = strCAId;
      		}
      		if(UIUtil.isNotNullAndNotEmpty(strtempCAId) && UIUtil.isNotNullAndNotEmpty(strtempCAId) && !strtempCAId.equals(strCAId)) {
      			isDiffCA = true;      
      			%>
      			<script language="JavaScript" type="text/javascript">
      			//XSSOK
      			alert("<%=strMarkupsWithDiffCAMsg%>");
      			</script>
      			<%
      			break;      			
      		}       		
      	} 
      	if(!isDiffCA) {
      		contentURL += "&toolbar=ENCOpenBOMMarkupToolBar";
      	}
      	
      }  else if (strPolicyClassification.equalsIgnoreCase("Development")) {
    	  contentURL += "&toolbar=ENCOpenBOMMarkupToolBar";
      } //Added for IR-266950
	
	
//}
//Modified for ENG Convergence End
	
%>
<html>
<body>
<form name="markupForm" action="<xss:encodeForHTMLAttribute><%=contentURL%></xss:encodeForHTMLAttribute>" method="post">
	<input type="hidden" name="jpoAppServerParamList" value="session:XMLINFO,session:ConflictList" />
</form>
<script language="JavaScript" type="text/javascript">
	document.markupForm.submit();
</script>
</body>
</html>


