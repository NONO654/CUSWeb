<%-- (c) Dassault Systemes, 2007, 2008 --%>

<%
    // Search page include file:
    //     Used when a VPM Project field is needed on a search page
    //     Has Name field in case we want to use it again (currently
    //     we are not using it)
    //
    // Variables needed to be declared in parent JSP:
    //     sStar    - Default field value that says "find anything"
    //     sClear   - Text of clear link
    //     simBean  - Java bean for class smaSearchSimulation
%>

    <!-- VPM Project -->
    <tr>
        <td width="150" class="label">
            <%=simBean.getVPMProjectLabel()%>
        </td>
        <td class="inputField" nowrap="nowrap">
            <input type="text" name="VPMProject" value="<%=sStar%>" 
                   maxlength="" size="20">&nbsp;
            <a class="dialogClear" href="#" 
            onclick="javascript:clearVPMProject(); return false;">
            <%=sClear%></a>
         </td>
    </tr>

    <script language="javascript">
    // Changes name field to be a star
    function clearVPMProject()
    {
        document.editDataForm.VPMProject.value="<%=sStar %>";
    }
    </script>
