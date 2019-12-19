#!/usr/bin/env ruby

require 'digest/md5'
require 'set'

class PrintDeepFilestructuresMD5
end

class BitmapsSanitycheck

  def initialize(md5, files, bitmaps)
    @md5 = md5
    @files = files
    @bitmaps = bitmaps
  end

  def update(file, bitmap)
    @files += [file]
    @bitmaps += [bitmap]
  end

  def assert_different_bitmaps
    if @files.length > 1
      s = Set.new([@bitmaps])
      if @bitmaps.length != s.size
        printf "Found (#{@files.length}) files with the same MD5: #{@md5}:\n"
        @files.each { |f|
          printf "#{f} \n"
        }
      end
    end
  end
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

def x.sanity_check(base_dir, file_name_pattern)
  files = Dir[File.join(base_dir, '**', file_name_pattern)].select { |f| File.file? f }.map { |f| File.expand_path f }

  file_bitmap_mapping = Hash::new
  files.each { |f|
    f_md5 = Digest::MD5.hexdigest(File.read f)
    sanitycheck = file_bitmap_mapping[f_md5]
    sanitycheck = BitmapsSanitycheck::new(f_md5, [], []) if sanitycheck == nil
    sanitycheck.update(f, File.read(f))
    file_bitmap_mapping[f_md5] = sanitycheck
  }

  file_bitmap_mapping.each_pair { |k, v|
    v.assert_different_bitmaps
  }
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

=begin
# Ruby feature which is not in Java because Array has not content-based Object.equals() method
a = [1, 2]
b = [2, 3]
c = [1, 2]
s = Set::new
s.add(a)
s.add(b)
s.add(c)
printf "\n#{s.size} is 2 and not 3"
s = Set.new([[1, 2], [2, 3], [1, 2]])
printf "\n#{s.size} is 2 and not 3"
=end

assert ARGV.length <= 2, 'Expected one or two arguments.'
base_dir = ARGV.length == 2 ? ARGV.first : '.'
file_name_pattern = ARGV.last

x.sanity_check(base_dir, file_name_pattern)
x.print_checksums(base_dir, file_name_pattern)
