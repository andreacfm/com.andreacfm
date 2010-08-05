<cfcomponent
	output="false"
	name="Gateway"
	hint="I am the system cfops gateway">

	<!---	constructor	--->		
	<cffunction name="init" description="initialize the object settings struct" output="false" returntype="com.andreacfm.datax.gateway">	
		<cfargument name="dataSettingsBean" required="true" type="com.andreacfm.datax.ModelConfig" />
		<cfargument name="dbFactory" required="true" type="com.andreacfm.datax.dbFactory" />
		<cfargument name="dataMgr" required="true" type="com.andreacfm.datax.dataMgr.dataMgr" />
		<cfargument name="EventManager" required="true" type="com.andreacfm.cfem.EventManager" />	
			
			<cfset variables.id = arguments.dataSettingsBean.getId() />
			<cfset variables.table = arguments.dataSettingsBean.getTable() />
			<cfset variables.pk = arguments.dataSettingsBean.getPk() />
			<cfset variables.skipFields = arguments.dataSettingsBean.getskipFields() />
			<cfset variables.beanClass = arguments.dataSettingsBean.getbeanClass() />
			<cfset variables.defaultOrderBy = arguments.dataSettingsBean.getdefaultOrderBy() />
			<cfset variables.dbFactory = arguments.dbFactory />
			<cfset variables.dataMgr = arguments.dataMgr />
			<cfset variables.EventManager = arguments.EventManager />			
			
		<cfreturn this/>		
	</cffunction>

	<!-----------------------------------------  PUBLIC   ---------------------------------------------------------------->
	
	<!---	read 	--->	
	<cffunction name="read" output="false" returntype="array">
		<cfargument name="sql" required="true" type="com.andreacfm.datax.Sql"/>
			<cfset var result = ""/>
			<cfset var data = {} />
			
			<cfset beforeRead( arguments.sql ) />
			
			<!--- if sql is killed this is skipped --->
			<cfset dbquery( arguments.sql ) />
			
			<!--- this allow a listener to kill the query and push a desired array recordset --->
			<cfif not arguments.sql.isAlive() and arguments.sql.getObjectsRecordset().size() gt 0>
				<cfset result = arguments.sql.getObjectsRecordset() />
			<cfelse>	
				<cfset result = queryToDataBean( arguments.sql.getQuery(), sql.isCaching() ) />				
			</cfif>
			
			<cfset afterRead( arguments.sql , result ) />
				
		<cfreturn result />
	</cffunction>

	<!---	list 	--->
	<cffunction name="list" output="false" returntype="query">
		<cfargument name="sql" required="true" type="com.andreacfm.datax.sql"/>
			
			<cfset beforeList(arguments.sql) />
			
			<cfset dbquery(sql:arguments.sql) />
			
			<cfset afterList( arguments.sql ) />
		
		<cfreturn arguments.sql.getQuery() />	
	</cffunction>

	<!---bean--->
	<cffunction name="getBean" access="public" output="false" returntype="com.andreacfm.datax.Model">
		<cfscript>
			var id = getid();
			var result = "";
			return getDbFactory().getbean(id); 			
		</cfscript>
	</cffunction>

	<!---id--->
	<cffunction name="getid" access="public" output="false" returntype="string">
		<cfreturn variables.id/>
	</cffunction>

	<!---table--->
	<cffunction name="gettable" access="public" output="false" returntype="string">
		<cfreturn variables.table/>
	</cffunction>

	<!---pk--->
	<cffunction name="getpk" access="public" output="false" returntype="string">
		<cfreturn variables.pk/>
	</cffunction>

	<!---skipFields--->
	<cffunction name="getskipFields" access="public" output="false" returntype="string">
		<cfreturn variables.skipFields/>
	</cffunction>

	<!---beanClass--->
	<cffunction name="getbeanClass" access="public" output="false" returntype="string">
		<cfreturn variables.beanClass/>
	</cffunction>

	<!---deafultOrderBy--->
	<cffunction name="getdefaultOrderBy" access="public" output="false" returntype="string">
		<cfreturn variables.defaultOrderBy/>
	</cffunction>

	<!---dbFactory--->
	<cffunction name="getdbFactory" access="public" output="false" returntype="com.andreacfm.datax.dbfactory">
		<cfreturn variables.dbfactory/>
	</cffunction>

	<!---dataMgr instance--->
	<cffunction name="getdataMgr" access="public" output="false" returntype="com.andreacfm.datax.dataMgr.dataMgr">
		<cfreturn variables.dataMgr />
	</cffunction>

	<!--- Event Manager--->
	<cffunction name="getEventManager" access="public" returntype="com.andreacfm.cfem.EventManager">
		<cfreturn variables.EventManager/>
	</cffunction>


	<!-----------------------------------------  PRIVATE   ---------------------------------------------------------------->

	<!--- 
		Interceptions 
	--->	
	<cffunction name="beforeRead" returntype="void" access="private">
		<cfargument name="sql" type="com.andreacfm.datax.Sql">
		<cfset var data = { sql = sql } />
		<cfset getEventManager().dispatchEvent(name = 'GatewayBeforeRead',data = data, target = this) />
	</cffunction>
	
	<cffunction name="beforeList" returntype="void" access="private">
		<cfargument name="sql" type="com.andreacfm.datax.Sql">
		<cfset var data = { sql = sql } />
		<cfset getEventManager().dispatchEvent(name = 'GatewayBeforeList',data = data, target = this) />
	</cffunction>

	<cffunction name="afterRead" returntype="void" access="private">
		<cfargument name="sql" type="com.andreacfm.datax.Sql">
		<cfargument name="result" type="array">
		<cfset var data = { sql = sql , result = result} />
		<cfset getEventManager().dispatchEvent(name = 'GatewayAfterRead',data = data, target = this) />
	</cffunction>
	
	<cffunction name="afterList" returntype="void" access="private">
		<cfargument name="sql" type="com.andreacfm.datax.Sql">
		<cfset var data = { sql = sql } />
		<cfset getEventManager().dispatchEvent(name = 'GatewayAfterList',data = data, target = this) />
	</cffunction>

	
	<!--- query database  --->	
	<cffunction name="dbquery" access="private" output="false" returntype="void">
		<cfargument name="sql" required="true" type="com.andreacfm.datax.sql"/>
		
			<cfset var dataMgr = getDataMgr() />
						
			<cfif arguments.sql.isAlive()>

				<!---set the default order by of nothing is passed--->
				<cfif arguments.sql.getOrderBy() eq "" >	
					<cfset arguments.sql.setOrderBy(getdefaultOrderBy())>
				</cfif>
							
				<cfset qRead = dataMgr.getRecords(
						tablename = gettable(),
						data = arguments.sql.getdata(),
						orderby = arguments.sql.getOrderBy(),
						maxrows = arguments.sql.getMaxrows(),
						fieldlist = arguments.sql.getfieldlist(),
						advsql = arguments.sql.getAdvSql(),
						filters = arguments.sql.getFilters(),
						offset = arguments.sql.getOffset())/>
			
				<cfset arguments.sql.setQuery(qRead) />

			</cfif>

	</cffunction>

	<!---queryToDataBean--->
	<cffunction name="queryToDataBean" output="false" returntype="array">
		<cfargument name="query" type="query" required="yes" />
		<cfargument name="cache" type="boolean" required="yes" />

		<cfscript>
		var myArray		=	createObject('java','java.util.ArrayList').init();
		var myQuery		=	arguments.query ;
		var colCount	=	0 ;
		var metaData	=	"" ;
		var q	=	0 ;
		var i	=	0 ;
		
		metaData	=	getMetaData(myQuery);
		colCount	=	arraylen(metaData);

		for( q = 1 ; q LTE myQuery.recordCount ; q = q + 1 ) {
			
			myBean = getbean();
			myBean.cache = cache;
		
			for( i = 1 ; i LTE colCount ; i = i + 1 ) {

				if( StructKeyExists( myBean , 'Set#metadata[i].name#' ) ){

					try{
				
						Evaluate("myBean.Set#metadata[i].name#( myQuery[metadata[i].name][q] )");
					
					}catch( any excp ){
					
					}
				
				}
		
			}
		
			myArray[ q ] = myBean ;
		
		}
		</cfscript>
		<cfreturn myArray />
	</cffunction>

				
 </cfcomponent>
