<cfcomponent>
    <cffunction name="init" access="public" returntype="com.onassignment.portal.PortalGateway">
        <cfset variables.clientId = "recruitmax-ats-01" />
        <cfset variables.clientSecret = "9de682ef-04d1-4a9c-a488-fb1155d43cab" />
        <cfset variables.oxfordMicroApiPath = REQUEST.oxfordMicroservicesApiDomain />

        <cfreturn this />
    </cffunction>

    <cffunction name="getBearerTokenHeader" access="public" returntype="string">
        <cfset var bearerToken = getBearerToken() />
        <cfset var bearerTokenHeader = "Bearer " & trim(bearerToken) />

        <cfreturn bearerTokenHeader />
    </cffunction>

    <cffunction name="getMicroservicesPath" access="public" returntype="string">
        <cfargument name="path" type="string" required="true" />

        <cfreturn variables.oxfordMicroApiPath & arguments.path />
    </cffunction>

    <cffunction name="getBearerToken" access="public" returntype="string">
        <cfif not isDefined("application.publicPortalToken")>
            <cfreturn requestBearerToken() />
        </cfif>

        <cfif not tokenValid()>
            <cfreturn requestBearerToken() />
        </cfif>

        <cfreturn readBearerToken() />
    </cffunction>

    <cffunction name="readBearerToken" access="private" returntype="string">
        <cfset var token = "" />

        <cflock name="portalAccessToken" type="readonly" timeout="5" throwOnTimeout="yes">
            <cfset token = application.publicPortalToken />
        </cflock>

        <cfreturn token />
    </cffunction>

    <cffunction name="tokenValid" access="private" returntype="boolean">
        <cfset var endPoint = "/oauth/check_token" />
        <cfset var path = variables.oxfordMicroApiPath & endPoint />
        <cfset var jsonResponse = "" />
        <cfset var token = readBearerToken() />

        <cfif isDefined("application.publicPortalToken")>
            <cfhttp url="#path#" method="get">
                <cfhttpparam type="formfield" name="token" value="#token#" />
            </cfhttp>

            <cfset jsonResponse = deserializeJSON(cfhttp.fileContent) />

            <cfif not structKeyExists(jsonResponse, "error") AND structKeyExists(jsonResponse, "client_id") AND jsonResponse["client_id"] eq variables.clientId>
                <cfreturn true />
            </cfif>

        </cfif>

        <cfreturn false />
    </cffunction>

    <cffunction name="writeBearerToken" access="private" returntype="void">
        <cfargument name="tokenString" type="string" required="true" />

        <cflock name="portalAccessToken" type="exclusive" timeout="5" throwOnTimeout="yes">
            <cfset application.publicPortalToken = trim(arguments.tokenString) />
        </cflock>
    </cffunction>

    <cffunction name="requestBearerToken" access="private" returntype="string">
        <cfset var authStringHeader = "Basic: " />
        <cfset var authString = "" />
        <cfset var endPoint = "/oauth/token?grant_type=client_credentials" />
        <cfset var path = variables.oxfordMicroApiPath & endPoint />
        <cfset var jsonResponse = "" />
        <cfset var tokenString = "" />

        <cfset authString = authString & variables.clientId />
        <cfset authString = authString & ":" />
        <cfset authString = authString & variables.clientSecret />
        <cfset authString = "Basic " & toBase64(authString, "utf-8") />

        <cfhttp url="#path#" method="post">
            <cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded" />
            <cfhttpparam type="header" name="Authorization" value="#authString#" />
        </cfhttp>

        <cfset jsonResponse = deserializeJSON(cfhttp.fileContent) />

        <cfif not structKeyExists(jsonResponse, "access_token")>
            <cfset tokenString = "ERROR" />
        <cfelse>
            <cfset tokenString = jsonResponse["access_token"] />
        </cfif>

        <cfset writeBearerToken(tokenString) />

        <cfreturn tokenString />
    </cffunction>

</cfcomponent>