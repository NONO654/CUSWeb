<%-- (c) Dassault Systemes, 2007, 2008 --%>

<%
    // Search page include file:
    //     Used when a business type field is needed on a search page
    //
    // Variables needed to be declared in parent JSP:
    //     sStar    - Default field value that says "find anything"
    //     sClear   - Text of clear link
    //     simBean  - Java bean for class smaSearchSimulation
    //     sTypes   - Business type(s) of entity to search for
    //     sTrans   - I18N translation of sTypes
%>
    <!-- Type -->
    <tr>
        <td width="150" class="label">
            <%=simBean.getTypeLabel()%>
        </td>
        <td class="inputField" nowrap="nowrap">
            <input type="text" name="TypeDisplay" value="<%=sTrans%>" 
                maxlength="" size="20" readonly="readonly">
            <input type="hidden" name="Type"  value="<%=sTypes%>">
            <input type="button" name="TypeButton" value="..." 
                onclick="javascript:showTypeChooser(); return false;">
                &nbsp;<a class="dialogClear" href="#" 
                onclick="javascript:clearType(); return false;">
                   <%=sClear%></a>
        </td>
    </tr>

    <script language="javascript">

    // Opens a "chooser" window to select a type
    function showTypeChooser()
    {
        showChooser('../simulationcentral/smaSearchUtil.jsp' + 
            '?slmmode=searchTypeChooser' + 
            '&formName=editDataForm' + 
            '&frameName=searchPane' + 
            '&fieldNameActual=Type' + 
            '&fieldNameDisplay=TypeDisplay' +
            '&inclusionList=<%=sTypes%>',700,500);
    }

    // Changes type field to be a star
    function clearType()
    {
        document.editDataForm.TypeDisplay.value="<%=sStar %>";
        document.editDataForm.Type.value="<%=sStar %>";
    }

    </script>
