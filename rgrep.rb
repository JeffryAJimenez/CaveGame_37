args = ARGV

if args.length() < 2 or not(File.exists?(args[0]))
  puts 'Missing required arguments'
  exit(1)
end

filename = args.shift

#default flag

args.each do |x|
  if (x =~ Regexp.new('(^-[a-bd-ln-oq-ux-z]$)'))
    puts "Invalid option"
  end
end

if not(args.include?('-v') or args.include?('-p') or args.include?('-w'))
  args.unshift('-p')
end


def hasFlag(arr, flag)
  arr.each do |x|
    return true if x==flag
  end
  return false
end

def getPatten(arr)
  arr.each do |x|
    return x if x[0] != '-'
  end
  return nil
end


def getRE(args)

  args. each do |x|
    case x
      when "-p"
        #-p and -v flag contradict each other
        if hasFlag(args, "-v")
          puts "Invalid combination of options"
          exit(1)
        end
        if hasFlag(args, "-w")
          puts "Invalid combination of options"
          exit(1)
        end
        pattern = getPatten(args)
        #exit if no pattern is provided
        exit(1) if pattern.nil?
        return Regexp.new("#{pattern}")

      when "-w"
        #-p and -v flag contradict what -w should do
          if hasFlag(args, "-p")
            puts "Invalid combination of options"
            exit(1)
          end
          if hasFlag(args, "-v")
            puts "Invalid combination of options"
            exit(1)
          end

          pattern = getPatten(args)
          #exit if no pattern is provided
          exit(1) if pattern.nil?

          return Regexp.new("\\b#{pattern}\\b")

      when "-v"
        #-p and -v flag contradict each other
        if hasFlag(args, "-p")
          puts "Invalid combination of options"
          exit(1)
        end
        if hasFlag(args, "-w")
          puts "Invalid combination of options"
          exit(1)
        end
        if hasFlag(args, "-m")
          puts "Invalid combination of options"
          exit(1)
        end

        pattern = getPatten(args)
        #exit if no pattern is provided
        exit(1) if pattern.nil?
        return Regexp.new("#{pattern}")

      when "-c"
        if hasFlag(args, "-m")
          puts "Invalid combination of options"
          exit(1)
        end
        next
      when "-m"
        if hasFlag(args, "-c")
          puts "Invalid combination of options"
          exit(1)
        end
        next
      else
        puts "Invalid option"
        exit(1)
    end
  end
end

#main
regex = getRE(args)
notMatch = hasFlag(args, '-v')
File.open(filename, "r") do |aFile|
  if hasFlag(args, '-c')
    total = 0
    aFile.each_line do|line|
      if notMatch
        total+= 1 if line !~regex
      else
        total+= 1 if line =~regex
      end
    end
    puts total
  elsif hasFlag(args, '-m')
    aFile.each_line do|line|
      puts $& if line =~regex
    end
  else
    aFile.each_line do|line|
      if notMatch
        puts line if line !~regex
      else
        puts line if line =~regex
      end
    end
  end
end
