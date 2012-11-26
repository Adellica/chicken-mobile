


(declare
 (unit find-extension)
 (export ##sys#find-extension))

(define %##sys#find-extension ##sys#find-extension)
(define (##sys#find-extension p inc?)
  (print "##sys#find-extension: looking for " p ".so or " (string-append "lib" p ".so"))
  (or (%##sys#find-extension p inc?)
      (%##sys#find-extension (string-append "lib" p) inc?)))

