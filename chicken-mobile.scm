#!/bin/sh
#|
exec csi -s "$0" "$@"
|#


;; spec: list-of module-spec
;; module-spec: module-name | (module-name dir: module-dir file: module-file)
;; module-file and module-dir defaults to module-name
(define modules `(bind
                  (cplusplus-object dir: bind)
                  (coops file: coops-module)
                  matchable
                  record-variants))

(use setup-api setup-helper-mod posix)

;; conventions from setup-api
(define (c-source-filename file)
  (conc file ".c"))


(define chicken-mobile-home (make-parameter "~/.chicken-mobile/"))

;; (plist-ref '(key1: a key2: b) key2:)
;; (plist-ref '(key1: a key2: b) false:)
;; (plist-ref '(key1: a key2: b fiasco:) key1:)
;; (plist-ref 'error key0:)
(define (plist-ref plist key)
  (assert (= 0 (remainder (length plist) 2)) "odd number of elements in plist")
  (let loop ([plist plist])
    (if (null? plist)
        #f
        (if (eq? key (car plist))
            (cadr plist)
            (loop (cddr plist))))))

;; (module-name key1: value1 key2: value2)
(define (modspec-ref module key)
  (if (list? module)
      (plist-ref (cdr module) key)
      #f))

;; (module-name '(bind 1 2 3))
;; (module-name 'bind)
(define (module-name module)
  (if (list? module) (car module) module))

;; return source/target file of module
;; always a string
(define (module-file module)
  (conc (or (modspec-ref module file:)
            (module-name module))))


;; (module-dir '(cplusplus-object dir: bind))
;; (module-dir '(cplusplus-object file: trick))
;; (module-dir 'cplusplus-object)
(define (module-dir module)
  (conc (or (modspec-ref module dir:) (module-name module))))

(define (.scm module s)
  (source-filename s))

(define (.c m s)
  (c-source-filename s))

(define (.import m s)
  (import-filename s))

(define (module/ m s)
  (make-pathname (module-dir m) s))

(define (target/ m s)
  (make-pathname ".chicken-mobile/build/" s))

;; (p target/ dir/ '(coops file: coops-module-file dir: coops-module-dir))
;; (p target/ dir/ .c .import '(cplusplus-object dir: bind))
(define (p . procs-module)
  (let ([module (last procs-module)])
    (assert (or (and (list? module) (symbol? (car module))) (symbol? module)))
    (let loop ([procs (reverse (drop-right procs-module 1))]
               [s (module-file module)])
      (if (null? procs)
          s
          (loop (cdr procs) ((car procs) module s))))))

(define (mk-module-body module-name . source-files)
  `("include $(CLEAR_VARS)"
    ,(conc "LOCAL_MODULE := " module-name)
    ,(apply conc (cons "LOCAL_SRC_FILES := " source-files))
    "LOCAL_SHARED_LIBRARIES := chicken"
    "LOCAL_CFLAGS := -DC_SHARED"
    "include $(BUILD_SHARED_LIBRARY)"))

;; obs: assuming module name always = module.c file (from compile
;; step)
;; (print (string-join (flatten (map mk-module modules)) "\n"))
(define (mk-module module)
  (let ([module (module-name module)])
    `(,(conc"# -------------------- " module)
      "# (shared library)"
      ,(mk-module-body (module-name module) (p .c module))
      "# (shared import library) "
      ,(mk-module-body (module-name module) (p .c .import module))
      "")))



(print* "writing Chickem.mk ...")
(with-output-to-file "Chicken.mk"
  (lambda ()
    (print (string-join
            (flatten
             `(,(conc "# GENERATED BY chicken-mobile " (time->string (seconds->local-time)))
               "#" "#" "# (do not commit)" "#" "#" "" ""
               ,@(map mk-module modules)))
            "\n"))))
(print "done.")



;; (make-print-reasons #t)
;; (make/proc `(("liba" ("/tmp") ,(lambda () (print "---- ran liba")))
;;              ("main" ("liba") ,(lambda () (print "---- ran main"))))
;;            "main")

;; (pp (mk-module 'cplusplus-object))



