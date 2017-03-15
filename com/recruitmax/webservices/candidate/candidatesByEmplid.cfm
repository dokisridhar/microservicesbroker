<cfprocessingdirective pageEncoding="utf-8" />
<cfsetting enablecfoutputonly="true" showdebugoutput="false" />
<cfset url.contenttype = "application/json" />

<cfset requestContentType = getHTTPRequestData().headers["Content-Type"] />

<cfif cgi.request_method eq "POST">
    <cfif requestContentType eq "application/json">
        <cfset jsonString = toString(getHTTPRequestData().content) />
        <cfset json = deserializeJSON(jsonString) />

        <!--- TODO: Implement an actual Recruitmax based solution here --->
        <cfset fakeArray = arrayNew(1) />

        <cfset firstNameArray = arrayNew(1) />
        <cfset lastNameArray = arrayNew(1) />
        <cfset arrayAppend(firstNameArray, "Brian") />
        <cfset arrayAppend(firstNameArray, "PJ") />
        <cfset arrayAppend(firstNameArray, "Erich") />
        <cfset arrayAppend(firstNameArray, "Mike") />
        <cfset arrayAppend(firstNameArray, "James") />
        <cfset arrayAppend(firstNameArray, "Phil") />
        <cfset arrayAppend(firstNameArray, "Your Mom") />
        <cfset arrayAppend(lastNameArray, "Carr") />
        <cfset arrayAppend(lastNameArray, "Metzger") />
        <cfset arrayAppend(lastNameArray, "Haemmerle") />
        <cfset arrayAppend(lastNameArray, "Chandler") />
        <cfset arrayAppend(lastNameArray, "Johnson") />
        <cfset arrayAppend(lastNameArray, "Jackson") />
        <cfset arrayAppend(lastNameArray, "Is Hot") />

        <cfloop array="#json#" index="myNode">
            <cfset fakeStruct = structNew() />
            <cfset fakeStruct["emplId"] = myNode["_id"] />
            <cfset fakeStruct["rmaxId"] = RandRange(30002312, 39890267) />
            <cfset fakeStruct["fullName"] = firstNameArray[RandRange(1,7)] & " " & lastNameArray[RandRange(1,7)] />
            <cfset arrayAppend(fakeArray, fakeStruct) />
        </cfloop>
        <!--- TODO: END of fake Recruitmax response --->

        <cfset finalJson = serializeJSON(fakeArray) />

        <cfheader name="Content-Type" value="application/json" />
        <cfoutput>#finalJson#</cfoutput>

    <cfelse>
        <cfthrow type="NoPayload" message="A JSON Payload was expected but not found." />
    </cfif>
<cfelse>
    <cfthrow type="MethodNotSupported" message="The POST method is required for this end point." />
</cfif>