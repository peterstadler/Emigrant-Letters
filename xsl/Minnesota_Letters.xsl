<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:ct="http://wiki.tei-c.org/index.php/SIG:Correspondence/task-force-correspDesc"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">
            <xsl:text>href="https://raw2.github.com/TEI-Correspondence-SIG/correspDesc/master/proposal.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
        </xsl:processing-instruction>
        <xsl:element name="TEI">
            <xsl:call-template name="create-teiHeader"/>
            <xsl:element name="text">
                <xsl:element name="body">
                    <xsl:element name="listBibl">
                        <xsl:apply-templates select="//tei:row[position() gt 1][count(tei:cell) eq 7]"/>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:row">
        <xsl:element name="ct:correspDesc">
            <xsl:attribute name="n" select="tei:cell[1]"/>
            <xsl:attribute name="corresp" select="tei:cell[2]"/>
            <xsl:element name="ct:sender">
                <xsl:value-of select="tei:cell[4]"/>
            </xsl:element>
            <xsl:element name="ct:addressee">
                <xsl:value-of select="tei:cell[6]"/>
            </xsl:element>
            <xsl:element name="ct:placeSender">
                <xsl:value-of select="tei:cell[5]"/>
            </xsl:element>
            <xsl:element name="ct:placeAddressee">
                <xsl:value-of select="tei:cell[7]"/>
            </xsl:element>
            <xsl:copy-of select="ct:create-date(tei:cell[3])"/>
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
                <xsl:element name="title">Immigrant Letter Collection of the University of Minnesota. Metadata in TEI format according to the current proposal of the Correspondence SIG</xsl:element>
                <xsl:element name="respStmt">
                    <xsl:element name="resp">Extraction</xsl:element>
                    <xsl:element name="name">Luis Espinosa Anke</xsl:element>
                </xsl:element>
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
        <xsl:param name="dateString" as="xs:string"/>
        <xsl:variable name="months" as="xs:string+" select="(
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December')"/>
        <xsl:variable name="dateTokens" as="xs:string*" select="tokenize($dateString, ',?\s+')"/>
        <xsl:variable name="date" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$dateString castable as xs:date">
                    <xsl:value-of select="$dateString"/>
                </xsl:when>
                <xsl:when test="count($dateTokens) eq 3">
                    <xsl:variable name="date-from-tokens" as="xs:string?"> 
                        <xsl:value-of select="string-join(($dateTokens[3], format-number(index-of($months, $dateTokens[1]), '00'), format-number(number($dateTokens[2]), '00')), '-')"/>
                    </xsl:variable>
                    <xsl:if test="$date-from-tokens castable as xs:date">
                        <xsl:value-of select="$date-from-tokens"/>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="ct:dateSender">
            <xsl:choose>
                <xsl:when test="$date">
                    <xsl:attribute name="when" select="$date"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="date">
                        <xsl:value-of select="$dateString"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        
        <!--<xsl:if test="not($date)">
            <xsl:message select="$dateString"/>
        </xsl:if>-->
    </xsl:function>
    
</xsl:stylesheet>