#!/usr/bin/env ruby

require 'digest/md5'

class PrintDeepFilestructuresMD5
end

x = PrintDeepFilestructuresMD5.new

# @param [String] base_dir             path to the file system structure, optionally absolute
# @param [String] file_name_pattern    the regex pattern for file name including the extension
# @return [Map] file name mapped to array of MD5 hexa strings
def x.group_file_md5(base_dir, file_name_pattern)
  files = Dir[File.join(base_dir, '**', file_name_pattern)].select { |f| File.file? f }.map { |f| File.expand_path f }

  file_name_mapping = Hash::new
  files.each { |f|
    f_name = File.basename f
    hashes = file_name_mapping[f_name]
    f_md5 = Digest::MD5.hexdigest(File.read(f))
    if hashes == nil
      hashes = [f_md5]
    else
      hashes.push(f_md5)
    end
    file_name_mapping[f_name] = hashes
  }
  file_name_mapping
end

# @param [String] base_dir             path to the file system structure, optionally absolute
# @param [String] file_name_pattern    the regex pattern for file name including the extension
def x.print_checksums(base_dir, file_name_pattern)
  file_name_mapping = self.group_file_md5(base_dir, file_name_pattern)
  file_name_mapping.keys.sort.each{|f|
    h = file_name_mapping[f]
    printf "\n"
    printf f
    printf "\n"
    h.each { |c|
      printf '    MD5: '
      printf c
      printf "\n"
    }
  }
end

def assert(success, err_msg)
  raise err_msg unless success
end

assert ARGV.length <= 2, 'Expected one or two arguments.'
base_dir = ARGV.length == 2 ? ARGV.first : '.'
file_name_pattern = ARGV.last

x.print_checksums(base_dir, file_name_pattern)
