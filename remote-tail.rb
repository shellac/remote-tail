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

watcher = Watcher::Watcher.new

a = Thread.new do
	IO.popen('ssh data-bris.acrc.bris.ac.uk tail -f /var/log/tomcat6/catalina.out') do |p|
		while !p.eof? do
			watcher.report Watcher::Line.new(1, p.read(100))
		end
	end
end

b = Thread.new do
	IO.popen('ssh www11-py.ilrt.bris.ac.uk tail -f ~databris/ckan/var/log/ckan.log') do |p|
		while !p.eof? do
			watcher.report Watcher::Line.new(2, p.read(100))
		end
	end
end

a.join
b.join
