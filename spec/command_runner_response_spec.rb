require "command_runner"

describe CommandRunner::Response do
	describe "#new" do
		it "returns a Response instance with the correct attributes" do
			response = CommandRunner::Response.new(cmd_str: "test string",
				stdout: "stdout", stderr: "stderr", exit_code: 0)
			expect(response).to be_an_instance_of CommandRunner::Response
			expect(response.cmd_str).to eql("test string")
			expect(response.stdout).to eql("stdout")
			expect(response.stderr).to eql("stderr")
			expect(response.exit_code).to eql(0)
		end
	end

	def new_response
		response = CommandRunner::Response.new(cmd_str: "test string",
			stdout: "stdout", stderr: "stderr", exit_code: exit_code)
	end

	describe "#success?" do
		context "when the exit code is zero" do
			let(:exit_code) { 0 }
			it "returns true" do
				expect(new_response).to be_success
			end
		end

		context "when the exit code is non-zero" do
			let(:exit_code) { 1 }
			it "returns false" do
				expect(new_response).not_to be_success
			end
		end
	end

	describe "#on_success" do
		context "when the exit code is zero" do
			let(:exit_code) { 0 }
			it "yields with self" do
				response = new_response
				expect { |b| response.on_success(&b) }.to yield_with_args(response)
			end
		end

		context "when the exit code is non-zero" do
			let(:exit_code) { 1 }
			it "does not yield" do
				response = new_response
				expect { |b| response.on_success(&b) }.not_to yield_with_args
			end
		end
	end

	describe "#on_failure" do
		context "when the exit code is zero" do
			let(:exit_code) { 0 }
			it "does not yield" do
				response = new_response
				expect { |b| response.on_failure(&b) }.not_to yield_with_args
			end
		end

		context "when the exit code is non-zero" do
			let(:exit_code) { 1 }
			it "yields with self" do
				response = new_response
				expect { |b| response.on_failure(&b) }.to yield_with_args(response)
			end
		end
	end

end
