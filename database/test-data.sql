# ===================================================================
# File:		database/test_data.sql
# Project:	ShinyCMS
# Purpose:	Test data
# 
# Author:	Denny de la Haye <2010@denny.me>
# Copyright (c) 2009-2010 Shiny Ideas - www.shinyideas.co.uk
# 
# ShinyCMS is free software. You can redistribute it and/or modify it 
# under the terms of the GNU Affero General Public License.
# ===================================================================

# --------------------
# Tidy up
# --------------------

truncate tagset;
truncate tag;

truncate event;

truncate blog_post;
truncate blog;
truncate comment;
truncate discussion;

truncate news_item;

truncate poll_answer;
truncate poll_question;

truncate shop_category;
truncate shop_item_category;
truncate shop_item;

truncate cms_form;
truncate cms_page_element;
truncate cms_page;
truncate cms_section;
truncate cms_template_element;
truncate cms_template;

truncate user_role;
truncate role;
truncate user;



# --------------------
# Users
# --------------------

insert into user values ( 1, 'denny', 'a736c6304e69e0a8b22bde9d900204949f0608dd072e9044b008d5e183f00c3cXKLR5haJsl', '2010@denny.me', 'Denny', 'de la Haye', 'Denny', '2010 at denny dot me', 'http://denny.me', 'space-invader.png', 'Perl hacker, people watcher, Internet resident.  Partner in Shiny Ideas.', 'London, England', 'EC1V 9AU', null, 1 );
insert into user values ( 2, 'helen', '36ef4b23752ec2e6355898d56714d64fa11d3e6b9caa7e9c940f53a5836ef5edWZFFgCOBsV', 'helen.doesnt.like.spam@shinyideas.co.uk', 'Helen', 'Lambert', 'Helen', 'helen at shinyideas co uk', null, null, null, null, null, null, 1 );
insert into user values ( 3, 'username', 'f9190a9b4c6a9fb80fa5a20bdc6aa704cdefb02628f0859d38b6a8dedfdc2fccA/JrY88R89', 'user.name@shinycms.org', 'User', 'Name', 'User', 'user@domain.tld', null, null, null, null, null, null, 0 );


insert into role values (  1, 'User'               );
insert into role values (  2, 'User Admin'         );
insert into role values (  3, 'CMS Page Editor'    );
insert into role values (  4, 'CMS Page Admin'     );
insert into role values (  5, 'CMS Template Admin' );
insert into role values (  6, 'CMS Form Admin'     );
insert into role values (  7, 'File Admin'         );
insert into role values (  8, 'News Admin'         );
insert into role values (  9, 'Blog Author'        );
insert into role values ( 10, 'Poll Admin'         );
insert into role values ( 11, 'Events Admin'       );
insert into role values ( 12, 'Shop Admin'         );


insert into user_role values ( 1,  1 );
insert into user_role values ( 1,  2 );
insert into user_role values ( 1,  3 );
insert into user_role values ( 1,  4 );
insert into user_role values ( 1,  5 );
insert into user_role values ( 1,  6 );
insert into user_role values ( 1,  7 );
insert into user_role values ( 1,  8 );
insert into user_role values ( 1,  9 );
insert into user_role values ( 1, 10 );
insert into user_role values ( 1, 11 );
insert into user_role values ( 1, 12 );

insert into user_role values ( 2,  1 );
insert into user_role values ( 2,  2 );
insert into user_role values ( 2,  3 );
insert into user_role values ( 2,  4 );
insert into user_role values ( 2,  5 );
insert into user_role values ( 2,  6 );
insert into user_role values ( 2,  7 );
insert into user_role values ( 2,  8 );
insert into user_role values ( 2,  9 );
insert into user_role values ( 2, 11 );

insert into user_role values ( 3,  1 );



# --------------------
# CMS Pages
# --------------------

insert into cms_template values ( 1, 'Homepage',     'homepage.tt'     );
insert into cms_template values ( 2, 'Subpage',      'plain.tt'        );
insert into cms_template values ( 3, 'Contact Form', 'contact-form.tt' );

insert into cms_template_element values ( 1, 1, 'heading1',    'Short Text' );
insert into cms_template_element values ( 2, 1, 'html1',       'HTML'       );
insert into cms_template_element values ( 3, 2, 'heading1',    'Short Text' );
insert into cms_template_element values ( 4, 2, 'paragraphs1', 'Long Text'  );
insert into cms_template_element values ( 5, 2, 'html1',       'HTML'       );
insert into cms_template_element values ( 6, 2, 'image1',      'Image'      );

insert into cms_section values ( 1, 'Main', 'main', 'home',    1 );
insert into cms_section values ( 2, 'Misc', 'misc', 'subpage', 2 );

insert into cms_page values ( 1, 'Home Page',     'home',       1, 1, 1 );
insert into cms_page values ( 2, 'Subpage',       'subpage',    2, 2, 2 );
insert into cms_page values ( 3, 'Upper Subpage', 'upper',      2, 2, 1 );
insert into cms_page values ( 4, 'Contact Us',    'contact-us', 3, 1, 2 );


insert into cms_page_element values (  1, 1, 'heading1',   'Short Text', 'This is a CMS heading' );
insert into cms_page_element values (  2, 1, 'html1',      'HTML',       '<p>This text comes from the database, not the disk.  It is under CMS control.  It is WYSIWYG editable.</p>' );

insert into cms_page_element values (  3, 2, 'heading1',    'Short Text', 'This is another CMS heading' );
insert into cms_page_element values (  4, 2, 'paragraphs1', 'Long Text',  'This is the subpage.  It has different content.  This text can be edited too, but only as text (with paragraph breaks), not as full HTML WYSIWYG content.' );
insert into cms_page_element values (  5, 2, 'html1',       'HTML',       '<p>HTML editor widget is still WYSIWYGy though!</p>' );
insert into cms_page_element values (  6, 2, 'image1',      'Image',      'blue-dog.jpg' );

insert into cms_page_element values (  7, 3, 'heading1',    'Short Text', 'This is the third page' );
insert into cms_page_element values (  8, 3, 'paragraphs1', 'Long Text',  'Although this page was created after subpage, it should be above it in the menus due to its menu_position setting.' );
insert into cms_page_element values (  9, 3, 'html1',       'HTML',       '<p>HTML editor widget remains WYSIWYGy.</p>' );
insert into cms_page_element values ( 10, 3, 'image1',      'Image',      'blue-dog.jpg' );

insert into cms_form values ( 1, 'Contact Form', 'contact', '/pages/main/home', 'Email', '2010@denny.me', null );



# --------------------
# Shop
# --------------------

insert into shop_category values ( 1, null, 'Widgets', 'widgets', 'This is the widgets section.' );
insert into shop_category values ( 2, null, 'Doodahs', 'doodahs', 'This is the doodahs section.' );
insert into shop_category values ( 3, 1, 'Ambidextrous Widgets', 'ambi-widgets', 'Ambidextrous widgets only.' );


insert into shop_item values ( 1, 'blue-lh-widget', 'Blue Left-handed Widget', 'A widget, blue in colour, suitable for left-handed applications.', 'blue-dog.jpg', 314, '<form target="paypal" action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="8299526">
<input type="image" src="https://www.paypal.com/en_GB/i/btn/btn_cart_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online.">
<img alt="" border="0" src="https://www.paypal.com/en_GB/i/scr/pixel.gif" width="1" height="1">
</form>' );
insert into shop_item values ( 2, 'red-rh-widget',  'Red Right-handed Widget', 'A widget, red in colour, suitable for right-handed applications.', 'redphanatic.jpg', 272, '<form target="paypal" action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="8299566">
<input type="image" src="https://www.paypal.com/en_GB/i/btn/btn_cart_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online.">
<img alt="" border="0" src="https://www.paypal.com/en_GB/i/scr/pixel.gif" width="1" height="1">
</form>' );
insert into shop_item values ( 3, 'green-ambi-widget',  'Green Ambidextrous Widget', 'This green widget swings both ways.  Handy.', 'razer.jpg', 123, null );


insert into shop_item_category values ( 1, 1 );
insert into shop_item_category values ( 2, 1 );
insert into shop_item_category values ( 3, 1 );
insert into shop_item_category values ( 3, 2 );



# --------------------
# News
# --------------------

insert into news_item values ( null, 1, 'This is the news', 'this-is-the-news', '<p>Film at 11</p>', date_sub( now(), interval '1' hour ) );
insert into news_item values ( null, 1, 'Moar newz', 'moar-newz', '<p>Pumpkin at midnight</p>', now() );



# --------------------
# Blogs
# --------------------

insert into blog values ( 1, 'Main blog'      );
insert into blog values ( 2, 'Secondary blog' );


insert into discussion values ( 1, 1, 'BlogPost' );
insert into discussion values ( 2, 3, 'BlogPost' );


insert into blog_post values ( 1, 'First Post!', 'first-post', "<p>We hold these truths to be self-evident, that all men are created equal, that they are endowed by their Creator with certain unalienable Rights, that among these are Life, Liberty and the pursuit of Happiness. — That to secure these rights, Governments are instituted among Men, deriving their just powers from the consent of the governed, — That whenever any Form of Government becomes destructive of these ends, it is the Right of the People to alter or to abolish it, and to institute new Government, laying its foundation on such principles and organizing its powers in such form, as to them shall seem most likely to effect their Safety and Happiness.</p>", 1, 1, '2010-01-01 01:01:01', 1 );
insert into blog_post values ( 2, 'Hot Grits!!',    'hot-grits',    '<p>Blog body...</p>', 1, 1, '2010-02-02 02:02:02', null );
insert into blog_post values ( 3, 'Portman!!!',     'portman',      '<p>Blog body...</p>', 1, 2, '2010-03-03 03:03:03', 2 );
insert into blog_post values ( 4, 'Mmmm, content!', 'mmmm-content', '<p>Blog body...</p>', 2, 1, '2010-01-02 03:04:05', null );
insert into blog_post values ( 5, 'Hmmm, content?', 'hmmm-content', '<p>Blog body...</p>', 2, 2, '2010-05-04 03:02:01', null );


insert into comment values ( 1, 1, null, 1,    'Site User', null, null, null, 'First Comment',  "Congress shall make no law respecting an establishment of religion, or prohibiting the free exercise thereof; or abridging the freedom of speech, or of the press; or the right of the people peaceably to assemble, and to petition the Government for a redress of grievances.", now() );
insert into comment values ( 1, 2, null, 1,    'Unverified', 'denny', null, 'http://denny.me', 'Second Comment', 'Comment body text...', now() );
insert into comment values ( 2, 1, null, 3,    'Site User', null, null, null, 'Second Thread',   'Comment body text...', now() );
insert into comment values ( 1, 3, 1,    null, 'Anonymous', null, null, null, 'First Reply', 'Comment body text...', now() );
insert into comment values ( 1, 4, null, 1,    'Site User', null, null, null, 'Third top-level', 'Comment body text...', now() );
insert into comment values ( 1, 5, 3,    1,    'Site User', null, null, null, 'Reply reply', 'Comment body text...', now() );



# --------------------
# Polls
# --------------------

insert into poll_question values ( 1, 'Question goes where?' );

insert into poll_answer values ( 1, 1, 'Here'  );
insert into poll_answer values ( 2, 1, 'There' );



# --------------------
# Events
# --------------------

insert into event values ( 1, 'First Event', 'first-event', 'This is the first event, it is in the past.', null, '2010-01-01 18:00', '2010-01-01 20:00', 'EC1V 9AU', null, null, null );
insert into event values ( 2, 'Second Event', 'second-event', 'This is the second event, it is happening today.', null, now(), now(), 'EC1V 9AU', null, null, null );
insert into event values ( 3, 'Third Event', 'third-event', 'This is the third event, it is in the future.', null, '2010-10-10 10:10', '2010-11-11 11:11', 'EC1V 9AU', null, 'http://shinycms.org', null );



# --------------------
# Tags
# --------------------

insert into tagset values ( 1, 1, 'BlogPost' );
insert into tagset values ( 2, 5, 'BlogPost' );

insert into tag values ( 'test',     1 );
insert into tag values ( 'two tags', 1 );
insert into tag values ( 'test',     2 );


