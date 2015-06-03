#!/usr/bin/perl

# Expects as input the output of the command
# git log --name-status --format=";;%p;;%ai;;%an;;%s";

$_ = <>;
while (/^;;/) {
	#print "Inspecting $_...\n";
	m/^;;(.*?);;(.*?);;(.*?);;(.*)/ or die "Bad line '$_'";
	($hash, $time, $name, $subject) = ($1, $2, $3, $4);
	$_ = <>;
	/^$/ or die "Unexpected non-empty line '$_'\n";
	print "  * $time <cite>$subject</cite><br>by $name\n";
	while (<>) {
		last if /^;;/;
		/^(\S+)\s+(\S+)/ or die "Undexpected non-numstat line '$_'\n";
		($t, $file) = ($1, $2, $3);
		next unless $t =~ /^[AM]$/;
		next unless $file =~ /^(.*?)\.md$/;
		next if $file eq "nav.md";
		$type = $t eq "A" ? "New article" : "Edited";
		print "    * $type [$1]($1.html)\n";
	}
}
