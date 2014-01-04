
(in-package :peldan.pgn)

(defvar files (coerce "abcdefgh" 'list))
(defvar ranks (coerce "12345678" 'list))


(defun parse-file
    (text)
  (let ((c (car text))
	(rest (cdr text)))
    (unless (member c files)
      (error 'parse-error))
    (values rest c)))


(defun parse-rank
    (text)
  (let ((c (car text))
	(rest (cdr text)))
    (unless (member c ranks)
      (error 'parse-error))
    (values rest (char-to-number c))))


(defun parse-consecutive
    (text &rest parsers)
  (if parsers
    (multiple-value-bind (next r) (funcall (car parsers) text)
      (multiple-value-bind (pos rs) (apply #'parse-consecutive next (cdr parsers))
	  (values pos (cons r rs))))
    (values text nil)))


(defun parse-square
    (text)
  (parse-consecutive text #'parse-file #'parse-rank))


(defun parse-move-type
    (text)
  (let ((c (car text))
	(rest (cdr text)))
    (if (eql c #\x) (values rest :takes) (values text :moves))))



(defun parse-square-indicator
    (text)
  (multiple-value-bind (pos r) (parse-square text)
    (values pos (acons :square r nil))))


(defun parse-file-indicator
    (text)
  (multiple-value-bind (pos r) (parse-file text)
    (values pos (acons :file r nil))))


(defun parse-rank-indicator
    (text)
  (multiple-value-bind (pos r) (parse-rank text)
    (values pos (acons :rank r nil))))



(defun parse-alternatives
    (text &rest alternatives)
  (when alternatives
    (handler-case (funcall (car alternatives) text)
      (error (_)
	(declare (ignore _))
	(apply #'parse-alternatives text (cdr alternatives))))))

(defun parse-source-indicator
    (text)
  (parse-alternatives text
		      #'parse-square-indicator
		      #'parse-file-indicator
		      #'parse-rank-indicator))


(defun parse-long-pawn-move
    (text)
  (multiple-value-bind
	(pos r) (parse-consecutive text
				   #'parse-file-indicator
				   #'parse-move-type
				   #'parse-square)

    (values pos
	    (pairlis '(:source :move-type :destination)
		     r))))


(defun parse-short-pawn-move
    (text)
  (multiple-value-bind (pos r) (parse-square text)
    (values pos
	    (pairlis '(:destination :move-type) (list r :moves)))))



(defun parse-pawn-move
    (text)
  (multiple-value-bind
	(pos r) (parse-alternatives text
				    #'parse-long-pawn-move
				    #'parse-short-pawn-move)
    (values pos (acons :piece-type :pawn r))))



(def-suite pgn :description "Testing of the pgn package")
(in-suite pgn)

(test parse-rank
  (multiple-value-bind (_ r) (parse-rank (list #\3))
    (declare (ignore _))
    (is (eql 3 r))))

(test parse-rank-fail
  nil)

(test parse-source-indicator
  (multiple-value-bind (_ r) (parse-source-indicator (coerce "d4" 'list))
    (declare (ignore _))
    (is (not (null (assoc :square r))))))


(test parse-consecutive
  (multiple-value-bind (pos r) (parse-square (list #\e #\4))
    (is (not (null r)))
    (is (eql #\e (car r)))
    (is (eql 4 (nth 1 r)))
    (is (eql 2 (length r)))
    (is (eql 0 (length pos)))))


(run! 'pgn)
