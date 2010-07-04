<cfcomponent extends="mxunit.framework.TestCase">
	
	<cfset variables.testpath = '/com/andreacfm/logging/logs' />
	
	<cffunction name="setUp">
		<cfdirectory action="create" directory="#expandPath(variables.testpath)#" />
	</cffunction>
	
	<cffunction name="tearDown">
		<cfdirectory action="delete" directory="#expandPath(variables.testpath)#" recurse="true"/>
	</cffunction>
		
	<cffunction name="test_append_basic" returntype="void" hint="log an error catch struct">
		<cfset var path = variables.testpath & '/test1.log'/>
		<cfset var logger = createObject('component','com.andreacfm.logging.Logger').init('mylogger',path) />
		<cfset var logStruct = ""/>
		
		<cftry>
			<cfset a = b />
			<cfcatch type="any">
				<cfset logger.append(cfcatch,'synch') />
			</cfcatch>
		</cftry>
				
		<cfset assertTrue(fileExists(expandpath(path)),'log file has not been craeted') />
		
		<cfset logStruct = logger.readLog() />
		<cfset assertTrue(arraylen(logStruct) eq 1,'Log file have #arraylen(logStruct)# lines in place of 2.') />
			
	</cffunction>
	
	<cffunction name="testSchema" returntype="void" hint="test a custom schema">
		<cfset var path = variables.testpath & '/test1.log'/>
		<cfset var schema = 'name,phone,age' />
		<cfset var logger = createObject('component','com.andreacfm.logging.Logger').init('mylogger',path,schema) />		
		<cfset var logArray = ""/>
		<cfset var str = {} />
		
		
		<cfset str['name'] = 'andrea' />
		<cfset str['phone'] = 555 />
		<cfset str['age'] = 35 />
		<cfset logger.append(str) />	
		
		<!--- check log has been created --->
		<cfset assertTrue(fileExists(expandpath(path)),'log file has not been craeted') />
		
		<!--- read the file --->
		<cfset logArray = logger.readLog() />
		<cfset assertTrue(logArray[1].name eq 'andrea' and logArray[1].phone eq 555 and logArray[1].age eq 35,'Data logged incorrectly') />

		<!---log again --->
		<cfset str['name'] = 'luigi' />
		<cfset str['phone'] = 444 />
		<cfset str['age'] = 44 />

		<cfset logger.append(str) />
		<!--- read the file --->
		<cfset logArray = logger.readLog() />
		
		<cfset assertTrue(logArray[2].name eq 'luigi' and logArray[2].phone eq 444 and logArray[2].age eq 44,'Data logged incorrectly') />			
					
	</cffunction>	

	<cffunction name="test_do_archive_when_oversize" returntype="void">
		<cfset var path = variables.testpath & '/test.log'/>
		<cfset var zippath = variables.testpath & '/test.zip'/>
		<cfset var zippath_1 = variables.testpath & '/test_1.zip'/>
		<cfset var logger = createObject('component','com.andreacfm.logging.Logger').init(id = 'mylogger', filePath = path, maxSize = '10000') />
		<cfset var logStruct = ""/>

		<!--- add 100 lines --->
		<cfloop from="1" to="200" index="i">
		<cftry>
			<cfset a = b />
			<cfcatch type="any">
				<cfset logger.append(cfcatch,'synch') />
			</cfcatch>
		</cftry>
		</cfloop>

		<!--- zipfile exists --->		
		<cfset assertTrue(fileExists(expandpath(zippath)),'zip file has not been craeted') />		
		<!--- zipfile _1 exists --->		
		<cfset assertTrue(fileExists(expandpath(zippath_1)),'zip file has not been craeted') />		
		<!--- file exists --->		
		<cfset assertTrue(fileExists(expandpath(path)),'new log file ( after zip ) has not been craeted') />
					
	</cffunction>	

	
</cfcomponent>