package alfred.tasks

import alfred.sceduling.Result

class EmptyTask implements Task {
	override execute() {
		return Result.Failure
	}
}