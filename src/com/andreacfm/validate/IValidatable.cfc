<cfinterface>

	<!---	validate	--->
	<cffunction name="validate" output="false" returntype="void" hint="Validate method called on an injected validator bean">
		<cfargument name="context" required="false" type="string" default="" />		

	</cffunction>

	<!--- isAlwaysValid --->
	<cffunction name="isAlwaysValid" output="false" returntype="boolean">

	</cffunction>
	
	<!---	skipValidation	--->
	<cffunction name="skipValidation" output="false" returntype="void">
		<cfargument name="value" type="boolean" required="true" />

	</cffunction>

	<!---	isValidObject	--->
	<cffunction name="isValidObject" output="false" returntype="boolean">

	</cffunction>

    <!---   errors   --->
	<cffunction name="geterrors" access="public" output="false" returntype="array">

	</cffunction>

	<cffunction name="seterrors" access="public" output="false" returntype="void">
		<cfargument name="errors" type="array" required="true"/>
	</cffunction>

	<!---  hasErrors  --->
	<cffunction name="hasErrors" output="false" returntype="boolean">
	</cffunction>
	
	<!--- resetErrors --->
	<cffunction name="resetErrors" returntype="void">	
	</cffunction>
		
	<!---  addError  --->
	<cffunction name="addError" output="false" returntype="void">
		<cfargument name="error" type="string" required="true" />
	</cffunction>

	<!---	validator	--->
	<cffunction name="getvalidator" access="public" output="false" returntype="com.andreacfm.validate.Validator">
	</cffunction>
	<cffunction name="setvalidator" access="public" output="false" returntype="void">
		<cfargument name="validator" type="com.andreacfm.validate.Validator" required="true"/>
	</cffunction>



</cfinterface>