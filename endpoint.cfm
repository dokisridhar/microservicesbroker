<cfprocessingdirective pageEncoding="utf-8" />
<cfsetting enablecfoutputonly="true" showdebugoutput="false" />
<cfset url.contenttype = "application/json" />

<cfparam name="url.apiMicro" default="" />
<cfset url.apiMicro = trim(url.apiMicro) />

<cfif trim(url.apiMicro) eq "">
    <cfthrow type="NoApiMicro" message="The apiMicro value must exist as a URL query parameter." />
</cfif>

<cfif isdefined("url.spreadSheet")>
    <cfset isSpreadsheet = true />
    <cfset structDelete(url, "spreadSheet") />
<cfelse>
    <cfset isSpreadsheet = false />
</cfif>

<!---
/endpoint.cfm?apiMicro=scheduler.data.companies&info=34&whatever=true
--->

<cfset exceptions = arrayNew(1) />
<cfset arrayAppend(exceptions, "contenttype") />
<cfset arrayAppend(exceptions, "apiMicro") />
<cfset arrayAppend(exceptions, "fieldnames") />

<cfset requestFormatter = createObject("component", "com.onassignment.portal.PortalRequestFormatter").init() />
<cfset portalBroker = createObject("component", "com.onassignment.portal.PortalRequestBroker").init() />

<cfif cgi.request_method eq "POST">
    <cfif getHTTPRequestData().headers["Content-Type"] eq "application/json">
        <cfset json = structNew() />
        <cfset json["requestBody"] = toString(getHTTPRequestData().content) />
        <cfset serviceRequest = requestFormatter.formatPost(url.apiMicro, json) />
    <cfelse>
        <cfset serviceRequest = requestFormatter.formatPost(url.apiMicro, form, exceptions) />
    </cfif>
<cfelseif cgi.request_method eq "GET">
    <cfset serviceRequest = requestFormatter.formatGet(url.apiMicro, url, exceptions) />
</cfif>

<cfset serviceResponseStruct = portalBroker.send(serviceRequest) />
<cfset bodyContent = serviceResponseStruct["content"] />
<cfset headers = serviceResponseStruct["headers"] />

<cfif not isSpreadsheet>
    <cfoutput>
        <cfloop list="#structKeyList(headers)#" index="key">
            <cfheader name="#key#" value="#headers[key]#" />
        </cfloop>
        <cfheader statuscode="#bodyContent['Status_Code']#" statustext="#bodyContent['Explanation']#" />
        #bodyContent["html_content"]#
    </cfoutput>
<cfelse>
    <cfset excelOutput = bodyContent["html_content"] />

    <cfoutput>
    <cfheader name="Content-Disposition" value="#headers['Content-Disposition']#" />
    <cfheader name="Content-Type" value="#headers['Content-Type']#" />
    <cfcontent variable="#excelOutput.toByteArray()#" />
    </cfoutput>
</cfif>