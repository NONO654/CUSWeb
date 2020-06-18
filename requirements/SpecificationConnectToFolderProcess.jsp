<%--  SpecificationConnectToFolderProcess.jsp   - Processing page to connect selected requirement specifications to the folder.
   Copyright (c)  2008-2018 Dassault Systemes. All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: SpecificationConnectToFolderProcess.jsp
--%>
<%-- @quickreview T25 OEP 21 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags and tag Lib are included--%>
<%-- @quickreview T25 DJH 2013:02:28  IR-220061V6R2014  STP: Add to Project Folder functionality on Requirement Speciifcation is KO.  XSS Output filter corresponding tags Lib is included --%>
<%-- @quickreview T25 DJH 18 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included. --%>
<%-- @quickreview HAT1 ZUD 2014:05:28  IR-272999V6R2015.STP: In Requirement Specification, adding Project Folder from Properties category is KO.--%>
<%-- @quickreview HAT1 ZUD 2014:08:27  IR-320838-3DEXPERIENCER2015x. R417-STP: In Requirement Specification, adding Project Folder from Properties category refresh edit form.--%>
<%-- @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget. --%>
<%-- @quickreview QYG      15:07:14 : IR-333936-3DEXPERIENCER2016 popup doesn’t collapse after choosing folder and clicked on done button --%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>

<%@page import = "com.matrixone.apps.domain.DomainConstants, com.matrixone.apps.domain.DomainRelationship, com.matrixone.apps.domain.DomainObject, com.matrixone.apps.domain.util.ContextUtil, com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>

<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>


<%

	// get time stamp
	String timeStamp = emxGetParameter(request, "timeStamp");
	
	String sFolderName    = "";
	String sFolderTitle   = "";
	boolean isControlledFolder = false;
	String strObjIds      = "";

	StringBuffer sbFolderName               = new StringBuffer(50);
		
	StringList strListfolderIds             = new StringList();
	StringList sfolderAndProjectValues      = new StringList();

	String formName         = emxGetParameter(request, "formName");
	String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
	String fieldNameActual  = emxGetParameter(request, "fieldNameActual");

	//to get the selected folder ids
	String[] folderIds      = emxGetParameterValues(request, "emxTableRowId");
	
	final String SELECT_ATTRIBUTE_TITLE = "attribute[" + ReqSchemaUtil.getTitleAttribute(context) + "]";
    final String SELECT_IS_KINDOF_CONTROLLED_FOLDER = "type.kindof[" + ReqSchemaUtil.getControlledFolderType(context) + "]";
    	
	if(folderIds!=null) 
		{
			for(int itr = 0; itr < folderIds.length; itr++) 
				{
					//get the pipe separated values in the list
					sfolderAndProjectValues = FrameworkUtil.split(folderIds[itr],"|");
			
							strListfolderIds.add(sfolderAndProjectValues.get(0));
					} //end of for loop
		} //end of if loop

   
		{
	    	StringList slBusSelect = new StringList();
	    	slBusSelect.add(DomainConstants.SELECT_NAME);
	    	slBusSelect.add(SELECT_ATTRIBUTE_TITLE);
	    	slBusSelect.add(SELECT_IS_KINDOF_CONTROLLED_FOLDER);
	    	
			for(int i=0; i<strListfolderIds.size(); i++)
				{
					if(!"".equals(strListfolderIds.get(i))) 
						{
							//get a folder id
							String sFolderValue = (String)strListfolderIds.elementAt(i);

				            //construct the object
							DomainObject domObj = DomainObject.newInstance(context, sFolderValue);
				            Map mapObjInfo = domObj.getInfo(context, slBusSelect);
				            
							sFolderName = (String) mapObjInfo.get(DomainConstants.SELECT_NAME);
							sFolderTitle = (String) mapObjInfo.get(SELECT_ATTRIBUTE_TITLE);
							isControlledFolder = "TRUE".equalsIgnoreCase((String) mapObjInfo.get(SELECT_IS_KINDOF_CONTROLLED_FOLDER));
							
							strObjIds   = strObjIds + sFolderValue;

							// For Controlled Folder the name of the folder is stored in Title attribute
							if (isControlledFolder) {
							    sbFolderName.append(sFolderTitle);
							}
							else {
							sbFolderName.append(sFolderName);
							}
        
							//forming buffer to append comma if more than one folders to display
							if(i<(strListfolderIds.size()-1))
								{
									sbFolderName.append(" , ");
									strObjIds=strObjIds+",";
								}
						} 
				}  //end of for loop
			}  //end of if flag loop

	String param                       = "";
	String strRelatedObjId             = "";
	int sizeCount                      = 0;

	String relVaultedDocs = PropertyUtil.getSchemaProperty(context,"relationship_VaultedDocumentsRev2");
	String folderType     = PropertyUtil.getSchemaProperty(context,"type_ProjectVault");

	param = (String)emxGetParameter(request, "param");

	// param contains the selected requirement Specification Ids from Add to project folder Command
	if(param!=null && !"".equals(param))
		{
			//separate the selected requirement Specification Ids with comma
			StringList requirementSpecificationIds = FrameworkUtil.split(param,";");
			StringList slFinalReqSpecIds = new StringList();
			String strSelectedType = null;
			String strFinalSelectedObj = null;
			
			for(int i=0; i<requirementSpecificationIds.size(); i++) 
			{
	            strSelectedType = (String)requirementSpecificationIds.get(i);
	            if(strSelectedType.contains("|"))
	            {
	            	strFinalSelectedObj = strSelectedType.split("[|]")[1];
	            	slFinalReqSpecIds.add(strFinalSelectedObj);
	            }
			}
			
			sizeCount = slFinalReqSpecIds.size();
			String[] requirementSpecIds = new String[sizeCount];

			for(int i=0; i<slFinalReqSpecIds.size(); i++) 
				{
					if(!"".equals(slFinalReqSpecIds.get(i))) 
						{
							//construct an array of selected requirement Specification ids to pass to connect method
							requirementSpecIds[i] = (String)slFinalReqSpecIds.get(i);
						}
				}
         
			try {
                 //to iterate to each requirement Specification id
				for(int i=0; i<requirementSpecIds.length; i++) 
					{
				
					DomainObject domObj = new DomainObject(requirementSpecIds[i]);
	
					StringList idsList = new StringList();
					StringList objSelectList = new StringList(2);
					objSelectList.add(DomainConstants.SELECT_ID);

				    //get the all related folder objects from requirement Specification id
					MapList reqObjMapList = domObj.getRelatedObjects(context,relVaultedDocs,folderType,objSelectList,null,true,true,(short)0,null,null);
					Iterator itr = reqObjMapList.iterator();

					while(itr.hasNext()) 
						{
							Map reqObjMap = (Map)itr.next();
							idsList.add((String)reqObjMap.get(DomainConstants.SELECT_ID));
							//namesList.add((String)reqObjMap.get(DomainConstants.SELECT_Name));
						}

					Vector vecResult = new Vector();
					
					for(int j=0; j < strListfolderIds.size(); j++)
						{
							if(!"".equals(strListfolderIds.get(j)))
								{
									strRelatedObjId = (String)strListfolderIds.elementAt(j);
									//only allow unique folder ids to connect to requirement Specification id
									if(!idsList.contains(strRelatedObjId)) 
										{
											vecResult.add(strRelatedObjId);
											
										}
								}
					   } 
					
					String [] strArrayFolderIdsValues = new String[vecResult.size()];	

                        //Added:2-Feb-09:kyp:R207:Bug 361383
                        strArrayFolderIdsValues = (String[])vecResult.toArray(strArrayFolderIdsValues);
                        //EndR207:Bug 361383
	
                        /*Removed:2-Feb-09:kyp:R207:Bug 361383
					     for(int counter=0; counter < strArrayFolderIdsValues.length; counter++){
					           strArrayFolderIdsValues[counter] = (String)vecResult.elementAt(counter); 
                         }	 
                        End:R207:Bug 361383*/

					//connect the requirement Specification id with the folder ids array
					java.util.Map connectionMap = (java.util.Map)DomainRelationship.connect(context, domObj, relVaultedDocs, false, strArrayFolderIdsValues);
				
					}
			
				}  //end of try  
		
			catch (Exception e) 
				{
					throw new Exception(e.getMessage());
				}
			} //end of if loop

String strMsg2 = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.SameProjectSelectionNotAllowed");
%>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../components/emxComponentsJSFunctions.js"></script>

<script language="JavaScript">
		{ 
			var folderName = "";
			var fieldNameDisplay = '<xss:encodeForJavaScript><%=fieldNameDisplay%></xss:encodeForJavaScript>';

			var folderId = "";
			var objForm  = "";
			//KIE1 ZUD TSK447636 
			var vhref = getTopWindow().getWindowOpener().location.href;
			
			var countEdit = 0;
			var countAddToProjectFolder = "";

			var folderNames ="";
			var folderIds ="";

			var id = "";
			var oid = "";
			var name = "";
			var uniqueFolderId = new Array();
			var uniqueFolderName = new Array();
			var uniqueFolderIdsArray = new Array();
			var uniqueFolderNamesArray = new Array();
			var uniqueFolderIds = "";
			var uniqueFolderNames = "";
	   
			//check if values are coming from edit page
			//++ HAT1 ZUD IR-320838-3DEXPERIENCER2015x.
			//-- HAT1 ZUD IR-320838-3DEXPERIENCER2015x.
            countEdit = vhref.indexOf("emxForm.jsp");
			if(countEdit > 0) 
				{
				//KIE1 ZUD TSK447636 
					objForm = emxUICore.getNamedForm(getTopWindow().getWindowOpener(), '<xss:encodeForJavaScript><%=formName%></xss:encodeForJavaScript>');
				var fieldNameActual = '<xss:encodeForJavaScript><%=fieldNameActual%></xss:encodeForJavaScript>';
            
				 //if user selected the folder values second time need to remove duplicate & append only unique ones
				if((objForm.elements[fieldNameDisplay].value)==null || (objForm.elements[fieldNameDisplay].value)=="")
					{
						folderName = '<xss:encodeForJavaScript><%=sbFolderName.toString()%></xss:encodeForJavaScript>';
						objForm.elements[fieldNameDisplay].value=folderName;
						folderId = '<xss:encodeForJavaScript><%=strObjIds%></xss:encodeForJavaScript>';
						objForm.elements[fieldNameActual].value=folderId; 
					} 
				else
					{
						folderName  = objForm.elements[fieldNameDisplay].value;
					    folderNames = '<xss:encodeForJavaScript><%=sbFolderName.toString()%></xss:encodeForJavaScript>';
						folderId    = '<xss:encodeForJavaScript><%=strObjIds.toString()%></xss:encodeForJavaScript>';
						folderIds   = objForm.elements[fieldNameActual].value;
				
		    			uniqueFolderId   = folderId.split(",");
						uniqueFolderName = folderNames.split(",");

						if((folderIds.indexOf("["))> -1)
						  {
							oids = folderIds.substring(1,folderIds.length);
							folderIds = oids;
				
							if((folderIds.indexOf("]"))> -1)
								{
									oids = folderIds.substring(0,folderIds.length-1);
									folderIds = oids;
								}
							}

					var count=0;
					for(var i=0; i< uniqueFolderId.length; i++)
						{
	                       id   = uniqueFolderId[i];
					       name = uniqueFolderName[i];
					
						if((id.indexOf("["))> -1)
							{
								oid = id.substring(1,id.length);
								id = oid;
							}

						if((id.indexOf("]"))> -1)
							{
							  oid = id.substring(0,id.length-1);
							   id = oid;
							}
						
						//check if the selection contains duplicate values
						if((folderIds.indexOf(jsTrim(id)))>-1)
							{
								//alert("<%=strMsg2%>");	
							}
						else
							{
						   		uniqueFolderIdsArray[count]=id;
								uniqueFolderNamesArray[count]=name;
								count++;
							}
				   
						}

					for (var itr=0; itr < uniqueFolderIdsArray.length ; itr++) 
						{
							uniqueFolderIds+= uniqueFolderIdsArray[itr];
							uniqueFolderNames+= uniqueFolderNamesArray[itr];

							if(itr < uniqueFolderIdsArray.length-1)
								{
									uniqueFolderIds+= ',';
									uniqueFolderNames+= ',';
								}
						}
                 	uniqueFolderIds = uniqueFolderIds.substring(0,uniqueFolderIds.length);
							
					if(uniqueFolderIds.length >0)
						{
							folderNames = folderName +','+uniqueFolderNames;
							objForm.elements[fieldNameDisplay].value=folderNames;
							folderId  = folderIds +','+uniqueFolderIds;
							objForm.elements[fieldNameActual].value=folderId;
						}
					else
						{
							objForm.elements[fieldNameDisplay].value=folderName;
							objForm.elements[fieldNameActual].value='<xss:encodeForJavaScript><%=strObjIds%></xss:encodeForJavaScript>'; 
						}
					}
					getTopWindow().closeWindow();
				}  
		else{
				if(isIE){ getTopWindow().open('','_self',''); }
				//KIE1 ZUD TSK447636 
				getTopWindow().closeWindow();
				getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
			}
	}
</script>
