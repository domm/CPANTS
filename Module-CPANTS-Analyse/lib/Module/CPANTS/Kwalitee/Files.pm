package Module::CPANTS::Kwalitee::Files;
use warnings;
use strict;
use File::Find::Rule;
use File::Spec::Functions qw(catdir catfile abs2rel splitdir);
use File::stat;
use File::Basename;
use Data::Dumper;
use Readonly;
use Software::LicenseUtils;
use File::Slurp            qw(slurp);

sub order { 10 }

##################################################################
# Analyse
##################################################################

Readonly::Scalar my $large_file => 200_000;

my %generated_db_files;

sub analyse {
    my $class=shift;
    my $me=shift;
    my $distdir=$me->distdir;
    
    my @files = File::Find::Rule->file()->relative()->in($distdir);
    my @dirs  = File::Find::Rule->directory()->relative()->in($distdir);
    #my $unixy=join('/',splitdir($File::Find::name));

    my $size = 0;
    my %files;
    my %licenses;
    foreach my $name (@files) { 
        my $path = catfile($distdir, $name);
        $files{$name}{size} += -s $path || 0;
        $size += $files{$name}{size};

        if ($name =~ /\.(pl|pm|pod)$/) {
            my $text = slurp($path);
            my $license = Software::LicenseUtils->guess_license_from_pm($text);
            if ($license) {
                $licenses{$license} = $name;
                $files{$name}{license} = $license;
            }
        }
    }
    if (%licenses) {
        $me->d->{licenses} = \%licenses;
        if (keys %licenses == 1) {
            my ($type) = keys %licenses;
            $me->d->{license_type} = $type;
            $me->d->{license_file} = $licenses{$type};
        }
    }

    #die Dumper \%files;
    $me->d->{size_unpacked}=$size;

    $me->d->{files}=\%files;
    $me->d->{dirs}=\@dirs;

    # find symlinks
    my @symlinks;
    foreach my $f (@dirs, @files) {
        my $p=catfile($distdir,$f);
        if (-l $f) {
            push(@symlinks,$f);
        }
    }

    # store stuff
    $me->d->{files}=scalar @files;
    $me->d->{files_list}=join(';',@files);
    $me->d->{files_array}=\@files;
    $me->d->{files_hash}=\%files;
    $me->d->{dirs}=scalar @dirs;
    $me->d->{dirs_list}=join(';',@dirs);
    $me->d->{dirs_array}=\@dirs;
    $me->d->{symlinks}=scalar @symlinks;
    $me->d->{symlinks_list}=join(';',@symlinks);

    # find special files
    my %reqfiles;
    my @special_files=(qw(Makefile.PL Build.PL META.yml SIGNATURE MANIFEST NINJA test.pl LICENSE LICENCE));
    map_filenames($me, \@special_files, \@files);
    my @generated_files=qw(Build Makefile _build blib pm_to_blib); # files that should not...
    %generated_db_files=map_filenames($me, \@generated_files, \@files);

    # find more complex files
    my %regexs=(
        file_changelog=>qr{^chang|history}i,
        file_readme=>qr{^readme(?:\.txt)?}i,
    );
    while (my ($name,$regex)=each %regexs) {
        $me->d->{$name}=join(',',grep {$_=~/$regex/} @files);
    }
    
    # find special dirs
    my @special_dirs=(qw(lib t xt));
    foreach my $dir (@special_dirs){
        my $db_dir="dir_".$dir;
        $me->d->{$db_dir}=((grep {$_ eq "$dir"} @dirs)?1:0);
    }
    
    # get mtime
    my $mtime=0;
    foreach (@files) {
        next if /\//;
        my $to_stat=catfile($distdir,$_);
        next unless -e $to_stat; # TODO hmm, warum ist das kein File?
        my $stat=stat($to_stat);
        my $thismtime=$stat->mtime;
        $mtime=$thismtime if $mtime<$thismtime;
    }
    #$me->d->{released_epoch}=$mtime;
    $me->d->{released}=scalar localtime($mtime);
   
    # Check permissions of Build.PL/Makefile.PL
    {
        my $build_exe=0;

        $build_exe=1 if ($me->d->{file_makefile_pl} && -x catfile($me->distdir,'Makefile.PL'));
        $build_exe=2 if ($me->d->{file_build_pl} && -x catfile($me->distdir,'Build.PL'));
        $build_exe=3 unless ($me->d->{file_makefile_pl} || $me->d->{file_build_pl});
        $me->d->{buildfile_executable}=$build_exe;
    }

    # check STDIN in Makefile.PL and Build.PL 
    # objective: convince people to use prompt();
    # http://www.perlfoundation.org/perl5/index.cgi?cpan_packaging
    {
        foreach my $file ('Makefile.PL', 'Build.PL') {
            (my $handle = $file) =~ s/\./_/;
            $handle = "stdin_in_" . lc $handle;
            my $path = catfile($me->distdir,$file);
            next if not -e $path;
            if (open my $fh, '<', $path) {
                if (grep {/<STDIN>/} <$fh>) {
                    $me->d->{$handle} = 1;
                }
            }
        } 
    } 
    return;
}

sub map_filenames {
    my ($me, $special_files, $files) = @_;
    my %ret;
    foreach my $file (@$special_files){
        (my $db_file=$file)=~s/\./_/g;
        $db_file="file_".lc($db_file);
        $me->d->{$db_file}=((grep {$_ eq "$file"} @$files)?1:0);
        $ret{$db_file}=$file;
    }
    return %ret;
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators {
  return [
    {
        name=>'extractable',
        error=>q{This package uses an unknown packaging format. CPANTS can handle tar.gz, tgz and zip archives. No kwalitee metrics have been calculated.},
        remedy=>q{Pack the distribution with tar & gzip or zip.},
        code=>sub { shift->{extractable} ? 1 : -100 },
    },
    {
        name=>'extracts_nicely',
        error=>q{This package doesn't create a directory and extracts its content into this directory. Instead, it spews its content into the current directory, making it really hard/annoying to remove the unpacked package.},
        remedy=>q{Issue the command to pack the distribution in the directory above it. Or use a buildtool ('make dist' or 'Build dist')},
        code=>sub { shift->{extracts_nicely} ? 1 : 0},
    },
    {
        name=>'has_readme',
        error=>q{The file 'README' is missing from this distribution. The README provide some basic information to users prior to downloading and unpacking the distribution.},
        remedy=>q{Add a README to the distribution. It should contain a quick description of your module and how to install it.},
        code=>sub { shift->{file_readme} ? 1 : 0 },
    },
    {
        name=>'has_manifest',
        error=>q{The file 'MANIFEST' is missing from this distribution. The MANIFEST lists all files included in the distribution.},
        remedy=>q{Add a MANIFEST to the distribution. Your buildtool should be able to autogenerate it (eg 'make manifest' or './Build manifest')},
        code=>sub { shift->{file_manifest} ? 1 : 0 },
    },
    {
        name=>'has_meta_yml',
        error=>q{The file 'META.yml' is missing from this distribution. META.yml is needed by people maintaining module collections (like CPAN), for people writing installation tools, or just people who want to know some stuff about a distribution before downloading it.},
        remedy=>q{Add a META.yml to the distribution. Your buildtool should be able to autogenerate it.},
        code=>sub { shift->{file_meta_yml} ? 1 : 0 },
    },
    {
        name=>'has_buildtool',
        error=>q{Makefile.PL and/or Build.PL are missing. This makes installing this distribution hard for humans and impossible for automated tools like CPAN/CPANPLUS},
        remedy=>q{Use a buildtool like Module::Build (recomended) or ExtUtils::MakeMaker to manage your distribution},
        code=>sub {
            my $d=shift;
            return 1 if $d->{file_makefile_pl} || $d->{file_build_pl};
            return 0;
        },
    },
    {
        name=>'has_changelog',
        error=>q{The distribution hasn't got a Changelog (named something like m/^chang(es?|log)|history$/i. A Changelog helps people decide if they want to upgrade to a new version.},
        remedy=>q{Add a Changelog (best named 'Changes') to the distribution. It should list at least major changes implemented in newer versions.},
        code=>sub { shift->{file_changelog} ? 1 : 0 },
    },
    {
        name=>'no_symlinks',
        error=>q{This distribution includes symbolic links (symlinks). This is bad, because there are operating systems that do not handle symlinks.},
        remedy=>q{Remove the symlinkes from the distribution.},
        code=>sub {shift->{symlinks} ? 0 : 1},
    },
    {
        name=>'has_tests',
        error=>q{This distribution doesn't contain either a file called 'test.pl' or a directory called 't'. This indicates that it doesn't contain even the most basic test-suite. This is really BAD!},
        remedy=>q{Add tests!},
        code=>sub {
            my $d=shift;
            return 1 if $d->{file_test_pl} || $d->{dir_t};
            return 0;
        },
    },
    {
        name=>'has_tests_in_t_dir',
        is_extra=>1,
        error=>q{This distribution contains either a file called 'test.pl' (the old test file) or is missing a directory called 't'. This indicates that it uses the old test mechanism or it has no test-suite.},
        remedy=>q{Add tests or move tests.pl to the t/ directory!},
        code=>sub {
            my $d=shift;
            return 1 if !$d->{file_test_pl} && $d->{dir_t};
            return 0;
        },
    },
    {
        name=>'buildtool_not_executable',
        error=>q{The buildtool (Build.PL/Makefile.PL) is executable. This is bad, because you should specifiy which perl you want to use while installing.},
        remedy=>q{Change the permissions of Build.PL/Makefile.PL to not-executable.},
        code=>sub {shift->{buildfile_executable} ? 0 : 1},
    },
    {
        name=>'has_example',
        is_extra=>1,
        error=>'This distribution does not include examples.',
        remedy=>q{Add a directory matching the regex (bin|scripts?|ex|eg|examples?|samples?|demos?) or a file matching the regex /\/(examples?|samples?|demos?)\.p(m|od)$/i to your distribution that includes some scripts showing one or more use-cases of the distribution. },
        code=>sub {
            my $d=shift;
            return 1 if grep {/^(bin|scripts?|ex|eg|examples?|samples?|demos?)\/\w/i} @{ $d->{files_array} };
            return 1 if grep {/\/(examples?|samples?|demos?)\.p(m|od)$/i} @{ $d->{files_array} };
            return 0;
        },
    },
    {
        name=>'no_generated_files',
        error=>q{This distribution has a file that it should generate and not be distribute.},
        remedy=>q{Remove the offending file!},
        code=>sub {
            my $d=shift;
            #die Dumper \%generated_db_files;
            my @errors = map { $generated_db_files{$_} }
                         grep { $d->{$_} }
                         keys %generated_db_files;
            #die $d->{build};
            if (@errors) {
                $d->{error}{no_generated_files} = join ", ", @errors;
                
                return 0;
            }
            return 1;
        },
    },
    {
        name=>'no_stdin_for_prompting',
        error=>q{This distribution is using direct call from STDIN instead of prompt())},
        is_extra=>1,
        remedy=>q{Use the prompt() method},
        code=>sub {
            my $d=shift;
            if ($d->{stdin_in_makefile_pl}||$d->{stdin_in_build_pl}) {
                $d->{error}{no_stdin_for_prompting} = "Make sure STDIN is not used in Makefile.PL or Build.PL see http://www.perlfoundation.org/perl5/index.cgi?cpan_packaging";
                return 0;
            }
            return 1;
        },
    },
    {
        name=>'no_large_files',
        error=>qq{This distribution has at least one file larger than $large_file bytes)},
        remedy=>q{No remedy for that.},
        is_extra=>1,
        is_experimental=>1,
        code=>sub {
            my $d=shift;
            my @errors = map { "$_:$d->{files_hash}{$_}{size}" }
                         grep { $d->{files_hash}{$_}{size} > $large_file }
                         keys %{ $d->{files_hash} };
            if (@errors) {
                $d->{error}{no_large_files} = join "; ", @errors;
                return 0;
            }
            return 1;
        },
    },
];
}


q{Favourite record of the moment:
  Fat Freddys Drop: Based on a true story};


__END__

=pod

=head1 NAME

Module::CPANTS::Kwalitee::Files - Check for various files

=head1 SYNOPSIS

Find various files and directories that should be part of every self-respecting distribution.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<10>, as data generated by C<MCK::Files> is used by all other tests.

=head3 map_filenames

get db_filenames from real_filenames

=head3 analyse

C<MCK::Files> uses C<File::Find> to get a list of all files and dirs in a dist. It checks if certain crucial files are there, and does some other file-specific stuff.

=head3 get_files

The subroutine used by C<File::Find>. Unfortunantly, it depends on some global values.

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * extractable

=item * extracts_nicely

=item * has_readme

=item * has_manifest

=item * has_meta_yml

=item * has_buildtool

=item * has_changelog 

=item * no_symlinks

=item * has_tests

=item * has_tests_in_t_dir

=item * buildfile_not_executabel

=item * has_example (optional)

=item * no_generated_file

=item * has_version_in_each_file

=item * no_stdin_for_prompting

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

Thomas Klausner, <domm@cpan.org>, http://domm.zsi.at

=head1 COPYRIGHT

You may use and distribute this module according to the same terms
that Perl is distributed under.

=cut
