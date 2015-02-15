require '../lib/checkstyle_filter/git'

# format examples:
# https://gist.github.com/sanemat/5416e4f701922a47773a

# git diff -z --name-only origin/master..HEAD \
# | xargs -0 bundle exec rubocop-select \
# | xargs rubocop \
#     --require rubocop/formatter/checkstyle_formatter \
#     --format RuboCop::Formatter::CheckstyleFormatter \
# | checkstyle_filter-git diff origin/master..HEAD

# raw_xml
# git_diff file_name, line_no_start, line_no_end
# git_diff.files.each |file|
#   file.lines = Set[1,2,5]
# end
# reformed = raw_xml.check_style.file=file.line[1,2,5]
# reformed.to_xml
