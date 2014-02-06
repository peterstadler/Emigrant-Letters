<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:ct="http://wiki.tei-c.org/index.php/SIG:Correspondence/task-force-correspDesc"
    xmlns:functx="http://www.functx.com"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:include href="http://www.xsltfunctions.com/xsl/functx-1.0-nodoc-2007-01.xsl"/>
    
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">
            <xsl:text>href="https://raw2.github.com/TEI-Correspondence-SIG/correspDesc/master/proposal.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
        </xsl:processing-instruction>
        <xsl:element name="TEI">
            <xsl:call-template name="create-teiHeader"/>
            <xsl:element name="text">
                <xsl:element name="body">
                    <xsl:element name="listBibl">
                        <xsl:apply-templates select="//h:tr"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <!-- Exclude table heading and empty rows at position 1, 5001, 5002 -->
    <xsl:template match="h:tr[not(position() = (1, 5001, 5002))]">
        <xsl:element name="ct:correspDesc">
            <xsl:attribute name="n" select="position()"/>
            <xsl:variable name="recordtitle" select="tokenize(ct:normalize-space(h:td[2]), '[\s,]+[Tt]o[,\.]?\s+')"/>
            <xsl:variable name="sender" select="tokenize($recordtitle[1], '\s*,\s*')"/>
            <xsl:variable name="addressee" select="tokenize($recordtitle[2], '\s*,\s*')"/>
            <xsl:variable name="placeSender" select="ct:normalize-name(string-join(subsequence($sender, 2)[matches(., '\w')], ', '))"/>
            <xsl:variable name="placeAddressee" select="ct:normalize-name(string-join(subsequence($addressee, 2)[matches(., '\w')], ', '))"/>
            <xsl:element name="ct:sender">
                <xsl:value-of select="ct:normalize-name($sender[1])"/>
            </xsl:element>
            <xsl:if test="$placeSender">
                <xsl:call-template name="create-element">
                    <xsl:with-param name="myElementName" select="'ct:placeSender'"/>
                    <xsl:with-param name="myElementContent" select="$placeSender"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$addressee[1]">
                <xsl:call-template name="create-element">
                    <xsl:with-param name="myElementName" select="'ct:addressee'"/>
                    <xsl:with-param name="myElementContent" select="ct:normalize-name($addressee[1])"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="$placeAddressee">
                <xsl:call-template name="create-element">
                    <xsl:with-param name="myElementName" select="'ct:placeAddressee'"/>
                    <xsl:with-param name="myElementContent" select="$placeAddressee"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:copy-of select="ct:create-date(normalize-space(h:td[6]))"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Empty template for removing table heading and empty rows -->
    <xsl:template match="*"/>
    
    <xsl:function name="ct:normalize-name" as="xs:string">
        <xsl:param name="myString"/>
        <xsl:value-of select="
            string-join(
                for $i in tokenize(replace(ct:normalize-tokens($myString), '\.', '. '), '\s+')
                return 
                    if(matches($i, '^[A-Z]$')) then concat($i, '.')
                    else $i,
                ' ')
            "/>
    </xsl:function>
    
    <xsl:function name="ct:normalize-space" as="xs:string">
        <xsl:param name="myString"/>
        <xsl:value-of select="normalize-space(replace($myString, '&#160;|&#8194;|&#8195;|&#8201;|[\.,]\s*$', ' '))"/>
    </xsl:function>
    
    <xsl:function name="ct:normalize-tokens" as="xs:string">
        <xsl:param name="myString"/>
        <xsl:variable name="replacements">
            <ct:replacements>
                <ct:replacement>
                    <ct:regex>U\.?\s*S\.?\s*A\.?</ct:regex>
                    <ct:string>USA</ct:string>
                </ct:replacement>
                <ct:replacement>
                    <ct:regex>N\.?\s*Y\.?</ct:regex>
                    <ct:string>NY</ct:string>
                </ct:replacement>
                <ct:replacement>
                    <ct:regex>Co\s</ct:regex>
                    <ct:string>Co. </ct:string>
                </ct:replacement>
                <ct:replacement>
                    <ct:regex>Jr\s</ct:regex>
                    <ct:string>Jr. </ct:string>
                </ct:replacement>
                <ct:replacement>
                    <ct:regex>Mr\s</ct:regex>
                    <ct:string>Mr. </ct:string>
                </ct:replacement>
                <ct:replacement>
                    <ct:regex>Mrs\s</ct:regex>
                    <ct:string>Mrs. </ct:string>
                </ct:replacement>
                <ct:replacement>
                    <ct:regex>County\s</ct:regex>
                    <ct:string>Co. </ct:string>
                </ct:replacement>
            </ct:replacements>
        </xsl:variable>
        <xsl:value-of select="functx:replace-multi($myString, $replacements//ct:regex, $replacements//ct:string)"/>
    </xsl:function>
    
    <xsl:function name="ct:is-uncertain" as="xs:boolean">
        <xsl:param name="myString"/>
        <xsl:copy-of select="matches($myString, '^\[[^\]]+\?\]$')"/>
    </xsl:function>
    
    <xsl:function name="ct:strip-brackets" as="xs:string">
        <xsl:param name="myString"/>
        <xsl:value-of select="substring($myString, 2, string-length($myString) - 3)"/>
    </xsl:function>
    
    <xsl:template name="create-element" as="element()">
        <xsl:param name="myElementName" as="xs:string"/>
        <xsl:param name="myElementContent" as="xs:string?"/>
        <xsl:element name="{$myElementName}">
            <xsl:choose>
                <xsl:when test="ct:is-uncertain($myElementContent)">
                    <xsl:attribute name="cert" select="'medium'"/>
                    <xsl:value-of select="ct:strip-brackets($myElementContent)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$myElementContent"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="create-teiHeader">
        <xsl:element name="teiHeader">
            <xsl:call-template name="fileDesc"/>
            <xsl:call-template name="revisionDesc"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="fileDesc">
        <xsl:element name="fileDesc">
            <xsl:element name="titleStmt">
                <xsl:element name="title">MCMS Letters. Metadata in TEI format according to the current proposal of the Correspondence SIG</xsl:element>
                <xsl:element name="respStmt">
                    <xsl:element name="resp">Transformation to TEI</xsl:element>
                    <xsl:element name="name">Peter Stadler</xsl:element>
                </xsl:element>
            </xsl:element>
            <xsl:element name="publicationStmt">
                <xsl:element name="p">Available under dual license CC-BY and BSD-2</xsl:element>
            </xsl:element>
            <xsl:element name="sourceDesc">
                <xsl:element name="p">Born digital. Created via XSLT from a spreadsheet</xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="revisionDesc">
        <xsl:element name="revisionDesc">
            <xsl:attribute name="status" select="'candidate'"/>
            <xsl:element name="change">
                <xsl:attribute name="when" select="adjust-date-to-timezone(current-date(), ())"/>
                <xsl:attribute name="who" select="'Peter'"/>
                <xsl:attribute name="status" select="'candidate'"/>
                <xsl:text>Initial creation</xsl:text>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:function name="ct:create-date" as="element(ct:dateSender)?">
        <xsl:param name="recorddate" as="xs:string"/>
        <xsl:variable name="date" select="concat(
            substring($recorddate,1,4),'-',
            substring($recorddate,5,2),'-',
            substring($recorddate,7,2))"/>
        <xsl:if test="$date castable as xs:date">
            <xsl:element name="ct:dateSender">
                <xsl:attribute name="when" select="$date"/>
            </xsl:element>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>

