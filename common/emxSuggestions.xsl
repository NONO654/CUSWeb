<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
        <xsl:template match="/mxRoot">
      	<div id="SuggestionsContainer">
            <div id="SuggestionsContent">
                  <h2>Search Results for: 			     
				  	<xsl:for-each select="txtTextSearch/txtTextSearch">     
        				"<xsl:value-of select="setting"/>"
			     	</xsl:for-each>    	  

                  </h2>
                  <p>No results found.</p>
                  <p>                 
                  	 <xsl:for-each select="object/object">
        <xsl:variable name="value"><xsl:value-of select="string"/></xsl:variable>
			        Did you mean "<a href="javascript:suggestions_Search('{$value}')">
			                <xsl:value-of select="string"/>
			        </a> "?
			        
        </xsl:for-each>
        			
				  </p>
            </div>
        </div>

        </xsl:template>
</xsl:stylesheet>

