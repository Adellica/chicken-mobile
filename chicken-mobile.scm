(use setup-api setup-helper-mod posix make)

;; find the directory where this program is run from,
;; things like ./android/chicken.mk should be there.
(define chicken-mobile-home
  (make-parameter
   (pathname-directory
    (let ([p  (program-name)])
      (if (symbolic-link? p)
       (normalize-pathname
        ;; symlink relative to p, make absolute
        (make-pathname (pathname-directory p)
                       (read-symbolic-link p)))
       p)))))

(define chicken-mobile-eggs
  (make-parameter "~/.chicken-mobile/eggs/"))


;; spec: list-of module-spec
;; module-spec: module-name | (module-name dir: module-dir file: module-file)
;; module-file and module-dir defaults to module-name
(define modules `(bind
                  (cplusplus-object dir: bind)
                  (coops file: coops-module)
                  matchable
                  record-variants))

;; conventions from setup-api
(define (c-source-filename file)
  (conc file ".c"))

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
    (assert (or (and (list? module) (symbol? (car module))) (symbol? module)) "invalid module" module)
    (let loop ([procs (reverse (drop-right procs-module 1))]
               [s initial-path])
      (if (null? procs)
          s
          (loop (cdr procs) ((car procs) s module))))))

;; (module-path target/ module/ 'bind)
;; (module-file 'bind)
(define (module-path . procs-module)
  (apply construct-path (cons "" procs-module)))

;; (./file "dir" 'bind)
;; (./file "dir" '(coops file: coops-module))
(define (./file s m)
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
                           (./file "" module)
                           procs-module))))

(define (.scm s #!optional m)
  (source-filename s))

(define (.c s #!optional m)
  (c-source-filename s))

(define (.import s #!optional m)
  (import-filename s))

(define (module/ s m)
  (make-pathname (conc (or (modspec-ref m dir:) (module-name m)))
                 s))

(define (./name s m)
  (make-pathname s (conc (module-name m))))

(define (target/ s #!optional m)
  (make-pathname ".chicken-mobile/build/" s))

(define (chicken-mobile/ s #!optional m)
  (make-pathname (chicken-mobile-home) s))

;; (module-file (make-searcher/ (lambda (m s) '("a" "b" "c")) (lambda (f search-paths) 'gone!)) 'bind)
(define (make-searcher/ proc-search-paths
                        proc-not-found
                        #!optional (tried
                                    (lambda (s p) (print "; not found: " p))))
  (lambda (s m)
    (let* ([sp (proc-search-paths s m)]
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
(define search/ (make-searcher/ (lambda (s m)
                                  (list (module-path target/ module/ m)
                                        (chicken-mobile-eggs)))
                                (lambda (f search-paths) #f)))


;; ================  end of path constructs

(define (mk-module-body module-name module-dir module-source)
  `("include $(CLEAR_VARS)"
    ,(conc "LOCAL_MODULE := " module-name)
    ,(conc "LOCAL_PATH := " module-dir)
    ,(conc "LOCAL_SRC_FILES := " module-source)
    "LOCAL_SHARED_LIBRARIES := chicken"
    "LOCAL_CFLAGS := -DC_SHARED"
    "include $(BUILD_SHARED_LIBRARY)"))

;; obs: assuming module name always = module.c file (from compile
;; step) ----- module-name.c
;;; (print (string-join (flatten (map mk-module modules)) "\n"))
;;; (pp (mk-module 'bind))
(define (mk-module module)
  `(,(conc"# -------------------- " module)
    "# (shared library)"
    ,(mk-module-body (module-name module)
                     (module-path target/ module/ module)
                     (module-path .c ./name module))
    "# (shared import library) "
    ,(mk-module-body (.import (module-name module))
                     (module-path target/ module/ module)
                     (module-path .c .import ./name module))
    ""))

(define (write-chicken.mk)
  (print* "writing Chickem.mk ... ")
  (with-output-to-file (target/ "Chicken.mk")
    (lambda ()
      (print (string-join
              (flatten
               `(,(conc "# GENERATED BY chicken-mobile " (time->string (seconds->local-time)))
                 "#" "#" "# (do not commit)" "#" "#" "" ""
                 ""
                 ,@(map mk-module modules)
                 ""
                 ,(conc "$(call import-add-path," (chicken-mobile/ "android/modules-prebuilt") ")" )
                 ,(conc "$(call import-module,chicken)")
                 ))
              "\n"))))
  (print "done."))

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
    (run (cd ,(module-path target/ module/ module) ";" csc ,@arglist))))

(make-print-reasons #t)
;; compile all scm files into .c files
(make/proc
 (append
  ;; compile to .c files
  (map
   (lambda (module)
     `(  ,(module-path  target/ module/ .c   ./name module) ;; build target
         (,(module-path search/ module/ .scm ./file module)) ;; dependencies
         ,(csc-thunk module (module-compile-args module)))) ;; how-to-build target
   modules)

  ;; compile to import.c files
  (map
   (lambda (module)
     `(   ,(module-path  target/ module/ .c   .import ./name module)
          (,(module-path target/ module/ .scm .import ./name module)
           ,(module-path target/ module/ .c           ./name module))
          ,(csc-thunk module (module-compile-args/import module))))
   modules)

  ;; make all import.scm files depend on .c files so they get
  ;; recompiled too
  (map
   (lambda (module)
     `(   ,(module-path  target/ module/ .scm .import ./name module)
          (,(module-path target/ module/ .c           ./name module))))
   modules)


  ;; build-targets for module-names, depends on respective target-c-filename
  (map (lambda (m)
         `(,(conc (module-name m))
           (,(module-path target/ module/ .c         ./name m)
            ,(module-path target/ module/ .c .import ./name m))) )
       modules)

  `(("write-chicken.mk" () ,write-chicken.mk))

  `(("modules" ,(append (map (o conc module-name) modules) `("write-chicken.mk")))))
 "modules")

