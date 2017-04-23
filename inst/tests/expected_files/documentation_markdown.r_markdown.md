#  *file* documentation_markdown.R 
  
  provide a template for create_documentation() using markdown and standard R
  comments.  
  We distinguish between markdown and standard R comments, the latter won't
  make it into the markdown documentation.
  
  *author* Dominik Cullmann <dominik.cullmann@@forst.bwl.de>  
  *section Version:* $Id: 4a6af10c8b6bec39f67a7c6c3138dea703493c8c $  
  *note* That markdown requires two blanks to indicate a line break and a
  blank comment line to separate paragraphs. And we need the following, really
  blank line, to end this file header.

#  load packages, load local code, define local functions, set options 
##  load packages
##  load local code
##  define local functions
##  set "global" options
#  Analyize the data
##  load data
##  look at the data 
##  plot sorted data
###  set up common colors
###  create a local output directory
###  do a ggplot2 graphic
####  sort data by value
####  create plot
####  save graphic
###  redo the graphic manually
####  sort data by value, but different
####  write the graphic directly into the local output directory
####  set the limits of the abscissa
####  create plot
####  add title and note
####  create ordinate labels
####  plot conifers in different color
####  create shading rectangles
####  create abscissa labels
#  collect garbage  
