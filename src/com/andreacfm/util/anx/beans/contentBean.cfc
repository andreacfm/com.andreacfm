<cfcomponent 
	output="false" 
	name="Anx Content bean" 
	extends="cfops.core.bean">

	<cfproperty name="cContentId" type="numeric"/>
	<cfproperty name="rvBody" type="string"/>
	<cfproperty name="rvFile" type="string"/>
	<cfproperty name="rvImage" type="string"/>
	<cfproperty name="rvRevisionId" type="numeric"/>
	<cfproperty name="rvTeaser" type="string"/>
	<cfproperty name="rvTitle" type="string"/>
	<cfproperty name="tnodeid" type="numeric"/>
	<cfproperty name="tlanguage" type="string"/>
	
<!---------------------------CONSTRUCTOR------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="cfops.core.bean">
		<cfreturn this/>	
	</cffunction>

<!---cContentId--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getcContentId" access="public" output="false" returntype="numeric">
		<cfreturn variables.cContentId/>
	</cffunction>
	<cffunction name="setcContentId" access="public" output="false" returntype="void">
		<cfargument name="cContentId" type="numeric" required="true"/>
		<cfset variables.cContentId = arguments.cContentId/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---rvBody--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getrvBody" access="public" output="false" returntype="string">
		<cfreturn variables.rvBody/>
	</cffunction>
	<cffunction name="setrvBody" access="public" output="false" returntype="void">
		<cfargument name="rvBody" type="string" required="true"/>
		<cfset variables.rvBody = arguments.rvBody/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---rvFile--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getrvFile" access="public" output="false" returntype="string">
		<cfreturn variables.rvFile/>
	</cffunction>
	<cffunction name="setrvFile" access="public" output="false" returntype="void">
		<cfargument name="rvFile" type="string" required="true"/>
		<cfset variables.rvFile = arguments.rvFile/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---rvImage--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getrvImage" access="public" output="false" returntype="string">
		<cfreturn variables.rvImage/>
	</cffunction>
	<cffunction name="setrvImage" access="public" output="false" returntype="void">
		<cfargument name="rvImage" type="string" required="true"/>
		<cfset variables.rvImage = arguments.rvImage/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---rvRevisionId--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getrvRevisionId" access="public" output="false" returntype="numeric">
		<cfreturn variables.rvRevisionId/>
	</cffunction>
	<cffunction name="setrvRevisionId" access="public" output="false" returntype="void">
		<cfargument name="rvRevisionId" type="numeric" required="true"/>
		<cfset variables.rvRevisionId = arguments.rvRevisionId/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---rvTeaser--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getrvTeaser" access="public" output="false" returntype="string">
		<cfreturn variables.rvTeaser/>
	</cffunction>
	<cffunction name="setrvTeaser" access="public" output="false" returntype="void">
		<cfargument name="rvTeaser" type="string" required="true"/>
		<cfset variables.rvTeaser = arguments.rvTeaser/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---rvTitle--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getrvTitle" access="public" output="false" returntype="string">
		<cfreturn variables.rvTitle/>
	</cffunction>
	<cffunction name="setrvTitle" access="public" output="false" returntype="void">
		<cfargument name="rvTitle" type="string" required="true"/>
		<cfset variables.rvTitle = arguments.rvTitle/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---tnodeid--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="gettnodeid" access="public" output="false" returntype="numeric">
		<cfreturn variables.tnodeid/>
	</cffunction>
	<cffunction name="settnodeid" access="public" output="false" returntype="void">
		<cfargument name="tnodeid" type="numeric" required="true"/>
		<cfset variables.tnodeid = arguments.tnodeid/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---tlanguage--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="gettlanguage" access="public" output="false" returntype="string">
		<cfreturn getFacade().getObject('anxhelper').libs().getLocaleCode(variables.tlanguage)/>
	</cffunction>
	<cffunction name="settlanguage" access="public" output="false" returntype="void">
		<cfargument name="tlanguage" type="string" required="true"/>		
		<cfset variables.tlanguage = arguments.tlanguage />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

</cfcomponent>