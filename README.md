# Dssentinel

Simple archiving tool covering 2 cases:

- Move content that older than given date to archive directory.
- Keep only given number of files in current directory, by moving the oldest files to archive directory

# Usage:

`perl archive.pl -s /source/dir -d /destination/dir [-l <leave-number-of-last-files> ] [-o <YYYY-MM-DD hh:mm:ss> ] [ -k "keep_file1,keep_file2" ]`

`-s` - source directory from where unnecessary files are moved
`-d` - destination archive directory where unnecessary files are stored

`-l` - keeps number argument, that specifies the number of files being left in current directory. Older files are moved, newer kept.

`-d` - keeps date string argument like '2022-01-01 10:00:00'. All files changed before this date are moved to archive directory.

`-k` - comma-separated list of filenames, that must be left in source directory untouched, reagrdless on how old it is. You can use backslash to escape commas if it presented in filename.

