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

(use setup-api setup-helper-mod posix make)

;; conventions from setup-api
(define (c-source-filename file)
  (conc file ".c"))


(define chicken-mobile-home (make-parameter "~/.chicken-mobile/"))
(define chicken-mobile-eggs (make-parameter "~/.chicken-mobile/eggs/"))

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

;; =============================== path constructs

;; construct pathname with a list of procs
;; (construct-path "xXx" target/ module/ '(coops file: coops-module))
(define (construct-path initial-path . procs-module)
  (let ([module (last procs-module)])
    (assert (or (and (list? module) (symbol? (car module))) (symbol? module)))
    (let loop ([procs (reverse (drop-right procs-module 1))]
               [s initial-path])
      (if (null? procs)
          s
          (loop (cdr procs) ((car procs) module s))))))

;; (module-path target/ module/ 'bind)
;; (module-file 'bind)
(define (module-path . procs-module)
  (apply construct-path (cons "" procs-module)))

;; (./file 'bind "dir")
;; (./file '(coops file: coops-module) "dir")
(define (./file m s)
  (make-pathname s
                 ;; get module filename/default
                 (conc (or (modspec-ref m file:)
                           (module-name m)))))

;; shortcut for (module-path ... ./file module)
;; (module-file target/ module/ '(coops file: coops-module-file dir: coops-module-dir))
;; (module-file target/ module/ .c .import '(cplusplus-object dir: bind))
(define (module-file . procs-module)
  (let ([module (last procs-module)])
    (apply construct-path (cons
                           (./file module "")
                           procs-module))))

(define (.scm module s)
  (source-filename s))

(define (.c m s)
  (c-source-filename s))

(define (.import m s)
  (import-filename s))

(define (module/ m s)
  (make-pathname (conc (or (modspec-ref m dir:) (module-name m)))
                 s))

(define (./name m s)
  (make-pathname s (conc (module-name m))))

(define (target/ m s)
  (make-pathname ".chicken-mobile/build/" s))


;; (module-file (make-searcher/ (lambda (m s) '("a" "b" "c")) (lambda (f search-paths) 'gone!)) 'bind)
(define (make-searcher/ proc-search-paths
                        proc-not-found
                        #!optional (tried
                                    (lambda (s p) (print "; not found: " p))))
  (lambda (m s)
    (let* ([sp (proc-search-paths m s)]
           [found
            (find (lambda (pathname)
                    (if (file-exists? pathname)
                        #t
                        (begin (tried s pathname) #f)))
                  (map (cut make-pathname <> s)
                       sp))])
      (or found (proc-not-found s sp)))))

;; (search/ '(cplusplus-object dir: bind) "missing-file")
;; (module-file search/ module/ .scm 'coops)
(define search/ (make-searcher/ (lambda (m s)
                                  (list (module-path target/ module/ m)
                                        (chicken-mobile-eggs)))
                                (lambda (f search-paths) #f)))


;; ================  end of path constructs

(define (mk-module-body module-name . source-files)
  `("include $(CLEAR_VARS)"
    ,(conc "LOCAL_MODULE := " module-name)
    ,(apply conc (cons "LOCAL_SRC_FILES := " source-files))
    "LOCAL_SHARED_LIBRARIES := chicken"
    "LOCAL_CFLAGS := -DC_SHARED"
    "include $(BUILD_SHARED_LIBRARY)"))

;; obs: assuming module name always = module.c file (from compile
;; step) ----- module-name.c
;;; (print (string-join (flatten (map mk-module modules)) "\n"))
(define (mk-module module)
  (let ([module (module-name module)])
    `(,(conc"# -------------------- " module)
      "# (shared library)"
      ,(mk-module-body (module-name module) (module-file .c module))
      "# (shared import library) "
      ,(mk-module-body (module-name module) (module-file .c .import module))
      "")))

(print* "writing Chickem.mk ... ")
(with-output-to-file "Chicken.mk"
  (lambda ()
    (print (string-join
            (flatten
             `(,(conc "# GENERATED BY chicken-mobile " (time->string (seconds->local-time)))
               "#" "#" "# (do not commit)" "#" "#" "" ""
               ,@(map mk-module modules)))
            "\n"))))
(print "done.")

;; (module-compile-args '(coops file: coops-module))
(define (module-compile-args module)
  ;; always module-name.c (easier makefile gen)
  (let ([source.scm (module-file search/ module/ .scm module)]
        [target.c   (module-path .c ./name module)])
    `(-J
      -t ,source.scm
      -o ,target.c
      ;; most eggs include files from their own directory:
      -include-path ,(pathname-directory source.scm))))

(define (module-compile-args/import module)
  `(""
    -t ,(module-path .scm .import ./name module)
    -o ,(module-path .c   .import ./name module)
    ))

(define (csc-thunk module arglist)
  (lambda ()
    (create-directory (module-path target/ module/ module) #t)
    (run (cd ,(module-path target/ module/ module) |\;| csc ,@arglist))))

(make-print-reasons #t)
;; compile all scm files into .c files
(make/proc
 (append
  ;; compile to .c files
  (map
   (lambda (module)
     `(  ,(module-path target/ module/ .c ./name module) ;; build target
         (,(module-file search/ module/ .scm module)) ;; dependencies
         ,(csc-thunk module (module-compile-args module)))) ;; how-to-build target
   modules)

  ;; compile to import.c files
  (map
   (lambda (module)
     `(   ,(module-path .c .import ./name module)
          (,(module-path .scm .import ./name module)
           ,(module-path target/ module/ .c ./name module))
          ,(csc-thunk module (module-compile-args/import module))))
   modules)

  ;; make all import.scm files depend on .c files so they get
  ;; recompiled too
  (map
   (lambda (module)
     `(   ,(module-path .scm .import ./name module)
          (,(module-path target/ module/ .c ./name module))))
   modules)


  ;; build-targets for module-names, depends on respective target-c-filename
  (map (lambda (m)
         `(,(conc (module-name m))
           (,(module-path target/ module/ .c ./name m)
            ,(module-path .c .import ./name m))) )
       modules)

  `(("modules" ,(map (o conc module-name) modules))))
 "modules")


