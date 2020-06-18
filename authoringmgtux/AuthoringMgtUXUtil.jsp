<%--
  AuthoringMgtUXUtil.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>

<%@ page import = "com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>

<%@ page import = "matrix.db.*,
                   matrix.util.* ,
                   com.matrixone.servlet.*,
                   java.io.*,
                   java.util.*,
                   java.util.List"%>
                   
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>

<%
    
    boolean bIsError = false;
    String strMode = emxGetParameter(request,"mode");
    String stringResFileId = "emxEnterpriseChangeMgtStringResource";
	
    try     
    {
            if ("displayWorkUnder".equalsIgnoreCase(strMode))
            {   
            	String objectId      = (String)emxGetParameter(request, "objectId");
            	String changeControlCAName = "";
            	String changeControlCAId = "";
            	
            	String selectWorkUnderChange = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(), "AuthoringMgtUX.command.SelectWorkUnderChange");
                String workUnderChange = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(), "AuthoringMgtUX.Label.WorkUnderChange");
                
                HashMap requestMap = new HashMap();
                requestMap.put("objectId", objectId);
                
                HashMap programMap = new HashMap();
                programMap.put("requestMap", requestMap);
                
                Map changeControlCAInfo = (Map)JPO.invoke(context, "AuthoringMgtUxUtil", null, "getChangeControlCA", JPO.packArgs (programMap), Map.class);
                
                if(changeControlCAInfo != null && changeControlCAInfo.containsKey(DomainConstants.SELECT_ID)){
                	changeControlCAName = (String)changeControlCAInfo.get(DomainConstants.SELECT_NAME);
                	changeControlCAId = (String)changeControlCAInfo.get(DomainConstants.SELECT_ID);
                }
				
                %>
                <script>
                	displayWorkUnder();
                	
		            function displayWorkUnder() {
		            	
		            	var indentedTableDoc = self.parent.document;
		            	var indentedTableToolbars = self.parent.toolbars;
		            	
						var getAuthoringCommand = function(){
            				
            				var authoringCommand;
            				
            				for(var i=0; i < indentedTableToolbars.length; i++){
            					
            					var toolbarItems = indentedTableToolbars[i].items;
            					
            					if(toolbarItems && toolbarItems.length){
            						for(var j=0; j < toolbarItems.length; j++){
                						var toolbarItem = toolbarItems[j];
                						
                						if(toolbarItem.id == "ENOAuthoringUXCommand"){
                							return toolbarItem;                							
                						}
                					}
            					}
            				}
            			};
		            	
		            	var workUnderChangeClearImgOnClick = function(){
            				indentedTableDoc.getElementById("WorkUnderChange_displayValue").value = "";
            				indentedTableDoc.getElementById("WorkUnderChange_actualValue").value = "";
            			};
            			
		            	var workUnderChangeChooserCloseBtnOnClick = function(){            			    
		            		var newIcon = "../common/images/iconSmallActionWorkUnderCA.png";
		                	var newImage = "<img data-type=\"command\" src=\"../common/images/iconSmallActionWorkUnderCA.png\">";
		                	var newWorkUnderChangeTitle = "<%= selectWorkUnderChange %>";
		                	self.parent.setRequestSetting("ChangeAuthoringContextOID", "");
		                	
		                	if ( indentedTableDoc.getElementById("WorkUnderChange_displayValue").value != null && indentedTableDoc.getElementById("WorkUnderChange_displayValue").value != "" ) {		                		
		                		newIcon = "../common/images/iconSmallActionWorkUnderCACheck.png";
		                		newImage = "<img data-type=\"command\" src=\"../common/images/iconSmallActionWorkUnderCACheck.png\">";
		                		newWorkUnderChangeTitle = "<%= workUnderChange %> : " + indentedTableDoc.getElementById("WorkUnderChange_displayValue").value;
		                		self.parent.setRequestSetting("ChangeAuthoringContextOID", indentedTableDoc.getElementById("WorkUnderChange_actualValue").value);
		                	}
		                	  
		                	var workUnderCommandObj = getAuthoringCommand();
		                	workUnderCommandObj.element.title = newWorkUnderChangeTitle;
		                	workUnderCommandObj.text = newWorkUnderChangeTitle;
		                	workUnderCommandObj.element.innerHTML = newImage;
		                	workUnderCommandObj.icon = newIcon;
		                					                	
		                	indentedTableDoc.getElementById("workUnderChangeChooser").style.display = "none";
            			};
		            	
		            	
		            	if (indentedTableDoc.getElementById("workUnderChangeChooser") == null || indentedTableDoc.getElementById("workUnderChangeChooser") == "undefined") {
		            			var workUnderChangeDisplayText = indentedTableDoc.createElement("input");
		            			workUnderChangeDisplayText.setAttribute("type", "text");
		            			workUnderChangeDisplayText.setAttribute("name", "WorkUnderChange_displayValue");
		            			workUnderChangeDisplayText.setAttribute("id", "WorkUnderChange_displayValue");
		            			workUnderChangeDisplayText.setAttribute("value", "<%= changeControlCAName %>");
		            			workUnderChangeDisplayText.setAttribute("size", "25");
		            			workUnderChangeDisplayText.setAttribute("style", "padding: 6px;");
		            			workUnderChangeDisplayText.setAttribute("placeholder", "<%= selectWorkUnderChange %>");
		            			workUnderChangeDisplayText.setAttribute("readonly", "true");
		            			
		            			var workUnderChangeActualHidden = indentedTableDoc.createElement("input");
		            			workUnderChangeActualHidden.setAttribute("type", "hidden");
		            			workUnderChangeActualHidden.setAttribute("name", "WorkUnderChange_actualValue");
		            			workUnderChangeActualHidden.setAttribute("id", "WorkUnderChange_actualValue");
		            			workUnderChangeActualHidden.setAttribute("value", "<%= changeControlCAId %>");
		            			
		            			var workUnderChangeClearImg = indentedTableDoc.createElement("img");
		            			workUnderChangeClearImg.setAttribute("src", "images/iconActionRefresh.gif");
		            			workUnderChangeClearImg.setAttribute("id", "workUnderChangeClearImg");
		            			workUnderChangeClearImg.onclick = workUnderChangeClearImgOnClick;
		            			
		            			var workUnderChangeChooserBtn = indentedTableDoc.createElement("input");
		            			workUnderChangeChooserBtn.setAttribute("type", "button");
		            			workUnderChangeChooserBtn.setAttribute("value", "...");
		            			workUnderChangeChooserBtn.setAttribute("style", "padding: 6px;");
		            			workUnderChangeChooserBtn.setAttribute("onclick", "javascript:showModalDialog(\"../common/emxFullSearch.jsp?field=TYPES=type_ChangeAction:CURRENT=policy_ChangeAction.state_InWork&includeOIDprogram=AuthoringMgtUxUtil:getEligibleWorkunderChangeAction&txtPolicy=policy_ChangeAction&table=AuthoringMgtUXSearchResult&showInitialResults=false&objectId=<%=objectId %>&selection=single&submitAction=refreshCaller&submitURL=../authoringmgtux/AuthoringMgtUXUtil.jsp&fieldNameActual=WorkUnderChange_actualValue&fieldNameDisplay=WorkUnderChange_displayValue&mode=workUnderChange&sortColumnName=Name&portalMode=false&expandProgram=false&isIndentedView=false&showSavedQuery=True&searchCollectionEnabled=True\");");
		            				
		            			var workUnderChangeChooserCloseBtn = indentedTableDoc.createElement("input");
		            			workUnderChangeChooserCloseBtn.setAttribute("type", "button");
		            			workUnderChangeChooserCloseBtn.setAttribute("value", "\u2714");		            			
		            			workUnderChangeChooserCloseBtn.setAttribute("style", "padding: 6px;");
		            			workUnderChangeChooserCloseBtn.setAttribute("id", "workUnderChangeChooserCloseBtn");
		            			workUnderChangeChooserCloseBtn.onclick = workUnderChangeChooserCloseBtnOnClick;
		            			
		            			var workUnderChooserTable = indentedTableDoc.createElement("table");
		            			var workUnderChooserTableRow = indentedTableDoc.createElement("tr");
		            			var workUnderChooserTableColumn = indentedTableDoc.createElement("td");			
		            			
		            			workUnderChooserTableColumn.appendChild(workUnderChangeDisplayText);
		            			workUnderChooserTableColumn.appendChild(workUnderChangeActualHidden);
		            			workUnderChooserTableColumn.appendChild(workUnderChangeClearImg);
		            			workUnderChooserTableColumn.appendChild(workUnderChangeChooserBtn);
		            			workUnderChooserTableColumn.appendChild(workUnderChangeChooserCloseBtn);
		            			
		            			workUnderChooserTableRow.appendChild(workUnderChooserTableColumn);
		            			workUnderChooserTable.appendChild(workUnderChooserTableRow);
		            			
		            			var workUnderCommandObj = getAuthoringCommand();
		            			
		            			var iLeft = workUnderCommandObj.element.offsetLeft + 10;
		            			var iTop = workUnderCommandObj.element.offsetTop + 36;
		            					            			
		            			var divWidth = "290px";
		            			var isChrome = Browser.CHROME;
		            			
		            			if (isChrome) { divWidth = "310px"; } 
		            			
		            			var workUnderChangeChooserDiv = indentedTableDoc.createElement("div");
		            			workUnderChangeChooserDiv.setAttribute("id", "workUnderChangeChooser");		
		            			workUnderChangeChooserDiv.setAttribute("align", "center");
		            			workUnderChangeChooserDiv.setAttribute("class", "formLayer");
		            			workUnderChangeChooserDiv.setAttribute("style", "position: absolute; zIndex: 100; visibility: visible; margin: auto");
		            			workUnderChangeChooserDiv.style.width = divWidth;
		            			workUnderChangeChooserDiv.style.maxWidth = divWidth;
		            			workUnderChangeChooserDiv.style.left = iLeft + "px";
		            			workUnderChangeChooserDiv.style.top = iTop + "px";
		            			
		            			workUnderChangeChooserDiv.appendChild(workUnderChooserTable);
		            			
		            			indentedTableDoc.getElementById("pageHeadDiv").appendChild(workUnderChangeChooserDiv);
		            	}
		            	else{
		            		indentedTableDoc.getElementById("workUnderChangeChooser").style.display = "block";
		            		indentedTableDoc.getElementById("workUnderChangeClearImg").onclick = workUnderChangeClearImgOnClick;
		            		indentedTableDoc.getElementById("workUnderChangeChooserCloseBtn").onclick = workUnderChangeChooserCloseBtnOnClick;
		            	}
		            }
                </script>
                <%
            }
            else if("workUnderChange".equalsIgnoreCase(strMode)){ 
            	String fieldNameActual = emxGetParameter(request, "fieldNameActual");
        	    String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
        	    String fieldNameOID = emxGetParameter(request, "fieldNameOID");
        	    
        	  //get the selected Objects from the Full Search Results page
			     String strContextObjectId[] = emxGetParameterValues(request, "emxTableRowId");
			     
	             fieldNameActual = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameActual"));
	             fieldNameDisplay = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "fieldNameDisplay"));
	             
                StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[0] , "|");
                String strObjectId = strTokenizer.nextToken(); 

                DomainObject objContext = new DomainObject(strObjectId);
                String strContextObjectName = objContext.getInfo(context, DomainConstants.SELECT_NAME);
	                 
	%>
                <script language="javascript" type="text/javaScript">
	      			var vfieldNameActual = null;
	      			var vfieldNameDisplay = null;
	      			
	      			vfieldNameActual = getTopWindow().getWindowOpener().document.getElementById("<%=fieldNameActual%>");
		            vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementById("<%=fieldNameDisplay%>");			            
		            //getTopWindow().getWindowOpener().setRequestSetting("ChangeAuthoringContextOID", "<%=strObjectId%>");
	      			
	      		   vfieldNameDisplay.value ="<%=strContextObjectName%>" ;
                  vfieldNameActual.value ="<%=strObjectId%>" ;

                  getTopWindow().closeWindow();
                 
                </script>
	<%
            }
		}
		catch (Exception e) {
			bIsError = true;
			session.putValue("error.message", "" + e);
			
		}// End of main Try-catck block
            
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>



