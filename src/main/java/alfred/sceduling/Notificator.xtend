package alfred.sceduling

import alfred.tasks.Task

interface Notificator {
	def void notify(Task task, Result result)
}