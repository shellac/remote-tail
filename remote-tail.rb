module Watcher

	require 'celluloid'
	require 'term/ansicolor'

	Line = Struct.new(:source, :line)

	class Watcher
		include Celluloid
		include Term::ANSIColor

		@last_source = nil

		def report(line)
			if (@last_source != line.source)
				puts
				puts negative, "============== #{line.source} ================", reset
			end
			@last_source = line.source
			print line.line
		end
	end
end

def run(id, watcher, *command)
	p command
	Thread.new do
		IO.popen(command) do |p|
			while !p.eof? do
				watcher.report Watcher::Line.new(id, p.read(100))
			end
		end
	end
end

watcher_threads = []

watcher = Watcher::Watcher.new

# Read config file
# Format NAME HOST FILE
ARGF.lines do |line|
	description, host, remote_file = line.split(/\s+/)
	puts "Watch '#{description}' <#{remote_file}> on host <#{host}>"
	watcher_threads << run(description, watcher, 'ssh', host, 'tail', '-f', remote_file)
end

watcher_threads.each &:join
