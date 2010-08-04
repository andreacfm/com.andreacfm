<cfcomponent 
	output="false" 
	name="Anx User bean" 
	extends="cfops.core.bean">

<cfproperty name="uUserId" type="numeric"/>
<cfproperty name="uIdentifier" type="UUID"/>
<cfproperty name="uUsername" type="string"/>
<cfproperty name="uPassword" type="string"/>
<cfproperty name="uTitle" type="string"/>
<cfproperty name="uFirstname" type="string"/>
<cfproperty name="uLastName" type="string"/>
<cfproperty name="uAlias" type="string"/>
<cfproperty name="uCompany" type="string"/>
<cfproperty name="uPosition" type="string"/>
<cfproperty name="uAddress1" type="string"/>
<cfproperty name="uAddress2" type="string"/>
<cfproperty name="uCity" type="string"/>
<cfproperty name="uPostalCode" type="string"/>
<cfproperty name="uState" type="string"/>
<cfproperty name="uPhone" type="string"/>
<cfproperty name="uMobile" type="string"/>
<cfproperty name="uFax" type="string"/>
<cfproperty name="uEmail" type="string"/>
<cfproperty name="uLanguage" type="string"/>
<cfproperty name="uOptions" type="string"/>
<cfproperty name="uStatus" type="numeric"/>
<cfproperty name="uNotify" type="numeric"/>
<cfproperty name="uAccessCount" type="numeric"/>
<cfproperty name="uTScreated" type="date"/>
<cfproperty name="uTSUpdated" type="date"/>
<cfproperty name="uTSLastaccess" type="sate"/>
<cfproperty name="uCountry_id" type="numeric"/>


<!---------------------------CONSTRUCTOR------------------------------------------------------->
	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.core.bean">
		<cfreturn this/>	
	</cffunction>
<!--------------------------------------------------------------------------------------------->

<!---uUserId--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuUserId" access="public" output="false" returntype="numeric">
		<cfreturn variables.uUserId/>
	</cffunction>
	<cffunction name="setuUserId" access="public" output="false" returntype="void">
		<cfargument name="uUserId" type="numeric" required="true"/>
		<cfset variables.uUserId = arguments.uUserId/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uIdentifier--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuIdentifier" access="public" output="false" returntype="UUID">
		<cfreturn variables.uIdentifier/>
	</cffunction>
	<cffunction name="setuIdentifier" access="public" output="false" returntype="void">
		<cfargument name="uIdentifier" type="UUID" required="true"/>
		<cfset variables.uIdentifier = arguments.uIdentifier/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uUsername--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuUsername" access="public" output="false" returntype="string">
		<cfreturn variables.uUsername/>
	</cffunction>
	<cffunction name="setuUsername" access="public" output="false" returntype="void">
		<cfargument name="uUsername" type="string" required="true"/>
		<cfset variables.uUsername = arguments.uUsername/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uPassword--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuPassword" access="public" output="false" returntype="string">
		<cfreturn variables.uPassword/>
	</cffunction>
	<cffunction name="setuPassword" access="public" output="false" returntype="void">
		<cfargument name="uPassword" type="string" required="true"/>
		<cfset variables.uPassword = arguments.uPassword/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uTitle--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuTitle" access="public" output="false" returntype="string">
		<cfreturn variables.uTitle/>
	</cffunction>
	<cffunction name="setuTitle" access="public" output="false" returntype="void">
		<cfargument name="uTitle" type="string" required="true"/>
		<cfset variables.uTitle = arguments.uTitle/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uFirstname--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuFirstname" access="public" output="false" returntype="string">
		<cfreturn variables.uFirstname/>
	</cffunction>
	<cffunction name="setuFirstname" access="public" output="false" returntype="void">
		<cfargument name="uFirstname" type="string" required="true"/>
		<cfset variables.uFirstname = arguments.uFirstname/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uLastName--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuLastName" access="public" output="false" returntype="string">
		<cfreturn variables.uLastName/>
	</cffunction>
	<cffunction name="setuLastName" access="public" output="false" returntype="void">
		<cfargument name="uLastName" type="string" required="true"/>
		<cfset variables.uLastName = arguments.uLastName/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uAlias--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuAlias" access="public" output="false" returntype="string">
		<cfreturn variables.uAlias/>
	</cffunction>
	<cffunction name="setuAlias" access="public" output="false" returntype="void">
		<cfargument name="uAlias" type="string" required="true"/>
		<cfset variables.uAlias = arguments.uAlias/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uCompany--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuCompany" access="public" output="false" returntype="string">
		<cfreturn variables.uCompany/>
	</cffunction>
	<cffunction name="setuCompany" access="public" output="false" returntype="void">
		<cfargument name="uCompany" type="string" required="true"/>
		<cfset variables.uCompany = arguments.uCompany/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uPosition--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuPosition" access="public" output="false" returntype="string">
		<cfreturn variables.uPosition/>
	</cffunction>
	<cffunction name="setuPosition" access="public" output="false" returntype="void">
		<cfargument name="uPosition" type="string" required="true"/>
		<cfset variables.uPosition = arguments.uPosition/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uAddress1--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuAddress1" access="public" output="false" returntype="string">
		<cfreturn variables.uAddress1/>
	</cffunction>
	<cffunction name="setuAddress1" access="public" output="false" returntype="void">
		<cfargument name="uAddress1" type="string" required="true"/>
		<cfset variables.uAddress1 = arguments.uAddress1/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uAddress2--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuAddress2" access="public" output="false" returntype="string">
		<cfreturn variables.uAddress2/>
	</cffunction>
	<cffunction name="setuAddress2" access="public" output="false" returntype="void">
		<cfargument name="uAddress2" type="string" required="true"/>
		<cfset variables.uAddress2 = arguments.uAddress2/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uCity--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuCity" access="public" output="false" returntype="string">
		<cfreturn variables.uCity/>
	</cffunction>
	<cffunction name="setuCity" access="public" output="false" returntype="void">
		<cfargument name="uCity" type="string" required="true"/>
		<cfset variables.uCity = arguments.uCity/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uPostalCode--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuPostalCode" access="public" output="false" returntype="string">
		<cfreturn variables.uPostalCode/>
	</cffunction>
	<cffunction name="setuPostalCode" access="public" output="false" returntype="void">
		<cfargument name="uPostalCode" type="string" required="true"/>
		<cfset variables.uPostalCode = arguments.uPostalCode/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uState--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuState" access="public" output="false" returntype="string">
		<cfreturn variables.uState/>
	</cffunction>
	<cffunction name="setuState" access="public" output="false" returntype="void">
		<cfargument name="uState" type="string" required="true"/>
		<cfset variables.uState = arguments.uState/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uPhone--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuPhone" access="public" output="false" returntype="string">
		<cfreturn variables.uPhone/>
	</cffunction>
	<cffunction name="setuPhone" access="public" output="false" returntype="void">
		<cfargument name="uPhone" type="string" required="true"/>
		<cfset variables.uPhone = arguments.uPhone/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uMobile--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuMobile" access="public" output="false" returntype="string">
		<cfreturn variables.uMobile/>
	</cffunction>
	<cffunction name="setuMobile" access="public" output="false" returntype="void">
		<cfargument name="uMobile" type="string" required="true"/>
		<cfset variables.uMobile = arguments.uMobile/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uFax--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuFax" access="public" output="false" returntype="string">
		<cfreturn variables.uFax/>
	</cffunction>
	<cffunction name="setuFax" access="public" output="false" returntype="void">
		<cfargument name="uFax" type="string" required="true"/>
		<cfset variables.uFax = arguments.uFax/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uEmail--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuEmail" access="public" output="false" returntype="string">
		<cfreturn variables.uEmail/>
	</cffunction>
	<cffunction name="setuEmail" access="public" output="false" returntype="void">
		<cfargument name="uEmail" type="string" required="true"/>
		<cfset variables.uEmail = arguments.uEmail/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uLanguage--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuLanguage" access="public" output="false" returntype="string">
		<cfreturn variables.uLanguage/>
	</cffunction>
	<cffunction name="setuLanguage" access="public" output="false" returntype="void">
		<cfargument name="uLanguage" type="string" required="true"/>
		<cfset variables.uLanguage = arguments.uLanguage/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uOptions--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuOptions" access="public" output="false" returntype="string">
		<cfreturn variables.uOptions/>
	</cffunction>
	<cffunction name="setuOptions" access="public" output="false" returntype="void">
		<cfargument name="uOptions" type="string" required="true"/>
		<cfset variables.uOptions = arguments.uOptions/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uStatus--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuStatus" access="public" output="false" returntype="numeric">
		<cfreturn variables.uStatus/>
	</cffunction>
	<cffunction name="setuStatus" access="public" output="false" returntype="void">
		<cfargument name="uStatus" type="numeric" required="true"/>
		<cfset variables.uStatus = arguments.uStatus/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uNotify--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuNotify" access="public" output="false" returntype="numeric">
		<cfreturn variables.uNotify/>
	</cffunction>
	<cffunction name="setuNotify" access="public" output="false" returntype="void">
		<cfargument name="uNotify" type="numeric" required="true"/>
		<cfset variables.uNotify = arguments.uNotify/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uAccessCount--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuAccessCount" access="public" output="false" returntype="numeric">
		<cfreturn variables.uAccessCount/>
	</cffunction>
	<cffunction name="setuAccessCount" access="public" output="false" returntype="void">
		<cfargument name="uAccessCount" type="numeric" required="true"/>
		<cfset variables.uAccessCount = arguments.uAccessCount/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uTScreated--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuTScreated" access="public" output="false" returntype="date">
		<cfreturn variables.uTScreated/>
	</cffunction>
	<cffunction name="setuTScreated" access="public" output="false" returntype="void">
		<cfargument name="uTScreated" type="date" required="true"/>
		<cfset variables.uTScreated = arguments.uTScreated/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uTSUpdated--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuTSUpdated" access="public" output="false" returntype="date">
		<cfreturn variables.uTSUpdated/>
	</cffunction>
	<cffunction name="setuTSUpdated" access="public" output="false" returntype="void">
		<cfargument name="uTSUpdated" type="date" required="true"/>
		<cfset variables.uTSUpdated = arguments.uTSUpdated/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uTSLastaccess--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuTSLastaccess" access="public" output="false" returntype="date">
		<cfreturn variables.uTSLastaccess/>
	</cffunction>
	<cffunction name="setuTSLastaccess" access="public" output="false" returntype="void">
		<cfargument name="uTSLastaccess" type="date" required="true"/>
		<cfset variables.uTSLastaccess = arguments.uTSLastaccess/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---uCountry_id--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getuCountry_id" access="public" output="false" returntype="numeric">
		<cfreturn variables.uCountry_id/>
	</cffunction>
	<cffunction name="setuCountry_id" access="public" output="false" returntype="void">
		<cfargument name="uCountry_id" type="numeric" required="true"/>
		<cfset variables.uCountry_id = arguments.uCountry_id/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

</cfcomponent>
