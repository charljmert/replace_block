#!/bin/perl
# This script will perform a global replace of files which contain the block of text specified in your block file
# The block file can contain regex per line (for the whole file)

use POSIX 'strftime';
use File::Basename;
use Getopt::Long qw(GetOptions);

my $usage = <<END;
Usage: $0 [block file] [source-dir] [search-pattern]
Options:
	--replace-with file or text string to replace block with. use '\n' to delete the line -> this is default
	--log-date-format strftime compatible format e.g. '%Y-%m-%d %H:%M:%S'
	--search find iname paramater e.g. "*.php" or "" for all files
	--convert yes,  to specify that the source block.txt file will be converted to regex
	--raw-regex yes,  to specify raw regex lines in block file
END

if (@ARGV < 2) {
	print $usage;
	exit 1
}

my $date_format = '%Y-%m-%d %H:%M:%S';
my $search = '*.eml';
my $replace_with = '\n';
my $raw_regex = 0;
my $convert = 0;

GetOptions(
	'log-date-format=s' => \$date_format,
	'search=s' => \$search,
	'replace-with=s' => \$replace_with,
	'raw-regex' => \$raw_regex,
	'convert' => \$convert,
);

my $search_file = $ARGV[0];
my $source_dir = $ARGV[1];

my @block = ();

my $i = 0;
# read the block to search for
if (open(my $fh, '<:encoding(UTF-8)', $search_file)) {
	while (my $row = <$fh>) {
		chomp $row;
		$block[$i] = $row;

		if ($convert == 1) {
			print quotemeta($row) . "\n";
		}

		$i++;
	}
} else {
	my $date = strftime $date_format, localtime;
	warn $date . ",ERROR,could not open file, '$search_file' $!\n";
	exit(1);
}

if ($convert == 1) {
	exit(0);
}

my $block_line_count = $#block;

my $path = '';

foreach $file (split (/\n/,  `find "$source_dir" -type f -iname "$search"`)) {
	chomp($file);
	$pass = 1;

	# skip directories
	next unless -f $file;

	$path = dirname($file);
	$path =~ s{$source_dir/}{}g;
	if ($path =~ /^\.\.$/) {
		next;
	}

	$replace_with = '';
	my $replace_count = replace_text_block($file, $replace_with);

	print $file . ',[' . $replace_count . ']' . "\n";
}

sub replace_text_block() {
	my ($file, $replace_with) = @_;

	my $stat_replace_count = 0;

	my @buff = ();
	my @irem = ();
	$i = 0;
	if (open(my $fh, '<:encoding(UTF-8)', $file)) {
		while (my $row = <$fh>) {
			chomp $row;
			#print "$row\n";
			$buff[$i] = $row;
			$irem[$i] = 0;

			$match_count = 0;
			if ($i >= $block_line_count) {

				my @conditionals = ();
				my $y = 0;
				for (my $x = ($i - $block_line_count); $x <= $i; $x++) {
					#print "counter i         : $i\n";
					#print "block_line_count  : $block_line_count\n";
					#print "(i % block_line_count):" + $i % $block_line_count . "\n";

					my $search_line = $block[$x - $i - 1];

					if ($raw_regex == 0) {
						$search_line = quotemeta($search_line);
					}

					#print "search_line[$i|$x]: $search_line || $buff[$x]\n";
					#print "$buff[$x]\n";

					$conditionals[$y] = ($buff[$x] =~ /$search_line/);
					$y++;
				}

				#print 'count: ' . $#conditionals. "\n";
				$y = 0;
				my $pass = 1;
				foreach (@conditionals) {
					#print "$y: $_\n";
					if ($_ != 1) {
						$pass = 0;
					}
					$y++;
				}
				
				if ($pass == 1) {
					my $y = 0;
					for (my $x = ($i - $block_line_count); $x <= $i; $x++) {
						$irem[$x] = 1;
						$y++;
					}

					$stat_replace_count++;
				}
			}

			$i++;
		}

		close($fh) || warn "$file, AFTER_READ, Couldn't close file properly";

		if ($stat_replace_count > 0) {
			$y = 0;
			open (my $fh, ">$file") or die $!;
			foreach my $output_line (@buff) {
				if ($irem[$y] == 0) {
					printf $fh $buff[$y] . "\n";
				}
				$y++;
			}

			close($fh) || warn "$file AFTER_WRITE, Couldn't close file properly";
		}

	} else {
		my $date = strftime $date_format, localtime;
		warn $date . ",WARN,could not open file, '$file' $!\n";
	}

	return $stat_replace_count;
}
