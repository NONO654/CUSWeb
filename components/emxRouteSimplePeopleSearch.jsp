<%@include file = "../emxTagLibInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc" %>
<emxUtil:localize id="i18nId" bundle="emxComponentsStringResource" locale='<%= request.getHeader("Accept-Language") %>'/>
<%
        String findRole = emxGetParameter(request,"findRole");
        String findPerson = emxGetParameter(request,"findPerson");
        String findGroup = emxGetParameter(request,"findGroup");
        String findUserGroup = emxGetParameter(request,"findUserGroup");
        String findMemberList = emxGetParameter(request,"findMemberList");

%>
      <table cellpadding="5" cellspacing="2" width="100%">
	<tr>
		<td class="labelRequired" width="100%"> <emxUtil:i18n localize = "i18nId">emxComponents.CreateSimpleRoute.RouteTaskReceipents</emxUtil:i18n></td>
	</tr>
      </table>
      
	  <table cellpadding="5" cellspacing="2" width="100%">
          <tr>
   		<td width="100%" class="inputField">
   			<table width="100%">
   			<tr>
   					<td width="60%" valign="top" class="inputField">
   					<table cellpadding="2" cellspacing="0" >
   					<tr>
		                            	<td>
		                                	<select  size="7" style="width:400px" multiple name="memberFinalList" ></select>
                                            </td>
   					</tr>
   					<tr>
   								<td>
   									&nbsp;
   								</td>
   					</tr>
   					<tr>
		                            	<td align="left">
                                            <div class="rollover"  style="display: inline; width: 25%"  onmouseover="handleButtonEvent(1,this)" onmousedown="handleButtonEvent(2,this)" onmouseout="handleButtonEvent(3,this)"  onmouseup="handleButtonEvent(4,this)"  onclick="loadPersonPropertiesPage()">
		                                    	<img src="../common/images/iconSmallProperties.gif" border="middle" align="absmiddle" />&nbsp; <emxUtil:i18n localize = "i18nId">emxComponents.CreateSimpleRoute.Properties</emxUtil:i18n>
		                                    </div>
		                                    <div class="rollover" style="display: inline; width: 25%"  onmouseover="handleButtonEvent(1,this)" onmousedown="handleButtonEvent(2,this)"  onclick="removeRouteMember()"  onmouseout="handleButtonEvent(3,this)"  onmouseup="handleButtonEvent(4,this)">
		                                		<img src="../common/images/iconActionRemove.gif" border="middle" align="absmiddle" />&nbsp;<emxUtil:i18n localize = "i18nId">emxComponents.CreateSimpleRoute.Remove</emxUtil:i18n>
		                                	</div>
                                            </td>
   					</tr>	
					</table>
   				</td>
   					<td width="40%" valign="top" align="left" class="inputField">
   					<table cellpadding="0" cellspacing="2">
					<%if(!"hide".equals(findRole)){%>
   					<tr>
                            	<td>
                                            <div class="rollover" onmouseover="handleButtonEvent(1,this)" onmousedown="handleButtonEvent(2,this)"  onclick="getRouteMemebers('findRole')"  onmouseout="handleButtonEvent(3,this)"  onmouseup="handleButtonEvent(4,this)" >
                                    	<img src="../common/images/iconSmallRole.gif" border="middle" align="absmiddle" />&nbsp; <emxUtil:i18n localize = "i18nId">emxComponents.AddMembersDialog.AddRole</emxUtil:i18n>
                                    </div>
                                            </td>		
   					</tr>
					<%}if(!"hide".equals(findGroup)){%>
  					<tr>
                            	<td>
                                            <div class="rollover" onclick="javascript:getRouteMemebers('findGroup')" onmouseover="handleButtonEvent(1,this)" onmousedown="handleButtonEvent(2,this)"  onmouseout="handleButtonEvent(3,this)"  onmouseup="handleButtonEvent(4,this)" >
                                    	<img src="../common/images/iconSmallGroup.gif" border="middle" align="absmiddle" />&nbsp; <emxUtil:i18n localize = "i18nId">emxComponents.AddMembersDialog.AddGroup</emxUtil:i18n>
                                    </div>
                                            </td>		
   					</tr>
   					<%}if(!"hide".equals(findUserGroup)){%>
  					<tr>
                            	<td>
                                            <div class="rollover" onclick="javascript:getRouteMemebers('findUserGroup')" onmouseover="handleButtonEvent(1,this)" onmousedown="handleButtonEvent(2,this)"  onmouseout="handleButtonEvent(3,this)"  onmouseup="handleButtonEvent(4,this)" >
                                    	<img src="../common/images/iconActionAddPersons.png" border="middle" align="absmiddle" />&nbsp; <emxUtil:i18n localize = "i18nId">emxFramework.Common.RouteAccessAddUserGroups</emxUtil:i18n>
                                    </div>
                                            </td>		
   					</tr>
					<%}if(!"hide".equals(findPerson)){%>
  					<tr>
                        		<td>
                                            <div class="rollover" onclick="javascript:getRouteMemebers('findPerson')" onmouseover="handleButtonEvent(1,this)" onmousedown="handleButtonEvent(2,this)"  onmouseout="handleButtonEvent(3,this)"  onmouseup="handleButtonEvent(4,this)" >
                                    	<img src="../common/images/iconSmallPerson.png" border="middle" align="absmiddle" />&nbsp; <emxUtil:i18n localize = "i18nId">emxComponents.AddMembersDialog.AddPeople</emxUtil:i18n>
                                    </div>
                                            </td>		
   					</tr>
					<%}if(!"hide".equals(findMemberList)){%>
  					<tr>
                            	<td>
                                            <div class="rollover" onclick="javascript:getRouteMemebers('findMemberList')" onmouseover="handleButtonEvent(1,this)" onmousedown="handleButtonEvent(2,this)"  onmouseout="handleButtonEvent(3,this)"  onmouseup="handleButtonEvent(4,this)" >
                                    	<img src="../common/images/iconSmallMemberList.gif" border="middle" align="absmiddle" />&nbsp; <emxUtil:i18n localize = "i18nId">emxComponents.AddMembersDialog.AddMemberList</emxUtil:i18n>
                                    </div>
                                            </td>		
   					</tr>
					<%}%>
   					<tr>
                                            <td>&nbsp;</td>
   					</tr>
					</table>

   				</td>
   			</tr>
   			</table>
   		</td>
      </tr>
      </table>




      <script language="JavaScript">
    
            function loadFinalMemberList(values,labels)
            {
                thisForm=document.createSimpleDialog;
                selectBox=thisForm.memberFinalList;
    for(i=0;i<values.length;i++) {
                       curLabel=labels[i];
                       curValue=values[i];
                       curLabel=changeLabel(curValue,curLabel);
                       o=new Option(curLabel,curValue,false,false);
                       selectBox.options[i]=o;

                }
            }

function changeLabel(value,label) {
	if(value.indexOf("role_")!=-1 && label.indexOf("(ROLE)") ==-1) {
							label = label + "(ROLE)";
					}
	if(value.indexOf("group_")!=-1 && label.indexOf("(GROUP)") ==-1) {
							label = label +"(GROUP)";
					}
                    return label;
			}

function cleanComboBox(comboObject) {
	for(i=0;i<comboObject.length;i++) {
                        comboObject.options[i]=null;
                    }
            }

function shiftMembers(box1,box2) {		
					selectBox=box1;
					finalBox=box2
	for(i=0; i <selectBox.length;i++) {
						curOption=selectBox.options[i];
		if(curOption.selected) {
                                curValue=curOption.value;
								curLabel=changeLabel(curValue,curOption.text);
								finalBox[finalBox.length]=new Option(curLabel,curValue,false,false);
                                selectBox.options[i]=null;
						}
					}
			}

function populateComboBoxes(category) {
                thisForm=document.createSimpleDialog;
                selectBox=thisForm.memberFinalList;
                cleanComboBox(selectBox)
                labels=eval(category+"Labels");
                values=eval(category+"Values");
    for(i=0;i<labels.length;i++) {
                    o=new Option(labels[i],values[i],false,false);
                    selectBox[i]=o;
                }

            }

function makeFinalMemberList(strValue) {
	if(strValue!=null && strValue!="") {
                            optionElements=strValue.split("|");
                            labels=new Array();
                            values=new Array();
        for(i=0;i<optionElements.length;i++) {
                                    combText=optionElements[i].split("~");
                                    values[i]=combText[0];
                                    labels[i]=combText[1];
                            }
                            loadFinalMemberList(values,labels);
                   }
            }

function joinFinalMemberList(strValue) {
                thisForm=document.createSimpleDialog;
                selectBox=thisForm.memberFinalList;
                optionStr="";
    if(selectBox!=null && selectBox.length>0) {
		for(i=0;i<selectBox.length-1;i++) {
                            o=selectBox[i];
                            optionStr=optionStr+o.value+"~"+o.text+"|";
                        }
                       o=selectBox[i];
                       optionStr=optionStr+o.value+"~"+o.text;
                }
                return optionStr;
            }


</script>
