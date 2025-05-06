{
	"patcher" : 	{
		"fileversion" : 1,
		"appversion" : 		{
			"major" : 9,
			"minor" : 0,
			"revision" : 2,
			"architecture" : "x64",
			"modernui" : 1
		}
,
		"classnamespace" : "box",
		"rect" : [ 1004.0, 507.0, 486.0, 424.0 ],
		"gridsize" : [ 15.0, 15.0 ],
		"boxes" : [ 			{
				"box" : 				{
					"id" : "obj-4",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 265.0, 241.0, 29.5, 22.0 ],
					"text" : "fn 1"
				}

			}
, 			{
				"box" : 				{
					"filename" : "parser.js",
					"id" : "obj-1",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 265.0, 284.0, 70.0, 22.0 ],
					"saved_object_attributes" : 					{
						"parameter_enable" : 0
					}
,
					"text" : "v8 parser.js",
					"textfile" : 					{
						"filename" : "parser.js",
						"flags" : 0,
						"embed" : 0,
						"autowatch" : 1
					}

				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"destination" : [ "obj-1", 0 ],
					"source" : [ "obj-4", 0 ]
				}

			}
 ],
		"originid" : "pat-47",
		"dependency_cache" : [ 			{
				"name" : "parser.js",
				"bootpath" : "~/Desktop/Postdoc/prototypes/the-unfinder/prototypes/unfinder-v3",
				"patcherrelativepath" : ".",
				"type" : "TEXT",
				"implicit" : 1
			}
 ],
		"autosave" : 0
	}

}
