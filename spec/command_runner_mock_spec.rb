require "command_runner"

describe CommandRunner::Mock do
	describe "#respond_to" do
		context "for a command that has been added" do
			let(:rd) do
				CommandRunner::ResponseData.new.tap do | rd |
					rd.stdout = "stdout"
					rd.stderr = "stderr"
					rd.exit_code =11 
				end
			end
			let(:mock) do
				res = CommandRunner::Mock.new
				res.respond_to("test", "cmd", response_data: rd)
				#res.respond_to("test", "cmd") do | rd |
					#rd.stdout = "stdout"
					#rd.stderr = "stderr"
					#rd.exit_code = 11
				#end
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

	describe "#add_response" do
			let(:rd) do
				CommandRunner::ResponseData.new.tap do | rd |
					rd.stdout = "stdout"
					rd.stderr = "stderr"
					rd.exit_code = 0
				end
			end
		context "when two responses are queued" do
			let(:mock) do
				CommandRunner::Mock.new.tap do | m |
					m.add_response(response_data: rd) { |rd| rd.exit_code = 1 }
					m.add_response(response_data: rd) { |rd| rd.exit_code = 2 }
				end
			end

			it "returns them in the order queued" do
				response1 = mock.call("test1")
				response2 = mock.call("test2")
				expect(response1.cmd_str).to eql("test1")
				expect(response1.exit_code).to eql(1)
				expect(response2.cmd_str).to eql("test2")
				expect(response2.exit_code).to eql(2)
			end

			context "when calls are prepared with #respond_to" do
			let(:mock) do
				CommandRunner::Mock.new.tap do | m |
					m.respond_to("respond to", response_data: rd)
					m.add_response(response_data: rd) { |rd| rd.exit_code = 1 }
					m.add_response(response_data: rd) { |rd| rd.exit_code = 2 }
				end
			end
				it "ignores those calls" do
				response1 = mock.call("test1")
				response2 = mock.call("respond to")
				response3 = mock.call("respond to")
				response4 = mock.call("test2")
				expect(response1.cmd_str).to eql("test1")
				expect(response1.exit_code).to eql(1)
				expect(response4.cmd_str).to eql("test2")
				expect(response4.exit_code).to eql(2)
				end
				
			end

		end
		
	end
end


















