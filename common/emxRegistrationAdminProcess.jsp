<%-- emxRegistrationAdminProcess.jsp - This page is the processing page for Admin property registration dialog
    Copyright (c) 1992-2018 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only
    and does not evidence any actual or intended publication of such program
    
    static const char RCSID[] = $Id: emxRegistrationAdminProcess.jsp.rca 1.8 Wed Oct 22 15:48:32 2008 przemek Experimental przemek $
    
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<html>
<head>
<jsp:useBean id="adminBean" class="com.matrixone.apps.domain.util.RegistrationUtil"/>
<script type="text/javascript" src="../common/scripts/emxAdminUtils.js"></script>
<%
	matrix.db.Context mnCtx = Framework.getMainContext(request);
    String sAdminType           = (String) emxGetParameter(request, "lstAdminType");
    String shdnMode             = (String) emxGetParameter(request, "hdnMode");
    String sAdminName           = (String) emxGetParameter(request, "hdnregisteredadmins");
    String sSymbolicName        = (String) emxGetParameter(request, "txtSymbolicName");
    String sUnRegisteredAdmins  = (String) emxGetParameter(request, "lstunregisteredadmins");
    String shdnRegListIndex     = (String) emxGetParameter(request, "hdnRegListIndex");
    String shdnUnRegListIndex   = (String) emxGetParameter(request, "hdnUnRegListIndex");
    double clientTZOffset       = (new Double((String)session.getValue("timeZone"))).doubleValue();
//  uncomment the below lines for variable length select list boxes    
//  StringBuffer sbRegisteredValues     = new StringBuffer("<select name=\"lstregisteredadmins\" id=\"lstregisteredadmins\" onselect=\"disablefields();\"  onchange=\"disablefields();\" size=\"10\">");
//  StringBuffer sbUnRegisteredValues   = new StringBuffer("<select name=\"lstunregisteredadmins\" id=\"lstunregisteredadmins\" size=\"10\">");
//  uncomment the below lines for fixed length select list boxes 
	boolean isMobile = Boolean.valueOf(mnCtx.getCustomData("isMobile"));
	String style = isMobile ? "style=\"width:250px;text-overflow:ellipsis;overflow:hidden\"" : "";
    StringBuffer sbRegisteredValues     = new StringBuffer("<select name=\"lstregisteredadmins\" id=\"lstregisteredadmins\" onselect=\"disablefields();\"  onchange=\"disablefields();\" size=\"10\"" +style+ ">");
    StringBuffer sbUnRegisteredValues   = new StringBuffer("<select name=\"lstunregisteredadmins\" id=\"lstunregisteredadmins\" size=\"10\"" +style+ ">");
    if((sSymbolicName==null) || (sSymbolicName.equals(""))){
        sSymbolicName  = (String) emxGetParameter(request, "lstregisteredadmins");
    }

    Hashtable htProperties              = null;
    try{
        ContextUtil.startTransaction(context, true);
        if(shdnMode != null && shdnMode.length()>0 ) {
            if((shdnMode.equals("list"))){
                sbRegisteredValues.append(adminBean.getRegisteredList(context, sAdminType));
                sbUnRegisteredValues.append(adminBean.getUnRegisteredList(context, sAdminType));
                sbRegisteredValues.append("</select>");
                sbUnRegisteredValues.append("</select>");
            }else if(shdnMode.equals("properties")){
                htProperties = adminBean.getAdminProperties(context, sAdminType, sAdminName);
            }else{
                // Build the parameter/value HashMap from the request
                HashMap paramMap = UINavigatorUtil.getRequestParameterMap(request);              
                String strDate = (String) paramMap.get("txtInstalledDate");
                if(strDate != null && !"null".equals(strDate) && !strDate.equals("")){
                    //Formatting Date to Ematrix Date Format
                    try{
                        strDate = eMatrixDateFormat.getFormattedInputDate(context,strDate,clientTZOffset,request.getLocale());
                       } catch ( Exception ex) {
                           //Do nothing
                       }
                }
                paramMap.put("txtInstalledDate",strDate);
                if(shdnMode.equals("create")){
                    adminBean.createRegistration(context, paramMap);
                }else if(shdnMode.equals("transfer")){
                    adminBean.transferRegistration(context, paramMap);
                }else if(shdnMode.equals("update")){
                    adminBean.updateRegistration(context, paramMap);
                }else if(shdnMode.equals("delete")){
                    adminBean.deleteRegistration(context, paramMap);
                }
            }
        }
%>
<script language="javascript">
    <%
        if(shdnMode.equals("properties")){
    %>
            parent.document.forms[0].txtSymbolicName.value = parent.document.forms[0].lstregisteredadmins.value;
            <%
                if (htProperties.containsKey("application")) {
                    String strApplication = FrameworkUtil.findAndReplace(FrameworkUtil.findAndReplace((String)htProperties.get("application"),"'","\\\'"),"\"","\\\"");
            %>
                    parent.document.forms[0].txtApplication.value = '<%=strApplication%>';
            <%
                }else{
            %>
                    parent.document.forms[0].txtApplication.value = '';
            <%
                }
            %>
            <%
                if (htProperties.containsKey("version")) {
                String strVersion = FrameworkUtil.findAndReplace(FrameworkUtil.findAndReplace((String)htProperties.get("version"),"'","\\\'"),"\"","\\\"");
            %>
                parent.document.forms[0].txtVersion.value = '<%=strVersion%>';
            <%
                }else{
            %>
                    parent.document.forms[0].txtVersion.value = '';
            <%
                }
            %>
            <%
                if (htProperties.containsKey("installer")) {
                    String strInstaller = FrameworkUtil.findAndReplace(FrameworkUtil.findAndReplace((String)htProperties.get("installer"),"'","\\\'"),"\"","\\\"");
            %>
                    parent.document.forms[0].txtInstaller.value = '<%=strInstaller%>';
            <%
                }else{
            %>
                    parent.document.forms[0].txtInstaller.value = '';
            <%
                }
            %>
            <%
                if (htProperties.containsKey("installed date")) {
                    String strInstalledDate = FrameworkUtil.findAndReplace(FrameworkUtil.findAndReplace((String)htProperties.get("installed date"),"'","\\\'"),"\"","\\\"");
                    String strSlctdate = "";
                    try{
                        strSlctdate      = eMatrixDateFormat.getFormattedDisplayDate(strInstalledDate,clientTZOffset,request.getLocale());
                       } catch(Exception e) {
                           strSlctdate = strInstalledDate;
                       }
            %>
                    parent.document.forms[0].txtInstalledDate.value = '<%=strSlctdate%>';
            <%
                }else{
            %>
                    parent.document.forms[0].txtInstalledDate.value = '';
            <%
                }
            %>
            <%
                if (htProperties.containsKey("original name")) {
                    String strOriginalName = FrameworkUtil.findAndReplace(FrameworkUtil.findAndReplace((String)htProperties.get("original name"),"'","\\\'"),"\"","\\\"");
            %>
                    parent.document.forms[0].txtOriginalName.value = '<%=strOriginalName%>';
            <%
                }else{
            %>
                    parent.document.forms[0].txtOriginalName.value = '';
            <%
                }
            %>
    <%
        }else if((shdnMode.equals("list"))){
    %>
            var lstReg          = parent.document.getElementById("lstreg");
            //XSSOK
            lstReg.innerHTML    =  '<%=sbRegisteredValues.toString()%>';
            var lstUnReg        = parent.document.getElementById("lstunreg");
            //XSSOK
            lstUnReg.innerHTML  =  '<%=sbUnRegisteredValues.toString()%>';
            clearfields(parent.document.forms[0]);
    <%
        }
        String sRegisteredAdmins = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(sAdminName+"","'","\\\'"),"\"","\\\"");
        sUnRegisteredAdmins = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(sUnRegisteredAdmins+"","'","\\\'"),"\"","\\\"");
        sSymbolicName = FrameworkUtil.findAndReplace((String)FrameworkUtil.findAndReplace(sSymbolicName+"","'","\\\'"),"\"","\\\"");
        if(shdnMode.equals("create")){
    %>
            var optUnReg = new Option("<%=sUnRegisteredAdmins%>","<%=sSymbolicName%>");
            parent.document.forms[0].lstregisteredadmins.options.add(optUnReg);
            parent.document.forms[0].lstunregisteredadmins.options[<%=XSSUtil.encodeForHTMLAttribute(context, shdnUnRegListIndex)%>]=null;
    <%
        }else if(shdnMode.equals("transfer")){
    %>
            var optUnReg = new Option("<xss:encodeForHTMLAttribute><%=sUnRegisteredAdmins%></xss:encodeForHTMLAttribute>","<xss:encodeForHTMLAttribute><%=sSymbolicName%></xss:encodeForHTMLAttribute>");
            var optReg = new Option("<xss:encodeForHTMLAttribute><%=sRegisteredAdmins%></xss:encodeForHTMLAttribute>","<xss:encodeForHTMLAttribute><%=sRegisteredAdmins%></xss:encodeForHTMLAttribute>");

            parent.document.forms[0].lstregisteredadmins.options[<%=XSSUtil.encodeForHTMLAttribute(context, shdnRegListIndex)%>]=null;
            parent.document.forms[0].lstunregisteredadmins.options[<%=XSSUtil.encodeForHTMLAttribute(context, shdnUnRegListIndex)%>]=null;

            parent.document.forms[0].lstregisteredadmins.options.add(optUnReg);
            parent.document.forms[0].lstunregisteredadmins.options.add(optReg);
    <%
        }else if(shdnMode.equals("delete")){
    %>
            parent.document.forms[0].lstregisteredadmins.options[<%=XSSUtil.encodeForHTMLAttribute(context, shdnRegListIndex)%>]=null;
            var optReg = new Option("<%=sRegisteredAdmins%>","<%=sRegisteredAdmins%>");
            parent.document.forms[0].lstunregisteredadmins.options.add(optReg);
    <%
        }else if(shdnMode.equals("update")){
    %>
            parent.document.forms[0].lstregisteredadmins.options[<%=XSSUtil.encodeForHTMLAttribute(context, shdnRegListIndex)%>].value="<xss:encodeForHTMLAttribute><%=sSymbolicName%></xss:encodeForHTMLAttribute>";
    <%
        }
    %>
    //Enabling the dissabled butons in the parent page
    enableAdminButtons(parent.document.forms[0],"<xss:encodeForJavaScript><%=shdnMode%></xss:encodeForJavaScript>");

</script>
<%
    } catch (Exception ex) {
        ContextUtil.abortTransaction(context);
        ex.printStackTrace();
        emxNavErrorObject.addMessage(ex.toString().trim());
    } finally {
        ContextUtil.commitTransaction(context);
    }
%>
<script>
    parent.clicked= false;
    parent.turnOffProgress();
</script>
</head>
<body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
