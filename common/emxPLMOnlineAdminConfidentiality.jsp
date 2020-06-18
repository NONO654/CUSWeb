<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file= "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<html>
  <head> 
     <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<%  String Cancel = myNLS.getMessage("Cancel");
    String EditRows = myNLS.getMessage("EditRows");
    String AddRows = myNLS.getMessage("AddRows");
    String Save = myNLS.getMessage("Save");
    String Delete = myNLS.getMessage("Delete");
    String SecurityLevel = myNLS.getMessage("SecurityLevel");
    String AliasName = myNLS.getMessage("AliasName");

    String ERR_SecurityLevel = getNLSMessageWithParameter("ERR_CannotBeEmpty","SecurityLevel");
    String ERR_Alias = getNLSMessageWithParameter("ERR_CannotBeEmpty","AliasName"); 
    String CONF_CANCELMOD = getNLSMessageWithParameter("CONF_Message","CancelModifications"); 
    String CONF_DELETEROW = getNLSMessageWithParameter("CONF_Message","DeleteRow"); 
    String ERR_EmptyBlankCaracter = getNLSMessageWithParameter("ERR_IntegerAndNoBlank","SecurityLevel");
    String ERR_AlreadyExistSecLevel = myNLS.getMessage("ERR_AlreadyExist");
    String ERR_AliasAndNumber = getNLSMessageWithParameter("ERR_NoNumber","AliasName");

%>
<script>
        xmlreqs = new Array();
        var confidentialities="";

        function formatResponse()
        {
            var xmlhttp = xmlreqs[0];

            xmlhttp.onreadystatechange=function()
            {
               if(xmlhttp.readyState==4)
                {
                    var tables = document.getElementById("tableConfi");
                    confidentialities = xmlhttp.responseXML.getElementsByTagName("Confidentiality");
                  
                    for (var i = 0 ; i < confidentialities.length; i++){
                        var newConfidentialityRow = tables.insertRow(-1);
                        //Adding The delete Cell
                        var cellInnerHTML="<a href=\"javascript:deleteAllRow('"+confidentialities[i].getElementsByTagName("PLMID")[0].firstChild.data+"')\"><%=Delete%></a>";
                        addCellInARow(newConfidentialityRow, "link", 0,cellInnerHTML);
                        //Adding The Confidentiality Level Cell
                        addCellInARow(newConfidentialityRow, "Confidentiality", 1,confidentialities[i].getElementsByTagName("Value")[0].firstChild.data);
                        //Adding The Alias Cell
                        addCellInARow(newConfidentialityRow, "Confidentiality", 2,confidentialities[i].getElementsByTagName("Name")[0].firstChild.data);
                        //Adding The Description Cell
                        var Description ="";
                        if(confidentialities[i].getElementsByTagName("Description")[0].firstChild != null){
                            Description=confidentialities[i].getElementsByTagName("Description")[0].firstChild.data;
                        }
                        var newcell = addCellInARow(newConfidentialityRow, "Confidentiality", 3);
						newcell.appendChild(document.createTextNode(Description));
                    }
                }
            }
         }

        function initConfidentiality(){
            xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Confidentiality",formatResponse,0);
         }


        function addRow(){
            var newRow = document.getElementById('tableConfi').insertRow(-1);
            newRow.insertCell(0);
            addCellInARowWithTextInput(newRow, "Confidentiality", 1,"","Add","ElementForResources",15,15);
            addCellInARowWithTextInput(newRow, "Confidentiality", 2,"","","ElementForResources",50,100);
            addCellInARowWithTextInput(newRow, "Confidentiality", 3,"","","ElementForResources",80,100);
        }

    
        function editRow(){
            var size = document.getElementById('tableConfi').rows.length;
        
            for(var i = 1 ; i < size ; i++){
                var rowi = document.getElementById('tableConfi').rows[i];
                var nameRow =rowi.cells[1].innerHTML.htmlDecode();
                var nameRow1 =rowi.cells[2].innerHTML.htmlDecode();
                var nameRow2 =rowi.cells[3].innerHTML.htmlDecode();

                if ((nameRow.indexOf("input") == -1)  && (nameRow.indexOf("INPUT") == -1)){
                    var e = document.createElement('input');
                    e.type = 'text';
                    e.value = nameRow;
                    e.id = 'edit';
                    e.size = 15;
                    e.width = 100;
                    e.style.align = "middle";
                    e.style.border ="";
                    rowi.cells[1].innerHTML="";
                    e.name = "edit" ;
                    rowi.cells[1].appendChild(e);
                
                    var e2 = document.createElement('input');
                    e2.type = 'text';
                    e2.value = nameRow1;
                    e2.id = 'input';
                    e2.size = 50;
                    e2.width = 50;
                    e2.maxLength = 100;
                    e2.style.align = "middle";
                    e2.style.border ="";
                    rowi.cells[2].innerHTML="";
                    rowi.cells[2].appendChild(e2);

                    var e3 = document.createElement('input');
                    e3.type = 'text';
                    e3.value = nameRow2;
                    e3.id = 'input';
                    e3.size = 80;
                    e3.width = 80;
                    e3.maxLength = 100;
                    e3.style.align = "middle";
                    e3.style.border ="";
                    rowi.cells[3].innerHTML="";
                    rowi.cells[3].appendChild(e3);
                }
            }
      }

  
      function save(){
        var link = "emxPLMOnlineAdminManageConfidentiality.jsp?method=editAdd";
        var levels=",";
        var descs ="," ;
        var go ="true";
        var size = document.getElementById('tableConfi').rows.length;
        var sizeConfidentialities =confidentialities.length;
        var editValues="";
        var addValues="";
        for (var j = 1 ; j <=sizeConfidentialities ; j++ ){
            if ( ((document.getElementById('tableConfi').rows[j].cells[1].innerHTML).indexOf("input") != -1) || ((document.getElementById('tableConfi').rows[j].cells[1].innerHTML).indexOf("INPUT") != -1) ){
                var id = confidentialities[j-1].getElementsByTagName("PLMID")[0].firstChild.data;
                var alias = document.getElementById('tableConfi').rows[j].cells[2].firstChild.value;
                var description = document.getElementById('tableConfi').rows[j].cells[3].firstChild.value;
                
                var level = document.getElementById('tableConfi').rows[j].cells[1].firstChild.value;
                if((level == "" )&& (alias != "") ){alert("<%=ERR_SecurityLevel%>");go ="false";}
                if(!IsNumberString(level)){ alert("<%=ERR_EmptyBlankCaracter%>");go ="false";}
                if(levels.indexOf(","+level+",") != -1 && level!=""){alert("\""+level+"\"" + " " +"<%=ERR_AlreadyExistSecLevel%>");go ="false";}
                if(descs.indexOf(","+alias.toLowerCase()+",") != -1 && alias!=""){alert("\""+alias+"\"" + " " +"<%=ERR_AlreadyExistSecLevel%>");go ="false";}
                if( (alias!="") && (level!="") && !IsFrenchAlphaString(alias)){alert("<%=ERR_AliasAndNumber%>");go ="false";}
		if( (alias == "") && (level!="") ){alert("<%=ERR_Alias%>");go ="false";}
                var row = id+";;"+level+";;"+encodeURIComponent(alias)+";;"+encodeURIComponent(description);
                editValues = editValues+row+",SEP,";
            }else{
                var level = document.getElementById('tableConfi').rows[j].cells[1].innerHTML.htmlDecode();
                var alias = document.getElementById('tableConfi').rows[j].cells[2].innerHTML.htmlDecode();
                var description = document.getElementById('tableConfi').rows[j].cells[3].innerHTML.htmlDecode();

            }
            levels = levels+","+level+",";
            descs = descs + ","+alias.toLowerCase()+",";
        }
 
        if(editValues != ""){
            link = link + "&edit="+editValues;
        }
      
        if (size > sizeConfidentialities+1 ){
	    var descsAdd="";
            for (var i = sizeConfidentialities+1 ; i < size ; i++){
                var level = document.getElementById('tableConfi').rows[i].cells[1].firstChild.value;
                var alias = document.getElementById('tableConfi').rows[i].cells[2].firstChild.value;
                var description = document.getElementById('tableConfi').rows[j].cells[3].firstChild.value;

                if((level == "" )&& (alias != "") ){alert("<%=ERR_SecurityLevel%>");go ="false";}
                else{
                   if(!IsNumberString(level) && level!=""){ alert("<%=ERR_EmptyBlankCaracter%>");go ="false";
                   }else{
                        if(levels.indexOf(","+level+",") != -1 && level!=""){
                            alert("\""+level+"\"" + " " +"<%=ERR_AlreadyExistSecLevel%>");
                            go ="false";
                        }else{
                             if((alias == "" )&& (level != "") ){alert("<%=ERR_Alias%>");go ="false";}
					else if( (alias!="") && (level!="") && (alias.indexOf(" ") != -1) ){alert("Alias cannot contain a blank character.");go ="false";}
                                        else if( (alias!="") && (level!="") && !IsFrenchAlphaString(alias)){alert("<%=ERR_AliasAndNumber%>");go ="false";}

                             else {
                                 if(descs.toLowerCase().indexOf(","+alias.toLowerCase()+",") != -1 && alias!=""){alert("\""+alias+"\"" + " " +"<%=ERR_AlreadyExistSecLevel%>");go ="false";}
                                 if(descsAdd.toLowerCase().indexOf(","+alias.toLowerCase()+",") != -1 && alias!=""){alert("\""+alias+"\"" + " " +"<%=ERR_AlreadyExistSecLevel%>");go ="false";}
                                 descsAdd=descsAdd+","+alias.toLowerCase()+",";
                            }
                        }
                   }
                }
                var row = level+";;"+encodeURIComponent(alias)+";;"+encodeURIComponent(description);
                addValues = addValues+row+",SEP,";
            }

            if(addValues != ""){
                link = link + "&add="+addValues;
            }
      }
      if(go == 'true'){
          window.location.href = link;
      }
    }
    
    function deleteAllRow(a2){  
        var res = confirm("<%=CONF_DELETEROW%>");
        if(res == true){
            var link = "emxPLMOnlineAdminManageConfidentiality.jsp?method=delete&values="+a2;
            window.location.href = link; 
        }
    }

    function cancel(){
        var res = confirm("<%=CONF_CANCELMOD%>");
        if(res == true){
            var link = "emxPLMOnlineAdminManageConfidentiality.jsp?method=cancel";
            window.location.href = link;
        }
    }
  </script>
  </head>
  
    <%if (AdminUtilities.isCentralAdmin(mainContext)){%>
    <body onload="javascript:initConfidentiality()">
    <form action="" name="submitForm" method="POST">
        <table width="80%" align="center" style="height:90%;" >
            <tr style="height:70%" valign="top">
                <td>
                    <table  align="center" id="tableConfi" border="1px" style="border-color:white">
                        <tr valign="middle" align="center" style="width:80%">
                            <td></td>
                            <td width="10%" class="headerConf"  > <%=SecurityLevel%>
                            </td>
                            <td width="45%" class="headerConf"  ><%=AliasName%></td>
                            <td width="45%" class="headerConf"  ><%=myNLS.getMessage("Description")%></td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </form>
  </body>
  <script>addFooter("javascript:editRow()","images/buttonDialogApply.gif","<%=EditRows%>","<%=EditRows%>","javascript:addRow()","images/buttonDialogAdd.gif","<%=AddRows%>","<%=AddRows%>","javascript:save()","images/buttonDialogDone.gif","<%=Save%>","<%=Save%>",null,"javascript:cancel()","images/buttonDialogCancel.gif","<%=Cancel%>","<%=Cancel%>")</script>
<%}else{
      String NonAppropriateContextAdmin = getNLS("NonAppropriateContextAdmin");%>
<script>addTransparentLoading("<%=NonAppropriateContextAdmin%>","display");</script>
  <%}%>
</html>

