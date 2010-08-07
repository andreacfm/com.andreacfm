<cfcomponent displayname="core-bean" extends="mxunit.framework.TestCase">

	<cffunction name="setUp">
	</cffunction>
	
	<cffunction name="craete_objet_test" returntype="void" output="false">
		<cfscript>
		var obj = new com.andreacfm.caching.SimpleCache();
		assertTrue(isObject(obj));
		</cfscript>
	</cffunction>	
	
	<cffunction name="init_test" returntype="void" output="false">
		<cfscript>
		var cachewithin = createTimespan(0,10,0,0);
		var timeidle = createTimespan(0,10,0,0);

		var obj = new com.andreacfm.caching.SimpleCache(
			cachewithin = cachewithin,
			timeidle = timeidle,
			cachename = 'test'			
		);
		assertTrue(obj.getCacheName() eq 'test');
		assertTrue(obj.getcachewithin() eq cachewithin);
		assertTrue(obj.getTimeIdle() eq timeidle);
		
		</cfscript>
	</cffunction>	

	<cffunction name="put_test" returntype="void" output="false">
		<cfscript>
		var cachewithin = createTimespan(0,2,0,0);
		var obj = new com.andreacfm.caching.SimpleCache(
			cachewithin = cachewithin
		);
		obj.put('mykey',{a = 'b'});
		
		var store = obj.getStore();
		
		assertTrue(isStruct(store.mykey.value) and store.mykey.value.a eq 'b');
		assertTrue(dateCompare(store.mykey.expires,now()) eq 1);		
		</cfscript>
	</cffunction>	
	
	<cffunction name="exists_test" returntype="void" output="false">
		<cfscript>
		var obj = new com.andreacfm.caching.SimpleCache();
		
		var cachewithin = createTimespan(0,0,0,1);
		obj.put('mykey',{a = 'b'},cachewithin);		
		assertTrue(obj.exists('mykey'));
		
		obj.put('mykey2',{a = 'b'});
		sleep(2000);		
		assertTrue(not obj.exists('mykey2'));
		
		assertTrue(not obj.exists('another_key'));	
		</cfscript>
	</cffunction>	

	<cffunction name="get_test" returntype="void" output="false">
		<cfscript>
		var obj = new com.andreacfm.caching.SimpleCache();

		obj.put('mykey',{a = 'b'});		
		obj.put('mykey2',['ubuntu','osx']);
		
		assertTrue(obj.get('mykey').a eq 'b');
		assertTrue(obj.get('mykey2')[1] eq 'ubuntu');
				
		</cfscript>
	</cffunction>	
	
	<cffunction name="get_key_do_not_exists_test" returntype="void" output="false" mxunit:expectedException="com.andreacfm.caching.keyDoesNotExists">
		<cfscript>
		var obj = new com.andreacfm.caching.SimpleCache();
		obj.get('another_key');
		</cfscript>
	</cffunction>	
	

	<cffunction name="remove_test" returntype="void" output="false">
		<cfscript>
		var obj = new com.andreacfm.caching.SimpleCache();

		obj.put('mykey',{a = 'b'});		
		obj.put('mykey2',['ubuntu','osx']);
		
		obj.remove('mykey');		
		assertTrue(obj.exists('mykey2'));
		assertTrue(not obj.exists('mykey'));

		obj.put('mykey',{a = 'b'});		
		obj.put('mykey2',['ubuntu','osx']);

		obj.remove(criteria:'mykey');		
		assertTrue(not obj.exists('mykey2'));
		assertTrue(not obj.exists('mykey'));
				
		</cfscript>
	</cffunction>	

	<cffunction name="flush_test" returntype="void" output="false">
		<cfscript>
		var obj = new com.andreacfm.caching.SimpleCache();

		obj.put('mykey',{a = 'b'});		
		obj.put('mykey2',['ubuntu','osx']);
		
		obj.remove('mykey');		
		assertTrue(obj.exists('mykey2'));
		assertTrue(not obj.exists('mykey'));

		obj.put('mykey',{a = 'b'});		
		obj.put('mykey2',['ubuntu','osx']);

		obj.remove(criteria:'mykey');		
		assertTrue(not obj.exists('mykey2'));
		assertTrue(not obj.exists('mykey'));
				
		</cfscript>
	</cffunction>	

</cfcomponent>