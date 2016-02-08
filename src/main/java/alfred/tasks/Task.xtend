package alfred.tasks

import alfred.sceduling.Result

interface Task {
	def Result execute()
}