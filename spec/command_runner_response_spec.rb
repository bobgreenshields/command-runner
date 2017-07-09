require "command_runner"

describe CommandRunner::Response do
	describe "#new" do
		it "returns a Response instance with the correct attributes" do
			response = CommandRunner::Response.new(cmd_str: "test string",
																						 stdout: "stdout",
																						 stderr: "stderr",
																						 exit_code: 0)
			expect(response).to be_an_instance_of CommandRunner::Response
			expect(response.cmd_str).to eql("test string")
			expect(response.stdout).to eql("stdout")
			expect(response.stderr).to eql("stderr")
			expect(response.exit_code).to eql(0)
		end
	end
end
