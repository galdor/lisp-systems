;;; Copyright (c) 2020 Nicolas Martyanoff <khaelin@gmail.com>
;;;
;;; Permission to use, copy, modify, and distribute this software for any
;;; purpose with or without fee is hereby granted, provided that the above
;;; copyright notice and this permission notice appear in all copies.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
;;; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
;;; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
;;; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
;;; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
;;; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
;;; OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

;;;
;;; Create a temporary package to avoid polluting :CL-USER.
;;;
(defpackage :systems-init
  (:use :cl)
  (:export
   :root-directory
   :fasl-directory
   :asdf-source-path
   :asdf-fasl-path
   :load-asdf))

(in-package :systems-init)

(defvar *log-output* *error-output*
  "The stream used to log information during the initialization process.")

(defun root-directory ()
  "Return the root directory of the systems repository.

Signal an error if the initialization file was not loaded."
  (when (null *load-pathname*)
    (error "*LOAD-PATHNAME* is null, initialization file was not loaded"))
  (let ((current-directory (pathname-directory *load-pathname*)))
    (make-pathname :directory current-directory)))

(defun asdf-source-path ()
  "Locate and return the path of the ASDF source file bundled with the
  systems repository."
  (let ((root (systems-init:root-directory)))
    (make-pathname :directory (pathname-directory root)
                   :name "asdf" :type "lisp")))

(defun fasl-directory ()
  "Return the path of the directory used to store fasl files for the current
lisp implementation and platform."
  (let* ((implementation (lisp-implementation-type))
         (version (lisp-implementation-version))
         (architecture (machine-type))
         (directory-name (flet ((normalize (string)
                                  (substitute-if
                                   #\_
                                   (lambda (char)
                                     (member char '(#\Space #\/ #\-)
                                             :test #'char=))
                                   (string-downcase string))))
                           (format nil "~A-~A-~A"
                                   (normalize implementation)
                                   (normalize version)
                                   (normalize architecture))))
         (cache-path (make-pathname :directory `(:relative
                                                 ".cache"
                                                 "common-lisp"
                                                 "systems"
                                                 ,directory-name))))
    (merge-pathnames cache-path (user-homedir-pathname))))

(defun asdf-fasl-path ()
  "Return the path of the compiled version of the ASDF source file bundled
  with the systems repository. The location of the file depends on
  runtime information to ensure we always load a file which was compiled with
  the currently running Lisp implementation."
  (let ((file-path (make-pathname :directory '(:relative "asdf")
                                  :name "asdf" :type "fasl")))
    (merge-pathnames file-path (fasl-directory))))

(defun load-asdf ()
  "Locate and load the copy of ASDF bundled with systems.

Compile the ASDF main file since loading it from source is slow."
  (let ((asdf-source-path (systems-init:asdf-source-path))
        (asdf-fasl-path (systems-init:asdf-fasl-path)))
    (ensure-directories-exist asdf-fasl-path)
    (unless (probe-file asdf-source-path)
      (error "asdf file not found at ~S" asdf-source-path))
    (unless (probe-file asdf-fasl-path)
      (format *log-output* "compiling ~S to ~S~%"
              asdf-source-path asdf-fasl-path)
      (compile-file asdf-source-path :output-file asdf-fasl-path
                                     :verbose nil :print nil))
    (load asdf-fasl-path)))

;;;
;;; Main
;;;
(in-package :cl-user)

(systems-init:load-asdf)

;;;
;;; Cleaning
;;;
(delete-package :systems-init)
