<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" omit-xml-declaration="yes" indent="yes"/>
    <xsl:variable name="split" select="/mxRoot/setting[@name='split']"/>
    <xsl:variable name="compare" select="/mxRoot/requestMap/setting[@name='IsStructureCompare']" />
    <xsl:variable name="reportType">
        <xsl:if test="/mxRoot/requestMap/setting[@name='IsStructureCompare'] = 'TRUE'">
            <xsl:value-of select="/mxRoot/requestMap/setting[@name='reportType']" />
        </xsl:if>
    </xsl:variable>

    <!--
     ! root template
     !-->
    <xsl:template match="mxRoot">
        <!-- must be left-aligned to work properly -->
        <xsl:value-of select="//setting[@name='PageHeader']"/>
        <xsl:text>N:eW:Li:nE</xsl:text>
        <xsl:if test="/mxRoot/tableControlMap//setting[@name='subHeader']">
            <xsl:value-of select="/mxRoot/tableControlMap//setting[@name='subHeader']"/>
            <xsl:text>N:eW:Li:nE</xsl:text>
        </xsl:if>
        <xsl:text>N:eW:Li:nE</xsl:text>
        <xsl:apply-templates select="columns"/>
        <xsl:apply-templates select="rows"/>
    </xsl:template>

    <!--
     ! columns template
     !-->
    <xsl:template match="columns">
        <xsl:variable name="isIndentedView" select="//setting[@name='isIndentedView']"/>
        <xsl:variable name="hasMergedCell" select="/mxRoot/requestMap/setting[@name='HasMergedCell']/value"/>
        <xsl:variable name="currentNode" select="."/>

        <xsl:if test="//setting/@name='Group Header'">
            <!-- empty first cell for "level" column -->
            <xsl:if test="$reportType = 'Complete_Summary_Report'"><xsl:value-of select="','"/></xsl:if><xsl:if test="normalize-space($isIndentedView) = 'true'"><xsl:value-of select="','"/></xsl:if><xsl:apply-templates select="column" mode="group-header"/>
            <xsl:text>N:eW:Li:nE</xsl:text>
        </xsl:if>
        <xsl:if test="$reportType = 'Complete_Summary_Report' and /mxRoot/tableControlMap/setting[@name='HasDiffCodeColumn']/value = 'true'">
            <xsl:value-of select="//setting[@name='Labels']//item[@name='DiffCode']/value"/><xsl:value-of select="','"/>
        </xsl:if>
        <xsl:if test="normalize-space($isIndentedView) = 'true'">
            <xsl:value-of select="//setting[@name='Labels']//item[@name='Level']/value"/><xsl:value-of select="','"/>
            <xsl:choose>
                <xsl:when test="$hasMergedCell = 'true'">
                    <xsl:for-each select="/mxRoot/setting[@name = 'exportToExcelRows']/exportRow[position() = 1]/cell">
                    <xsl:variable name="cIndex" select="."/>
                    <xsl:choose>
                        <xsl:when test="$cIndex = 'BlankCell'">
                            <xsl:value-of select="','"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$currentNode/column/@type != 'separator'">
                                <xsl:apply-templates select="$currentNode/column[position() = $cIndex]"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:text>N:eW:Li:nE</xsl:text><xsl:value-of select="','"/>
                <xsl:for-each select="/mxRoot/setting[@name = 'exportToExcelRows']/exportRow[position() = 2]/cell">
                    <xsl:variable name="cIndex" select="."/>
                    <xsl:choose>
                        <xsl:when test="$cIndex = 'BlankCell'">
                            <xsl:value-of select="','"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$currentNode/column/@type != 'separator'">
                                <xsl:apply-templates select="$currentNode/column[position() = $cIndex]"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="column"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="normalize-space($isIndentedView) = 'false'">
            <xsl:choose>
                <xsl:when test="$hasMergedCell = 'true'">
                    <xsl:for-each select="/mxRoot/setting[@name = 'exportToExcelRows']/exportRow[position() = 1]/cell">
                    <xsl:variable name="cIndex" select="."/>
                    <xsl:choose>
                        <xsl:when test="$cIndex = 'BlankCell'">
                            <xsl:value-of select="','"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$currentNode/column/@type != 'separator'">
                                <xsl:apply-templates select="$currentNode/column[position() = $cIndex]"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <xsl:text>N:eW:Li:nE</xsl:text>
                <xsl:for-each select="/mxRoot/setting[@name = 'exportToExcelRows']/exportRow[position() = 2]/cell">
                    <xsl:variable name="cIndex" select="."/>
                    <xsl:choose>
                        <xsl:when test="$cIndex = 'BlankCell'">
                            <xsl:value-of select="','"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="$currentNode/column/@type != 'separator'">
                                <xsl:apply-templates select="$currentNode/column[position() = $cIndex]"/>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="column"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:text>N:eW:Li:nE</xsl:text>
    </xsl:template>

    <!--
     ! column template
     !-->
    <xsl:template match="column">
        <xsl:if test="@export='true'"><xsl:choose><xsl:when test="contains(@label,'img') and contains(@label,'src')"><xsl:value-of select="@name"/>,</xsl:when><xsl:otherwise><xsl:value-of select="@label"/>,</xsl:otherwise></xsl:choose>
        </xsl:if>
    </xsl:template>

    <!--
     ! column template (for group headers)
     !-->
    <xsl:template match="column" mode="group-header">
        <xsl:variable name="columnType" select="settings/setting[@name='Column Type']/text()"/>

        <xsl:if test="@type != 'separator' and $columnType!='image' and $columnType!='icon' and $columnType!='File'  and settings/setting[@name='Row Number']/text() = '1' and @export='true'">
            <xsl:choose>
                <xsl:when test="settings/setting/@name='Group Header'">
                    <xsl:choose>
                        <xsl:when test="settings/setting[@name='Group Header']">
                            <xsl:variable name="currentText" select="settings/setting[@name='Group Header']/text()"/>
                            <xsl:value-of select="settings/setting[@name='Group Header']/text()"/>
                            <xsl:value-of select="','"/>
                        </xsl:when>
                        <xsl:otherwise><xsl:value-of select="','"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="','"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
  </xsl:template>

    <!--
     ! rows template
     !-->
    <xsl:template match="rows">
        <xsl:apply-templates select="r"/>
    </xsl:template>

    <!--
     ! row template
     !-->
    <xsl:template match="r">
        <xsl:variable name="isIndentedView" select="//setting[@name='isIndentedView']"/>
        <xsl:variable name="display" select="string(@display)"/>
        <xsl:variable name="filter" select="string(@filter)" />
        <xsl:variable name="diffcode" select="string(@diffcode)"/>
        <xsl:variable name="hasMergedCell" select="/mxRoot/requestMap/setting[@name='HasMergedCell']/value"/>
        <xsl:variable name="currentr" select="."/>

        <xsl:if test="not($filter = 'true')">
            <xsl:if test="$reportType = 'Complete_Summary_Report' and /mxRoot/tableControlMap/setting[@name='HasDiffCodeColumn']/value = 'true'">
                <xsl:choose>
                    <xsl:when test="contains($diffcode,',')">&quot;<xsl:call-template name="replace-string"><xsl:with-param name="text" select="$diffcode"/><xsl:with-param name="from" select="','"/><xsl:with-param name="to" select="'N:Com:Sep'"/></xsl:call-template>&quot;,</xsl:when>
                    <xsl:otherwise>&quot;=&quot;&quot;<xsl:value-of select="$diffcode"/>&quot;&quot;&quot;,</xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="normalize-space($isIndentedView) = 'true'">
                <xsl:choose>
                    <xsl:when test="$hasMergedCell = 'true'">
                        <xsl:value-of select="count(ancestor-or-self::r)"/><xsl:value-of select="','"/>
                        <xsl:for-each select="/mxRoot/setting[@name = 'exportToExcelRows']/exportRow[position() = 1]/cell">
                            <xsl:variable name="cIndex" select="."/>
                            <xsl:choose>
                                <xsl:when test="$cIndex = 'BlankCell'">
                                    <xsl:value-of select="','"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="$currentr/c[position() = $cIndex]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:text>N:eW:Li:nE</xsl:text><xsl:value-of select="','"/>
                        <xsl:for-each select="/mxRoot/setting[@name = 'exportToExcelRows']/exportRow[position() = 2]/cell">
                            <xsl:variable name="cIndex" select="."/>
                            <xsl:choose>
                                <xsl:when test="$cIndex = 'BlankCell'">
                                    <xsl:value-of select="','"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="$currentr/c[position() = $cIndex]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
	        		<xsl:value-of select="count(ancestor-or-self::r)"/>,<xsl:apply-templates select="c"/>					
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="normalize-space($isIndentedView) = 'false'">
                <xsl:choose>
                    <xsl:when test="$hasMergedCell = 'true'">
                        <xsl:for-each select="/mxRoot/setting[@name = 'exportToExcelRows']/exportRow[position() = 1]/cell">
                            <xsl:variable name="cIndex" select="."/>
                            <xsl:choose>
                                <xsl:when test="$cIndex = 'BlankCell'">
                                    <xsl:value-of select="','"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="$currentr/c[position() = $cIndex]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:text>N:eW:Li:nE</xsl:text>
                        <xsl:for-each select="/mxRoot/setting[@name = 'exportToExcelRows']/exportRow[position() = 2]/cell">
                            <xsl:variable name="cIndex" select="."/>
                            <xsl:choose>
                                <xsl:when test="$cIndex = 'BlankCell'">
                                    <xsl:value-of select="','"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="$currentr/c[position() = $cIndex]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="c"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:text>N:eW:Li:nE</xsl:text>
            <xsl:if test="$display = 'block'">
                <xsl:choose>
                    <xsl:when test="$reportType='Unique_toLeft_Report'">
                        <xsl:apply-templates select="r[@matchresult='left']"/>
                    </xsl:when>
                    <xsl:when test="$reportType='Unique_toRight_Report'">
                        <xsl:apply-templates select="r[@matchresult='left']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="r[not(@displayRow='false')]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!--
     ! cell template
     !-->
    <xsl:template match="c">
        <xsl:variable name="index" select="position()"/>
        <xsl:variable name="cellvalue">
            <xsl:choose>
                <xsl:when test="./mxLink">
                    <xsl:for-each select="./mxLink/node()"><xsl:value-of select="."/></xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="not(/mxRoot/columns/column[$index]/@export='false')">
            <xsl:choose>
	<xsl:when test="not(/mxRoot/columns/column[$index]/settings/setting[@name='format'])">=&quot;<xsl:value-of select="."/>&quot;,</xsl:when>
	<xsl:when test="/mxRoot/columns/column[$index]/settings/setting[@name='format'] = 'alphanumeric'">
		<xsl:choose>
			<xsl:when test="contains(text(),'&#160;')">&quot;<xsl:call-template name="replace-string"><xsl:with-param name="text" select="$cellvalue"/><xsl:with-param name="from" select="'&#160;'"/><xsl:with-param name="to" select="' '"/></xsl:call-template>&quot;,</xsl:when>
			<xsl:when test="contains(text(),'&quot;')">&quot;<xsl:call-template name="replace-string"><xsl:with-param name="text" select="$cellvalue"/><xsl:with-param name="from" select="'&quot;'"/><xsl:with-param name="to" select="'&quot;&quot;'"/></xsl:call-template>&quot;,</xsl:when>
			 <xsl:when test="contains(text(),'&lt;') or contains(text(),'&gt;') or contains(text(),';')">&quot;<xsl:value-of select="$cellvalue"/>&quot;,</xsl:when>
			<xsl:when test="contains(.,',')">&quot;<xsl:call-template name="replace-string"><xsl:with-param name="text" select="$cellvalue"/><xsl:with-param name="from" select="','"/><xsl:with-param name="to" select="'N:Com:Sep'"/></xsl:call-template>&quot;,</xsl:when>
			<xsl:when test="./mxLink">&quot;=&quot;&quot;<xsl:for-each select="./mxLink/node()"><xsl:value-of select="."/></xsl:for-each>&quot;&quot;&quot;,</xsl:when>
			<xsl:when test="starts-with(text(),'0')"><xsl:value-of select="."/></xsl:when>
		   <xsl:otherwise>&quot;<xsl:value-of select="."/>&quot;,</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>&quot;<xsl:value-of select="."/>&quot;,</xsl:otherwise>
</xsl:choose>
        </xsl:if>
    </xsl:template>

    <!--
     ! utility template
     !-->
    <xsl:template name="replace-string">
        <xsl:param name="text"/>
        <xsl:param name="from"/>
        <xsl:param name="to"/>

        <xsl:choose>
            <xsl:when test="contains($text, $from)">
                <xsl:variable name="before" select="substring-before($text, $from)"/>
                <xsl:variable name="after" select="substring-after($text, $from)"/>
                <xsl:variable name="prefix" select="concat($before, $to)"/>

                <xsl:value-of select="$before"/>
                <xsl:value-of select="$to"/>
                <xsl:call-template name="replace-string">
                    <xsl:with-param name="text" select="$after"/>
                    <xsl:with-param name="from" select="$from"/>
                    <xsl:with-param name="to" select="$to"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>

