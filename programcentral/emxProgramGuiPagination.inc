<%--
  emxProgramGuiPagination.inc -- This inserts a pager into the calling jsp.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramGuiPagination.inc.rca 1.5 Wed Oct 22 15:49:13 2008 przemek Experimental przemek $"

  Usage:

    <%@ include file="emxProgramGuiPagination.inc" %>
--%>

  <table border="0">
    <tr>
      <td><img src="images/prevarrow.gif" width="11" height="11" /></td>
      <td>Page&nbsp;</td>
      <td>
        <select class="pagination" name="select">
          <option class="pagination" selected>1</option>
          <option class="pagination">2</option>
          <option class="pagination">3</option>
          <option class="pagination">4</option>
          <option class="pagination">5</option>
          <option class="pagination">6</option>
          <option class="pagination">7</option>
          <option class="pagination">8</option>
          <option class="pagination">9</option>
          <option class="pagination">10</option>
        </select>
      </td>
      <td nowrap>of 10</td>
      <td><img src="images/nextarrow.gif" width="11" height="11" /></td>
    </tr>
  </table>

