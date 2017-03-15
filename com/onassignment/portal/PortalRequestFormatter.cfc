<cfcomponent>
    <cffunction name="init" access="public" returntype="com.onassignment.portal.PortalRequestFormatter">
        <cfreturn this />
    </cffunction>

    <cffunction name="formatTransaction" access="public" returntype="string">
        <cfargument name="apiPath" type="string" required="true" />

        <cfset var formattedPath = "/" & replaceNoCase(arguments.apiPath, ".", "/", "ALL") />

        <cfreturn formattedPath />
    </cffunction>

    <cffunction name="formatPost" access="public" returntype="any">
        <cfargument name="transaction" type="string" required="true" />
        <cfargument name="parameters" type="struct" required="true" />
        <cfargument name="exceptions" type="array" required="false" default="#arrayNew(1)#" />

        <cfset var serviceRequest = formatGeneric(arguments.transaction, arguments.parameters, arguments.exceptions) />
        <cfset serviceRequest["method"] = "POST" />

        <cfreturn serviceRequest />
    </cffunction>

    <cffunction name="formatGet" access="public" returntype="struct">
        <cfargument name="transaction" type="string" required="true" />
        <cfargument name="parameters" type="struct" required="true" />
        <cfargument name="exceptions" type="array" required="false" default="#arrayNew(1)#" />

        <cfset var serviceRequest = formatGeneric(arguments.transaction, arguments.parameters, arguments.exceptions) />
        <cfset serviceRequest["method"] = "GET" />

        <cfreturn serviceRequest />
    </cffunction>

    <cffunction name="formatGeneric" access="public" returntype="struct">
        <cfargument name="transaction" type="string" required="true" />
        <cfargument name="parameters" type="struct" required="true" />
        <cfargument name="exceptions" type="array" required="false" default="#arrayNew(1)#" />

        <cfset var endpoint = formatTransaction(arguments.transaction) />
        <cfset var requestParameters = paramStripper(arguments.parameters, arguments.exceptions) />
        <cfset var serviceRequest = structNew() />

        <cfset serviceRequest["endPoint"] = endPoint />
        <cfset serviceRequest["parameters"] = requestParameters />

        <cfreturn serviceRequest />
    </cffunction>

    <cffunction name="paramStripper" access="private" returntype="struct">
        <cfargument name="parameters" type="struct" required="true" />
        <cfargument name="exceptions" type="array" required="false" default="#arrayNew(1)#" />

        <cfset var requestStruct = arguments.parameters />

        <cfif arrayLen(arguments.exceptions)>
            <cfloop array="#arguments.exceptions#" index="key">
                <cfset structDelete(requestStruct, key) />
            </cfloop>
        </cfif>

        <cfreturn requestStruct />
    </cffunction>


</cfcomponent>