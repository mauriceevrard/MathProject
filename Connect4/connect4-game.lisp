(defparameter *board*
  (make-array 7 :initial-element
              (make-list 6 :initial-element nil)))

(defun playerify (board-case)
  (case board-case
    (yellow 'o)
    (red    'x)
    (t      '+))) 

(defmacro count-to (x)
  (let ((i (gensym)))
    `(loop for ,i from 1 to ,x
          collect ,i)))

(defun show-board (board)
  (let ((row nil))
        (loop for i from 1 to 5
            do (progn
                    (setf row (map 'list #'car board))
                    (format t "~{~A ~}|~D~%" row i)
                    (setf board (map 'vector #'cdr board)))
            finally (format t "~{~D ~}~%"
                            (count-to 7)))))

(defun fullp (i board)
  (not (car (aref board i))))

(defun tiedp (board)
  (notany #'null
          (map 'list #'car board)))

(defun play (i color board)
  (labels ((push-until (lat token)
           (when (every #'null lat)
             (setf (sixth lat) token)
             lat)
           (cond
             ((cadr lat) (cons token (cdr lat)))
             (t (cons (car lat)
                      (push-until (cdr lat) token))))))
    (push-until (aref board i) color)))

(defun maximum (lat)
  (reduce (lambda (a b)
            (if (> a b)
                a
                b))
          lat))

(defun max-number-of-vertical-connections (color board)
  (labels ((number-in-vertical (column color buffer)
             (cond
               ((null column) buffer)
               ((not (car lat)) (number-in-vertical (cdr column) 0))
               ((eq (car lat) color)
                (number-in-vertical (cdr column) (1+ buffer)))
               (t buffer))))
    (maximum (map 'list #'number-in-vertical board))))

(defun max-subseq (color seq)
  (let ((maxi 0)
        (temp 0))
    (loop for token across seq
          if (eq color token)
            do (progn
                 (incf temp)
                 (setf maxi (max temp maxi)))
          else
            do (setf temp 0))
    maxi))

(defun max-number-of-horizontal-connections (board)
  (labels ((row-finder (the-board acc)
             (loop for row from 0 to 5
                   collect (map 'list #'car the-board) into rows
                   do (setf the-board (map 'vector #'cdr the-board))
                   finally (return rows))))
    (maximum (mapcar #'max-subseq (row-finder board)))))


(defun max-number-of-diagonal-connections (board)
  ...)

(defun winningp (board) 
  (or (> (max-number-of-connections 'yellow board) 3)
      (> (max-number-of-connections 'red    board) 3)))

(defun play-repl ()
  (loop while (and (not (winningp *board*))
                   (not (tiedp *board*)))
        do (progn
             (format t "A votre tour!~%Dans quelle colonne souhaitez-vous jouer? ")
             (let* ((column (read))
                    (i (1- column)))
               (cond
                 ((not (<= 1 column 7))
                  (format t "Veuillez jouer un numéro de colonne correct!~%")
                  (play-repl))
                 ((fullp i *board*)
                  (format t "Cette colonne est déjà remplie!~%")
                  (play-repl))
                 (t (setf *board* (play i 'yellow *board*)))))
             (setf *board* (computer-turn 'red *board*)))))
