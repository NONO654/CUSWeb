<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<html>
  <head> 
     <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<%  String Cancel = myNLS.getMessage("Cancel");
    String EditRows = myNLS.getMessage("EditRows");
    String AddRows = myNLS.getMessage("AddRows");
    String Save = myNLS.getMessage("Save");
    String FamilyName = myNLS.getMessage("FamilyName");

    String ERR_Alias = getNLSMessageWithParameter("ERR_CannotBeEmpty","Family");
    String CONF_CANCELMOD = getNLSMessageWithParameter("CONF_Message","CancelModifications"); 
    String CONF_DELETEROW = getNLSMessageWithParameter("CONF_Message","DeleteRow"); 
    String ERR_AlreadyExistSecLevel = myNLS.getMessage("ERR_AlreadyExist");
    String ERR_AliasAndNumber = getNLSMessageWithParameter("ERR_NoNumber","AliasName");

%>
<script>
        xmlreqs = new Array();
        var families="";

        function formatResponse()
        {
            var xmlhttp = xmlreqs[0];

            xmlhttp.onreadystatechange=function()
            {
               if(xmlhttp.readyState==4)
                {
                    families = xmlhttp.responseXML.getElementsByTagName("Family");
					var famitab = [];
                    for (var i = 0 ; i < families.length; i++){
						var name = families[i].getElementsByTagName("Name")[0].firstChild.data;
						if(families[i].getElementsByTagName("Description")[0].firstChild != null){
							name = name+"@@"+families[i].getElementsByTagName("Description")[0].firstChild.data;
						}
						famitab.push(name);
					}
					famitab.sort();
                    var tables = document.getElementById("tableConfi");
					for (var j = 0 ; j < famitab.length; j++){
                        var newFamilyRow = tables.insertRow(-1);
                        var newCell = addCellInARow(newFamilyRow, "Confidentiality", 0);
						var items = famitab[j].split("@@");
						newCell.appendChild(document.createTextNode(items[0]));
                        //Adding The Description Cell
                        if(items.length>1){
                            newCell = addCellInARow(newFamilyRow, "Confidentiality",1);
							newCell.appendChild(document.createTextNode(items[1]));
                        }else{
                            addCellInARow(newFamilyRow, "Confidentiality",1,"");
                        }
                   }
                }
            }
         }


        function initFamily(){
            xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Family&Solution=VPM",formatResponse,0);
         }


        function addRow(){
            var newRow = document.getElementById('tableConfi').insertRow(-1);
            addCellInARowWithTextInput(newRow, "Confidentiality", 0,"","Add","ElementForResources",15,15);
            addCellInARowWithTextInput(newRow, "Confidentiality", 1,"","","ElementForResources",50,100);
         }

         function editRow(){
            var size = document.getElementById('tableConfi').rows.length;

            for(var i = 1 ; i < size ; i++){
                var rowi = document.getElementById('tableConfi').rows[i];
                var nameRow =rowi.cells[0].innerHTML.htmlDecode();
                var nameRow1 =rowi.cells[1].innerHTML.htmlDecode();

                if ((nameRow.indexOf("input") == -1)  && (nameRow.indexOf("INPUT") == -1)){
                 
                    var e2 = document.createElement('input');
                    e2.type = 'text';
                    e2.value = nameRow1;
                    e2.id = 'input';
                    e2.size = 50;
                    e2.width = 50;
                    e2.maxLength = 100;
                    e2.style.align = "middle";
                    e2.style.border ="";
                    rowi.cells[1].innerHTML="";
                    rowi.cells[1].appendChild(e2);
                }
            }
        }


      function save(){
        var link = "emxPLMOnlineAdminManageFamily.jsp?method=editAdd";
        var descs ="," ;
        var go ="true";
        var size = document.getElementById('tableConfi').rows.length;
        var sizeConfidentialities =families.length;
        var editValues="";
        var addValues="";
        for (var j = 1 ; j <=sizeConfidentialities ; j++ ){
            if ( ((document.getElementById('tableConfi').rows[j].cells[1].innerHTML).indexOf("input") != -1) || ((document.getElementById('tableConfi').rows[j].cells[0].innerHTML).indexOf("INPUT") != -1) ){
                var id = families[j-1].getElementsByTagName("PLMID")[0].firstChild.data;

                var alias = document.getElementById('tableConfi').rows[j].cells[0].innerHTML.htmlDecode();
                var description = document.getElementById('tableConfi').rows[j].cells[1].firstChild.value;

                if(descs.indexOf(","+alias.toLowerCase()+",") != -1 && alias!=""){alert("\""+alias+"\"" + " " +"<%=ERR_AlreadyExistSecLevel%>");go ="false";}
                var row = id+";;"+encodeURIComponent(alias)+";;"+encodeURIComponent(description);
                editValues = editValues+row+",SEP,";
            }else{
                var alias = document.getElementById('tableConfi').rows[j].cells[0].innerHTML.htmlDecode();
                var description = document.getElementById('tableConfi').rows[j].cells[1].innerHTML.htmlDecode();

            }
            descs = descs + ","+alias.toLowerCase()+",";
        }
 
        if(editValues != ""){
            link = link + "&edit="+editValues;
        }

      
        if (size > sizeConfidentialities+1 ){
	    var descsAdd="";
            for (var i = sizeConfidentialities+1 ; i < size ; i++){
                var alias = document.getElementById('tableConfi').rows[i].cells[0].firstChild.value;
                var description = document.getElementById('tableConfi').rows[i].cells[1].firstChild.value;

                if((alias == "" )){alert("<%=ERR_Alias%>");go ="false";}
		else if( (alias!="") && !IsFrenchAlphaString(alias)){alert("<%=ERR_AliasAndNumber%>");go ="false";}
                else {
                    if(descs.toLowerCase().indexOf(","+alias.toLowerCase()+",") != -1 && alias!=""){alert("\""+alias+"\"" + " " +"<%=ERR_AlreadyExistSecLevel%>");go ="false";}
                    if(descsAdd.toLowerCase().indexOf(","+alias.toLowerCase()+",") != -1 && alias!=""){alert("\""+alias+"\"" + " " +"<%=ERR_AlreadyExistSecLevel%>");go ="false";}
                    descsAdd=descsAdd+","+alias.toLowerCase()+",";
                }
               
            var row = encodeURIComponent(alias)+";;"+encodeURIComponent(description);
            addValues = addValues+row+",SEP,";
        }
        }
        if(addValues != ""){
            link = link + "&add="+addValues;
        }


      if(go == 'true'){
          window.location.href = link;
      }
    }
    

    function cancel(){
        var res = confirm("<%=CONF_CANCELMOD%>");
        if(res == true){
            var link = "emxPLMOnlineAdminManageFamily.jsp?method=cancel";
            window.location.href = link;
        }
    }
  </script>
  </head>

    <body onload="javascript:initFamily()">
    <form action="" name="submitForm" method="POST">
				<div style="width:100%;height:500px;overflow-y:auto;">
                    <table width="80%" id="tableConfi" align="center" border="1px" style="border-color:white;overflow:hidden;">
						<tr valign="middle" align="center" style="width:100%">
                            <td width="45%" class="headerConf"  ><%=FamilyName%></td>
                            <td width="45%" class="headerConf"  ><%=getNLS("Description")%></td>
                        </tr>
                    </table>
				</div>
    </form>
  </body>
  <script>addFooter("javascript:editRow()","images/buttonDialogApply.gif","<%=EditRows%>","<%=EditRows%>","javascript:addRow()","images/buttonDialogAdd.gif","<%=AddRows%>","<%=AddRows%>","javascript:save()","images/buttonDialogDone.gif","<%=Save%>","<%=Save%>",null,"javascript:cancel()","images/buttonDialogCancel.gif","<%=Cancel%>","<%=Cancel%>")</script>
</html>

