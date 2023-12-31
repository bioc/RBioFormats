#' ImageMetadata and ImageMetadataList Class
#'
#' Formal representation of image metadata.
#' @template author
#' @example man-roxygen/ex-mockFile.R
#' @examples
#' metadata(img)
#' @exportClass ImageMetadata
.ImageMetadata <- setClass ("ImageMetadata",
          contains = "list",
          validity = function(object) {
            if ( !is.list(object) )
              return( 'ImageMetadata must be a list' )
            if ( length(object)!=3L )
              return( 'ImageMetadata must be a list of length 3' )
            if ( !all(names(object) %in% c("coreMetadata", "globalMetadata", "seriesMetadata")))
              return( 'ImageMetadata list must be a named list containing coreMetadata, globalMetadata, and seriesMetadata')

            TRUE
          }
)

#' @rdname ImageMetadata-class
#' @exportClass ImageMetadataList
.ImageMetadataList <- setClass ("ImageMetadataList",
          contains = "list",
          validity = function(object) {
            if ( !is.list(object) )
              return( 'ImageMetadataList must be a list' )
            if ( !all(vapply(object, function(x) is(x, "ImageMetadata"), logical(1), USE.NAMES = FALSE)) )
              return( 'ImageMetadataList must be a list of ImageMetadata objects' )

            TRUE
          }
)

#' @rdname ImageMetadata-class
#' @param coreMetadata a list of core metadata entries
#' @param globalMetadata a list of global metadata entries
#' @param seriesMetadata a list of series metadata entries
#' @return \code{ImageMetadata} returns a new \linkS4class{ImageMetadata} object.
#' @export
ImageMetadata <- function(coreMetadata = NULL, globalMetadata = NULL, seriesMetadata = NULL) {
  .ImageMetadata(list(coreMetadata = coreMetadata,
                      globalMetadata = globalMetadata,
                      seriesMetadata = seriesMetadata))
}

#' @rdname ImageMetadata-class
#' @param ... a list of \linkS4class{ImageMetadata} objects to include in the new object.
#' @return \code{ImageMetadataList} returns a new \linkS4class{ImageMetadataList} object.
#' @export
ImageMetadataList = function(...) .ImageMetadataList(...)

#' @rdname ImageMetadata-class
#' @param list.len numeric; maximum number of metadata entries to display
#' @export
print.ImageMetadata <- function(x, list.len=5L, ...) {
  cat("ImageMetadata\n")
  .printMetadata(x, list.len=list.len, ...)
}

#' @rdname ImageMetadata-class
#' @param object an \code{ImageMetadata} object
#' @export
setMethod ("show", signature(object = "ImageMetadata"), function(object) {
  cat("ImageMetadata\n")
  .printMetadata(object, list.len=6L)
})

.printMetadata <- function(x, list.len, ...) {
  ## named metadata list
  metadata = setNames(x@.Data, names(x))
  ## filter empty metadata
  metadata = metadata[vapply(metadata, function(y) length(y)>0L, logical(1), USE.NAMES=FALSE)]
  ## print structure
  max.level =
    if ( list.len == 0L ) {
      list.len = 9999L
      1L
    } else {
      ## truncate to avoid huge horizontal spacing
      metadata = lapply(metadata, function(y) {
        if ( list.len < length(y) ) names(y)[(list.len+1L):length(y)] = ""
        y
      })
      2L
    }

  str(metadata, no.list=TRUE, list.len=list.len, max.level=max.level, ...)
}

#' @rdname ImageMetadata-class
#' @export
setMethod ("show", signature(object = "ImageMetadataList"), function(object) {
  cat("ImageMetadata list of length", length(object), "\n\n")

  m = do.call(rbind, coreMetadata(object))
  m = m[, c("series", "resolutionLevel", "sizeX", "sizeY", "sizeC", "sizeZ", "sizeT", "imageCount")]

  cNames = c("series", "res", "sizeX", "sizeY", "sizeC", "sizeZ", "sizeT", "total")

  sMeta = vapply(seriesMetadata(object), length, integer(1), USE.NAMES=FALSE)
  if ( any(sMeta>0) ) {
    cNames = c(cNames, "seriesMetadata")
    m = cbind(m, paste("List of", sMeta))
  }

  colnames(m) = cNames
  rownames(m) = rep("", nrow(m))

  print(m)

  if ( length( (gMeta = globalMetadata(object)[[1L]]) ) > 0L ) {
    cat("\nglobalMetadata:")
    str( globalMetadata(object)[[1L]], list.len=5L )
  }
})

#' @rdname ImageMetadata-class
#' @param x An ImageMetadata object
#' @param ... further arguments to be passed to other methods
#' @export
print.ImageMetadataList <- function(x, ...) show(x)
