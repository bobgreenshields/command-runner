module CommandRunner
	class Response
		attr_reader :cmd_str, :stdout, :stderr, :exit_code

		def initialize(cmd_str:, stdout:, stderr:, exit_code:)
			@cmd_str = cmd_str
			@stdout = stdout
			@stderr = stderr
			@exit_code = exit_code
		end
	end
end
