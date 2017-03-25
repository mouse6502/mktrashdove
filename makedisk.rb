#!/usr/bin/ruby

MERLIN = "~/m/Merlin32 -V"
MACRO_PATH = "macro"

#files = [
#  "bresenham.s"
#]

files = ["linkfile"]

def star(txt,moretxt)
	0.upto(2){ |x| puts "*"*80 }
	0.upto(2){ puts "    #{txt}   #{txt}   #{txt}" }
	puts
	0.upto(2){ |x| puts "*"*80 }
	puts
	puts moretxt
end

def error
	star("ERROR","There was an error in the program. Please check the log to see where it has failed.")
end

def success
	star("SUCCESS","The program has compiled successfully.")
end

def do_cmd(cmd, flags={:errch => true})
    puts "Executing '#{cmd}'.."
    puts `#{cmd}`
    if $?.exitstatus != 0
	error()
	exit if flags[:errchk]
    end

    success()
end

begin
	#cmd = "#{MERLIN} #{MACRO_PATH} #{files.join(" ")}"
	#puts "Executing '#{cmd}'.."
	#puts `#{cmd}`
	#error() if $?.exitstatus != 0
	#success()
	do_cmd("mv -f ./main.dsk main.old.dsk", :errchk=>false)
	do_cmd("cp ~/m/ProDOS_2_0_3.dsk ./main.dsk")
	do_cmd("java -jar ~/m/ac-1.3.5.jar -p main.dsk MAIN.SYSTEM BIN 0x2000 < main")
	#do_cmd("java -jar ~/m/ac-1.3.5.jar -p main.dsk TD BIN 0x4FFE < td/TD-640X480.DLO")

	do_cmd("java -jar ~/m/ac-1.3.5.jar -p main.dsk TD BIN 0x5000 < trashdove.bin")

#	1.upto(4) do |n|
#		do_cmd("java -jar ~/m/ac-1.3.5.jar -p main.dsk TD#{n} BIN 0x5000 < td/tds#{n}.bin")
#	end

	#do_cmd("java -jar ~/m/ac-1.3.5.jar -p main.dsk TD BIN 0x7FE < td/TD1-SM.SLO")
	#do_cmd("java -jar ../ac/ac-1.3.5.jar -p mkmail.dsk GFX BIN 0x7200 < gfx")
	#do_cmd("java -jar ~/m/ac-1.3.5.jar -p mkmail.dsk GFX140 BIN 0x7200 < gfx140")
	#do_cmd("java -jar ~/m/ac-1.3.5.jar -p mkmail.dsk TABLES BIN 0x7C00 < tables")
end
