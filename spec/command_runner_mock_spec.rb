require "command_runner"

describe CommandRunner::Mock do
	describe "#respond_to" do
		context "for a command that has been added" do
			let(:mock) do
				res = CommandRunner::Mock.new
				res.respond_to("test", "cmd") do | rd |
					rd.stdout = "stdout"
					rd.stderr = "stderr"
					rd.exit_code = 11
				end
				res
			end
			it "returns a response object with the correct attributes" do
				response = mock.call("test cmd")
				expect(response).to be_an_instance_of(CommandRunner::Response)
				expect(response.cmd_str).to eql("test cmd")
				expect(response.stdout).to eql("stdout")
				expect(response.stderr).to eql("stderr")
				expect(response.exit_code).to eql(11)
			end
		end
		context "for a command that has not been added" do
			let(:mock) do
				res = CommandRunner::Mock.new
				res.respond_to("test", "cmd") do | rd |
					rd.stdout = "stdout"
					rd.stderr = "stderr"
					rd.exit_code = 11
				end
				res
			end
			it "raises an error" do
				expect{ mock.call("unexpected") }.to raise_error(StandardError)
			end
			
		end
	end
end
