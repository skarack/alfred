package alfred.sceduling

import alfred.tasks.Task

class Scheduler {
	def static runTask(Task task, Notificator notificator) {
		new Thread([
			val result = try { task.execute } catch (Exception e) { println(e) Result.Failure }
			notificator.notify(task, result)
		]).start
	} 
}