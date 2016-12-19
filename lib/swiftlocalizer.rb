# coding: utf-8
require "swiftlocalizer/version"
require "optparse"

module Swiftlocalizer
  class LocalizedString
    def initialize(en, ja, filename, lineno)
      @en = en
      @ja = ja
      @filename = filename
      @lineno = lineno
    end
    attr_accessor :en, :ja
    attr_accessor :filename, :lineno
    def to_s
      "#{@en},#{@ja},#{@filename},#{@lineno}"
    end

    def to_short_s
      "#{@en} #{@ja} #{File.basename(@filename)}:#{@lineno}"
    end    
  end

  class Command
    def self.get_localized_strings_from_file(file)
      get_localized_strings_from_lines(File.readlines(file), file)
    end

    def self.get_localized_strings_from_lines(lines, file)
      strings = []
      lines.each_with_index do |line, index|
        strings.concat(get_localized_strings_from_line(line, file, index))
      end
      strings
    end

    def self.get_localized_strings_from_line(line, file, index)
      strings = []
      while line =~ /NSLocalizedString\("([^"]+)",\s*comment:\s*"([^"]+)"\)/
        string = LocalizedString.new($1, $2, file, index)
        strings << string
        line = $'
      end
      strings
    end
    
    def self.run(argv)
      STDOUT.sync = true
      opts = {}
      opt = OptionParser.new(argv)
      opt.banner = "Usage: #{opt.program_name} [-h|--help] [config.yml]"
      opt.version = Swiftlocalizer::VERSION
      opt.separator('')
      opt.separator "Options:"
      opt.on_head('-h', '--help', 'Show this message') do |v|
        puts opt.help
        exit
      end
      opt.on('-v', '--verbose', 'Verbose message') {|v| opts[:v] = v}
      opt.on('-n', '--dry-run', 'Message only') {|v| opts[:n] = v}
#      opt.on('-f', '--force-import', 'Force import') {|v| opts[:f] = v}
      opt.parse!(argv)
      dir = ARGV.shift || '.'
      command = Command.new(opts, dir)
      command.run
    end

    def initialize(opts, dir)
      @opts = opts
      @dir = dir
    end

    def run
      strings = scan_sources

      check_duplicate(strings)
      
      basename = 'Localizable.strings'
      
      path = File.join(@dir, 'Base.lproj', basename)
      write_localizable_strings(strings, path, :en)
      
      path = File.join(@dir, 'ja.lproj', basename)      
      write_localizable_strings(strings, path, :ja)
    end

    private
    def scan_sources
      puts "Scan #{@dir}"  
      strings = []
      Dir.glob(@dir + '/**/*.swift').each do |f|
        puts f
        file_strings = Command.get_localized_strings_from_file(f)
        puts "retrieve #{file_strings.size} strings"
        file_strings.each{|str| puts "\t#{str.en} #{str.ja} #{str.lineno}\n"}
        strings.concat(file_strings)
      end
      strings
    end

    def check_duplicate(strings)
      puts "Check duplicate"
      hash_en = {}
      strings.each do |str|
        exists = hash_en[str.en]
        if exists
          puts "\t" + exists.to_short_s + " <=> " + str.to_short_s + "\n"
        else
          hash_en[str.en] = str
        end
      end
    end

    def write_localizable_strings(strings, path, sym)
      puts "Write #{path}" 
      unless FileTest.file?(path)
        raise RuntimeError, "#{path} doesn't exist."
      end
      File.open(path, 'w') do |f|
        strings.each do |str|
          en = str.send(:en)
          localized = str.send(sym.to_sym)
          f.puts "\"#{en}\" = \"#{localized}\";"
        end
      end
    end
  end
end

