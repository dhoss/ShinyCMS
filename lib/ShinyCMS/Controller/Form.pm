package ShinyCMS::Controller::Form;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }


=head1 NAME

ShinyCMS::Controller::Form

=head1 DESCRIPTION

Main controller for ShinyCMS's form-handling.

=head1 METHODS

=cut


=head2 index

Forward to the default page if no page is specified.

=cut

sub index : Path : Args(0) {
	my ( $self, $c ) = @_;
	
	$c->response->redirect( $c->uri_for( '/' ) );
}


=head2 base

Set up path and stash some useful stuff.

=cut

sub base : Chained( '/' ) : PathPart( 'form' ) : CaptureArgs( 0 ) {
	my ( $self, $c ) = @_;
	
	# Stash the upload_dir setting
	$c->stash->{ upload_dir } = $c->config->{ upload_dir };
	
	# Stash the public key for reCaptcha
	$c->stash->{ recaptcha_public_key  } = $c->config->{ 'recaptcha_public_key'  };
	$c->stash->{ recaptcha_private_key } = $c->config->{ 'recaptcha_private_key' };
	
	# Stash the controller name
	$c->stash->{ controller } = 'Form';
}


=head2 process

Process a form submission.

=cut

sub process : Chained( 'base' ) : PathPart( '' ) : Args( 1 ) {
	my ( $self, $c, $url_name ) = @_;
	
	# Get the form
	my $form = $c->model( 'DB::CmsForm' )->find({
		url_name => $url_name,
	});
	$c->stash->{ form } = $form;
	
	# Check for recaptcha
	if ( $c->request->param( 'recaptcha_challenge_field' ) ) {
		if ( $c->request->param( 'recaptcha_response_field' ) ) {
			# Recaptcha is present and was filled in - test it!
			my $rc = Captcha::reCAPTCHA->new;
			my $result = $rc->check_answer(
				$c->config->{ 'recaptcha_private_key' },
				$c->request->address,
				$c->request->param( 'recaptcha_challenge_field' ),
				$c->request->param( 'recaptcha_response_field'  ),
			);
			unless ( $result->{ is_valid } ) {
				# Failed recaptcha
				$c->flash->{ error_msg } = 'You did not corrently fill in the required two words.  Please go back and try again.';
				$c->response->redirect( $c->request->referer );
				return;
			}
		}
		else {
			# No attempt to fill in recaptcha - fail without testing
			$c->flash->{ error_msg } = 'You did not fill in the required two words.  Please go back and try again.';
			$c->response->redirect( $c->request->referer );
			return;
		}
	}
	
	# Dispatch to the appropriate form-handling method
	if ( $form->action eq 'Email' ) {
		if ( $form->template ) {
			$c->forward( 'send_email_with_template' );
		}
		else {
			$c->forward( 'send_email_without_template' );
		}
	}
	else {
		warn "We don't have any other types of form-handling yet!";
	}
	
	# Redirect user to an appropriate page
	if ( $c->flash->{ error_msg } ) {
		# Validation failed - reload form
		$c->response->redirect( $c->request->referer );
	}
	elsif ( $form->redirect ) {
		# Redirect to specified destination page, if one is set
		$c->response->redirect( $form->redirect );
	}
	elsif ( $c->request->referer ) {
		# Otherwise, bounce to referring page
		$c->response->redirect( $c->request->referer );
	}
	else {
		# User's browser is hiding referring page info - bounce them to /
		$c->response->redirect( '/' );
	}
}


=head2 send_email_with_template

Process a form submission that sends an email using a template.

=cut

sub send_email_with_template : Private {
	my ( $self, $c ) = @_;
	
	# Build the email
	my $sender;
	if ( $c->request->param( 'meta_from' ) ) {
		if ( $c->request->param( 'meta_name' ) ) {
			$sender = '"'. $c->request->param( 'meta_name' ) .'" '. 
						'<'. $c->request->param( 'meta_from' ) .'>';
		}
		else {
			$sender = $c->request->param( 'meta_from' );
		}
	}
	$sender ||= $c->config->{ email_from };
	my $sender_valid = Email::Valid->address(
		-address  => $sender,
		-mxcheck  => 1,
		-tldcheck => 1,
	);
	unless ( $sender_valid ) {
		$c->flash->{ error_msg } = 'Invalid email address.';
		return;
	}
	my $recipient = $c->stash->{ form }->email_to;
	$recipient  ||= $c->config->{ email_from };
	my $subject   = $c->request->param( 'meta_subject' );
	$subject    ||= 'Email from '. $c->config->{ site_name };
	
	my $email_data = {
		from     => $sender,
		to       => $recipient,
		subject  => $subject,
		template => $c->stash->{ form }->template,
	};
	$c->stash->{ email_data } = $email_data;
	
	# Send the email
	$c->forward( $c->view( 'Email::Template' ) );
}


=head2 send_email_without_template

Process a form submission that sends an email without using a template.

=cut

sub send_email_without_template : Private {
	my ( $self, $c ) = @_;
	
	# Build the email
	my $sender;
	if ( $c->request->param( 'meta_from' ) ) {
		if ( $c->request->param( 'meta_name' ) ) {
			$sender = '"'. $c->request->param( 'meta_name' ) .'" '. 
						'<'. $c->request->param( 'meta_from' ) .'>';
		}
		else {
			$sender = $c->request->param( 'meta_from' );
		}
	}
	$sender ||= $c->config->{ email_from };
	my $recipient = $c->stash->{ form }->email_to;
	$recipient  ||= $c->config->{ email_from };
	my $subject   = $c->request->param( 'meta_subject' );
	$subject    ||= 'Email from '. $c->config->{ site_name };
	
	my $body = "Form data from your website:\n\n";
	
	# Loop through the submitted params, building the message body
	foreach my $key ( sort keys %{ $c->request->params } ) {
		next if $key =~ m/^meta_/;
		next if $key =~ m/^recaptcha_\w+_field$/;
		$body .= $key .":\n". $c->request->param( $key ) ."\n\n";
	}
	
	my $email_data = {
		from    => $sender,
		to      => $recipient,
		subject => $subject,
		body    => $body,
	};
	$c->stash->{ email_data } = $email_data;
	
	# Send the email
	$c->forward( $c->view( 'Email' ) );
}



=head2 list_forms

List forms for admin interface.

=cut

sub list_forms : Chained( 'base' ) : PathPart( 'list' ) : Args( 0 ) {
	my ( $self, $c ) = @_;
	
	# Bounce if user isn't logged in
	unless ( $c->user_exists ) {
		$c->stash->{ error_msg } = 'You must be logged in to edit CMS forms.';
		$c->go( '/user/login' );
	}
	
	# Bounce if user isn't a CMS form admin
	unless ( $c->user->has_role( 'CMS Form Admin' ) ) {
		$c->stash->{ error_msg } = 'You do not have the ability to edit CMS forms.';
		$c->response->redirect( '/' );
	}
	
	my @forms = $c->model( 'DB::CmsForm' )->search;
	$c->stash->{ forms } = \@forms;
}


=head2 add_form

Add a new form.

=cut

sub add_form : Chained( 'base' ) : PathPart( 'add' ) : Args( 0 ) {
	my ( $self, $c ) = @_;
	
	# Bounce if user isn't logged in
	unless ( $c->user_exists ) {
		$c->stash->{ error_msg } = 'You must be logged in to add CMS forms.';
		$c->go( '/user/login' );
	}
	
	# Bounce if user isn't a CMS form admin
	unless ( $c->user->has_role( 'CMS Form Admin' ) ) {
		$c->stash->{ error_msg } = 'You do not have the ability to add CMS forms.';
		$c->response->redirect( '/' );
	}
	
	# Fetch the list of available templates
	$c->stash->{ templates } = get_template_filenames();
	
	# Set the TT template to use
	$c->stash->{template} = 'form/edit_form.tt';
}


=head2 edit_form

Edit an existing form.

=cut

sub edit_form : Chained( 'base' ) : PathPart( 'edit' ) : Args( 1 ) {
	my ( $self, $c, $url_name ) = @_;
	
	# Get the form
	my $form = $c->model( 'DB::CmsForm' )->find({
		url_name => $url_name,
	});
	$c->stash->{ form } = $form;
	
	# Bounce if user isn't logged in
	unless ( $c->user_exists ) {
		$c->stash->{ error_msg } = 'You must be logged in to edit CMS forms.';
		$c->go( '/user/login' );
	}
	
	# Bounce if user isn't a CMS form admin
	unless ( $c->user->has_role( 'CMS Form Admin' ) ) {
		$c->stash->{ error_msg } = 'You do not have the ability to edit CMS forms.';
		$c->response->redirect( '/' );
	}
	
	# Fetch the list of available templates
	$c->stash->{ templates } = $c->forward( 'get_template_filenames' );
}
	

=head2 edit_form_do

Process a form edit.

=cut

sub edit_form_do : Chained( 'base' ) : PathPart( 'edit-form-do' ) : Args( 0 ) {
	my ( $self, $c ) = @_;
	
	# Check to make sure user has the right to edit CMS forms
	die unless $c->user->has_role( 'CMS Form Admin' );	# TODO
	
	# Fetch the form, if one was specified
	my $form;
	if ( $c->request->param( 'form_id' ) ) {
		$form = $c->model( 'DB::CmsForm' )->find({
			id => $c->request->param( 'form_id' ),
		});
	}
	
	# Process deletions
	if ( defined $c->request->params->{ delete } && $c->request->param( 'delete' ) eq 'Delete' ) {
		$form->delete;
		
		# Shove a confirmation message into the flash
		$c->flash->{ status_msg } = 'Page deleted';
		
		# Bounce to the list of CMS forms
		$c->response->redirect( $c->uri_for( 'list' ) );
		return;
	}
	
	# Extract form details from request
	my $details = {
		name     => $c->request->param( 'name'     ) || undef,
		redirect => $c->request->param( 'redirect' ) || undef,
		action   => $c->request->param( 'action'   ) || undef,
		template => $c->request->param( 'template' ) || undef,
	};
	
	# Sanitise the url_name
	my $url_name = $c->request->param( 'url_name' );
	$url_name  ||= $c->request->param( 'name'     );
	$url_name   =~ s/\s+/-/g;
	$url_name   =~ s/-+/-/g;
	$url_name   =~ s/[^-\w]//g;
	$url_name   =  lc $url_name;
	$details->{ url_name } = $url_name;
	
	if ( $form ) {
		$form->update( $details );
	}
	else {
		$form = $c->model( 'DB::CmsForm' )->create ( $details );
	}
	
	# Shove a confirmation message into the flash
	$c->flash->{ status_msg } = 'Details updated';
	
	# Bounce back to the 'edit' page
	$c->response->redirect( $c->uri_for( 'edit', $form->url_name ) );
}


=head2 get_template_filenames

Get a list of available template filenames.

=cut

sub get_template_filenames : Private {
	my ( $self, $c ) = @_;
	
	my $template_dir = $c->path_to( 'root/emails' );
	opendir( my $template_dh, $template_dir ) 
		or die "Failed to open template directory $template_dir: $!";
	my @templates;
	foreach my $filename ( readdir( $template_dh ) ) {
		next if $filename =~ m/^\./; # skip hidden files
		next if $filename =~ m/~$/;  # skip backup files
		push @templates, $filename;
	}
	
	return \@templates;
}



=head1 AUTHOR

Denny de la Haye <2010@denny.me>

=head1 LICENSE

This program is free software: you can redistribute it and/or modify it 
under the terms of the GNU Affero General Public License as published by 
the Free Software Foundation, either version 3 of the License, or (at your 
option) any later version.

You should have received a copy of the GNU Affero General Public License 
along with this program (see docs/AGPL-3.0.txt).  If not, see 
http://www.gnu.org/licenses/

=cut

__PACKAGE__->meta->make_immutable;

1;

