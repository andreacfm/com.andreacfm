<cfcomponent
 name="Logger"
 output="false"
 extends="com.andreacfm.Object">
	
	<!---init--->
	<cffunction name="init" output="false" returntype="com.andreacfm.logging.Logger">
		<cfargument name="id" required="true" type="string"/>
		<cfargument name="filePath" required="true" type="string"/>
		<cfargument name="schema" required="false" type="string" default="type,message,detail,NativeErrorCode,SQLState,Sql,queryError,where,ErrNumber,missingFileName,LockName,LockOperation,ErrorCode,ExtendedInfo"/>
		<cfargument name="mailer" required="false" type="any" default="" />
		<cfargument name="charset" required="false" type="string" default="UTF-8" />
		<cfargument name="maxSize" required="false" type="numeric" default="10485760" />
		<!--- If on test mode append a note  --->
		<cfargument name="testmode" required="false" type="boolean" default="false" />
		
		<cfscript>		
		variables.FilePath = arguments.filePath;
		variables.id = arguments.id;
		variables.fileObj = createObject('java','java.io.File').init(getFilePath());
		setmaxSize(arguments.maxSize);
		setSchema(arguments.schema);
		setMailer(arguments.mailer);
		setCharset(arguments.charset);
		setTestMode(arguments.testMode);
		return this;
		</cfscript>

	</cffunction>

	<!-----------------------------------------	PUBLIC 	------------------------------------------------------------------->

	<!--- append --->
	<cffunction name="append" output="false" returntype="void">
		<cfargument name="values" required="true" type="struct"/>
		<cfargument name="mode" required="false" type="string" default="async"/><!--- sync / async --->
		
		<cfset var str = {} />
		<cfset var mailer = getmailer() />
		<cfset var schema = getschema() />
		<cfset var abPath = getFilePath() />
		
		<cfloop collection="#values#" item="key">
			<cfif isSimpleValue(values[key])>
				<cfset str[key] = values[key] />
			</cfif>
		</cfloop>
		
		<!--- if the file do not exists craete it --->
		<cfscript>
			if(not fileExists(abPath)){						
				doFile();
			}	
		</cfscript>

		<!--- Monthly Zip --->
		<cfif getSize() gt getmaxSize()>
			<cfset doZipFile() />
			<cfset doFile() />		
		</cfif>

		<cfif arguments.mode eq 'asynch'>
			<cfset handleLog(str) />
		<cfelse>
			<cfset processLog(str) />	
		</cfif>

		<cfif isInstanceOf(mailer,'com.andreacfm.net.Mailer')>			
			<cfsavecontent variable="html">
				<cfoutput><cfdump var="#str#"></cfoutput>
			</cfsavecontent>
			<cfset mail = mailer.send(subject = 'log report - #cgi.HTTP_HOST#', html = html) />				
		</cfif>

	</cffunction>

	<!---readLog--->
	<cffunction name="readLog" output="true" returntype="any">
		<cfargument name="format" required="false" default="array" type="string"><!--- array or html --->
		<cfscript>
			var result = [];
			var fileObj = fileOpen(getFilePath(),'read',getCharset());
			var marker = 1;
			var labels = "";
			var temp = {};
			var html = "";
			var schema = getSchema();
			
			while(NOT FileisEOF(fileObj))
			
			{
				line = FileReadLine(fileObj);
				
				if(marker == 1){
					
						labels = line;	
									
				}else{
					
					line = rereplace(line,'\",\"','| ','all');
					
					temp = {};
					
					for(i = 1 ; i <= listLen(labels); i ++){
						
						temp[listGetAt(labels,i)] = rereplace(listGetAt(line,i,'|'),'"','','All');
						
					}
					
					arrayAppend(result,temp);
				} 
														
				marker = marker + 1;     
			}
			
			FileClose(fileObj);			
		</cfscript>
		
		<cfif arguments.format eq 'html'>
			<cfsavecontent variable="html">
				<cfoutput>
					<style type="text/css">
					.tablelisting{
						background-color: ##CDCDCD;
						margin:10px 0pt 15px;
						border-spacing: 1px;
					}
					.tablelisting tr{
						background-color: ##F7F7F7;
					}
					.tablelisting tr.even{
						background-color: ##ffffff;
					}
					.tablelisting tr:hover { background: ##d7eafe}
					.tablelisting th {
						text-align: left;
						background-color: ##E0EFEF;
						padding: 4px;
					}
					.tablelisting th.center{
						text-align:center;
					}
					.tablelisting th a {
						color: ##000;
						background-color: inherit;
						text-decoration: none;
						border-bottom: none;
					}
					.tablelisting th a:hover {
						color: ##CC0001; 
						background-color: inherit;	
					}
					.tablelisting td{
						padding: 5px;
					}
					.tablelisting td.center{
						text-align: center;
					}
					.tablelisting a {
						text-decoration: none;
						border-bottom: none;
					}
					.tablelisting a:hover {
						color: ##CC0001; 
						background-color: inherit;	
					}
					.tablesorter td.center{
						text-align: center;
					}
					</style>
					<cfloop from="1" to="#arraylen(result)#" index="i">
						<table class="tablelisting">
							<tbody>
								<cfloop list="#schema#" index="j">
									<tr>
										<td><b>#j#</b></td>
										<td>#result[i][j]#</td>										
									</tr>
								</cfloop>	
							</tbody>
						</table>
					</cfloop>
				</cfoutput>
			</cfsavecontent>
			<cfset result = html />
		</cfif>
		
		<cfreturn result/>
	</cffunction>

	<!--- id--->
	<cffunction name="getid" access="public" returntype="String">
		<cfreturn variables.id/>
	</cffunction>
	
	<!---schema--->
	<cffunction name="getschema" access="public" output="false" returntype="string">
		<cfreturn variables.schema/>
	</cffunction>
	<cffunction name="setschema" access="private" output="false" returntype="void">
		<cfargument name="schema" type="string" required="true"/>
		<cfset arguments.schema = listAppend(arguments.schema,'ts') />
		<cfset variables.schema = arguments.schema/>
	</cffunction>

	<!---mailer--->
	<cffunction name="getmailer" access="public" output="false" returntype="any">
		<cfreturn variables.mailer/>
	</cffunction>
	<cffunction name="setmailer" access="private" output="false" returntype="void">
		<cfargument name="mailer" type="any" required="true"/>
		<cfset variables.mailer = arguments.mailer/>
	</cffunction>

	<!---charset--->
	<cffunction name="getcharset" access="public" output="false" returntype="string">
		<cfreturn variables.charset/>
	</cffunction>
	<cffunction name="setcharset" access="private" output="false" returntype="void">
		<cfargument name="charset" type="string" required="true"/>
		<cfset variables.charset = arguments.charset/>
	</cffunction>

	<!--- maxSize--->
	<cffunction name="setmaxSize" access="public" returntype="void">
		<cfargument name="maxSize" type="Numeric" required="true"/>
		<cfset variables.maxSize = maxSize />
	</cffunction> 
	<cffunction name="getmaxSize" access="public" returntype="Numeric">
		<cfreturn variables.maxSize/>
	</cffunction>
	
    <!--- testMode--->
    <cffunction name="settestMode" access="public" returntype="void">
		<cfargument name="testMode" type="Boolean" required="true"/>
		<cfset variables.testMode = testMode />
	</cffunction> 
	<cffunction name="isTestMode" access="public" returntype="Boolean">
		<cfreturn variables.testMode/>
	</cffunction>


	<!-----------------------------------------	PRIVATE ------------------------------------------------------------------->

	<!--- doFile --->
	<cffunction name="doFile" output="false" returntype="void">	
		<cfset var fileObj = "" />
		<cfset var abPath = getFilePath() />
		<cfset var schema = getschema() />

		<cfscript>
		if(fileExists(abPath)){	
			fileDelete(abPath);
		}
		// open file
		fileObj = fileOpen(abPath,'append',getCharset());
		// craete the file with the schema if no exits
		fileWriteLine(fileObj,schema);
		// close file
		fileClose(fileObj);
		</cfscript>
		
	</cffunction>

	<!--- 
	doZipFile
	 --->
	<cffunction name="doZipFile" returntype="void" output="false" access="public">				
		<cfset var exists = true>	
		<cfset var count = 0>
		<cfset var abPath = getFilePath() />
		<cfset var fileName = variables.fileObj.getName() />
		<cfset var extension = 'zip' />	
		<cfset var zipName = replace(fileName,'.log','') />	
		<cfset var tempName = zipName />		
		<cfset var path = rereplace(abpath,filename,'') />

		<cfloop condition="exists eq true">			
			<cfif fileExists(path &  zipName & "." & extension)>
				<cfset count = count+1>
				<cfset zipName = tempName & "_" & count>				
			<cfelse>
				<cfset exists = false>	
			</cfif>
		</cfloop>
			
		<cfzip action="zip" source="#abPath#" file="#path##zipname#.#extension#" prefix="" />

	</cffunction>
	
	<!--- getSize --->
	<cffunction name="getSize" output="false" returntype="date">	
		<cfreturn variables.fileObj.length() />
	</cffunction>

	<!---getFilePath--->
	<cffunction name="getFilePath" output="false" returntype="string">
		<cfscript>
			var path = expandPath(variables.FilePath);
			return path;
		</cfscript>
	</cffunction>

	<!--- processLog --->
	<cffunction name="processLog" output="false" access="private">
		<cfargument name="str" required="true" type="struct"/>
			
			<cfscript>
				var fileObj = "" ;
				var schema = getSchema();

				// open file buffer	
				fileObj = fileOpen(getFilePath(),'append',getCharset());

				writeLog(fileObj,arguments.str);
				
				fileClose(fileObj);
			</cfscript>
	
	</cffunction>

	<!--- handleLog --->
	<cffunction name="handleLog" output="false" access="private">
		<cfargument name="str" required="true" type="struct"/>
			
		<cfthread name="#createUUID()#" action="run" values="#arguments.str#">
			<cfscript>
				var fileObj = "" ;
				var schema = getSchema();

				// open file buffer	
				fileObj = fileOpen(getFilePath(),'append',getCharset());
		
				writeLog(fileObj,attributes.values);
				
				fileClose(fileObj);

			</cfscript>
						
		</cfthread>
			
	</cffunction>
	
	<!--- writeLog --->
	<cffunction name="writeLog" output="false" access="private">
		<cfargument name="fileObj" required="true"/>
		<cfargument name="values" required="true" type="struct"/>
		
		<cfscript>
			var listValues = "";
			var schema = getSchema();
			var value ='"' & '"';
			var schemaitem = "";
			
			for(i = 1 ; i LTE listlen(schema); i++ ){
				schemaitem = rereplacenocase(listGetAt(schema,i),'"','','All');
				// looks for match in passed struct				
				if(structKeyExists(arguments.values,schemaitem) and isSimpleValue(arguments.values[schemaitem])){
					// add macth to the value list
					value = '"' & arguments.values[schemaitem] & '"';
				}
				if(schemaitem eq 'ts'){
					value = '"' & now() & '"';
					if(isTestMode()){
						value = '"TEST --' & now() & '-- TEST"';
					}
				}
					
				listValues = listAppend(listValues,value,',');
					
				value ='"' & '"';
			
			}
			
			// write file
			fileWriteLine(arguments.fileObj,listValues);		
		</cfscript>
		
	</cffunction>

</cfcomponent>
