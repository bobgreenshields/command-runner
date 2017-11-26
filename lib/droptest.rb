require "open3"

puts "Process uid = #{Process.uid}\n"

user = `echo $SUDO_USER`
puts "sudo user is #{user}"

puts "\n\n"

puts "without dropping priviledges\n"

#stdout, stderr, status = Open3.capture3("echo $SUDO_USER")
#stdout, stderr, status = Open3.capture3("fdisk -l")
#puts "stdout = #{stdout}"
#puts "stderr = #{stderr}"
#puts "exit status  = #{status.exitstatus}"
res_arr = Open3.capture3("fdisk -l")
puts "stdout = #{res_arr[0]}"
puts "stderr = #{res_arr[1]}"
puts "exit status  = #{res_arr[2].exitstatus}"

puts "\n\n"

puts "now with dropped priviledges\n"

def drop_priv
  Process.initgroups("bobg", 1000)
  Process::Sys.setegid(1000)
  Process::Sys.setgid(1000)
  Process::Sys.setuid(1000)
end

#def do_as_user
#  unless pid = fork
#    drop_priv
#    user = `fdisk -l`
#    puts "fdisk -l output is\n#{user}"

#    exit! 0 # prevent remainder of script from running in the child process
#  end
#  puts "Child running as PID #{pid} with reduced privs"
#  Process.wait(pid)
#end

def do_as_user
	read, write = IO.pipe

	unless pid = fork
		read.close
		drop_priv
		result = Open3.capture3("fdisk -l")
		#result = `fdisk -l`
		#puts "fdisk -l output is\n#{user}"
		Marshal.dump(result, write)

		exit! 0 # prevent remainder of script from running in the child process
	end

	write.close
	result = read.read
	puts "Child running as PID #{pid} with reduced privs"
	Process.wait(pid)
	Marshal.load(result)
end


#puts do_as_user
res_arr = do_as_user
puts "stdout = #{res_arr[0]}"
puts "stderr = #{res_arr[1]}"
puts "exit status  = #{res_arr[2].exitstatus}"

#stdout, stderr, status = Open3.capture3("echo $SUDO_USER", uid: 1000, gid: 1000)
#puts "stdout = #{stdout}"
#puts "stderr = #{stderr}"
#puts "exit status  = #{status.exitstatus}"

#require "open3"

#module CommandRunner
	#class Response
		#attr_reader :cmd_str, :stdout, :stderr, :exit_code

		#def initialize(cmd_str:, stdout:, stderr:, exit_code:)
			#@cmd_str = cmd_str
			#@stdout = stdout
			#@stderr = stderr
			#@exit_code = exit_code
		#end

		#def success?
			#@exit_code == 0
		#end

		#def on_success
			#yield self if success?
		#end

		#def on_failure
			#yield self unless success?
		#end
	#end

	#class Shell
		#attr_writer :log

		#def call(*cmd)
			#stdout, stderr, status = Open3.capture3(*cmd)
			#response = Response.new(cmd_str: cmd.join(" "), stdout: stdout,
				#stderr: stderr, exit_code: status.to_i)
			#log.call(response)
			#response
		#end
