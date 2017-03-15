<cfcomponent>
    <cffunction name="init" access="public" returntype="com.onassignment.portal.PortalRequestBroker">
        <cfset variables.gateway = createObject("component", "com.onassignment.portal.PortalGateway").init() />
        <cfreturn this />
    </cffunction>

    <cffunction name="send" access="public" returntype="struct">
        <cfargument name="serviceRequest" type="struct" required="true" />

        <cfset var method = arguments.serviceRequest["method"] />
        <cfset var endPoint = arguments.serviceRequest["endPoint"] />
        <cfset var parameters = arguments.serviceRequest["parameters"] />
        <cfset var httpContent = "" />

        <cfif method eq "POST" AND structKeyExists(parameters, "requestBody")>
            <cfset httpContent = broadcastJson(endPoint, parameters["requestBody"]) />
        <cfelse>
            <cfset httpContent = broadcast(method, endPoint, parameters) />
        </cfif>

        <cfreturn responseFormatter(httpContent) />
    </cffunction>

    <cffunction name="broadcast" access="private" returntype="struct">
        <cfargument name="method" type="string" required="true" />
        <cfargument name="endPoint" type="string" required="true" />
        <cfargument name="parameters" type="struct" required="true" />

        <cfset var bearerToken = variables.gateway.getBearerTokenHeader() />

        <cfhttp url="#variables.gateway.getMicroservicesPath(arguments.endPoint)#" method="#method#">
            <cfhttpparam type="header" name="Authorization" value="#bearerToken#" />

            <cfif listLen(structKeyList(parameters))>
                <cfloop list="#structKeyList(parameters)#" index="key">
                    <cfhttpparam type="formfield" name="#key#" value="#parameters[key]#" />
                </cfloop>
            </cfif>
        </cfhttp>

        <cfreturn cfhttp />
    </cffunction>

    <cffunction name="broadcastJson" access="private" returntype="struct">
        <cfargument name="endPoint" type="string" required="true" />
        <cfargument name="json" type="string" required="true" />

        <cfset var bearerToken = variables.gateway.getBearerTokenHeader() />

        <cfhttp url="#variables.gateway.getMicroservicesPath(arguments.endPoint)#" method="post">
            <cfhttpparam type="header" name="Authorization" value="#bearerToken#" />
            <cfhttpparam type="header" name="Content-Type" value="application/json" />
            <cfhttpparam type="body" value="#json#" />
        </cfhttp>

        <cfreturn cfhttp />
    </cffunction>

    <cffunction name="responseFormatter" access="private" returntype="struct">
        <cfargument name="httpResponse" type="struct" required="true" />

        <cfset var formattedResponse = structNew() />
        <cfset var responseHeader = arguments.httpResponse["Responseheader"] />

        <!--- <cfdump var="#responseHeader#" /><cfabort /> --->

        <cfset formattedResponse["content"] = structNew() />
        <cfset formattedResponse["headers"] = structNew() />

        <cfset formattedResponse["headers"]["Access-Control-Allow-Origin"] = responseHeader["Access-Control-Allow-Origin"] />
        <cfset formattedResponse["headers"]["Date"] = responseHeader["Date"] />
        <cfset formattedResponse["headers"]["Http_Version"] = responseHeader["Http_Version"] />

        <cfif structKeyExists(responseHeader, "Content-disposition")>
            <cfset formattedResponse["headers"]["Content-disposition"] = responseHeader["Content-disposition"] />
        </cfif>
        <cfif structKeyExists(responseHeader, "Content-Type")>
            <cfset formattedResponse["headers"]["Content-Type"] = responseHeader["Content-Type"] />
        </cfif>
        <cfif structKeyExists(responseHeader, "Transfer-Encoding")>
            <cfset formattedResponse["headers"]["Transfer-Encoding"] = responseHeader["Transfer-Encoding"] />
        </cfif>

        <cfset formattedResponse["content"]["html_content"] = httpResponse.fileContent />
        <cfset formattedResponse["content"]["Explanation"] = responseHeader["Explanation"] />
        <cfset formattedResponse["content"]["Status_Code"] = responseHeader["Status_Code"] />

        <cfreturn formattedResponse />
    </cffunction>
</cfcomponent>