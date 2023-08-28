<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSL document will output the collected XML of all the harvested documents and remove all newline characters from text fields-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" omit-xml-declaration="yes" />
    <xsl:template match="/">
        <xsl:copy-of select="node()"/>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
