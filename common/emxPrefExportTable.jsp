<%--  emxPrefExportTable.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefExportTable.jsp.rca 1.13 Wed Oct 22 15:48:50 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<HTML>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>


  <HEAD>
    <TITLE></TITLE>
    <META http-equiv="imagetoolbar" content="no" />
    <META http-equiv="pragma" content="no-cache" />
    <SCRIPT language="JavaScript" src="scripts/emxUIConstants.js"
    type="text/javascript">
    </SCRIPT>
     <script language="JavaScript" src="scripts/emxUICore.js"></script>
    <SCRIPT language="JavaScript" src="scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT type="text/javascript">
       addStyleSheet("emxUIDefault");
       addStyleSheet("emxUIForm");

       var arrOptions = {};
       <%
     HashMap fieldSeparatorChoicesMap = PersonUtil.getFieldSeparatorChoices(context);
    Iterator keys = fieldSeparatorChoicesMap.keySet().iterator();
    while(keys.hasNext()){
        String key = (String)keys.next();
        ArrayList choices = (ArrayList)fieldSeparatorChoicesMap.get(key);
        for (int i = 0; i < choices.size(); i++)
        {
            String choice = (String)choices.get(i);
	        String choicePropKey = "emxFramework.Preferences.FieldSeparator." + choice.replace(' ', '_');
	        String choicePropValue = UINavigatorUtil.getI18nString(choicePropKey, "emxFrameworkStringResource", request.getHeader("Accept-Language"));

	        %>
	        if(arrOptions["<%=XSSUtil.encodeForJavaScript(context,key)%>"] == null){
	        	arrOptions["<%=XSSUtil.encodeForJavaScript(context,key)%>"] = [];
	        }
	        //XSSOK
	        arrOptions["<%=XSSUtil.encodeForJavaScript(context,key)%>"].push({Actual:"<%=choice%>",Display:"<%=choicePropValue%>"});
        	<%
        }
    } %>


       function doLoad() {
         if (document.forms[0].elements.length > 0) {
           var objElement = document.forms[0].elements[0];

           if (objElement.focus) objElement.focus();
           if (objElement.select) objElement.select();
         }
       }

       function setFormOptions(val){
            try{
                var theForm = document.forms[0];
                var fieldArray = new Array(theForm.fieldSeparator,
                                            theForm.removeCarriageReturns[0],theForm.removeCarriageReturns[1]);
                if(val == "Text" || val == "CSV"){
                	redrawFieldSeperator(val);
                    setDisabled(fieldArray,false);
                }else{
                    setDisabled(fieldArray,true);
                }
                setDisabled(new Array(theForm.recordSeparator_disp),true);
            }catch(e){
            }
       }

       function redrawFieldSeperator(format){
        	var objSelect = document.getElementById("fieldSeparator");
        	for(var i = 0; i < objSelect.options.length; i++){
                objSelect.options[i] = null;
                i--;
            }
            var newOptionsArr = arrOptions[format];

            for(var j = 0; j < newOptionsArr.length; j++){
            	objSelect.options[objSelect.options.length] = new Option(newOptionsArr[j].Display,newOptionsArr[j].Actual);
            }

       }

       function setDisabled(arrFields,bln){
            var len = arrFields.length;
            for(var i = 0; i < len; i++){
                arrFields[i].disabled = bln;
            }
       }
    </SCRIPT>
  </HEAD>
  <BODY onload="doLoad(), turnOffProgress()">
    <FORM method="post" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose();" action="emxPrefExportTableProcessing.jsp">
      <TABLE border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.Preferences.ExportFormat.Format</emxUtil:i18n>
          </TD>
          <TD class="inputField">
            <TABLE border="0">
<%
    try
    {
    ContextUtil.startTransaction(context, false);
    // Get Export Format choices
    ArrayList exportFormatChoices = PersonUtil.getExportFormatChoices(context);

    // Get Export Format preference set for logged in user
    String exportFormatDefault = PersonUtil.getExportFormat(context);

    //set fields to disabled if value is not "Text"
    String strBlnVal = "disabled=true";

    // for each Export Format choice
    for (int i = 0; i < exportFormatChoices.size(); i++)
    {
        // get choice
        String choice = (String)exportFormatChoices.get(i);

        // translate the choice
        String choicePropKey = "emxFramework.Preferences.ExportFormat." + choice.replace(' ', '_');
        String choicePropValue = UINavigatorUtil.getI18nString(choicePropKey, "emxFrameworkStringResource", request.getHeader("Accept-Language"));

        // if translation not found then show choice.
        if (choicePropValue == null || choicePropValue.equals(choicePropKey))
        {
            choicePropValue = choice;
        }

        //this string comes from emxFramework.Preferences.ExportFormat.Choices
        String stringToCompare = "Text";

        //if the checked value is "Text" or "CSV" enable fields
       if (("CSV".equals(exportFormatDefault)) || ("Text".equals(exportFormatDefault)))
       {
        strBlnVal = "";
       }

%>
              <TR>
                <TD width='8'>
<%
        // if choice is equal to default then
        // mark it selected
        if (choice.equals(exportFormatDefault))
        {
%>
                  <!-- //XSSOK -->
                  <INPUT type="radio" name="format" id="format" value="<%=choice%>" checked onClick="setFormOptions('<%=choice%>')" />
<%
        }
        else
        {
%>
                  <!-- //XSSOK -->
                  <INPUT type="radio" name="format" id="format" value="<%=choice%>" onClick="setFormOptions('<%=choice%>')" />
<%
        }
%>
                </TD>
                <TD>
                  <!-- //XSSOK -->
                  <%=choicePropValue%>
                </TD>
              </TR>
<%
    }
%>
            </TABLE>
          </TD>
        </TR>
        <TR>
          <TD>
            &nbsp;
          </TD>
          <TD>
            &nbsp;
          </TD>
        </TR>
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.Preferences.ExportFormat.Record_Seperator</emxUtil:i18n>
          </TD>
          <TD class="inputField">
<%
          String sRecordSeparator = PersonUtil.getRecordSeparator(context);
          if((sRecordSeparator == null) || "".equals(sRecordSeparator) ||
                                            "null".equalsIgnoreCase(sRecordSeparator)) {
              sRecordSeparator = UINavigatorUtil.getI18nString(
                                        "emxFramework.Preferences.FieldSeparator.New_Line",
                                        "emxFrameworkStringResource",
                                        request.getHeader("Accept-Language"));
          }
%>
            <!-- //XSSOK -->
            <INPUT type="text" name="recordSeparator_disp" id="recordSeparator_disp" value="<%=sRecordSeparator%>" <%= strBlnVal %> disabled="" />
	    <INPUT type="text" hidden="true" name="recordSeparator" id="recordSeparator" value="<%=sRecordSeparator%>" readonly="readonly" />

          </TD>
        </TR>
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.Preferences.ExportFormat.Field_Seperator</emxUtil:i18n>
          </TD>
          <TD class="inputField">
            <!-- //XSSOK -->
            <SELECT name="fieldSeparator" id="fieldSeparator" <%= strBlnVal %>>
<%


            ArrayList fieldSeparatorChoices = (ArrayList)fieldSeparatorChoicesMap.get(exportFormatDefault);

    // Get Field Separator preference set for logged in user
    String fieldSeparatorDefault = PersonUtil.getFieldSeparator(context);

    // for each Field Separator choice
    for (int i = 0; i < fieldSeparatorChoices.size(); i++)
    {
        // get choice
        String choice = (String)fieldSeparatorChoices.get(i);

        // translate the choice
        String choicePropKey = "emxFramework.Preferences.FieldSeparator." + choice.replace(' ', '_');
        String choicePropValue = UINavigatorUtil.getI18nString(choicePropKey, "emxFrameworkStringResource", request.getHeader("Accept-Language"));

        // if translation not found then show choice.
        if (choicePropValue == null || choicePropValue.equals(choicePropKey))
        {
            choicePropValue = choice;
        }

        // if choice is equal to default then
        // mark it selected
        if (choice.equals(fieldSeparatorDefault))
        {
%>
              <!-- //XSSOK -->
              <OPTION value="<%=choice%>" selected><%=choicePropValue%>
              </OPTION>
<%
        }
        else
        {
%>
              <!-- //XSSOK -->
              <OPTION value="<%=choice%>"><%=choicePropValue%>
              </OPTION>
<%
        }
    }
%>
            </SELECT>
          </TD>
        </TR>
        <TR>
          <TD>
            &nbsp;
          </TD>
          <TD>
            &nbsp;
          </TD>
        </TR>
        <TR>
          <TD width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.Preferences.ExportFormat.Remove_Carriage_Returns</emxUtil:i18n>
          </TD>
          <TD class="inputField">
            <TABLE border="0">
<%
    // Get Remove Carriage Return choices
    ArrayList removeCarriageReturnChoices = PersonUtil.getRemoveCarriageReturnChoices(context);

    // Get Remove Carriage Return preference set for logged in user
    String removeCarriageReturnDefault = PersonUtil.getRemoveCarriageReturns(context);

    // for each Remove Carriage Return choice
    for (int i = 0; i < removeCarriageReturnChoices.size(); i++)
    {
        // get choice
        String choice = (String)removeCarriageReturnChoices.get(i);

        // translate the choice
        String choicePropKey = "emxFramework.Preferences.RemoveCarriageReturns." + choice.replace(' ', '_');
        String choicePropValue = UINavigatorUtil.getI18nString(choicePropKey, "emxFrameworkStringResource", request.getHeader("Accept-Language"));

        // if translation not found then show choice.
        if (choicePropValue == null || choicePropValue.equals(choicePropKey))
        {
            choicePropValue = choice;
        }
%>
              <TR>
                <TD width='8'>
<%
        // if choice is equal to default then
        // mark it selected
        if (choice.equals(removeCarriageReturnDefault))
        {
%>
                  <!-- //XSSOK -->
                  <INPUT type="radio" name="removeCarriageReturns" id="removeCarriageReturns" value="<%=choice%>" checked  <%= strBlnVal %> />
<%
        }
        else
        {
%>
                  <!-- //XSSOK -->
                  <INPUT type="radio" name="removeCarriageReturns" id="removeCarriageReturns" value="<%=choice%>"  <%= strBlnVal %> />
<%
        }
%>
                </TD>
                <TD>
                  <!-- //XSSOK -->
                  <%=choicePropValue%>
                </TD>
              </TR>
<%
    }
    }
    catch (Exception ex)
    {
        ContextUtil.abortTransaction(context);

        if(ex.toString()!=null && (ex.toString().trim()).length()>0)
        {
            emxNavErrorObject.addMessage("emxPrefConversions:" + ex.toString().trim());
        }
    }
    finally
    {
        ContextUtil.commitTransaction(context);
    }
%>
            </TABLE>
          </TD>
        </TR>
      </TABLE>
    </FORM>
  </BODY>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</HTML>





