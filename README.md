# microservicesbroker
A ColdFusion interface for connecting with Oxford Microservices via Recruitmax.

To run this locally, be sure to manually add the following Application.cfm to simulate the Recruitmax environment variables:

---

```
<!--- NOTE: for DEV only, include the variable on line 4 in the Rmax Application.cfm --->
<cfapplication name="microservicesbroker" />

<!--- Edit this to suit your environment --->
<cfset REQUEST.oxfordMicroservicesApiDomain = "http://localhost:9002" />
```
