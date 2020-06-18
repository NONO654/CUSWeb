<%-- (c) Dassault Systemes, 2007, 2008 --%>

<%
    // Search page include file:
    //     Used when a VPM Intent field is needed on a search page
    //     Has Name field in case we want to use it again (currently
    //     we are not using it)
    //
    // Variables needed to be declared in parent JSP:
    //     sStar    - Default field value that says "find anything"
    //     simBean  - Java bean for class smaSearchSimulation

    List vpmIntents = simBean.getVPMSearchIntents();
    String sSpecify = simBean.getVPMSpecifyLabel();
%>

    <!-- VPM Intent HTML -->
    <tr id="VPMIntentRow">
        <td width="150" class="label">
            <%=simBean.getVPMTypeLabel()%>
        </td>
        <td class="inputField">
            <select name="VPMIntent" id="VPMIntent" size="1"
             onChange="javascript:smaSetIntentFields(this.selectedIndex);">
<!--
             <option value="SpecifyFields"><%=sSpecify%></option>
-->
<%
    Iterator iter = vpmIntents.iterator();
    while (iter.hasNext())
    {
       Map intent = (Map) iter.next();
       String sKey = (String) intent.get("Key");
       String sLabel = (String) intent.get("Label");
%>
                <option value="<%=sKey%>"><%=sLabel%></option>
<%
    }     
%>
            </select>
        </td>        
    </tr>

    <script language="javascript">
    var aKeys=new Array();
    var aLabels=new Array();
    var aTypes=new Array();
    var aUsages=new Array();
    var aDisciplines=new Array();
<%
    Iterator iter2 = vpmIntents.iterator();
    while (iter2.hasNext())
    {
       Map intent = (Map) iter2.next();
       String sKey = (String) intent.get("Key");
       String sLabel = (String) intent.get("Label");
       String sType = (String) intent.get("Type");
       String sUsage = (String) intent.get("Usage");
       String sDiscipline = (String) intent.get("Discipline");
%>
       aKeys.push("<%=sKey%>");
       aLabels.push("<%=sLabel%>");
       aTypes.push("<%=sType%>");
       aUsages.push("<%=sUsage%>");
       aDisciplines.push("<%=sDiscipline%>");
<%
    }     
%>
    function smaGetFieldByName(name)
    {
        var fieldArray = document.getElementsByName(name);
        for(i=0; i<fieldArray.length;i++) 
            if(fieldArray[i].type!="hidden")
                return fieldArray[i];
        return null;
    }
    
    function smaDisableText(field)
    {
        field.readOnly = true;        
        field.className = "disabled";        
    }
    function smaEnableText(field)
    {
        field.readOnly = false;        
        field.className = "";        
    }
    
    function smaSetIntentFields(choice)
    {
/**
        var flag=false;
        var typeField = smaGetFieldByName("VPMType");
        var usageField = smaGetFieldByName("VPMUsage");
        var discField = smaGetFieldByName("VPMDiscipline");
		
		var typeBtnField = smaGetFieldByName("TypeButton");
        
        if( choice == 0 )
        {
           typeBtnField.onclick = function () { showTypeChooser(); };
        }
		else if( choice == 2 )
        {
           typeBtnField.onclick = function () { showVPMRepresentationTypeChooser(); };
        }
		else if( choice == 3 )
        {
            typeBtnField.onclick = function () { showSimulationsTypeChooser(); };
        }
		
		if( choice == 0 )
        {
            // make editable
            typeField.disabled=false;        
            smaEnableText(usageField);
            smaEnableText(discField);
        }
        else
        {
            // make readonly
            typeField.disabled=true;  
            smaDisableText(usageField);
            smaDisableText(discField);

            // set values
            choice = choice - 1;
            typeField.value=aTypes[choice];                 
            usageField.value=aUsages[choice];        
            discField.value=aDisciplines[choice];
        }        
*/
    }

    // this function is used to create a specific vpm search dialog
    // it will set the type usage and discipline field values
    // to the values passed in and it will disable those fields
    // so the user can't change it.  It also hides the intent row
    // since not needed when specific values are set
    function smaSetIntentFieldsReadOnly(vpmType,vpmUsage,vpmDiscipline)
    {
        // if we don't have a type then return since not being used
        // to create specific vpm chooser dialog
        if (vpmType.length == 0) return;
        var flag=false;
        var typeField = smaGetFieldByName("VPMType");
        var usageField = smaGetFieldByName("VPMUsage");
        var discField = smaGetFieldByName("VPMDiscipline");
        var intentField = smaGetFieldByName("VPMIntent");
        
        // make readonly
        typeField.disabled=true;  
        smaDisableText(usageField);
        smaDisableText(discField);
        intentField.focus = null;
        usageField.disabled=true;
        discField.disabled=true;

        // set values
        typeField.value=vpmType;                 
        usageField.value=vpmUsage;        
        discField.value=vpmDiscipline;
        //intentField.value = "SpecifyFields";
        document.getElementById("VPMIntentRow").style.display="none";

    }
    function showSimulationsTypeChooser()
    {
        showChooser('../simulationcentral/smaSearchUtil.jsp' + 
            '?slmmode=searchTypeChooser' + 
            '&formName=editDataForm' + 
            '&frameName=searchPane' + 
            '&fieldNameActual=Type' + 
            '&fieldNameDisplay=TypeDisplay' +
            '&inclusionList=<%=sSimTypes%>',700,500);
    }
	
	function showVPMRepresentationTypeChooser()
    {
        showChooser('../simulationcentral/smaSearchUtil.jsp' + 
            '?slmmode=searchTypeChooser' + 
            '&formName=editDataForm' + 
            '&frameName=searchPane' + 
            '&fieldNameActual=Type' + 
            '&fieldNameDisplay=TypeDisplay' +
            '&inclusionList=<%=sRepTypes%>',700,500);
    }
    </script>
