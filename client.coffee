Dom = require 'dom'
Server = require 'server'
Ui = require 'ui'
Db = require 'db'
Plugin = require 'plugin'
Time = require 'time'
Loglist = require 'loglist'

exports.render = ->
	Ui.bigButton 'I Lost the Game', ->
		Server.call 'lost'
	Ui.emptyText(" ")
	Ui.list !->
		Dom.h3 "Top losers"
		Db.shared.iterate 'counter', (user) !->
			Ui.item !->
				if (0|user.key())==Plugin.userId()
					Dom.style fontWeight: 'bold'
				
				Ui.avatar Plugin.userAvatar(user.key())
				
				Dom.div !->
					Dom.style
						marginLeft: '10px'
						Flex: true
					Dom.text Plugin.userName(user.key())
				
				Dom.div !->
					Dom.style
						fontSize: '150%'
					Dom.text user.get('score')
					
		, (user) -> [(-user.get('score')), user.get('naam')]
	
	Ui.list !->
		maxO = Db.shared.get('lostId')
		firstO = maxO-9
		if firstO < 1
			firstO = 1
		
		Dom.h3 "Recent losers"
		Loglist.render firstO, maxO, (num) !->
			lose = Db.shared.ref('lost', num)
			Ui.item !->
				if (0|lose.get('user'))==Plugin.userId()
					Dom.style fontWeight: 'bold'
				
				Ui.avatar Plugin.userAvatar(lose.get('user'))
				
				Dom.div !->
					Dom.style
						marginLeft: '10px'
						Flex: true
					Dom.text Plugin.userName(lose.get('user'))
				
				Dom.div !->
					Time.deltaText lose.get('date')