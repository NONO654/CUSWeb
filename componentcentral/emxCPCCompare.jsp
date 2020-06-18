 <%--  emxObjectCompareReportBody.jsp
       (c) Dassault Systemes, 1993-2016.  All rights reserved.
 --%>

 <jsp:useBean id="compareBean" class="com.matrixone.apps.componentcentral.CPCCompare" scope="session"/>
 <%@include file = "../common/emxNavigatorInclude.inc"%>
 <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>


 <%
        String acceptLanguage=request.getHeader("Accept-Language");
        String browser = request.getHeader("USER-AGENT");



        boolean pivot=true;
        if (compareBean.pivot)
        {
            pivot = false;
        }
		boolean disExtAttr = true;
		if (compareBean.displayExtAttr)
		{
		    disExtAttr = false;
        }
        boolean isIE = browser.indexOf("MSIE") > 0;
        boolean reportMode = false;

        if ( !(reportMode && isIE) )
        {
 %>
             <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
 <%
        }

 try
         {
           MapList objectMapList =null;
           String baseObjectId = compareBean.getBaseObjectID();
           HashMap tableBeanMap = (HashMap)session.getAttribute("cpcTableMap");
           HashMap reqMap = (HashMap)tableBeanMap.get("RequestMap");
           String selPartObjectId = (String)reqMap.get("selPartObjectId");
           String selPartRelId = (String)reqMap.get("selPartRelId");
           String selPartParentOId = (String)reqMap.get("selPartParentOId");
           String objectId = (String)reqMap.get("objectId");
           String calledMethod = (String)reqMap.get("calledMethod");
           objectMapList =(MapList) compareBean.getCompareReport(context,(String)session.getAttribute("timeZone"), tableBeanMap,acceptLanguage);
           if(objectMapList == null)
           {
              objectMapList=new MapList();
           }
           String selectedAttributes[] =(String[]) compareBean.getselectedAttributes();

           Calendar currServerCal = Calendar.getInstance();
           Date currentDateObj = currServerCal.getTime();
           int iDateFormat = PersonUtil.getPreferenceDateFormatValue(context);
           java.text.DateFormat outDateFrmt= java.text.DateFormat.getDateInstance(iDateFormat, request.getLocale());
           currentDateObj = outDateFrmt.parse(outDateFrmt.format(currentDateObj));
           String currentTime = outDateFrmt.format(currentDateObj);
           String userName = "";
           userName = PersonUtil.getFullName(context);

           String headerNotice="";
           String noticeAppendString="";
           headerNotice=getI18NString("emxComponentCentralStringResource","emxComponentCentral.ObjectCompare.ReportMessage", acceptLanguage);
           String basicAttrHeader = getI18NString("emxComponentCentralStringResource","emxComponentCentral.ObjectCompare.BasicAttributes",acceptLanguage);
           String extendedAttrHeader = getI18NString("emxComponentCentralStringResource","emxComponentCentral.ObjectCompare.ExtendedAttributes",acceptLanguage);
           String libraryAttrHeader = getI18NString("emxComponentCentralStringResource","emxComponentCentral.ObjectCompare.LibraryAttributes",acceptLanguage);
		   String basePart = getI18NString("emxComponentCentralStringResource","emxComponentCentral.ObjectCompare.BasePart",acceptLanguage);
		   String comparedPart = getI18NString("emxComponentCentralStringResource","emxComponentCentral.ObjectCompare.ComparedPart",acceptLanguage);
		   String busObjectNotFound = getI18NString("emxComponentCentralStringResource","emxComponentCentral.Common.NoBusinessObject",acceptLanguage);
           // Adding appropriate styles
             if ( reportMode && isIE)
              {
              }
            else
            {
              noticeAppendString=getI18NString("emxComponentCentralStringResource","emxComponentCentral.ObjectCompare.ReportMessage1", acceptLanguage);
%>
             <script>
                  addStyleSheet("emxUICompareReport");
            </script>
<%
            }
%>

           <script language="javascript">

			  function pivotCompareReportTable()
              {
                 window.parent.location.href = "emxCPCCompareFS.jsp?pivot=<%=pivot%>&calledMethod=<%=calledMethod%>";
              }
				//displayExtendedAttributes
              function displayExtendedAttributes()
              {
				 window.parent.location.href = "emxCPCComparePreProcess.jsp?showExt=true&disExtAttr=<%=disExtAttr%>&calledMethod=<%=calledMethod%>";

		  	  }
              function checkBasePart(radobj)
              {
				var objForm = document.objcomparereport;
				var selectedBaseId=radobj.value;

				if (radobj.checked) {
					document.objcomparereport.baseObjId.value = selectedBaseId;
				}

				document.objcomparereport.action= "emxCPCCompareFS.jsp?pivot=<%=pivot%>&calledMethod=<%=calledMethod%>";
				document.objcomparereport.submit();
			  }
			  function submitAddExisting()
			  {

				  var selPartId=0;
				  for(z=0;z<document.objcomparereport.elements.length;z++) {
				  	if(document.objcomparereport.elements[z].checked == true) {
						selPartId=document.objcomparereport.elements[z].value;
					}
				  }
				var callMethod = "<%=calledMethod%>";
				var winobj = getTopWindow().getWindowOpener().getTopWindow();

				winobj.top.location.href = "../componentexperience/emxCPXPartBOMAddExisting.jsp?&selPartObjectId=<%=selPartObjectId%>&selPartRelId=<%=selPartRelId%>&selPartParentOId=<%=selPartParentOId%>&objectId=<%=objectId%>&emxTableRowId="+selPartId;
				getTopWindow().close();

		      }
           </script>
<%         if ( !(reportMode && isIE) )
              {
%>
    </head>
    <body>
<%
              }
%>
           <form name="objcomparereport" id="objcomparereport" target="_top">
			<input type=hidden name="baseObjId" value="">
			<input type=hidden name="calledMethod" value="<xss:encodeForHTMLAttribute><%=calledMethod%></xss:encodeForHTMLAttribute>">

             <table border="0" cellpadding="5" cellspacing="0" class="list" width="100%">
               <thead>
                 <tr>
                    <td colspan="<%=selectedAttributes.length%>"><%=headerNotice %> <span class="highlight"><%=noticeAppendString %></span> </td>
                 </tr>
                 <tr>

<%


           Map objDetails=null;
           Map style=null;
           String attrValue="";
           String attrName="";
           String cellStyle="";
           String alias="";
           String typeIcon="";
           String basicAttrLabel = "";
           int basicAttrSize=Integer.parseInt(selectedAttributes[0]);
           int dispBasicAttrLength = basicAttrSize-4;
		   int extAttrSize=Integer.parseInt(selectedAttributes[1]);
		   int libAttrSize = Integer.parseInt(selectedAttributes[2]);
		   int displayLibSize = 0;
		   if(extAttrSize == -1)
		   		displayLibSize = basicAttrSize+1;
		   else
				displayLibSize = basicAttrSize+extAttrSize-1;
           Vector attributes = new Vector();
           for (int i=3;i<selectedAttributes.length;i++ )
           {
              attributes.addElement(selectedAttributes[i]);
           }

           Iterator attrItr = attributes.iterator();
           Iterator listItr = objectMapList.iterator();

           if (!compareBean.pivot)
           {
			   %>
						<td></td>
						<td colspan="<%=dispBasicAttrLength%>"><span class="listCell"><b><%=basicAttrHeader%></b></span> </td>
						<%
						if (compareBean.displayExtAttr) {
						%>
							<td></td><td colspan="<%=extAttrSize%>"><span class="listCell"><b><%=extendedAttrHeader%></b></span> </td><br>

						<%
							if(libAttrSize > 0) {
							%>
							<td></td><td colspan="<%=libAttrSize%>"><span class="listCell"><b><%=libraryAttrHeader%></b></span> </td>
							<%
							}
						}
						%>
						</tr>
						<tr>
				<%
                // for displaying selected attributes as table headers in case of non pivot view.
               int k=0;
               for (int i=3;i<selectedAttributes.length;i++)
               {
                     attrName=selectedAttributes[i];
                     if (i<basicAttrSize)
                     {

						if(attrName.equals("id")) {
						%>
	                       <td></td>
						<%

				 	 	}

						else {


							if(!attrName.contains("ProgramHTML")) {
								StringList basAttrList = FrameworkUtil.split(attrName, ":");
								basicAttrLabel =(String) basAttrList.get(0);
								attrName =(String)basAttrList.get(1);
								/*if(!basicAttrLabel.contains("emxFramework")) {
									basicAttrLabel=getI18NString("emxFrameworkStringResource","emxFramework.ObjectCompare."+attrName, acceptLanguage);
								}
								else {
									basicAttrLabel=getI18NString("emxFrameworkStringResource",basicAttrLabel, acceptLanguage);
								}*/
                    	   	 %>
							     <th nowrap="nowrap"><%=basicAttrLabel%> </th>
							 <%
							}
							else {
								StringList attrList = FrameworkUtil.split(attrName, "|");
								String phAttrName = (String)attrList.get(0);
							%>
								<th nowrap="nowrap"><%=phAttrName%> </th>
							 <%
							}
						}
                     }
                     else
                     {
%>
                        <th> <%=getAdminI18NString("Attribute",attrName,acceptLanguage)%>&nbsp;</th>
<%
                      }
                      if(k==(dispBasicAttrLength)){
						%>
						<td></td>
						<%
					  }
					  if((k==(dispBasicAttrLength+extAttrSize)) && (extAttrSize>0)){
						%>
						<td></td>
						<%
					  }
					  k++;
               }
           }
           else
           {

              // If pivot view is true swap attributes list iterator and objects list iterator
              listItr=attributes.iterator();
%>
                <tr><td colspan="<%=objectMapList.size()+2%>" >&nbsp </td></tr>
<%
           }
%>
                 </tr>
               </thead>
            <tbody>
<%
             String nextElement="";
             //Bug Fix 314794
             String orgAttributeName = "";
             AttributeType attrType = null;
             StringList choices =  null;
             String sDataType = "";
			 String sDefaultValue = "";

             int i=2;

             // If pivot view is true loop through attributes.
             // If pivot view is false loop through object maps list
           while(listItr.hasNext())
           {

              attrItr=attributes.iterator();

              if (compareBean.pivot)
              {
                 // If pivot view is true swap attributes list iterator and objects list iterator
                 attrItr =objectMapList.iterator();
                //retrieving attribute name for pivot view
                 if(i==3) {
					 %>
					 <tr><td colspan="<%=objectMapList.size()+2%>" class="listCell"><b><%=basicAttrHeader%></b></td></tr>
					 <%
				}
				if(i==basicAttrSize-1){
					%>
						<tr><td colspan="<%=objectMapList.size()+2%>" class="listCell"><b><%=extendedAttrHeader%></b></td></tr>
					 <%
				}
				if(i==displayLibSize) {
					%>
						<tr><td colspan="<%=objectMapList.size()+2%>" class="listCell"><b><%=libraryAttrHeader%></b></td></tr>
					 <%
				}
                 i++;
                 attrName=selectedAttributes[i];
                 //Bug Fix 314794
                 orgAttributeName = attrName;

                  // displaying the attributes name as a column with table header style.
                 if (i<basicAttrSize)
                 {

					 if(attrName.equals("id")) {
%>
                    <tr>
                     <td> </td>
<%

				 	 }
				 	 else {

%>
                    	<tr>
                    	<%
                    	if(!attrName.contains("ProgramHTML")) {
							StringList basAttrList = FrameworkUtil.split(attrName, ":");
							basicAttrLabel =(String) basAttrList.get(0);
							attrName =(String)basAttrList.get(1);
							/*if(!basicAttrLabel.contains("emxFramework")) {
								basicAttrLabel=getI18NString("emxFrameworkStringResource","emxFramework.ObjectCompare."+attrName, acceptLanguage);
							}
							else {
								basicAttrLabel=getI18NString("emxFrameworkStringResource",basicAttrLabel, acceptLanguage);
							}*/
                    	%>
							<td valign="top" class="pivotHead"><%=basicAttrLabel%> </td>
<%
				    	}
				    	else {
							StringList attrList = FrameworkUtil.split(attrName, "|");
						 	String phAttrName = (String)attrList.get(0);
%>
							<td valign="top" class="pivotHead"><%=phAttrName%></td>
<%
						}
					}
                 }
                 else
                 {
%>
                     <tr>
                         <td valign="top" class="pivotHead"> <%=getAdminI18NString("Attribute",attrName,acceptLanguage)%>&nbsp;</td>
<%
                        attrName="attribute["+attrName+"]";
                 }
                 // dummy variable for iterating.
                 nextElement=(String)listItr.next();
              }
              else
              {
%>
                 <tr>
<%
                 i=2;

                 //retrieving object details for normal view
                 objDetails=(HashMap)listItr.next();

                 style=(HashMap)listItr.next();
                 if(((String)objDetails.get(DomainObject.SELECT_NAME)).equals("") && ((String)objDetails.get(DomainObject.SELECT_REVISION)).equals("revision"))
                 {
                     throw new Exception(busObjectNotFound);
                 }
              }
			  int k=0;
              while(attrItr.hasNext())
              {
                   if (compareBean.pivot)
                   {
                         //retrieving object details for pivot view
                         objDetails=(HashMap)attrItr.next();
                         style=(HashMap)attrItr.next();
                   }
                   else
                   {
                            //retrieving attribute name for normal view
                          i++;
                          if(i<basicAttrSize && !selectedAttributes[i].contains("ProgramHTML") && !selectedAttributes[i].equals("id")) {
							StringList basAttrList = FrameworkUtil.split(selectedAttributes[i], ":");
							attrName =(String)basAttrList.get(1);
					      }
					      else {
                      	    attrName=selectedAttributes[i];
					  	  }
                          //Bug Fix 314794
                          orgAttributeName = attrName;
                          if (i>=basicAttrSize)
                          {

                             attrName="attribute["+attrName+"]";
                          }
                          // dummy variable for iterating.
                          nextElement=(String)attrItr.next();
                   }

           attrValue = (String)objDetails.get(attrName);

           //Bug Fix 314794
           if (attrName.startsWith("attribute["))
           {
            attrType = new AttributeType(orgAttributeName);
            attrType.open(context);
            choices = attrType.getChoices();
            sDataType = attrType.getDataType();
            sDefaultValue = attrType.getDefaultValue();
            attrType.close(context);
            if ("boolean".equals(sDataType))
            {
              attrValue = getRangeI18NString("BooleanAttribute", attrValue, acceptLanguage);
            }
            else if (choices != null && choices.contains(attrValue))
            {
              attrValue = getRangeI18NString(orgAttributeName, attrValue, acceptLanguage);
            }
			else if (sDefaultValue != null && !"".equals(sDefaultValue.trim())  && sDefaultValue.equals(attrValue))
			{
				attrValue = i18nNow.getDefaultAttributeValueI18NString(orgAttributeName, acceptLanguage);
			}
            attrType = null;
            choices =  null;
            sDataType = "";
			sDefaultValue = "";
          }

                   cellStyle=(String)style.get(attrName);
                   typeIcon="";


                    // for internationalising type and policy
                    if (attrName.equals("type"))
                    {
                       attrValue=getAdminI18NString("Type",attrValue,acceptLanguage);
                    }
                    else if (attrName.equals("current"))
                    {
                        attrValue = getStateI18NString((String)objDetails.get(DomainObject.SELECT_POLICY), attrValue, acceptLanguage);
                    }

                   //  Display icon if column is of type "Name"
                    if (attrName.equals(DomainObject.SELECT_NAME))
                    {
                       typeIcon = UINavigatorUtil.getTypeIconProperty(context, (String)objDetails.get(DomainObject.SELECT_TYPE));
                        if (typeIcon == null || "null".equals(typeIcon) || (typeIcon.length() ==0))
                        {
                            typeIcon="iconSmallDefault.gif";
                        }
%>
                <td valign="top" class="<%=cellStyle%>">
                    <table border="0">
                        <tr>
                            <td valign="top">
                                <img src="../common/images/<%=typeIcon%>" border="0" alt="<%=typeIcon%>">
                            </td>
                            <td valign="top">
                                <%=attrValue%>&nbsp;
                            </td>
                        </tr>
                    </table>
                  </td>
<%
                    }
                    else if(attrName.equals("id")) {
						if(attrValue.equals(baseObjectId)) {
						%>
                    	   <td valign="top" class="listCellArchetype">  <input onclick="checkBasePart(this)" type="radio" name="comparePartSelect" value="<xss:encodeForHTMLAttribute><%=attrValue%></xss:encodeForHTMLAttribute>" checked><%=basePart%></td>
						<%
						}
						else {
						%>
                    	   <td valign="top" class="listCellArchetype">  <input onclick="checkBasePart(this)" type="radio" name="comparePartSelect" value="<xss:encodeForHTMLAttribute><%=attrValue%></xss:encodeForHTMLAttribute>"><%=comparedPart%></td>
						<%
						}
					}
                    else
                    {
%>
                       <td  nowrap="nowrap" valign="top" class="<%=cellStyle%>" ><%=attrValue%>&nbsp;</td>
<%
                    }
                    if(k==(dispBasicAttrLength)){
											%>
											<td></td>
											<%
										  }
										  if((k==(dispBasicAttrLength+extAttrSize)) && (extAttrSize>0)){
											%>
											<td></td>
											<%
										  }
					  k++;
              }
         }
%>
            </tr>
         </tbody>
          </table>
         </form>

<%
       }catch (Exception ex)
       {
		   ex.printStackTrace();
          if (ex != null && ex.toString().trim().equals("java.lang.Exception: 'business object' does not exist"))
          {
%>
             <script language = "javascript">
                   alert("<emxUtil:i18nScript localize="i18nId">emxComponentCentral.ObjectCompare.ObjectsDeleted</emxUtil:i18nScript>");
                   parent.window.close();
             </script>
<%
           }
           else
           {
                 emxNavErrorObject.addMessage(ex.toString());
           }
       }
     if ( !(reportMode && isIE) )
              {
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc" %>
</body>
</html>
<%
              }

%>
