<cfcomponent 
	name="helper" 
	output="false" 
	hint="collection of anx helper functions" 
	extends="com.andreacfm.core.object">

<!---init--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" output="false" returntype="com.andreacfm.core.object">
		<cfreturn this />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---getMasterAssets--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getMasterAssets" output="false" returntype="struct">
		<cfargument name="nodeid" required="true" type="numeric" />
		<cfargument name="mode" required="false" type="numeric" default="2"/>
		
		<cfset var q = application.ancontent.nodeContent(arguments.nodeid,arguments.mode,"all")/> 
		<cfset var result = {masterLink = "",masterFile="",teaserImage=""} />

		<cfif q.recordcount gt 0>
			<cfif len(q.rvFile[1]) neq 0>
				<cfif findNoCase("/anlibasset/",q.rvFile[1]) eq 0>
					<cfset result.masterLink = "#application.virtualPaths.ANROOT#/index.cfm/3,#q.tNodeID[1]#,#q.cContentID[1]#/#q.rvFile[1]#"/>
					<cfset result.masterFile = q.rvFile[1]/>
				<cfelse>
					<cfset result.masterLink = "#application.virtualPaths.ANROOT#/index.cfm/8,#q.tNodeID[1]#,#q.cContentID[i]#,#listGetAt(q.rvFile[1],2,"/")#/#listLast(q.rvFile[1],"/")#"/>
					<cfset result.masterFile = listLast(q.rvFile[1],"/")/>									
				</cfif>
			</cfif>
			
			<cfif len(q.rvImage[1]) neq 0>
				<cfif findNoCase("/anlibimage",q.rvImage[1]) eq 0>
					<cfset result.teaserImage = "#application.virtualPaths.IMAGES#/content/#q.cContentID[1]#/#q.rvRevisionID[1]#/#q.rvImage[1]#"/>
				<cfelse>
					<cfset result.teaserImage = "#application.virtualPaths.IMAGES#/library/#listGetAt(q.rvImage[1],2,"/")#/#listLast(q.rvImage[1],"/")#"/>
				</cfif>
			</cfif>	
		</cfif>
		
		<cfreturn result />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---getCountryName--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getCountryName" output="false" returntype="string">
		<cfargument name="cyCountryId" required="true" type="numeric" />
		
		<cfset var result = "State #arguments.cyCountryId# not found!" />
		
		<cfquery name="q" datasource="#application.config.dsn#">
		Select cycountry
		From countries
		Where cyCountryID = #arguments.cyCountryId#
		</cfquery>
		
		<cfif q.recordcount eq 1>
			<cfset result = q.cycountry />
		</cfif>
		
		<cfreturn result />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---nodeStatus--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="nodeStatus" output="false" returntype="numeric">
		<cfargument name="nodeId" required="true" type="numeric">
		
			<cfset var qRead = "" />
			
			<cfquery datasource="#application.config.dsn#" name="qRead">
				SELECT tStatus
				FROM tree
				WHERE tNodeId = #arguments.nodeid#
			</cfquery>
		
		<cfreturn qRead.tStatus />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---moduleAccess--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="moduleAccess" output="false" returntype="boolean">
		<cfargument name="appid" required="false" default="#session.anmodule.appid#" type="numeric" />
		<cfargument name="userRoleIds" required="false" default="#session.anuser.userRoleIds#" type="string" />
		
		<cfset var highestRoleAdmitted = "" />
		<cfset var qRead = "" />
		<cfset var result = false />
		
		<cfquery name="qRead" datasource="#application.config.dsn#">
			SELECT rwrole_id as role
			FROM roles_webapplications
			WHERE rwwebapplication_id = #arguments.appid#
		</cfquery>
		
		<cfscript>
		
		 for(i = 0; i < len(arguments.userRoleIds);i++){
		 	if( i lte qRead.role){
		 		result = true;
		 		break;
		 	}
		 }
		
		return result;		
		</cfscript>		
		
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---libs--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="libs" output="false" returntype="any">
		<cfreturn application.libs />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---getConfigs--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getConfigs" output="false" returntype="any">
		<cfreturn application.config />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---getConfig--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getConfig" output="false" returntype="any">
		<cfargument name="str" required="true" type="string" />
		<cfreturn application.config[arguments.str] />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
	
<!---getVirtualPath--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getVirtualPath" output="false" returntype="string">
		<cfargument name="str" required="true" type="string" />
		<cfreturn application.virtualPaths[arguments.str] />		
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
	
</cfcomponent>