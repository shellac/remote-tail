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

watcher = Watcher::Watcher.new

a = run('data-bris catalina.out', watcher,
	'ssh', 'data-bris.acrc.bris.ac.uk', 'tail', '-f', '/var/log/tomcat6/catalina.out')

b = run('ckan prod log', watcher,
	'ssh', 'www11-py.ilrt.bris.ac.uk', 'tail', '-f', '~databris/ckan/var/log/ckan.log')

c = run('data-bris localhost', watcher,
	'ssh', 'data-bris.acrc.bris.ac.uk', 'tail', '-f', '/var/log/tomcat6/localhost.2014-10-17.log')


a.join
b.join
c.join
