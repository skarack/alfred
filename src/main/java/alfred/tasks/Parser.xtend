package alfred.tasks

import alfred.tasks.torrent.TorrentTask

class Parser {
	def static extractTask(String command) {
		val cmdParts = command.split("\\s+")
		val first = cmdParts.get(0)
		
		val task = switch(first) {
			case "torrent":  TorrentTask.fromParts(cmdParts)
			default: new EmptyTask
		}
		
		task
	}
}