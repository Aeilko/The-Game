Db = require 'db'
Plugin = require 'plugin'
Event = require 'event'

exports.onInstall = !->
	users = {}
	for userId in Plugin.userIds()
		users[userId] = {naam: Plugin.userName(userId), score: 0, date: 0}
	Db.shared.set 'counter', users
	
	Db.shared.set 'lost', {}
	log 'Installed'

exports.client_lost = ->
	log 'id#', Plugin.userId(), ' ', Plugin.userName(), 'lost the game'
	date = new Date()/1000
	lastDate = Db.shared.get('counter', Plugin.userId(), 'date')
	
	# Maximaal eens in het half uur de game verliezen
	if (date-lastDate > 60*30)
		Db.shared.modify 'counter', Plugin.userId(), 'score', (v) -> (v||0)+1
		Db.shared.set 'counter', Plugin.userId(), 'date', date
		
		id = Db.shared.modify 'lostId', (v) -> (v||0)+1
		Db.shared.set 'lost', id, {user: Plugin.userId(), date: date}
		
		name = Plugin.userName()
		Event.create
			unit: 'msg'
			text: "#{name} just lost the game"
			read: [Plugin.userId()]