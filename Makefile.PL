# $Id: Makefile.PL,v 1.4 2003/09/14 08:09:43 cvspub Exp $
use ExtUtils::MakeMaker;
$proxy = prompt("Please set your PROXY server for faster testing:");
open F, '>', '.proxy';
print F $proxy.$/;
close F;
WriteMakefile(
	      'NAME'		=> 'WWW::Google::Groups',
	      'VERSION_FROM'	=> 'Groups.pm', 
	      'PREREQ_PM'		=> {
		  qw(
		   WWW::Mechanize 0.5
		   Email::Simple  1.6
		   Date::Parse    2.24
		     )
		  }, 
	      ($] >= 5.005 ?    
	       (ABSTRACT_FROM => 'Groups.pm', 
		AUTHOR     => 'xern <xern@cpan.org>') : ()),
);
