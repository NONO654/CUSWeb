
<%--  MultiObjectSelectDecision.jsp  

Intermediate JSP to update the ContainedInSpecification field by the object name of the selected SpecificationObject

--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
--%>
<!-- Include directives -->
<%@include file = "../emxRequestWrapperMethods.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<!-- Page directives -->
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.servlet.Framework"%>


<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<%
matrix.db.Context context = null;

try {
		matrix.db.Context nestedContext = (matrix.db.Context)request.getAttribute("context");
		if(nestedContext != null){
			context = nestedContext;
		}else{
			context = Framework.getFrameContext(session);
		}
        //Retrieves the time stamp & newObjectId values.
		String timeStamp   = emxGetParameter(request, "timeStamp");
		String newObjectId = emxGetParameter(request, "newObjectId");
		session.setAttribute("newObjectId",newObjectId);

		String strFormName         = "";
		String strFieldNameDisplay = "";
		String strFieldNameActual  = "";
		String strFieldSelected    = "";
		String strSelectedChoice   = "";
		String strDecisionName     = "";
		String strObjname          = "";
		String strfinalObjectNames = "";
		String strfinalObjectid    = ""; 
		String strSelectedAction   = ""; 
		String strFieldRadioSelected  = "";

		strFormName         = emxGetParameter(request, "parentFormName");
		strFieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
		strFieldNameActual  = emxGetParameter(request, "fieldNameActual");
		strFieldSelected    = emxGetParameter(request, "fieldSelected");
		strSelectedChoice   = emxGetParameter(request, "selected");
		strSelectedAction   = emxGetParameter(request, "selectedAction");
		strFieldRadioSelected = emxGetParameter(request, "fieldRadioSelected");

       //when the newly created requirement object id is not null, get the form name & field values.
	   if(newObjectId != null && !"".equalsIgnoreCase(newObjectId) && !"null".equalsIgnoreCase(newObjectId)) {
       

			//construct a new Domain Object with the newObjectId passed.
			DomainObject domDecObj = new DomainObject(newObjectId);
			//get the name information of this business object.
			strDecisionName        = domDecObj.getInfo(context,"name");
			strfinalObjectNames    = strDecisionName;
			strfinalObjectid       = newObjectId;
			session.setAttribute("decisionName",strDecisionName);
	    	session.setAttribute("fieldRadioSelected",strSelectedAction);

		} 
		 //when the existing requirement object ids are selected from the table.
		else{ 

            //get the selected rows object ids
			String[] emxTableRowId = emxGetParameterValues(request, "emxTableRowId");
			String strTableRowId   = "";
			String strShowRevision = emxGetParameter(request, "ShowRevision");
			String languageStr     = request.getHeader("Accept-Language");
            
			    //when no row is selected display the message.
				if ((emxTableRowId == null)||(emxTableRowId.equals("null"))||(emxTableRowId.equals("")))
				{
					String strRetMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Common.PleaseSelectitem"); 
					throw new FrameworkException(strRetMsg);
				}
				//when user selected row enter in else loop.
				else {
                        //iterate to each selected row id
						for(int i=0;i<emxTableRowId.length;i++) {
							strTableRowId = emxTableRowId[i];
						    StringList sList = FrameworkUtil.split(strTableRowId,"|");
						    if(sList.size() == 3){
						        strTableRowId = (String)sList.get(0);
						    }else if(sList.size() == 4){
						        strTableRowId = (String)sList.get(1);
						    }else if(sList.size() == 2){ 
						        strTableRowId = (String)sList.get(1);
						    }
						    							
							//construct a new Domain Object with selected ObjectId passed.
							DomainObject domObj= new DomainObject(strTableRowId);

							Map objMap = new HashMap();
							StringList selectList = new StringList();
							selectList.addElement(DomainConstants.SELECT_TYPE);
							selectList.addElement(DomainConstants.SELECT_REVISION);

							//get a map containing information regarding type, revision of the constructed domain object.
							objMap = domObj.getInfo(context,selectList);          

								if(((strShowRevision != null) && (!strShowRevision.equalsIgnoreCase("")) && !("null".equalsIgnoreCase(strShowRevision))) && (strShowRevision.equalsIgnoreCase("true")))
								{
									//This is to get obj name & rev.
									strObjname =  FrameworkUtil.getObjectNameWithRevision(context, strTableRowId);
								}
								else {
									//This has to be read from the bean method to get name.
									strObjname = FrameworkUtil.getObjectName(context, strTableRowId); 
								}

				                //when the name of the object is neither empty nor null enter in if loop
								if(!"".equals(strObjname) && !"null".equals(strObjname)) {
									if("".equals(strfinalObjectNames) || "null".equals(strfinalObjectNames)) {
										//assign the name & id value to the respective variables.
										strfinalObjectNames=strObjname;
										strfinalObjectid=strTableRowId;
									}
									else {
										//concatenate the names & ids with comma separated.
									   strfinalObjectNames=strfinalObjectNames+","+strObjname;
									   strfinalObjectid=strfinalObjectid+","+strTableRowId;
									}
								}
						 } //end of iteration - for loop
                   }
		    }
       
			String ENO_CSRF_TOKEN = (String)session.getAttribute("ENO_CSRF_TOKEN_SAVED");
			if(ENO_CSRF_TOKEN != null){
				session.setAttribute("ENO_CSRF_TOKEN", ENO_CSRF_TOKEN);
				session.removeAttribute("ENO_CSRF_TOKEN_SAVED");
			}


    %>
    <script language="javascript" src="../common/scripts/emxUICore.js"></script>
    <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="javascript">

		var objForm    = "";
		var objectName = "";
		var objectId   = "";

		var fieldNameDisplay = '<xss:encodeForJavaScript><%=strFieldNameDisplay%></xss:encodeForJavaScript>';
		var fieldNameActual  = '<xss:encodeForJavaScript><%=strFieldNameActual%></xss:encodeForJavaScript>';
		var fieldSelected    = '<xss:encodeForJavaScript><%=strFieldSelected%></xss:encodeForJavaScript>';
  //KIE1 ZUD TSK447636 
  		if(<xss:encodeForJavaScript><%=strFormName%></xss:encodeForJavaScript>){
			objForm = emxUICore.getNamedForm(parent.parent.getTopWindow().getWindowOpener(), '<xss:encodeForJavaScript><%=strFormName%></xss:encodeForJavaScript>');

			objectName = '<xss:encodeForJavaScript><%=strfinalObjectNames%></xss:encodeForJavaScript>';
			//put the name value into the form's respective field value.
			objForm.elements[fieldNameDisplay].value=objectName;

			objectId = '<xss:encodeForJavaScript><%=strfinalObjectid%></xss:encodeForJavaScript>';
			//pass the objectId value into the form's respective field value.
			objForm.elements[fieldNameActual].value=objectId; 

			objForm.elements[fieldNameActual].id='<xss:encodeForJavaScript><%=strSelectedChoice%></xss:encodeForJavaScript>'; 
			objForm.elements[fieldRadioSelected].value='<xss:encodeForJavaScript><%=strSelectedAction%></xss:encodeForJavaScript>'; 
  		}
  		else
  	  	{
			objectName = '<xss:encodeForJavaScript><%=strfinalObjectNames%></xss:encodeForJavaScript>';
			//put the name value into the form's respective field value.
			//objForm.elements[fieldNameDisplay].value=objectName;
			  //KIE1 ZUD TSK447636 
			getTopWindow().getWindowOpener().document.getElementsByName(fieldNameDisplay)[0].value=objectName;

			objectId = '<xss:encodeForJavaScript><%=strfinalObjectid%></xss:encodeForJavaScript>';
			//pass the objectId value into the form's respective field value.
			//objForm.elements[fieldNameActual].value=objectId; 
			  //KIE1 ZUD TSK447636 
			getTopWindow().getWindowOpener().document.getElementsByName(fieldNameActual)[0].value=objectId;
			
			//objForm.elements['selected'].value='<%=strSelectedChoice%>'; 
			getTopWindow().getWindowOpener().document.getElementsByName('DecisionAction')[0].value='<xss:encodeForJavaScript><%=strSelectedChoice%></xss:encodeForJavaScript>';
  		}
			
		getTopWindow().closeWindow();

    </script>

    
    <%
    } // End of try
    catch(Exception ex) {
       session.putValue("error.message", ex.getMessage());
     } // End of catch
    %>
 <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
