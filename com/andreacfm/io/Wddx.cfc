<cfcomponent 
	name="wddx"
	output="false" 
	extends="com.andreacfm.core.object">

	<cfproperty name="fileRoot" type="string"/>

	<cfset variables.fileRoot = "/" />
	
<!---init--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="init" output="false" returntype="com.andreacfm.core.object">
		<cfargument name="fileRoot" type="string" required="false" default="/" />

		<cfset variables.fileRoot = fileRoot />	

		<cfreturn this />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->

<!---write--->
<!--------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="write" access="public" returntype="com.andreacfm.utils.message" >
  		<cfargument name="obj"type="any" required="yes">
  		
		<cfset var WddxPacket="">
		<cfset var result = createObject('component','com.andreacfm.utils.message').init() />
  		
		<cftry>
			
			<cfwddx action="cfml2wddx"input="#arguments.obj#"output="WddxPacket">
  			<cffile action="WRITE"file="#getFileRoot()#"output="#WddxPacket#">
			
			<cfcatch type="any">
				<cfset result.setStatus(false) />
				<cfset result.setType('error') />
				<cfset result.setText(cfcatch.Message) />
			</cfcatch>
		
		</cftry>
		
		<cfreturn result />
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->	

<!---read--->
<!--------------------------------------------------------------------------------------------------------------------->	
	<cffunction name="read" access="public" returntype="com.andreacfm.utils.message">

		<cfset var result = createObject('component','com.andreacfm.utils.message').init() />
		<cfset var data = "" />
 		<cfset var WddxPacket="" />
 
		<cftry>

			 <cffile action="read"file="#getFileRoot()#"variable="WddxPacket">    
 			 <cfwddx action="wddx2cfml" input="#WddxPacket#" output="data">
			 <cfset result.setData(data) />

			<cfcatch type="any">
				<cfset result.setStatus(false) />
				<cfset result.setType('error') />
				<cfset result.setText(cfcatch.Message) />
			</cfcatch>
		
		</cftry>	 	
    
  <cfreturn result>  
</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->	

<!---fileRoot--->
<!--------------------------------------------------------------------------------------------------------------------->
	<cffunction name="getfileRoot" access="public" output="false" returntype="string">
		<cfreturn variables.fileRoot/>
	</cffunction>
	<cffunction name="setfileRoot" access="public" output="false" returntype="void">
		<cfargument name="fileRoot" type="string" required="true"/>
		<cfset variables.fileRoot = arguments.fileRoot/>
	</cffunction>
<!--------------------------------------------------------------------------------------------------------------------->
	
</cfcomponent>