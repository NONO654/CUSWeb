<%--
ManufacturingPlanResolutionDialog.jsp
Copyright (c) 1993-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of 
Dassault Systemes.
Copyright notice is precautionary only and does not evidence any actual
or intended publication of such program

static const char RCSID[] = "$Id: /web/configuration/emxResolvedManufacturingPlanUtil.jsp 1.86.2.5.1.1.1.5.1.8 Fri Jan 16 14:21:52 2009 GMT ds-shbehera Experimental$";

--%>

<%-- Common Includes --%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.MessageUtil"%>
<%@page import="com.matrixone.apps.common.util.FormBean"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlan"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>


<!--emxUIConstants.js is included to call the findFrame() method to get a frame-->
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<%

String manufacturingPlanChoices = "DMCPlanning.Heading.ManufacturingPlanChoices";
String usage = "DMCPlanning.Table.Usage";
String strMode = emxGetParameter(request, "mode");
String toolbar = emxGetParameter(request, "toolbar");
String strFunctionality = emxGetParameter(request, "functionality");
String HelpMarker = emxGetParameter(request, "HelpMarker");
boolean bPrinterFriendly = true;

String objectId = emxGetParameter(request, "objectId");
String parentOID = emxGetParameter(request, "parentOID");
String selObjId = emxGetParameter(request, "selObjId");
String language  = request.getHeader("Accept-Language");

MapList objectsToDisplay = new MapList();

//Get Design Structure with related Model sorted by Model
//Added for IR-078267V6R2012 
if(selObjId==null ||"".equalsIgnoreCase(selObjId)){
	selObjId=(String)session.getAttribute("ctxMPPlan");
}
//End of IR-078267V6R2012 
ManufacturingPlan manuPlan=new ManufacturingPlan(selObjId);
MapList relatedDesignObjects = manuPlan.getDesignComposition(context,parentOID);

MapList unresolvedDesignObjects = new MapList();
MapList unresolvedDesignToImplementObjects = new MapList();

if(relatedDesignObjects!=null && !relatedDesignObjects.isEmpty()){
	Iterator relatedDesignObjectsItr = relatedDesignObjects.iterator();
	while(relatedDesignObjectsItr.hasNext()){
		Map relatedDesignObject = (Map)relatedDesignObjectsItr.next();
		if(relatedDesignObject!=null && !relatedDesignObject.isEmpty()){
			MapList relatedProducts = (MapList)relatedDesignObject.get("relatedProducts");
			if(relatedProducts!=null && !relatedProducts.isEmpty()){
				if(relatedProducts.size()>1){
					unresolvedDesignObjects.add(relatedDesignObject);
				}
			}
		}
	}
	if(strMode!=null && !strMode.equalsIgnoreCase("")){
		if(strMode.equalsIgnoreCase("edit")){
			unresolvedDesignToImplementObjects=manuPlan.getUnresolvedDesignToImplementObjects(context,unresolvedDesignObjects);
			objectsToDisplay.addAll(unresolvedDesignToImplementObjects);
		}else if(strMode.equalsIgnoreCase("update")){
			objectsToDisplay.addAll(unresolvedDesignObjects);
		}
	}
}

%>


<html>
<head>
<script language="javascript">
function submit(){
	var flag = "true";
	<%	
	StringList masterList = new StringList();
	String refreshMode = "";
	
	if(objectsToDisplay!=null && !objectsToDisplay.isEmpty()){
		Iterator objectsToDisplayItr = objectsToDisplay.iterator();
		while(objectsToDisplayItr.hasNext()){
			Map objectToDisplay = (Map)objectsToDisplayItr.next();
			if(objectToDisplay!=null && !objectToDisplay.isEmpty()){
				String masterTempId = (String)objectToDisplay.get("Master");
				if(masterTempId!=null && !masterTempId.equalsIgnoreCase("")){
					masterList.addElement(masterTempId);
					%>
					var masterValue = document.getElementById('<%=XSSUtil.encodeForJavaScript(context,masterTempId)%>').value;
					if(masterValue == ""){
						flag = "false";
					}
					<%
				}
			}
		}
	}
	if(strMode!=null && !strMode.equalsIgnoreCase("")){
		if(strMode.equalsIgnoreCase("edit")){
			refreshMode = "";
		}else if(strMode.equalsIgnoreCase("update")){
			refreshMode = "refresh";
		}
	}
	%>
	if(flag == "true"){
		var formObject = self.document.manufacturingPlanResolution;
		formObject.action="ManufacturingPlanUtil.jsp?mode=updateUnresolvedDesignObjects&objectId=<%=XSSUtil.encodeForURL(context,objectId)%>&parentOID=<%=XSSUtil.encodeForURL(context,parentOID)%>&selObjId=<%=XSSUtil.encodeForURL(context,selObjId)%>&masterList=<%=XSSUtil.encodeForURL(context,masterList.toString())%>&refreshMode=<%=XSSUtil.encodeForURL(context,refreshMode)%>";
	    formObject.submit();
	}else{
		var msg = "<%=i18nStringNowUtil("DMCPlanning.Alert.SelectAtleastOne","dmcplanningStringResource",language)%> ";
		alert(msg);
	}
}

function closeWindow() {
	//self.document.featureOptions.action="DesignEffectivityUtil.jsp?mode=cleanupsession";
	//self.document.featureOptions.submit();
    parent.window.closeWindow();
}
</script>

<link rel="stylesheet" type="text/css" media="screen" href="./styles/emxUIConfigurator.css">
</head>
<body>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="manufacturingPlanResolution" method="post" marginheight="0" marginwidth="10" scrolling="no" border="0" frameborder="no"  framespacing="5">
<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
<input type="hidden" id="lstTrueMPRId" lstTrueMPRId=""></input>
<input type="hidden" id="strExcludeListMPR" strExcludeListMPR=""></input>


<div id="mx_divBasePrice">
	<table border="0" cellpadding="0" cellspacing="0">
		<thead>
			<tr>
			    <td class="mx_status">&#160;</td>
				<td class="mx_name"></td>
				<td class="mx_usage">&#160;</td>
			</tr>
		</thead>
		<tbody>
			<tr>
			    <td class="mx_status">&#160;</td>
				<td class="mx_name"><framework:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,manufacturingPlanChoices)%></framework:i18n></td>
				<td class="mx_usage" style="align:left"><b><framework:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,usage)%></framework:i18n></b></td>
			</tr>
		</tbody>
	</table>
</div>
	<div id="mx_divConfiguratorBody">
		<table id="ResolutionTable" border="0" cellpadding="0" cellpadding="0">
			<tbody id="ResolutionTableBody">
			
				<%
				if(objectsToDisplay!=null && !objectsToDisplay.isEmpty()){
					Iterator objectsToDisplayItr = objectsToDisplay.iterator();
					while(objectsToDisplayItr.hasNext()){
						String masterId = "";
						String selectedRevId = "";
						
						Map objectToDisplay = (Map)objectsToDisplayItr.next();
						if(objectToDisplay!=null && !objectToDisplay.isEmpty()){
							masterId = (String)objectToDisplay.get("Master");
							MapList relatedProducts = (MapList)objectToDisplay.get("relatedProducts");
							if(masterId!=null && !masterId.equalsIgnoreCase("")){
								DomainObject masterDom = new DomainObject(masterId);
								String masterType = masterDom.getInfo(context, DomainConstants.SELECT_TYPE);
								String masterName = masterDom.getInfo(context, DomainConstants.SELECT_NAME);
								String masterTypeIcon = UINavigatorUtil.getTypeIconProperty(context, masterType);
								%>
								<tr id="MprRow" + intRowNumber + isTopLevel="true" class="">
									<td class="mx_status">
										<div id="MF<xss:encodeForHTMLAttribute><%=masterId%></xss:encodeForHTMLAttribute>" MFRowId="MFRow"></div>
										<td>
										<table border="0" cellpadding="0" cellspacing="0" class="mx_feature-option">
											<tr>
												<td class="mx_spacer-cell level-1">
													<img src="../common/images/iconStatusComplete.gif">
												</td>
												<td class="mx_input-cell">
													<div id="<xss:encodeForHTMLAttribute><%=masterId%></xss:encodeForHTMLAttribute>Div" MFId="<%=masterId%>" innerHTMLId="<%=masterId%>" groupName="<%=masterId%>" selectionType="">
													</div>
												</td>
						
												<td class"mx_icon">
													<img src="../common/images/<xss:encodeForHTMLAttribute><%=masterTypeIcon%></xss:encodeForHTMLAttribute>">
												</td>
												<td class="mx_feature-option"> <%=XSSUtil.encodeForHTML(context,masterName)%> </td>
											</tr>
										</table>
									</td>
						
									<td class="mx_usage">
										<a id="<xss:encodeForHTMLAttribute><%=masterId%></xss:encodeForHTMLAttribute>OrderedQuantity">
										<b><framework:i18n localize="i18nId">DMCPlanning.Range.FeatureUsage.Mandatory</framework:i18n></b></a>
									</td>
								</tr>
							
								<%
								if(relatedProducts!=null && !relatedProducts.isEmpty()){
									Iterator relatedProductsItr = relatedProducts.iterator();
									while(relatedProductsItr.hasNext()){
										Map relatedProduct = (Map)relatedProductsItr.next();
										if(relatedProduct!=null && !relatedProduct.isEmpty()){
											String objectRevId = (String)relatedProduct.get(DomainConstants.SELECT_ID);
											if(objectRevId!=null && !objectRevId.equalsIgnoreCase("")){
												DomainObject objectRevDom = new DomainObject(objectRevId);
												String objectRevType = (String)relatedProduct.get(DomainConstants.SELECT_TYPE);
												String objectRevName =(String)relatedProduct.get(DomainConstants.SELECT_NAME);
												String objectRevRevision = (String)relatedProduct.get(DomainConstants.SELECT_REVISION);
												String objectRevTypeIcon = UINavigatorUtil.getTypeIconProperty(context, objectRevType);
												String isChecked = "";
												String strUsage = (String)relatedProduct.get("usage");
												
												if(strMode!=null && !strMode.equalsIgnoreCase("")){											
													if(strMode.equalsIgnoreCase("edit")){
														//find Feature Allocation Type
														if(strUsage!=null && !strUsage.equalsIgnoreCase("")){
															if(strUsage.equalsIgnoreCase("Standard")){
																isChecked = "checked";
																selectedRevId = objectRevId;
																%>
																<script language="javascript" type="text/javaScript">
																var id="<%=XSSUtil.encodeForJavaScript(context,masterId)%>"+"Div";
																var masterValue = document.getElementById(id);
																masterValue.value = '<%=XSSUtil.encodeForJavaScript(context,objectRevId)%>';
																</script>
																<%
															}
														}
													}else if(strMode.equalsIgnoreCase("update")){
														//find the one which is already connected
														MapList relatedManufacturingPlans = objectRevDom.getRelatedObjects(context,
																ManufacturingPlanConstants.RELATIONSHIP_MANUFACTURING_PLAN_IMPLEMENTS,
																ManufacturingPlanConstants.TYPE_MANUFACTURING_PLAN,
																new StringList(DomainConstants.SELECT_ID),
																new StringList(DomainConstants.SELECT_RELATIONSHIP_ID),
																true,	//to relationship
																false,	//from relationship
																(short)1,
																DomainConstants.EMPTY_STRING, //objectWhereClause
																DomainConstants.EMPTY_STRING, //relationshipWhereClause
																0);
														
														if(relatedManufacturingPlans!=null && !relatedManufacturingPlans.isEmpty()){
															Iterator relatedManufacturingPlansItr = relatedManufacturingPlans.iterator();
															while(relatedManufacturingPlansItr.hasNext()){
																Map relatedManufacturingPlan = (Map)relatedManufacturingPlansItr.next();
																if(relatedManufacturingPlan!=null && !relatedManufacturingPlan.isEmpty()){
																	String relatedManufacturingPlanId = (String)relatedManufacturingPlan.get(DomainConstants.SELECT_ID);
																	if(relatedManufacturingPlanId!=null && !relatedManufacturingPlanId.equalsIgnoreCase("")){
																		if(selObjId!=null && !selObjId.equalsIgnoreCase("")){
																			if(relatedManufacturingPlanId.equalsIgnoreCase(selObjId)){
																				isChecked = "checked";
																				selectedRevId = objectRevId;
																				%>
																				<script language="javascript" type="text/javaScript">
																				var id="<%=XSSUtil.encodeForJavaScript(context,masterId)%>"+"Div";
																				var masterValue = document.getElementById(id);
																				masterValue.value = '<%=XSSUtil.encodeForJavaScript(context,objectRevId)%>';
																				</script>
																				<%
																			}
																		}
																	}
																}
															}
														}
													}
												}
												
												%>
												<tr id="MprRow" class="">
													<td class="mx_status">
														<div id="TF" MFRowId="MFRow"></div>
													</td>
													<td>
														<table border="0" cellpadding="0" cellspacing="0" class="mx_feature-option">
															<tr>
																<td class="mx_spacer-cell level-2">
																	<img src="../common/images/utilSpacer.gif">
																</td>
																<td class="mx_input-cell">
																	<div id="<xss:encodeForHTMLAttribute><%=masterId%></xss:encodeForHTMLAttribute>Div" TFId="<xss:encodeForHTMLAttribute><%=objectRevId%></xss:encodeForHTMLAttribute>" innerHTMLId="<xss:encodeForHTMLAttribute><%=objectRevId%></xss:encodeForHTMLAttribute>" groupName="<xss:encodeForHTMLAttribute><%=masterId%></xss:encodeForHTMLAttribute>">
																	<%
																	StringBuffer strBuffer = new StringBuffer();
													            	strBuffer.append("var masterValue = document.getElementById('" + masterId + "');");
												            		strBuffer.append("masterValue.value = '" + objectRevId + "';");
																	%>
																	<input name="<xss:encodeForHTMLAttribute><%=masterId%></xss:encodeForHTMLAttribute>Group" id="<xss:encodeForHTMLAttribute><%=masterId%></xss:encodeForHTMLAttribute>Group" featureRowLevel="" type="radio" value="radio" onclick="<xss:encodeForHTMLAttribute><%=strBuffer.toString()%></xss:encodeForHTMLAttribute>" <%=isChecked%>>
																	</div>
																</td>
																<td class="mx_icon">
																	<img src="../common/images/<xss:encodeForHTMLAttribute><%=objectRevTypeIcon%></xss:encodeForHTMLAttribute>">
																</td>
																<td class="mx_option"> <%=XSSUtil.encodeForHTML(context,objectRevName)%> <%=XSSUtil.encodeForHTML(context,objectRevRevision)%></td>
															</tr>
														</table>
													</td>
													<td class="mx_usage">
														<a id="<xss:encodeForHTMLAttribute><%=objectRevId%></xss:encodeForHTMLAttribute>OrderedQuantity">
														<%
														if("Required".equals(strUsage))
														{
															strUsage = "Mandatory";
														}
														%>
															<b><framework:i18n localize="i18nId">DMCPlanning.Range.FeatureUsage.<%=XSSUtil.encodeForHTML(context,strUsage)%></framework:i18n></b></a>
													</td>
												</tr>
												<%
											}
										}
									}
								}
							}
						}
						%>
						<input type="hidden" id="<%=masterId%>" name="<%=masterId%>" value="<xss:encodeForHTMLAttribute><%=selectedRevId%></xss:encodeForHTMLAttribute>">
						<%
					}
					//Mettre le input hidden
				}
				else
				{
					 %>
                     <script language="javascript" type="text/javaScript">
                     var msg = "<%=i18nStringNowUtil("DMCPlanning.Alert.Resolved","dmcplanningStringResource",language)%> ";
                     alert(msg);
                     closeWindow();
                     </script>  
                 <% 
				}
				%>
				
			</tbody>
		</table>
	</div>
</form>


</body>
</head>
</html>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
