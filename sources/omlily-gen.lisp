;;; ====================================================================
;;;
;;;      OM2Lily 2.0 v1.1
;;;
;;;      � 2005 IRCAM - Karim Haddad
;;;
;;; ====================================================================

;;;;la c'est la version generique

(in-package :om)


;;;maybe a big BUG
;;;redefined here from my patches
(defmethod get-group-ratio ((self group) )
   (let* ((tree (tree self))
          (extent (car tree))
          (addition (loop for item in (second tree) sum (floor (abs (if (listp item) (car item) item))))))
     ;(print addition)
     (cond
      ((= (round (abs addition)) 1) nil)
      ( (integerp (/ extent addition))  addition)  ;;;HERE IS THE CHANGE ,it is now uncommented......
      ( (and (integerp (/ extent addition)) 
             (or (power-of-two-p (/ extent addition))
                 (and (integerp (/ addition extent)) 
                      (power-of-two-p (/ addition extent)))))  nil)
      (t addition))))



;;;;;;;;;;;;;;Utilities section




;;;for note conversion


(defvar *no-sharp-read-table*)

(setf *kascii-note-c-scale*
  (mapc #'(lambda (x) (setf (car x) (string-downcase (string (car x)))))
    '((c) (c . :q) (c . :s) (c . :qs)
      (d) (d . :q) (d . :s) (d . :qs)
      (e) (e . :q)
      (f) (f . :q) (f . :s) (f . :qs)
      (g) (g . :q) (g . :s) (g . :qs)
      (a) (a . :q) (a . :s) (a . :qs)
      (b) (b . :q)  )))



(setf *kascii-note-alterations*
   '((:s "is" +100) (:f "es" -100)
     (:q "ih" +50) (:qs "isih" +150) (:-q "eh" -50) (:f-q "eseh" -150)
     (:s "is" +100)))



(setf *kascii-note-scales* (list *kascii-note-C-scale*))




;;;;;pour les cautionnary naturals

(setf *k-n-ascii-note-c-scale*
  (mapc #'(lambda (x) (setf (car x) (string-downcase (string (car x)))))
    '((c . :n) (c . :q) (c . :s) (c . :qs)
      (d . :n) (d . :q) (d . :s) (d . :qs)
      (e . :n) (e . :q)
      (f . :n) (f . :q) (f . :s) (f . :qs)
      (g . :n) (g . :q) (g . :s) (g . :qs)
      (a . :n) (a . :q) (a . :s) (a . :qs)
      (b . :n) (b . :q)  )))



(setf *k-n-ascii-note-alterations*
   '((:n "" ) (:s "is" +100) (:f "es" -100)
     (:q "ih" +50) (:qs "isih" +150) (:-q "eh" -50) (:f-q "eseh" -150)
     (:s "is" +100)))


(setf *k-n-ascii-note-scales* (list *k-n-ascii-note-C-scale*))


;;;;;;;




(defun append-str (list)                
  (let ((str ""))
    (loop for s in list do
          (setf str (concatenate 'string str s)))
    str))

;;(append-str '("'" "'" "'"))


(defun proappend-str (list)
  (let ((str " "))
    (loop for s in list 
          
          do (setf str (concatenate 'string str s " ")))
    str))

;;(proappend-str '("'" "'" "'"))

(defun octaviation (num)
  (cond ((> num 4) (append-str (om::repeat-n "'" (- num 4))))
        ((< num 4) (append-str (om::repeat-n "," (- 4 num))))
        (t "")))


;(octaviation 4)




(defun mc->lilynotes1 (midic)
  "Converts <midic> to a string representing a symbolic ascii note."
  (let* ((kascii-note-scale (car *kascii-note-scales*))
        (dmidic (/ 1200 (length kascii-note-scale))) 
        note)
    (let* ((values (multiple-value-list (round midic dmidic)))
           (midic/50 (car values))
           (cents (cadr values))
           (values2 (multiple-value-list (floor (* midic/50 dmidic) 1200)))
           (oct+2 (car values2))
           (midic<1200 (cadr values2)))

      ;(print (list midic/50 cents oct+2 midic<1200))

      (setq note (nth (/ midic<1200 dmidic) kascii-note-scale))
      (format nil "~A~A~A~A~A"
              (car note) 
              (or (car (cassq (cdr note) *kascii-note-alterations*)) "")
              (octaviation oct+2) (if (> cents 0) "+" "") (if (zerop cents) "" cents) ))))



;(mc->lilynotes1 6350) =====> problem!!!!!!!!!!



(defmethod mc->lilynotes ((midics? list))
 "mc->n takes a midi-cent value <midics> or list of midi-cent values,
 and returns corresponding symbolic (ASCII) note names. 
 Symbolic note names follow standard notation with middle c 
(midi-cent 6000) being C3.  Semitones are labeled with a '#' or a 'b.'  
Quartertone flats are labeled with a '_', and quartertone sharps with a '+'.  Thus, 
C3 a quartertone sharp (midi-cent 6050), would be labeled 'C+3'.  Gradations 
smaller than a quartertone are expressed as the closest  quartertone + or - the 
remaining cent value (i.e., midi-cent 8176 would be expressed as Bb4-24)."
 
  (deep-mapcar 'mc->lilynotes 'mc->lilynotes1 (approx-m midics? 4)))



;;;;for cautionnary

(defun mc->lilynotes1-nat (midic)
  "Converts <midic> to a string representing a symbolic ascii note."
  (let* ((kascii-note-scale (car *k-n-ascii-note-scales*))
        (dmidic (/ 1200 (length kascii-note-scale))) 
        note)
    (let* ((values (multiple-value-list (round midic dmidic)))
           (midic/50 (car values))
           (cents (cadr values))
           (values2 (multiple-value-list (floor (* midic/50 dmidic) 1200)))
           (oct+2 (car values2))
           (midic<1200 (cadr values2)))

      ;(print (list midic/50 cents oct+2 midic<1200))

      (setq note (nth (/ midic<1200 dmidic) kascii-note-scale))
     
      (if (equal (cdr note) :n)
        (format nil "~A~A~A~A~A"
                (car note) 
                (octaviation oct+2)
                (if (> cents 0) "+" "") (if (zerop cents) "" cents)
                (or (car (cassq (cdr note) *k-n-ascii-note-alterations*)) ""))
        
        (format nil "~A~A~A~A~A"
                (car note) 
                (or (car (cassq (cdr note) *k-n-ascii-note-alterations*)) "")
                (octaviation oct+2) (if (> cents 0) "+" "") (if (zerop cents) "" cents) )))))




(defmethod mc->lilynotes-nat ((midics? list))
 "mc->n takes a midi-cent value <midics> or list of midi-cent values,
 and returns corresponding symbolic (ASCII) note names. 
 Symbolic note names follow standard notation with middle c 
(midi-cent 6000) being C3.  Semitones are labeled with a '#' or a 'b.'  
Quartertone flats are labeled with a '_', and quartertone sharps with a '+'.  Thus, 
C3 a quartertone sharp (midi-cent 6050), would be labeled 'C+3'.  Gradations 
smaller than a quartertone are expressed as the closest  quartertone + or - the 
remaining cent value (i.e., midi-cent 8176 would be expressed as Bb4-24)."
 
  (deep-mapcar 'mc->lilynotes-nat 'mc->lilynotes1-nat (approx-m midics? 4)))




;;for time conversion


(defun note-strict-lp (val)
  (cond
   ((>= val 16) (car (before&after-bin val)))
   ((= val 8) "\\maxima")
   ((= val 4) "\\longa")
   ((= val 2) "\\breve")
   (t (denominator val))))


(defun get-head-and-points (val)
 (let* ((haut (numerator val))
 (bas (denominator val))
 (bef (car (before&after-bin haut)))
(points 0) (char "*"))
 (cond
 ((= bef haut)
 (setf char (note-strict-lp (/ haut bas)))
 (setf points 0))
 ((= (* bef 1.5) haut)
 (setf char (note-strict-lp (/ bef bas)))
 (setf points 1))
 ((= (* bef 1.75) haut)
 (setf char (note-strict-lp (/ bef bas)))
 (setf points 2)))
 ;(print (format nil "val ~D head ~D� points ~D" val char points))
 (list char points)))



;(get-head-and-points 3/4)
;(get-head-and-points 2)
;(get-head-and-points 9)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;Utilities;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;this function is for getting the symbolic note figure 
;;;;;;of an object
;;;;;; important for stemming


(defmethod get-note-figure ((self t))
  (remove nil (flat (getdembeams self nil nil))))



(defmethod getdembeams ((self om::poly) listclefs freestore)
  (let ((rep nil) 
        (voices (om::inside self)))
    (loop for staff in voices
          for i = 0 then (+ i 1) do
          (setf rep (append rep (getdembeams staff (nth i listclefs) freestore))))
    
    rep))

(defmethod getdembeams ((self om::voice) clef freestore)
  (let* ((rep nil)
         (mesures (om::inside self))
         (lastmes nil))
    (loop for mes in mesures
          for i = 1 then (+ i 1) do
          (setf rep (append rep (getdembeams mes lastmes freestore)))
          (setf lastmes mes))
    rep))


(defmethod getdembeams ((self om::measure) lastmes chiffrage)
  (let* ((inside (om::inside self))
         (tree (om::tree self))
         (real-beat-val (/ 1 (om::fdenominator (first tree))))
         (symb-beat-val (/ 1 (om::find-beat-symbol (om::fdenominator (first tree)))))
         (rep nil))
    
    (loop for obj in inside do
          (setf rep (list rep 
                            (let* ((dur-obj-noire (/ (om::extent obj) (om::qvalue obj)))
                                   (factor (/ (* 1/4 dur-obj-noire) real-beat-val))
                                   (exp (getdembeams obj (* symb-beat-val factor) (car (tree self)))))
                              exp
                              )
                            )))
    rep))


(defmethod getdembeams ((self om::group) dur ratio)
  (let* ((durtot (if (listp dur) (car dur) dur))
         (cpt (if (listp dur) (cadr dur) 0))
         (num (or (om::get-group-ratio self)  (om::extent self)))
         (denom (om::find-denom num durtot))
         (num (if (listp denom) (car denom) num))
         (denom (if (listp denom) (second denom) denom))
         (unite (/ durtot denom))
         (inside (om::inside self))
         (sympli (/ num denom))
         (rep nil) (val nil))

    
    (cond
     ((not (om::get-group-ratio self)) 
      (loop for obj in inside
            do (setf rep (list (list! rep) (let* ((dur-obj (/ (/ (om::extent obj) (om::qvalue obj)) 
                                                        (/ (om::extent self) (om::qvalue self)))))
                                       (getdembeams obj (* dur-obj durtot) ratio))))))
     ((= sympli 1)
      (loop for obj in inside
            do (setf rep (list (list! rep) (let* ((operation (/ (/ (om::extent obj) (om::qvalue obj)) 
                                                          (/ (om::extent self) (om::qvalue self))))
                                            (dur-obj (numerator (/ (/ (om::extent obj) (om::qvalue obj)) 
                                                                   (/ (om::extent self) (om::qvalue self))))))
                                       (setf dur-obj (* dur-obj (/ num (denominator operation))))
                                       (getdembeams obj (* dur-obj unite) ratio)))))
      
      )
     

     (t 

(let ((pos (length rep))
            (depth 0))
        (loop for obj in inside do
              (setf rep (list (list! rep) (let* ((operation (/ (/ (om::extent obj) (om::qvalue obj)) 
                                                         (/ (om::extent self) (om::qvalue self))))
                                           (dur-obj (numerator operation))
                                           exp tmp)
                                      (setf dur-obj (* dur-obj (/ num (denominator operation))))
                                      
                                      (setf tmp (multiple-value-list 
                                                 (getdembeams obj (list (* dur-obj unite) cpt) ratio)))
                                      
                                      
                                      (setf exp (car tmp))
                                      (when (and (cadr tmp) (> (cadr tmp) depth))
                                        (setf depth (cadr tmp)))
                                      exp
                                      ;(list exp)
                                      ))))
        (setf val (+ depth 1))
        
        
        )

      )



     ) 
    (values rep val)))


(defmethod getdembeams ((self om::chord) dur ratio)
  ;(print dur)
  (if (listp dur) (car dur) dur))


(defmethod getdembeams ((self om::rest) dur ratio)
  (if (listp dur) (car dur) dur)) 


(setf *voice-rank*
      '((1 . "one") (2 . "two")(3 . "three") (4 . "four")
        (5 . "five") (6 . "six")(7 . "seven") (8 . "eight")
        (9 . "nine") (10 . "ten")(11 . "eleven") (12 . "twelve")
        (13 . "thirteen") (14 . "fourteen")(15 . "fifteen") (16 . "sixteen")
        (17 . "seventeen") (18 . "eighteen")(19 . "nineteen") (20 . "twenty")
        (21 . "twentyone") (22 . "twentytwo")(23 . "twentythree") (24 . "twentyfour")
        (25 . "twentyfive") (26 . "twentysix")(27 . "twentyseven") (28 . "twentyeight")
        (29 . "twentynine") (30 . "thirty")(31 . "thirtyone") (32 . "thirtytwo")
        (33 . "thirtythree") (34 . "thirtyfour")(35 . "thirtyfive") (36 . "thirtysix")
        (37 . "thirtyseven") (38 . "thirtyeight")(39 . "thirtynine") (40 . "forty")
        (41 . "fortyone") (42 . "fortytwo")(43 . "fortythree") (44 . "fortyfour")(45 . "fortyfive")
        (46 . "fortysix") (47 . "fortyseven")(48 . "fortyeight") (49 . "fortynine")
        (50 . "fifty") (51 . "fiftyone")(52 . "fiftytwo") (53 . "fiftythree")
        (54 . "fiftyfour") (55 . "fiftyfive")(56 . "fiftysix") (57 . "fiftyseven")
        (58 . "fiftyeight") (59 . "fiftynine")(60 . "sixty") (61 . "sixtyone")
        (62 . "sixtytwo") (63 . "sixtythree")(64 . "sixtyfour") (65 . "sixtyfive")
        (66 . "sixtysix") (67 . "sixtseven")(68 . "sixtyeight") (69 . "sixtynine")
        (70 . "seventy") (71 . "seventyone")(72 . "seventytwo")(73 . "seventythree")
        (74 . "seventyfour")(75 . "seventyfive")(76 . "seventysix")(77 . "seventyseven")
        (78 . "seventyeight")(79 . "seventynine")
        (80 . "eighty")(81 . "eightyone")(82 . "eightytwo")(83 . "eightythree")(84 . "eightyfour")(85 . "eightyfive")(86 . "eightysix")
        (87 . "eightyseven")(88 . "eightyeight")(89 . "eightynine")
        (90 . "ninety")(91 . "ninetyone")(92 . "ninetytwo")(93 . "ninetythree")(94 . "ninetyfour")
        (95 . "ninetyfive")(96 . "ninetysix")(97 . "ninetyseven")(98 . "ninetyeight")(99 . "ninetynine")
        (100 . "hundred")(101 . "hundredone")(102 . "hundredtwo")(103 . "hundredthree")(104 . "hundredfour")(105 . "hundredfive")
        (106 . "hundredsix")(107 . "hundredseven")(108 . "hundredeight")(109 . "hundrednine")
        (110 . "hundredten")(111 . "hundredeleven")(112 . "hundredtwelve")(113 . "hundredthirteen")(114 . "hundredfourteen")(115 . "hundredfifteen")
        (116 . "hundredsixteen")(117 . "hundredseventeen")(118 . "hundredeightteen")(119 . "hundrednineteen")
        (120 . "hundredtewenty")(121 . "hundredtewentyone")(122 . "hundredtewentytwo")(123 . "hundredtewentythree")(124 . "hundredtewentyfour")(125 . "hundredtewentyfive")
        (126 . "hundredtewentysix")(127 . "hundredtewentyseven")(128 . "hundredtewentyeight")(129 . "hundredtewentynine")
        (130 . "hundredthirty")(131 . "hundredthirtyone")(132 . "hundredthirtytwo")(133 . "hundredthirtythree")(134 . "hundredthirtyfour")
        (135 . "hundredthirtyfive")(136 . "hundredthirtysix")(137 . "hundredthirtyseven")(138 . "hundredthirtyeight")(139 . "hundredthirtynine")
        (140 . "hundredfourty")(141 . "hundredfourtyone")(142 . "hundredfourtytwo")(143 . "hundredfourtythree")(144 . "hundredfourtyfour")))


;(cassq 30 *voice-rank*)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;DA CODE;;;;;;;;;;;;;;;
;;;;where everything is transcribed


(defvar *cautionnary* nil)



(defvar *treeratios* '())
(defvar *chords-and-cont* '())
(defvar *switch* nil)
(defvar *voice-num* 0)
(defvar *mesure-num* 0)

(defun print-lily (voice)
  (setf *mesure-num* 0)
  (setf *voice-num* 1)
  (loop for elt in (cons-lily-expr voice "G" nil) do (print elt)))



;;;;;;;;;;;;;;Utilities section

(defun cassq (sym l)
  (cdr (assoc sym l)))


(defun print-lil (voice)
  (setf *mesure-num* 0)
  (setf *voice-num* 1)
  (loop for elt in (cons-lil-expr voice "G") do (print elt)))






(setf *voice-rank*
      '((1 . "one") (2 . "two")(3 . "three") (4 . "four")
      (5 . "five") (6 . "six")(7 . "seven") (8 . "eight")
      (9 . "nine") (10 . "ten")(11 . "eleven") (12 . "twelve")
      (13 . "thirteen") (14 . "fourteen")(15 . "fifteen") (16 . "sixteen")
      (17 . "seventeen") (18 . "eighteen")(19 . "nineteen") (20 . "twenty")
      (21 . "twentyone") (22 . "twentytwo")(23 . "twentythree") (24 . "twentyfour")
      (25 . "twentyfive") (26 . "twentysix")(27 . "twentyseven") (28 . "twentyeight")
      (29 . "twentynine") (30 . "thirty")(31 . "thirtyone") (32 . "thirtytwo")
      (33 . "thirtythree") (34 . "thirtyfour")(35 . "thirtyfive") (36 . "thirtysix")))


;(cassq 30 *voice-rank*)





;(defun massq (item list)
;(format nil "~S" (cdr (assoc item list :test 'equal))))  

(defun massq (item list)
(cdr (assoc item list :test 'equal)))

(setf *vel-for-lil*
      '(("i" . "\\ffff") ("h" . "\\fff") ("g" . "\\ff")("f" . "\\f") ("F" . "\\mf") ("e" . "\\sfz")
      ("P" . "\\mp") ("p" . "\\p")("Q" . "\\pp") ("R" . "\\ppp")("S" . "\\pppp")))




;(format nil "~S" (cdr (assoc "h" *vel-for-lil* :test 'equal)))
;(massq  "h" *vel-for-lil*)






(defmethod cons-lil-expr-extr ((self om::poly) listclefs)
  (let ((rep (list " ")) 
        (voices (om::inside self)))
    (setf *voice-num* 0)
    (loop for staff in voices
          for i = 0 then (+ i 1) 
          do
          (progn 
          (setf *voice-num* (incf *voice-num*))
          (setf rep (append rep (cons-lil-expr-extr staff (nth i listclefs))))))
 

      (setf rep (append rep (list (format nil "\\score { ~% { ~%~%"))))
      (setf rep (append rep (list (format nil "~%\% \#(with-output-to-file \"temp.lisp\"" ))))
      (setf rep (append rep (list (format nil "\% (lambda () #{ \\displayMusic {"))))
      (setf rep (append rep (list (format nil "<<"))))
      (setf rep (append rep (list (format nil "\\new StaffGroup~% << ~%~%"))))


    (setf *voice-num* 0)
    (loop for staff in voices
          for i = 0 then (+ i 1) 
          do
          (progn 
          (setf *voice-num* (incf *voice-num*))
          (setf rep (append rep (list (format nil "~%\\new Staff  {"))))
          (setf rep (append rep (list (string+ "\\"(cassq *voice-num* *voice-rank* )))))
          (setf rep (append rep (list "}")))
))

(setf rep (append rep (list (format nil " >> ~% >>"))))
(setf rep (append rep (list "\% } #}))")))
(setf rep (append rep (list (format nil "~%} ~% ~%"))))

rep))





(defmethod cons-lil-expr-extr ((self om::voice) clef)
  (setf *mesure-num* 0)
  (let ((rep (list (format nil "~s=" (cassq *voice-num* *voice-rank* )) "{" 
                   (format nil "\%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
                   (format nil "\%%%%%%%%%%%%%%%%%%%%%%% VOICE : ~d %%%%%%%%%%%%%%%%%%%%%%%%" *voice-num*)
                   (format nil "\%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
                   (if (= 1 *voice-num*) 
                    ; (format nil "~%\\tempo 4=~D ~%" (round (tempo-a-la-noire (car (tempo self)))))
                       (format nil "") 
                       (format nil ""))
                   (format nil "~%#(set-accidental-style 'dodecaphonic)~%")
                   ;(format nil  "\\set tupletNumberFormatFunction = #fraction-tuplet-formatter")
                   ))
        (mesures (om::inside self))
        (lastmes nil))
    (when clef
      (setf rep (append rep (list (format nil "\\clef ~s" clef)))))

(if (= 1 *voice-num*)
        (let (mem-mes)

          (loop for mes in mesures
                for i = 1 then (+ i 1) do
          
                
                (setf *mesure-num* (incf *mesure-num*))
                (setf rep (append rep (list (format nil  "\%%%%%%%%%%%%%%%%%%%%%%% MESURE : ~d %%%%%%%%%%%%%%%%%%%%%%%" *mesure-num*))))
                (let ((tempo (if (atom (qtempo mes)) 
                                 (qtempo mes)
                                 (cadar (qtempo mes)))))
                  ;;(print tempo) ;;this is to check the tempo....
                  (if (not (equal tempo mem-mes))
                  (progn 
                    ;(setf rep (append rep (list (format nil "\\tempo \\markup {\\rounded-box \\concat{\\smaller \\general-align #Y #DOWN  \\note #\"4\" #1 \" = ~d\" } }" tempo))))
                    (setf rep (append rep (list (format nil "\\tempo 4 = ~d" (round tempo))))) ;chg tempo into (round tempo) 'cause lily doesn't accept tempo floats !
                    (setf mem-mes (round tempo))) ;chg tempo into (round tempo)
                  ))

                (setf rep (append rep (cons-lil-expr-extr mes lastmes)))
                (setf rep (append rep (list (format nil  "|"))))
                (setf lastmes mes)
                )
          )


      (loop for mes in mesures
            for i = 1 then (+ i 1) do
            (setf *mesure-num* (incf *mesure-num*))
            (setf rep (append rep (list (format nil  "\%%%%%%%%%%%%%%%%%%%%%%% MESURE : ~d %%%%%%%%%%%%%%%%%%%%%%%" *mesure-num*))))
            (setf rep (append rep (cons-lil-expr-extr mes lastmes)))
            (setf rep (append rep (list (format nil  "|"))))
            (setf lastmes mes))
      )

    (setf rep (append rep (list (format nil"} ~% ~%"))))
    rep))

;symb-beat-val= For a key signature equivalent to 3//3 will be the half note (blanche)
;real-beat-val= For the same key sign, this will be the halfnote of a triplet (blanche de triolet)
;These refer to the beats in a measure, and for special cases using non-standard key signature

(defmethod cons-lil-expr-extr ((self om::measure) lastmes)
  (setf *chords-and-cont* (collect-chords  self))
  (setf *treeratios* (get-note-figure self))
  (setf *switch* nil)
  (let* ((inside (om::inside self))
         (tree (om::tree self))
         (real-beat-val (/ 1 (om::fdenominator (first tree))))
         (symb-beat-val (/ 1 (om::find-beat-symbol (om::fdenominator (first tree)))))
         (rep nil))
    ;(setf *mesure-num* (incf *mesure-num*))
    ;(setf rep (list (format nil  "\%%%%%%%%%%%%%%%%%%%%%%% MESURE : ~d %%%%%%%%%%%%%%%%%%%%%%%" *mesure-num*)))
    
    (unless (and lastmes (equal (first tree) (first (tree lastmes))))
      ;(setf *mesure-num* (incf *mesure-num*))
      ;(setf rep (list (format nil  "\%%%%%%%%%%%%%%%%%%%%%%% MESURE : ~d %%%%%%%%%%%%%%%%%%%%%%%" *mesure-num*)))
      (setf rep (list (format nil  "\\time ~d/~d" (om::fnumerator (first tree)) (om::fdenominator (first tree)))))
      )
    (loop for obj in inside do
          (setf rep (append rep 
                            (let* ((dur-obj-noire (/ (om::extent obj) (om::qvalue obj)))
                                   (factor (/ (* 1/4 dur-obj-noire) real-beat-val))
                                   (exp (cons-lil-expr-extr obj (* symb-beat-val factor))))
                              exp
                              )
                            )))
    rep))



(defmethod cons-lil-expr-extr ((self om::group) dur)
  (let* ((durtot (if (listp dur) (car dur) dur))
         (cpt (if (listp dur) (cadr dur) 0))
         (num (or (om::get-group-ratio self)  (om::extent self)))
         (denom (om::find-denom num durtot))
         (num (if (listp denom) (car denom) num))
         (denom (if (listp denom) (second denom) denom))
         (unite (/ durtot denom))
         (inside (om::inside self))
         (sympli (/ num denom))
         (rep nil) (val nil))
    ;(print durtot)
    (cond
     ((not (om::get-group-ratio self)) 
      (loop for obj in inside
            do (setf rep (append rep (let* ((dur-obj (/ (/ (om::extent obj) (om::qvalue obj)) 
                                                        (/ (om::extent self) (om::qvalue self)))))
                                       (cons-lil-expr-extr obj (* dur-obj durtot)))))))
     ((= sympli 1)
      (loop for obj in inside
            do (setf rep (append rep (let* ((operation (/ (/ (om::extent obj) (om::qvalue obj)) 
                                                          (/ (om::extent self) (om::qvalue self))))
                                            (dur-obj (numerator (/ (/ (om::extent obj) (om::qvalue obj)) 
                                                                   (/ (om::extent self) (om::qvalue self))))))
                                       (setf dur-obj (* dur-obj (/ num (denominator operation))))
                                       (cons-lil-expr-extr obj (* dur-obj unite)))))))
     
     (t
      (let ((pos (length rep))
            (depth 0))
        (setf rep (append rep (list (format nil "\\once \\override TupletBracket #'padding = #"))))
        (setf rep (append rep (list (format nil "\\tuplet ~d/~d {" num denom))))
        (loop for obj in inside do
              (setf rep (append rep (let* ((operation (/ (/ (om::extent obj) (om::qvalue obj)) 
                                                         (/ (om::extent self) (om::qvalue self))))
                                           (dur-obj (numerator operation))
                                           exp tmp)
                                      (setf dur-obj (* dur-obj (/ num (denominator operation))))
                                      (setf tmp (multiple-value-list 
                                                 (cons-lil-expr-extr obj (list (* dur-obj unite) cpt))))
                                      (setf exp (car tmp))
                                      (when (and (cadr tmp) (> (cadr tmp) depth))
                                        (setf depth (cadr tmp)))
                                      exp
                                      ))))
        (setf val (+ depth 1))
        (if (= depth 0)
          (setf (nth pos rep) "")
          (setf (nth pos rep) (string+ (nth pos rep) (format nil "~D" (float (* 3 depth)))))
          )
        (setf rep (append rep (list "}")))
        )
      ))
    (values rep val)))



(defun get-extra-text (liste)
  (remove 'nil 
  (loop for i in liste
        collect (if (text-extra-p i) (thetext i)))))


(defun get-extra-vel (liste)
  (remove 'nil 
  (loop for i in liste
        collect (if (vel-extra-p i) (thechar i)))))


(defmethod cons-lil-expr-extr ((self om::chord) dur)
  (let* ((notes (inside self))
        (extra (car (mapcar #'extra-obj-list notes)))
        (text (car (get-extra-text extra)))
        (vel (car (get-extra-vel extra)))
        (durtot (if (listp dur) (car dur) dur))
        (inside (om::inside self))
        (str "")) 

   ; (print (list "eeee" extra vel)) 
    
    (if (= (length inside) 1)
      (setf str (cons-lily-note (car inside)))
      (let ((notes ""))
        (loop for note in inside do (setf notes (string+ notes " " (cons-lily-note note)))) 
        (setf str (string+ "<" notes ">")))
      )
    (let* ((durconv (get-head-and-points durtot))
           (head (first durconv))
           (points (if (< 0 (second durconv))
                     (append-str (om::repeat-n "." (second durconv))))))
      
      (setf str (string+ str 
                         (if (not points)
                           (format nil "~d" head)
                           (format nil "~d~A" head points)
                           ))))
    (when (or (and (not (om::cont-chord-p self))
                   (om::cont-chord-p (om::next-container self '(om::chord))))
              (and (om::cont-chord-p self)
                   (om::cont-chord-p (om::next-container self '(om::chord))))
              )
      (setf str (string+ str "~"))
      )


    (if vel 
        (setf str (string+ str  (massq vel *vel-for-lil*)))
      )

    (if text     
        (setf str (string+ str  (format nil " ^\\markup{ ~S}" text)))
      )
    
    (list str)
    ))



                      
(defmethod cons-lil-expr-extr ((self om::rest) dur)
(let* ((durtot (if (listp dur) (car dur) dur))
       (durconv (get-head-and-points durtot))
           (head (first durconv))
           (points (if (< 0 (second durconv))
                     (append-str (om::repeat-n "." (second durconv))))))
  

                     (if (not points)
                       (list (format nil "r~d" head))
                       (list (format nil "r~d~A" head points))
                       )))




(defmethod cons-lily-note ((self om::note))
  (car (mc->lilynotes (list (midic self)))))



;;;;;;;;;;;;;;;;;;;;i/o and interface

;;;peut-etre ajouter l'encoding du text : unix
;;Attention:
;;Lily genere des erreur dues aux commentaires
;;;une fois que l'on les encodes en unix tout marche



(defun write-lil-file (list path paper layout)
  (let ((pathname (or path (om-choose-new-file-dialog)))
        (version (lilypond-version));;;inputs the current version of installe dlilypond
        )
    (setf *voice-num* 0)
    (setf *mesure-num* 0)
    (WITH-OPEN-FILE (out pathname :direction :output  :if-does-not-exist :create :if-exists :supersede)
      ;;;HERE COMES THE HEADER and GENERAL SETTINGS
     ; (format out "\\version \"2.18\"~%~%")
      (if version
      (format out "\\version \"~A\"~%~%" version )
        (format out "\\version \"2.18\"~%~%"))
      ;;;;page sizes
      (WITH-OPEN-FILE (in paper :direction :input)
        (loop 
         while (not (file-eof-p in))
         do (let ((line (read-line in)))
              (write-line  line out))))
      ;;;;The music
   
      ;;;;;
      (loop for elt in list do
            (format out "~A~%" elt))

      
         
      ;;;;layout templates
      (WITH-OPEN-FILE (in layout :direction :input)
        (loop 
         while (not (file-eof-p in))
         do (let ((line (read-line in)))
              (write-line  line out))))
      (format out "}~%~%~%")

 )
    pathname))


(defun run-lilypond (path)
  (let* ((lily-path (pathname-name *LILYPOND-PATH*))
         (pdf-path (pathname-name *PDF-READER-PATH*))
         (folder (pathname-directory path))
         (folderpath (make-pathname :directory folder))
         (outfile (make-pathname :directory folder :name (pathname-name path)))
         (pdffile (make-pathname :directory folder :name (pathname-name path) :type "pdf")))
    (print lily-path)

    (cond
     ((equal *om-os* :linux)
      (progn
        (om-cmd-line (format nil "cd ~s; sh -c '~s ~s'" 
                             (om-path2cmdpath folderpath) 
                             lily-path
                             (om-path2cmdpath path)))
        (om-cmd-line (format nil "~s ~s" pdf-path (om-path2cmdpath  pdffile)))
        pdffile))

     ((equal *om-os* :mac)
      (progn
        (om-cmd-line (format nil "cd ~s; bash -l -c '~s ~s'" 
                             (om-path2cmdpath folderpath) 
                             lily-path
                             (om-path2cmdpath path)))
         
        (om-cmd-line (format nil "open ~s" (om-path2cmdpath  pdffile)))
        pdffile))
     (t outfile))))



;---------------------get-D------------------------

(defun list-to-ratio (list)
"transform a simple list of 2 elmts into num/denom"
(/ (car list) (second list)))


(om::defmethod! get-measure ((self voice))
   :icon 134
   :indoc '("objekt")
   :initvals (list t)
   :doc "Give list of measures contained in <objekt>"
   (let* ((tree (tree self))
          (liste (mapcar #'first (cadr tree))))
     (mapcar #'list-to-ratio liste)))



(om::defmethod! get-measure ((self poly))
   :icon 134
   :indoc '("objekt")
   :initvals (list t)
   :doc "Give list of measures contained in <objekt>"
   (let* ((voices (inside self)))
     (mapcar #'get-measure voices)))


(defun binary-list (liste)
"tests if all list are binary fractions"
  (let ((test 't))
  (loop for i in liste
        while test
        do (setf test (is-binaire? i)))
  test))

;(binary-list '(1/2 1/4 1/31 2/2 1 ))
;;;;;;


(defmethod! om->lily-gen ((self poly) &optional 
                      (clef nil)
                      (paper "a3landmarg")
                      (layout "template")
                      (path nil))
            :icon 161
            :indoc '("self" "clef" "paper" "layout" "path" )
            :initvals '(t ("G") "a3landmarg" "temp1" t)
            :menuins '((2 (("A3 Landscape" "a3landmarg" )
                           ))
                       (3 (("template" "template")
                           )))
            :doc "Exports voice, poly,chordseq to lilypond format"
            (let* ((ressource-folder (lib-resources-folder (find-library "omlily")))
                   (paperfile (merge-pathnames (string+ "lily-templates/sizes/" paper ".ly") ressource-folder))
                   (layoutfile (merge-pathnames (string+ "lily-templates/layouts/" layout ".ly") ressource-folder))
                   (pathname (or path (om-choose-new-file-dialog)))
                   (lilyfile (write-lil-file (cons-lil-expr-extr self clef) pathname paperfile layoutfile))
                   )
                  
              (run-lilypond lilyfile)))


(defmethod! om->lily-gen ((self voice) &optional
                      (clef nil)
                      (paper "a3landmarg")
                      (layout "template")
                      (path nil))
            (let* ((ressource-folder (lib-resources-folder (find-library "omlily")))
                   (paperfile (merge-pathnames (string+ "lily-templates/sizes/" paper ".ly") ressource-folder))
                   (layoutfile (merge-pathnames (string+ "lily-templates/layouts/" layout ".ly") ressource-folder))
                   (pathname (or path (om-choose-new-file-dialog)))
                   (lilyfile 
                    (write-lil-file  (cons-lil-expr-extr (make-instance 'poly
                                                                        :voices self) clef ) pathname paperfile layoutfile))
                   )
                   
                   
              (run-lilypond lilyfile)))


(defmethod! om->lily ((self poly) &optional 
                      (clef nil)
                      (paper "a3landmarg")
                      (layout "template")
                      (path nil))
            :icon 161
            :indoc '("self" "clef" "paper" "layout" "path" )
            :initvals '(t ("G") "a3landmarg" "temp1" t)
            :menuins '((2 (("A3 Landscape" "a3landmarg" )
                           ))
                       (3 (("template" "template")
                           )))
            :doc "Exports voice, poly,chordseq to lilypond format"
            (let* ((ressource-folder (lib-resources-folder (find-library "omlily")))
                   (paperfile (merge-pathnames (string+ "lily-templates/sizes/" paper ".ly") ressource-folder))
                   (pathname (or path (om-choose-new-file-dialog)))
                   (binary? (binary-list (flat (get-measure self))))
                   (layoutfile
                    (if binary?
                        (merge-pathnames (string+ "lily-templates/layouts/" layout ".ly") ressource-folder)
                      (merge-pathnames (string+ "lily-templates/layouts/" "template1" ".ly") ressource-folder))
                    )
                    
                   (lilyfile 
                    (if binary?
                        (write-lil-file (cons-lil-expr-extr self clef) pathname paperfile layoutfile)
                      (write-lil-file (cons-lily-expr self clef nil) pathname paperfile layoutfile)
                      )))
              (run-lilypond lilyfile)))


(defmethod! om->lily ((self voice) &optional
                      (clef nil)
                      (paper "a3landmarg")
                      (layout "template")
                      (path nil))
            (let* ((ressource-folder (lib-resources-folder (find-library "omlily")))
                   (paperfile (merge-pathnames (string+ "lily-templates/sizes/" paper ".ly") ressource-folder))
                   (pathname (or path (om-choose-new-file-dialog)))
                   (binary? (binary-list (get-measure self)))
                   (layoutfile
                    (if binary?
                        (merge-pathnames (string+ "lily-templates/layouts/" layout ".ly") ressource-folder)
                      (merge-pathnames (string+ "lily-templates/layouts/" "template1" ".ly") ressource-folder))
                    )
                   (lilyfile 
                    (if binary?
                        (write-lil-file  (cons-lil-expr-extr (make-instance 'poly
                                                                 :voices self) clef ) pathname paperfile layoutfile)
                      (write-lil-file (cons-lily-expr (make-instance 'poly
                                                                 :voices self) clef nil) pathname paperfile layoutfile)
                      )))
                   
              (run-lilypond lilyfile)))


