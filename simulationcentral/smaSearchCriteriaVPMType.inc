<%-- (c) Dassault Systemes, 2007, 2008 --%>

<%
    // Search page include file:
    //     Used when a VPM Type field is needed on a search page
    //     Has Name field in case we want to use it again (currently
    //     we are not using it)
    //
    // Variables needed to be declared in parent JSP:
    //     sStar    - Default field value that says "find anything"
    //     simBean  - Java bean for class smaSearchSimulation
     HashMap vpmTypes = simBean.getVPMSearchTypes();
%>

    <!-- VPM Type -->
    <tr>
        <td width="150" class="label">
            <%=simBean.getVPMTypeLabel()%>
        </td>
        <td class="inputField">
            <select name="VPMType" id="VPMType" size="1">
                <option value="Product"><%=vpmTypes.get("Product")%></option>
                <option value="Simulation"><%=vpmTypes.get("Simulation")%></option>
                <option value="Representation"><%=vpmTypes.get("Representation")%></option>
                <option value="Reference"><%=vpmTypes.get("Reference")%></option>
            </select>
        </td>
    </tr>
