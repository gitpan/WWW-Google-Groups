# $Id: Article.pm,v 1.5 2003/09/14 08:09:43 cvspub Exp $
package WWW::Google::Groups::Article;
use strict;
our $VERSION = '0.01';

use Email::Simple;

sub new {
    my ($pkg, $message) = @_;
    return Email::Simple->new($$message) if $$message;
    undef;
}


__END__
