<cfcomponent
	accessors="true" extends="com.andreacfm.datax.Model">
	
	<cfproperty name="authorid" type="numeric" />
	<cfproperty name="authorname" type="string" />
	<cfproperty name="createon" type="date" />
	<cfproperty name="updateon" type="date" />
	<cfproperty name="sort" type="numeric" />
	
	<cfproperty name="bookList" type="string" />
	<cfproperty name="bookArray" type="array" />
	<cfproperty name="relatedTables" type="array" />
	
	<cfscript>
	
	variables['authorid'] = 0;
	variables['authorname'] = "";
	variables['createon'] = now();
	variables['updateon'] = now();
	variables['sort'] = 0;
	
	variables['bookList'] = "";
	variables['bookArray'] = createObject('java','java.util.ArrayList').init();
	variables['relatedTables'] = ['author','book'];

	</cfscript>
	
	<!--- Constructor --->
	<cffunction name="init" access="public" output="false" returntype="com.andreacfm.datax.Model">	
		<cfargument name="dao" required="true" type="com.andreacfm.datax.Dao"/>
		<cfargument name="validator" required="false" type="com.andreacfm.validate.Validator" default="#createObject('component','com.andreacfm.validate.Validator').init()#"/>		

		<cfscript>
			super.init(arguments.dao,arguments.validator);			
			return this;		
		</cfscript>
	
	</cffunction>
	
<!-------------------------------------- Composite -------------------------------------------------->

	<!--- bookList --->
	<cffunction name="getbookList" output="false" returntype="string" >
		<cfscript>	
		return variables.bookList;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setbookList" output="false" returntype="void" >
		<cfargument name="bookList" type="string" required="true"/>
		<cfscript>
		variables.bookList = arguments.bookList;		
		</cfscript>
	</cffunction>	
	
	<!--- bookArray --->	
	<cffunction name="getbookArray" output="false" returntype="any" >
		<cfargument name="pop" type="boolean" default="false" />
		<cfargument name="data" type="Struct" default="#structNew()#" />
		<cfargument name="filters" type="Array" default="#arrayNew(1)#" />
		<cfargument name="refresh" type="boolean" default="false" />
		<cfscript>
			var advsql = structNew();	
			var list = "";
			
				if(listlen(getbookList()) and not structKeyExists(variables['loaded'],'bookArray') or arguments.refresh){
					list = getbookList();
					advsql.where = "bookId IN (#list#)";
					setbookArray(getBeanFactory().getBean('dsManager').getService('bookService').read( data = arguments.data, filters = arguments.filters, advsql = advsql, cache = this.cache));
				};			
			
			if(arguments.pop){
				return variables.bookArray[1];
			}
			return variables.bookArray;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setbookArray" output="false" returntype="void" >
		<cfargument name="bookArray" type="array" required="true"/>
		<cfscript>	
		variables.bookArray = arguments.bookArray;
		variables['loaded']['bookArray'] = 'loaded';
		</cfscript>
	</cffunction>	

	<!--- bookQuery --->	
	<cffunction name="getbookQuery" output="false" returntype="query" >
		<cfargument name="pop" type="boolean" default="false" />
		<cfargument name="data" type="Struct" default="#structNew()#" />
		<cfargument name="filters" type="Array" default="#arrayNew(1)#" />
		<cfargument name="refresh" type="boolean" default="false" />
		<cfscript>
			var advsql = structNew();	
			var list = "";
			var q = queryNew('x');

			
				if(listlen(getbookList()) or arguments.refresh){
					list = getbookList();
					advsql.where = "bookId IN (#list#)";
					q = getBeanFactory().getBean('dsManager').getService('bookService').list( data = arguments.data, filters = arguments.filters, advsql = advsql, cache = this.cache);
				};			
			

			return q;
		</cfscript>
	</cffunction>	




</cfcomponent>
