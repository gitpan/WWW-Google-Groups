# $Id: Article.pm,v 1.3 2003/09/04 07:32:23 cvspub Exp $
package WWW::Google::Groups::Article;
use strict;
our $VERSION = '0.01';

use Email::Simple;

sub new {
    my ($pkg, $message) = @_;
    return unless $$message;
    my $mail = Email::Simple->new($$message);
}


__END__
