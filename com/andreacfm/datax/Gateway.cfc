<cfcomponent
	output="false"
	name="Gateway"
	hint="I am the system cfops gateway"
	accessors="true">

	<cfproperty name="EventManager" type="com.andreacfm.cfem.EventManager">
	<cfproperty name="CacheManager" type="com.andreacfm.caching.ICacheManager">
	<cfproperty name="dataMgr" type="com.andreacfm.datax.dataMgr.dataMgr">
	<cfproperty name="dbFactory" type="com.andreacfm.datax.dbfactory">
	<cfproperty name="id" type="numeric">
	<cfproperty name="table" type="string">
	<cfproperty name="pk" type="string">
	<cfproperty name="skipFields" type="string">
	<cfproperty name="beanClass" type="string">
	<cfproperty name="defaultOrderBy" type="string">
		
	<cfset _counter = 1 >	
		
	<!---	constructor	--->		
	<cffunction name="init" description="initialize the object settings struct" output="false" returntype="com.andreacfm.datax.gateway">	
		<cfargument name="dataSettingsBean" required="true" type="com.andreacfm.datax.ModelConfig" />
		<cfargument name="dbFactory" required="true" type="com.andreacfm.datax.dbFactory" />
		<cfargument name="dataMgr" required="true" type="com.andreacfm.datax.dataMgr.dataMgr" />
		<cfargument name="EventManager" required="true" type="com.andreacfm.cfem.EventManager" />	
		<cfargument name="CacheManager" required="true" type="com.andreacfm.caching.ICacheManager" />	
			
			<cfset setid(dataSettingsBean.getId()) />
			<cfset settable(dataSettingsBean.getTable()) />
			<cfset setpk(dataSettingsBean.getPk() )/>
			<cfset setskipFields(dataSettingsBean.getskipFields())  />
			<cfset setbeanClass(dataSettingsBean.getbeanClass())  />
			<cfset setdefaultOrderBy(dataSettingsBean.getdefaultOrderBy())  />
			<cfset setdbFactory(dbFactory) />
			<cfset setdataMgr(dataMgr) />
			<cfset setEventManager(EventManager) />
			<cfset setCacheManager(CacheManager) />				
			
		<cfreturn this/>		
	</cffunction>

	<!-----------------------------------------  PUBLIC   ---------------------------------------------------------------->
	
	<!---	read 	--->	
	<cffunction name="read" output="false" returntype="array">
		<cfargument name="sql" required="true" type="com.andreacfm.datax.Sql"/>
			<cfset var result = ""/>
			<cfset var data = {} />
			
			<cfset beforeRead( arguments.sql ) />
			
			<cfif arguments.sql.isAlive() and arguments.sql.isCaching()>
				<cfset processPreCacheRequest(arguments.sql)>
			</cfif>
			
			<!--- if sql is killed this is skipped --->
			<cfset dbquery( arguments.sql ) />
			
			<!--- this allow a listener to kill the query and push a desired array recordset --->
			<cfif not arguments.sql.isAlive()>
				<cfset result = arguments.sql.getResult() />
			<cfelse>	
				<!--- 
				Process the request and say to the objects if they will be cached or not. 
				The bean so knows was cached or not and will eventually cache the composite as default 
				implementation.
				 --->
				<cfset result = queryToDataBean( arguments.sql.getResult(), sql.isCaching() ) />
				<!--- push for listeners --->
				<cfset arguments.sql.setResult(result)>				
			</cfif>

			<cfif arguments.sql.isCaching()>
				<cfset processPostCacheRequest(arguments.sql)>
			</cfif>
			
			<cfset afterRead( arguments.sql) />
				
		<cfreturn result />
	</cffunction>

	<!---	list 	--->
	<cffunction name="list" output="false" returntype="query">
		<cfargument name="sql" required="true" type="com.andreacfm.datax.sql"/>
			
			<cfset beforeList(arguments.sql) />

			<cfif arguments.sql.isAlive() and arguments.sql.isCaching()>
				<cfset processPreCacheRequest(arguments.sql)>
			</cfif>
			
			<!--- if sql is killed this is skipped --->
			<cfset dbquery(sql:arguments.sql) />

			<!--- this allow a listener to kill the query and push a desired array recordset --->
			<cfif not arguments.sql.isAlive()>
				<cfset result = arguments.sql.getResult() />
			</cfif>

			<cfif arguments.sql.isCaching()>
				<cfset processPostCacheRequest(arguments.sql)>
			</cfif>
			
			<cfset afterList( arguments.sql ) />
		
		<cfreturn arguments.sql.getResult() />	
	</cffunction>

	<!---bean--->
	<cffunction name="getBean" access="public" output="false" returntype="com.andreacfm.datax.Model">
		<cfscript>
			var id = getid();
			var result = "";
			return getDbFactory().getbean(id); 			
		</cfscript>
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
		<cfset var data = { sql = sql } />
		<cfset getEventManager().dispatchEvent(name = 'GatewayAfterRead',data = data, target = this) />
	</cffunction>
	
	<cffunction name="afterList" returntype="void" access="private">
		<cfargument name="sql" type="com.andreacfm.datax.Sql">
		<cfset var data = { sql = sql } />
		<cfset getEventManager().dispatchEvent(name = 'GatewayAfterList',data = data, target = this) />
	</cffunction>

	<!--- processPreCacheRequest--->
	<cffunction name="processPreCacheRequest" returntype="void" output="false" access="private" hint="Sql is caching so look for a caches">
		<cfargument name="sql" type="com.andreacfm.datax.Sql">
		<cfscript>	
		var cm = getCacheManager();
		var key = sql.getKey();

		if(cm.exists(key)){
			arguments.sql.setResult(cm.get(key));
			arguments.sql.kill();
		}

		out = createObject('java','java.lang.System').out;
		out.println('pre store len : ' & structCount(cm.getStore()));
		
		</cfscript>
	</cffunction>

	<!--- processPostCacheRequest--->
	<cffunction name="processPostCacheRequest" returntype="void" output="false" access="private" hint="Sql is caching but no key so push the result">
		<cfargument name="sql" type="com.andreacfm.datax.Sql">
		<cfscript>
		var cm = getCacheManager();
		var key = sql.getKey();
		
		if(not cm.exists(key)){
			var str = sql.getMemento();
			str.value = sql.getResult(); 
			cm.put(argumentCollection = str);
		}

		out = createObject('java','java.lang.System').out;
		out.println('post store len : ' & structCount(cm.getStore()));

		</cfscript>

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
			
				<cfset arguments.sql.setResult(qRead) />

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
