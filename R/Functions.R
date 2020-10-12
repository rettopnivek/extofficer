# Function definitions
# Written by Kevin Potter
# email: kevin.w.potter@gmail.com
# Please email me directly if you
# have any questions or comments
# Last updated 2020-10-12

# Table of contents
# 1) Functions for string manipulation
#   1.1) wtext
# 2) Functions interfacing with 'flextable'
#   2.1) create_header
#   2.2) create_ft
#   2.3) bold_significant
# 3) Functions interfacing with 'officer'
#   3.1) word_add_text
#   3.2) word_add_table
#   3.3) word_add_image
# 4) Functions to create summary statistics tables
#   4.1) create_summary_table

###
### 1) Functions for string manipulation
###

# 1.1)
#' Function to Prepare Text to Add to a Word Document
#'
#' A function to process a character string (e.g.,
#' substituting values for placeholders or removing
#' new line characters ) before adding it to a Word
#' document.
#'
#' @param string A character string.
#' @param strip_nl Logical; if \code{TRUE}, strips the
#'   new line indicator '\code{\\n}' from the sring.
#' @param strip_dbl Logical; if \code{TRUE}, strips
#'   instances of double spaces from the string.
#' @param values An optional vector of values (e.g., numeric
#'   values like descriptive statistics) to replace placeholders
#'   of the form '\code{[[i]]}' where \code{i} refers to the
#'   ith position in the vector \code{values}.
#'
#' @return A processed character string.
#'
#' @examples
#' # Example string
#' string = "
#' Hello world!
#'  Here is a new sentence.
#' "
#' # Remove new line characters
#' wtext( string, strip_nl = T )
#'
#' # Substituting values
#' values = c( 2, 10 )
#' string = "
#' Here is the first value: [[1]],
#'  and here is the second value: [[2]].
#' "
#' wtext( string, strip_nl = T, values = values )
#'
#' @export

wtext = function( string,
                  strip_nl = F,
                  strip_dbl = F,
                  values = NULL ) {

  # Initialize output
  out = string

  # Substitute in values for placeholders
  if ( !is.null( values ) ) {

    # Loop over values
    nv = length( values )
    for ( i in 1:nv ) {

      # Placeholder value
      # to be replaced
      ph = paste( "[[", i, "]]", sep = "" )
      # Substitute given value for placeholder
      # text
      out = gsub( ph, as.character( values[i] ),
                  out, fixed = T )
    }

  }

  # Strip the new line character from the
  # string
  if ( strip_nl ) {
    out = gsub( "\n", "", out, fixed = T )
  }

  # Strip double spaces
  if ( strip_dbl ) {
    out = gsub( "  ", "", out, fixed = T )
  }

  return( out )
}

###
### 2) Functions interfacing with 'flextable'
###

# 2.1)
#' Function to Initialize Header for Flextable Object
#'
#' A function to initialize a data frame with the
#' header information needed when creating a flextable
#' object.
#'
#' @param tbl The data frame to be converted into a
#'   flextable object.
#' @param nc The number of columns (later converted
#'   into rows for the header) to initialize.
#'
#' @return A data frame with the 'col_keys' column
#'   and the columns corresponding to the rows to
#'   add to the header (with placeholder text).
#'
#' @examples
#' # Example table
#' data( "mtcars" )
#' tbl = mtcars[1:6,1:3]
#' tbl = cbind( Cars = rownames( tbl ), tbl )
#' # Initialize header
#' th = create_header( tbl, nc = 2 )
#' # Replace placeholder text
#' th$colA = c( "Cars", "Miles", "Cylinders", "Displacement" )
#' th$colB = c( "", "(per gallon)", "(Number)", "(cu. in.)" )
#' # Create flextable object
#' ft = create_ft( tbl, th )
#'
#' @export

create_header = function( tbl, nc = 1 ) {

  dflt = paste( "C", 1:ncol( tbl ), sep = "" )

  tbl_header = data.frame(
    col_keys = colnames( tbl ),
    colA = dflt,
    stringsAsFactors = F
  )

  if ( nc > 1 ) {
    M = matrix(
      dflt,
      ncol( tbl ), nc - 1, byrow = F
    )
    colnames( M ) = paste( "col", LETTERS[2:nc], sep = "" )
    tbl_header = cbind( tbl_header, M )
  }

  return( tbl_header )
}

# 2.2)
#' Function to Create an APA-style Flextable Object
#'
#' A function that converts a data frame into a
#' APA-style flextable object.
#'
#' @param tbl A data frame.
#' @param tbl_header A data frame with the structure for
#'   the header of the flextable object (see
#'   \code{\link{create_header}}).
#' @param alignment An optional named list giving the
#'   column indices to be either left, right, or
#'   center-aligned.
#' @param font.size The size of the font (defaults to 11).
#' @param font.family The font family (defaults to Arial).
#' @param padding_sym The set of characters to search for
#'   when checking for padding within cells.
#' @param padding_pos Whether padding should be applied to
#'   the left or right.
#' @param alternate_col An optional color specification to
#'   create alternating rows shaded a different color.
#'
#' @return A processed character string.
#'
#' @examples
#' # Example table
#' data( "mtcars" )
#' tbl = mtcars[1:6,1:2]
#' tbl = cbind( Cars = rownames( tbl ), tbl )
#' # Table header
#' th = create_header( tbl )
#' th$colA = c( "Cars", "MPG", "Cylinders" )
#' # List with column indices for alignments
#' a = list( left = 1, center = 2, right = 3 )
#' # Create flextable object
#' ft = create_ft( tbl, th, alignment = a )
#'
#' @export

create_ft = function( tbl, tbl_header,
                      alignment = NULL,
                      font.size = 11,
                      font.family = "Arial",
                      padding_sym = "   ",
                      padding_pos = "left",
                      alternate_col = NULL ) {

  # Convert columns to character strings
  for ( j in 1:ncol( tbl ) ) {
    tbl[[j]] = as.character( tbl[[j]] )
  }

  # Create flextable object
  ft = flextable::flextable(
    tbl,
    col_keys = tbl_header$col_keys
  )

  # Add header with detailed column labels
  ft = ft %>%
    flextable::set_header_df(
      mapping = tbl_header,
      key = 'col_keys'
    )

  # Remove default borders
  ft = ft %>%
    flextable::border_remove()

  # Add borders for top and bottom typical
  # for APA-style tables
  ft = ft %>%
    flextable::hline_top(
      border = officer::fp_border(
        width = 1.5,
        color = 'black'
      ), part = "header" ) %>%
    flextable::hline_bottom(
      border = officer::fp_border(
        width = 1.5,
        color = 'black'
      ), part = "header" ) %>%
    flextable::hline_bottom(
      border = officer::fp_border(
        width = 1.5,
        color = 'black'
      ), part = "body" )

  # Search for padding
  pad_ij = array(
    NA, dim = c( nrow( tbl ), ncol( tbl ), 2 )
  )
  for ( i in 1:nrow( tbl ) ) {
    for ( j in 1:ncol( tbl ) ) {
      yes_pad = grepl( padding_sym, tbl[i,j], fixed = T )
      if ( yes_pad ) {
        pad_ij[i,j,1] = i
        pad_ij[i,j,2] = j
      }
    }
  }

  # If padding is present
  if ( any( !is.na( pad_ij ) ) ) {

    for ( i in 1:nrow( tbl ) ) {
      for ( j in 1:ncol( tbl ) ) {
        yes_pad =
          !is.na( pad_ij[i,j,1] )
        if ( yes_pad ) {
          if ( padding_pos == "left" ) {
            ft = ft %>%
              padding( i = i, j = j,
                       padding.left = nchar(padding_sym)*3
              )
          }
          if ( padding_pos == "right" ) {
            ft = ft %>%
              padding( i = i, j = j,
                       padding.right = nchar(padding_sym)*3
              )
          }

        }
      }
    }

  }

  # Default alignment

  # Center-align cells
  ft = ft %>%
    flextable::align(
      align = "center",
      part = "all"
    )
  # Left-align 1st column
  ft = ft %>%
    flextable::align(
      j = 1,
      align = "left",
      part = "all"
    )

  # Custom alignment
  if ( !is.null( alignment ) ) {

    if ( !is.null( alignment$left ) ) {
      for ( j in alignment$left ) {
        ft = ft %>%
          flextable::align(
            j = j,
            align = "left",
            part = "all"
          )
      }
    }

    if ( !is.null( alignment$right ) ) {
      for ( j in alignment$right ) {
        ft = ft %>%
          flextable::align(
            j = j,
            align = "right",
            part = "all"
          )
      }
    }

    if ( !is.null( alignment$center ) ) {
      for ( j in alignment$center ) {
        ft = ft %>%
          flextable::align(
            j = j,
            align = "center",
            part = "all"
          )
      }
    }

  }

  # Merge identical cells in header
  ft = ft %>%
    flextable::merge_h( part = "header" )

  # Adjust font size
  ft = ft %>%
    flextable::fontsize( size = font.size, part = "all" )

  # Adjust font family
  ft = ft %>%
    flextable::font( fontname = font.family, part = "all" )

  # Resize cells for nicer formatting
  ft = flextable::autofit( ft )

  # If a color is specified, shade rows in alternating fashion
  if ( !is.null( alternate_col ) ) {
    ft = ft %>%
      bg( i = seq( 2, nrow( tbl ), 2 ),
          bg = alternate_col, part = 'body' )
  }

  # Return flextable object
  return( ft )
}

# 2.3)

#' Bold Cells with Significant P-values
#'
#' A function that will check whether a column in an
#' APA-style flextable object has significant p-values;
#' if it does, these cells are bolded.
#'
#' @param ft A flextable object.
#' @param col_index The column index for the column in the
#'   flextable object to update.
#' @param column The character vector for the column of p-values
#'   (by default, assumes p-values are in the format 'p = 0.X',
#'   where the decimal place is the 6th character in the string).
#' @param skip_rows An optional logical vector of matching length
#'   to \code{column} marked \code{TRUE} for rows to skip
#'   when processing.
#' @parm alpha A character string with the cut-off for significance.
#'   For example, if p < 0.05 is deemed significant, \code{alpha}
#'   would be '05'. If p < 0.005 is deemed significant, then
#'   \code{alpha} would be '005'.
#' @param decimal_place The index for when the decimal place in
#'   the character string representing p-values starts. Values
#'   after this index will be compared against \code{alpha} to
#'   assess for significance, values before and at this index
#'   will be ignored.
#'
#' @return An updated flextable object with bolded cells for
#' significant p-values for the specified column.
#'
#' @examples
#' # Create example table
#' ex = data.frame(
#'   Test = c( 'Test 1', 'A', 'B', 'Test 2', 'A', 'B' ),
#'   p_value = c( '', 'p = 0.123', 'p = 0.040', '', 'p = 0.051', 'p < 0.001' )
#' )
#' th = create_header( ex ); th$colA = c( 'Label', 'p-value' )
#' ft = create_ft( ex, th )
#'
#' # Bold cells with p < 0.05
#' ft.1 = ft %>% bold_significant( 2, ex$p_value, alpha = '05' )
#' ft.1
#'
#' # Bold cells with p < 0.005
#' ft.2 = ft %>% bold_significant( 2, ex$p_value, alpha = '005' )
#' ft.2
#'
#' @export

bold_significant = function( ft, col_index, column,
                             skip_rows = NULL, alpha = "05",
                             decimal_place = 6 ) {

  # Parse digits for cut-off for significance
  alpha_parts = strsplit( alpha, split = "" )[[1]]
  num = as.character( 0:9 )

  # Rows to skip when checking for significance
  if ( is.null( skip_rows ) )
    skip_rows = rep( F, length( column ) )

  # Initialize index for significant effects
  any_sig = rep( F, length( column ) )


  # Check which p-values are below cut-off
  lst = lapply( 1:length( alpha_parts ), function(x) any_sig )

  # Standard format of p-value is
  # p = 0.XXX
  # Decimal point is 6th character

  inc = decimal_place # Position of decimal place

  # Loop over components of cut-off
  for ( k in 1:length( alpha_parts ) ) {

    # Check whether observed digits at or below cut-off components
    cmp = num[ 1:which( num == alpha_parts[k] ) ]
    if ( length( cmp ) == 1 ) {
      lst[[k]] =
        stringr::str_sub( column[ !skip_rows ],
                          start = inc + 1, end = inc + 1 ) == cmp
    } else {
      lst[[k]] =
        stringr::str_sub( column[ !skip_rows ],
                          start = inc + 1, end = inc + 1 ) %in%
        cmp[ -length( cmp ) ]
    }
    inc = inc + 1
  }

  # Index of significant values
  any_sig = apply(
    matrix( unlist( lst ), length( any_sig ), length( alpha_parts ) ),
    1,
    all
  )

  # If any values were significant
  if ( any( any_sig ) ) {

    # Rows to loop over
    rws = which( any_sig )

    # Bold cell
    for ( j in 1:length( rws ) ) {
      ft = ft %>%
        bold( i = rws[j], j = col_index, part = 'body' )
    }

  }

  return( ft )
}

###
### 3) Functions interfacing with 'officer'
###

# 3.1)
#' Function to Add Formatted Text to a docx Object
#'
#' A function that streamlines the process of adding
#' a formatted paragraph to a docx object generated
#' via the \pkg{officer} package.
#'
#' @param x A docx device.
#' @param string A character string.
#' @param font.size The font size.
#' @param font.family The font family.
#' @param ... Additional parameters for the
#'   \code{\link[officer]{fp_text}} function.
#'
#' @return An updated docx object.
#'
#' @examples
#' # Create docx object
#' require( "officer" )
#' my_doc = read_docx()
#'
#' # Example text
#' string = "Hello word!"
#' my_doc = my_doc %>% word_add_text( string )
#'
#' # Write to a docx file
#' my_doc %>% print( target = tempfile(fileext = ".docx" )
#' # full path of produced file is returned
#' print(.Last.value)
#'
#' @export

word_add_text = function( x, string,
                          font.size = 11,
                          font.family = "Arial",
                          ... ) {

  # Define convenience functions for
  # adding content to Word document
  mw = function( string ) {

    # Define formatting for text
    fpt = officer::fp_text(
      font.size = font.size,
      font.family = font.family,
      ...
    )

    # Format text
    out =
      officer::fpar(
        officer::ftext(
          string,
          prop = fpt
        )
      )
    return( out )

  }

  return( officer::body_add_fpar( x, mw( string ) ) )
}

# 3.2)
#' Function to Add Flextable Object to a docx Object
#'
#' A function that streamlines the process of adding
#' a flextable object to a docx object via the
#' \pkg{officer} and \pkg{flextable} packages.
#'
#' @param x A docx device.
#' @param ft A flextable object.
#' @param string A table caption.
#' @param num The table number.
#' @param ... Additional parameters for the
#'   \code{\link{word_add_text}} function.
#'
#' @return An updated docx object.
#'
#' @examples
#' # Create docx object
#' my_doc = read_docx()
#'
#' # Example table
#' data( "mtcars" )
#' tbl = mtcars[1:6,1:2]
#' tbl = cbind( Cars = rownames( tbl ), tbl )
#' # Table header
#' th = create_header( tbl )
#' th$colA = c( "Cars", "MPG", "Cylinders" )
#' # List with column indices for alignments
#' a = list( left = 1, center = 2, right = 3 )
#' # Create flextable object
#' ft = create_ft( tbl, th, alignment = a )
#'
#' # Add to docx object
#' my_doc = my_doc %>% word_add_text( ft, string = "Example", num = 1 )
#'
#' # Write to a docx file
#' my_doc %>% print( target = tempfile(fileext = ".docx" ) )
#' # full path of produced file is returned
#' print(.Last.value)
#'
#' @export

word_add_table = function( x, ft,
                           string = NULL,
                           num = NULL,
                           align = "left",
                           ... ) {

  # Table caption
  if ( !is.null( string ) ) {

    # Add table number
    if ( !is.null( num ) ) {
      ttl = paste( "Table ", num, ": ", string, sep = "" )
    } else {
      ttl = string
    }

  } else {
    ttl = ""
  }

  # Update docx object
  x = x %>%
    word_add_text( ttl, ... ) %>%
    flextable::body_add_flextable(
      ft,
      align = align
    ) %>%
    officer::body_add_par( "" )

  return( x )
}

# 3.3)
#' Function to Add Image to a docx Object
#'
#' A function that streamlines the process of adding
#' an image to a docx object via the \pkg{officer}
#' package.
#'
#' @param x A docx device.
#' @param filename The image filename.
#' @param string A figure caption.
#' @param num The figure number.
#' @param width The height of the image in inches.
#' @param height The width of the image in inches.
#' @param ... Additional parameters for the
#'   \code{\link{word_add_text}} function.
#'
#' @return An updated docx object.
#'
#' @examples
#' # Create docx object
#' my_doc = read_docx()
#'
#' # Save example png
#' fname = "Example.png"
#' png( filename = fname, width = 6, height = 6, units = "in", res = 200 )
#' hist( rnorm(100), col = 'grey', border = 'white', breaks = 'FD' )
#' dev.off()
#'
#' # Add to docx object
#' my_doc = my_doc %>% word_add_image( fname, string = "Example", num = 1 )
#'
#' # Write to a docx file
#' my_doc %>% print( target = tempfile(fileext = ".docx" ) )
#' # full path of produced file is returned
#' print(.Last.value)
#'
#' @export

word_add_image = function( x,
                           filename,
                           string = NULL,
                           num = NULL,
                           width = 6,
                           height = 6,
                           ... ) {

  # Figure caption
  if ( !is.null( string ) ) {

    # Add table number
    if ( !is.null( num ) ) {
      ttl = paste( "Figure ", num, ": ", string, sep = "" )
    } else {
      ttl = string
    }

  } else {
    ttl = ""
  }

  # Update docx object
  x = x %>%
    word_add_text( ttl, ... ) %>%
    officer::body_add_img(
      src = filename,
      width = width,
      height = height
    ) %>%
    officer::body_add_par( "" )

  return( x )

}

###
### 4) Functions to create summary statistics tables
###

# 4.1)
#' Create Summary Statistics Table
#'
#' A function to build (in iterative fashion)
#' a table of summary statistics for a data
#' set that can then be passed on to functions
#' like \code{\link{create_ft}}.
#'
#' @param x Either... 1) A character string, giving
#'   the variable names (or labels for empty rows)
#'   to summarize, 2) the data frame of observations
#'   to summarize, 3) the summary table, to strip
#'   away the design elements for the final
#'   nice-looking product, or 4) a list of 3-item character
#'   strings, giving [1] the label, [2] the variable name,
#'   and [3] the type, category, number of digits, and level,
#'   separated by the pipe symbol.
#' @param design A data frame specifying the design
#'   of the summary table - columns for the
#'   summary table are iteratively added to
#'   this data frame.
#' @param stat A function computing the summary
#'   statistics and returning a character string.
#'   To create a custom function, modify the
#'   function returned by calling
#'   \code{create_summary_table} with \code{x}
#'   equal to \code{NULL}.
#' @param label_trim The number of characters to
#'   trim away (starting from the left) when
#'   initializing the 'Label' column in the
#'   design data frame.
#' @param padding_sym The set of characters to use when
#'   creating padding for instances of the 'Level' column
#'   set to 2.
#' @param padding_pos Whether padding should be applied to
#'   the left or right.
#' @param ... Additional parameters to pass to the
#'   internal \code{stat} function.
#'
#' @details The \code{create_summary_table} function can be
#'   used to create summary tables with complex formatting
#'   that are easy to convert into APA-style tables via the
#'   \code{\link{create_ft}} function. Table creation proceeds
#'   in four steps.
#'
#'   First, the user provides a vector of names to the function.
#'   Names matching columns in the data frame of observations
#'   will have summary statistics computed. Non-matching
#'   names will result in blank rows - this provides a simple
#'   way to produce section headings for subsets of rows.
#'   The function will output a 'design' data frame, with
#'   each column specifying processing details to use when
#'   generating the corresponding rows of the summary table.
#'
#'   Second, the user modifies the details of the 'design'
#'   matrix. Users can change the row labels (i.e., the
#'   first column) via the 'Label' column. Users can
#'   specify the type of summary statistics to compute
#'   via the 'Type' column (by default, 0 = blank,
#'   1 = counts (%), 2 = mean (SD), 3 = sample size).
#'   For categorical variables, users can specify the
#'   level over which to compute counts and percentages
#'   via the 'Category' column. The 'Digits' column
#'   can be used to determine the number of digits to
#'   round to when computing summary statistics.
#'   Finally, the 'Level' column controls padding
#'   as applied to the row labels. If values for
#'   'Level' are set to \code{2}, the function
#'   will shift the row labels by the \code{padding_sym}
#'   characters based on the setting of \code{padding_pos}.
#'
#'   Third, the user adds new columns in iterative
#'   fashion via multiple calls to \code{create_summary_table},
#'   with the data frame of observations and the
#'   updated 'design' data frame from the previous call
#'   as the \code{x} and \code{design} arguments.
#'
#'   Fourth, once all desired columns have been added, the
#'   user makes one final call to \code{create_summary_table},
#'   passing in the final version of the 'design' data frame.
#'   This call strips away all design columns from the
#'   data frame, leaving the final version of the summary
#'   table with the desired formatting.
#'
#' @return A 'design' data frame, with columns for
#' summary statistics added iteratively, and
#' final post-processing calls to remove the design
#' elements to create the final summary table.
#'
#' @examples
#' # Example data set
#' data( "iris" )
#' # Variables to summarize
#' rws = colnames( iris )[1:4]
#' # Add rows for sectioning
#' rws = c( 'Sepal', rws[1:2], 'Petal', rws[3:4] )
#' # Initialize data frame specifying design
#' design = create_summary_table( rws )
#'
#' # Indicate rows to report mean (SD) and
#' # rows to leave blank
#' design$Type = 2; design$Type[c(1,4)] = 0
#' # Create nice labels
#' design$Label[c(2,3,5,6)] = rep( c('Length','Width'), 2 )
#' # Shift length/width rows via padding
#' design$Level[c(2,3,5,6)] = 2
#'
#' # Create table
#' st = create_summary_table( iris, design, padding_pos = "right" )
#' # Create new column with summary only for
#' # 'setosa' species
#' st = iris %>%
#'   filter( Species == 'setosa' ) %>%
#'   create_summary_table( design = st )
#'
#' # Remove design elements for nice looking table
#' st = create_summary_table( st )
#' colnames( st ) = c( 'Measures', 'All', 'Setosa' )
#' st
#'
#' # Specify full design via list with...
#' # [1] Label
#' # [2] Variable name
#' # [3] Type|Category|Digits|Level
#' lst = list(
#'   c( "Length", "", "0|NA|NA|1"),
#'   c( "Sepal", colnames(iris)[1], "2|NA|1|2" ),
#'   c( "Petal", colnames(iris)[3], "2|NA|1|2" ),
#'   c( "Width", "", "0|NA|NA|1"),
#'   c( "Sepal", colnames(iris)[2], "2|NA|1|2" ),
#'   c( "Petal", colnames(iris)[3], "2|NA|1|2" )
#' )
#' design = create_summary_table( lst )
#' st = iris %>% create_summary_table( design = design )
#' st = create_summary_table( st )
#'
#' @export

create_summary_table = function( x,
                                 design = NULL,
                                 stat = NULL,
                                 label_trim = 0,
                                 padding_sym = "   ",
                                 padding_pos = "left",
                                 ... ) {
  # A) Function for computing summary statistics
  #   A.A) Counts and percent for binary variables
  #   A.B) Mean and standard deviation for continuous variables
  #   A.C) Sample size only
  # B) Initialize data frame specifying design of summary table
  #   B.A) Trim specified number of characters from labels
  #   B.B) Remove spacing variables
  #   B.C) Capitalize first letter
  # C) List with full details on table
  # D) Tidy up summary table
  # E) Create column for summary table
  #   E.A) Create new column
  #   E.B) Add new column to 'design' data frame
  #   E.C) Adjust positioning of labels

  # A) Function for computing summary statistics

  if ( is.null( stat ) ) {

    # Default function
    stat = function( x,
                     type,
                     digits = NA,
                     category = NA,
                     variable = NA,
                     label = NA,
                     ... ) {
      # Purpose:
      # Default function to compute
      # summary statistics and return
      # a character string of the results.
      # Arguments:
      # x        - A column from a data frame
      # type     - The type of summary statistic
      #            to compute, where...
      #            1 = Counts (%) for binary data
      #            2 = Mean (SD) for continuous data
      #            3 = Sample size
      # digits   - The number of digits to round to
      # variable - The category to compute counts (%)
      #            over (can convert multi-category
      #            data to binary)
      # column   - The column name in the data
      #            frame of observations
      # label    - The label for the table row
      # ...      - Additional parameters
      # Returns:
      # A character string.

      # Initialize output
      out = ''

      # A.A) Counts and percent for binary variables
      if ( type == 1 ) {

        if ( is.na( digits ) ) {
          digits = 0
        }

        if ( is.na( category ) ) {
          category = sort( unique( x ) )[1]
        }

        p = round( 100*mean( x == category[1] ),
                   digits = as.numeric( digits ) )
        n = sum( x == category[1] )
        out = paste( p, '% (', n, ')', sep = '' )

      }

      # A.B) Mean and standard deviation for continuous variables
      if ( type == 2 ) {

        if ( is.na( digits ) ) {
          digits = 1
        }

        m = round( mean( x ), digits = as.numeric( digits ) )
        s = round( sd( x ), digits = as.numeric( digits ) )
        out = paste( m, ' (', s, ')', sep = '' )

      }

      # A.C) Sample size only
      if ( type == 3 ) {

        n = length( x )
        out = as.character( n )

      }

      return( out )
    }

    if ( is.null(x) ) {
      return( stat )
    }
  }

  if ( !is.null( x ) ) {

    # B) Initialize data frame specifying
    #    design of summary table

    # If no data frame for table design
    # is provided
    if ( is.null( design ) ) {

      # If input is a vector of character
      # strings
      if ( is.character( x ) ) {

        # Initialize data frame with
        # details on table
        design = data.frame(
          Variable = x,
          Label = x,
          Type = 1,
          Category = NA,
          Digits = NA,
          Level = 1,
          stringsAsFactors = F
        )

        # Adjust labels

        # B.A) Trim specified number of characters from labels
        if ( label_trim > 0 ) {

          for ( i in 1:nrow( design ) ) {

            ind_char = strsplit( design$Label[i], split = "" )[[1]]
            new_label = paste( ind_char[ -(1:label_trim) ],
                               collapse = "" )
            design$Label[i] = new_label
          }

        }

        # B.B) Remove spacing variables
        design$Label =
          gsub( ".", " ", design$Label, fixed = T )
        design$Label =
          gsub( "_", " ", design$Label, fixed = T )

        # B.C) Capitalize first letter
        for ( i in 1:nrow( design ) ) {
          ind_char = strsplit( design$Label[i], split = "" )[[1]]
          if ( ind_char[1] %in% letters ) {
            ind_char[1] = LETTERS[ letters %in% ind_char[1] ]
          }
          new_label = paste( ind_char, collapse = "" )
          design$Label[i] = new_label
        }

        return( design )

      }

      # C) List with full details on table

      # if input is a list of 3-item character vectors, where...
      # [1] Label
      # [2] Variable name
      # [3] Details separated by the pipe symbol

      if ( is.list(x) ) {
        if ( length( x[[1]] ) == 3 ) {
          if ( grepl( '|', x[[1]][3], fixed = T ) ) {

            # Define function to extract design characteristics
            extract_design_char = function( x, index ) {

              out = NULL

              chr = strsplit( x, split = '|', fixed = T )[[1]]

              if ( index == 1 ) {
                out = as.integer( chr[1] )
              }
              if ( index == 2 ) {
                out = as.character( chr[2] )
                if ( out == 'NA' ) out = NA
              }
              if ( index == 3 ) {
                if ( chr[3] == 'NA' ) {
                  out = NA
                } else {
                  out = as.numeric( chr[3] )
                }
              }
              if ( index == 4 ) {
                out = as.numeric( chr[4] )
              }

              return( out )
            }

            # Initialize data frame with
            # details on table
            design = data.frame(
              Variable = sapply( x, function(y) return( y[2] ) ),
              Label = sapply( x, function(y) return( y[1] ) ),
              Type = sapply( x, function(y) extract_design_char( y[3], 1 ) ),
              Category = sapply( x, function(y) extract_design_char( y[3], 2 ) ),
              Digits = sapply( x, function(y) extract_design_char( y[3], 3 ) ),
              Level = sapply( x, function(y) extract_design_char( y[3], 4 ) ),
              stringsAsFactors = F
            )

            return( design )
          }
        }
      }

      # D) Tidy up summary table

      if ( is.data.frame( x ) ) {

        clm = colnames( x )

        needed_columns = c(
          'Variable',
          'Type',
          'Category',
          'Digits',
          'Level'
        )
        if ( all( needed_columns %in% clm ) ) {
          output = x
          output$Variable = NULL
          output$Type = NULL
          output$Category = NULL
          output$Digits = NULL
          output$Level = NULL

          return( output )
        }

      }

    } else {

      # E) Create column for summary table

      check =
        is.data.frame( design ) &
        is.data.frame( x )
      if ( check ) {

        # E.A) Create new column

        # Create new column by
        # applying summary function to
        # 'x' as specified by each
        # row of 'design'
        new_column = apply(
          design,
          1,
          function(dsgn) {
            stat(
              x = unlist( x[[ dsgn[['Variable']] ]] ),
              type = unlist( dsgn[[ 'Type' ]] ),
              digits = unlist( dsgn[[ 'Digits' ]] ),
              category = unlist( dsgn[['Category']] ),
              variable = unlist( dsgn[['Variable']] ),
              label = unlist( dsgn[['Label']] )
            )
          }
        )
        NC = matrix( rep( '', nrow( design ) ),
                     nrow( design ), 1 )

        # E.B) Add new column to 'design' data frame

        val = 1
        clm = colnames( design )
        sel = grepl( 'X', clm )
        if ( any(sel) ) {
          prev_val = as.numeric( gsub( 'X', '', clm[sel] ) )
          val = max( prev_val ) + 1
        }
        output = cbind( design, new_column )
        colnames( output )[ ncol( output ) ] =
          paste( 'X', val, sep = '' )

        # E.C) Adjust positioning of labels

        if ( any( output$Level > 1 ) ) {
          if ( padding_pos == "left" ) {
            output$Label[ output$Level > 1 ] =
              paste( padding_sym,
                     output$Label[ output$Level > 1 ],
                     sep = '' )
          }
          if ( padding_pos == "right" ) {
            output$Label[ output$Level > 1 ] =
              paste( output$Label[ output$Level > 1 ],
                     padding_sym,
                     sep = '' )
          }
          output$Level = 1
        }

        return( output )
      }

    }

  }

  # Checks for correct input
  err_msg = paste(
    'Necessary inputs not detected, try',
    '?create_summary_table to see options and',
    'examples' )
  stop( err_msg, call. = F )

}


