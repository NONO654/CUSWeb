<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" version="4.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="SEARCH">
    <html>
      <body>
        <h2><xsl:value-of select="TITLE"/></h2>

        <table border="1">
          <tr bgcolor="#9acd32">
            <th>Thumbnail</th>
            <th>Type</th>
            <th>Title</th>
            <th>Description</th>
            <th>Owner</th>
          </tr>
          <xsl:for-each select="SEARCH_ITEM">
            <tr>
              <td>
                <xsl:if test="ATTRIBUTE[@id='image']">
                  <img>
                    <xsl:attribute name="src">
                      <xsl:value-of select="ATTRIBUTE[@id='image']"/>
                    </xsl:attribute>
                  </img>
                </xsl:if>
              </td>
              <td>
                <xsl:if test="ATTRIBUTE[@id='icon']">
                  <img height="16" width="16">
                    <xsl:attribute name="src">
                      <xsl:value-of select="ATTRIBUTE[@id='icon']"/>
                    </xsl:attribute>
                  </img>
                </xsl:if>
                <xsl:value-of select="ATTRIBUTE[@id='ds6w:type']"/>
              </td>
              <td><xsl:value-of select="ATTRIBUTE[@id='title']"/></td>
              <td><xsl:value-of select="ATTRIBUTE[@id='content']"/></td>
              <td><xsl:value-of select="ATTRIBUTE[@id='ds6w:responsible']"/></td>
            </tr>
          </xsl:for-each>
        </table>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
