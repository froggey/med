(in-package :med)

(defvar *mark-stack* ())

(defun function-source-file (function-symbol)
  (let* ((function (or (macro-function function-symbol)
                       (fdefinition function-symbol)))
         (string (sixth (sys.int::function-debug-info function))))
    (when string
      (if (eql (char string 0) #\#)
        (read-from-string string) ; convert pathname
        (pathname string)))))

(defun function-top-level-form-number (function-symbol)
  (let ((function (or (macro-function function-symbol)
                      (fdefinition function-symbol))))
    (seventh (sys.int::function-debug-info function))))

(defun find-definition (function-symbol)
  (let* ((buffer (current-buffer *editor*))
         (file (function-source-file function-symbol))
         (form (function-top-level-form-number function-symbol)))
      (cond ((and file form)
             (format t "~A ~A ~A ~A~%" buffer *package* file form)
             (let ((buffer (find-file file)))
               (move-beginning-of-buffer buffer)
               (move-sexp buffer (1+ form))
               (move-sexp buffer -1)))
            (t (format t "Cannot find definition for function ~A" function-symbol)))))

(defun find-definition-command ()
  (find-definition (read-from-string (symbol-at-point (current-buffer *editor*)))))
