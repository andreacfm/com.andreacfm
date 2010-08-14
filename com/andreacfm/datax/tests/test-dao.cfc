<cfcomponent displayname="core-bean" extends="mxunit.framework.TestCase">

	<cffunction name="setUp">
		<cfset variables.beanfactory = CreateObject('component','com.andreacfm.util.beanutils.DynamicXmlBeanFactory').init()/>
		<cfset variables.beanfactory.loadBeansFromDynamicXmlFile('/com/andreacfm/datax/tests/config/coldspring.xml.cfm') />
		<cfset variables.beanfactory.getBean('EventManager').getLogger().setOut('console')>		
	</cffunction>

	<cffunction name="teardown">
		<cfscript>
		</cfscript>
	</cffunction>
	
	<cffunction name="test_clean_cache_on_update" returntype="void" output="false">
		<cfscript>
			transaction action="begin"{
				try{	
					var bf = variables.beanFactory;
					var sv = bf.getBean('dsManager').getService('bookService');
					var svauth = bf.getBean('dsManager').getService('authorService');
					var dbf = bf.getBean('dbFactory');
					var cm = bf.getBean('CacheManager');					
					
					//insert a book
					var book = dbf.getBean('book');
					book.setBookName('mybook');
					book.create();

					//insert a book
					var author = dbf.getBean('author');
					author.setAuthorName('author');
					author.create();
					
					var q = sv.list(cache=true);
					assertTrue(q.recordcount eq 1);
					assertTrue(structCount(cm.getStore()) eq 1);

					var q = svauth.list(cache=true);
					assertTrue(q.recordcount eq 1);
					assertTrue(structCount(cm.getStore()) eq 2);
					
					book.setBookName('new name');
					book.update();
					
					assertTrue(structCount(cm.getStore()) eq 0);
					
					
				}
				catch(any e){
					transaction action="rollback";
					rethrow;				
				}				
				transaction action="rollback";
			}			
		</cfscript>
	</cffunction>
	
			
</cfcomponent>