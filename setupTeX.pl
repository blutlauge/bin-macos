#!/usr/bin/env perl -w

###############################################################################
# 
# Usage: setupTex <title>  
# Description: 
#
# Copyright 2014
# Author: M. Schlienger
# Contact: marc@schlienger.net
#
###############################################################################

#######################################
#
# Headers
#
#######################################

use strict;
use warnings;
use utf8;

use Tk;
use Tk::HList;
use Tk::ItemStyle;
use Tk::BrowseEntry;
use Tk::DialogBox;
use File::Copy;
use Getopt::Std;

#######################################
#
# Global variables
#
#######################################

### version management
# time
my $DATE = localtime; 

# version
my $VERSION = "setupTeX-0.1";

### project
# src directory
my $SRC_DIR = "/Users/marc/System/Vorlagen/latex/school/"; 

# src file
my $SRC_FILE = $SRC_DIR."doc.tex";

# name of the tex file to create
my $FILE_NAME = "";

# project directory
my $PRJ_DIR;

# data
my ($AUTHOR, $COURSE, $PAPER_SIZE, $ORIENTATION, $SUBJECT, $TITLE, $TYPE) =
  ("M. Schlienger", "", "a4paper", "portrait", "", "", "Arbeitsblatt");
my $ICON = "edit-icon.png"; 

### help message
my $HELP_MESSAGE = 
  "Usage: setupTex [OPTION...] [PROJECT NAME]
  \nsetupTeX sets up an environment for creating work sheets, information sheets or transparencies using LaTeX.
  \n\nOptions:
	\nGeneral Options
	\n\t-h\t\tdisplay this help page
	\n\t-n\t\tno gui
	\n\nOptions controlling the output:
	\n\t-a\t\tspecify the author(s) (default: M. Schlienger)
	\n\t-c\t\tspecify the course (E, J1, J2)
	\n\t-p\t\tspecify the paper size (a5paper, a4paper; default: a4paper)
	\n\t-o\t\tspecify the paper orientation (landscape, portrait; default: portrait)
	\n\t-s\t\tspecify the subject (Mathematik, Physik)
	\n\t-t\t\tspecify the title
	\n\t-y\t\tspecify the type of the sheet (Arbeitsblatt, Folie, Gruppenarbeit, Merkblatt; default: Arbeitsblatt)
	\n\nCopyright 2014\nAuthor: M. Schlienger\nContact: marc\@schlienger-bw.de
    \n";

my %WIDGETS = ();

###################
sub help {
###################

  print $HELP_MESSAGE;
}

###################
sub parseArgs {
###################
	
  ### local variables
  my %option = %{ $_[0] };

  # extract the sheet name
  $FILE_NAME = pop(@ARGV);
	
  SWITCH: {
	$option{a} and do { $AUTHOR = $option{a}; };
	$option{c} and do { $COURSE = $option{c}; };
	$option{p} and do { $PAPER_SIZE = $option{p}; };
	$option{o} and do { $ORIENTATION = $option{o}; };
	$option{s} and do { $SUBJECT = $option{s}; };
	$option{t} and do { $TITLE = $option{t}; };
	$option{y} and do { $TYPE = $option{y}; };  
  }
}

###############################################################################
sub setupTexFile {
###############################################################################

  # set the ICON variable
  $ICON = "edit.png"; 
  SWITCH: {
	$TYPE eq "Arbeitsblatt" and do { $ICON = "edit-icon.png"; last SWITCH; };
    $TYPE eq "Merkblatt" and do { $ICON = "info.png"; last SWITCH; };
    $TYPE eq "Gruppenarbeit" and do { $ICON = "user-group-icon.png"; last SWITCH; };
    $TYPE eq "Planarbeit" and do { $ICON = "plan.png"; last SWITCH; };
    $TYPE eq "Folie" and do { $ICON = "transparency.png"; last SWITCH; };
    print "Wrong type given. Switching to 'Arbeitsblatt'!\n";
  }

  # set the ORIENTATION variable
  if($ORIENTATION eq "portrait") {$ORIENTATION = ""}

  # create directories
  $PRJ_DIR = "./" . $FILE_NAME . "/";

  unless(-e $PRJ_DIR or mkdir $PRJ_DIR) {
    die "Unable to create directory $PRJ_DIR: $!";
  }

  my $PRJ_IMG_DIR = $PRJ_DIR . "images";
  unless(-e $PRJ_IMG_DIR or mkdir $PRJ_IMG_DIR) {
    die "Unable to create directory $PRJ_DIR: $!";
  }

  # tex file to create
  my $tex_file = "./" . $PRJ_DIR . $FILE_NAME . ".tex";

  # write tex file
  open(IN, "<$SRC_FILE")
	or die "Couldn't open file $SRC_FILE: $!\n";
  open(OUT, ">$tex_file")
	or die "Couldn't open file $tex_file: $!\n";

  # print using utf8 encoding
  binmode(OUT, ":utf8");
  LINE: while(<IN>)
  {
    s/teacher}{.*}\s*$/teacher}{$AUTHOR}\n/;
    s/course}{.*}\s*$/course}{$COURSE}\n/;
    s/papersize{.*}/papersize{$PAPER_SIZE}\n/;
    s/orientation{.*}/orientation{$ORIENTATION}\n/;
    s/mysubject}{.*}/mysubject}{$SUBJECT}\n/;
    s/mytitle}{.*}/mytitle}{$TITLE}\n/;
    s/icon}{.*}/icon}{$ICON}\n/;

    print OUT $_;
    #print $_;
  }

  close OUT;
  close IN;
}

###################
sub save {
###################
  
  if($FILE_NAME eq "") {
    $WIDGETS{dialog1} = $WIDGETS{main}->DialogBox(
	  -title => "Information",
	  -buttons => ["Close", "Ok"]
	);
	$WIDGETS{dialog1}->add( "Label", 
	  -text => "You have to specify a file name! Use 'NewSheet'?"
	)->pack();
	my $answer = $WIDGETS{dialog1}->Show(
	  -popanchor => 'c', 
	  -overanchor => 'c', 
	  -popover => $WIDGETS{main}
	);
	
    SWITCH: {
      $answer eq "Close" and do { 
        return;
      };
      $answer eq "Ok" and do { 
        $FILE_NAME = "NewSheet"; 
      };
    }
  }
  setupTexFile();
  if($_[0] eq "true") {
    exit(0);
  }
  return;
}

###############################################################################
sub showHelp{
###############################################################################
  $WIDGETS{helpDialog} = $WIDGETS{main}->DialogBox(
	-title			=>	"Help",
	-buttons		=>	["Ok"]
	);
  $WIDGETS{helpDialog}->add(
	"Scrolled",
	'Text',
	-scrollbars		=> 'e'
  )->pack()->insert( 'end', $HELP_MESSAGE);
  $WIDGETS{helpDialog}->Show(
	-popanchor		=> 'c', 
	-overanchor		=> 'c', 
	-popover		=> $WIDGETS{main}
  );
}

###################
sub gui {
###################
  ### local variables
  my $buttonFont = "Helvetica 11 bold";

  # main window
  $WIDGETS{main} = MainWindow->new();
  $WIDGETS{main}->title($VERSION);
  $WIDGETS{main}->minsize(qw(680 150));
  $WIDGETS{main}->configure( -background =>  'Gainsboro' );
  $WIDGETS{main}->optionAdd( '*font', 'Helvetica 9 bold' );
    
  # body
  $WIDGETS{body} = $WIDGETS{main}->Frame(
	-background			=>	'Gainsboro', 
	-borderwidth		=>	2,
	-relief				=>	'groove'
  )->pack(
	-expand				=>	1, 
	-fill				=>	'both', 
	-padx				=>	14, 
	-pady				=>	14
  );

  # frame1 = body->frame: top of the body
  $WIDGETS{frame1} = $WIDGETS{body}->Frame(
	-borderwidth		=>	1,
	-relief				=>	'flat'
  )->pack(
	-expand				=>	1,  
	-fill				=>	'both', 
	-padx				=>	10, 
	-pady				=>	10,
	-side				=>	'top'
  );
	
  # frame11 = frame1->frame: top of frame1
  $WIDGETS{frame11} = $WIDGETS{frame1}->Labelframe(
    -text               =>  'Allgemein',
	-background			=>	'Gainsboro',
	-borderwidth		=>	1,
	-relief				=>	'sunken'
  )->pack(  
	-expand				=>	1,
	-fill				=>	'x', 
	-padx				=>	5,
	-pady				=>	10,
	-side				=>	'top',
	-anchor				=>	'w'
  );

  # file name entry
  $WIDGETS{filenameEntry} = $WIDGETS{frame11}->LabEntry(
	-label				=>	'Dateiname',
    -labelPack          =>  [ -side => "left", -anchor => "e"],
	-background			=>	'White', 
	-borderwidth		=>	2,
	-relief				=>	'sunken', 
	-textvariable		=>	\$FILE_NAME, 
	-selectforeground	=>	'White', 
	-selectbackground	=>	'Blue',
  )->pack(
    -expand             =>  '1',
    -fill               =>  'x',
	-padx				=>	5,
	-pady				=>	5,
	-side				=>	'left',
    -anchor             =>  'w'
  );

  # type entry
  $WIDGETS{titleEntry} = $WIDGETS{frame11}->LabEntry(
	-label				=>	'Titel',
    -labelPack          =>  [ -side => "left", -anchor => "e"],
	-background			=>	'White', 
	-borderwidth		=>	2,
	-relief				=>	'sunken', 
	-textvariable		=>	\$TITLE, 
	-selectforeground	=>	'White', 
	-selectbackground	=>	'Blue',
    -width              =>  60, 
  )->pack(
	-padx				=>	5,
	-pady				=>	5,
	-side				=>	'left',
    -expand             =>  '1',
    -fill               =>  'x',
    -anchor             =>  'w'
  );

  # frame12 = frame1->frame: middle of frame1
  $WIDGETS{frame12} = $WIDGETS{frame1}->Labelframe(
    -text               =>  'Schulisches',
	-background			=>	'Gainsboro',
	-borderwidth		=>	1,
	-relief				=>	'sunken'
  )->pack(  
	-expand				=>	1,
	-fill				=>	'x', 
	-padx				=>	5,
	-pady				=>	10,
	-side				=>	'top',
	-anchor				=>	'w'
  );

  # teacher entry
  $WIDGETS{teacherEntry} = $WIDGETS{frame12}->BrowseEntry(
    -style              =>  'MSWin32',
    -label              =>  'Autor',
	-labelBackground	=>	'Gainsboro', 
	-background	        =>	'White', 
	-variable			=>	\$AUTHOR, 
	-borderwidth		=>	2,
	-relief				=>	'sunken', 
	-selectforeground	=>	'White', 
	-selectbackground	=>	'Blue',
    -width              =>  20, 
    -autolimitheight    =>  '1',
    -autolistwidth      =>  '1'
  )->pack(
	-padx				=>	5,
	-pady				=>	5,
	-side				=>	'left',
    -anchor             =>  'w'
  );
  $WIDGETS{teacherEntry}->Subwidget("slistbox")->configure( 
    -background         =>  'White', 
	-selectforeground	=>	'White', 
	-selectbackground	=>	'Blue',
  ); 
  $WIDGETS{teacherEntry}->Subwidget("arrow")->configure( 
    -background         => 'Gainsboro', 
  ); 
  $WIDGETS{teacherEntry}->insert( 'end', 'M. Schlienger' ); 

  # subject entry
  $WIDGETS{subjectEntry} = $WIDGETS{frame12}->BrowseEntry(
    -style              =>  'MSWin32',
    -label              =>  'Fach',
	-labelBackground	=>	'Gainsboro', 
	-background	        =>	'White', 
	-variable			=>	\$SUBJECT, 
	-width				=>	20,
	-borderwidth		=>	2, 
	-relief				=>	'sunken', 
    -autolimitheight    =>  '1',
    -autolistwidth      =>  '1'
  )->pack(
	-side				=>	'left', 
	-padx				=>	5,
	-pady				=>	5
  );
  $WIDGETS{subjectEntry}->Subwidget("slistbox")->configure( 
    -background         =>  'White', 
	-selectforeground	=>	'White', 
	-selectbackground	=>	'Blue',
  ); 
  $WIDGETS{subjectEntry}->Subwidget("arrow")->configure( 
    -background         => 'Gainsboro', 
  ); 
  $WIDGETS{subjectEntry}->insert( 'end', 'Mathematik', 'Physik' ); 
	
  # course entry
  $WIDGETS{courseEntry} = $WIDGETS{frame12}->BrowseEntry(
    -style              =>  'MSWin32',
    -label              =>  'Kurs',
	-labelBackground	=>	'Gainsboro', 
	-background	        =>	'White', 
	-variable			=>	\$COURSE, 
	-width				=>	5,
	-borderwidth		=>	2, 
	-relief				=>	'sunken', 
    -autolimitheight    =>  '1',
    -autolistwidth      =>  '1'
  )->pack(
	-side				=>	'left', 
	-padx				=>	0,
	-pady				=>	5
  );
  $WIDGETS{courseEntry}->Subwidget("slistbox")->configure( 
    -background         =>  'White', 
	-selectforeground	=>	'White', 
	-selectbackground	=>	'Blue',
  ); 
  $WIDGETS{courseEntry}->Subwidget("arrow")->configure( 
    -background         => 'Gainsboro', 
  ); 
  $WIDGETS{courseEntry}->insert( 'end', 'E', 'J1', 'J2' );
	
  # frame13 = frame1->frame: bottom of frame1
  $WIDGETS{frame13} = $WIDGETS{frame1}->Labelframe(
    -text               =>  'Format',
	-background			=>	'Gainsboro',
	-borderwidth		=>	1,
	-relief				=>	'sunken'
  )->pack(  
	-expand				=>	1,
	-fill				=>	'x', 
	-padx				=>	5,
	-pady				=>	10,
	-side				=>	'top',
	-anchor				=>	'w'
  );

  # type entry
  $WIDGETS{typeEntry} = $WIDGETS{frame13}->BrowseEntry(
    -style              =>  'MSWin32',
    -label              =>  'Typ',
	-labelBackground	=>	'Gainsboro', 
	-background	        =>	'White', 
	-variable			=>	\$TYPE, 
	-borderwidth		=>	2,
	-relief				=>	'sunken', 
	-selectforeground	=>	'White', 
	-selectbackground	=>	'Blue',
    -width              =>  15,
    -autolimitheight    =>  '1',
    -autolistwidth      =>  '1'
  )->pack(
	-padx				=>	5,
	-pady				=>	5,
	-side				=>	'left',
    -anchor             =>  'w'
  );
  $WIDGETS{typeEntry}->Subwidget("slistbox")->configure( 
    -background         =>  'White', 
	-selectforeground	=>	'White', 
	-selectbackground	=>	'Blue',
  ); 
  $WIDGETS{typeEntry}->Subwidget("arrow")->configure( 
    -background         => 'Gainsboro', 
  ); 
  $WIDGETS{typeEntry}->insert( 'end', 'Arbeitsblatt', 'Merkblatt', 
    'Gruppenarbeit', 'Planarbeit', 'Folie' ); 

  # paper size entry
  $WIDGETS{papersizeEntry} = $WIDGETS{frame13}->BrowseEntry(
    -style              =>  'MSWin32',
    -label              =>  'Papierformat',
	-labelBackground	=>	'Gainsboro', 
	-background	        =>	'White', 
	-variable			=>	\$PAPER_SIZE, 
	-borderwidth		=>	2,
	-relief				=>	'sunken', 
    -width              =>  15,
    -autolimitheight    =>  '1',
    -autolistwidth      =>  '1'
  )->pack(
	-padx				=>	5,
	-pady				=>	5,
	-side				=>	'left'
  );
  $WIDGETS{papersizeEntry}->Subwidget("slistbox")->configure( 
    -background         =>  'White', 
	-selectforeground	=>	'White', 
	-selectbackground	=>	'Blue',
  ); 
  $WIDGETS{papersizeEntry}->Subwidget("arrow")->configure( 
    -background         => 'Gainsboro', 
  ); 
  $WIDGETS{papersizeEntry}->insert( 'end', 'a5paper', 'a4paper' ); 

  # orientation entry
  $WIDGETS{orientationEntry} = $WIDGETS{frame13}->BrowseEntry(
    -style              =>  'MSWin32',
    -label              =>  'Ausrichtung',
	-labelBackground	=>	'Gainsboro', 
	-background	        =>	'White', 
	-variable			=>	\$ORIENTATION, 
	-borderwidth		=>	2,
	-relief				=>	'sunken', 
    -width              =>  15,
    -autolimitheight    =>  '1',
    -autolistwidth      =>  '1'
  )->pack(
	-padx				=>	5,
	-pady				=>	5,
	-side				=>	'left'
  );
  $WIDGETS{orientationEntry}->Subwidget("slistbox")->configure( 
    -background         =>  'White', 
	-selectforeground	=>	'White', 
	-selectbackground	=>	'Blue',
  ); 
  $WIDGETS{orientationEntry}->Subwidget("arrow")->configure( 
    -background         => 'Gainsboro', 
  ); 
  $WIDGETS{orientationEntry}->insert( 'end', 'landscape', 'portrait' ); 

  # frame2 = body->frame: bottom of the body
  $WIDGETS{frame2} = $WIDGETS{body}->Frame(
	-background			=>	'Gainsboro', 
	-relief				=>	'flat',
	-borderwidth		=>	3
  )->pack(
	-side				=>	'bottom', 
	-expand				=>	0, 
	-fill				=>	'x', 
	-padx				=>	5, 
	-pady				=>	5
  );

  # frame21 = body->frame2->frame: left side of frame2
  $WIDGETS{frame21} = $WIDGETS{frame2}->Frame(
	-background			=>	'Gainsboro', 
	-relief				=>	'flat',
	-borderwidth		=>	3
  )->pack(
	-side				=>	'left', 
	-expand				=>	0, 
	-fill				=>	'both', 
	-padx				=>	15
  );

  # save button
  $WIDGETS{saveButton} = $WIDGETS{frame21}->Button(
	-font				=>	$buttonFont, 
	-relief				=>	'groove',
	-text				=>	'Save',
	-activeforeground	=>	'DarkGreen',
	-activebackground	=>	'Snow2',
	-foreground			=>	'DarkGreen',
	-background			=>	'Snow3',
	-command			=>	sub{save("false")}
)->pack(
	-side				=>	'left', 
	-anchor				=>	'w', 
	-fill				=>	'none', 
	-padx				=>	5
);

# save-and-quit button
$WIDGETS{saveQuitButton} = $WIDGETS{frame21}->Button(
	-font				=>	$buttonFont, 
	-relief				=>	'groove',
	-text				=>	'Save and Quit',
	-foreground			=>	'DarkOrange',
	-background			=>	'Snow3',
	-activeforeground	=>	'DarkOrange',
	-activebackground	=>	'Snow2',
	-command			=>	sub{save("true")}
)->pack(
	-side				=>	'left', 
	-anchor				=>	'w', 
	-fill				=>	'none', 
	-padx				=>	5
);

# help-button
$WIDGETS{helpButton} = $WIDGETS{frame21}->Button(
	-font				=>	$buttonFont, 
	-relief				=>	'groove',
	-text				=>	'Help',
	-foreground			=>	'Black',
	-background			=>	'Snow3',
	-activeforeground	=>	'Black',
	-activebackground	=>	'Snow2',
	-command			=>	sub{showHelp()},
	-borderwidth		=>	3
)->pack(
	-side				=>	'left', 
	-anchor				=>	'w', 
	-fill				=>	'none', 
	-padx				=>	5
);

# frame32 = body->frame3->frame: right side of frame3
$WIDGETS{frame22} = $WIDGETS{frame2}->Frame(
	-background			=>	'Gainsboro', 
	-relief				=>	'flat',
	-borderwidth		=>	3
)->pack(
	-side				=>	'right', 
	-expand				=>	0, 
	-padx				=>	15, 
	-fill				=>	'both'
);

  # quit-button
  $WIDGETS{quitButton} = $WIDGETS{frame22}->Button(
	-font				=>	$buttonFont, 
	-relief				=>	'groove',
	-borderwidth		=>	3,
	-text				=>	'Quit', 
	-foreground			=>	'Red',
	-background			=>	'Snow3', 
	-activeforeground	=>	'Red',
	-activebackground	=>	'Snow2',
	-command			=>	sub{exit(0)}
  )->pack(
	-side				=>	'right', 
	-anchor				=>	'w', 
	-fill				=>	'none'
  );
	
  ### MainLoop
  MainLoop();
}

###############################################################################
# Main
###############################################################################

# get the command line options
my %option = ();
getopts("hna:c:p:o:s:t:y:", \%option);

# command line or gui
if($option{n}) {
  # parse the command line arguments
  parseArgs({ %option });

  # if no arguments are given or help is activated print the help page
  if(!(@ARGV) || ($option{h}))
  {
    help();
    exit(0);
  }
  
  setupTexFile()
}
else {
  # if help is activated print the help page
  if($option{h})
  {
    help();
    exit(0);
  }

  gui();
}

###############################################################################

