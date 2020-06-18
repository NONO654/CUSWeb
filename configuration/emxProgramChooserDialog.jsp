

<%--  emxProgramChooserDialog.jsp  -

   Performs the action of displaying the Program Names

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: /ENOVariantConfigurationBase/CNext/webroot/configuration/emxProgramChooserDialog.jsp 1.3.2.1.1.1 Wed Oct 29 22:27:16 2008 GMT przemek Experimental$";
--%>


<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%-- Common Includes --%>

<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>


<%
  ProgramList pl = Program.getPrograms(context);
%>

<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css" />
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css" />
<link rel="stylesheet" href="emxUIProductLine.css" type="text/css" />


<script language="javascript">
  function submit()
    {
	  //XSSOK
      prgNames = new Array(<%= pl.size() %>);
      <% for(int k=0;k<pl.size();k++) { %>
      //XSSOK
       prgNames[<%= k %>] = "<%= pl.elementAt(k).toString() %>";
      <% } %>

      var i=0;
      document.ProgramChooser.hdnFormName.value= "<%= XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"formName")) %>";
      document.ProgramChooser.hdnFieldName.value= "<%= XSSUtil.encodeForJavaScript(context,emxGetParameter(request,"fieldName")) %>";
      for(i=0;i<document.ProgramChooser.lstRadio.length;i++)
        {
          if(document.ProgramChooser.lstRadio[i].checked == true)
           {
            document.ProgramChooser.hdnProgramName.value= prgNames[i];
           }
        }
      document.ProgramChooser.submit();
     }


   function closeWindow()
    {
      parent.window.closeWindow()
    }


</script>

<script language="JavaScript" type="text/javascript">

  function doCheck()
    {
      var objForm = document.forms[0];
      var chkList = objForm.chkList;
      var reChkName = /chkItem/gi;

      for (var i=0; i < objForm.elements.length; i++)
        if (objForm.elements[i].name.indexOf('chkItem') > -1)
          objForm.elements[i].checked = chkList.checked;
    }


  function updateCheck()
    {
      var objForm = document.forms[0];
      var chkList = objForm.chkList;
      chkList.checked = false;
    }


  function updateRowColors()
    {
      var objTable = document.getElementById("tblMain");
      var j=0;

      for (var i=0; i < objTable.tBodies[0].rows.length; i++)
        if (objTable.tBodies[0].rows[i].style.display != "none") {
          objTable.tBodies[0].rows[i].className = (j++ % 2 == 0 ? "odd" : "even");
        }

    }


  function clickPlusMinus(iIndex, objImage)
    {
      var objTable = document.getElementById("tblMain");
      var objRow = objTable.tBodies[0].rows[iIndex-1];

      var iIndent = isNaN(parseInt(objRow.getAttribute("emx:indent"))) ?  0 : parseInt(objRow.getAttribute("emx:indent"));
      if (objImage.alt == "More")
        {
          var i=iIndex;
          while (i < objTable.tBodies[0].rows.length && parseInt(objTable.tBodies[0].rows[i].getAttribute("emx:indent")) == iIndent + 1 )
            {
              objTable.tBodies[0].rows[i].style.display = "";
              i++;
            }
        }
      else
        {
          var i=iIndex;
          while ( i < objTable.tBodies[0].rows.length && parseInt(objTable.tBodies[0].rows[i].getAttribute("emx:indent")) == iIndent + 1 )
            {
              objTable.tBodies[0].rows[i].style.display = "none";
              i++;
            }
        }
      updateRowColors();
    }

</script>

    <form name="ProgramChooser" action="emxProgramChooserIntermediate.jsp">
      <input type="hidden" name="hdnFormName"></input>
      <input type="hidden" name="hdnFieldName"></input>
      <input type="hidden" name="hdnProgramName"></input>
      <table border="0" cellpadding="3" width="100%" id="tblMain" cellspacing="2">
        <thead>
          <tr>
            <th width="5%" style="text-align:center">&nbsp;</th>
            <th>
              <emxUtil:i18n localize="i18nId"> emxProduct.Heading.ProgramChooserListPage
              </emxUtil:i18n></th>
          </tr>
        </thead>
        <tbody>

        <tr emx:indent="0" style="" class="odd" xmlns:emx="http://www.matrixone.com/">
        <td style="text-align: center; "><input type="radio" name="lstRadio" checked /></td>
        <td style=""><%= XSSUtil.encodeForHTML(context,pl.elementAt(0).toString()) %></td>
        </tr>

        <% for(int j=1;j<pl.size()-2;j+=2) { %>
                 <tr emx:indent="0" style="" class="even" xmlns:emx="http://www.matrixone.com/">
                 <td style="text-align: center; "><input type="radio" name="lstRadio" /></td>
                 <td style=""><%= XSSUtil.encodeForHTML(context,pl.elementAt(j).toString()) %></td>
                 </tr>

                <tr emx:indent="0" style="" class="odd" xmlns:emx="http://www.matrixone.com/">
                <td style="text-align: center; "><input type="radio" name="lstRadio" /></td>
                 <td style=""><%= XSSUtil.encodeForHTML(context,pl.elementAt(j+1).toString()) %></td>
                </tr>
       <%  } %>
        </tbody>
      </table>
    </form>


<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

