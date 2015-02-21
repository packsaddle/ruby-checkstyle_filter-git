# CheckstyleFilter::Git

[![Gem Version](http://img.shields.io/gem/v/checkstyle_filter-git.svg?style=flat)](http://badge.fury.io/rb/checkstyle_filter-git)
[![Build Status](http://img.shields.io/travis/packsaddle/ruby-checkstyle_filter-git/master.svg?style=flat)](https://travis-ci.org/packsaddle/ruby-checkstyle_filter-git)

## What is this?

1. checkstyle format errors

```xml
<?xml version='1.0'?>
<checkstyle>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/checkstyle_filter-git.gemspec'/>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/Gemfile'/>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/bin/console'/>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/example/invalid.rb'>
    <error line='3' column='100' severity='info' message='Line is too long. [188/100]' source='com.puppycrawl.tools.checkstyle.Metrics/LineLength'/>
  </file>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/exe/checkstyle_filter-git'/>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/lib/checkstyle_filter/git/cli.rb'>
    <error line='14' column='6' severity='info' message='Assignment Branch Condition size for diff is too high. [54.73/15]' source='com.puppycrawl.tools.checkstyle.Metrics/AbcSize'/>
  </file>
<checkstyle>
```

2. git diff

```diff
diff --git a/example/invalid.rb b/example/invalid.rb
new file mode 100644
index 0000000..b13da3a
--- /dev/null
+++ b/example/invalid.rb
@@ -0,0 +1,5 @@
+class Invalid
+  def foo
+    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
+  end
+end
diff --git a/lib/checkstyle_filter/git/cli.rb b/lib/checkstyle_filter/git/cli.rb
index 6d503a3..e45bdef 100644
--- a/lib/checkstyle_filter/git/cli.rb
+++ b/lib/checkstyle_filter/git/cli.rb
@@ -61,10 +61,12 @@ def file_element_file_in_git_diff?(file_name, parsed_git_diff)
             .include?(Pathname.new(file_name).expand_path)
         end

-        def file_element_error_line_no_in_modified?(file_name, parsed_git_diff, line)
+        def file_element_error_line_no_in_modified?(file_name, parsed_git_diff, line_no)
           require 'pathname'
           diff_pairs = parsed_git_diff
-                       .select { |diff| Pathname.new(diff[:file_name]).expand_path == Pathname.new(file_name).expand_path }
+                       .select do |diff|
+            Pathname.new(diff[:file_name]).expand_path == Pathname.new(file_name).expand_path
+          end
           return false if diff_pairs.empty?
           modified_lines = Set.new
           diff_pairs.map do |diff_pair|
@@ -72,7 +74,7 @@ def file_element_error_line_no_in_modified?(file_name, parsed_git_diff, line)
               modified_lines << line.number
             end
           end
-          modified_lines.include?(line)
+          modified_lines.include?(line_no)
         end
       end
     end
```

3. filter! output **only errors** on modified lines

```
$ cat checkstyle.xml | checkstyle_filter-git diff HEAD~1..origin/master
```

```xml
<?xml version='1.0'?>
<checkstyle>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/checkstyle_filter-git.gemspec'/>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/Gemfile'/>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/bin/console'/>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/example/invalid.rb'>
    <error line='3' column='100' severity='info' message='Line is too long. [188/100]' source='com.puppycrawl.tools.checkstyle.Metrics/LineLength'/>
  </file>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/exe/checkstyle_filter-git'/>
  <file name='/Users/sane/work/ruby-study/checkstyle_filter-git/lib/checkstyle_filter/git/cli.rb'>
  </file>
<checkstyle>
```

## Expected usage

```
git diff -z --name-only origin/master.. \
 | xargs -0 rubocop-select \
 | xargs rubocop \
     --require rubocop/formatter/checkstyle_formatter \
     --format RuboCop::Formatter::CheckstyleFormatter \
 | checkstyle_filter-git diff origin/master.. \
 | saddler report \
     --require github/pull-request-comment-formatter \
     --format Github::PullRequestCommentFormatter
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'checkstyle_filter-git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install checkstyle_filter-git

## Help

```
$ checkstyle_filter-git
Commands:
  checkstyle_filter-git diff            # Filter using `git diff`
  checkstyle_filter-git help [COMMAND]  # Describe available commands or one specific command
  checkstyle_filter-git version         # Show the CheckstyleFilter/Git version

$ checkstyle_filter-git help diff
Usage:
  checkstyle_filter-git diff

Options:
  [--data=DATA]
  [--file=FILE]

Filter using `git diff`
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec checkstyle_filter-git` to use the code located in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/packsaddle/ruby-checkstyle_filter-git/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
