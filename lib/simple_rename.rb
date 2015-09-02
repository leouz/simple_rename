require "simple_rename/version"
require 'paint'

module SimpleRename
  
  class Process
    def initialize str
      @command, @from, @to = str.split(':')
    end

    def process rename_unit
      if @command == "-replace"
        rename_unit.new_path = rename_unit.old_path.dup
        rename_unit.new_path.gsub! @from, @to

        if rename_unit.is_diff
          rename_unit.old_path_with_color = rename_unit.old_path.dup
          rename_unit.old_path_with_color.gsub! @from, Paint[@from, :red]
          
          rename_unit.new_path_with_color = rename_unit.old_path.dup
          rename_unit.new_path_with_color.gsub! @from, Paint[@to, :yellow]
        end        
      end
    end
  end

  class RenameUnit
    attr_accessor :new_path, :old_path, :old_path_with_color, :new_path_with_color

    def initialize path
      @old_path = path        
    end

    def is_diff
      @old_path != @new_path      
    end    
  end

  def self.rename args
    processes = []
    units = []
    commit = false
    
    args.each do |a|
      if a == "-commit"
        commit = true
      elsif a.start_with? "-"
        processes << Process.new(a)
      else
        units << RenameUnit.new(a)
      end
    end

    units.each do |u|
      processes.each do |p|
        p.process u
      end      
      
      if u.is_diff
        puts "old: " + u.old_path_with_color
        puts "new: " + u.new_path_with_color
        if commit
          File.rename(u.old_path, u.new_path)
          puts " ** renamed ** \n"
        end

        puts "\n"
      end

    end
  end

end