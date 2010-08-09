<cfcomponent
	accessors="true" extends="com.andreacfm.datax.Model">
	
	<cfproperty name="bookid" type="numeric" />
	<cfproperty name="bookname" type="string" />
	<cfproperty name="createon" type="date" />
	<cfproperty name="updateon" type="date" />
	<cfproperty name="sort" type="numeric" />
	
	<cfproperty name="authorList" type="string" />
	<cfproperty name="authorArray" type="array" />
	<cfproperty name="relatedTables" type="array" />
	
	<cfscript>
	
	variables['bookid'] = 0;
	variables['bookname'] = "";
	variables['createon'] = now();
	variables['updateon'] = now();
	variables['sort'] = 0;
	
	variables['authorList'] = "";
	variables['authorArray'] = createObject('java','java.util.ArrayList').init();
	variables['relatedTables'] = ['book','author'];

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

	<!--- authorList --->
	<cffunction name="getauthorList" output="false" returntype="string" >
		<cfscript>	
		return variables.authorList;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setauthorList" output="false" returntype="void" >
		<cfargument name="authorList" type="string" required="true"/>
		<cfscript>
		variables.authorList = arguments.authorList;		
		</cfscript>
	</cffunction>	
	
	<!--- authorArray --->	
	<cffunction name="getauthorArray" output="false" returntype="any" >
		<cfargument name="pop" type="boolean" default="false" />
		<cfargument name="data" type="Struct" default="#structNew()#" />
		<cfargument name="filters" type="Array" default="#arrayNew(1)#" />
		<cfargument name="refresh" type="boolean" default="false" />
		<cfscript>
			var advsql = structNew();	
			var list = "";
			
				if(listlen(getauthorList()) and not structKeyExists(variables['loaded'],'authorArray') or arguments.refresh){
					list = getauthorList();
					advsql.where = "authorId IN (#list#)";
					setauthorArray(getBeanFactory().getBean('dsManager').getService('authorService').read( data = arguments.data, filters = arguments.filters, advsql = advsql, cache = this.cache));
				};			
			
			if(arguments.pop){
				return variables.authorArray[1];
			}
			return variables.authorArray;
		</cfscript>
	</cffunction>	
	
	<cffunction name="setauthorArray" output="false" returntype="void" >
		<cfargument name="authorArray" type="array" required="true"/>
		<cfscript>	
		variables.authorArray = arguments.authorArray;
		variables['loaded']['authorArray'] = 'loaded';
		</cfscript>
	</cffunction>	

	<!--- authorQuery --->	
	<cffunction name="getauthorQuery" output="false" returntype="query" >
		<cfargument name="pop" type="boolean" default="false" />
		<cfargument name="data" type="Struct" default="#structNew()#" />
		<cfargument name="filters" type="Array" default="#arrayNew(1)#" />
		<cfargument name="refresh" type="boolean" default="false" />
		<cfscript>
			var advsql = structNew();	
			var list = "";
			var q = queryNew('x');

			
				if(listlen(getauthorList()) or arguments.refresh){
					list = getauthorList();
					advsql.where = "authorId IN (#list#)";
					q = getBeanFactory().getBean('dsManager').getService('authorService').list( data = arguments.data, filters = arguments.filters, advsql = advsql, cache = this.cache);
				};			
			

			return q;
		</cfscript>
	</cffunction>	




</cfcomponent>
