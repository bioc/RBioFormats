#' AnnotatedImage Class
#'
#' Extends the \linkS4class{Image} class from the \pkg{EBImage} package.
#'
#' @slot metadata an \linkS4class{ImageMetadata} object containing image metadata
#' @importClassesFrom EBImage Image
#' @importFrom EBImage Image
#' @include ImageMetadata.R
#' @seealso \linkS4class{AnnotatedImageList}
#' @template author
#' @example man-roxygen/ex-mockFile.R
#' @examples
#' img
#' @exportClass AnnotatedImage
.AnnotatedImage <- setClass ("AnnotatedImage",
          contains = "Image",
          slots = c(metadata = "ImageMetadata"),
          validity = function(object) {
            if ( !is(object, "Image") )
              return( 'AnnotatedImage must be an Image' )
            if ( !is(object@metadata, "ImageMetadata") )
              return( 'the metadata slot must be an ImageMetadata object' )

            TRUE
          }
)

#' @rdname AnnotatedImage-class
#' @param ... arguments passed to the \linkS4class{Image} constructor.
#' @param metadata an \linkS4class{ImageMetadata} object containing image metadata
#' @return \code{AnnotatedImage} returns a new \linkS4class{AnnotatedImage} object.
#' @export
AnnotatedImage <- function(..., metadata = ImageMetadata()) {
  .AnnotatedImage(Image(...), metadata = metadata)
}

#' AnnotatedImageList Class
#'
#' A list of \linkS4class{AnnotatedImage} objects.
#' @example man-roxygen/ex-mockFileSeries.R
#' @examples
#' img
#' @exportClass AnnotatedImageList
.AnnotatedImageList <- setClass ("AnnotatedImageList",
          contains = "list",
          validity = function(object) {
            if ( !is.list(object) )
              return( 'AnnotatedImageList must be a list' )
            if ( !all(vapply(object, function(x) is(x, "AnnotatedImage"), logical(1), USE.NAMES = FALSE)) )
              return( 'AnnotatedImageList must be a list of AnnotatedImage objects' )

            TRUE
          }
)

#' @rdname AnnotatedImageList-class
#' @param ... a list of \linkS4class{AnnotatedImage} objects to include in the new object.
#' @return \code{AnnotatedImageList} returns a new \linkS4class{AnnotatedImageList} object.
#' @export
AnnotatedImageList <- function(...) .AnnotatedImageList(...)

#' Image Frames Order
#'
#' Get the ordering of image frames.
#'
#' @param x An \code{\link[EBImage]{Image}} object or an array
#' @return A character vector giving the dimension names.
#' @examples
#' # sample timelapse image
#' f = mockFile(sizeC=2, sizeT=10)
#' img = read.image(f)
#'
#' dimorder(img)
#'
#' @template author
#' @export
dimorder = function(x) names(dimnames(x))

#' @rdname AnnotatedImage-class
#' @param x an \linkS4class{AnnotatedImage} object.
#' @param short logical, turns off image data preview.
#' @export
print.AnnotatedImage <- function(x, short=FALSE, ...) {
  NextMethod(x, short)
  .printImageMetadata(x)
}

#' @rdname AnnotatedImage-class
#' @param object an \linkS4class{AnnotatedImage} object
#' @export
setMethod ("show", signature(object = "AnnotatedImage"), function(object) {
  callNextMethod()
  .printImageMetadata(object)
})

.printImageMetadata = function(x) {
  cat('\nmetadata\n')
  .printMetadata(x@metadata, list.len=0L)
}

#' @rdname AnnotatedImage-class
#' @importFrom EBImage as.Image
#' @return \code{as.Image} returns an \linkS4class{Image} object.
#' @export
as.Image.AnnotatedImage = function(x) as(x, "Image")

#' @importFrom methods slot slot<-
setAs("AnnotatedImage", "Image", function(from) new("Image",
                                                    from@.Data,
                                                    colormode = from@colormode,
                                                    dim = from@dim,
                                                    dimnames = NULL)
)
