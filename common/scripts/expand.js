function getName(id,email,firstName,lastName,street,city,state,postalCode,country,phone,ctx,orgList,orgID){
           document.getElementById("treeFrame").style.display = "block";
            document.getElementById("treeFrame").src = "emxPLMOnlineAdminCreatePerson.jsp?source=admin&plm_ExternalID="+encodeURIComponent(id)+"&v_email="+encodeURIComponent(email)+"&v_first_name="+encodeURIComponent(firstName)+"&v_last_name="+encodeURIComponent(lastName)+"&street="+encodeURIComponent(street)+"&city="+encodeURIComponent(city)+"&state="+encodeURIComponent(state)+"&postalCode="+encodeURIComponent(postalCode)+"&country="+encodeURIComponent(country)+"&phone="+encodeURIComponent(phone)+"&ctx="+encodeURIComponent(ctx)+"&list_Org="+encodeURIComponent(orgList)+"&OrgId="+encodeURIComponent(orgID);
            document.getElementById("treeFrame").height = "250px";
}

function addCloseTag(){
	document.write('</table></td></tr></table></td></tr>');
}

function addTdM(value,name){
	document.write('<tr><td class="title" width="50%">'+value+'<b style="color:red;">*</b></td>');
	document.write('<td><input type="text" size="20" id='+name+' name='+name+' value=""></td></tr>');
}

function addTr(value1,name1,value2,name2,func2Call){
       document.write('<tr><td class="title" width="25%" >'+value1+'</td>');
        document.write('<td><input onkeypress="return enterEvent(event,'+func2Call+')" type="text" size="20" id='+name1+' name='+name1+' value=""></td>');
        document.write('<td  class="title">'+value2+'</td><td><input type="text" size="20" id='+name2+' name='+name2+' value=""></td></tr>');
}

function addTrSelect(value1,name1,func2Call,mandatory){
        if(mandatory == "Mand"){
           document.write('<tr><td class="title">'+value1+'<b style="color:red;">*</b></td>');
        }else{
           document.write('<tr><td class="title">'+value1+'</td>'); 
        }
        document.write('<td><select multiple onkeypress="return enterEvent(event,'+func2Call+')"  size="10" id='+name1+' name='+name1+' ></select>');
        document.write('</td></tr>');
}



function addTd(value,name,func2Call){
	document.write('<tr><td class="title" width="50%">'+value+'</td>');
	document.write('<td><input  onkeypress="return enterEvent(event,'+func2Call+')" type="text" size="20" name='+name+' value="" id='+name+'></td></tr>');
}


function addTdRE(value,name,val,func2Call){
	document.write('<tr><td class="title" width="50%">'+value+'</td>');
	document.write('<td><input onkeypress="return enterEvent(event,'+func2Call+')" type="text" size="20" name='+name+' value='+val+' id='+name+'></td></tr>');
}

function addActionButton(name,func2Call){
	document.write('<tr><td align="right" valign="bottom"><img src="images/buttonSearchNext.gif" onclick="javascript:'+func2Call+';" style="cursor:pointer"><a href="javascript:'+func2Call+';" class="link">'+name+'</a></td></tr>');
}

function addTdR(value,name,recup){
	document.write('<tr><td class="title" width="50%">'+value+'</td>');
	document.write('<td><input type="text" size="20" name='+name+' value='+recup+' id='+name+' disabled></td></tr>');
}

function addTable(image,title,nb){
	document.write('<tr><td><table width="100%"><tr bgcolor="#659ac2" align="left"><td class="pic" style="border:0" ><img src="images/'+image+'"></td>');
	document.write('<td class="header">'+title+'</td><td align="right"><img src="images/xpcollapse1_s.gif" onclick="clicMenu(\''+nb+'\')" id="im'+nb+'" style="cursor:pointer" ></td></tr>');
    document.write('<tr><td class="pic" style="border:0"></td><td id="menu'+nb+'"class="menu" colspan="1" style="display:block"><table width="100%" >');
}
 

 function enterEvent(event,func2Call) {
       if (event && event.which == 13)
           func2Call();
       else if (window.event && window.event.keyCode == 13)
           func2Call();
       else
    return true;}

/*
 *Verify that a string is a mail : XXXxxx@yyy.zzzz
 * @emailStr : String to verify
 * @return   : true if emailStr is a real mail false otherwise
 */
function IsEMail(emailStr)
{
    var validDomain=false;
    if (emailStr == ""){validDomain=true}
    else{
        var AtPos = emailStr.lastIndexOf("@");
	var DotPos= emailStr.lastIndexOf(".");
	if((AtPos>0)&&(DotPos>0)&&(AtPos<DotPos))
	{
            validDomain=true;
	}
    }
    return(validDomain);
}

/*
 * Verify that a string contains only A to Z letters (not case sensitive)
 * @NumStr : String to verify
 * @return   : true if NumStr real A-Z string false otherwise
*/
function IsAlphaString(NumStr)
{
    var regEx=/^[A-Za-z]+[\s]*[A-Za-z]+$/;
    var ret=false;
    if (regEx.test(NumStr)) ret=true;
    return ret;
}

/*
 * Verify that a string contains only A to Z letters or frensh letters (é è à ...)
 * @NumStr : String to verify
 * @return   : true if NumStr real A-Zeèà string false otherwise
*/
function IsFrenchAlphaString(NumStr)
{
    var regEx=/^[A-Za-zéèà]+[\s]*[A-Za-zéèà]+$/;
    var ret=false;
    if (regEx.test(NumStr)) ret=true;
    return ret;
}


function IsNumberString(NumStr)
{
    var regEx=/^[0-9]+$/;
    var ret=false;
    if (regEx.test(NumStr)) ret=true;
        return ret;
}

function IsPhoneNumber(NumStr)
         {
                var regEx=/^[+]?[0-9]+([0-9]+[\s-._]?)*[0-9]+$/;
                var ret=false;
                if (regEx.test(NumStr)) ret=true;
                return ret;
        }
                
           
   function reInit(){
            var table = document.getElementsByTagName('td'); 
            
            for ( var i = 0; i < table.length; i++ ) 
            { 
                 // on r�cup�re toutes les cellules dynamiques 
                if ( (table[i].className == 'create') || (table[i].className == 'exist')) 
                { 
                    table[i].className='basicColor';
                 }
           }   
        }
        
        
 //@contextToSPlit : all context of the database separated by a ","
        function appel(contextToSplit){
            reInit();
           //@project is the project name to use
	    var project = document.submitForm.elements['projectSelect'].options[ document.submitForm.elements['projectSelect'].selectedIndex].innerHTML;
            //@contextList is the array of contexts.
            var contextList = contextToSplit.split(",");
	    var index = document.submitForm.elements['projectSelect'].selectedIndex;
            //if a project was chosen
            if (index != -1){
              //treat the context list to see which Security contexts already exist in the database
              for (var i=0; i<contextList.length; i++) {
                     
          

                var projectCtx = contextList[i].substring(contextList[i].lastIndexOf(".")+1,contextList[i].length);
                   
                if( projectCtx == project){
				
                    var roleCtx = contextList[i].substring(0,contextList[i].indexOf("."));
                  
                    var org = contextList[i].substring(contextList[i].indexOf(".")+1,contextList[i].lastIndexOf("."));
                    var resFinal = roleCtx+ "."+org;
                    var idTab = document.getElementById(resFinal);
                    if (idTab == null) idTab="null";
                    
                    if ( idTab.toString() != "null"){
                       
                        document.getElementById(resFinal).className="exist";
                    }
                }
            }

            }
           
            else{
                alert("You have to choose a project");
            }
        }

         function verif(){
           var project =  document.submitForm.elements['projectSelect'].selectedIndex;
            if (project != -1){
              if (this.className =="basicColor" ){
                this.className="create";
             }
             else{ if ((this.className) =="create" ){
              this.className="basicColor" ;
             }
             }
             }
             else{alert("You have to choose a project");}
         }
         
         
         
         function getContextToCreate(){
			DisplayLoading();
            var table = document.getElementsByTagName('td'); 
            var context2Create = "";
            
            var index =  document.submitForm.elements['projectSelect'].selectedIndex;
            
             if (index != -1){
           
            var project = document.submitForm.elements['projectSelect'].options[ document.submitForm.elements['projectSelect'].selectedIndex].text;
          
            
                for ( var i = 0; i < table.length; i++ ) 
                { 
                
                     // on r�cup�re toutes les cellules dynamiques 
                    if ( (table[i].className == 'create') ) 
                    { 
                        context2Create= context2Create.concat(encodeURIComponent(table[i].getAttribute('Id')));
                        context2Create= context2Create.concat(",");
                    }   
                }
				if (context2Create == "") {
				alert("You have to check at least one role/project box");
				HideLoading();
				}
				else {
                document.submitForm.action = "emxPLMOnlineAdminCreateContextDB.jsp?roleProject="+context2Create+"&organization="+encodeURIComponent(project);
                document.submitForm.submit();
				}
            }
            else{alert("You have to choose an organization");
            }
         }

		 
  function displayChoice(listFinal){
                 var filter = document.getElementById('nameFilter').options[document.getElementById('nameFilter').options.selectedIndex].text;
                 var listFilter = listFinal.split(",");
                 var nomrole ="";
                 
                 if (filter == "Role"){
               
                    document.getElementById('valueFilter').options.length=0;
                    var j = 0;
                   for (var i = 1 ; i < listFilter.length ; i ++ ){
                        var role = listFilter[i].split(".");
                        if (nomrole.indexOf(role[0]) == -1){                          
                            document.getElementById('valueFilter').options[j] = new Option(role[0], role[0]);
                            j++;
                        }
                        nomrole=nomrole+role[0];
                    }  
                 }
                 else if (filter == "Organization"){
                    document.getElementById('valueFilter').options.length=0;
                    var j = 0;
                   for (var i = 1 ; i < listFilter.length ; i ++ ){
                        
                        var withoutCtx = listFilter[i].split("::");
                        var role = listFilter[i].split(".");
                        if (nomrole.indexOf(role[1]) == -1){                          
                            document.getElementById('valueFilter').options[j] = new Option(role[1], role[1]);
                            j++;
                        }
                        nomrole=nomrole+role[1];
                    }  
                 }
                 else if (filter == "Project"){
                    document.getElementById('valueFilter').options.length=0;
                    var j = 0;
                   for (var i = 1 ; i < listFilter.length ; i ++ ){
                        var role = listFilter[i].split(".");
                        if (nomrole.indexOf(role[2]) == -1){                          
                            document.getElementById('valueFilter').options[j] = new Option(role[2], role[2]);
                            j++;
                        }
                        nomrole=nomrole+role[2];
                    }  
                 }
				 else {
                    document.getElementById('valueFilter').options.length=0;
                 }

            }


 function filterBy(liste){
                //Filter type name : Role, Organization, Project, No Filter
                var nom = document.getElementById('nameFilter').options[document.getElementById('nameFilter').options.selectedIndex].text;
                var tabCtx = liste.split(",");
                var j = 0;
                
                if (nom == "Role"||nom == "Organization"||nom == "Project"){
                    var valeur = document.getElementById('valueFilter').options[document.getElementById('valueFilter').options.selectedIndex].text;
                     document.getElementById('listCtxAdmin').options.length = 0;
                    for (var i = 0 ; i < tabCtx.length ; i++){
                        if (tabCtx[i].indexOf(valeur) != -1){
                            document.getElementById('listCtxAdmin').options[j] = new Option(tabCtx[i],tabCtx[i]);
                            j++;  
                        }    
                    }
                        document.getElementById('listCtxAdmin').size = j;
                }else{
                    document.getElementById('listCtxAdmin').options.length = 0;
                    document.getElementById('valueFilter').options.length = 0;
                    
                    for (var i = 1 ; i < tabCtx.length  ; i++){
                         document.getElementById('listCtxAdmin').size = tabCtx.length-1;
                         document.getElementById('listCtxAdmin').options[j] = new Option(tabCtx[i],tabCtx[i]);
                         j++;
                    }
               }             
            }

			
			
	     function getTop(number){
                var plmID= window.frames['middleFrame'].document.getElementById('PLM_ExternalID').firstChild.data;
                var firstName= window.frames['middleFrame'].document.getElementById('V_first_name').value;
                var lastName= window.frames['middleFrame'].document.getElementById('V_last_name').value;
                var phone= window.frames['middleFrame'].document.getElementById('V_phone').value;    
                var mail= window.frames['middleFrame'].document.getElementById('V_email').value;
                var street= window.frames['middleFrame'].document.getElementById('Street').value;
                var city= window.frames['middleFrame'].document.getElementById('City').value;
                var state= window.frames['middleFrame'].document.getElementById('State').value;
                var postalCode= window.frames['middleFrame'].document.getElementById('PostalCode').value;
                var country= window.frames['middleFrame'].document.getElementById('Country').value;
                var Accreditation= window.frames['middleFrame'].document.getElementById('Accreditation').value;
				var Work_Phone_number= window.frames['middleFrame'].document.getElementById('Work_Phone_Number').value;

                var Alias= window.frames['middleFrame'].document.getElementById('Alias').value;
                if (Alias == null ){
                    Alias= window.frames['middleFrame'].document.getElementById('Alias').innerHTML;
                }
               
	           if(!IsEMail(mail)){alert("Email address is not valid");}  
                   else if(!IsPhoneNumber(phone) && (phone.length >0) ){alert("Your phone number is not valid");}
                   else if(!IsPhoneNumber(Work_Phone_number) && (Work_Phone_number.length >0) ){alert("Your office phone number is not valid");}
                  else{
	               if(number == 0){
                     var target = "emxPLMOnlineAdminUpdatePerson.jsp?PLM_ExternalID="+encodeURIComponent(plmID)+"&V_first_name="+encodeURIComponent(firstName)+"&V_last_name="+encodeURIComponent(lastName)+"&V_phone="+encodeURIComponent(phone)+"&Work_Phone_Number="+encodeURIComponent(Work_Phone_number)+"&V_email="+encodeURIComponent(mail)+"&Street="+encodeURIComponent(street)+"&City="+encodeURIComponent(city)+"&PostalCode="+encodeURIComponent(postalCode)+"&Country="+encodeURIComponent(country)+"&State="+encodeURIComponent(state)+"&Accreditation="+encodeURIComponent(Accreditation)+"&Alias="+encodeURIComponent(Alias);
            	    
                    }
                	else{
                		 var Active = false;
                        if( window.frames['middleFrame'].document.getElementById('Active').checked){
                                Active = true;
                        }
                        var ctx= window.frames['middleFrame'].document.getElementById('stockAdd').value;
                		var ctxRemove= window.frames['middleFrame'].document.getElementById('stockRemove').value;
                               var target = "emxPLMOnlineAdminUpdatePerson.jsp?Source=Admin&PLM_ExternalID="+encodeURIComponent(plmID)+"&V_first_name="+encodeURIComponent(firstName)+"&V_last_name="+encodeURIComponent(lastName)+"&V_phone="+encodeURIComponent(phone)+"&Work_Phone_Number="+encodeURIComponent(Work_Phone_number)+"&V_email="+encodeURIComponent(mail)+"&Street="+encodeURIComponent(street)+"&City="+encodeURIComponent(city)+"&PostalCode="+encodeURIComponent(postalCode)+"&Country="+encodeURIComponent(country)+"&State="+encodeURIComponent(state)+"&Ctx2Add="+encodeURIComponent(ctx)+"&Ctx2Remove="+encodeURIComponent(ctxRemove)+"&Accreditation="+encodeURIComponent(Accreditation)+"&Alias="+encodeURIComponent(Alias)+"&Active="+Active;
                		}
               window.location.href = target;
            }
       }

/*
 *Add a node to a tree
 * @Node     : node to wich we want to add the newNode created
 * @iconName : the icon associated to this node
 * @label    : the newNode Label
 * @jspPath  : the path of the jsp to call
 * @return   : newNode created
 */
 function addNodeToTree(Node,iconName,label,jspPath){
     if (jspPath.indexOf("?") != -1){
        var jspFinal = jspPath + "&suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common";
     }else{
        var jspFinal = jspPath + "?suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common";
     }
     var objNewNodePreferences = new top.emxUIObjectNode(iconName, label ,jspFinal , "null", "null", "", "", "", "r");
     objNewNodePreferences = Node.addChild(objNewNodePreferences);
     return objNewNodePreferences;
 }
function removeChildByID(node,strNodeID) {
        var objNode = node.tree.nodes[strNodeID];
        if (objNode) {
                node.childNodes.remove(objNode);
                node.tree.nodes.remove(objNode);
                node.tree.nodes[strNodeID] = null;
                var objObject = node.tree.objects[objNode.objectID];
                objObject.nodes.remove(objNode);
                if (objObject.nodes.length == 0) {
                        node.tree.deleteObject(objNode.objectID);
                } 
        } 
}
/*
 *Add a row to a table
 * @tableName     : Name of the table to which we want to add the row
 */
function addRowToTable(tableName){
        var newRow = document.getElementById(tableName).insertRow(-1);
        var size = document.getElementById(tableName).rows.length;

        var newCell = newRow.insertCell(0);
        newCell.style.backgroundColor= "#eeeeee";
        newCell.style.color = "#67738d";
        newCell.align = "center";

        var newCell1 = newRow.insertCell(1);
        newCell1.style.backgroundColor= "#eeeeee";
        newCell1.style.color = "#67738d";
        newCell1.align = "center";

        var newCell3 = newRow.insertCell(2);
        newCell3.style.backgroundColor= "#eeeeee";
        newCell3.style.color = "#67738d";
        newCell3.align = "center";
        newCell3.fontFamily = "Arial, Helvetica, Sans-Serif ";
        newCell3.fontSize = "6pt";

        var e2 = document.createElement('input');

        e2.type = 'text';
        e2.name = 'bu' ;
        e2.value = "";
        e2.id = 'Sec'+size;
        e2.size = 5;
        e2.width = 100;
        e2.style.align = "middle";
        e2.style.border ="";

        var e1 = document.createElement('input');

        e1.type = 'text';
        e1.name = 'bu' ;
        e1.value = "";
        e1.id = 'Desc'+size;
        e1.size = 5;
        e1.width = 100;
        e1.style.border ="";
        newCell.appendChild(e2);
        newCell1.appendChild(e1);
    }

/*
 *Add a row to a table
 * @tableName     : Name of the table to which we want to add the row
 */
function editAllRowsInTable(tableName){
       var size = document.getElementById(tableName).rows.length;
       
 document.getElementById('test').name = "edit";

        for(var i = 1 ; i < size ; i++){
            var rowi = document.getElementById(tableName).rows[i];
            var nameRow =rowi.cells[0].innerHTML;
            var nameRow1 =rowi.cells[1].innerHTML;
            var plmid =rowi.cells[0].name;
            if (nameRow.indexOf("INPUT") == -1){
                var e = document.createElement('input');
                e.type = 'text';
                e.value = nameRow;

                e.id = 'input1';
                e.size = 5;
                e.width = 100;
                e.style.align = "middle";
                e.style.border ="";
                rowi.cells[0].innerHTML="";
                e.name = plmid ;
                rowi.cells[0].appendChild(e);

                var e2 = document.createElement('input');
                e2.type = 'text';
                e2.value = nameRow1;
                e2.id = 'input2'+i;;
                e2.size = 5;
                e2.width = 100;
                e2.style.align = "middle";
                e2.style.border ="";
                rowi.cells[1].innerHTML="";
                rowi.cells[1].appendChild(e2);

            }
        }

    }


function displaySecondColumnFrame(secondSrc,thirdSource){
       var resultat="";
       for(var i = 0 ; i <document.submitForm.elements.length-1 ; i++ ){
        if( (document.submitForm.elements[i].name != null) || (document.submitForm.elements[i].name != "") ){
            resultat = resultat + document.submitForm.elements[i].name + "=" + encodeURIComponent(document.submitForm.elements[i].value)+"&";
	}}
        resultat = resultat+document.submitForm.elements[document.submitForm.elements.length-1].name+ "=" + encodeURIComponent(document.submitForm.elements[document.submitForm.elements.length-1].value);
        parent.document.getElementById("frameCol").cols="20,80";
        parent.Topos.location.href=secondSrc+"?"+resultat;
        if(thirdSource != ""){
              parent.document.getElementById("sommaire").src=thirdSource;
        }
    }


// Function to collapse/expand a menu
// @num : Menu number to expand
function clicMenu(num) {
  // Boolen reconnaissant le navigateur (vu en partie 2)
  isIE = (document.all) 
  isNN6 = (!isIE) && (document.getElementById)

  if (isIE) menu = document.all['menu' + num];
  if (isNN6) menu = document.getElementById('menu' + num);

  // On ouvre ou ferme
  if (menu.style.display == "none"){
    menu.style.display = 'block';
    if(document.getElementById('im'+num).name != "images/xpexpand1_s.gif"){
    document.getElementById('im'+num).src = "images/xpcollapse1_s.gif";
    document.getElementById('im'+num).value = "images/xpcollapse1_s.gif";
    }
    else {
    document.getElementById('im'+num).src = "images/xpcollapse2_s.gif";
    document.getElementById('im'+num).value = "images/xpcollapse2_s.gif";
    
    
    }
  } else {
    // On le cache
    menu.style.display = "none"

      if(document.getElementById('im'+num).value != "images/xpcollapse1_s.gif"){
    document.getElementById('im'+num).src = "images/xpexpand1_s.gif";
    document.getElementById('im'+num).value = "images/xpexpand1_s.gif";
    }
    else {
    document.getElementById('im'+num).src = "images/xpexpand1_s.gif";
    document.getElementById('im'+num).value = "images/xpexpand1_s.gif";
    }
   }
}

 function CreationFrame(iTypeName){
                parent.document.getElementById('frameCol').cols="100,0";
                parent.document.getElementById('frameRow').rows="100,0";
                parent.document.getElementById('sommaire').src="emxPLMOnlineAdminCreate"+iTypeName+".jsp";
            }


 //ZUR
 function SwitchMenuParams(divName, currentElement) 
 {
	var el = document.getElementById(divName);
		
	if(el != null)
	{
		if ( el.style.display != 'none' ) 
		{
			//hide
			el.style.display = 'none';
			currentElement.src = '../common/images/xpexpand1_s.gif';
		}
		else 
		{
			//show
			el.style.display = '';	
			currentElement.src = '../common/images/xpcollapse1_s.gif';
		}
	}
}

//ZUR
function addTableControllingDiv(DivID,iTitle,toolbarWidth,iconFileName,iconToolTip)
{
	document.write('<table border="0" width="'+toolbarWidth+'" >');
	document.write('<tr bgcolor="#659ac2" align="left">');
	document.write('<td class="pic" style="border:0"><img src="../common/images/'+iconFileName+'" title="'+iconToolTip+'"/></td>');
	document.write('<td class="header"><b>'+iTitle+'</b></td>');
	document.write('<td class="pic" style="border:0" align="center"><img src="images/xpcollapse1_s.gif" onclick="SwitchMenuParams(\''+DivID+'\', this);"/></td>');
	document.write('</tr>')
	document.write('</table>');
}

//ZUR
function addDivForNonAppropriateContext(iDisplayHide,iTextToShow,iwidth,iheight)
{					
	document.write('<div class="transparency" id="paramLoadingDiv"  style="z-index:1; position:absolute; display:'+iDisplayHide+'" >');
	document.write('<table width="'+iwidth+'" style="height :'+iheight+'" >');
	document.write('<tr valign="middle" align="middle">');
	document.write('<td id="paramMsgWarningHolder" style="color:#990000 ; font-style:italic; font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt">');
	document.write(iTextToShow+'</td>');
	document.write('</tr></table>');
	document.write('</div>');
}

//ZUR IR-425416-3DEXPERIENCER2015x
function sendLicenseWarningMsg(iMsgTexttoShow) {
	var iparamLoadingDiv = document.getElementById('paramLoadingDiv'),
	    iTextCell = document.getElementById('paramMsgWarningHolder');
	
	if (iparamLoadingDiv.style.display == 'none') {
		iparamLoadingDiv.style.display = 'block';
		iTextCell.innerHTML = '<td style="color:#990000 ; font-style:italic; font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt">'+iMsgTexttoShow+'</td>';
	} else {
		//'block', mix the message
		iparamLoadingDiv.style.display = 'block';//force it anyway		
		iMsgTexttoShow =  iTextCell.innerHTML + '<BR>'+ iMsgTexttoShow;
		iTextCell.innerHTML = '<td style="color:#990000 ; font-style:italic; font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt">'+iMsgTexttoShow+'</td>';	
	}
}
