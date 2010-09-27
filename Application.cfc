<cfcomponent output="false">

<cfset this.path = expandPath('/andreacfm')>
<cfset this.name = "#this.path#">
	
<cfset this.mappings = {
	com = this.path & '/com/'
}>	

</cfcomponent>