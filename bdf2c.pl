#!/usr/bin/perl

@encodings=();
for($i=0;$i<256*5;$i++) {
  $encodings[$i]="0";
}

$out="";
$counter=0;

$i=0;
$searchfor="";
$nullx="0x";

while(<>) {
  if(/^ENCODING (.*)$/) {
    $glyphindex=$1;
    $searchfor="BBX";
  } elsif(/^BBX (.*) (.*) (.*) (.*)$/) {
    ($width,$height,$x,$y)=($1,$2,$3,$4);
    @encodings[$glyphindex*5..($glyphindex*5+4)]=($counter,$width,$height,$x,$y);
    $searchfor="BITMAP";
  } elsif(/^BITMAP/) {
    $i=1;
  } elsif($i>0) {
    if($i>$height) {
      $i=0;
      $out.=" /* $glyphindex */\n";
    } else {
      $_=substr($_,0,length($_)-1);
      $counter+=length($_)/2;
      s/(..)/$nullx$1,/g;
      $out.=$_;
      $i++;
    }
  }
}

print "unsigned char bdffontdata[$counter]={\n" . $out;
print "};\nint bdffontmetadata[256*5]={\n";
for($i=0;$i<256*5;$i++) {
  print $encodings[$i] . ",";
}
print "};\n";