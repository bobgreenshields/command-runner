require "open3"

module CommandRunner
	class Response
		attr_reader :cmd_str, :stdout, :stderr, :exit_code

		def initialize(cmd_str:, stdout:, stderr:, exit_code:)
			@cmd_str = cmd_str
			@stdout = stdout
			@stderr = stderr
			@exit_code = exit_code
		end

		def success?
			@exit_code == 0
		end

		def on_success
			yield self if success?
		end

		def on_failure
			yield self unless success?
		end
	end

	class Shell
		attr_writer :log

		def call(*cmd)
			stdout, stderr, status = Open3.capture3(*cmd)
			response = Response.new(cmd_str: cmd.join(" "), stdout: stdout,
				stderr: stderr, exit_code: status.to_i)
			log.call(response)
			response
		end

		# if @log is not defined it returns a lambda which responds to call
		# and does nothing
		def log
			@log ||= -> (response) {}
		end
	end

	ResponseData = Struct.new(:stdout, :stderr, :exit_code, :cmd_str)

	class Mock
		attr_reader :cmds

		def initialize(spy: nil)
			@spy = spy
			@cmds = []
			@programmed_responses = {}
		end

		def respond_to(*cmds)
			response_data = ResponseData.new
			yield response_data
			cmd_str = cmds.join(" ").strip
			response_data.cmd_str = cmd_str
			@programmed_responses[cmd_str] = response_data
		end

		def call(*cmd)
			cmd_str = cmd.join(" ").strip
			if @programmed_responses.key? cmd_str
				return response_from_data(@programmed_responses[cmd_str])
			end

			raise "unexpected command called: #{cmd_str}"
		end
		
		def response_from_data(response_data)
			Response.new(cmd_str: response_data.cmd_str,
									 stdout: response_data.stdout,
									 stderr: response_data.stderr,
									 exit_code: response_data.exit_code)
		end
	end
end
