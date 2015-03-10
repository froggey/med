(in-package :med)

(defvar *grep-key-map* (make-hash-table))
(set-key #\Newline 'grep-find-file-at-point *grep-key-map*)
(set-key #\C-m 'grep-find-file-at-point *grep-key-map*)

(defun grep ()
  (let* ((buffer (get-buffer-create "*grep*"))
         (search-string (read-from-minibuffer "Search string: "))
         (default-pathname-defaults (buffer-property
                                            (current-buffer *editor*)
                                            'default-pathname-defaults
                                            *default-pathname-defaults*))
         (filespec (read-from-minibuffer "File(s): " 
                                        (namestring default-pathname-defaults)))
         (files (directory filespec)))
    (setf (buffer-property buffer 'default-pathname-defaults) default-pathname-defaults)
    (setf (buffer-key-map buffer) *grep-key-map*)
    (switch-to-buffer buffer)
    (move-beginning-of-buffer buffer)
    (let ((point (copy-mark (buffer-point buffer))))
       (move-end-of-buffer buffer)
       (delete-region buffer point (buffer-point buffer)))       
    (dolist (file files)
      (with-open-file (f file)
        (do ((line (read-line f nil) (read-line f nil))
             (lineno 1 (incf lineno)))
            ((not line))
          (when (search search-string line)
            (insert buffer (format nil "~A:~A: ~A~%" 
                                   (file-namestring file) lineno line))))))))

(defun grep-find-file-at-point ()
  (let* ((buffer (current-buffer *editor*)))
    (move-beginning-of-line buffer)
    (let ((point (copy-mark (buffer-point buffer))))
       (scan-forward (buffer-point buffer) (lambda (c) (char= c #\:)))
       (let ((file (buffer-string buffer point (buffer-point buffer)))
             (*default-pathname-defaults* (buffer-property buffer 
                                                           'default-pathname-defaults)))      
         (find-file file)
         (move-mark (buffer-point buffer))
         (let ((point (copy-mark (buffer-point buffer))))
           (scan-forward (buffer-point buffer) (lambda (c) (char= c #\:)))
           (let ((lineno (read-from-string 
                           (buffer-string buffer point (buffer-point buffer)))))
             (move-beginning-of-buffer (current-buffer *editor*))
             (dotimes (i (1- lineno))
               (next-line-command))))))))
